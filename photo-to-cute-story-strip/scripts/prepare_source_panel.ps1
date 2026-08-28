[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [ValidateRange(0.0, 1.0)]
    [double]$FocusX = 0.5,

    [ValidateRange(0.0, 1.0)]
    [double]$FocusY = 0.5,

    [ValidateRange(1.0, 4.0)]
    [double]$Zoom = 1.0,

    [ValidateRange(600, 6000)]
    [int]$Width = 1536
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $SourcePath -PathType Leaf)) {
    throw "Input image does not exist: $SourcePath"
}

if (($Width % 6) -ne 0) {
    throw 'Width must be divisible by 6 so all four final panels can have equal integer dimensions.'
}

if (Test-Path -LiteralPath $OutputPath) {
    throw "Output already exists; choose a new path: $OutputPath"
}

$manifestPath = "$OutputPath.manifest.json"
if (Test-Path -LiteralPath $manifestPath) {
    throw "Manifest already exists; choose a new output path: $manifestPath"
}

foreach ($command in @('ffmpeg', 'ffprobe')) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "Required command is unavailable: $command"
    }
}

$outputDirectory = Split-Path -Parent $OutputPath
if ($outputDirectory -and -not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

function Get-ImageDimensions {
    param([string]$Path)

    $raw = & ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of 'csv=s=x:p=0' -- $Path
    if ($LASTEXITCODE -ne 0 -or $raw -notmatch '^(\d+)x(\d+)$') {
        throw "Could not read image dimensions: $Path"
    }

    return @([int]$Matches[1], [int]$Matches[2])
}

$sourceDimensions = Get-ImageDimensions -Path $SourcePath
$panelHeight = [int]($Width / 3)
$focusXText = "$FocusX" -replace ',', '.'
$focusYText = "$FocusY" -replace ',', '.'
$zoomText = "$Zoom" -replace ',', '.'

$cropX = "max(0\,min(iw-ow\,iw*${focusXText}-ow/2))"
$cropY = "max(0\,min(ih-oh\,ih*${focusYText}-oh/2))"
$filter = "scale=${Width}:${panelHeight}:force_original_aspect_ratio=increase," +
          "scale=iw*${zoomText}:ih*${zoomText}," +
          "crop=${Width}:${panelHeight}:${cropX}:${cropY},setsar=1,format=rgba"

$arguments = @(
    '-hide_banner', '-loglevel', 'error', '-n',
    '-i', $SourcePath,
    '-vf', $filter,
    '-frames:v', '1',
    $OutputPath
)

& ffmpeg @arguments
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $OutputPath -PathType Leaf)) {
    throw 'ffmpeg failed to create the canonical source panel.'
}

$outputDimensions = Get-ImageDimensions -Path $OutputPath
if ($outputDimensions[0] -ne $Width -or $outputDimensions[1] -ne $panelHeight) {
    throw "Unexpected output dimensions: $($outputDimensions[0])x$($outputDimensions[1]); expected ${Width}x${panelHeight}."
}

$manifest = @{
    mode = 'subject-aware-source-crop'
    source_path = (Resolve-Path -LiteralPath $SourcePath).Path
    source_sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $SourcePath).Hash
    source_dimensions = "$($sourceDimensions[0])x$($sourceDimensions[1])"
    target_aspect_ratio = '3:1'
    focus_x = $FocusX
    focus_y = $FocusY
    zoom = $Zoom
    output_path = (Resolve-Path -LiteralPath $OutputPath).Path
    output_sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $OutputPath).Hash
    output_dimensions = "$($outputDimensions[0])x$($outputDimensions[1])"
}

$manifest | ConvertTo-Json | Set-Content -Encoding utf8 -LiteralPath $manifestPath

Write-Output "Created: $OutputPath"
Write-Output "Dimensions: $($outputDimensions[0])x$($outputDimensions[1])"
Write-Output "Manifest: $manifestPath"

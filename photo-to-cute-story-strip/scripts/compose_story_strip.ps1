[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,

    [Parameter(Mandatory = $true)]
    [string]$TriptychPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [ValidateRange(0.0, 1.0)]
    [double]$FocusX = 0.5,

    [ValidateRange(0.0, 1.0)]
    [double]$FocusY = 0.5
)

$ErrorActionPreference = 'Stop'

foreach ($path in @($SourcePath, $TriptychPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Input image does not exist: $path"
    }
}

if (Test-Path -LiteralPath $OutputPath) {
    throw "Output already exists; choose a new path: $OutputPath"
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
$triptychDimensions = Get-ImageDimensions -Path $TriptychPath
$triptychRatio = $triptychDimensions[0] / [double]$triptychDimensions[1]

if ($triptychRatio -lt 0.80 -or $triptychRatio -gt 1.20) {
    throw "Triptych must be approximately square before compositing; actual dimensions are $($triptychDimensions[0])x$($triptychDimensions[1])."
}

$width = [int]$triptychDimensions[0]
if (($width % 2) -ne 0) {
    $width -= 1
}
$panelHeight = [int]($width / 3.0)
$expectedHeight = $width + $panelHeight

$focusXText = "$FocusX" -replace ',', '.'
$focusYText = "$FocusY" -replace ',', '.'

$filter = "[0:v]scale=${width}:${panelHeight}:force_original_aspect_ratio=increase,crop=${width}:${panelHeight}:(in_w-out_w)*${focusXText}:(in_h-out_h)*${focusYText},setsar=1[src];" +
          "[1:v]scale=${width}:${width}:force_original_aspect_ratio=increase,crop=${width}:${width}:(in_w-out_w)/2:(in_h-out_h)/2,setsar=1[trip];" +
          '[src][trip]vstack=inputs=2,format=rgba[out]'

$arguments = @(
    '-hide_banner', '-loglevel', 'error', '-n',
    '-i', $SourcePath,
    '-i', $TriptychPath,
    '-filter_complex', $filter,
    '-map', '[out]',
    '-frames:v', '1',
    $OutputPath
)

& ffmpeg @arguments
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $OutputPath -PathType Leaf)) {
    throw 'ffmpeg failed to create the story strip.'
}

$outputDimensions = Get-ImageDimensions -Path $OutputPath
if ($outputDimensions[0] -ne $width -or $outputDimensions[1] -ne $expectedHeight) {
    throw "Unexpected output dimensions: $($outputDimensions[0])x$($outputDimensions[1]); expected ${width}x${expectedHeight}."
}

$manifestPath = "$OutputPath.manifest.json"
if (Test-Path -LiteralPath $manifestPath) {
    throw "Manifest already exists; choose a new output path: $manifestPath"
}

$manifest = @{
    mode = 'fidelity-composite'
    source_path = (Resolve-Path -LiteralPath $SourcePath).Path
    source_sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $SourcePath).Hash
    source_dimensions = "$($sourceDimensions[0])x$($sourceDimensions[1])"
    triptych_path = (Resolve-Path -LiteralPath $TriptychPath).Path
    triptych_sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $TriptychPath).Hash
    triptych_dimensions = "$($triptychDimensions[0])x$($triptychDimensions[1])"
    focus_x = $FocusX
    focus_y = $FocusY
    output_path = (Resolve-Path -LiteralPath $OutputPath).Path
    output_sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $OutputPath).Hash
    output_dimensions = "$($outputDimensions[0])x$($outputDimensions[1])"
}

$manifest | ConvertTo-Json | Set-Content -Encoding utf8 -LiteralPath $manifestPath

Write-Output "Created: $OutputPath"
Write-Output "Dimensions: $($outputDimensions[0])x$($outputDimensions[1])"
Write-Output "Manifest: $manifestPath"

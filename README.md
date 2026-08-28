# Photo to Cute Story Strip

[简体中文](README.zh-CN.md)

A Codex Skill that turns one source photo into one vertical four-panel story strip:

1. original photo;
2. naive flat illustration;
3. textured children's-book print;
4. building-block diorama.

The Skill first tries a cohesive one-pass generation. If the generated top panel drifts from the source—or the user explicitly requires the actual original photo—it generates the lower three panels and deterministically prepends a crop of the source image.

## What it preserves

- subject identity, count, pose or action, gaze, silhouette, and camera direction;
- distinguishing colors, markings, props, and recognizable background anchors;
- fixed media order and a clean `3:4` stacked layout;
- exact source pixels in fidelity mode after deterministic resizing and cropping.

## Requirements

- Codex with the built-in image generation tool.
- For the optional fidelity fallback on Windows: PowerShell, `ffmpeg`, and `ffprobe` available on `PATH`.

The primary direct-generation path does not require an API key. The included compositor does not install dependencies or modify the source image.

## Install

Use the bundled Codex Skill installer.

macOS/Linux:

```bash
python ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --repo Adieuuuuuu/photo-to-cute-story-strip \
  --path photo-to-cute-story-strip
```

Windows PowerShell:

```powershell
python "$env:USERPROFILE\.codex\skills\.system\skill-installer\scripts\install-skill-from-github.py" `
  --repo Adieuuuuuu/photo-to-cute-story-strip `
  --path photo-to-cute-story-strip
```

Restart Codex or start a new task after installation so the Skill list refreshes.

## Use

Attach exactly one source photo, then invoke:

```text
$photo-to-cute-story-strip
```

Optional instructions can be appended, for example:

```text
$photo-to-cute-story-strip Keep the top panel as the actual original photo and use no decorative title.
```

## Workflow

The Skill:

1. inspects the source and writes a compact identity/composition anchor;
2. generates a complete four-panel image in one pass;
3. validates panel count, order, source fidelity, subject continuity, media separation, anatomy, text, and watermark absence;
4. switches to the deterministic fidelity fallback when the top panel is not trustworthy;
5. saves one final image and reports which mode won.

The fidelity compositor refuses to overwrite an existing output and writes a SHA-256 manifest beside the result.

## Repository layout

```text
photo-to-cute-story-strip/
|-- SKILL.md
|-- agents/
|   `-- openai.yaml
`-- scripts/
    `-- compose_story_strip.ps1
```

## Privacy

This repository contains no source photos, generated examples, credentials, API keys, or machine-specific paths. Your input image is not part of the Skill package.

## License

[MIT](LICENSE)

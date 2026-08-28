# Photo to Cute Story Strip

[简体中文](README.zh-CN.md)

A Codex Skill that turns one source photo into one vertical four-panel story strip:

1. original photo;
2. naive flat illustration;
3. textured children's-book print;
4. building-block diorama.

The default workflow accepts any common source aspect ratio, isolates the user-named or visually dominant subject, prepares and inspects one canonical `3:1` source crop, generates only the lower three styles from that crop, and mechanically prepends the real source pixels. A one-pass four-panel generation remains available only when the user explicitly accepts a generated top band.

## What it preserves

- a user-selected person, pet, animal, food dish, or object, even when other subjects are visible;
- subject identity, count, pose or action, gaze, silhouette, camera direction, and defining food details;
- distinguishing colors, markings, props, and recognizable background anchors;
- fixed media order and a clean `3:4` stacked layout;
- exact source pixels in the default workflow after deterministic, inspectable resizing and cropping.

## Requirements

- Codex with the built-in image generation tool.
- On Windows: PowerShell, `ffmpeg`, and `ffprobe` available on `PATH` for the canonical crop and compositor.

The built-in generation path does not require an API key. The included crop and compositor scripts do not install dependencies or modify the source image.

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
$photo-to-cute-story-strip Keep the large bowl in the center, exclude the dessert cup, and use no decorative title.
```

## Workflow

The Skill:

1. inspects the source, resolves the requested subject, and writes a compact identity/composition anchor;
2. prepares an exact `3:1` source panel with auditable focus and zoom values, then visually checks the crop;
3. generates a square three-band stack containing only the flat illustration, textured print, and brick diorama;
4. prepends the approved real source panel and validates exact dimensions, panel order, source fidelity, continuity, media separation, text, and watermark absence;
5. saves one final image and reports the selected subject and any unavoidable crop limitation.

Both helpers refuse to overwrite an existing output and write SHA-256 manifests beside their results.

## Repository layout

```text
photo-to-cute-story-strip/
|-- SKILL.md
|-- agents/
|   `-- openai.yaml
`-- scripts/
    |-- prepare_source_panel.ps1
    `-- compose_story_strip.ps1
```

## Privacy

This repository contains no source photos, generated examples, credentials, API keys, or machine-specific paths. Your input image is not part of the Skill package.

## License

[MIT](LICENSE)

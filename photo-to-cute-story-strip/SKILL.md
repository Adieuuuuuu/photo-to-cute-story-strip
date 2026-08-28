---
name: photo-to-cute-story-strip
description: Turn one source photo of any common aspect ratio into one standardized 3:4 vertical four-panel image ordered as the actual source crop, a naive flat illustration, a textured children's-book print, and a building-block diorama. Use when a user provides a person, pet, animal, food dish, or object photo, optionally names which visible subject to keep, and wants this specific stacked style progression; do not route arbitrary multi-photo collages here.
---

# Photo to Cute Story Strip

Create one finished image from one source photo. First normalize the requested subject to an inspected `3:1` source panel; use that same panel as the generation anchor and as the exact top band.

## Fixed output contract

- Accept one raster source image at any common aspect ratio. Deliver one exact `3:4` portrait image made of four equal, edge-to-edge horizontal bands. Every band is exactly `3:1`.
- Keep this order: original photo -> naive flat illustration -> textured storybook print -> building-block diorama.
- Use actual pixels from the prepared source crop in the top band. A model reconstruction is never the default and never counts as exact source preservation.
- Keep the same subject, count, pose or action, gaze, silhouette, camera direction, dominant colors, important props, and recognizable background anchors across all four bands.
- Do not add frames, gutters, rounded cards, arrows, panel labels, logos, signatures, watermarks, or explanatory copy.
- A short decorative title is optional. Use it only when it is obvious from visible content. Choose one neutral English phrase of one to three common words, render that exact phrase at most twice, and prohibit all other text. If accurate text would compete with the subject, use no text.

## Prepare the source anchor

1. Require exactly one source raster image. If several images are present, identify which is the source before generating. Treat screenshots that merely demonstrate the target layout as style references, never as edit targets.
2. Inspect a local source image with `view_image` before image generation.
3. Resolve the target subject:
   - a user-named person, animal, dish, or object always wins;
   - when no target is named, use the sole or visually dominant subject;
   - ask only when multiple plausible targets remain and choosing silently would materially change the result.
4. Write a compact anchor brief from visible evidence only:
   - subject type, count, distinguishing colors and markings;
   - pose or action, gaze, expression, and silhouette;
   - framing and subject position;
   - important props and one or two background anchors;
   - restrained palette shared by the generated panels;
   - for food, vessel silhouette and color, camera angle, broth or sauce color, garnish distribution, and several visually defining ingredients.
5. When text is appropriate, choose the short title now and quote it exactly in the prompt.

## Prepare the canonical 3:1 source panel

Do this before image generation. Estimate `FocusX` and `FocusY` as the target's normalized visual center and choose the smallest `Zoom` that removes unrelated distractors while retaining defining features.

- `Zoom 1.0`: maximum context; use when the target already dominates.
- `Zoom 1.15` to `1.6`: tighten a loose portrait or dish composition.
- `Zoom 1.6` to `2.5`: isolate one subject among several.
- Avoid values above `2.5` unless the user explicitly requests a very tight detail.

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-dir>\scripts\prepare_source_panel.ps1" `
  -SourcePath "<source-image>" `
  -OutputPath "<new-source-panel.png>" `
  -FocusX <0..1> -FocusY <0..1> -Zoom <1..4> -Width 1536
```

Inspect the prepared panel with `view_image`. It passes only when the requested target is unmistakable, defining features are not accidentally clipped, and unrelated nearby objects no longer read as co-subjects. Adjust focus or zoom once when needed. A very tall subject cannot fit fully inside a `3:1` band: keep its defining region by default; if the user explicitly requires the full subject, ask whether padding or generative outpainting is acceptable instead of silently clipping it.

## Default path: generate three styles, then prepend the source

Use the built-in `image_gen` tool with the canonical source panel as the sole reference. Request one square, edge-to-edge stack containing exactly three equal horizontal bands: naive flat illustration, textured storybook print, and building-block diorama. Do not ask the model to generate a source-photo band.

Build the prompt from this template, replacing bracketed fields with the anchor brief:

```text
Use case: identity-preserving three-style transformation from one prepared source crop
Asset type: one square three-band image that will become the lower three bands of a 3:4 story strip
Input images: Image 1 is the sole subject, crop, camera-direction, and palette reference

Primary request: show the exact same [TARGET_SUBJECT] from Image 1 in three unmistakably different media while preserving [ANCHOR_BRIEF]. Do not include any other nearby person, animal, dish, cup, plate, prop, or background object unless the anchor brief explicitly requires it.

Layout: exact square canvas; three equal full-width horizontal bands; every band is approximately 3:1; edge-to-edge; perfectly aligned boundaries; no source-photo band; no gutters, frames, borders, arrows, panel labels, or rounded corners.

Band 1: distinctly naive flat illustration, not watercolor realism; warm Korean-inspired editorial picture-book look; large simple flat color shapes; very limited shading; chunky slightly uneven hand-drawn contours; restrained dry-crayon speckle; airy pale background. Preserve [ANCHORS]. [TITLE_RULE]

Band 2: vintage children's-book gouache and woodblock print; deeper navy, muted cream, dusty ochre, and source-derived colors; visible paper grain and imperfect ink edges; quiet fairy-tale atmosphere. Preserve [ANCHORS]. No text.

Band 3: physically plausible miniature sculpture made entirely from interlocking toy building bricks with visible studs and stepped geometry; same viewpoint and framing; small tabletop set derived only from the selected subject; soft product-photography light. Preserve [ANCHORS]. [TITLE_RULE]

For food: preserve the vessel silhouette, viewing angle, broth or sauce color, garnish placement, and defining visible ingredients; keep the dish appetizing; do not invent side dishes or tableware.

Cross-panel continuity: [ANCHOR_BRIEF]. Keep subject count, silhouette, orientation, dominant colors, and crop consistent in all three bands.
Text: [EXACT_TITLE_OR_NO_TEXT]. Never invent extra letters, captions, logos, signatures, or watermarks.
Avoid: extra subjects, changed species or dish, mirrored orientation, missing or duplicated anatomy or ingredients, generic clip-art, realistic fur rendering or watercolor wash in band 1, heavy print texture in band 1, glossy 3D in illustration bands, smooth clay or pixels in the brick band, UI chrome.
```

Inspect the generated triptych. Then compose it with the already approved canonical panel:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-dir>\scripts\compose_story_strip.ps1" `
  -SourcePath "<prepared-source-panel.png>" `
  -TriptychPath "<generated-three-band-image>" `
  -OutputPath "<new-output.png>"
```

The compositor refuses to overwrite, normalizes the triptych width to a multiple of six, creates four exactly equal-height bands, and writes a source-panel SHA-256 manifest beside the final image.

## Optional path: direct four-panel generation

Use this only when the user explicitly prioritizes seamless one-pass rendering and accepts a generated reconstruction in the top band. Use the canonical source panel as the reference/edit target. Ask for a single complete four-panel image in one call. Do not use an API-key CLI merely for sizing or fidelity control.

Build the prompt from this template, replacing bracketed fields with the anchor brief:

```text
Use case: illustration-story with identity-preserving style transfer
Asset type: one finished 3:4 vertical four-panel story strip
Input images: Image 1 is the prepared 3:1 subject crop and the sole subject and composition reference

Primary request: create one cohesive four-band image that shows the exact same [SUBJECT] in four media stages. The top band must remain a photorealistic reconstruction of Image 1, while the next three bands reinterpret the same subject without changing identity, count, pose/action, gaze, silhouette, or camera direction.

Layout: exact 3:4 portrait canvas; four equal full-width horizontal bands; every band is approximately 3:1; edge-to-edge; perfectly aligned boundaries; no gutters, frames, borders, arrows, labels, or rounded corners.

Band 1 — source photo: photorealistic and visually indistinguishable from Image 1 at normal viewing size. Match the same crop, subject placement, lighting, background, colors, markings, expression, and small details. Do not beautify, restage, stylize, or add anything.

Band 2 — distinctly naive flat illustration, not watercolor realism: warm Korean-inspired editorial picture-book look; large simple flat color shapes; very limited shading; chunky, slightly uneven hand-drawn contours; simplified fur or surface masses instead of realistic strands; restrained dry-crayon speckle only; airy pale background. Preserve [ANCHORS]. [TITLE_RULE]

Band 3 — textured storybook print: vintage children's-book gouache and woodblock texture; deeper navy, muted cream, dusty ochre, and source-derived colors; visible paper grain and imperfect ink edges; quiet fairy-tale atmosphere. Preserve [ANCHORS]. No text.

Band 4 — building-block diorama: a physically plausible miniature sculpture made entirely from interlocking toy building bricks with visible studs and stepped geometry; same pose and framing; small tabletop set derived from the original background; soft product-photography light. Preserve [ANCHORS]. [TITLE_RULE]

Cross-panel continuity: [ANCHOR_BRIEF]. The subject must read as the same individual in all four bands. Keep the palette connected while making the three generated media unmistakably different.

Text: [EXACT_TITLE_OR_NO_TEXT]. Never invent extra letters, captions, logos, signatures, or watermarks.
Avoid: extra subjects, changed species or identity, mirrored pose, changed gaze, altered markings, missing or duplicated anatomy, generic clip-art, realistic fur rendering or watercolor wash in band 2, heavy paper texture in band 2, glossy 3D in the illustration bands, smooth clay in the brick band, fake collage shadows, UI chrome.
```

For `[TITLE_RULE]`, use `integrate the exact title "..." once as small hand lettering with ample negative space` in band 2 and `render the same exact title once in simple brick-built lettering` in band 4. Otherwise use `no text`.

## Inspect and decide

Inspect the actual generated bitmap before accepting it. An optional direct result passes only when all of these are true:

- there are exactly four horizontal bands in the fixed order and roughly equal heights;
- band 1 is photorealistic and matches the source subject, crop, pose, colors, lighting, and background without salient drift;
- the same individual and pose/action remain recognizable in bands 2–4;
- flat illustration, textured print, and brick diorama are clearly different physical media;
- the brick band has visible studs and constructed geometry rather than plush, clay, pixels, or generic 3D;
- any requested title is spelled exactly and no other text or watermark appears;
- no band has broken anatomy, accidental duplicates, separators, or app UI.

If only one localized problem exists, make one targeted edit and repeat every invariant. If band 1 has material source drift, do not keep asking the model to reproduce it: return to the default canonical-panel workflow. When the user requires actual original-photo pixels at the top, a generated reconstruction never counts as exact even when it looks close.

## Raw-source compatibility mode

The compositor can still accept a raw non-`3:1` source for backward compatibility. Prefer the inspected two-step canonical-panel workflow because it catches a bad subject crop before spending a generation call.

1. Ask the built-in `image_gen` tool for a square, edge-to-edge three-band stack containing only bands 2–4. Use the same anchor brief and style definitions. Require three equal full-width horizontal bands, no source-photo band, no separators, and the same subject continuity.
2. Copy the selected generated triptych into the current workspace; do not leave a project deliverable only in the generator's default storage.
3. Choose `FocusX` and `FocusY` as the target's normalized visual center, each from `0` to `1`, and choose `Zoom` from `1` to `4` using the same crop rules above.
4. Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-dir>\scripts\compose_story_strip.ps1" `
  -SourcePath "<source-image>" `
  -TriptychPath "<generated-three-band-image>" `
  -OutputPath "<new-output.png>" `
  -FocusX <0..1> -FocusY <0..1> -Zoom <1..4>
```

The helper requires `ffmpeg` and `ffprobe`, refuses to overwrite, normalizes the triptych to a square, crops the original photo to the top `3:1` band around the chosen focus, and writes a source-hash manifest beside the output. This mode is not the default because the crop cannot be visually approved before generation.

## Final validation and handoff

- Inspect the final file, not just the generation response.
- Confirm the output is exactly `W x (4W/3)`, `W` is divisible by six, all four bands are equal height, and both crop and final manifests record SHA-256 provenance.
- Prefer the default canonical-panel result. Use the optional direct result only when the user knowingly accepts a generated top band.
- Save the accepted image under the task's output directory with a descriptive, non-overwriting name such as `<source-stem>-cute-story-strip.png`.
- Return the image inline when supported, state whether canonical fidelity or optional direct mode was used, report the saved path, and briefly name any remaining visual limitation. Do not call a generation successful before visual inspection.

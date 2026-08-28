---
name: photo-to-cute-story-strip
description: Turn one source photo into one 3:4 vertical four-panel image ordered as the original photo, a naive flat illustration, a textured children's-book print, and a building-block diorama. Use when a user provides a single person, pet, animal, or cute-object photo and wants this specific stacked style progression; do not route arbitrary multi-photo collages here.
---

# Photo to Cute Story Strip

Create one finished image from one source photo. The invocation is one user action even when the fidelity fallback needs a second generation call.

## Fixed output contract

- Deliver one `3:4` portrait image made of four equal, edge-to-edge horizontal bands. Each band is approximately `3:1`.
- Keep this order: original photo -> naive flat illustration -> textured storybook print -> building-block diorama.
- Keep the same subject, count, pose or action, gaze, silhouette, camera direction, dominant colors, important props, and recognizable background anchors across all four bands.
- Do not add frames, gutters, rounded cards, arrows, panel labels, logos, signatures, watermarks, or explanatory copy.
- A short decorative title is optional. Use it only when it is obvious from visible content. Choose one neutral English phrase of one to three common words, render that exact phrase at most twice, and prohibit all other text. If accurate text would compete with the subject, use no text.

## Prepare the source anchor

1. Require exactly one source raster image. If several images are present, identify which is the source before generating. Treat screenshots that merely demonstrate the target layout as style references, never as edit targets.
2. Inspect a local source image with `view_image` before image generation.
3. Write a compact anchor brief from visible evidence only:
   - subject type, count, distinguishing colors and markings;
   - pose or action, gaze, expression, and silhouette;
   - framing and subject position;
   - important props and one or two background anchors;
   - restrained palette shared by the generated panels.
4. When text is appropriate, choose the short title now and quote it exactly in the prompt.

## Default path: direct four-panel generation

Use the built-in `image_gen` tool with the source photo as the reference/edit target. Ask for a single complete four-panel image in one call. Do not use an API-key CLI merely for sizing or fidelity control.

Build the prompt from this template, replacing bracketed fields with the anchor brief:

```text
Use case: illustration-story with identity-preserving style transfer
Asset type: one finished 3:4 vertical four-panel story strip
Input images: Image 1 is the sole subject and composition reference

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

Inspect the actual generated bitmap before accepting it. The direct result passes only when all of these are true:

- there are exactly four horizontal bands in the fixed order and roughly equal heights;
- band 1 is photorealistic and matches the source subject, crop, pose, colors, lighting, and background without salient drift;
- the same individual and pose/action remain recognizable in bands 2–4;
- flat illustration, textured print, and brick diorama are clearly different physical media;
- the brick band has visible studs and constructed geometry rather than plush, clay, pixels, or generic 3D;
- any requested title is spelled exactly and no other text or watermark appears;
- no band has broken anatomy, accidental duplicates, separators, or app UI.

If only one localized problem exists, make one targeted edit and repeat every invariant. If band 1 has material source drift, do not keep asking the model to reproduce it: switch to the fidelity fallback. When the user explicitly requires the actual original photo or unchanged source pixels at the top, a generated reconstruction never counts as exact even when it looks close; the final result must use the fidelity fallback.

## Fidelity fallback: generate three bands, then prepend the source

1. Ask the built-in `image_gen` tool for a square, edge-to-edge three-band stack containing only bands 2–4. Use the same anchor brief and style definitions. Require three equal full-width horizontal bands, no source-photo band, no separators, and the same subject continuity.
2. Copy the selected generated triptych into the current workspace; do not leave a project deliverable only in the generator's default storage.
3. Choose `FocusX` and `FocusY` from the visible subject position, each from `0` to `1`. Use `0.5,0.5` when centered; bias toward the head or face when a wide source crop is required.
4. Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-dir>\scripts\compose_story_strip.ps1" `
  -SourcePath "<source-image>" `
  -TriptychPath "<generated-three-band-image>" `
  -OutputPath "<new-output.png>" `
  -FocusX <0..1> -FocusY <0..1>
```

The helper requires `ffmpeg` and `ffprobe`, refuses to overwrite, normalizes the triptych to a square, crops the original photo to the top `3:1` band around the chosen focus, and writes a source-hash manifest beside the output.

## Final validation and handoff

- Inspect the final file, not just the generation response.
- For a fallback result, confirm the output is `W x (W + round(W/3))` and the manifest records the source SHA-256.
- Prefer the direct result when it passes because its light, palette, and boundaries are more unified. Prefer the fallback whenever preserving the actual source photo matters more than seamless generation.
- Save the accepted image under the task's output directory with a descriptive, non-overwriting name such as `<source-stem>-cute-story-strip.png`.
- Return the image inline when supported, state whether direct or fidelity mode won, report the saved path, and briefly name any remaining visual limitation. Do not call a generation successful before visual inspection.

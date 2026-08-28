# Repository rules

## Purpose

Publish the reusable `photo-to-cute-story-strip` Codex Skill as a standalone public GitHub repository.

## Structure

- `photo-to-cute-story-strip/`: installable Skill source.
- `README.md`: English landing page and installation instructions.
- `README.zh-CN.md`: Chinese documentation.
- `LICENSE`: MIT license.

## Behavioral contract

- Accept one raster source image at any common aspect ratio. A user-named person, animal, food item, or object is the target; when no target is named, use the sole or visually dominant subject.
- Normalize the real source photo to one inspected `3:1` subject-aware panel before generation. All four final bands must share that exact aspect ratio and equal height.
- The default fidelity workflow is: prepare the canonical source panel, generate only the three stylized panels from it, then prepend the canonical panel mechanically. The top band must retain real source pixels rather than a model reconstruction.
- Keep direct one-pass four-panel generation only as an explicit alternative for users who prioritize seamless rendering over exact source preservation.
- Cropping parameters must be deterministic and auditable. Never silently replace a requested subject, include unrelated nearby objects as co-subjects, or claim a crop is acceptable before inspecting it.
- Do not commit source photos, generated tests, crop manifests, or machine-specific paths. Public examples must be separately licensed and intentionally added.

## Public-release constraints

- Never include the user's source photo, generated test images, local manifests, credentials, tokens, absolute user paths, private repository data, or test-only dependencies.
- Keep the installable Skill byte-identical to the validated public-safe deliverable unless a documented public-path correction is required.
- Use the official Codex Skill installer command with repository path `photo-to-cute-story-strip`.
- Validate the Skill, scan for secrets and machine-specific paths, and inspect the staged diff before every public push.
- The repository is public under `Adieuuuuuu/photo-to-cute-story-strip`; the default branch is `main`.
- Do not force-push, rewrite history, publish releases/packages, or add CI secrets.

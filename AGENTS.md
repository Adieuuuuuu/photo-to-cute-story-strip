# Repository rules

## Purpose

Publish the reusable `photo-to-cute-story-strip` Codex Skill as a standalone public GitHub repository.

## Structure

- `photo-to-cute-story-strip/`: installable Skill source.
- `README.md`: English landing page and installation instructions.
- `README.zh-CN.md`: Chinese documentation.
- `LICENSE`: MIT license.

## Public-release constraints

- Never include the user's source photo, generated test images, local manifests, credentials, tokens, absolute user paths, private repository data, or test-only dependencies.
- Keep the installable Skill byte-identical to the validated public-safe deliverable unless a documented public-path correction is required.
- Use the official Codex Skill installer command with repository path `photo-to-cute-story-strip`.
- Validate the Skill, scan for secrets and machine-specific paths, and inspect the staged diff before every public push.
- The repository is public under `Adieuuuuuu/photo-to-cute-story-strip`; the default branch is `main`.
- Do not force-push, rewrite history, publish releases/packages, or add CI secrets.

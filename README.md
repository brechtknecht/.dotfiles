# .dotfiles

Personal dotfiles for macOS.

## Contents

| File | Description |
|------|-------------|
| `.zshrc` | Zsh config — Oh My Zsh, aliases, git helpers (`git-history`, `git-yeet`, `git-diff`), Playwright QA runner (`pwqa`) |
| `.config/ghostty/themes/e-paper-dark` | Custom Ghostty dark theme (e-paper palette) |
| `.config/ghostty/themes/e-paper-light` | Custom Ghostty light theme (e-paper palette) |

## Setup

```sh
# Clone into home directory
git clone https://github.com/brechtknecht/.dotfiles.git ~

# Create a local secrets file (not committed)
cp ~/.env.example ~/.env  # or create from scratch
```

## Secrets

Sensitive tokens (`NPM_TOKEN`, `FIGMA_OAUTH_TOKEN`, `GITLAB_TOKEN`) live in `~/.env` which is sourced by `.zshrc` at startup. This file is **not** tracked — create it manually on each machine:

```sh
export NPM_TOKEN=...
export FIGMA_OAUTH_TOKEN=...
export GITLAB_TOKEN=...
```

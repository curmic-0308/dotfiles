# OpenCode + Oh My OpenCode Dotfiles

Personal dotfiles for [OpenCode](https://opencode.ai/) with [Oh My OpenCode](https://github.com/code-yeongyu/oh-my-openagent).

## Contents

| File | Purpose |
|------|---------|
| `opencode\opencode.jsonc` | OpenCode main configuration (plugins, LSP, agents) |
| `opencode\oh-my-openagent.json` | Oh My OpenCode agents, categories, and background task settings |
| `opencode\tui.json` | TUI plugin configuration |

## Usage

### First install

```powershell
git clone https://github.com/curmic-0308/dotfiles.git
cd dotfiles
.\install.ps1
```

This copies all files from `opencode\` to `$env:APPDATA\opencode`.

### Updating

1. Modify files in the `opencode\` folder
2. Commit and push to GitHub
3. On another PC (or after a fresh install): pull latest and re-run `.\install.ps1`

## Requirements

- Windows
- OpenCode installed (config lives under `%APPDATA%\opencode`)

# dotfiles bootstrap

Minimal bootstrap to set up a new machine with my dotfiles from Forgejo.

## Usage

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/philhug/dotfiles/main/bootstrap.sh)"
```

## What it does

1. Installs `git` and `git-credential-oauth` (supports pacman, apt, dnf)
2. Configures git credential helpers for OAuth2
3. Installs `chezmoi`
4. Runs `chezmoi init --apply` from `code.homenet.ge/hug/dotfiles`

A browser window will open for Forgejo OAuth2 authentication.
Use your phone's Bitwarden passkey to authenticate.

## What it does NOT do

- Install packages beyond git + credential helper
- Set up age keys (chezmoi handles that)
- Configure shell, SSH, or other dotfiles (comes from the private repo)

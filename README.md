# TermConfig

My terminal setup: the configs for zsh, Ghostty, herdr, worktrunk, git and fresh, plus a few helper scripts. Configs are symlinked into `$HOME` with [GNU Stow](https://www.gnu.org/software/stow/), so edits made in place go straight into the repo.

## Quick start

1. **Install Homebrew**

   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Clone and install**

   ```sh
   git clone https://github.com/bmiller/TermConfig.git ~/TermConfig
   cd ~/TermConfig
   ./install.sh
   ```

   This runs `brew bundle` on the [`Brewfile`](Brewfile) and then stows every config package into `$HOME`.

3. **Finish the [manual setup](#manual-setup)** below, then reload:

   ```sh
   source ~/.zshrc
   herdr server reload-config
   ```

> **Existing files:** Stow won't overwrite a real file that's already in place (for example a default `~/.zshrc`). Back it up and delete it, then re-run `./install.sh`. Or run `stow --adopt -t ~ <package>` followed by `git checkout .` to replace it with the repo version.

## What's included

### Configs

| Package     | Links to                         |
| ----------- | -------------------------------- |
| `zsh`       | `~/.zshrc`                       |
| `ghostty`   | `~/.config/ghostty/config`       |
| `herdr`     | `~/.config/herdr/config.toml` and `~/.config/herdr/plugins/config/herdr-file-viewer/config.toml` |
| `worktrunk` | `~/.config/worktrunk/config.toml`|
| `git`       | `~/.config/git/ignore`           |
| `fresh`     | `~/.config/fresh/config.json`    |
| `scripts`   | `~/.local/bin/*.sh`              |

### Scripts

These are installed to `~/.local/bin`, which `.zshrc` puts on your `PATH`.

- **`clean-derived-data.sh`**: deletes the Xcode DerivedData folders for a worktree. worktrunk runs it automatically as a `pre-remove` hook.

### Tools (from the Brewfile)

| Tool | Description |
| ---- | ----------- |
| [Ghostty](https://ghostty.org) | Terminal app |
| MesloLG Nerd Font | Font with icons, used by Ghostty and eza |
| zsh-autosuggestions | Suggests commands from your history as you type |
| zsh-syntax-highlighting | Highlights commands as you type them |
| eza | A better `ls` (aliased to `ls`) |
| zoxide | A better `cd` that remembers directories you've visited; jump back with part of the name |
| bat | `cat` with syntax highlighting |
| fzf | Interactive fuzzy picker |
| gh | GitHub CLI |
| jq | Command-line JSON processor |
| lazygit | Terminal UI for git |
| fresh (`fresh-editor`) | Terminal text editor; set as `$EDITOR` in `.zshrc` |
| mole | Cleans up files to free disk space |
| taproom | Terminal UI for Homebrew |
| worktrunk | Git worktree manager (`wt`) |
| [herdr](https://herdr.dev) | Terminal multiplexer and agent coordinator |
| stow | Symlinks the configs in this repo |
| gitleaks | Scans commits for secrets (pre-commit hook) |

## Manual setup

These steps can't go in the Brewfile.

### GitHub CLI

```sh
gh auth login
```

### Node.js (via nvm)

The herdr skill install below uses `npx`, so you need a current Node. Install it with [nvm](https://github.com/nvm-sh/nvm). `.zshrc` already loads nvm when it's present.

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh | bash
source ~/.zshrc
nvm install --lts
```

> **Old Node already installed?** If `npx` fails with `npm ERR! cb.apply is not a function`, the machine is using an old system npm. Installing nvm and running `nvm install --lts` fixes it.
>
> **Check `.zshrc` afterward:** the nvm installer may add its own loading lines to `~/.zshrc`, which is a symlink into this repo. `.zshrc` already has them, so throw the extra lines away with `git -C ~/TermConfig checkout zsh/.zshrc`.

### herdr

Install the Claude integration ([docs](https://herdr.dev/docs/integrations/)):

```sh
herdr integration install claude
```

Install the agent skill:

```sh
npx skills add herdrdev/herdr --skill herdr -g
```

Install the plugins (the keybindings in `config.toml` depend on them):

```sh
herdr plugin install crokily/herdr-lazygit
herdr plugin install devashish2203/herdr-worktrunk
herdr plugin install smarzban/herdr-file-viewer
```

### Machine-specific settings and secrets

`.zshrc` sources `~/.zshrc.local` if it exists. That file isn't tracked, so use it for API keys and anything that should only apply to one machine:

```sh
# ~/.zshrc.local
export OPENROUTER_API_KEY='...'
```

### Secret scanning

`install.sh` turns on a pre-commit hook (`.githooks/pre-commit`) that runs [gitleaks](https://github.com/gitleaks/gitleaks) on staged changes. If it finds something that looks like a secret, the commit is blocked. To fix it, move the value into `~/.zshrc.local`. For a false positive, add a `gitleaks:allow` comment on that line.

If you cloned the repo without running `install.sh`, enable the hook yourself:

```sh
git config core.hooksPath .githooks
```

## Day-to-day

- **Edit configs in place** (for example `~/.config/ghostty/config`). They're symlinks, so the change shows up in the repo right away. Commit and push.
- **On other machines**, run `git pull`. Configs that are already linked update immediately.
- **New package or new file in a package:** re-run `./install.sh`, or `stow --no-folding -t ~ <package>`.
- **Adding a new config:** mirror its path under a new package folder (for example `foo/.config/foo/config`), add the package to `PACKAGES` in `install.sh`, and run it.
- **Adding a Homebrew tool:** add it to the `Brewfile`, then run `brew bundle`.

Always use `--no-folding` with stow. Without it, Stow may symlink a whole directory like `~/.config/herdr`, and then herdr's logs, sockets and session files would end up inside the repo.

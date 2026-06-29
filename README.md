# dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io).

This repo doubles as the chezmoi **source directory** — it is *not* at the default
`~/.local/share/chezmoi`. The source dir is pinned to `~/Documents/dotfiles` in the
machine-local config (`~/.config/chezmoi/chezmoi.toml`).

## How this repo is laid out

```
~/Documents/dotfiles/                 # repo root = chezmoi sourceDir
├── README.md                         # this file
├── archived/                         # legacy bash/vim configs (NOT managed by chezmoi)
├── .chezmoiroot                      # contains "home" -> chezmoi's real source root
└── home/                             # everything chezmoi manages lives here
    ├── .chezmoi.toml.tmpl            # generates ~/.config/chezmoi/chezmoi.toml; prompts name/email
    ├── .chezmoiignore                # paths chezmoi must never write / manage (incl. secrets)
    ├── Brewfile                      # Homebrew packages (read by the bootstrap script)
    ├── .chezmoiscripts/
    │   └── run_onchange_after_install-packages.sh.tmpl   # runs `brew bundle` when Brewfile changes
    ├── dot_zshrc                     # -> ~/.zshrc
    ├── dot_zprofile                  # -> ~/.zprofile
    ├── dot_gitconfig.tmpl            # -> ~/.gitconfig (identity templated from prompts)
    ├── private_dot_ssh/config        # -> ~/.ssh/config  (private; keys NOT managed)
    ├── dot_config/
    │   ├── git/ignore                # -> ~/.config/git/ignore
    │   └── private_gh/private_config.yml  # -> ~/.config/gh/config.yml  (hosts.yml excluded)
    └── private_Library/private_Application Support/Code/User/settings.json
                                       # -> ~/Library/Application Support/Code/User/settings.json
```

Because `.chezmoiroot` points at `home/`, the repo-root files (`README.md`, `archived/`)
are invisible to chezmoi and stay as ordinary git files.

### Source-name conventions

chezmoi encodes target metadata in the source filename:

| Prefix / suffix | Meaning |
|---|---|
| `dot_` | leading `.` in the target (`dot_zshrc` → `~/.zshrc`) |
| `private_` | target gets `0600`/`0700` perms (group/other stripped) |
| `.tmpl` | rendered as a Go template at apply time |

Never rename these by hand — use `chezmoi add`, `chezmoi chattr`, or `chezmoi edit`.

---

## Day-to-day usage

chezmoi has two sides: the **source** (this repo, where files carry `dot_`/`.tmpl`
names) and the **destination** (`$HOME`, the real files). `apply` pushes source →
home; `add`/`re-add` pull home → source.

> Always run `chezmoi diff` before `chezmoi apply`. It shows exactly what would change.

### Common commands

| Command | What it does |
|---|---|
| `chezmoi edit <file>` | Edit the **source** version of a managed file (e.g. `chezmoi edit ~/.zshrc`). Add `--apply` to apply on save. |
| `chezmoi add <file>` | Start managing a **new** file that exists in `$HOME`. |
| `chezmoi re-add` | Pull edits you made **directly** to already-managed live files back into the source. Does *not* pick up new files. |
| `chezmoi diff` | Preview source → home changes. Run before every apply. |
| `chezmoi apply` | Make `$HOME` match the source (renders templates, fixes perms, runs scripts). |
| `chezmoi managed` | List every path chezmoi manages. |
| `chezmoi cat ~/.gitconfig` | Show the **rendered** result of a templated file. |
| `chezmoi cd` | Open a subshell in this repo for git operations. |
| `chezmoi doctor` | Health check. |

### Editing an existing managed file

```sh
chezmoi edit ~/.zshrc        # edits the source (home/dot_zshrc)
chezmoi diff                 # review
chezmoi apply                # apply to $HOME
```

If instead you edited the **live** file directly (e.g. opened `~/.zshrc` in an editor):

```sh
chezmoi re-add               # pulls your live edits back into the source
chezmoi diff                 # should now be empty
```

### Adding a brand-new file

```sh
chezmoi add ~/.config/foo/config.toml        # plain file
chezmoi add --template ~/.somerc             # store as a template
chezmoi add --encrypt ~/.secret              # store age-encrypted (see Secrets)
```

### Commit & push (autoCommit/autoPush are OFF)

Nothing leaves your machine until you push. After any change:

```sh
chezmoi cd
git add -A
git commit -m "Describe the change"
git push
exit
```

### Adding/changing Homebrew packages

Edit the package list, then let the bootstrap script reconcile:

```sh
brew bundle dump --force --file="$HOME/Documents/dotfiles/home/Brewfile"   # snapshot current state
chezmoi diff                 # the run_onchange script re-runs only when the Brewfile hash changes
chezmoi apply                # runs `brew bundle`
```

### Git identity

`~/.gitconfig` is a template; `name`/`email` come from values prompted **once** at
`chezmoi init` and stored in `~/.config/chezmoi/chezmoi.toml`. To change them:

```sh
chezmoi edit-config          # edit the [data] name/email, then:
chezmoi apply
```

---

## Bootstrapping a new machine

On a fresh macOS machine:

1. **Install prerequisites** — [Homebrew](https://brew.sh) (and the Xcode CLT it pulls in):

   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Clone this repo to the expected location** (the source dir is pinned to
   `~/Documents/dotfiles`):

   ```sh
   git clone git@github.com:vindir/dotfiles.git ~/Documents/dotfiles
   ```

   > If SSH isn't set up yet, clone over HTTPS and switch the remote to SSH later:
   > `git clone https://github.com/vindir/dotfiles.git ~/Documents/dotfiles`

3. **Init + apply with chezmoi** (install chezmoi via Homebrew first):

   ```sh
   brew install chezmoi
   chezmoi init --source="$HOME/Documents/dotfiles" --apply
   ```

   This prompts for your git name/email, renders all configs into `$HOME`, and runs
   `brew bundle` to install every package in the Brewfile.

4. **Restore secrets manually** (intentionally *not* in the repo):
   - SSH private keys (`~/.ssh/id_ed25519`, `id_ed25519_signing`, `id_ed25519_authkey`)
     — copy from your password manager / secure backup, then
     `chmod 600 ~/.ssh/id_ed25519*`.
   - `gh auth login` to regenerate `~/.config/gh/hosts.yml`.

5. **Verify:**

   ```sh
   chezmoi doctor
   git config user.email        # should show your identity
   exec zsh                     # reload the shell
   ```

One-liner equivalent (installs chezmoi too), once the repo is cloned:

```sh
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --source="$HOME/Documents/dotfiles" --apply
```

---

## Merging a config from another machine

When a machine has a **local version of a file that chezmoi already manages** (e.g.
you tweaked `~/.zshrc` on a laptop whose changes never made it into the repo), don't
blindly `apply` (overwrites the local file) or `re-add` (overwrites the repo).
Reconcile them so the **best of both** is kept.

### Option A — interactive 3-way merge (preferred)

```sh
chezmoi merge ~/.zshrc
```

This opens your merge tool (`vimdiff` by default) with three panes — the current
**source**, the **destination** (live file), and the merge target — so you can pick the
best lines from each. Save the merged result; it's written back to the **source**. Then:

```sh
chezmoi diff                 # confirm
chezmoi apply                # push the merged version to $HOME
```

Merge *every* file that differs in one pass:

```sh
chezmoi merge-all
```

Configure a nicer merge tool in `~/.config/chezmoi/chezmoi.toml` if desired:

```toml
[merge]
    command = "nvim"
    args = ["-d", "{{ .Destination }}", "{{ .Source }}", "{{ .Target }}"]
```

### Option B — inspect, then choose a direction

1. See how the live file differs from the source:

   ```sh
   chezmoi diff ~/.zshrc
   ```

2. If the **live** file is the better version, pull it into the source:

   ```sh
   chezmoi re-add ~/.zshrc
   ```

   If the **source** (repo) is the better version, push it onto the machine:

   ```sh
   chezmoi apply ~/.zshrc
   ```

### Recommended cross-machine routine

On each machine, before making changes, sync from the remote first:

```sh
chezmoi update               # git pull --autostash --rebase, then apply
```

If `update`'s apply would clobber good local edits, stop and use `chezmoi merge`
instead, then commit & push the reconciled source so other machines get the best
version:

```sh
chezmoi merge ~/.zshrc
chezmoi cd && git add -A && git commit -m "Merge zshrc from <machine>" && git push && exit
```

---

## Secrets — what is NOT in this repo

Excluded from the source and reinforced in `home/.chezmoiignore`:

- All `~/.ssh/id_ed25519*` **private keys**, `known_hosts*`, and `agent-environment`.
- `~/.config/gh/hosts.yml` (GitHub auth tokens).
- The machine-local `~/.config/chezmoi/chezmoi.toml` (lives outside the repo by design).

Only key **paths** are referenced (in `.zshrc`'s ssh-agent block and `.gitconfig`'s
`signingkey`), never key material — those are safe to commit.

If you ever need to store a secret *file* in the repo, encrypt it:

```sh
chezmoi add --encrypt ~/.some-secret      # stored as encrypted_… ; keep the age key OFF-repo
```

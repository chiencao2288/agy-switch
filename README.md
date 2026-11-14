# agy-switch

Lightweight multi-account switcher for Google Antigravity CLI (`agy`) using hashed credential profiles, atomic symlinks, and OS keyring sync.

## Key Concepts

- **Credentials Stored Securely in `~/.agy-profiles`**: Profile data is saved in your user home directory with `0700` permissions, completely outside this Git repository. You can safely clone, edit, and push this repository to GitHub without any risk of leaking tokens.
- **Hashed Profile Names**: Account folders are named after unique credential hashes (e.g. `ue6d04bc6f7b044d6`). Commands present them cleanly as numbered indices (`[1]`, `[2]`, ...).
- **Shared History & Context**: All conversation history (`conversations/`), summaries SQLite database (`conversation_summaries.db`), CLI history (`history.jsonl`), brain artifacts, and settings (`settings.json`) at `~/.gemini/antigravity-cli` **remain permanently shared across all accounts**. You never lose previous conversations or context when switching.
- **Swapped Auth Only**: Only the authentication credentials (`~/.config/antigravity` and the OS Keyring token for `service=gemini, username=antigravity`) are hot-swapped.

## Prerequisites

- `agy` (Google Antigravity CLI)
- `libsecret` / `secret-tool` (For OS keyring credential sync: `sudo dnf install libsecret` or `sudo apt install libsecret-tools`)
- `jq` (For parsing account email: `sudo dnf install jq` or `sudo apt install jq`)

## Installation

### One-line installer
```bash
curl -fsSL https://raw.githubusercontent.com/chiencao2288/agy-switch/main/install.sh | bash
```

### Manual installation
```bash
git clone https://github.com/chiencao2288/agy-switch.git
cd agy-switch
chmod +x install.sh agy-switch
./install.sh
```

## Directory Structure

```
~/.agy-profiles/                     <-- Credentials stored securely in user home
├── ue6d04bc6f7b044d6/
│   ├── antigravity/
│   │   └── credential-user-scope
│   └── keyring_secret.json
└── u6a6e465963a1df79/
    ├── antigravity/
    │   └── credential-user-scope
    └── keyring_secret.json

~/.../agy-switch/                     <-- Clean Git Repository (No private tokens)
├── agy-switch                       <-- Main executable script
├── install.sh                       <-- One-liner installer
├── README.md
├── LICENSE
└── .gitignore
```

## Commands & Usage

```bash
# 1. List accounts (displays index [1], [2], email, and hash)
agy-switch list          # (alias: agy-switch ls)

# 2. View currently active account
agy-switch current

# 3. Switch account
agy-switch switch        # Interactive: displays list and prompts for number
agy-switch switch 1      # Switch directly to account 1
agy-switch switch 2      # Switch directly to account 2

# 4. Add a new account
agy-switch new           # Prepares clean profile, wait for login, press Enter to save

# 5. Remove an account profile (cannot remove currently active account)
agy-switch remove 2      # (alias: agy-switch rm 2)

# 6. View help
agy-switch help
```

## Adding a New Account Workflow

1. Run:
   ```bash
   agy-switch new
   ```
2. Open another terminal and run `agy` (or complete Google sign-in in your browser).
3. Return to the `agy-switch new` terminal and press **[Enter]**.
4. The new credentials and email are automatically captured into `~/.agy-profiles/` and registered!

## License

[MIT](LICENSE) © 2026 Chien Cao

# 🚀 Starship RS Setup on Windows 10
**Windows Terminal + PowerShell 7 + VS Code**

A clean, modern, and fully working **developer-grade terminal setup** using **Starship.rs**, **Catppuccin**, **Nerd Fonts**, and a suite of modern CLI tools on **Windows 10**.

---

## ✅ What You'll Get

- Windows Terminal
- PowerShell 7 (default shell)
- Catppuccin color theme
- Nerd Font icons
- Starship prompt
- Preset-based customization
- Smart directory jumping with Zoxide
- Fuzzy finder with fzf
- Beautiful file listing with lsd
- Same look in Windows Terminal & VS Code

Fast • Clean • Professional 💎

---

## 🔹 Step 1 – Install Windows Terminal

Download:
https://github.com/microsoft/terminal/releases

> Windows 11 users can skip default terminal application setup.

---

## 🔹 Step 2 – Install PowerShell 7

Download:
https://github.com/PowerShell/PowerShell/releases

After installation:

- Open **Windows Terminal**
- **Settings → Startup**
  - Default Profile → **PowerShell 7**
  - Default Terminal Application → **Windows Terminal** (Windows 10 only)

---

## 🔹 Step 3 – Terminal Appearance

**Settings → Profiles → PowerShell → Appearance**

- Transparency: `70%`
- Enable Acrylic Material: `ON`

---

## 🎨 Step 4 – Install Catppuccin Theme

Repository:
https://github.com/catppuccin/windows-terminal

Choose a flavor:

| Flavor     | Files                                  |
|------------|----------------------------------------|
| Frappe     | `frappe.json`, `frappeTheme.json`      |
| Latte      | `latte.json`, `latteTheme.json`        |
| Macchiato  | `macchiato.json`, `macchiatoTheme.json`|
| Mocha      | `mocha.json`, `mochaTheme.json`        |

---

## 🔹 Step 5 – Apply Catppuccin Theme

Open Settings → **Open JSON file**  
Shortcut: `Ctrl + Shift + ,`

Paste `flavor.json` inside:

```json
"schemes": [
  // paste Catppuccin scheme here
]
```

Paste `flavorTheme.json` inside:

```json
"themes": [
  // paste Catppuccin theme here
]
```

Save → Close.

Then:

**Settings → Profiles → Appearance → Color Scheme**
Select your Catppuccin flavor.

---

## 🔠 Step 6 – Install Nerd Font (Required)

Starship icons require Nerd Fonts.

Download:
[https://www.nerdfonts.com/font-downloads](https://www.nerdfonts.com/font-downloads)

Recommended:

- JetBrainsMono Nerd Font
- FiraCode Nerd Font

After installing font:

- Restart Windows Terminal
- **Settings → Profiles → Appearance → Font Face**
- Select your Nerd Font

### Why Nerd Fonts?

- Git icons
- Branch symbols
- Language logos
- Clean professional UI
- Proper Starship rendering

---

## 🔐 Step 7 – Fix Execution Policy

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Restart Terminal.

---

## 📦 Step 8 – Install Chocolatey

Run PowerShell (Admin recommended):

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

Verify:

```powershell
choco --version
```

---

## 🌟 Step 9 – Install Starship

```powershell
choco install starship -y
```

Verify:

```powershell
starship --version
```

---

## 🛠 Step 10 – Install Modern CLI Tools

These tools enhance your terminal experience with smart navigation, fuzzy search, and beautiful output. All installed via Chocolatey — no API keys, no paid dependencies.

```powershell
choco install zoxide fzf lsd -y
```

### Verify all tools

```powershell
zoxide --version
fzf --version
lsd --version
```

### Tool Reference

| Tool       | Purpose                              | Installed via | Verify command       |
|------------|--------------------------------------|---------------|----------------------|
| **Zoxide** | Smart `cd` (directory jumper)        | Chocolatey    | `zoxide --version`   |
| **fzf**    | Fuzzy finder (used in `cdf`)         | Chocolatey    | `fzf --version`      |
| **lsd**    | Modern `ls` with icons & colors      | Chocolatey    | `lsd --version`      |

> **Note:** `lsd` requires a Nerd Font to display icons correctly. Make sure Step 6 is done before using it.

---

## 📝 Step 11 – Setup PowerShell Profile

Open your profile:

```powershell
notepad $PROFILE
```

Add the following block. This is the **complete recommended profile** including Starship, Zoxide, and shell aliases:

```powershell
# ── Starship Prompt ─────────────────────────────────────────────────────────
if (Get-Command starship -ErrorAction SilentlyContinue) {
  Invoke-Expression (&starship init powershell)
}

# ── Zoxide (smart cd) ────────────────────────────────────────────────────────
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# ── fzf fuzzy directory jump ─────────────────────────────────────────────────
function cdf {
  $dir = Get-ChildItem -Recurse -Directory -ErrorAction SilentlyContinue |
         Select-Object -ExpandProperty FullName |
         fzf --prompt="Jump to: "
  if ($dir) { Set-Location $dir }
}

# ── lsd aliases ──────────────────────────────────────────────────────────────
Set-Alias ls  lsd
Set-Alias ll  { lsd -l }
Set-Alias la  { lsd -la }
Set-Alias lt  { lsd --tree }
```

Save → close → restart Terminal.

### What each section does

| Section           | What it does                                                          |
|-------------------|-----------------------------------------------------------------------|
| Starship          | Initializes the Starship prompt on every shell start                  |
| Zoxide            | Replaces `cd` with `z` — learns your frequent dirs (`z proj`, `z dl`)|
| `cdf` function    | Uses `fzf` to fuzzy-search all subdirectories and jump into one       |
| lsd aliases       | Replaces default `ls`/`ll`/`la` with icon-rich `lsd` output          |

---

## 🧩 Step 12 – Create Starship Config (IMPORTANT – Windows 10)

On Windows 10, `.config` **does not exist by default**.

### Create `.config` folder

```powershell
mkdir $env:USERPROFILE\.config -Force
```

### Create / edit Starship config

```powershell
notepad $env:USERPROFILE\.config\starship.toml
```

Click **Yes** if prompted.

---

### ✨ Example Minimal Config

```toml
add_newline = true

[character]
success_symbol = "❯"
error_symbol = "❯"

[git_branch]
symbol = " "

[nodejs]
symbol = " "

[python]
symbol = " "
```

Save → close.

Reload:

```powershell
. $PROFILE
```

---

## 🎨 Step 13 – Use Starship Presets

List presets:

```powershell
starship preset
```

Apply a preset:

```powershell
starship preset nerd-font-symbols > $HOME\.config\starship.toml
```

Other examples:

```powershell
starship preset pastel-powerline > $HOME\.config\starship.toml
starship preset minimal > $HOME\.config\starship.toml
```

Reload:

```powershell
. $PROFILE
```

---

## 🧪 Step 14 – Test Full Setup

```powershell
# Core
starship --version
where.exe starship

# CLI Tools
zoxide --version
fzf --version
lsd --version

# Test zoxide
z ~          # jump to home
cdf          # open fuzzy dir picker

# Test lsd
ls           # icon-rich listing
ll           # detailed list
lt           # tree view
```

---

## 🛠 Troubleshooting

### ❌ `starship` not recognized

```powershell
choco install starship -y
```

Restart Terminal & VS Code.

---

### ❌ `zoxide` / `fzf` / `lsd` not recognized

```powershell
choco install zoxide fzf lsd -y
```

Restart Terminal. If still missing, verify Chocolatey's bin is in your PATH:

```powershell
$env:PATH -split ";" | Where-Object { $_ -like "*chocolatey*" }
```

---

### ❌ `z` command not working (Zoxide)

Make sure your `$PROFILE` includes the Zoxide init block:

```powershell
Invoke-Expression (& { (zoxide init powershell | Out-String) })
```

Then reload:

```powershell
. $PROFILE
```

---

### ❌ `lsd` shows broken boxes instead of icons

You haven't applied a Nerd Font yet. Go back to **Step 6**, install a Nerd Font, and set it in:

**Settings → Profiles → Appearance → Font Face**

---

### ❌ `choco` not recognized

Reinstall Chocolatey and restart Terminal.

---

### ❌ VS Code terminal errors

Ensure `$PROFILE` contains only valid commands. The safe minimal version:

```powershell
if (Get-Command starship -ErrorAction SilentlyContinue) {
  Invoke-Expression (&starship init powershell)
}
```

---

### ❌ Scripts blocked

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 📍 Windows 10 Paths Reference

| Item                   | Path                                                                      |
|------------------------|---------------------------------------------------------------------------|
| Starship config        | `C:\Users\<You>\.config\starship.toml`                                    |
| PowerShell profile     | `C:\Users\<You>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`    |
| Starship binary        | `C:\ProgramData\chocolatey\bin\starship.exe`                              |
| Zoxide binary          | `C:\ProgramData\chocolatey\bin\zoxide.exe`                                |
| fzf binary             | `C:\ProgramData\chocolatey\bin\fzf.exe`                                   |
| lsd binary             | `C:\ProgramData\chocolatey\bin\lsd.exe`                                   |

---

## ✨ Final Result

You now have a **modern, themed, icon-rich terminal** with:

- Starship.rs prompt
- Catppuccin colors
- Nerd Font icons
- PowerShell 7
- Windows Terminal
- VS Code terminal sync
- Zoxide smart directory jumping
- fzf fuzzy directory picker (`cdf`)
- lsd modern file listing with icons

Enjoy your **developer-grade Windows terminal** 🚀

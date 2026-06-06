# ==========================================
# Zai Startup Banner (Auto + Manual Commands)
# Windows Terminal + PowerShell 7 + Starship
# ==========================================

# 1. Zoxide (smart cd)
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# 2. fzf fuzzy cd (type cdf to open fuzzy folder picker)
function fcd { $dir = fzf --walker=dir; if ($dir) { Set-Location $dir } }
Set-Alias cdf fcd

# 3. thefuck (auto correct mistyped commands)
# $env:TF_SHELL = "powershell"
# Invoke-Expression "$(thefuck --alias)"

# 4. PSReadLine (inline history suggestions)
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# ==========================================
# Zai Banner Settings
# ==========================================

# Auto banner toggle (persistent per-user)
$script:ZaiAutoFlagPath = Join-Path $env:USERPROFILE ".zai-banner-auto"
if (-not (Test-Path $script:ZaiAutoFlagPath)) { "on" | Set-Content -Encoding ASCII $script:ZaiAutoFlagPath }

# Cache path for -fast
$script:ZaiCachePath = Join-Path $env:USERPROFILE ".zai-banner-cache.json"

# Track "shown once" per session
$global:ZAI_BANNER_SHOWN = $false

function Get-ZaiAutoState {
    try {
        $v = (Get-Content $script:ZaiAutoFlagPath -ErrorAction Stop | Select-Object -First 1).Trim().ToLower()
        if ($v -ne "off") { return "on" }
        return "off"
    } catch { return "on" }
}

function Set-ZaiAutoState([ValidateSet("on","off")]$state) {
    $state | Set-Content -Encoding ASCII $script:ZaiAutoFlagPath
}

function Get-ZaiInfoFast {
    $maxAgeHours = 24
    $needRefresh = $true

    if (Test-Path $script:ZaiCachePath) {
        try {
            $json = Get-Content $script:ZaiCachePath -Raw | ConvertFrom-Json
            $ts = [datetime]$json.timestamp
            if (((Get-Date) - $ts).TotalHours -lt $maxAgeHours) {
                $needRefresh = $false
                return @{
                    User   = $json.user
                    Host   = $json.host
                    OS     = $json.os
                    Shell  = $json.shell
                    CPU    = $json.cpu
                    RAM    = $json.ram
                    GPU    = $json.gpu
                    Disk   = $json.disk
                    Uptime = $json.uptime
                }
            }
        } catch { $needRefresh = $true }
    }

    if ($needRefresh) {
        $info = Get-ZaiInfoLive
        try {
            @{
                timestamp = (Get-Date).ToString("o")
                user      = $info.User
                host      = $info.Host
                os        = $info.OS
                shell     = $info.Shell
                cpu       = $info.CPU
                ram       = $info.RAM
                gpu       = $info.GPU
                disk      = $info.Disk
                uptime    = $info.Uptime
            } | ConvertTo-Json | Set-Content -Encoding UTF8 $script:ZaiCachePath
        } catch { }
        return $info
    }
}

function Get-ZaiInfoLive {
    try {
        $os  = Get-CimInstance Win32_OperatingSystem
        $cs  = Get-CimInstance Win32_ComputerSystem
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1

        $ram = [math]::Round($cs.TotalPhysicalMemory / 1GB, 1)

        $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
        $diskTotal = [math]::Round($disk.Size / 1GB, 0)
        $diskFree  = [math]::Round($disk.FreeSpace / 1GB, 0)

        $uptime = (Get-Date) - $os.LastBootUpTime
        $uptimeStr = "{0}d {1}h {2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes

        return @{
            User   = $env:USERNAME
            Host   = "ZaiNix"
            #Host  = $env:COMPUTERNAME
            OS     = "Win 10 LTSC (64-bit)"
            #OS    = "$($os.Caption) ($($os.OSArchitecture))"
            Shell  = "PowerShell $($PSVersionTable.PSVersion)"
            CPU    = (($cpu.Name -replace "\s+", " ").Trim())
            RAM    = "$ram GB"
            GPU    = (($gpu.Name -replace "\s+", " ").Trim())
            Disk   = "C: $diskTotal GB / $diskFree GB free"
            Uptime = $uptimeStr
        }
    } catch {
        return @{
            User   = $env:USERNAME
            Host   = $env:COMPUTERNAME
            OS     = "Unavailable"
            Shell  = "PowerShell $($PSVersionTable.PSVersion)"
            CPU    = "Unavailable"
            RAM    = "Unavailable"
            GPU    = "Unavailable"
            Disk   = "Unavailable"
            Uptime = "Unavailable"
        }
    }
}

function Show-ZaiBanner {
    param(
        [switch]$Mini,
        [switch]$Fast,
        [switch]$Clear
    )

    # Auto-run should only show once per session
    if (-not $Clear -and -not $Mini -and -not $Fast) {
        if ($global:ZAI_BANNER_SHOWN) { return }
        $global:ZAI_BANNER_SHOWN = $true
    }

    if ($Clear) { Clear-Host }

    $logo = @(
" ███████████            ███ ",
"░█░░░░░░███            ░░░  ",
"░     ███░    ██████   ████ ",
"     ███     ░░░░░███ ░░███ ",
"    ███       ███████  ░███ ",
"  ████     █ ███░░███  ░███ ",
" ███████████░░████████ █████",
"░░░░░░░░░░░  ░░░░░░░░ ░░░░░ "
)

    # Nerd Font Icons
    $I_USER = ""
    $I_HOST = "󰟀"
    $I_OS   = "󰍹"
    $I_SH   = ""
    $I_CPU  = "󰍛"
    $I_RAM  = "󰘚"
    $I_GPU  = "󰢮"
    $I_DISK = "󰋊"
    $I_UP   = "󱫐"

    $info = if ($Fast) { Get-ZaiInfoFast } else { Get-ZaiInfoLive }

    if ($Mini) {
        Write-Host ($logo[0]) -ForegroundColor Gray
        Write-Host ("{0}  {1} {2}" -f $I_USER, "User:", $info.User) -ForegroundColor Cyan
        Write-Host ("{0}  {1} {2}" -f $I_HOST, "Host:", $info.Host) -ForegroundColor Cyan
        Write-Host ("{0}  {1} {2}" -f $I_CPU,  "CPU :", $info.CPU)  -ForegroundColor Cyan
        Write-Host ("{0}  {1} {2}" -f $I_RAM,  "RAM :", $info.RAM)  -ForegroundColor Cyan
        Write-Host ""
        return
    }

    $rows = @(
        @{ i=$I_USER; l="User";   v=$info.User },
        @{ i=$I_HOST; l="Host";   v=$info.Host },
        @{ i=$I_OS;   l="OS";     v=$info.OS },
        @{ i=$I_SH;   l="Shell";  v=$info.Shell },
        @{ i=$I_CPU;  l="CPU";    v=$info.CPU },
        @{ i=$I_RAM;  l="RAM";    v=$info.RAM },
        @{ i=$I_GPU;  l="GPU";    v=$info.GPU },
        @{ i=$I_DISK; l="Disk";   v=$info.Disk },
        @{ i=$I_UP;   l="Uptime"; v=$info.Uptime }
    )

    $leftWidth  = ($logo | Measure-Object Length -Maximum).Maximum + 2
    $labelWidth = 7
    $maxLines   = [Math]::Max($logo.Count, $rows.Count)

    for ($n = 0; $n -lt $maxLines; $n++) {
        $left = if ($n -lt $logo.Count) { $logo[$n] } else { "" }
        Write-Host ($left.PadRight($leftWidth)) -NoNewline -ForegroundColor Gray

        if ($n -lt $rows.Count) {
            $icon  = $rows[$n].i
            $label = $rows[$n].l.PadRight($labelWidth)
            $value = $rows[$n].v

            Write-Host "  $icon  " -NoNewline -ForegroundColor Cyan
            Write-Host "$label"    -NoNewline -ForegroundColor Cyan
            Write-Host " ▸ "       -NoNewline -ForegroundColor DarkGray
            Write-Host "$value"    -ForegroundColor White
        } else {
            Write-Host ""
        }
    }

    Write-Host ""
}

# ==========================================
# Zai Command
# ==========================================
# Usage:
#   zai           -> show banner
#   zai -c        -> clear screen + show banner
#   zai -mini     -> compact banner
#   zai -fast     -> cached/fast banner
#   zai on        -> enable auto banner on startup
#   zai off       -> disable auto banner on startup
#   zai -help     -> show help
# ==========================================
function zai {
    param(
        [switch]$c,
        [switch]$mini,
        [switch]$fast,
        [switch]$help,
        [ValidateSet("on","off")] [string]$toggle
    )

    if ($help) {
        Write-Host ""
        Write-Host "Zai Banner Command" -ForegroundColor Cyan
        Write-Host "------------------" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "Usage:" -ForegroundColor Yellow
        Write-Host "  zai              Show banner (manual)" -ForegroundColor White
        Write-Host "  zai -c           Clear screen + show banner" -ForegroundColor White
        Write-Host "  zai -mini        Show compact banner" -ForegroundColor White
        Write-Host "  zai -fast        Show banner using cached system info" -ForegroundColor White
        Write-Host "  zai on           Enable auto banner on terminal start" -ForegroundColor White
        Write-Host "  zai off          Disable auto banner on terminal start" -ForegroundColor White
        Write-Host "  zai -help        Show this help message" -ForegroundColor White
        Write-Host ""
        return
    }

    if ($toggle) {
        Set-ZaiAutoState $toggle
        Write-Host "Zai auto banner: $toggle" -ForegroundColor Green
        return
    }

    $global:ZAI_BANNER_SHOWN = $false
    Show-ZaiBanner -Clear:$c -Mini:$mini -Fast:$fast
}

# ==========================================
# Auto Banner (once per session)
# ==========================================
if ((Get-ZaiAutoState) -eq "on") {
    Show-ZaiBanner
}

# ==========================================
# Aliases
# ==========================================
Set-Alias ls lsd

# ==========================================
# Starship Prompt (always last)
# ==========================================
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

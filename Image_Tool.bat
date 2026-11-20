@echo off
setlocal DisableDelayedExpansion
set "IMAGE_TOOL_INITIAL_1=%~1"
set "IMAGE_TOOL_INITIAL_2=%~2"
set "IMAGE_TOOL_INITIAL_3=%~3"
set "IMAGE_TOOL_INITIAL_4=%~4"
set "IMAGE_TOOL_INITIAL_5=%~5"
set "IMAGE_TOOL_INITIAL_6=%~6"
set "IMAGE_TOOL_INITIAL_7=%~7"
set "IMAGE_TOOL_INITIAL_8=%~8"
set "IMAGE_TOOL_INITIAL_9=%~9"
set "IMAGE_TOOL_BAT=%~f0"
title Console Image Tool
rem Run directly in this console. Do not spawn/hide a second console process tree.
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy Bypass -EncodedCommand dAByAHkAIAB7AAoAIAAgACAAIAAkAGEAbABsACAAPQAgAEcAZQB0AC0AQwBvAG4AdABlAG4AdAAgAC0ATABpAHQAZQByAGEAbABQAGEAdABoACAAJABlAG4AdgA6AEkATQBBAEcARQBfAFQATwBPAEwAXwBCAEEAVAAgAC0AUgBhAHcAIAAtAEUAcgByAG8AcgBBAGMAdABpAG8AbgAgAFMAdABvAHAACgAgACAAIAAgACQAbQBhAHIAawBlAHIAIAA9ACAAJwAjACMAIwAgACcAIAArACAAJwBQAE8AVwBFAFIAUwBIAEUATABMACAAIwAjACMAJwAKACAAIAAgACAAJABwAG8AcwBpAHQAaQBvAG4AIAA9ACAAJABhAGwAbAAuAEkAbgBkAGUAeABPAGYAKAAkAG0AYQByAGsAZQByACkACgAgACAAIAAgAGkAZgAgACgAJABwAG8AcwBpAHQAaQBvAG4AIAAtAGwAdAAgADAAKQAgAHsAIAB0AGgAcgBvAHcAIAAnAFQAaABlACAAZQBtAGIAZQBkAGQAZQBkACAAYQBwAHAAbABpAGMAYQB0AGkAbwBuACAAcwBlAGMAdABpAG8AbgAgAGkAcwAgAG0AaQBzAHMAaQBuAGcALgAnACAAfQAKACAAIAAgACAAJgAgACgAWwBzAGMAcgBpAHAAdABiAGwAbwBjAGsAXQA6ADoAQwByAGUAYQB0AGUAKAAkAGEAbABsAC4AUwB1AGIAcwB0AHIAaQBuAGcAKAAkAHAAbwBzAGkAdABpAG8AbgAgACsAIAAkAG0AYQByAGsAZQByAC4ATABlAG4AZwB0AGgAKQApACkACgB9ACAAYwBhAHQAYwBoACAAewAKACAAIAAgACAAdAByAHkAIAB7ACAAKAAkAF8AIAB8ACAATwB1AHQALQBTAHQAcgBpAG4AZwApACAAfAAgAFMAZQB0AC0AQwBvAG4AdABlAG4AdAAgAC0ATABpAHQAZQByAGEAbABQAGEAdABoACAAKABKAG8AaQBuAC0AUABhAHQAaAAgACgAUwBwAGwAaQB0AC0AUABhAHQAaAAgACQAZQBuAHYAOgBJAE0AQQBHAEUAXwBUAE8ATwBMAF8AQgBBAFQAKQAgACcASQBtAGEAZwBlAF8AVABvAG8AbAAtAGUAcgByAG8AcgAuAGwAbwBnACcAKQAgAH0AIABjAGEAdABjAGgAIAB7ACAAfQAKACAAIAAgACAATQBpAGMAcgBvAHMAbwBmAHQALgBQAG8AdwBlAHIAUwBoAGUAbABsAC4AVQB0AGkAbABpAHQAeQBcAFcAcgBpAHQAZQAtAEgAbwBzAHQAIAAoACcAQwBvAG4AcwBvAGwAZQAgAEkAbQBhAGcAZQAgAFQAbwBvAGwAIABmAGEAaQBsAGUAZAA6ACAAJwAgACsAIAAkAF8ALgBFAHgAYwBlAHAAdABpAG8AbgAuAE0AZQBzAHMAYQBnAGUAKQAgAC0ARgBvAHIAZQBnAHIAbwB1AG4AZABDAG8AbABvAHIAIABSAGUAZAAKACAAIAAgACAAUgBlAGEAZAAtAEgAbwBzAHQAIAAnAFAAcgBlAHMAcwAgAEUAbgB0AGUAcgAgAHQAbwAgAGMAbABvAHMAZQAnACAAfAAgAE8AdQB0AC0ATgB1AGwAbAAKACAAIAAgACAAZQB4AGkAdAAgADEACgB9AA==
if errorlevel 1 pause
exit /b

### POWERSHELL ###



param([switch]$LibraryOnly)
$script:toolRoot = Split-Path -Parent $env:IMAGE_TOOL_BAT
$script:windowMemorySource = @'
using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading;

// Poll from a CLR thread so closing the console with X still retains recent geometry.
public static class ImageToolWindow
{
    [StructLayout(LayoutKind.Sequential)] public struct Rect { public int Left, Top, Right, Bottom; }
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")] static extern bool SetWindowPos(IntPtr h, IntPtr after, int x, int y, int w, int height, uint flags);
    [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h, IntPtr processId);
    [StructLayout(LayoutKind.Sequential)] struct GuiThreadInfo {
        public uint Size, Flags;
        public IntPtr Active, Focus, Capture, MenuOwner, MoveSize, Caret;
        public Rect CaretRect;
    }
    [DllImport("user32.dll")] static extern bool GetGUIThreadInfo(uint threadId, ref GuiThreadInfo info);
    public static void RestoreBounds(IntPtr handle, int x, int y, int width, int height)
    {
        if (!IsWindowVisible(handle) || IsIconic(handle) || IsZoomed(handle)) return;
        var info = new GuiThreadInfo();
        info.Size = (uint)Marshal.SizeOf(typeof(GuiThreadInfo));
        uint threadId = GetWindowThreadProcessId(handle, IntPtr.Zero);
        if (threadId == 0 || !GetGUIThreadInfo(threadId, ref info)) return;
        // Leave active mouse capture and the host's move/resize loop alone.
        if (info.Capture != IntPtr.Zero || info.MoveSize != IntPtr.Zero || (info.Flags & 2) != 0) return;
        // The console belongs to another process. Post the request; never activate or reorder it.
        const uint NoZOrder = 0x0004, NoActivate = 0x0010, AsyncWindowPos = 0x4000;
        SetWindowPos(handle, IntPtr.Zero, x, y, width, height, NoZOrder | NoActivate | AsyncWindowPos);
    }
    [DllImport("user32.dll")] static extern bool GetWindowRect(IntPtr h, out Rect r);
    [DllImport("user32.dll")] static extern bool IsIconic(IntPtr h);
    [DllImport("user32.dll")] static extern bool IsZoomed(IntPtr h);
    [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
    static Timer timer;
    static string previous;
    public static void Start(IntPtr handle, string path)
    {
        if (timer != null) timer.Dispose();
        timer = new Timer(delegate {
            try {
                Rect r;
                if (!IsWindowVisible(handle) || IsIconic(handle) || IsZoomed(handle) || !GetWindowRect(handle, out r)) return;
                int w = r.Right - r.Left, h = r.Bottom - r.Top;
                if (w < 300 || h < 240) return;
                string json = String.Format("{{\"X\":{0},\"Y\":{1},\"Width\":{2},\"Height\":{3}}}", r.Left, r.Top, w, h);
                if (json == previous) return;
                File.WriteAllText(path, json);
                previous = json;
            } catch { /* Preferences must never interrupt image processing. */ }
        }, null, 0, 500);
    }
}
'@

# Shared console, dependency and input helpers. Compatible with Windows PowerShell 5.1.
$script:svgMinimum = 2048
$script:decodedInputs = @{}
$script:inputTemporaryRoot = $null

function Get-DecodedInputPath {
    param([string]$Path)
    if ($Path -notmatch '(?i)\.(svgz|svg\.gz)$') { return $Path }
    $source = Get-Item -LiteralPath $Path
    $key = $source.FullName + '|' + $source.LastWriteTimeUtc.Ticks + '|' + $source.Length
    if ($script:decodedInputs.ContainsKey($key)) { return $script:decodedInputs[$key] }
    if (-not $script:inputTemporaryRoot) {
        $script:inputTemporaryRoot = Join-Path ([IO.Path]::GetTempPath()) ('console-image-tool-input-' + [Guid]::NewGuid().ToString('N'))
        $null = New-Item -ItemType Directory -Path $script:inputTemporaryRoot
    }
    $destination = Join-Path $script:inputTemporaryRoot ([Guid]::NewGuid().ToString('N') + '.svg')
    $inputStream = [IO.File]::OpenRead($Path)
    try {
        $gzip = New-Object IO.Compression.GZipStream($inputStream, [IO.Compression.CompressionMode]::Decompress)
        try {
            $outputStream = [IO.File]::Create($destination)
            try { $gzip.CopyTo($outputStream) } finally { $outputStream.Dispose() }
        } finally { $gzip.Dispose() }
    } finally { $inputStream.Dispose() }
    $script:decodedInputs[$key] = $destination
    return $destination
}

function Remove-ImageToolTemporaryInputs {
    if ($script:inputTemporaryRoot) {
        $resolved = [IO.Path]::GetFullPath($script:inputTemporaryRoot)
        $temp = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\') + '\'
        if ($resolved.StartsWith($temp, [StringComparison]::OrdinalIgnoreCase) -and
            [IO.Path]::GetFileName($resolved).StartsWith('console-image-tool-input-')) {
            Remove-Item -LiteralPath $resolved -Recurse -Force -ErrorAction SilentlyContinue
        }
        $script:inputTemporaryRoot = $null
        $script:decodedInputs = @{}
    }
}

function Write-UiText {
    param([object]$Object = '', [switch]$NoNewline,
        [ConsoleColor]$ForegroundColor = [ConsoleColor]::Gray,
        [ConsoleColor]$BackgroundColor = [ConsoleColor]::Black)
    $options = @{ ForegroundColor = $ForegroundColor }
    if ($PSBoundParameters.ContainsKey('BackgroundColor')) { $options.BackgroundColor = $BackgroundColor }
    if ($NoNewline) {
        Microsoft.PowerShell.Utility\Write-Host $Object -NoNewline @options
        return
    }
    $width = [Math]::Max(8, [Console]::WindowWidth - 1)
    foreach ($paragraph in ([string]$Object -split '\r?\n')) {
        $line = $paragraph
        while ($line.Length -gt $width) {
            $cut = $line.LastIndexOf(' ', $width)
            if ($cut -lt 3) { $cut = $width }
            Microsoft.PowerShell.Utility\Write-Host $line.Substring(0, $cut) @options
            $line = '  ' + $line.Substring($cut).TrimStart()
        }
        Microsoft.PowerShell.Utility\Write-Host $line @options
    }
}

function Initialize-ImageTool {
    param([switch]$SkipWindowMemory)
    [Console]::Title = 'Console Image Tool'
    $portable = Join-Path $script:toolRoot 'ImageMagick\magick.exe'
    if (Test-Path -LiteralPath $portable) {
        $script:magickPath = $portable
        # Keep delegates and configuration alongside the portable binary.
        $env:MAGICK_HOME = Split-Path -Parent $portable
        $env:PATH = "$env:MAGICK_HOME;$env:PATH"
    }
    else {
        $command = Get-Command magick.exe -ErrorAction SilentlyContinue
        if ($command) { $script:magickPath = $command.Source }
    }
    if (-not $script:magickPath) {
        Write-UiText 'ImageMagick is missing. Extract the complete portable ZIP, keeping the ImageMagick folder beside this batch file.' -ForegroundColor Yellow
        Read-Host 'Press Enter to close' | Out-Null
        exit 1
    }
    & $script:magickPath -version 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'ImageMagick could not start. Check device application policies.' }
    if (-not $SkipWindowMemory) { Initialize-WindowMemory }
}

function Initialize-WindowMemory {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        if (-not ('ImageToolWindow' -as [type])) {
            Add-Type -TypeDefinition $script:windowMemorySource
        }
        $stateRoot = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'ConsoleImageTool'
        $null = New-Item -ItemType Directory -Force -Path $stateRoot
        $statePath = Join-Path $stateRoot 'window.json'
        $handle = [ImageToolWindow]::GetConsoleWindow()
        if ($handle -eq [IntPtr]::Zero) { return }
        $bounds = New-Object Drawing.Rectangle(80, 80, 560, 640)
        if (Test-Path -LiteralPath $statePath) {
            try {
                $saved = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
                if ($saved.Width -ge 300 -and $saved.Height -ge 240) {
                    $bounds = New-Object Drawing.Rectangle([int]$saved.X, [int]$saved.Y, [int]$saved.Width, [int]$saved.Height)
                }
            } catch { } # A corrupt preferences file must not prevent startup.
        }
        $area = [Windows.Forms.Screen]::FromRectangle($bounds).WorkingArea
        $width = [Math]::Min($bounds.Width, $area.Width)
        $height = [Math]::Min($bounds.Height, $area.Height)
        $x = [Math]::Max($area.Left, [Math]::Min($bounds.X, $area.Right - $width))
        $y = [Math]::Max($area.Top, [Math]::Min($bounds.Y, $area.Bottom - $height))
        # Let the host manage its buffer. Synchronous buffer/window resizing can interfere
        # with mouse capture; the native helper only posts an idle, non-activating restore.
        [ImageToolWindow]::RestoreBounds($handle, $x, $y, $width, $height)
        [ImageToolWindow]::Start($handle, $statePath)
    }
    catch { Write-UiText "Window memory unavailable: $($_.Exception.Message)" -ForegroundColor Yellow }
}

function Read-TextInput {
    param([string]$Prompt)
    Write-UiText $Prompt -ForegroundColor Cyan
    $text = ''
    while ($true) {
        $key = [Console]::ReadKey($true)
        if ($key.Key -eq [ConsoleKey]::Escape) { Write-UiText; return $null }
        if ($key.Key -eq [ConsoleKey]::Enter) { Write-UiText; return $text }
        if ($key.Key -eq [ConsoleKey]::Backspace) {
            if ($text.Length -gt 0) { $text = $text.Substring(0, $text.Length - 1) }
        }
        elseif (-not [char]::IsControl($key.KeyChar)) { $text += $key.KeyChar }
        $width = [Math]::Max(4, [Console]::WindowWidth - 1)
        $visible = if ($text.Length -gt $width - 2) { $text.Substring($text.Length - ($width - 2)) } else { $text }
        [Console]::CursorLeft = 0
        Write-UiText ('> ' + $visible).PadRight($width) -NoNewline
    }
}

function ConvertTo-HexColor {
    param([string]$Text)
    $value = $Text.Trim() -replace '^#', ''
    if ($value -match '^[0-9a-fA-F]{3}$') {
        $value = -join ($value.ToCharArray() | ForEach-Object { "$_$_" })
    }
    if ($value -notmatch '^[0-9a-fA-F]{6}$') { return $null }
    return '#' + $value.ToUpperInvariant()
}

function Select-CustomBackground {
    while ($true) {
        $value = Read-TextInput 'Background hex (e.g. #8FA796 or 8FA796); Esc cancels:'
        if ($null -eq $value) { return $null }
        $color = ConvertTo-HexColor $value
        if ($color) { break }
        Write-UiText 'Use 3 or 6 hex digits.' -ForegroundColor Yellow
    }
    while ($true) {
        $value = Read-TextInput 'Padding per side in pixels (Enter = 20, 0 = none):'
        if ($null -eq $value) { return $null }
        if ($value -eq '') { $value = '20' }
        $amount = 0
        if ([int]::TryParse($value, [ref]$amount) -and $amount -ge 0 -and $amount -le 4096) {
            return [pscustomobject]@{ Type = 'background'; Color = $color; Padding = $amount }
        }
        Write-UiText 'Enter a whole number from 0 to 4096.' -ForegroundColor Yellow
    }
}

function Get-ImageReadArguments {
    param([string]$Path)
    $info = Get-ImageInfo $Path
    $Path = Get-DecodedInputPath $Path
    $arguments = @('-background', 'none')
    if ($info -and $info.Format -in @('SVG', 'SVGZ', 'MSVG')) {
        $longest = [Math]::Max($info.Width, $info.Height)
        if ($longest -gt 0 -and $longest -lt $script:svgMinimum) {
            $scale = $script:svgMinimum / [double]$longest
            # Density is applied BEFORE the SVG is decoded, retaining vector detail.
            $arguments += @('-density', ([Math]::Ceiling(96 * $scale)).ToString([Globalization.CultureInfo]::InvariantCulture))
        }
        $arguments += "$Path[0]"
        if ($longest -gt 0 -and $longest -lt $script:svgMinimum) {
            $w = [Math]::Max(1, [Math]::Round($info.Width * $scale))
            $h = [Math]::Max(1, [Math]::Round($info.Height * $scale))
            $arguments += @('-resize', "${w}x${h}!")
        }
    }
    else { $arguments += "$Path[0]" }
    return $arguments
}

$sizeLimit = 5242880
$targetBytes = [long]($sizeLimit * 0.92)
$maximumAttempts = 4
$padding = 20
$outputFolder = $null
$preserveCopyright = $false
$script:lastAction = $null

function Write-Banner {
    Write-UiText '  CONSOLE IMAGE TOOL' -ForegroundColor Cyan
    Write-UiText '  Compress / Background / Convert / Invert' -ForegroundColor White
    Write-UiText '  Drop files or a folder. Originals stay safe.' -ForegroundColor DarkGray
    Write-UiText '  Esc: cancel or close' -ForegroundColor DarkGray
}

function Format-FileSize {
    param([long]$Bytes)

    if ($Bytes -ge 1MB) { return ("{0:N2} MiB" -f ($Bytes / 1MB)) }
    if ($Bytes -ge 1KB) { return ("{0:N1} KiB" -f ($Bytes / 1KB)) }
    return "$Bytes bytes"
}

function Get-ShortText {
    param([string]$Text, [int]$Maximum = 48)

    if ($Text.Length -le $Maximum) { return $Text }
    return "..." + $Text.Substring($Text.Length - ($Maximum - 3))
}

function Split-DroppedPaths {
    param([string]$Text)

    $paths = @()
    foreach ($match in [regex]::Matches($Text.Trim(), '"([^"]+)"|(\S+)')) {
        if ($match.Groups[1].Success) {
            $paths += $match.Groups[1].Value
        }
        else {
            $paths += $match.Groups[2].Value
        }
    }

    return $paths
}

function Read-DroppedPaths {
    param(
        [string]$Prompt = "Drop images or a folder here",
        [string]$EscapeLabel = "close"
    )

    Write-UiText
    Write-UiText "  $Prompt" -ForegroundColor Cyan
    Write-UiText "  (Esc to $EscapeLabel)" -ForegroundColor DarkGray
    Write-UiText "  > " -NoNewline -ForegroundColor DarkCyan

    $buffer = ""
    $lastInput = Get-Date

    while ($true) {
        while ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true)

            if ($key.Key -eq [ConsoleKey]::Escape) {
                Write-UiText
                return @()
            }

            if ($key.Key -eq [ConsoleKey]::Enter) {
                if ($buffer.Length -gt 0) {
                    Write-UiText "received" -ForegroundColor DarkGray
                    return @(Split-DroppedPaths $buffer)
                }
            }
            elseif ($key.Key -eq [ConsoleKey]::Backspace) {
                if ($buffer.Length -gt 0) {
                    $buffer = $buffer.Substring(0, $buffer.Length - 1)
                }
            }
            elseif ($key.KeyChar -ne [char]0) {
                $buffer += $key.KeyChar
            }

            $lastInput = Get-Date
        }

        if ($buffer.Length -gt 0 -and ((Get-Date) - $lastInput).TotalMilliseconds -ge 500) {
            Write-UiText "received" -ForegroundColor DarkGray
            return @(Split-DroppedPaths $buffer)
        }

        Start-Sleep -Milliseconds 20
    }
}

function Show-ArrowMenu {
    param([string]$Title, [array]$Items, [int]$SelectedIndex = 0)
    $oldCursorVisible = [Console]::CursorVisible
    [Console]::CursorVisible = $false
    $lastSize = ''
    $redraw = $true
    $menuTop = $null
    try {
        while ($true) {
            $size = "$([Console]::WindowWidth)x$([Console]::WindowHeight)"
            if ($size -ne $lastSize) {
                # Reserve a fresh menu block only on entry/resize. Never erase scrollback.
                Write-UiText
                Write-UiText $Title -ForegroundColor White
                $count = [Math]::Min($Items.Count, [Math]::Max(1, [Console]::WindowHeight - 5))
                $rows = $count + 2
                for ($row = 0; $row -lt $rows; $row++) { Write-UiText }
                $menuTop = [Console]::CursorTop - $rows
                $menuBottom = [Console]::CursorTop
                $lastSize = $size
                $redraw = $true
            }
            if ($redraw) {
                $width = [Math]::Max(8, [Console]::WindowWidth - 1)
                $first = [Math]::Max(0, [Math]::Min($SelectedIndex - [int]($count / 2), $Items.Count - $count))
                for ($row = 0; $row -lt $count; $row++) {
                    $i = $first + $row
                    $prefix = if ($i -eq $SelectedIndex) { '> ' } else { '  ' }
                    $hotkey = if ($Items[$i].HotKey) { "[$($Items[$i].HotKey)] " } else { '' }
                    $line = $prefix + $hotkey + $Items[$i].Label
                    if ($line.Length -gt $width) { $line = $line.Substring(0, $width - 3) + '...' }
                    [Console]::SetCursorPosition(0, $menuTop + $row)
                    if ($i -eq $SelectedIndex) {
                        Write-UiText $line.PadRight($width) -NoNewline -ForegroundColor White -BackgroundColor DarkCyan
                    } else { Write-UiText $line.PadRight($width) -NoNewline -ForegroundColor Gray }
                }
                [Console]::SetCursorPosition(0, $menuTop + $count)
                $hint = 'Arrows: choose | Enter: run | Esc: back'
                if ($Items.Count -gt $count) { $hint = "$($SelectedIndex + 1)/$($Items.Count) | " + $hint }
                if ($hint.Length -gt $width) { $hint = $hint.Substring(0, $width) }
                Write-UiText $hint.PadRight($width) -NoNewline -ForegroundColor DarkGray
                [Console]::SetCursorPosition(0, $menuBottom)
                $redraw = $false
            }
            if (-not [Console]::KeyAvailable) { Start-Sleep -Milliseconds 50; continue }
            $key = [Console]::ReadKey($true)
            switch ($key.Key) {
                ([ConsoleKey]::UpArrow) { $SelectedIndex = ($SelectedIndex - 1 + $Items.Count) % $Items.Count; $redraw = $true }
                ([ConsoleKey]::DownArrow) { $SelectedIndex = ($SelectedIndex + 1) % $Items.Count; $redraw = $true }
                ([ConsoleKey]::Enter) { return $Items[$SelectedIndex].Value }
                ([ConsoleKey]::Escape) { return $null }
                default {
                    foreach ($item in $Items) {
                        if ($item.HotKey -and $key.Key -eq $item.HotKey) { return $item.Value }
                    }
                }
            }
        }
    }
    finally { [Console]::CursorVisible = $oldCursorVisible }
}

function Get-ImageInfo {
    param([string]$Path)

    try {
        $readPath = Get-DecodedInputPath $Path
        $raw = & $script:magickPath -quiet -background none "$readPath[0]" -format '%m|%w|%h|%[opaque]' info: 2>$null
    } catch { return $null }
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($raw)) {
        return $null
    }

    $parts = ([string]$raw).Split('|')
    if ($parts.Count -lt 4) { return $null }

    return [pscustomobject]@{
        Format = $parts[0]
        Width = [int]$parts[1]
        Height = [int]$parts[2]
        Opaque = ($parts[3] -eq 'True')
        Bytes = (Get-Item -LiteralPath $Path).Length
    }
}

function Resolve-InputImages {
    param([array]$DroppedPaths)

    $candidates = New-Object System.Collections.Generic.List[string]

    foreach ($droppedPath in $DroppedPaths) {
        $path = ([string]$droppedPath).Trim().Trim([char]34)

        if (Test-Path -LiteralPath $path -PathType Container) {
            foreach ($file in Get-ChildItem -LiteralPath $path -File) {
                $candidates.Add($file.FullName)
            }
        }
        elseif (Test-Path -LiteralPath $path -PathType Leaf) {
            $candidates.Add([IO.Path]::GetFullPath($path))
        }
        else {
            Write-UiText "  [!] Not found: $path" -ForegroundColor Red
        }
    }

    $images = New-Object System.Collections.Generic.List[object]
    $seen = New-Object System.Collections.Generic.HashSet[string]([StringComparer]::OrdinalIgnoreCase)

    for ($index = 0; $index -lt $candidates.Count; $index++) {
        if ($candidates.Count -gt 1) {
            Write-Progress -Activity "Scanning for images" -Status "$($index + 1) of $($candidates.Count)" -PercentComplete ((($index + 1) / $candidates.Count) * 100)
        }

        $candidate = $candidates[$index]
        if (-not $seen.Add($candidate)) { continue }
        $info = Get-ImageInfo $candidate
        if ($null -ne $info) {
            $images.Add([pscustomobject]@{ Path = $candidate; Info = $info })
        }
        else {
            Write-UiText "  [!] Unsupported or unreadable: $([IO.Path]::GetFileName($candidate)). May require an optional decoder." -ForegroundColor Red
        }
    }

    Write-Progress -Activity "Scanning for images" -Completed
    return $images | ForEach-Object { $_ }
}

function Get-AvailableOutputPath {
    param(
        [string]$InputPath,
        [string]$Suffix,
        [string]$Extension
    )

    $folder = if ([string]::IsNullOrWhiteSpace($script:outputFolder)) {
        [IO.Path]::GetDirectoryName($InputPath)
    }
    else {
        $script:outputFolder
    }

    $name = [IO.Path]::GetFileNameWithoutExtension($InputPath)
    $candidate = [IO.Path]::Combine($folder, $name + $Suffix + $Extension)
    $number = 2

    while (Test-Path -LiteralPath $candidate) {
        $candidate = [IO.Path]::Combine($folder, $name + $Suffix + "_" + $number + $Extension)
        $number++
    }

    return $candidate
}

function Move-GeneratedFile {
    param([string]$Source, [string]$Destination)

    try {
        Copy-Item -LiteralPath $Source -Destination $Destination -ErrorAction Stop
        if (-not (Test-Path -LiteralPath $Destination -PathType Leaf)) {
            throw 'The copied output could not be verified.'
        }

        Remove-Item -LiteralPath $Source -Force -ErrorAction Stop
        return $true
    }
    catch {
        if (Test-Path -LiteralPath $Destination -PathType Leaf) {
            Remove-Item -LiteralPath $Destination -Force
        }
        return $false
    }
}

function Get-CopyrightText {
    param([string]$InputPath)

    foreach ($property in @('%[EXIF:Copyright]', '%[IPTC:2:116]')) {
        $value = & $script:magickPath identify -quiet -format $property "$InputPath[0]" 2>$null
        if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($value)) {
            return ([string]$value).Trim()
        }
    }

    $comment = & $script:magickPath identify -quiet -format '%[comment]' "$InputPath[0]" 2>$null
    if ($LASTEXITCODE -eq 0 -and ([string]$comment) -match '(?i)^\s*copyright\s*:\s*(.+)$') {
        return $matches[1].Trim()
    }

    $generic = & $script:magickPath identify -quiet -format '%[copyright]' "$InputPath[0]" 2>$null
    if (
        $LASTEXITCODE -eq 0 -and
        -not [string]::IsNullOrWhiteSpace($generic) -and
        ([string]$generic) -notmatch '(?i)ImageMagick Studio LLC'
    ) {
        return ([string]$generic).Trim()
    }

    return $null
}

function Get-MetadataArguments {
    param([string]$InputPath)

    $arguments = @('-strip')
    if (-not $script:preserveCopyright) { return $arguments }

    $copyright = Get-CopyrightText $InputPath
    if (-not [string]::IsNullOrWhiteSpace($copyright)) {
        $arguments += @(
            '-define', 'png:include-chunk=all',
            '-set', 'copyright', $copyright,
            '-set', 'exif:Copyright', $copyright,
            '-set', 'comment', "Copyright: $copyright"
        )
    }

    return $arguments
}

function New-ProcessResult {
    param(
        [string]$InputPath,
        [object]$Before,
        [string]$OutputPath,
        [double]$Seconds,
        [string]$Status,
        [string]$Message = ""
    )

    $after = if ($OutputPath -and (Test-Path -LiteralPath $OutputPath -PathType Leaf)) {
        Get-ImageInfo $OutputPath
    }
    else {
        $null
    }

    return [pscustomobject]@{
        Input = $InputPath
        Output = $OutputPath
        Before = $Before
        After = $after
        Seconds = $Seconds
        Status = $Status
        Message = $Message
    }
}

function Invoke-CompressionPass {
    param(
        [string]$InputPath,
        [string]$WorkingPath,
        [double]$Scale
    )

    $arguments = @(Get-ImageReadArguments $InputPath) + @('-auto-orient')
    $arguments += @(Get-MetadataArguments $InputPath)

    if ($Scale -lt 0.999) {
        $percentage = [Math]::Max(1, [Math]::Floor($Scale * 100))
        $arguments += @('-resize', "$percentage%")
    }

    $arguments += @(
        '-colorspace', 'sRGB',
        '-dither', 'FloydSteinberg',
        '-colors', '256',
        '-define', 'png:compression-level=6',
        '-define', 'png:compression-strategy=1',
        $WorkingPath
    )

    & $script:magickPath @arguments
    return $LASTEXITCODE
}

function Compress-Image {
    param([object]$Image)

    $inputPath = $Image.Path
    $before = $Image.Info
    $outputPath = Get-AvailableOutputPath $inputPath '_compressed' '.png'
    $workingPath = [IO.Path]::Combine([IO.Path]::GetDirectoryName($outputPath), '.image-tool-' + [Guid]::NewGuid().ToString('N') + '.png')
    $timer = [Diagnostics.Stopwatch]::StartNew()

    try {
        # Files already below the limit remain at their original dimensions.
        $scale = if ($before.Bytes -lt $sizeLimit) {
            1.0
        }
        else {
            [Math]::Min(0.90, [Math]::Sqrt($targetBytes / [double]$before.Bytes))
        }

        for ($attempt = 1; $attempt -le $maximumAttempts; $attempt++) {
            $exitCode = Invoke-CompressionPass $inputPath $workingPath $scale
            if ($exitCode -ne 0 -or -not (Test-Path -LiteralPath $workingPath -PathType Leaf)) {
                $timer.Stop()
                return New-ProcessResult $inputPath $before $null $timer.Elapsed.TotalSeconds 'Failed' 'Conversion failed'
            }

            $candidateSize = (Get-Item -LiteralPath $workingPath).Length
            if ($candidateSize -lt $sizeLimit) {
                if (-not (Move-GeneratedFile $workingPath $outputPath)) {
                    $timer.Stop()
                    return New-ProcessResult $inputPath $before $null $timer.Elapsed.TotalSeconds 'Failed' 'Could not save the compressed output'
                }

                $timer.Stop()
                return New-ProcessResult $inputPath $before $outputPath $timer.Elapsed.TotalSeconds 'OK'
            }

            $adjustment = [Math]::Sqrt($targetBytes / [double]$candidateSize)
            $scale = [Math]::Max(0.01, $scale * [Math]::Min(0.90, $adjustment))
        }

        $timer.Stop()
        return New-ProcessResult $inputPath $before $null $timer.Elapsed.TotalSeconds 'Failed' 'Could not reach the strict 5 MiB limit'
    }
    finally {
        if (Test-Path -LiteralPath $workingPath) {
            Remove-Item -LiteralPath $workingPath -Force
        }
    }
}

function Add-ImageBackground {
    param(
        [object]$Image,
        [string]$Color,
        [int]$PaddingPixels = 20
    )

    $inputPath = $Image.Path
    $before = $Image.Info
    $suffix = $Color.Replace('#', ''); $outputPath = Get-AvailableOutputPath $inputPath "_$suffix" '.png'
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $arguments = @(Get-ImageReadArguments $inputPath) + @('-auto-orient')

    # Trim only transparent edges. Opaque photographs keep their full canvas.
    if (-not $before.Opaque) {
        $arguments += @('-channel', 'A', '-trim', '+repage', '+channel')
    }

    $arguments += @(
        '-background', $Color,
        '-alpha', 'remove',
        '-alpha', 'off',
        '-bordercolor', $Color,
        '-border', "${PaddingPixels}x${PaddingPixels}"
    )
    $arguments += @(Get-MetadataArguments $inputPath)
    $arguments += $outputPath

    & $script:magickPath @arguments
    $timer.Stop()

    if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath $outputPath -PathType Leaf)) {
        return New-ProcessResult $inputPath $before $outputPath $timer.Elapsed.TotalSeconds 'OK'
    }

    if (Test-Path -LiteralPath $outputPath) { Remove-Item -LiteralPath $outputPath -Force }
    return New-ProcessResult $inputPath $before $null $timer.Elapsed.TotalSeconds 'Failed' 'Conversion failed'
}

function Invert-ImageColors {
    param([object]$Image)

    $inputPath = $Image.Path
    $before = $Image.Info
    $outputPath = Get-AvailableOutputPath $inputPath '_inverted' '.png'
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $arguments = @(Get-ImageReadArguments $inputPath) + @(
        '-auto-orient',
        '-colorspace', 'sRGB',
        '-channel', 'RGB',
        '-negate',
        '+channel'
    )
    $arguments += @(Get-MetadataArguments $inputPath)
    $arguments += $outputPath

    & $script:magickPath @arguments
    $timer.Stop()

    if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath $outputPath -PathType Leaf)) {
        return New-ProcessResult $inputPath $before $outputPath $timer.Elapsed.TotalSeconds 'OK'
    }

    if (Test-Path -LiteralPath $outputPath) { Remove-Item -LiteralPath $outputPath -Force }
    return New-ProcessResult $inputPath $before $null $timer.Elapsed.TotalSeconds 'Failed' 'Color inversion failed'
}

function Convert-Image {
    param(
        [object]$Image,
        [string]$Format,
        [string]$Extension
    )

    $inputPath = $Image.Path
    $before = $Image.Info
    $outputPath = Get-AvailableOutputPath $inputPath '_converted' $Extension
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $arguments = @(Get-ImageReadArguments $inputPath) + @('-auto-orient')
    $arguments += @(Get-MetadataArguments $inputPath)

    if ($Format -in @('JPEG', 'BMP')) {
        $arguments += @('-background', 'white', '-alpha', 'remove', '-alpha', 'off')
    }

    if ($Format -eq 'ICO') { $arguments += @('-resize', '256x256>') }

    if ($Format -in @('JPEG', 'WEBP', 'HEIC', 'AVIF')) {
        $arguments += @('-quality', '92')
    }

    $arguments += "$Format`:$outputPath"
    & $script:magickPath @arguments
    $timer.Stop()

    if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath $outputPath -PathType Leaf)) {
        return New-ProcessResult $inputPath $before $outputPath $timer.Elapsed.TotalSeconds 'OK'
    }

    if (Test-Path -LiteralPath $outputPath) { Remove-Item -LiteralPath $outputPath -Force }
    return New-ProcessResult $inputPath $before $null $timer.Elapsed.TotalSeconds 'Failed' 'Conversion failed'
}

function Get-WritableFormats {
    $formats = New-Object System.Collections.Generic.HashSet[string]([StringComparer]::OrdinalIgnoreCase)

    foreach ($line in (& $script:magickPath -list format)) {
        if ($line -match '^\s*([A-Z0-9]+)\*?\s+(?:\S+\s+)?([r-][w-][+-])\s+') {
            if ($matches[2][1] -eq 'w') { $null = $formats.Add($matches[1]) }
        }
    }

    # Prevent PowerShell from unrolling the HashSet into a plain string array.
    return ,$formats
}

function Select-ConversionFormat {
    param([System.Collections.Generic.HashSet[string]]$WritableFormats)

    $definitions = @(
        @{ Label = 'PNG'; Value = 'PNG|.png'; HotKey = [ConsoleKey]::P },
        @{ Label = 'JPEG'; Value = 'JPEG|.jpg'; HotKey = [ConsoleKey]::J },
        @{ Label = 'WebP'; Value = 'WEBP|.webp'; HotKey = [ConsoleKey]::W },
        @{ Label = 'GIF (first frame)'; Value = 'GIF|.gif'; HotKey = [ConsoleKey]::G },
        @{ Label = 'ICO (Windows icon)'; Value = 'ICO|.ico'; HotKey = [ConsoleKey]::C },
        @{ Label = 'JPEG 2000'; Value = 'JP2|.jp2'; HotKey = [ConsoleKey]::K },
        @{ Label = 'TIFF'; Value = 'TIFF|.tif'; HotKey = [ConsoleKey]::T },
        @{ Label = 'BMP'; Value = 'BMP|.bmp'; HotKey = [ConsoleKey]::B },
        @{ Label = 'HEIC'; Value = 'HEIC|.heic'; HotKey = [ConsoleKey]::H },
        @{ Label = 'AVIF'; Value = 'AVIF|.avif'; HotKey = [ConsoleKey]::A }
    )

    $items = @()
    foreach ($definition in $definitions) {
        $format = $definition.Value.Split('|')[0]
        if ($WritableFormats.Contains($format)) {
            $items += [pscustomobject]$definition
        }
    }

    $items += [pscustomobject]@{ Label = 'Other locally supported format...'; Value = 'OTHER'; HotKey = [ConsoleKey]::O }
    $choice = Show-ArrowMenu 'Convert to:' $items
    if ($null -eq $choice) { return $null }

    if ($choice -ne 'OTHER') { return $choice }

    Write-UiText
    $formatInput = Read-TextInput 'Enter an ImageMagick format name (Esc cancels):'
    if ($null -eq $formatInput) { return $null }
    $formatName = $formatInput.Trim().ToUpperInvariant()
    if (-not $WritableFormats.Contains($formatName)) {
        Write-UiText "  [!] That format is not writable on this computer." -ForegroundColor Red
        return $null
    }

    return "$formatName|.$($formatName.ToLowerInvariant())"
}

function Select-ActionChain {
    $actions = New-Object System.Collections.Generic.List[object]

    Write-UiText
    Write-UiText "  BUILD ACTION CHAIN" -ForegroundColor Cyan
    Write-UiText "  Press actions in the order they should run:" -ForegroundColor White
    Write-UiText "    [C] Compress  [W] White bg  [B] Black bg  [I] Invert  [F] Convert  [H] Custom bg" -ForegroundColor Gray
    Write-UiText "    [Backspace] Undo  [Enter] Run  [Esc] Cancel" -ForegroundColor DarkGray
    Write-UiText "  Tip: order matters; put Compress last if the final file must be below 5 MiB." -ForegroundColor DarkGray

    while ($true) {
        $chainText = if ($actions.Count -eq 0) {
            '(empty)'
        }
        else {
            (@($actions | ForEach-Object { Get-ActionLabel $_ }) -join ' -> ')
        }

        Write-UiText "  Chain: $chainText" -ForegroundColor $(if ($actions.Count -eq 0) { 'DarkGray' } else { 'Green' })
        $key = [Console]::ReadKey($true)

        if ($key.Key -eq [ConsoleKey]::Escape) {
            return $null
        }

        if ($key.Key -eq [ConsoleKey]::Enter) {
            if ($actions.Count -gt 0) {
                return [pscustomobject]@{
                    Type = 'chain'
                    Actions = @($actions | ForEach-Object { $_ })
                }
            }

            Write-UiText "  Add at least one action first." -ForegroundColor Yellow
            continue
        }

        if ($key.Key -eq [ConsoleKey]::Backspace) {
            if ($actions.Count -gt 0) {
                $actions.RemoveAt($actions.Count - 1)
                Write-UiText "  Removed the last action." -ForegroundColor Yellow
            }
            continue
        }

        if ($actions.Count -ge 8) {
            Write-UiText "  Maximum chain length reached (8 actions)." -ForegroundColor Yellow
            continue
        }

        switch ($key.Key) {
            ([ConsoleKey]::C) { $actions.Add([pscustomobject]@{ Type = 'compress' }) }
            ([ConsoleKey]::W) { $actions.Add([pscustomobject]@{ Type = 'white' }) }
            ([ConsoleKey]::B) { $actions.Add([pscustomobject]@{ Type = 'black' }) }
            ([ConsoleKey]::I) { $actions.Add([pscustomobject]@{ Type = 'invert' }) }
            ([ConsoleKey]::H) {
                $background = Select-CustomBackground
                if ($null -ne $background) { $actions.Add($background) }
            }
            ([ConsoleKey]::F) {
                $formatChoice = Select-ConversionFormat $script:writableFormats
                if ($null -ne $formatChoice) {
                    $parts = $formatChoice.Split('|')
                    $actions.Add([pscustomobject]@{
                        Type = 'convert'
                        Format = $parts[0]
                        Extension = $parts[1]
                    })
                }
            }
        }
    }
}

function Select-OutputLocation {
    $items = @(
        [pscustomobject]@{ Label = 'Save beside each original'; Value = 'SOURCE'; HotKey = [ConsoleKey]::S },
        [pscustomobject]@{ Label = 'Choose an existing output folder...'; Value = 'CUSTOM'; HotKey = [ConsoleKey]::C }
    )

    $choice = Show-ArrowMenu 'Output location:' $items
    if ($choice -eq 'SOURCE') {
        $script:outputFolder = $null
        Write-UiText "  Output reset to each source folder." -ForegroundColor Green
        return
    }

    if ($choice -eq 'CUSTOM') {
        $paths = @(Read-DroppedPaths 'Drop the output folder here' 'cancel')
        if ($paths.Count -eq 1 -and (Test-Path -LiteralPath $paths[0] -PathType Container)) {
            $script:outputFolder = [IO.Path]::GetFullPath($paths[0])
            Write-UiText "  Output: $($script:outputFolder)" -ForegroundColor Green
        }
        elseif ($paths.Count -gt 0) {
            Write-UiText "  [!] Please choose one existing folder." -ForegroundColor Red
        }
    }
}

function Get-ActionLabel {
    param([object]$Action)

    if ($null -eq $Action) { return '' }
    switch ($Action.Type) {
        'compress' { return 'Compress below 5 MiB' }
        'background' { return "Bg $($Action.Color) + $($Action.Padding) px" }
        'white' { return 'White background + padding' }
        'black' { return 'Black background + padding' }
        'invert' { return 'Invert colors' }
        'convert' { return "Convert to $($Action.Format)" }
        'chain' { return (@($Action.Actions | ForEach-Object { Get-ActionLabel $_ }) -join ' -> ') }
    }
}

function Select-Action {
    param([int]$ImageCount)

    while ($true) {
        $items = @()
        if ($null -ne $script:lastAction) {
            $items += [pscustomobject]@{
                Label = "Repeat last: $(Get-ActionLabel $script:lastAction)"
                Value = 'REPEAT'
                HotKey = [ConsoleKey]::R
            }
        }

        $items += @(
            [pscustomobject]@{ Label = 'Compress to PNG below 5 MiB'; Value = 'COMPRESS'; HotKey = [ConsoleKey]::C },
            [pscustomobject]@{ Label = 'White background + 20 px'; Value = 'WHITE'; HotKey = [ConsoleKey]::W },
            [pscustomobject]@{ Label = 'Black background + 20 px'; Value = 'BLACK'; HotKey = [ConsoleKey]::B },
            [pscustomobject]@{ Label = 'Custom background + padding...'; Value = 'BACKGROUND'; HotKey = [ConsoleKey]::H },
            [pscustomobject]@{ Label = 'Invert colors'; Value = 'INVERT'; HotKey = [ConsoleKey]::I },
            [pscustomobject]@{ Label = 'Convert format...'; Value = 'CONVERT'; HotKey = [ConsoleKey]::F },
            [pscustomobject]@{ Label = 'Build action chain...'; Value = 'CHAIN'; HotKey = [ConsoleKey]::A }
        )

        $outputLabel = if ([string]::IsNullOrWhiteSpace($script:outputFolder)) {
            'Output: beside each original'
        }
        else {
            "Output: $(Get-ShortText $script:outputFolder)"
        }

        $metadataLabel = if ($script:preserveCopyright) {
            'Metadata: remove all except copyright'
        }
        else {
            'Metadata: remove all'
        }

        $items += @(
            [pscustomobject]@{ Label = $outputLabel; Value = 'OUTPUT'; HotKey = [ConsoleKey]::O },
            [pscustomobject]@{ Label = $metadataLabel; Value = 'METADATA'; HotKey = [ConsoleKey]::M }
        )

        $choice = Show-ArrowMenu "Choose once for $ImageCount image$(if ($ImageCount -ne 1) { 's' }):" $items

        switch ($choice) {
            'REPEAT' { return $script:lastAction }
            'COMPRESS' { return [pscustomobject]@{ Type = 'compress' } }
            'WHITE' { return [pscustomobject]@{ Type = 'white' } }
            'BLACK' { return [pscustomobject]@{ Type = 'black' } }
            'BACKGROUND' {
                $background = Select-CustomBackground
                if ($null -ne $background) { return $background }
            }
            'INVERT' { return [pscustomobject]@{ Type = 'invert' } }
            'CHAIN' {
                $chain = Select-ActionChain
                if ($null -ne $chain) { return $chain }
            }
            'CONVERT' {
                $formatChoice = Select-ConversionFormat $script:writableFormats
                if ($null -ne $formatChoice) {
                    $parts = $formatChoice.Split('|')
                    return [pscustomobject]@{ Type = 'convert'; Format = $parts[0]; Extension = $parts[1] }
                }
            }
            'OUTPUT' { Select-OutputLocation }
            'METADATA' {
                $script:preserveCopyright = -not $script:preserveCopyright
                $state = if ($script:preserveCopyright) { 'Copyright will be preserved.' } else { 'All metadata will be removed.' }
                Write-UiText "  $state" -ForegroundColor Green
            }
            default { return $null }
        }
    }
}

function Get-ActionSuffix {
    param([object]$Action)

    switch ($Action.Type) {
        'compress' { return 'compressed' }
        'background' { return ('bg_' + $Action.Color.TrimStart('#') + '_' + $Action.Padding) }
        'white' { return 'white' }
        'black' { return 'black' }
        'invert' { return 'inverted' }
        'convert' { return "to_$($Action.Format.ToLowerInvariant())" }
    }
}

function Invoke-SingleAction {
    param([object]$Image, [object]$Action)

    switch ($Action.Type) {
        'compress' { return Compress-Image $Image }
        'background' { return Add-ImageBackground $Image $Action.Color $Action.Padding }
        'white' { return Add-ImageBackground $Image 'white' }
        'black' { return Add-ImageBackground $Image 'black' }
        'invert' { return Invert-ImageColors $Image }
        'convert' { return Convert-Image $Image $Action.Format $Action.Extension }
    }
}

function Invoke-ActionChainForImage {
    param([object]$Image, [object]$Chain)

    $originalOutputFolder = $script:outputFolder
    $temporaryRoot = [IO.Path]::Combine(
        [IO.Path]::GetTempPath(),
        'console-image-tool-chain-' + [Guid]::NewGuid().ToString('N')
    )
    $timer = [Diagnostics.Stopwatch]::StartNew()

    New-Item -ItemType Directory -Path $temporaryRoot | Out-Null

    try {
        $script:outputFolder = $temporaryRoot
        $currentImage = $Image

        foreach ($step in $Chain.Actions) {
            $stepResult = Invoke-SingleAction $currentImage $step
            if ($null -eq $stepResult -or $stepResult.Status -ne 'OK') {
                $timer.Stop()
                $message = if ($null -ne $stepResult -and $stepResult.Message) {
                    "$(Get-ActionLabel $step): $($stepResult.Message)"
                }
                else {
                    "$(Get-ActionLabel $step) failed"
                }

                return New-ProcessResult $Image.Path $Image.Info $null $timer.Elapsed.TotalSeconds 'Failed' $message
            }

            $currentImage = [pscustomobject]@{
                Path = $stepResult.Output
                Info = $stepResult.After
            }
        }

        $script:outputFolder = $originalOutputFolder
        $suffix = '_' + (@($Chain.Actions | ForEach-Object { Get-ActionSuffix $_ }) -join '_')
        $extension = [IO.Path]::GetExtension($currentImage.Path)
        $finalPath = Get-AvailableOutputPath $Image.Path $suffix $extension
        if (-not (Move-GeneratedFile $currentImage.Path $finalPath)) {
            $timer.Stop()
            return New-ProcessResult $Image.Path $Image.Info $null $timer.Elapsed.TotalSeconds 'Failed' 'Could not save the final chained output'
        }

        $timer.Stop()

        return New-ProcessResult $Image.Path $Image.Info $finalPath $timer.Elapsed.TotalSeconds 'OK'
    }
    finally {
        $script:outputFolder = $originalOutputFolder

        if (Test-Path -LiteralPath $temporaryRoot -PathType Container) {
            $resolvedTemporaryRoot = [IO.Path]::GetFullPath($temporaryRoot)
            $resolvedSystemTemp = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
            $temporaryName = [IO.Path]::GetFileName($resolvedTemporaryRoot)

            if (
                $resolvedTemporaryRoot.StartsWith($resolvedSystemTemp, [StringComparison]::OrdinalIgnoreCase) -and
                $temporaryName.StartsWith('console-image-tool-chain-', [StringComparison]::Ordinal)
            ) {
                Remove-Item -LiteralPath $resolvedTemporaryRoot -Recurse -Force
            }
        }
    }
}

function Invoke-ActionForImages {
    param([array]$Images, [object]$Action)

    $results = New-Object System.Collections.Generic.List[object]
    $label = Get-ActionLabel $Action

    for ($index = 0; $index -lt $Images.Count; $index++) {
        $fileName = [IO.Path]::GetFileName($Images[$index].Path)
        Write-Progress -Activity $label -Status "$($index + 1) of $($Images.Count): $fileName" -PercentComplete ((($index + 1) / $Images.Count) * 100)

        $result = if ($Action.Type -eq 'chain') {
            Invoke-ActionChainForImage $Images[$index] $Action
        }
        else {
            Invoke-SingleAction $Images[$index] $Action
        }

        $results.Add($result)
    }

    Write-Progress -Activity $label -Completed
    return $results | ForEach-Object { $_ }
}

function Write-Results {
    param([array]$Results)

    Write-UiText
    Write-UiText "  RESULTS" -ForegroundColor Cyan
    Write-UiText "  -------" -ForegroundColor DarkCyan

    if ($Results.Count -eq 1) {
        $result = $Results[0]
        $before = $result.Before
        Write-UiText "  Before: $($before.Format)  $($before.Width)x$($before.Height)  $(Format-FileSize $before.Bytes)" -ForegroundColor Gray

        if ($result.Status -eq 'OK') {
            $after = $result.After
            $change = if ($before.Bytes -gt 0) { (($after.Bytes - $before.Bytes) / [double]$before.Bytes) * 100 } else { 0 }
            $changeText = if ($change -lt 0) { "{0:N0}% smaller" -f (-$change) } elseif ($change -gt 0) { "{0:N0}% larger" -f $change } else { 'same size' }
            Write-UiText "  After:  $($after.Format)  $($after.Width)x$($after.Height)  $(Format-FileSize $after.Bytes)  ($changeText)" -ForegroundColor Green
            Write-UiText "  Time:   $($result.Seconds.ToString('N2')) s" -ForegroundColor DarkGray
            Write-UiText "  Saved:  $($result.Output)" -ForegroundColor White
        }
        else {
            Write-UiText "  Failed: $($result.Message)" -ForegroundColor Red
        }

        return
    }

    $rows = foreach ($result in $Results) {
        if ($result.Status -eq 'OK') {
            $change = if ($result.Before.Bytes -gt 0) { (($result.After.Bytes - $result.Before.Bytes) / [double]$result.Before.Bytes) * 100 } else { 0 }
            $changeText = if ($change -lt 0) { "-{0:N0}%" -f (-$change) } elseif ($change -gt 0) { "+{0:N0}%" -f $change } else { '0%' }
            [pscustomobject]@{
                File = Get-ShortText ([IO.Path]::GetFileName($result.Input)) 28
                Before = "$($result.Before.Width)x$($result.Before.Height) $(Format-FileSize $result.Before.Bytes)"
                After = "$($result.After.Width)x$($result.After.Height) $(Format-FileSize $result.After.Bytes)"
                Change = $changeText
                Time = "$($result.Seconds.ToString('N2'))s"
                Status = 'OK'
            }
        }
        else {
            [pscustomobject]@{
                File = Get-ShortText ([IO.Path]::GetFileName($result.Input)) 28
                Before = "$($result.Before.Width)x$($result.Before.Height) $(Format-FileSize $result.Before.Bytes)"
                After = '-'
                Change = '-'
                Time = "$($result.Seconds.ToString('N2'))s"
                Status = 'FAILED'
            }
        }
    }

    if ([Console]::WindowWidth -lt 100) {
        foreach ($result in $Results) {
            Write-UiText "  $([IO.Path]::GetFileName($result.Input))" -ForegroundColor White
            if ($result.Status -eq 'OK') {
                Write-UiText "  OK: $($result.After.Width)x$($result.After.Height), $(Format-FileSize $result.After.Bytes)" -ForegroundColor Green
                Write-UiText "  Saved: $($result.Output)" -ForegroundColor DarkGray
            } else { Write-UiText "  Failed: $($result.Message)" -ForegroundColor Red }
        }
    } else { $rows | Format-Table -AutoSize | Out-Host }
    $succeeded = @($Results | Where-Object Status -eq 'OK').Count
    $failed = $Results.Count - $succeeded
    Write-UiText "  Completed: $succeeded succeeded, $failed failed." -ForegroundColor $(if ($failed -eq 0) { 'Green' } else { 'Yellow' })
    if ([string]::IsNullOrWhiteSpace($script:outputFolder)) {
        Write-UiText "  Outputs were saved beside their originals." -ForegroundColor DarkGray
    }
    else {
        Write-UiText "  Output folder: $($script:outputFolder)" -ForegroundColor DarkGray
    }
}

if ($LibraryOnly) { return }
Initialize-ImageTool
try {
Write-Banner
$script:writableFormats = Get-WritableFormats
$pendingPaths = @()
for ($number = 1; $number -le 9; $number++) {
    $value = [Environment]::GetEnvironmentVariable("IMAGE_TOOL_INITIAL_$number")
    if (-not [string]::IsNullOrWhiteSpace($value)) { $pendingPaths += $value }
}

while ($true) {
    $droppedPaths = if ($pendingPaths.Count -gt 0) {
        $items = @($pendingPaths)
        $pendingPaths = @()
        Write-UiText
        Write-UiText "  Received $($items.Count) item$(if ($items.Count -ne 1) { 's' })." -ForegroundColor Cyan
        $items
    }
    else {
        @(Read-DroppedPaths)
    }

    if ($droppedPaths.Count -eq 0) { break }

    $images = @(Resolve-InputImages $droppedPaths)
    if ($images.Count -eq 0) {
        Write-UiText "  [!] No readable images found." -ForegroundColor Red
        continue
    }

    Write-UiText "  Ready: $($images.Count) image$(if ($images.Count -ne 1) { 's' })." -ForegroundColor Green
    $action = Select-Action $images.Count
    if ($null -eq $action) {
        Write-UiText "  Cancelled." -ForegroundColor Yellow
        continue
    }

    Write-UiText ("  Action: " + (Get-ActionLabel $action)) -ForegroundColor Cyan
    $results = @(Invoke-ActionForImages $images $action)
    $script:lastAction = $action
    Write-Results $results
}
} finally { Remove-ImageToolTemporaryInputs }

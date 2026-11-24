# Execution example (in case PowerShell ExecutionPolicy blocks script execution):
# powershell -ExecutionPolicy Bypass -File ".\WallShift.ps1" -image ".\Windows Dark 4k HD.jpg"
# powershell -ExecutionPolicy Bypass -File ".\WallShift.ps1" -image ".\Windows Dark Logo 4k HD.jpg"

param (
    [Alias("image")]
    [string]$imagem,
    [switch]$help,
    [switch]$h
)

function Show-Help {
    Write-Output ""
    Write-Output "==============================="
    Write-Output "       WallShift - HELP"
    Write-Output "==============================="
    Write-Output ""
    Write-Output "Usage:"
    Write-Output "    .\WallShift.ps1 -image PATH_OR_URL"
    Write-Output ""
    Write-Output "Examples:"
    Write-Output "    .\WallShift.ps1 -image "C:\Wallpapers\photo.jpg""
    Write-Output "    .\WallShift.ps1 -image "https://site.com/image.jpg""
    Write-Output ""
    Write-Output "The wallpaper is automatically set to stretch (WallpaperStyle=2)."
    Write-Output "Web URLs are downloaded automatically."
    Write-Output ""
    exit 0
}

if ($help -or $h -or -not $imagem) {
    Show-Help
}

# Define pasta temporária
$tempDir = "$env:TEMP\WallpaperChanger"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
$finalPath = $imagem

# Verifica se é URL e baixa imagem se necessário
if ($imagem -match "^https?://") {
    $downloadedFile = "$tempDir\wallpaper.jpg"
    try {
        Invoke-WebRequest -Uri $imagem -OutFile $downloadedFile -ErrorAction Stop
        $finalPath = $downloadedFile
    } catch {
        exit 1
    }
} elseif (-Not (Test-Path $imagem)) {
    exit 1
}

# Converte para caminho completo
$finalPath = (Get-Item $finalPath).FullName

# Atualiza registro
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value $finalPath
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -Value "2"
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -Value "0"

# Atualiza TranscodedWallpaper
$themeWallpaper = "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaper"
try {
    Copy-Item -Path $finalPath -Destination $themeWallpaper -Force
} catch {}

# Aplica usando API
Add-Type @"
using System.Runtime.InteropServices;
public class NativeMethods {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

[NativeMethods]::SystemParametersInfo(20, 0, $finalPath, 3) | Out-Null

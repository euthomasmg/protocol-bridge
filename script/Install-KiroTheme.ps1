# Exemplo de execução (caso a política de execução do PowerShell bloqueie o script):
# powershell -ExecutionPolicy Bypass -File ".\script\Install-KiroTheme.ps1"

param (
    [ValidateSet("Kiro Dark", "Kiro Light", "Neo Kiro Dark", "Neo Kiro Light")]
    [string]$Theme = "Kiro Dark",
    [switch]$IncludeVSCode,
    [switch]$KeepDefaultIcons,
    [switch]$Force,
    [switch]$Help,
    [switch]$h
)

function Show-Help {
    Write-Output ""
    Write-Output "=========================================="
    Write-Output "    Kiro Theme Installer - AJUDA"
    Write-Output "=========================================="
    Write-Output ""
    Write-Output "Instala automaticamente os temas, icones (kiricons + Material) e ajustes"
    Write-Output "exatos de cores do Kiro IDE no Antigravity IDE (e opcionalmente no VS Code)."
    Write-Output ""
    Write-Output "Uso:"
    Write-Output "    powershell -ExecutionPolicy Bypass -File .\Install-KiroTheme.ps1 [opcoes]"
    Write-Output ""
    Write-Output "Opcoes:"
    Write-Output "    -Theme <nome>        Tema para ativar (padrao: 'Kiro Dark')."
    Write-Output "                         Valores: 'Kiro Dark', 'Kiro Light', 'Neo Kiro Dark', 'Neo Kiro Light'"
    Write-Output "    -IncludeVSCode       Tambem instala e aplica no Visual Studio Code."
    Write-Output "    -KeepDefaultIcons    Nao altera os icones da barra lateral para 'kiricons'."
    Write-Output "    -Force               Reinstala as extensoes mesmo se ja estiverem instaladas."
    Write-Output "    -Help, -h            Mostra esta mensagem de ajuda."
    Write-Output ""
    exit 0
}

if ($Help -or $h) {
    Show-Help
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Get-VsixFromMarketplace {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ExtensionId,
        [Parameter(Mandatory = $true)]
        [string]$OutFile
    )

    $body = @{
        filters = @(@{
            criteria = @(
                @{ filterType = 8; value = "Microsoft.VisualStudio.Code" },
                @{ filterType = 7; value = $ExtensionId }
            )
            pageNumber = 1
            pageSize   = 1
        })
        flags = 514
    } | ConvertTo-Json -Depth 5

    $headers = @{ "Accept" = "application/json;api-version=3.0-preview.1" }
    $queryUrl = "https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery"

    $response = Invoke-RestMethod -Uri $queryUrl -Method Post -Body $body -ContentType "application/json" -Headers $headers -ErrorAction Stop
    $ext = $response.results[0].extensions[0]
    if (-not $ext) {
        throw "Extensao '$ExtensionId' nao encontrada no Marketplace."
    }

    $vsixUrl = $ext.versions[0].files |
        Where-Object { $_.assetType -eq "Microsoft.VisualStudio.Services.VSIXPackage" } |
        Select-Object -First 1 -ExpandProperty source

    if (-not $vsixUrl) {
        $parts = $ExtensionId.Split('.')
        $vsixUrl = "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/$($parts[0])/vsextensions/$($parts[1])/latest/vspackage"
    }

    $oldProgress = $ProgressPreference
    try {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $vsixUrl -OutFile $OutFile -UseBasicParsing -ErrorAction Stop
    } finally {
        $ProgressPreference = $oldProgress
    }
}

function Set-JsoncSetting {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SettingsPath,
        [Parameter(Mandatory = $true)]
        [string]$Key,
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    $dir = Split-Path -Parent $SettingsPath
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)

    if (-not (Test-Path $SettingsPath)) {
        $initial = "{`r`n    `"$Key`": `"$Value`"`r`n}`r`n"
        [System.IO.File]::WriteAllText($SettingsPath, $initial, $utf8NoBom)
        return
    }

    $content = [System.IO.File]::ReadAllText($SettingsPath, [System.Text.Encoding]::UTF8)
    if ([string]::IsNullOrWhiteSpace($content) -or $content -match '^\s*\{\s*\}\s*$') {
        $updated = "{`r`n    `"$Key`": `"$Value`"`r`n}`r`n"
        [System.IO.File]::WriteAllText($SettingsPath, $updated, $utf8NoBom)
        return
    }

    $escapedKey = [regex]::Escape($Key)
    $keyPattern = "(?m)^(\s*)`"$escapedKey`"\s*:\s*`"[^`"]*`""

    if ([regex]::IsMatch($content, $keyPattern)) {
        $updated = [regex]::Replace($content, $keyPattern, "`$1`"$Key`": `"$Value`"")
    } else {
        $openBracePattern = "^(\s*(?://[^\r\n]*\r?\n|\s)*)\{"
        $updated = [regex]::Replace($content, $openBracePattern, "`$1{`r`n    `"$Key`": `"$Value`",", 1)
    }

    [System.IO.File]::WriteAllText($SettingsPath, $updated, $utf8NoBom)
}

function Update-IdeSettings {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SettingsPath,
        [Parameter(Mandatory = $true)]
        [string]$ThemeName,
        [switch]$SkipKiroIcons
    )

    $dir = Split-Path -Parent $SettingsPath
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $kiroColors = [ordered]@{
        "editor.selectionBackground"       = "#c099ff40"
        "tree.indentGuidesStroke"          = "#938f9b80"
        "tree.inactiveIndentGuidesStroke"  = "#938f9b40"
        "panel.border"                     = "#00000000"
        "terminal.border"                  = "#4a464f"
    }

    $raw = if (Test-Path $SettingsPath) {
        [System.IO.File]::ReadAllText($SettingsPath, [System.Text.Encoding]::UTF8)
    } else {
        "{}"
    }
    if ([string]::IsNullOrWhiteSpace($raw)) { $raw = "{}" }

    try {
        $obj = $raw | ConvertFrom-Json -ErrorAction Stop
        if (-not $obj) { $obj = New-Object PSCustomObject }

        $obj | Add-Member -NotePropertyName "workbench.colorTheme" -NotePropertyValue $ThemeName -Force
        $obj | Add-Member -NotePropertyName "workbench.iconTheme" -NotePropertyValue "material-icon-theme" -Force
        if (-not $SkipKiroIcons) {
            $obj | Add-Member -NotePropertyName "workbench.productIconTheme" -NotePropertyValue "kiricons" -Force
        }

        $colorCust = $obj."workbench.colorCustomizations"
        if (-not $colorCust) {
            $colorCust = New-Object PSCustomObject
        }
        $colorCust | Add-Member -NotePropertyName "[Kiro Dark]" -NotePropertyValue ([PSCustomObject]$kiroColors) -Force
        $obj | Add-Member -NotePropertyName "workbench.colorCustomizations" -NotePropertyValue $colorCust -Force

        $formatted = ($obj | ConvertTo-Json -Depth 10) + "`r`n"
        [System.IO.File]::WriteAllText($SettingsPath, $formatted, $utf8NoBom)
    } catch {
        # Fallback caso settings.json contenha comentarios '//' (JSONC)
        Set-JsoncSetting -SettingsPath $SettingsPath -Key "workbench.iconTheme" -Value "material-icon-theme"
        if (-not $SkipKiroIcons) {
            Set-JsoncSetting -SettingsPath $SettingsPath -Key "workbench.productIconTheme" -Value "kiricons"
        }
        Set-JsoncSetting -SettingsPath $SettingsPath -Key "workbench.colorTheme" -Value $ThemeName

        $current = [System.IO.File]::ReadAllText($SettingsPath, [System.Text.Encoding]::UTF8)
        if ($current -notmatch '"workbench\.colorCustomizations"') {
            $block = @"
    "workbench.colorCustomizations": {
        "[Kiro Dark]": {
            "editor.selectionBackground": "#c099ff40",
            "tree.indentGuidesStroke": "#938f9b80",
            "tree.inactiveIndentGuidesStroke": "#938f9b40",
            "panel.border": "#00000000",
            "terminal.border": "#4a464f"
        }
    },
"@
            $openBracePattern = "^(\s*(?://[^\r\n]*\r?\n|\s)*)\{"
            $updated = [regex]::Replace($current, $openBracePattern, "`$1{`r`n$block", 1)
            [System.IO.File]::WriteAllText($SettingsPath, $updated, $utf8NoBom)
        }
    }
}

function Find-Targets {
    $targets = @()

    # 1. Antigravity IDE
    $agyCandidates = @(
        "$env:LOCALAPPDATA\Programs\Antigravity IDE\bin\antigravity-ide.cmd",
        "$env:ProgramFiles\Antigravity IDE\bin\antigravity-ide.cmd"
    )
    $agyCmd = Get-Command "antigravity-ide.cmd", "antigravity-ide" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($agyCmd) { $agyCandidates += $agyCmd.Source }

    $agyCli = $agyCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
    if ($agyCli) {
        $targets += [PSCustomObject]@{
            Name          = "Antigravity IDE"
            CliPath       = $agyCli
            ExtensionsDir = "$env:USERPROFILE\.antigravity-ide\extensions"
            SettingsPath  = "$env:APPDATA\Antigravity IDE\User\settings.json"
        }
    }

    # 2. Visual Studio Code (se solicitado ou se Antigravity nao estiver instalado)
    if ($IncludeVSCode -or $targets.Count -eq 0) {
        $codeCandidates = @(
            "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
            "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd"
        )
        $codeCmd = Get-Command "code.cmd", "code" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($codeCmd) { $codeCandidates += $codeCmd.Source }

        $codeCli = $codeCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
        if ($codeCli) {
            $targets += [PSCustomObject]@{
                Name          = "Visual Studio Code"
                CliPath       = $codeCli
                ExtensionsDir = "$env:USERPROFILE\.vscode\extensions"
                SettingsPath  = "$env:APPDATA\Code\User\settings.json"
            }
        }
    }

    return $targets
}

$targets = @(Find-Targets)
if ($targets.Count -eq 0) {
    Write-Error "Nenhuma instalacao do Antigravity IDE ou VS Code foi encontrada neste computador."
    exit 1
}

$extensions = @(
    @{ Id = "MohdZaid.kiro-theme";       Label = "Kiro Theme (Oficial Dark/Light)" },
    @{ Id = "jeanluc243.Neokiro-theme";  Label = "Neo Kiro Theme + Icones" },
    @{ Id = "PKief.material-icon-theme"; Label = "Material Icon Theme" }
)

$tempDir = Join-Path $env:TEMP "KiroThemeInstaller"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

Write-Host ""
Write-Host "=== Instalador do Tema Kiro IDE ===" -ForegroundColor Magenta

foreach ($target in $targets) {
    Write-Host "`n-> Configurando $($target.Name)..." -ForegroundColor Cyan

    foreach ($ext in $extensions) {
        $prefix = $ext.Id.ToLower()
        $alreadyInstalled = (-not $Force) -and (Test-Path $target.ExtensionsDir) -and
            [bool](Get-ChildItem -Path $target.ExtensionsDir -Directory -Filter "$prefix*" -ErrorAction SilentlyContinue)

        if ($alreadyInstalled) {
            Write-Host "   [OK] $($ext.Label) ja esta instalado." -ForegroundColor Green
            continue
        }

        $vsixFile = Join-Path $tempDir "$($ext.Id).vsix"
        if (-not (Test-Path $vsixFile) -or $Force) {
            Write-Host "   [..] Baixando $($ext.Label)..." -ForegroundColor Yellow
            try {
                Get-VsixFromMarketplace -ExtensionId $ext.Id -OutFile $vsixFile
            } catch {
                Write-Warning "   Falha ao baixar $($ext.Id): $_"
                continue
            }
        }

        Write-Host "   [..] Instalando $($ext.Label)..." -ForegroundColor Yellow
        $installArgs = @("--install-extension", $vsixFile)
        if ($Force) { $installArgs += "--force" }

        $output = & $target.CliPath @installArgs 2>&1 | Out-String
        $installedNow = ($output -match "successfully installed|instalada com êxito") -or
            ((Test-Path $target.ExtensionsDir) -and [bool](Get-ChildItem -Path $target.ExtensionsDir -Directory -Filter "$prefix*" -ErrorAction SilentlyContinue))

        if ($installedNow) {
            Write-Host "   [OK] $($ext.Label) instalado com sucesso!" -ForegroundColor Green
        } else {
            Write-Warning "   Nao foi possivel confirmar a instalacao de $($ext.Id). Saida:`n$output"
        }
    }

    Write-Host "   [..] Aplicando tema '$Theme', icones e cores exatas do Kiro em settings.json..." -ForegroundColor Yellow
    Update-IdeSettings -SettingsPath $target.SettingsPath -ThemeName $Theme -SkipKiroIcons:$KeepDefaultIcons
    Write-Host "   [OK] Configuracoes salvas em: $($target.SettingsPath)" -ForegroundColor Green
}

Write-Host ""
Write-Host "Concluido! Se a IDE estiver aberta, pressione Ctrl+Shift+P -> 'Reload Window' para recarregar o visual." -ForegroundColor Magenta
Write-Host ""

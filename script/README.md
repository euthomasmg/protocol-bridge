# ⚡ WallShift — Dynamic Wallpaper Engine

Script em PowerShell para alterar o plano de fundo da área de trabalho do Windows instantaneamente via Win32 API, com suporte a imagens locais e URLs da web.

---

## 📁 Arquivos Inclusos

- **`WallShift.ps1`**: Script que baixa/carrega a imagem, atualiza o registro e aciona a API do Windows.
- **`Install-KiroTheme.ps1`**: Script que baixa e instala automaticamente o visual completo do **Kiro IDE** (temas + ícones) no Antigravity IDE / VS Code.
- **`Windows Dark 4k HD.jpg`**: Papel de parede estilo Dark Minimal (Opção 1).
- **`Windows Dark Logo 4k HD.jpg`**: Papel de parede estilo Dark Windows Logo (Opção 2).

---

## 🚀 Comandos Prontos para Executar

Abra o terminal **PowerShell** e copie o comando da opção desejada:

### Se o terminal estiver na raiz do projeto (`protocol-bridge`):

#### 🔹 Opção 1: Dark Minimal Background
```powershell
powershell -ExecutionPolicy Bypass -File ".\script\WallShift.ps1" -image ".\script\Windows Dark 4k HD.jpg"
```

#### 🔹 Opção 2: Dark Windows Logo
```powershell
powershell -ExecutionPolicy Bypass -File ".\script\WallShift.ps1" -image ".\script\Windows Dark Logo 4k HD.jpg"
```

---

### Se o terminal estiver dentro da pasta (`script`):

```powershell
cd D:\Thomas\protocol-bridge\script
```

#### 🔹 Opção 1:
```powershell
powershell -ExecutionPolicy Bypass -File ".\WallShift.ps1" -image ".\Windows Dark 4k HD.jpg"
```

#### 🔹 Opção 2:
```powershell
powershell -ExecutionPolicy Bypass -File ".\WallShift.ps1" -image ".\Windows Dark Logo 4k HD.jpg"
```

---

## 🌐 Usando com Outras Imagens ou Links da Web

O script aceita tanto `-image` quanto `-imagem`:

```powershell
# Imagem local qualquer:
powershell -ExecutionPolicy Bypass -File ".\WallShift.ps1" -image "C:\Users\User\Pictures\minha_foto.jpg"

# Imagem direta da internet (download automático):
powershell -ExecutionPolicy Bypass -File ".\WallShift.ps1" -image "https://images.unsplash.com/photo-1506744038136-46273834b3fb"
```

---

> **Dica:** O parâmetro `-ExecutionPolicy Bypass` evita qualquer restrição de política de execução do PowerShell no Windows.

---

## 🎨 Instalar o Visual do Kiro IDE em Outro Computador

Para aplicar automaticamente o tema **`Kiro Dark`** (com as 212 cores exatas do Kiro original) + **`kiricons`** + **`Material Icon Theme`** na IDE em qualquer outro PC Windows:

### Executando da raiz do projeto (`protocol-bridge`):
```powershell
powershell -ExecutionPolicy Bypass -File ".\script\Install-KiroTheme.ps1"
```

### Opções extras:
```powershell
# Instalar tanto no Antigravity IDE quanto no VS Code:
powershell -ExecutionPolicy Bypass -File ".\script\Install-KiroTheme.ps1" -IncludeVSCode

# Manter os ícones padrão da barra lateral (sem kiricons):
powershell -ExecutionPolicy Bypass -File ".\script\Install-KiroTheme.ps1" -KeepDefaultIcons
```

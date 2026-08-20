# ╔═════════════════════════════════════════════════════════════╗
# ║   Grade Uploader — Script de instalación para Windows        ║
# ╚═════════════════════════════════════════════════════════════╝

$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "Grade Uploader - Instalación"

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       Grade Uploader — Instalación automática           ║" -ForegroundColor Cyan
Write-Host "║       Notas Parciales UNED                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# --- Paso 1: Verificar Python ---
Write-Host "[1/4] Verificando Python..." -ForegroundColor Yellow

$pythonCmd = $null
foreach ($cmd in @("python", "python3", "py")) {
    try {
        $version = & $cmd --version 2>&1
        if ($version -match "Python 3\.(\d+)") {
            $minor = [int]$Matches[1]
            if ($minor -ge 10) {
                $pythonCmd = $cmd
                Write-Host "  OK: $version encontrado ($cmd)" -ForegroundColor Green
                break
            } else {
                Write-Host "  ADVERTENCIA: $version encontrado pero se requiere 3.10+" -ForegroundColor Yellow
            }
        }
    } catch {
        continue
    }
}

if (-not $pythonCmd) {
    Write-Host ""
    Write-Host "  ERROR: Python 3.10+ no encontrado." -ForegroundColor Red
    Write-Host ""
    Write-Host "  Para instalar Python en Windows:" -ForegroundColor White
    Write-Host ""
    Write-Host "  Opción 1 (recomendada): Desde Microsoft Store" -ForegroundColor Cyan
    Write-Host "    Abrí Microsoft Store y buscá 'Python 3.12'" -ForegroundColor White
    Write-Host ""
    Write-Host "  Opción 2: Desde la web" -ForegroundColor Cyan
    Write-Host "    1. Andá a https://www.python.org/downloads/" -ForegroundColor White
    Write-Host "    2. Descargá la versión más reciente (3.12+)" -ForegroundColor White
    Write-Host "    3. Al instalar, MARCÁ la casilla 'Add Python to PATH'" -ForegroundColor White
    Write-Host ""
    Write-Host "  Opción 3: Con winget (si lo tenés)" -ForegroundColor Cyan
    Write-Host "    winget install Python.Python.3.12" -ForegroundColor White
    Write-Host ""
    Write-Host "  Después de instalar Python, cerrá esta ventana y" -ForegroundColor Yellow
    Write-Host "  ejecutá instalar.bat de nuevo." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Presioná Enter para cerrar"
    exit 1
}

# --- Paso 2: Crear entorno virtual ---
Write-Host "[2/4] Creando entorno virtual (.venv)..." -ForegroundColor Yellow

if (Test-Path ".venv") {
    Write-Host "  Ya existe .venv, reutilizando..." -ForegroundColor Gray
} else {
    & $pythonCmd -m venv .venv
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ERROR: No se pudo crear el entorno virtual." -ForegroundColor Red
        Read-Host "Presioná Enter para cerrar"
        exit 1
    }
    Write-Host "  OK: Entorno virtual creado" -ForegroundColor Green
}

# --- Paso 3: Instalar dependencias ---
Write-Host "[3/4] Instalando dependencias..." -ForegroundColor Yellow

& .venv\Scripts\pip.exe install -r requirements.txt --quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ERROR: No se pudieron instalar las dependencias." -ForegroundColor Red
    Write-Host "  Intentá manualmente: .venv\Scripts\pip.exe install -r requirements.txt" -ForegroundColor Yellow
    Read-Host "Presioná Enter para cerrar"
    exit 1
}
Write-Host "  OK: Dependencias instaladas" -ForegroundColor Green

# --- Paso 4: Crear .env ---
Write-Host "[4/4] Configurando archivo .env..." -ForegroundColor Yellow

if (Test-Path ".env") {
    Write-Host "  Ya existe .env, no se sobrescribe." -ForegroundColor Gray
    Write-Host "  (Si necesitás empezar de cero, borrá .env y ejecutá de nuevo)" -ForegroundColor Gray
} else {
    Copy-Item ".env.example" ".env"
    Write-Host "  OK: .env creado desde plantilla" -ForegroundColor Green
}

# --- Listo ---
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║              Instalación completada                     ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Próximos pasos:" -ForegroundColor White
Write-Host ""
Write-Host "  1. Abrí el archivo .env con un editor de texto" -ForegroundColor Cyan
Write-Host "     y completá tus credenciales NTLM y cookies." -ForegroundColor Cyan
Write-Host "     (Consultá el README.md para instrucciones detalladas)" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Para usar el script, primero activá el entorno virtual:" -ForegroundColor Cyan
Write-Host "     .venv\Scripts\activate" -ForegroundColor White
Write-Host ""
Write-Host "  3. Probá la conexión con:" -ForegroundColor Cyan
Write-Host "     python notasparciales_upload.py probe --ano 2026 ..." -ForegroundColor White
Write-Host ""
Read-Host "Presioná Enter para cerrar"

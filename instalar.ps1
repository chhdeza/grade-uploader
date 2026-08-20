# ╔═════════════════════════════════════════════════════════════╗
# ║   Grade Uploader — Script de instalación para Windows        ║
# ╚═════════════════════════════════════════════════════════════╝

$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "Grade Uploader - Instalación"

# Trabajar SIEMPRE en la carpeta donde está este script, no en el directorio
# actual. Si el usuario hace "Ejecutar como administrador", Windows arranca en
# C:\Windows\System32 y las rutas relativas (.venv, requirements.txt, .env)
# apuntarían al lugar equivocado.
Set-Location -LiteralPath $PSScriptRoot

# Con ErrorActionPreference="Stop", cualquier error no previsto termina el
# script; sin este trap la ventana se cerraría de golpe y el usuario no
# alcanzaría a leer qué pasó.
trap {
    Write-Host ""
    Write-Host "  ERROR INESPERADO durante la instalación:" -ForegroundColor Red
    Write-Host "  $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Copiá este mensaje y pedí ayuda con él." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Presioná Enter para cerrar"
    exit 1
}

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       Grade Uploader — Instalación automática           ║" -ForegroundColor Cyan
Write-Host "║       Notas Parciales UNED                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# --- Paso 1: Verificar Python ---
Write-Host "[1/5] Verificando Python..." -ForegroundColor Yellow

$pythonCmd = $null
foreach ($cmd in @("python", "python3", "py")) {
    try {
        # 2>$null y no 2>&1: en PowerShell 5.1, redirigir stderr de un .exe
        # envuelve cada línea en un ErrorRecord y, con ErrorActionPreference
        # en "Stop", eso puede abortar la detección y reportar por error que
        # Python no está instalado.
        $version = (& $cmd --version 2>$null | Out-String).Trim()
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
Write-Host "[2/5] Creando entorno virtual (.venv)..." -ForegroundColor Yellow

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
Write-Host "[3/5] Instalando dependencias..." -ForegroundColor Yellow

if (-not (Test-Path "requirements.txt")) {
    Write-Host "  ERROR: No se encontró requirements.txt." -ForegroundColor Red
    Write-Host "  Asegurate de haber descargado el proyecto completo," -ForegroundColor Yellow
    Write-Host "  no solo el archivo instalar.bat." -ForegroundColor Yellow
    Read-Host "Presioná Enter para cerrar"
    exit 1
}

& .venv\Scripts\pip.exe install -r requirements.txt --quiet --disable-pip-version-check
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ERROR: No se pudieron instalar las dependencias." -ForegroundColor Red
    Write-Host "  Detalle del error:" -ForegroundColor Yellow
    Write-Host ""
    # Reintento sin --quiet para que el usuario vea el motivo real
    # (sin red, proxy de la UNED, permisos, etc.) y lo pueda reportar.
    & .venv\Scripts\pip.exe install -r requirements.txt
    Write-Host ""
    Read-Host "Presioná Enter para cerrar"
    exit 1
}
Write-Host "  OK: Dependencias instaladas" -ForegroundColor Green

# --- Paso 4: Crear .env ---
Write-Host "[4/5] Configurando archivo .env..." -ForegroundColor Yellow

if (Test-Path ".env") {
    Write-Host "  Ya existe .env, no se sobrescribe." -ForegroundColor Gray
    Write-Host "  (Si necesitás empezar de cero, borrá .env y ejecutá de nuevo)" -ForegroundColor Gray
} elseif (Test-Path ".env.example") {
    Copy-Item ".env.example" ".env"
    Write-Host "  OK: .env creado desde plantilla" -ForegroundColor Green
} else {
    Write-Host "  ADVERTENCIA: no se encontró .env.example." -ForegroundColor Yellow
    Write-Host "  Vas a tener que crear el archivo .env a mano con estas dos líneas:" -ForegroundColor Yellow
    Write-Host "     NP_NTLM_USER=tu_usuario" -ForegroundColor White
    Write-Host "     NP_NTLM_PASSWORD=tu_contraseña" -ForegroundColor White
}

# --- Paso 5: Verificar que la instalación quedó funcionando ---
Write-Host "[5/5] Verificando la instalación..." -ForegroundColor Yellow

# Importar las dependencias ahora evita descubrir un problema recién a mitad
# de una carga de notas.
& .venv\Scripts\python.exe -c "import requests, requests_ntlm, dotenv, openpyxl" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ERROR: las dependencias no se importan correctamente." -ForegroundColor Red
    Write-Host "  Probá borrar la carpeta .venv y ejecutar instalar.bat otra vez." -ForegroundColor Yellow
    Read-Host "Presioná Enter para cerrar"
    exit 1
}

& .venv\Scripts\python.exe notasparciales_upload.py --help > $null 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ERROR: el script no se puede ejecutar." -ForegroundColor Red
    Write-Host "  Verificá que notasparciales_upload.py esté en esta carpeta." -ForegroundColor Yellow
    Read-Host "Presioná Enter para cerrar"
    exit 1
}
Write-Host "  OK: todo funciona" -ForegroundColor Green

# --- Listo ---
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║              Instalación completada                     ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Próximos pasos:" -ForegroundColor White
Write-Host ""
Write-Host "  1. Abrí el archivo .env con el Bloc de notas y completá" -ForegroundColor Cyan
Write-Host "     tu usuario y contraseña de la UNED (los mismos del correo):" -ForegroundColor Cyan
Write-Host ""
Write-Host "        NP_NTLM_USER=tu_usuario        (sin @uned.ac.cr)" -ForegroundColor White
Write-Host "        NP_NTLM_PASSWORD=tu_contraseña" -ForegroundColor White
Write-Host ""
Write-Host "     Guardá el archivo y cerralo." -ForegroundColor Cyan
Write-Host ""
Write-Host "  2. Volvé a esta carpeta en la terminal y ejecutá:" -ForegroundColor Cyan
Write-Host ""
Write-Host "        .venv\Scripts\python.exe notasparciales_upload.py estado" -ForegroundColor White
Write-Host ""
Write-Host "     Ese comando te va a decir en qué paso estás y cuál es" -ForegroundColor Cyan
Write-Host "     el siguiente comando exacto que tenés que ejecutar." -ForegroundColor Cyan
Write-Host "     No se conecta a la UNED y no modifica ninguna nota." -ForegroundColor Gray
Write-Host ""
Write-Host "  Nota: usá siempre '.venv\Scripts\python.exe' (no 'python' solo)." -ForegroundColor Gray
Write-Host "  Así no hace falta activar el entorno virtual." -ForegroundColor Gray
Write-Host ""
Read-Host "Presioná Enter para cerrar"

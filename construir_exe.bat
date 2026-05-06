@echo off
title Grade Uploader - Construir .exe
echo.
echo ========================================
echo   Construir ejecutable (.exe)
echo   Grade Uploader - Notas Parciales UNED
echo ========================================
echo.

REM Verificar que existe el entorno virtual
if not exist ".venv\Scripts\activate.bat" (
    echo ERROR: No se encontro el entorno virtual .venv
    echo Ejecuta primero instalar.bat para crear el entorno.
    echo.
    pause
    exit /b 1
)

REM Activar entorno virtual
echo [1/3] Activando entorno virtual...
call .venv\Scripts\activate.bat

REM Instalar PyInstaller
echo [2/3] Instalando PyInstaller...
pip install -r requirements-exe.txt --quiet
if errorlevel 1 (
    echo ERROR: No se pudo instalar PyInstaller.
    pause
    exit /b 1
)

REM Construir el .exe
echo [3/3] Construyendo ejecutable...
pyinstaller --onefile --name notasparciales_upload notasparciales_upload.py
if errorlevel 1 (
    echo ERROR: La construccion del .exe fallo.
    pause
    exit /b 1
)

REM Copiar el .exe a la raiz
if exist "dist\notasparciales_upload.exe" (
    copy /y "dist\notasparciales_upload.exe" "notasparciales_upload.exe" >nul
    echo.
    echo ========================================
    echo   Ejecutable creado exitosamente!
    echo   Archivo: notasparciales_upload.exe
    echo ========================================
    echo.
    echo Para usarlo, necesitas:
    echo   1. notasparciales_upload.exe
    echo   2. .env (con tus credenciales)
    echo.
    echo Ambos archivos deben estar en la misma carpeta.
    echo.
) else (
    echo ERROR: No se encontro el archivo .exe generado.
)

pause

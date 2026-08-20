@echo off
REM Este archivo se mantiene en ASCII puro a proposito: los .bat se leen con la
REM codepage de la consola (cp850/cp437) y los acentos saldrian mal. El texto
REM con acentos vive en instalar.ps1, que si se lee como UTF-8.
title Grade Uploader - Instalacion
echo.
echo Iniciando instalacion de Grade Uploader...
echo.

REM %~dp0 = carpeta de este .bat. Nos movemos ahi para que la instalacion no
REM dependa del directorio desde el que se ejecuto (por ejemplo, si se usa
REM "Ejecutar como administrador", Windows arranca en C:\Windows\System32).
cd /d "%~dp0"

where powershell >nul 2>nul
if errorlevel 1 (
    echo ERROR: No se encontro PowerShell en este equipo.
    echo Grade Uploader necesita PowerShell, que viene incluido en
    echo Windows 10 y Windows 11.
    echo.
    pause
    exit /b 1
)

if not exist "%~dp0instalar.ps1" (
    echo ERROR: No se encontro instalar.ps1 junto a este archivo.
    echo Asegurate de haber descargado el proyecto completo y no
    echo solamente el archivo instalar.bat.
    echo.
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0instalar.ps1"

REM Si PowerShell termino con error y no alcanzo a mostrar su propio mensaje,
REM al menos dejamos la ventana abierta para que se pueda leer.
if errorlevel 1 (
    echo.
    echo La instalacion termino con errores. Revisa los mensajes de arriba.
    echo.
    pause
)

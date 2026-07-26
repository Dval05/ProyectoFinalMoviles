# Script para iniciar el servidor de Appium con todas las variables de entorno inyectadas
# Esto evita el error de "Neither ANDROID_HOME nor ANDROID_SDK_ROOT" o fallos con Java.

$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$env:ANDROID_SDK_ROOT = "$env:LOCALAPPDATA\Android\Sdk"

# Buscamos la carpeta de Java automáticamente o usamos una predeterminada si existe
if (Test-Path "C:\Program Files\Eclipse Adoptium\jdk-25.0.3.9-hotspot") {
    $env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-25.0.3.9-hotspot"
}

Write-Host "Iniciando servidor Appium con variables de entorno inyectadas para la presentacion..." -ForegroundColor Yellow
Write-Host "ANDROID_HOME: $env:ANDROID_HOME" -ForegroundColor Cyan

# Ejecutar appium
appium

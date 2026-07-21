const { remote } = require('webdriverio');

const capabilities = {
    platformName: 'Android',
    'appium:automationName': 'Flutter',
    // IMPORTANTE: Asegúrate de que el emulador esté corriendo y obtén su nombre con `adb devices`
    // 'appium:deviceName': 'emulator-5554',
    // La ruta de tu app compilada:
    // 'appium:app': '../build/app/outputs/flutter-apk/app-debug.apk',
    // Alternativamente, si ya está instalada, puedes usar el appPackage y appActivity
    'appium:appPackage': 'com.hostsigchos.frontend',
    'appium:appActivity': 'com.hostsigchos.frontend.MainActivity',
    'appium:noReset': true
};

const wdOpts = {
    hostname: process.env.APPIUM_HOST || '127.0.0.1',
    port: Number.parseInt(process.env.APPIUM_PORT, 10) || 4723,
    logLevel: 'info',
    capabilities,
};

async function runTest() {
    console.log("Conectando al servidor Appium...");
    const driver = await remote(wdOpts);

    try {
        console.log("Aplicación iniciada. Esperando unos segundos para que cargue...");
        await driver.pause(5000);

        // Ejemplo: Cambiar el contexto a FLUTTER para usar comandos específicos del driver de Flutter
        await driver.switchContext('FLUTTER');

        // Aquí puedes realizar validaciones usando selectores de flutter.
        // Ejemplo: buscar un texto
        // const byText = `//flutter-text[@text="Iniciar Sesión"]`;
        // await driver.execute('flutter:waitFor', byText);

        console.log("Prueba básica finalizada con éxito.");
    } catch (e) {
        console.error("Error durante la prueba:", e);
    } finally {
        await driver.deleteSession();
        console.log("Sesión finalizada.");
    }
}

runTest();

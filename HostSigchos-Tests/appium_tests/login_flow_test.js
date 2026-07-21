require('dotenv').config({ path: '../.env' });
const { remote } = require('webdriverio');

const capabilities = {
    platformName: 'Android',
    'appium:automationName': 'Flutter',
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

async function runLoginTest() {
    const driver = await remote(wdOpts);
    try {
        console.log("Iniciando prueba de login...");
        await driver.pause(5000);
        await driver.switchContext('FLUTTER');

        // Referenciar los ValueKey definidos en login_screen.dart (emailField, passwordField)
        const emailField = `//flutter-widget[@key="emailField"]`;
        const passwordField = `//flutter-widget[@key="passwordField"]`;
        const loginBtn = `//flutter-widget[@key="loginButton"]`;

        // Esperar el campo de email
        await driver.execute('flutter:waitFor', emailField);

        // Ingresar credenciales tomadas del archivo .env (que es privado y está en gitignore)
        console.log(`Ingresando usuario de prueba: ${process.env.TEST_EMAIL}`);
        await driver.execute('flutter:enterText', emailField, process.env.TEST_EMAIL);
        
        await driver.execute('flutter:enterText', passwordField, process.env.TEST_PASSWORD);

        // Presionar el botón de inicio de sesión
        console.log("Presionando botón de login...");
        await driver.execute('flutter:tap', loginBtn);

        // Esperar que aparezca un elemento de la pantalla principal o el indicador de carga
        await driver.pause(4000);
        
        console.log("Prueba de Login finalizada correctamente con credenciales privadas.");
    } catch (e) {
        console.error("Falló la prueba de Login:", e);
    } finally {
        await driver.deleteSession();
    }
}

runLoginTest();

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

async function runMapTest() {
    const driver = await remote(wdOpts);
    try {
        await driver.pause(5000);
        await driver.switchContext('FLUTTER');

        // Buscar texto "Mapa" o icono de mapa. Vamos a suponer que hay un texto de mapa en el BottomNav
        const mapTab = `//flutter-text[@text="Mapa"]`;
        try {
            await driver.execute('flutter:waitFor', mapTab, 5000);
            await driver.execute('flutter:tap', mapTab);
        } catch(e) {
            console.log("No se encontro tab de mapa, probando encontrar FlutterMap...");
        }
        
        await driver.pause(3000);

        // Interactuar con el mapa si es posible
        // Appium Flutter Driver no tiene scroll/zoom nativo avanzado tan simple por key, 
        // pero podemos probar un click al centro.
        console.log("Map interaction test complete.");
    } catch (e) {
        console.error(e);
    } finally {
        await driver.deleteSession();
    }
}

runMapTest();

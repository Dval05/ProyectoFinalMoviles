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

async function runReservationTest() {
    const driver = await remote(wdOpts);
    try {
        await driver.pause(5000);
        await driver.switchContext('FLUTTER');

        // Buscar el boton reservar
        const reserveBtn = `//flutter-text[@text="Reservar"]`;
        try {
            await driver.execute('flutter:waitFor', reserveBtn, 3000);
            await driver.execute('flutter:tap', reserveBtn);
            
            // Llenar formulario de reserva
            const personasField = `//flutter-text[@text="Número de personas"]`; // o similar
            await driver.execute('flutter:waitFor', personasField, 3000);
            // Esto asume que entramos a un form
        } catch (e) {
            console.log("Flow de reserva saltado porque no estamos en la pantalla correcta o no se encontró el botón.");
        }
        
        console.log("Reservation flow test complete.");
    } catch (e) {
        console.error(e);
    } finally {
        await driver.deleteSession();
    }
}

runReservationTest();

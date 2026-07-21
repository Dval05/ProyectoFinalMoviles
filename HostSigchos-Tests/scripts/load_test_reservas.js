import http from 'k6/http';
import { check, sleep } from 'k6';

// Ejecutar con: k6 run scripts/load_test_reservas.js
export const options = {
  // Simular 50 usuarios virtuales que intentan reservar simultáneamente
  vus: 50,
  duration: '10s',
};

// Reemplazar con el endpoint REST real de tu Firestore (requiere un token JWT de prueba si tienes auth)
// Para pruebas de Race Condition sin auth, podrías temporalmente permitir write: true en una DB de pruebas
const PROJECT_ID = 'hostsigchos';
const URL = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/reservas`;

export default function () {
  const payload = JSON.stringify({
    fields: {
      usuarioId: { stringValue: `user_${__VU}` }, // __VU es el ID del Virtual User
      habitacionId: { stringValue: 'habitacion_prueba_01' },
      fechaCheckIn: { timestampValue: '2027-10-15T14:00:00Z' },
      fechaCheckOut: { timestampValue: '2027-10-18T12:00:00Z' },
      estado: { stringValue: 'pendiente' },
      // ... otros campos
    }
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
      // 'Authorization': 'Bearer TU_JWT_AQUI'
    },
  };

  const res = http.post(URL, payload, params);

  // Verificamos cuántas reservas pasan y cuántas rebotan (debido a colisión o error de reglas)
  check(res, {
    'Reserva creada con éxito (HTTP 200)': (r) => r.status === 200,
    'Reserva bloqueada por colisión (HTTP 4xx/5xx)': (r) => r.status !== 200,
  });

  sleep(1);
}

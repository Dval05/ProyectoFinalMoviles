import { initializeApp } from "firebase/app";
import { getAuth, createUserWithEmailAndPassword } from "firebase/auth";
import { getFirestore, doc, setDoc, serverTimestamp } from "firebase/firestore";
import dotenv from "dotenv";
import fs from "fs";

dotenv.config();

const firebaseConfig = {
  apiKey: process.env.VITE_FIREBASE_API_KEY,
  authDomain: process.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: process.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.VITE_FIREBASE_APP_ID
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app, "hostsigchos");

const hosterias = [
  { id: "el_trapiche", email: "el_trapiche@hostsigchos.com", nombre: "El Trapiche" },
  { id: "hostal_chugchilan", email: "hostal_chugchilan@hostsigchos.com", nombre: "Hostal Chugchilan" },
  { id: "hostal_cloud_forest", email: "hostal_cloud_forest@hostsigchos.com", nombre: "Hostal Cloud Forest" },
  { id: "hostal_dinos", email: "hostal_dinos@hostsigchos.com", nombre: "Hostal Dinos" },
  { id: "hostal_el_castillo", email: "hostal_el_castillo@hostsigchos.com", nombre: "Hostal El Castillo" },
  { id: "hostal_el_vaquero", email: "hostal_el_vaquero@hostsigchos.com", nombre: "Hostal El Vaquero" },
  { id: "hostal_jardin_de_los_andes", email: "hostal_jardin_de_los_andes@hostsigchos.com", nombre: "Hostal Jardin De Los Andes" },
  { id: "hostal_mirador_oro_verde", email: "hostal_mirador_oro_verde@hostsigchos.com", nombre: "Hostal Mirador Oro Verde" },
  { id: "hostal_rosita", email: "hostal_rosita@hostsigchos.com", nombre: "Hostal Rosita" },
  { id: "hosteria_san_jose_de_sigchos", email: "hosteria_san_jose_de_sigchos@hostsigchos.com", nombre: "Hosteria San Jose De Sigchos" },
  { id: "hotel_lagoon", email: "hotel_lagoon@hostsigchos.com", nombre: "Hotel Lagoon" },
  { id: "inti_amanta_lodge", email: "inti_amanta_lodge@hostsigchos.com", nombre: "Inti Amanta Lodge" },
  { id: "llullu_llama_mountain_lodge", email: "llullu_llama_mountain_lodge@hostsigchos.com", nombre: "Llullu Llama Mountain Lodge" },
  { id: "sigchos_lodge", email: "sigchos_lodge@hostsigchos.com", nombre: "Sigchos Lodge" },
  { id: "starlight_mountain_lodge_sigchos", email: "starlight_mountain_lodge_sigchos@hostsigchos.com", nombre: "Starlight Mountain Lodge Sigchos" },
  { id: "the_black_sheep_inn", email: "the_black_sheep_inn@hostsigchos.com", nombre: "The Black Sheep Inn" },
  { id: "urku_nan_quilotoa", email: "urku_nan_quilotoa@hostsigchos.com", nombre: "Urku Nan Quilotoa" }
];

async function seed() {
  console.log("Iniciando sembrado usando users.json local...");
  
  // Read exported users
  const usersData = JSON.parse(fs.readFileSync('users.json', 'utf8'));
  const exportedUsers = usersData.users || [];
  
  for (const hosteria of hosterias) {
    let uid = null;
    
    // Find if user is in exported users
    const existingUser = exportedUsers.find(u => u.email === hosteria.email);
    
    if (existingUser) {
      console.log(`⚠️ Usuario encontrado en Auth: ${hosteria.email} (UID: ${existingUser.localId})`);
      uid = existingUser.localId;
    } else {
      try {
        console.log(`👤 Creando usuario nuevo en Auth: ${hosteria.email}`);
        const userCredential = await createUserWithEmailAndPassword(auth, hosteria.email, "Sigchos2026");
        uid = userCredential.user.uid;
      } catch (error) {
        console.error(`❌ Error creando ${hosteria.nombre} en Auth:`, error.message);
        continue;
      }
    }

    if (uid) {
      try {
        // 2. Create document in 'propietarios' collection
        await setDoc(doc(db, "propietarios", uid), {
          email: hosteria.email,
          nombre: hosteria.nombre,
          fechaRegistro: serverTimestamp(),
          idioma: "es",
          fotoUrl: null,
          telefono: null,
          ubicacion: null
        });
        console.log(`✅ Creado doc en propietarios para: ${hosteria.nombre}`);
      } catch (error) {
         console.error(`❌ Error escribiendo Firestore para ${hosteria.nombre}:`, error.message);
      }
    }
  }
  console.log("Proceso terminado. Presiona Ctrl+C para salir.");
  process.exit(0);
}

seed();

import { initializeApp } from "firebase/app";
import { getFirestore, collection, getDocs } from "firebase/firestore";
import dotenv from "dotenv";

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
const db = getFirestore(app, "hostsigchos");

async function check() {
  try {
    const querySnapshot = await getDocs(collection(db, "propietarios"));
    console.log(`Found ${querySnapshot.size} documentos en 'propietarios'`);
    querySnapshot.forEach((doc) => {
      console.log(doc.id, "=>", doc.data().nombre);
    });
  } catch (error) {
    console.error("Error reading:", error);
  }
  process.exit(0);
}

check();

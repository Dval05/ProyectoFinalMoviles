import React, { createContext, useState, useEffect, useContext, useMemo } from 'react';
import PropTypes from 'prop-types';
import { auth, db } from '../config/firebase';
import { 
  onAuthStateChanged, 
  signInWithEmailAndPassword, 
  signOut 
} from 'firebase/auth';
import { 
  doc, 
  getDoc, 
  collection, 
  query, 
  where, 
  getDocs, 
  onSnapshot, 
  updateDoc, 
  addDoc,
  deleteDoc,
  deleteField
} from 'firebase/firestore';

export const AppContext = createContext();

export const useAppContext = () => useContext(AppContext);

export const AppProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [role, setRole] = useState(null); // 'propietario' | 'admin'
  const [isSuperAdmin, setIsSuperAdmin] = useState(false);
  const [hosteria, setHosteria] = useState(null);
  const [loadingAuth, setLoadingAuth] = useState(true);
  
  const [rooms, setRooms] = useState([]);
  const [reservations, setReservations] = useState([]);
  const [promotions, setPromotions] = useState([]);

  // Admin states
  const [allHosterias, setAllHosterias] = useState([]);
  const [allReservations, setAllReservations] = useState([]);
  const [allUsers, setAllUsers] = useState([]);
  const [allRooms, setAllRooms] = useState([]);

  // Auth Functions
  const login = async (email, password) => {
    try {
      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      // Check role
      if (email === 'andrade.dval@gmail.com') {
        return { success: true, role: 'admin' };
      }
      
      const adminDocRef = doc(db, 'administradores', email);
      const adminDocSnap = await getDoc(adminDocRef);
      if (adminDocSnap.exists()) {
        return { success: true, role: 'admin' };
      }

      const userDocRef = doc(db, 'propietarios', userCredential.user.uid);
      const userDocSnap = await getDoc(userDocRef);
      if (userDocSnap.exists()) {
        return { success: true, role: 'propietario' };
      }
      
      await signOut(auth);
      return { success: false, error: 'Acceso denegado: No estás registrado como propietario ni administrador.' };
    } catch (error) {
      console.error("Login error:", error);
      return { success: false, error: 'Credenciales incorrectas o error de red.' };
    }
  };

  const logout = async () => {
    await signOut(auth);
    setUser(null);
    setRole(null);
    setIsSuperAdmin(false);
    setHosteria(null);
    setRooms([]);
    setReservations([]);
    setPromotions([]);
    setAllHosterias([]);
    setAllReservations([]);
    setAllUsers([]);
    setAllRooms([]);
  };

  const handleAuthStateChanged = async (firebaseUser) => {
    if (!firebaseUser) {
      setUser(null);
      setRole(null);
      setIsSuperAdmin(false);
      setHosteria(null);
      setLoadingAuth(false);
      return;
    }

    try {
      let currentRole = 'propietario';
      let currentSuper = false;

      if (firebaseUser.email === 'andrade.dval@gmail.com') {
        currentRole = 'admin';
        currentSuper = true;
      } else {
        const adminDocRef = doc(db, 'administradores', firebaseUser.email);
        const adminDocSnap = await getDoc(adminDocRef);
        if (adminDocSnap.exists()) {
          currentRole = 'admin';
        }
      }

      setRole(currentRole);
      setIsSuperAdmin(currentSuper);

      if (currentRole === 'admin') {
        setUser({ uid: firebaseUser.uid, email: firebaseUser.email });
      } else {
        // Logica para propietario
        const userDocRef = doc(db, 'propietarios', firebaseUser.uid);
        const userDocSnap = await getDoc(userDocRef);
        
        if (!userDocSnap.exists()) {
          await signOut(auth);
          setLoadingAuth(false);
          return;
        }
        
        const userData = userDocSnap.data();
        setUser({ uid: firebaseUser.uid, ...userData });
        
        // Find the hosteria by owner's name
        const hosteriasRef = collection(db, 'hosterias');
        const q = query(hosteriasRef, where('nombre', '==', userData.nombre));
        const querySnapshot = await getDocs(q);
        
        if (querySnapshot.empty) {
          console.warn("No hosteria found for this owner name:", userData.nombre);
        } else {
          const hosteriaData = querySnapshot.docs[0].data();
          setHosteria({ id: querySnapshot.docs[0].id, ...hosteriaData });
        }
      }
    } catch (error) {
      console.error("Error fetching user data:", error);
    }
    
    setLoadingAuth(false);
  };

  // Listen to Auth State
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, handleAuthStateChanged);
    return () => unsubscribe();
  }, []);

  // Listen to Firestore Data once hosteria is loaded
  useEffect(() => {
    if (!hosteria) return;

    // Listen Rooms (Habitaciones)
    const roomsRef = collection(db, 'habitaciones');
    const qRooms = query(roomsRef, where('hosteriaId', '==', hosteria.id));
    const unsubRooms = onSnapshot(qRooms, (snapshot) => {
      const roomsData = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      setRooms(roomsData);
    });

    // Listen Reservations (Reservas)
    const resRef = collection(db, 'reservas');
    const qRes = query(resRef, where('hosteriaId', '==', hosteria.id));
    const unsubRes = onSnapshot(qRes, async (snapshot) => {
      // 1. Mostrar información base INMEDIATAMENTE para que los números carguen rápido
      const basicResData = snapshot.docs.map(docSnapshot => {
        const data = docSnapshot.data();
        let clientName = data.esParaOtraPersona && data.nombreOtraPersona 
          ? data.nombreOtraPersona 
          : 'Usuario Registrado';
        return {
          id: docSnapshot.id,
          ...data,
          resolvedClientName: clientName
        };
      });
      
      setReservations(basicResData);

      // 2. Cargar los nombres reales usando caché para evitar muchas peticiones
      const userCache = {};
      const fullResDataPromises = basicResData.map(async (resItem) => {
        if (!resItem.esParaOtraPersona && resItem.usuarioId) {
          if (userCache[resItem.usuarioId]) {
            return { ...resItem, resolvedClientName: userCache[resItem.usuarioId] };
          }
          try {
            const userDocRef = doc(db, 'usuarios', resItem.usuarioId);
            const userDocSnap = await getDoc(userDocRef);
            if (userDocSnap.exists()) {
              const userData = userDocSnap.data();
              const name = userData.nombre || userData.name || userData.displayName || 'Usuario Registrado';
              userCache[resItem.usuarioId] = name;
              return { ...resItem, resolvedClientName: name };
            }
          } catch (e) {
            console.error("Error fetching user name:", e);
          }
        }
        return resItem;
      });
      
      const fullResData = await Promise.all(fullResDataPromises);
      setReservations(fullResData);
    });

    // Listen Promotions
    const promoRef = collection(db, 'promociones');
    const qPromo = query(promoRef, where('hosteriaId', '==', hosteria.id));
    const unsubPromo = onSnapshot(qPromo, (snapshot) => {
      const promoData = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      setPromotions(promoData);
    });

    return () => {
      unsubRooms();
      unsubRes();
      unsubPromo();
    };
  }, [hosteria]);

  // Admin: Listen to global data if role is admin
  useEffect(() => {
    if (role !== 'admin') return;

    // Listen to all Hosterias
    const hosteriasRef = collection(db, 'hosterias');
    const unsubHost = onSnapshot(hosteriasRef, (snapshot) => {
      setAllHosterias(snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })));
    });

    // Listen to all Reservations
    const resRef = collection(db, 'reservas');
    const unsubRes = onSnapshot(resRef, (snapshot) => {
      setAllReservations(snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })));
    });

    // Listen to all Users
    const usersRef = collection(db, 'usuarios');
    const unsubUsers = onSnapshot(usersRef, (snapshot) => {
      setAllUsers(snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })));
    });

    // Listen to all Rooms
    const allRoomsRef = collection(db, 'habitaciones');
    const unsubAllRooms = onSnapshot(allRoomsRef, (snapshot) => {
      setAllRooms(snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })));
    });

    return () => {
      unsubHost();
      unsubRes();
      unsubUsers();
      unsubAllRooms();
    };
  }, [role]);

  // Rooms Functions
  const toggleRoomStatus = async (roomId, isAvailable, closedUntil = null) => {
    try {
      const roomRef = doc(db, 'habitaciones', roomId);
      await updateDoc(roomRef, { 
        disponible: isAvailable,
        closedUntil: closedUntil 
      });
      console.log(`Room ${roomId} updated to disponible: ${isAvailable}`);
    } catch (error) {
      console.error("Error updating room status: ", error);
    }
  };

  const editRoom = async (roomId, roomData) => {
    try {
      const roomRef = doc(db, 'habitaciones', roomId);
      await updateDoc(roomRef, roomData);
      console.log(`Room ${roomId} updated successfully.`);
    } catch (error) {
      console.error("Error editing room: ", error);
    }
  };

  // Reservations Functions
  const updateReservationStatus = async (reservationId, newStatus) => {
    const resRef = doc(db, 'reservas', reservationId);
    await updateDoc(resRef, { estado: newStatus });
  };

  // Promotions Functions
  const addPromotion = async (promo) => {
    if (!hosteria) return;
    
    // 1. Create the promotion document
    const promoRef = collection(db, 'promociones');
    await addDoc(promoRef, {
      ...promo,
      hosteriaId: hosteria.id,
      createdAt: new Date().toISOString()
    });
    
    // 2. Apply discount directly to selected rooms so the mobile app sees the new price
    if (promo.habitacionesAplicables && promo.habitacionesAplicables.length > 0) {
      for (const roomId of promo.habitacionesAplicables) {
        const roomRef = doc(db, 'habitaciones', roomId);
        const roomSnap = await getDoc(roomRef);
        if (roomSnap.exists()) {
          const roomData = roomSnap.data();
          const originalPrice = roomData.precioOriginal || roomData.precioPorNoche;
          const discountAmount = originalPrice * (promo.discount / 100);
          const newPrice = originalPrice - discountAmount;
          
          await updateDoc(roomRef, {
            precioOriginal: originalPrice,
            precioPorNoche: newPrice
          });
        }
      }
    }
  };

  const restoreRoomPrice = async (roomId) => {
    const roomRef = doc(db, 'habitaciones', roomId);
    const roomSnap = await getDoc(roomRef);
    if (!roomSnap.exists()) return;
    
    const roomData = roomSnap.data();
    if (roomData.precioOriginal) {
      await updateDoc(roomRef, {
        precioPorNoche: roomData.precioOriginal,
        precioOriginal: deleteField()
      });
    }
  };

  const deletePromotion = async (promoId) => {
    const promoRef = doc(db, 'promociones', promoId);
    
    // 1. Restore the original price to the affected rooms before deleting
    const promoSnap = await getDoc(promoRef);
    if (promoSnap.exists()) {
      const promoData = promoSnap.data();
      const roomsToRestore = promoData.habitacionesAplicables || [];
      await Promise.all(roomsToRestore.map(restoreRoomPrice));
    }
    
    // 2. Delete the promotion document
    await deleteDoc(promoRef);
  };

  // Settings Functions
  const updateHosteriaSettings = async (newData) => {
    if (!hosteria) return;
    try {
      const hosteriaRef = doc(db, 'hosterias', hosteria.id);
      await updateDoc(hosteriaRef, newData);
      console.log('Hosteria settings updated successfully');
    } catch (error) {
      console.error('Error updating hosteria settings: ', error);
      throw error;
    }
  };

  const contextValue = useMemo(() => ({
    user,
    role,
    isSuperAdmin,
    hosteria,
    loadingAuth,
    login,
    logout,
    rooms,
    toggleRoomStatus,
    editRoom,
    reservations,
    updateReservationStatus,
    promotions,
    addPromotion,
    deletePromotion,
    updateHosteriaSettings,
    allHosterias,
    allReservations,
    allUsers,
    allRooms,
  }), [user, role, isSuperAdmin, hosteria, loadingAuth, rooms, reservations, promotions, allHosterias, allReservations, allUsers, allRooms]);

  return (
    <AppContext.Provider value={contextValue}>
      {!loadingAuth && children}
    </AppContext.Provider>
  );
};

AppProvider.propTypes = {
  children: PropTypes.node.isRequired,
};

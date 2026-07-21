import React, { useState, useEffect } from 'react';
import { ShieldAlert, Plus, Trash2 } from 'lucide-react';
import { db } from '../config/firebase';
import { collection, getDocs, doc, setDoc, deleteDoc } from 'firebase/firestore';
import { useAppContext } from '../context/AppContext';

const ManageAdmins = () => {
  const { isSuperAdmin } = useAppContext();
  const [admins, setAdmins] = useState([]);
  const [newEmail, setNewEmail] = useState('');
  const [loading, setLoading] = useState(true);

  const fetchAdmins = async () => {
    setLoading(true);
    try {
      const querySnapshot = await getDocs(collection(db, 'administradores'));
      const adminList = querySnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      setAdmins(adminList);
    } catch (error) {
      console.error("Error fetching admins:", error);
    }
    setLoading(false);
  };

  useEffect(() => {
    if (isSuperAdmin) {
      fetchAdmins();
    }
  }, [isSuperAdmin]);

  const handleAddAdmin = async (e) => {
    e.preventDefault();
    if (!newEmail?.includes('@')) return;

    try {
      const email = newEmail.toLowerCase();
      
      // Registrar el usuario en la colección administradores
      const adminRef = doc(db, 'administradores', email);
      await setDoc(adminRef, {
        addedAt: new Date().toISOString(),
        role: 'admin'
      });
      
      setNewEmail('');
      fetchAdmins();
    } catch (error) {
      console.error("Error adding admin:", error);
      alert('Error al agregar el administrador.');
    }
  };

  const handleRemoveAdmin = async (emailId) => {
    if (globalThis.confirm(`¿Estás seguro de eliminar a ${emailId} como administrador?`)) {
      try {
        await deleteDoc(doc(db, 'administradores', emailId));
        fetchAdmins();
      } catch (error) {
        console.error("Error removing admin:", error);
        alert('Error al eliminar el administrador.');
      }
    }
  };

  if (!isSuperAdmin) {
    return (
      <div style={{ padding: '40px', textAlign: 'center', color: '#e74c3c' }}>
        <ShieldAlert size={48} style={{ margin: '0 auto 16px auto' }} />
        <h2>Acceso Denegado</h2>
        <p>Solo el Super Administrador puede gestionar a otros administradores.</p>
      </div>
    );
  }

  return (
    <div className="animate-fade-in">
      <header className="dashboard-topbar">
        <div>
          <h1 className="page-title">Gestión de Administradores</h1>
          <p className="page-subtitle">Otorga o revoca permisos de administrador a otros usuarios (Exclusivo Super Admin).</p>
        </div>
      </header>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 2fr', gap: '24px', marginTop: '24px', alignItems: 'start' }}>
        {/* Add Form */}
        <div className="card" style={{ padding: '24px' }}>
          <h3 style={{ marginTop: 0, marginBottom: '20px', borderBottom: '1px solid #eaeaea', paddingBottom: '12px' }}>
            Agregar Nuevo
          </h3>
          <form onSubmit={handleAddAdmin} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            <div className="input-group">
              <label htmlFor="admin-email" className="input-label">Correo Electrónico</label>
              <input 
                id="admin-email"
                type="email" 
                className="input-field" 
                value={newEmail}
                onChange={(e) => setNewEmail(e.target.value)}
                placeholder="ejemplo@correo.com"
                required
              />
            </div>
            <button type="submit" className="btn btn-primary" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px' }}>
              <Plus size={18} /> Agregar Admin
            </button>
            <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '8px' }}>
              Al agregar el correo, ese usuario obtendrá privilegios de Administrador y podrá iniciar sesión en este panel usando su misma contraseña.
            </p>
          </form>
        </div>

        {/* List */}
        <div className="card table-card">
          <h3 style={{ padding: '20px 20px 0 20px', margin: 0, fontSize: '1.2rem' }}>Administradores Actuales</h3>
          <table className="data-table">
            <thead>
              <tr>
                <th>Correo Electrónico</th>
                <th>Fecha de Asignación</th>
                <th style={{ textAlign: 'right' }}>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {/* Hardcoded Super Admin row */}
              <tr>
                <td style={{ fontWeight: 'bold' }}>
                  andrade.dval@gmail.com{' '}
                  <span style={{ marginLeft: '8px', backgroundColor: '#e74c3c', color: 'white', padding: '2px 8px', borderRadius: '12px', fontSize: '0.75rem' }}>
                    Super Admin
                  </span>
                </td>
                <td>Sistema</td>
                <td style={{ textAlign: 'right', color: 'var(--text-secondary)' }}>-</td>
              </tr>
              
              {loading && (
                <tr><td colSpan="3" style={{ textAlign: 'center', padding: '20px' }}>Cargando...</td></tr>
              )}
              {!loading && admins.length > 0 && (
                admins.map(admin => (
                  <tr key={admin.id}>
                    <td style={{ fontWeight: '500' }}>{admin.id}</td>
                    <td>{new Date(admin.addedAt).toLocaleDateString()}</td>
                    <td style={{ textAlign: 'right' }}>
                      <button 
                        onClick={() => handleRemoveAdmin(admin.id)}
                        style={{ background: 'none', border: 'none', color: '#e74c3c', cursor: 'pointer', padding: '4px' }}
                        title="Revocar acceso"
                      >
                        <Trash2 size={18} />
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default ManageAdmins;

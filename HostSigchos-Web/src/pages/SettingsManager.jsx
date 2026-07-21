import React, { useState, useEffect } from 'react';
import { Settings, Save, Home, MapPin, Phone, Globe, FileText } from 'lucide-react';
import { useAppContext } from '../context/AppContext';

const SettingsManager = () => {
  const { hosteria, updateHosteriaSettings } = useAppContext();
  const [isSaving, setIsSaving] = useState(false);
  const [successMsg, setSuccessMsg] = useState('');
  const [errorMsg, setErrorMsg] = useState('');
  
  const [formData, setFormData] = useState({
    nombre: '',
    descripcion: '',
    direccion: '',
    telefono: '',
    sitioWeb: ''
  });

  useEffect(() => {
    if (hosteria) {
      setFormData({
        nombre: hosteria.nombre || '',
        descripcion: hosteria.descripcion || '',
        direccion: hosteria.direccion || '',
        telefono: hosteria.telefono || '',
        sitioWeb: hosteria.sitioWeb || ''
      });
    }
  }, [hosteria]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsSaving(true);
    setSuccessMsg('');
    setErrorMsg('');
    
    try {
      await updateHosteriaSettings(formData);
      setSuccessMsg('¡Configuración guardada exitosamente!');
      setTimeout(() => setSuccessMsg(''), 3000);
    } catch (err) {
      console.error(err);
      setErrorMsg('Error al guardar la configuración. Por favor, inténtalo de nuevo.');
    } finally {
      setIsSaving(false);
    }
  };

  if (!hosteria) return <div style={{ padding: '40px', textAlign: 'center' }}>Cargando configuración...</div>;

  return (
    <div className="animate-fade-in">
      <header className="dashboard-topbar">
        <div>
          <h1 className="page-title">Configuración de Hostería</h1>
          <p className="page-subtitle">Actualiza la información pública de tu establecimiento.</p>
        </div>
      </header>

      <div className="card" style={{ maxWidth: '800px', margin: '24px auto', padding: '32px' }}>
        <h2 style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '24px', fontSize: '1.4rem', borderBottom: '1px solid #eaeaea', paddingBottom: '16px' }}>
          <Settings className="text-primary" size={24} /> 
          Información General
        </h2>
        
        {successMsg && (
          <div style={{ padding: '12px 16px', backgroundColor: 'rgba(46, 204, 113, 0.1)', color: 'var(--green-dark)', borderRadius: '8px', marginBottom: '24px', fontWeight: '500' }}>
            {successMsg}
          </div>
        )}
        
        {errorMsg && (
          <div style={{ padding: '12px 16px', backgroundColor: 'rgba(231, 76, 60, 0.1)', color: '#c0392b', borderRadius: '8px', marginBottom: '24px', fontWeight: '500' }}>
            {errorMsg}
          </div>
        )}

        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          
          <div className="input-group">
            <label htmlFor="set-nombre" className="input-label" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <Home size={16} /> Nombre de la Hostería
            </label>
            <input 
              id="set-nombre"
              type="text" 
              name="nombre"
              className="input-field" 
              value={formData.nombre} 
              onChange={handleChange}
              required 
            />
          </div>

          <div className="input-group">
            <label htmlFor="set-desc" className="input-label" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <FileText size={16} /> Descripción
            </label>
            <textarea 
              id="set-desc"
              name="descripcion"
              className="input-field" 
              rows="4"
              value={formData.descripcion} 
              onChange={handleChange}
              required 
            />
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '20px' }}>
            <div className="input-group">
              <label htmlFor="set-dir" className="input-label" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                <MapPin size={16} /> Dirección
              </label>
              <input 
                id="set-dir"
                type="text" 
                name="direccion"
                className="input-field" 
                value={formData.direccion} 
                onChange={handleChange}
                required 
              />
            </div>

            <div className="input-group">
              <label htmlFor="set-tel" className="input-label" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                <Phone size={16} /> Teléfono
              </label>
              <input 
                id="set-tel"
                type="text" 
                name="telefono"
                className="input-field" 
                value={formData.telefono} 
                onChange={handleChange}
              />
            </div>
          </div>

          <div className="input-group">
            <label htmlFor="set-web" className="input-label" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <Globe size={16} /> Sitio Web (Opcional)
            </label>
            <input 
              id="set-web"
              type="url" 
              name="sitioWeb"
              className="input-field" 
              value={formData.sitioWeb} 
              onChange={handleChange}
              placeholder="https://www.mi-hosteria.com"
            />
          </div>

          <div style={{ marginTop: '16px', display: 'flex', justifyContent: 'flex-end' }}>
            <button 
              type="submit" 
              className="btn btn-primary" 
              style={{ display: 'flex', alignItems: 'center', gap: '8px', padding: '10px 24px', fontSize: '1rem' }}
              disabled={isSaving}
            >
              <Save size={18} />
              {isSaving ? 'Guardando...' : 'Guardar Cambios'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default SettingsManager;

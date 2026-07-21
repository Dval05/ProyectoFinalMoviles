import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { Search, Grid, List, MapPin, Star, Building } from 'lucide-react';
import { db } from '../config/firebase';
import { collection, getDocs } from 'firebase/firestore';
import './LandingPage.css';

const LandingPage = () => {
  const [hosterias, setHosterias] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchHosterias = async () => {
      try {
        const snapshot = await getDocs(collection(db, 'hosterias'));
        const hosteriasData = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        setHosterias(hosteriasData);
      } catch (error) {
        console.error("Error fetching hosterias:", error);
      }
      setLoading(false);
    };

    fetchHosterias();
  }, []);
  return (
    <div className="landing-page animate-fade-in">
      {/* Hero Section */}
      <header className="hero">
        <div className="hero-overlay"></div>
        <nav className="navbar container">
          <div className="logo">
            <h2>HostSigchos</h2>
          </div>
          <div className="nav-actions">
            <Link to="/login" className="btn btn-glass">
              Ingresar
            </Link>
          </div>
        </nav>
        
        <div className="hero-content container">
          <h1 className="hero-title">Descubre HostSigchos</h1>
          <p className="hero-subtitle">
            Encuentra el lugar perfecto para tu próxima aventura en la naturaleza.
          </p>
        </div>
      </header>

      {/* Search Section */}
      <section className="search-section container">
        <div className="search-bar glass-panel">
          <div className="search-input-wrapper">
            <Search className="search-icon" size={20} />
            <input 
              type="text" 
              placeholder="Buscar por nombre, ubicación..." 
              className="search-input"
            />
          </div>
          <div className="view-toggles">
            <button className="icon-btn active"><Grid size={20} /></button>
            <button className="icon-btn"><List size={20} /></button>
          </div>
        </div>
      </section>

      <section className="hosterias-section container">
        <h3 className="section-title">Hosterías Destacadas</h3>
        
        {loading && (
          <div style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>
            Cargando hosterías...
          </div>
        )}
        
        {!loading && hosterias.length > 0 && (
          <div className="hosterias-grid">
            {hosterias.map(h => (
              <div className="card hosteria-card" key={h.id}>
                <div className="card-image-wrapper" style={{ height: '200px', backgroundColor: '#f0f0f0', overflow: 'hidden', position: 'relative' }}>
                  {(h.imagenes && h.imagenes.length > 0) || h.imagenUrl ? (
                    <img 
                      src={h.imagenes && h.imagenes.length > 0 ? h.imagenes[0] : h.imagenUrl} 
                      alt={h.nombre} 
                      style={{ width: '100%', height: '100%', objectFit: 'cover' }} 
                    />
                  ) : (
                    <div style={{ width: '100%', height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#999' }}>
                      <Building size={48} />
                    </div>
                  )}
                  {h.rating && (
                    <div style={{ position: 'absolute', top: '10px', right: '10px', backgroundColor: 'rgba(255,255,255,0.9)', padding: '4px 8px', borderRadius: '12px', display: 'flex', alignItems: 'center', gap: '4px', fontSize: '0.85rem', fontWeight: 'bold' }}>
                      <Star size={14} color="#f1c40f" fill="#f1c40f" />
                      {h.rating}
                    </div>
                  )}
                </div>
                <div className="card-content">
                  <h4 style={{ margin: '0 0 8px 0', fontSize: '1.2rem', color: '#2c3e50' }}>{h.nombre}</h4>
                  <p className="location" style={{ display: 'flex', alignItems: 'center', gap: '4px', color: 'var(--text-secondary)', marginBottom: '16px', fontSize: '0.9rem' }}>
                    <MapPin size={16}/> {h.direccion || 'Sigchos, Cotopaxi'}
                  </p>
                  <div className="card-actions" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderTop: '1px solid #eaeaea', paddingTop: '12px' }}>
                    <span className="price" style={{ fontWeight: 'bold', color: 'var(--primary-color)' }}>
                      {h.precioBase ? `$${h.precioBase}` : 'Ver detalles'}
                    </span>
                    <Link to="/login" className="btn btn-primary btn-sm">Reservar</Link>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
        
        {!loading && hosterias.length === 0 && (
          <div style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>
            No hay hosterías disponibles en este momento.
          </div>
        )}
      </section>
    </div>
  );
};

export default LandingPage;

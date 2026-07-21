import React, { useState } from 'react';
import { Building, MapPin, Phone, Star, Search } from 'lucide-react';
import { useAppContext } from '../context/AppContext';

const AdminHosterias = () => {
  const { allHosterias, allReservations, allRooms, allUsers } = useAppContext();
  
  // Paginación
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(10);
  
  // Modal State
  const [selectedHosteria, setSelectedHosteria] = useState(null);

  // Filtros
  const [searchTerm, setSearchTerm] = useState('');
  const [minRating, setMinRating] = useState('0');

  const filteredHosterias = allHosterias.filter(h => {
    let matchText = true;
    if (searchTerm) {
      matchText = h.nombre?.toLowerCase().includes(searchTerm.toLowerCase()) || 
                  h.direccion?.toLowerCase().includes(searchTerm.toLowerCase());
    }
    let matchRating = true;
    if (minRating !== '0') {
      matchRating = (h.rating || 0) >= Number(minRating);
    }
    return matchText && matchRating;
  });

  // Lógica de paginación
  const totalPages = Math.ceil(filteredHosterias.length / itemsPerPage) || 1;
  
  if (currentPage > totalPages && totalPages > 0) {
    setCurrentPage(totalPages);
  }
  
  const startIndex = (currentPage - 1) * itemsPerPage;
  const paginatedHosterias = filteredHosterias.slice(startIndex, startIndex + itemsPerPage);

  const hosteriaReservationsList = selectedHosteria ? allReservations.filter(r => r.hosteriaId === selectedHosteria.id) : [];

  return (
    <div className="animate-fade-in">
      <header className="dashboard-topbar" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h1 className="page-title">Directorio de Hosterías</h1>
          <p className="page-subtitle">Listado completo de todas las hosterías asociadas al sistema.</p>
        </div>
        <div className="search-bar" style={{ display: 'flex', alignItems: 'center', backgroundColor: '#fff', padding: '8px 16px', borderRadius: '20px', boxShadow: '0 2px 5px rgba(0,0,0,0.05)' }}>
          <Search size={18} color="#999" />
          <input 
            type="text" 
            placeholder="Buscar por nombre o ubicación..." 
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            style={{ border: 'none', outline: 'none', marginLeft: '8px', width: '250px' }}
          />
        </div>
      </header>

      <div className="card" style={{ marginTop: '24px', padding: '16px', display: 'flex', gap: '16px', flexWrap: 'wrap', alignItems: 'flex-end' }}>
        <div className="input-group" style={{ marginBottom: 0, flex: '1 1 200px' }}>
          <label htmlFor="filter-rating" className="input-label" style={{ fontSize: '0.85rem' }}>Calificación Mínima (Estrellas)</label>
          <select id="filter-rating" className="input-field" value={minRating} onChange={e => setMinRating(e.target.value)}>
            <option value="0">Cualquiera</option>
            <option value="3">3 Estrellas o más</option>
            <option value="4">4 Estrellas o más</option>
            <option value="4.5">4.5 Estrellas o más</option>
            <option value="5">5 Estrellas</option>
          </select>
        </div>
        <div style={{ flex: '0 0 auto' }}>
          <button className="btn btn-outline" onClick={() => { setSearchTerm(''); setMinRating('0'); }}>Limpiar Filtros</button>
        </div>
      </div>

      {/* Modal Detalles de Reservas */}
      {selectedHosteria && (
        <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: 'rgba(0,0,0,0.6)', zIndex: 1000, display: 'flex', alignItems: 'center', justifyContent: 'center', backdropFilter: 'blur(3px)' }}>
          <div className="card" style={{ width: '100%', maxWidth: '800px', maxHeight: '80vh', display: 'flex', flexDirection: 'column', backgroundColor: '#ffffff', boxShadow: '0 20px 40px rgba(0,0,0,0.3)', borderRadius: '16px', border: '1px solid #e0e0e0', overflow: 'hidden' }}>
            <div style={{ padding: '24px', borderBottom: '1px solid #f0f0f0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <h2 style={{ margin: 0, fontSize: '1.4rem', fontWeight: 'bold', color: '#1a1a1a' }}>Reservas de {selectedHosteria.nombre}</h2>
              <button onClick={() => setSelectedHosteria(null)} style={{ background: 'none', border: 'none', fontSize: '1.5rem', cursor: 'pointer', color: '#999' }}>&times;</button>
            </div>
            
            <div style={{ padding: '24px', overflowY: 'auto', flex: 1 }}>
              {hosteriaReservationsList.length > 0 ? (
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Código</th>
                      <th>Cliente</th>
                      <th>Check-In</th>
                      <th>Total</th>
                      <th>Estado</th>
                    </tr>
                  </thead>
                  <tbody>
                    {hosteriaReservationsList.map(res => {
                      const dateObj = res.fechaCheckIn?.toDate ? res.fechaCheckIn.toDate() : new Date(res.fechaCheckIn);
                      const isDateValid = !Number.isNaN(dateObj.valueOf());
                      
                      // Intentar resolver nombre de cliente si es necesario, o usar el ID
                      let clientName = res.usuarioId ? 'Usuario Registrado' : 'Desconocido';
                      if (res.usuarioId) {
                        const user = allUsers?.find(u => u.id === res.usuarioId);
                        if (user) clientName = user.nombre || user.email || 'Usuario Registrado';
                      }
                      
                      return (
                        <tr key={res.id}>
                          <td><span style={{fontFamily: 'monospace', fontSize: '0.85rem', color: 'var(--text-secondary)'}}>#{res.id.substring(0,8).toUpperCase()}</span></td>
                          <td>{clientName}</td>
                          <td>{isDateValid ? dateObj.toLocaleDateString() : 'N/A'}</td>
                          <td style={{ fontWeight: 'bold' }}>${res.precioTotal ? Number.parseFloat(res.precioTotal).toFixed(2) : '0.00'}</td>
                          <td style={{ textTransform: 'capitalize' }}>{res.estado || 'Pendiente'}</td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              ) : (
                <p style={{ textAlign: 'center', color: 'var(--text-secondary)' }}>Esta hostería no tiene reservas registradas.</p>
              )}
            </div>
            
            <div style={{ padding: '16px 24px', borderTop: '1px solid #f0f0f0', display: 'flex', justifyContent: 'flex-end', backgroundColor: '#fafafa' }}>
              <button className="btn btn-primary" onClick={() => setSelectedHosteria(null)}>Cerrar</button>
            </div>
          </div>
        </div>
      )}

      <div className="card table-card" style={{ marginTop: '24px' }}>
        {/* Controles superiores si hubiera buscador */}
        
        <table className="data-table">
          <thead>
            <tr>
              <th>Hostería</th>
              <th>Dirección</th>
              <th>Contacto</th>
              <th>Total Habitaciones</th>
              <th style={{ textAlign: 'center' }}>Total Reservas</th>
            </tr>
          </thead>
          <tbody>

            {paginatedHosterias.length > 0 ? (
              paginatedHosterias.map(h => {
                const hReservations = allReservations.filter(r => r.hosteriaId === h.id).length;
                const totalRooms = allRooms?.filter(room => room.hosteriaId === h.id).length || 0;
                
                return (
                  <tr key={h.id}>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                        <div style={{ width: '40px', height: '40px', borderRadius: '8px', overflow: 'hidden', backgroundColor: '#f0f0f0' }}>
                          {((h.imagenes && h.imagenes.length > 0) || h.imagenUrl) ? (
                            <img src={h.imagenes && h.imagenes.length > 0 ? h.imagenes[0] : h.imagenUrl} alt={h.nombre} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                          ) : (
                            <div style={{ width: '100%', height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#999' }}>
                              <Building size={20} />
                            </div>
                          )}
                        </div>
                        <div>
                          <div style={{ fontWeight: '600' }}>{h.nombre}</div>
                          {h.rating && (
                            <div style={{ fontSize: '0.8rem', color: '#f1c40f', display: 'flex', alignItems: 'center', gap: '4px' }}>
                              <Star size={12} fill="currentColor" /> {h.rating}
                            </div>
                          )}
                        </div>
                      </div>
                    </td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-secondary)' }}>
                        <MapPin size={16} />
                        {h.direccion || 'No especificada'}
                      </div>
                    </td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-secondary)' }}>
                        <Phone size={16} />
                        {h.telefono || 'No especificado'}
                      </div>
                    </td>
                    <td>{totalRooms} habs.</td>
                    <td style={{ textAlign: 'center' }}>
                      <button 
                        onClick={() => setSelectedHosteria(h)}
                        style={{ 
                          backgroundColor: 'var(--primary-color)', 
                          color: 'white', 
                          padding: '4px 12px', 
                          borderRadius: '16px', 
                          fontSize: '0.85rem', 
                          fontWeight: 'bold',
                          border: 'none',
                          cursor: 'pointer',
                          transition: 'opacity 0.2s',
                          boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
                        }}
                        onMouseOver={(e) => e.currentTarget.style.opacity = '0.8'}
                        onFocus={(e) => e.currentTarget.style.opacity = '0.8'}
                        onMouseOut={(e) => e.currentTarget.style.opacity = '1'}
                        onBlur={(e) => e.currentTarget.style.opacity = '1'}
                      >
                        {hReservations}
                      </button>
                    </td>
                  </tr>
                );
              })
            ) : (
            <tr>
                <td colSpan="5" style={{ textAlign: 'center', padding: '40px' }}>
                  No hay hosterías registradas en el sistema.
                </td>
              </tr>
            )}
          </tbody>
        </table>
        
        {/* Controles de Paginación */}
        {filteredHosterias.length > 0 && (
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '16px 20px', borderTop: '1px solid #eaeaea', backgroundColor: '#fafafa' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <span style={{ fontSize: '0.9rem', color: 'var(--text-secondary)' }}>Mostrar:</span>
              <select 
                value={itemsPerPage} 
                onChange={(e) => { setItemsPerPage(Number(e.target.value)); setCurrentPage(1); }}
                style={{ padding: '4px 8px', borderRadius: '4px', border: '1px solid #ddd' }}
              >
                <option value={10}>10</option>
                <option value={20}>20</option>
                <option value={50}>50</option>
              </select>
            </div>
            
            <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
              <span style={{ fontSize: '0.9rem', color: 'var(--text-secondary)' }}>
                Página {currentPage} de {totalPages} ({filteredHosterias.length} total)
              </span>
              <div style={{ display: 'flex', gap: '8px' }}>
                <button 
                  onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                  disabled={currentPage === 1}
                  className="btn btn-outline btn-sm"
                  style={{ padding: '4px 12px', opacity: currentPage === 1 ? 0.5 : 1 }}
                >
                  Anterior
                </button>
                <button 
                  onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                  disabled={currentPage === totalPages}
                  className="btn btn-outline btn-sm"
                  style={{ padding: '4px 12px', opacity: currentPage === totalPages ? 0.5 : 1 }}
                >
                  Siguiente
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default AdminHosterias;

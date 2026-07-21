import React, { useState } from 'react';
import { User, Mail, Calendar, Search } from 'lucide-react';
import { useAppContext } from '../context/AppContext';

const AdminUsers = () => {
  const { allUsers, allReservations, allHosterias } = useAppContext();
  const [searchTerm, setSearchTerm] = useState('');
  const [dateFrom, setDateFrom] = useState('');
  const [dateTo, setDateTo] = useState('');
  
  // Paginación
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(10);
  
  // Modal State
  const [selectedUser, setSelectedUser] = useState(null);

  const filteredUsers = allUsers.filter(u => {
    let matchText = true;
    if (searchTerm) {
      const nameMatch = u.nombre?.toLowerCase().includes(searchTerm.toLowerCase());
      const emailMatch = u.correo?.toLowerCase().includes(searchTerm.toLowerCase());
      matchText = nameMatch || emailMatch;
    }

    let matchDate = true;
    if (dateFrom || dateTo) {
      const dateObj = u.createdAt?.toDate ? u.createdAt.toDate() : new Date(u.createdAt || u.fechaCreacion || Date.now());
      const time = dateObj.getTime();
      if (dateFrom && time < new Date(dateFrom).getTime()) matchDate = false;
      if (dateTo && time > new Date(dateTo).getTime() + 86400000) matchDate = false;
    }
    return matchText && matchDate;
  });

  // Lógica de paginación
  const totalPages = Math.ceil(filteredUsers.length / itemsPerPage) || 1;
  
  // Asegurar que currentPage no exceda el máximo si cambian los filtros
  if (currentPage > totalPages && totalPages > 0) {
    setCurrentPage(totalPages);
  }
  
  const startIndex = (currentPage - 1) * itemsPerPage;
  const paginatedUsers = filteredUsers.slice(startIndex, startIndex + itemsPerPage);

  const userReservationsList = selectedUser ? allReservations.filter(r => r.usuarioId === selectedUser.id) : [];

  return (
    <div className="animate-fade-in">
      <header className="dashboard-topbar" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 className="page-title">Directorio de Usuarios</h1>
          <p className="page-subtitle">Visualiza todos los usuarios (clientes) registrados en la aplicación.</p>
        </div>
        
        <div className="search-bar" style={{ display: 'flex', alignItems: 'center', backgroundColor: '#fff', padding: '8px 16px', borderRadius: '20px', boxShadow: '0 2px 5px rgba(0,0,0,0.05)' }}>
          <Search size={18} color="#999" />
          <input 
            type="text" 
            placeholder="Buscar por nombre o correo..." 
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            style={{ border: 'none', outline: 'none', marginLeft: '8px', width: '250px' }}
          />
        </div>
      </header>

      {/* Modal Detalles de Reservas */}
      {selectedUser && (
        <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: 'rgba(0,0,0,0.6)', zIndex: 1000, display: 'flex', alignItems: 'center', justifyContent: 'center', backdropFilter: 'blur(3px)' }}>
          <div className="card" style={{ width: '100%', maxWidth: '800px', maxHeight: '80vh', display: 'flex', flexDirection: 'column', backgroundColor: '#ffffff', boxShadow: '0 20px 40px rgba(0,0,0,0.3)', borderRadius: '16px', border: '1px solid #e0e0e0', overflow: 'hidden' }}>
            <div style={{ padding: '24px', borderBottom: '1px solid #f0f0f0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <h2 style={{ margin: 0, fontSize: '1.4rem', fontWeight: 'bold', color: '#1a1a1a' }}>Reservas de {selectedUser.nombre}</h2>
              <button onClick={() => setSelectedUser(null)} style={{ background: 'none', border: 'none', fontSize: '1.5rem', cursor: 'pointer', color: '#999' }}>&times;</button>
            </div>
            
            <div style={{ padding: '24px', overflowY: 'auto', flex: 1 }}>
              {userReservationsList.length > 0 ? (
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Código</th>
                      <th>Hostería</th>
                      <th>Check-In</th>
                      <th>Total</th>
                      <th>Estado</th>
                    </tr>
                  </thead>
                  <tbody>
                    {userReservationsList.map(res => {
                      const dateObj = res.fechaCheckIn?.toDate ? res.fechaCheckIn.toDate() : new Date(res.fechaCheckIn);
                      const isDateValid = !Number.isNaN(dateObj.valueOf());
                      
                      const hosteria = allHosterias?.find(h => h.id === res.hosteriaId);
                      const hosteriaNombre = hosteria?.nombre || 'Desconocida';
                      
                      return (
                        <tr key={res.id}>
                          <td><span style={{fontFamily: 'monospace', fontSize: '0.85rem', color: 'var(--text-secondary)'}}>#{res.id.substring(0,8).toUpperCase()}</span></td>
                          <td>{hosteriaNombre}</td>
                          <td>{isDateValid ? dateObj.toLocaleDateString() : 'N/A'}</td>
                          <td style={{ fontWeight: 'bold' }}>${res.precioTotal ? Number.parseFloat(res.precioTotal).toFixed(2) : '0.00'}</td>
                          <td style={{ textTransform: 'capitalize' }}>{res.estado || 'Pendiente'}</td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              ) : (
                <p style={{ textAlign: 'center', color: 'var(--text-secondary)' }}>Este usuario no tiene reservas registradas.</p>
              )}
            </div>
            
            <div style={{ padding: '16px 24px', borderTop: '1px solid #f0f0f0', display: 'flex', justifyContent: 'flex-end', backgroundColor: '#fafafa' }}>
              <button className="btn btn-primary" onClick={() => setSelectedUser(null)}>Cerrar</button>
            </div>
          </div>
        </div>
      )}

      <div className="card" style={{ marginTop: '24px', padding: '16px', display: 'flex', gap: '16px', flexWrap: 'wrap', alignItems: 'flex-end' }}>
        <div className="input-group" style={{ marginBottom: 0, flex: '1 1 150px' }}>
          <label htmlFor="filter-date-from" className="input-label" style={{ fontSize: '0.85rem' }}>Registrado Desde</label>
          <input id="filter-date-from" type="date" className="input-field" value={dateFrom} onChange={e => setDateFrom(e.target.value)} />
        </div>
        <div className="input-group" style={{ marginBottom: 0, flex: '1 1 150px' }}>
          <label htmlFor="filter-date-to" className="input-label" style={{ fontSize: '0.85rem' }}>Registrado Hasta</label>
          <input id="filter-date-to" type="date" className="input-field" value={dateTo} onChange={e => setDateTo(e.target.value)} />
        </div>
        <div style={{ flex: '0 0 auto' }}>
          <button className="btn btn-outline" onClick={() => { setSearchTerm(''); setDateFrom(''); setDateTo(''); }}>Limpiar Filtros</button>
        </div>
      </div>

      <div className="card table-card" style={{ marginTop: '24px' }}>
        <table className="data-table">
          <thead>
            <tr>
              <th>Usuario</th>
              <th>Correo Electrónico</th>
              <th>Cédula</th>
              <th>Teléfono</th>
              <th>Fecha de Registro</th>
              <th style={{ textAlign: 'center' }}>Total Reservas</th>
            </tr>
          </thead>
          <tbody>
            {paginatedUsers.length > 0 ? (
              paginatedUsers.map(u => {
                // firebase timestamps o ISO strings
                const dateObj = u.createdAt?.toDate ? u.createdAt.toDate() : new Date(u.createdAt || u.fechaCreacion || Date.now());
                const isDateValid = !Number.isNaN(dateObj.valueOf());
                
                // Contar reservas
                const userReservations = allReservations.filter(r => r.usuarioId === u.id).length;
                
                return (
                  <tr key={u.id}>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                        <div style={{ width: '36px', height: '36px', borderRadius: '50%', backgroundColor: 'rgba(52, 152, 219, 0.1)', color: '#3498db', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                          <User size={18} />
                        </div>
                        <div style={{ fontWeight: '500' }}>{u.nombre || 'Sin nombre'} {u.apellido || ''}</div>
                      </div>
                    </td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-secondary)' }}>
                        <Mail size={14} />
                        {u.correo || u.email || 'N/A'}
                      </div>
                    </td>
                    <td style={{ color: 'var(--text-secondary)' }}>
                      {u.cedula || 'N/A'}
                    </td>
                    <td style={{ color: 'var(--text-secondary)' }}>
                      {u.telefono || 'N/A'}
                    </td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-secondary)' }}>
                        <Calendar size={14} />
                        {isDateValid ? dateObj.toLocaleDateString() : 'N/A'}
                      </div>
                    </td>
                    <td style={{ textAlign: 'center' }}>
                      <button 
                        onClick={() => setSelectedUser(u)}
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
                        {userReservations}
                      </button>
                    </td>
                  </tr>
                );
              })
            ) : (
              <tr>
                <td colSpan="6" style={{ textAlign: 'center', padding: '40px' }}>
                  No se encontraron usuarios.
                </td>
              </tr>
            )}
          </tbody>
        </table>
        
        {/* Controles de Paginación */}
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
              Página {currentPage} de {totalPages} ({filteredUsers.length} total)
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
      </div>
    </div>
  );
};

export default AdminUsers;

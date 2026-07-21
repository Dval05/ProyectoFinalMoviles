import React, { useState } from 'react';
import { Calendar, Search, Building } from 'lucide-react';
import { useAppContext } from '../context/AppContext';

const AdminReservations = () => {
  const { allReservations, allHosterias } = useAppContext();
  const [searchTerm, setSearchTerm] = useState('');
  
  // Filtros adicionales
  const [hosteriaFilter, setHosteriaFilter] = useState('Todas');
  const [statusFilter, setStatusFilter] = useState('Todas');
  const [dateFrom, setDateFrom] = useState('');
  const [dateTo, setDateTo] = useState('');
  
  // Paginación
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(10);

  // Enriquecer reservas con el nombre de la hostería
  const enrichedReservations = allReservations.map(res => {
    const hosteria = allHosterias.find(h => h.id === res.hosteriaId);
    return {
      ...res,
      hosteriaNombre: hosteria?.nombre || 'Hostería Desconocida'
    };
  });

  const filteredReservations = enrichedReservations.filter(res => {
    // Texto
    const matchText = !searchTerm || 
      res.id.toLowerCase().includes(searchTerm.toLowerCase()) || 
      res.hosteriaNombre?.toLowerCase().includes(searchTerm.toLowerCase());

    // Hostería
    const matchHosteria = hosteriaFilter === 'Todas' || res.hosteriaId === hosteriaFilter;

    // Estado
    const resStatus = res.estado?.toLowerCase() || 'pendiente';
    const mappedFilter = statusFilter === 'En Revisión' ? 'en_revision' : statusFilter.toLowerCase();
    const matchStatus = statusFilter === 'Todas' || resStatus === mappedFilter;
    
    // Rango de Fechas
    let matchDate = true;
    if (dateFrom || dateTo) {
      const time = (res.fechaCheckIn?.toDate ? res.fechaCheckIn.toDate() : new Date(res.fechaCheckIn || 0)).getTime();
      const fromTime = dateFrom ? new Date(dateFrom).getTime() : 0;
      const toTime = dateTo ? new Date(dateTo).getTime() + 86400000 : Infinity;
      matchDate = time >= fromTime && time <= toTime;
    }

    return matchText && matchHosteria && matchStatus && matchDate;
  });

  // Lógica de paginación
  const totalPages = Math.ceil(filteredReservations.length / itemsPerPage) || 1;
  
  // Asegurar que currentPage no exceda el máximo si cambian los filtros
  if (currentPage > totalPages && totalPages > 0) {
    setCurrentPage(totalPages);
  }
  
  const startIndex = (currentPage - 1) * itemsPerPage;
  const paginatedReservations = filteredReservations.slice(startIndex, startIndex + itemsPerPage);

  const getStatusColor = (status) => {
    const s = (status || '').toLowerCase();
    if (s.includes('confirmada')) return '#2ecc71';
    if (s.includes('cancelada')) return '#e74c3c';
    if (s.includes('revisión') || s.includes('revision')) return '#f1c40f';
    return '#95a5a6';
  };

  return (
    <div className="animate-fade-in">
      <header className="dashboard-topbar" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 className="page-title">Monitor de Reservas Global</h1>
          <p className="page-subtitle">Visualiza todas las reservas registradas en el sistema.</p>
        </div>
        
        <div className="search-bar" style={{ display: 'flex', alignItems: 'center', backgroundColor: '#fff', padding: '8px 16px', borderRadius: '20px', boxShadow: '0 2px 5px rgba(0,0,0,0.05)' }}>
          <Search size={18} color="#999" />
          <input 
            type="text" 
            placeholder="Buscar código o hostería..." 
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            style={{ border: 'none', outline: 'none', marginLeft: '8px', width: '250px' }}
          />
        </div>
      </header>

      <div className="card" style={{ marginTop: '24px', padding: '16px', display: 'flex', gap: '16px', flexWrap: 'wrap', alignItems: 'flex-end' }}>
        <div className="input-group" style={{ marginBottom: 0, flex: '1 1 200px' }}>
          <label htmlFor="filter-hosteria" className="input-label" style={{ fontSize: '0.85rem' }}>Hostería</label>
          <select id="filter-hosteria" className="input-field" value={hosteriaFilter} onChange={e => setHosteriaFilter(e.target.value)}>
            <option value="Todas">Todas</option>
            {allHosterias.map(h => (
              <option key={h.id} value={h.id}>{h.nombre}</option>
            ))}
          </select>
        </div>
        <div className="input-group" style={{ marginBottom: 0, flex: '1 1 150px' }}>
          <label htmlFor="filter-status" className="input-label" style={{ fontSize: '0.85rem' }}>Estado</label>
          <select id="filter-status" className="input-field" value={statusFilter} onChange={e => setStatusFilter(e.target.value)}>
            <option>Todas</option>
            <option>Pendiente</option>
            <option>En Revisión</option>
            <option>Confirmada</option>
            <option>Cancelada</option>
          </select>
        </div>
        <div className="input-group" style={{ marginBottom: 0, flex: '1 1 150px' }}>
          <label htmlFor="filter-date-from" className="input-label" style={{ fontSize: '0.85rem' }}>Check-in Desde</label>
          <input id="filter-date-from" type="date" className="input-field" value={dateFrom} onChange={e => setDateFrom(e.target.value)} />
        </div>
        <div className="input-group" style={{ marginBottom: 0, flex: '1 1 150px' }}>
          <label htmlFor="filter-date-to" className="input-label" style={{ fontSize: '0.85rem' }}>Check-in Hasta</label>
          <input id="filter-date-to" type="date" className="input-field" value={dateTo} onChange={e => setDateTo(e.target.value)} />
        </div>
        <div style={{ flex: '0 0 auto' }}>
          <button className="btn btn-outline" onClick={() => { setSearchTerm(''); setHosteriaFilter('Todas'); setStatusFilter('Todas'); setDateFrom(''); setDateTo(''); }}>Limpiar Filtros</button>
        </div>
      </div>

      <div className="card table-card" style={{ marginTop: '24px' }}>
        <table className="data-table">
          <thead>
            <tr>
              <th>Código</th>
              <th>Hostería</th>
              <th>Fecha de Solicitud</th>
              <th>Período</th>
              <th>Total</th>
              <th>Estado</th>
            </tr>
          </thead>
          <tbody>
            {paginatedReservations.length > 0 ? (
              paginatedReservations.map(res => {
                const dateObj = res.fechaCreacion?.toDate ? res.fechaCreacion.toDate() : new Date(res.fechaCreacion);
                const isDateValid = !Number.isNaN(dateObj.valueOf());
                
                return (
                  <tr key={res.id}>
                    <td>
                      <span style={{fontFamily: 'monospace', fontSize: '0.9rem', color: 'var(--text-secondary)'}}>
                        #{res.id.substring(0,8).toUpperCase()}
                      </span>
                    </td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontWeight: '500' }}>
                        <Building size={16} color="var(--primary-color)" />
                        {res.hosteriaNombre}
                      </div>
                    </td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-secondary)' }}>
                        <Calendar size={14} />
                        {isDateValid ? dateObj.toLocaleDateString() : 'N/A'}
                      </div>
                    </td>
                    <td style={{ color: 'var(--text-secondary)' }}>
                      {res.fechaCheckIn?.toDate ? res.fechaCheckIn.toDate().toLocaleDateString() : (res.fechaCheckIn || '?')} - 
                      {' '}
                      {res.fechaCheckOut?.toDate ? res.fechaCheckOut.toDate().toLocaleDateString() : (res.fechaCheckOut || '?')}
                    </td>
                    <td style={{ fontWeight: 'bold' }}>
                      ${res.precioTotal ? Number.parseFloat(res.precioTotal).toFixed(2) : '0.00'}
                    </td>
                    <td>
                      <span style={{ 
                        backgroundColor: getStatusColor(res.estado) + '20', 
                        color: getStatusColor(res.estado), 
                        padding: '4px 12px', 
                        borderRadius: '16px', 
                        fontSize: '0.85rem', 
                        fontWeight: '600',
                        textTransform: 'capitalize'
                      }}>
                        {res.estado || 'Pendiente'}
                      </span>
                    </td>
                  </tr>
                );
              })
            ) : (
              <tr>
                <td colSpan="6" style={{ textAlign: 'center', padding: '40px' }}>
                  No se encontraron reservas.
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
              Página {currentPage} de {totalPages} ({filteredReservations.length} total)
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

export default AdminReservations;

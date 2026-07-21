import React, { useState } from 'react';
import { CheckCircle, XCircle, Info } from 'lucide-react';
import { useAppContext } from '../context/AppContext';

const ReservationsManager = () => {
  const { reservations, updateReservationStatus } = useAppContext();
  const [selectedResInfo, setSelectedResInfo] = useState(null);

  // Filtros
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('Todas');
  const [dateFrom, setDateFrom] = useState('');
  const [dateTo, setDateTo] = useState('');

  const filteredReservations = reservations.filter(res => {
    // Nombre
    const matchName = !searchTerm || (res.resolvedClientName?.toLowerCase().includes(searchTerm.toLowerCase()));
    
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

    return matchName && matchStatus && matchDate;
  });

  const sortedReservations = [...filteredReservations].sort((a, b) => {
    const dateA = a.fechaCreacion?.toDate ? a.fechaCreacion.toDate() : new Date(a.fechaCreacion || 0);
    const dateB = b.fechaCreacion?.toDate ? b.fechaCreacion.toDate() : new Date(b.fechaCreacion || 0);
    return dateB - dateA; // Most recent first
  });

  return (
    <div className="animate-fade-in">
      <header className="dashboard-topbar">
        <div>
          <h1 className="page-title">Gestión de Reservas</h1>
          <p className="page-subtitle">Confirma o cancela las reservas de tus clientes.</p>
        </div>
      </header>

      {selectedResInfo && (
        <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: 'rgba(0,0,0,0.6)', zIndex: 1000, display: 'flex', alignItems: 'center', justifyContent: 'center', backdropFilter: 'blur(3px)' }}>
          <div className="card" style={{ width: '100%', maxWidth: '500px', padding: '32px', backgroundColor: '#ffffff', boxShadow: '0 20px 40px rgba(0,0,0,0.3)', borderRadius: '16px', border: '1px solid #e0e0e0' }}>
            <h2 style={{ marginBottom: '20px', fontSize: '1.6rem', fontWeight: 'bold', color: '#1a1a1a', borderBottom: '2px solid #f0f0f0', paddingBottom: '10px' }}>Detalles de Reserva #{selectedResInfo.id.substring(0,8).toUpperCase()}</h2>
            <div style={{ display: 'grid', gap: '14px', fontSize: '1.05rem', color: '#333333' }}>
              <p><strong>Cliente:</strong> {selectedResInfo.resolvedClientName}</p>
              {selectedResInfo.esParaOtraPersona && (
                <p><strong>Reserva a nombre de:</strong> {selectedResInfo.nombreOtraPersona}</p>
              )}
              <p>
                <strong>Check-in:</strong> {selectedResInfo.fechaCheckIn?.toDate ? selectedResInfo.fechaCheckIn.toDate().toLocaleDateString() : new Date(selectedResInfo.fechaCheckIn).toLocaleDateString()}
              </p>
              <p>
                <strong>Check-out:</strong> {selectedResInfo.fechaCheckOut?.toDate ? selectedResInfo.fechaCheckOut.toDate().toLocaleDateString() : new Date(selectedResInfo.fechaCheckOut).toLocaleDateString()}
              </p>
              <p><strong>Habitación:</strong> {selectedResInfo.tipoHabitacion || selectedResInfo.habitacionId}</p>
              <p><strong>Cant. Habitaciones:</strong> {selectedResInfo.numHabitaciones || 1}</p>
              <p><strong>Huéspedes:</strong> {selectedResInfo.numHuespedes || 1}</p>
              <p><strong>Observaciones / Notas:</strong> {selectedResInfo.notas || 'Ninguna'}</p>
            </div>
            <div style={{ marginTop: '24px', display: 'flex', justifyContent: 'flex-end' }}>
              <button className="btn btn-primary" onClick={() => setSelectedResInfo(null)}>Cerrar</button>
            </div>
          </div>
        </div>
      )}

      <div className="card" style={{ marginBottom: '24px', padding: '16px', display: 'flex', gap: '16px', flexWrap: 'wrap', alignItems: 'flex-end' }}>
        <div className="input-group" style={{ marginBottom: 0, flex: '1 1 200px' }}>
          <label htmlFor="filter-client" className="input-label" style={{ fontSize: '0.85rem' }}>Buscar cliente</label>
          <input id="filter-client" type="text" className="input-field" placeholder="Nombre..." value={searchTerm} onChange={e => setSearchTerm(e.target.value)} />
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
          <button className="btn btn-outline" onClick={() => { setSearchTerm(''); setStatusFilter('Todas'); setDateFrom(''); setDateTo(''); }}>Limpiar</button>
        </div>
      </div>

      <div className="card table-card">
        <table className="data-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Cliente</th>
              <th>Fecha Ingreso</th>
              <th>Habitación</th>
              <th>Total</th>
              <th>Estado</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            {sortedReservations.length > 0 ? (
              sortedReservations.map(res => {
                let checkInDate = 'N/A';
                if (res.fechaCheckIn?.toDate) {
                  checkInDate = res.fechaCheckIn.toDate().toLocaleDateString();
                } else if (res.fechaCheckIn) {
                  checkInDate = new Date(res.fechaCheckIn).toLocaleDateString();
                }
                
                const status = res.estado?.toLowerCase() || 'pendiente';
                
                let badgeClass = 'cancelled';
                if (status === 'pendiente' || status === 'en_revision') badgeClass = 'pending';
                if (status === 'confirmada') badgeClass = 'confirmed';
                
                return (
                <tr key={res.id}>
                  <td><span style={{fontFamily: 'monospace', fontSize: '0.9rem', color: 'var(--text-secondary)'}}>#{res.id.substring(0,8).toUpperCase()}</span></td>
                  <td>{res.resolvedClientName}</td>
                  <td>{checkInDate}</td>
                  <td>{res.tipoHabitacion || res.habitacionId || 'Habitación'}</td>
                  <td>${res.precioTotal || 0}</td>
                  <td>
                    <span className={`status-badge ${badgeClass}`} style={
                      status === 'cancelada' 
                        ? { backgroundColor: 'rgba(231, 76, 60, 0.2)', color: '#c0392b' } 
                        : undefined
                    }>
                      {status === 'en_revision' ? 'En Revisión' : status.charAt(0).toUpperCase() + status.slice(1)}
                    </span>
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <button 
                        className="btn btn-outline" 
                        style={{ padding: '6px 12px', fontSize: '0.85rem', borderRadius: 'var(--radius-sm)', borderColor: '#3498db', color: '#3498db' }}
                        onClick={() => setSelectedResInfo(res)}
                        title="Ver Info"
                      >
                        <Info size={16} />
                      </button>
                      {(status === 'pendiente' || status === 'en_revision') && (
                        <>
                          <button 
                            className="btn btn-primary" 
                            style={{ padding: '6px 12px', fontSize: '0.85rem', borderRadius: 'var(--radius-sm)' }}
                            onClick={() => updateReservationStatus(res.id, 'confirmada')}
                            title="Confirmar"
                          >
                            <CheckCircle size={16} />
                          </button>
                          <button 
                            className="btn btn-outline" 
                            style={{ padding: '6px 12px', fontSize: '0.85rem', borderRadius: 'var(--radius-sm)', borderColor: '#e74c3c', color: '#e74c3c' }}
                            onClick={() => updateReservationStatus(res.id, 'cancelada')}
                            title="Cancelar"
                          >
                            <XCircle size={16} />
                          </button>
                        </>
                      )}
                      {status === 'confirmada' && (
                         <button 
                           className="btn btn-outline" 
                           style={{ padding: '6px 12px', fontSize: '0.85rem', borderRadius: 'var(--radius-sm)', borderColor: '#e74c3c', color: '#e74c3c' }}
                           onClick={() => updateReservationStatus(res.id, 'cancelada')}
                           title="Cancelar Reserva"
                         >
                           <XCircle size={16} />
                         </button>
                      )}
                    </div>
                  </td>
                </tr>
              )})
            ) : (
              <tr>
                <td colSpan="7" style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '24px' }}>
                  No hay reservas registradas.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default ReservationsManager;

import React, { useState } from 'react';
import { Calendar, TrendingUp, BedDouble, CheckCircle, XCircle, Info } from 'lucide-react';
import { useAppContext } from '../context/AppContext';
import './Dashboard.css';

const DashboardInicio = () => {
  const { user, rooms, reservations, updateReservationStatus } = useAppContext();

  const activeReservations = reservations.filter(r => r.estado?.toLowerCase() === 'confirmada').length;
  const freeRooms = rooms.filter(r => r.disponible === true).length;
  
  // Calculate total income from confirmed reservations
  const totalIncome = reservations
    .filter(r => r.estado?.toLowerCase() === 'confirmada')
    .reduce((sum, res) => sum + (res.precioTotal || 0), 0);

  // Get recent reservations (e.g. last 5)
  const recentReservations = [...reservations].sort((a, b) => {
    const dateA = a.fechaCreacion?.toDate ? a.fechaCreacion.toDate() : new Date(a.fechaCreacion || 0);
    const dateB = b.fechaCreacion?.toDate ? b.fechaCreacion.toDate() : new Date(b.fechaCreacion || 0);
    return dateB - dateA;
  }).slice(0, 5);

  const [selectedResInfo, setSelectedResInfo] = useState(null);

  return (
    <>
      <header className="dashboard-topbar">
        <div>
          <h1 className="page-title">Bienvenido, {user?.name || 'Hostería'}</h1>
          <p className="page-subtitle">Aquí tienes un resumen de tu actividad.</p>
        </div>
        <div className="user-profile">
          <div className="avatar bg-green-light">HJ</div>
        </div>
      </header>

      <section className="stats-grid">
        <div className="stat-card card">
          <div className="stat-icon bg-green-light"><Calendar size={24}/></div>
          <div className="stat-info">
            <h3>{activeReservations}</h3>
            <p>Reservas Confirmadas</p>
          </div>
        </div>
        <div className="stat-card card">
          <div className="stat-icon bg-green-dark"><BedDouble size={24} color="white"/></div>
          <div className="stat-info">
            <h3>{freeRooms}</h3>
            <p>Habitaciones Libres</p>
          </div>
        </div>
        <div className="stat-card card">
          <div className="stat-icon bg-golden"><TrendingUp size={24}/></div>
          <div className="stat-info">
            <h3>${totalIncome}</h3>
            <p>Ingresos del Mes</p>
          </div>
        </div>
      </section>

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

      <section className="recent-activity">
        <h2 className="section-title">Últimas Reservas</h2>
        <div className="card table-card">
          <table className="data-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Cliente</th>
                <th>Fecha Ingreso</th>
                <th>Habitación</th>
                <th>Estado</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {recentReservations.length > 0 ? (
                recentReservations.map(res => {
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
                    <td>#{res.id.substring(0,8).toUpperCase()}</td>
                    <td>{res.resolvedClientName}</td>
                    <td>{checkInDate}</td>
                    <td>{res.tipoHabitacion || res.habitacionId || 'Habitación'}</td>
                    <td>
                      <span className={`status-badge ${badgeClass}`}>
                        {status === 'en_revision' ? 'En Revisión' : status.charAt(0).toUpperCase() + status.slice(1)}
                      </span>
                    </td>
                    <td>
                      <div style={{ display: 'flex', gap: '8px' }}>
                        <button 
                          className="btn btn-outline" 
                          style={{ padding: '4px 8px', fontSize: '0.75rem', borderRadius: 'var(--radius-sm)', borderColor: '#3498db', color: '#3498db' }}
                          onClick={() => setSelectedResInfo(res)}
                          title="Ver Info"
                        >
                          <Info size={14} />
                        </button>
                        {(status === 'pendiente' || status === 'en_revision') && (
                          <>
                            <button 
                              className="btn btn-primary" 
                              style={{ padding: '4px 8px', fontSize: '0.75rem', borderRadius: 'var(--radius-sm)' }}
                              onClick={() => updateReservationStatus(res.id, 'confirmada')}
                              title="Confirmar"
                            >
                              <CheckCircle size={14} />
                            </button>
                            <button 
                              className="btn btn-outline" 
                              style={{ padding: '4px 8px', fontSize: '0.75rem', borderRadius: 'var(--radius-sm)', borderColor: '#e74c3c', color: '#e74c3c' }}
                              onClick={() => updateReservationStatus(res.id, 'cancelada')}
                              title="Cancelar"
                            >
                              <XCircle size={14} />
                            </button>
                          </>
                        )}
                        {status === 'confirmada' && (
                           <button 
                             className="btn btn-outline" 
                             style={{ padding: '4px 8px', fontSize: '0.75rem', borderRadius: 'var(--radius-sm)', borderColor: '#e74c3c', color: '#e74c3c' }}
                             onClick={() => updateReservationStatus(res.id, 'cancelada')}
                           >
                             Cancelar
                           </button>
                        )}
                      </div>
                    </td>
                  </tr>
                )})
              ) : (
                <tr>
                  <td colSpan="4" style={{ textAlign: 'center', color: 'var(--text-secondary)' }}>
                    No hay reservas recientes.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </section>
    </>
  );
};

export default DashboardInicio;

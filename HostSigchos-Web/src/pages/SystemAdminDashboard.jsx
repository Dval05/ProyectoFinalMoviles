import React, { useMemo } from 'react';
import { Building, Users, Calendar, CheckCircle, Clock, XCircle, AlertTriangle } from 'lucide-react';
import { useAppContext } from '../context/AppContext';

const SystemAdminDashboard = () => {
  const { allHosterias, allReservations, allUsers } = useAppContext();

  const stats = useMemo(() => {
    let confirmadas = 0;
    let canceladas = 0;
    let pendientes = 0;
    let enRevision = 0;

    allReservations.forEach(r => {
      const estado = (r.estado || '').toLowerCase();
      if (estado === 'confirmada') confirmadas++;
      else if (estado === 'cancelada') canceladas++;
      else if (estado === 'en_revision' || estado === 'en_revisión') enRevision++;
      else pendientes++;
    });

    return { confirmadas, canceladas, pendientes, enRevision };
  }, [allReservations]);

  return (
    <div className="animate-fade-in">
      <header className="dashboard-topbar">
        <div>
          <h1 className="page-title">Vista General del Sistema</h1>
          <p className="page-subtitle">Monitoreo global de todas las hosterías, usuarios y reservas de HostSigchos.</p>
        </div>
      </header>

      {/* Global Stats Cards */}
      <div className="stats-grid" style={{ marginTop: '24px' }}>
        <div className="stat-card">
          <div className="stat-icon" style={{ backgroundColor: 'rgba(52, 152, 219, 0.1)', color: '#3498db' }}>
            <Building size={24} />
          </div>
          <div className="stat-content">
            <h3>Total Hosterías</h3>
            <p className="stat-value">{allHosterias.length}</p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon" style={{ backgroundColor: 'rgba(155, 89, 182, 0.1)', color: '#9b59b6' }}>
            <Users size={24} />
          </div>
          <div className="stat-content">
            <h3>Usuarios Registrados</h3>
            <p className="stat-value">{allUsers.length}</p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon" style={{ backgroundColor: 'rgba(241, 196, 15, 0.1)', color: '#f1c40f' }}>
            <Calendar size={24} />
          </div>
          <div className="stat-content">
            <h3>Reservas Totales</h3>
            <p className="stat-value">{allReservations.length}</p>
          </div>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '20px', marginTop: '24px' }}>
        <div className="card" style={{ padding: '20px', textAlign: 'center', borderTop: '4px solid #2ecc71' }}>
          <CheckCircle size={32} color="#2ecc71" style={{ margin: '0 auto 10px auto' }} />
          <h4 style={{ margin: 0, color: 'var(--text-secondary)' }}>Confirmadas</h4>
          <h2 style={{ margin: '10px 0 0 0', fontSize: '2rem' }}>{stats.confirmadas}</h2>
        </div>
        <div className="card" style={{ padding: '20px', textAlign: 'center', borderTop: '4px solid #e67e22' }}>
          <Clock size={32} color="#e67e22" style={{ margin: '0 auto 10px auto' }} />
          <h4 style={{ margin: 0, color: 'var(--text-secondary)' }}>Pendientes</h4>
          <h2 style={{ margin: '10px 0 0 0', fontSize: '2rem' }}>{stats.pendientes}</h2>
        </div>
        <div className="card" style={{ padding: '20px', textAlign: 'center', borderTop: '4px solid #3498db' }}>
          <AlertTriangle size={32} color="#3498db" style={{ margin: '0 auto 10px auto' }} />
          <h4 style={{ margin: 0, color: 'var(--text-secondary)' }}>En Revisión</h4>
          <h2 style={{ margin: '10px 0 0 0', fontSize: '2rem' }}>{stats.enRevision}</h2>
        </div>
        <div className="card" style={{ padding: '20px', textAlign: 'center', borderTop: '4px solid #e74c3c' }}>
          <XCircle size={32} color="#e74c3c" style={{ margin: '0 auto 10px auto' }} />
          <h4 style={{ margin: 0, color: 'var(--text-secondary)' }}>Canceladas</h4>
          <h2 style={{ margin: '10px 0 0 0', fontSize: '2rem' }}>{stats.canceladas}</h2>
        </div>
      </div>

      <div className="card table-card" style={{ marginTop: '24px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '20px 20px 0 20px' }}>
          <h3 style={{ margin: 0, fontSize: '1.2rem' }}>Últimas Hosterías Registradas</h3>
          <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>Mostrando max. 5 recientes</span>
        </div>
        <table className="data-table">
          <thead>
            <tr>
              <th>Nombre</th>
              <th>Dirección</th>
              <th>Teléfono</th>
              <th>Reservas (Global)</th>
            </tr>
          </thead>
          <tbody>
            {allHosterias.length > 0 ? (
              allHosterias.slice(0, 5).map(h => {
                const hReservations = allReservations.filter(r => r.hosteriaId === h.id).length;
                return (
                  <tr key={h.id}>
                    <td style={{ fontWeight: 'bold' }}>{h.nombre}</td>
                    <td>{h.direccion || 'N/A'}</td>
                    <td>{h.telefono || 'N/A'}</td>
                    <td>
                      <span style={{ backgroundColor: 'var(--primary-color)', color: 'white', padding: '2px 8px', borderRadius: '12px', fontSize: '0.85rem' }}>
                        {hReservations}
                      </span>
                    </td>
                  </tr>
                );
              })
            ) : (
              <tr>
                <td colSpan="4" style={{ textAlign: 'center', padding: '40px' }}>No hay hosterías registradas.</td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default SystemAdminDashboard;

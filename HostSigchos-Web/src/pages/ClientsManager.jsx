import React, { useMemo, useState } from 'react';
import { Users } from 'lucide-react';
import { useAppContext } from '../context/AppContext';

const ClientsManager = () => {
  const { reservations } = useAppContext();
  const [searchTerm, setSearchTerm] = useState('');
  const [minSpent, setMinSpent] = useState('');

  // Extract unique clients from reservations
  const clientsList = useMemo(() => {
    const clientMap = {};
    
    reservations.forEach(res => {
      // Use usuarioId as primary key, fallback to name
      const key = res.usuarioId || res.resolvedClientName;
      if (!key) return; // Skip if no identifier
      
      if (!clientMap[key]) {
        clientMap[key] = {
          id: res.usuarioId || `guest_${Date.now().toString(36)}_${Object.keys(clientMap).length}`,
          name: res.resolvedClientName || 'Cliente Anónimo',
          email: res.usuarioCorreo || 'No especificado',
          phone: res.usuarioTelefono || 'No especificado',
          reservationsCount: 0,
          totalSpent: 0,
          lastReservation: null
        };
      }
      
      clientMap[key].reservationsCount += 1;
      clientMap[key].totalSpent += (res.precioTotal || 0);
      
      const currentLast = clientMap[key].lastReservation?.toDate 
        ? clientMap[key].lastReservation.toDate() 
        : new Date(clientMap[key].lastReservation || 0);
      const newDate = res.fechaCreacion?.toDate 
        ? res.fechaCreacion.toDate() 
        : new Date(res.fechaCreacion || 0);
        
      if (!clientMap[key].lastReservation || newDate > currentLast) {
        clientMap[key].lastReservation = res.fechaCreacion;
      }
    });

    return Object.values(clientMap).sort((a, b) => b.totalSpent - a.totalSpent);
  }, [reservations]);

  const filteredClients = useMemo(() => {
    return clientsList.filter(c => {
      let matchText = true;
      if (searchTerm) {
        matchText = c.name?.toLowerCase().includes(searchTerm.toLowerCase());
      }
      let matchSpent = true;
      if (minSpent) {
        matchSpent = c.totalSpent >= Number(minSpent);
      }
      return matchText && matchSpent;
    });
  }, [clientsList, searchTerm, minSpent]);

  return (
    <div className="animate-fade-in">
      <header className="dashboard-topbar">
        <div>
          <h1 className="page-title">Gestión de Clientes</h1>
          <p className="page-subtitle">Visualiza la lista de tus clientes frecuentes (Extraídos de tus reservas).</p>
        </div>
      </header>

      <div className="card" style={{ marginTop: '24px', padding: '16px', display: 'flex', gap: '16px', flexWrap: 'wrap', alignItems: 'flex-end' }}>
        <div className="input-group" style={{ marginBottom: 0, flex: '1 1 200px' }}>
          <label htmlFor="filter-name" className="input-label" style={{ fontSize: '0.85rem' }}>Buscar por nombre</label>
          <input id="filter-name" type="text" className="input-field" placeholder="Nombre del cliente..." value={searchTerm} onChange={e => setSearchTerm(e.target.value)} />
        </div>
        <div className="input-group" style={{ marginBottom: 0, flex: '1 1 150px' }}>
          <label htmlFor="filter-spent" className="input-label" style={{ fontSize: '0.85rem' }}>Gasto Mínimo ($)</label>
          <input id="filter-spent" type="number" min="0" className="input-field" placeholder="Ej: 50" value={minSpent} onChange={e => setMinSpent(e.target.value)} />
        </div>
        <div style={{ flex: '0 0 auto' }}>
          <button className="btn btn-outline" onClick={() => { setSearchTerm(''); setMinSpent(''); }}>Limpiar Filtros</button>
        </div>
      </div>

      <div className="card table-card" style={{ marginTop: '24px' }}>
        <table className="data-table">
          <thead>
            <tr>
              <th>Cliente</th>
              <th>Reservas Totales</th>
              <th>Gasto Total</th>
              <th>Última Reserva</th>
            </tr>
          </thead>
          <tbody>
            {filteredClients.length > 0 ? (
              filteredClients.map(client => {
                const lastResDate = client.lastReservation?.toDate 
                  ? client.lastReservation.toDate().toLocaleDateString() 
                  : new Date(client.lastReservation).toLocaleDateString();

                return (
                  <tr key={client.id}>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                        <div style={{ width: '40px', height: '40px', borderRadius: '50%', backgroundColor: 'var(--primary-color)', color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold' }}>
                          {client.name.charAt(0).toUpperCase()}
                        </div>
                        <div>
                          <p style={{ fontWeight: '600', margin: 0 }}>{client.name}</p>
                          {client.id.startsWith('guest_') ? (
                            <span style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>Invitado</span>
                          ) : (
                            <span style={{ fontSize: '0.8rem', color: 'var(--primary-color)' }}>Registrado</span>
                          )}
                        </div>
                      </div>
                    </td>
                    <td>{client.reservationsCount}</td>
                    <td style={{ fontWeight: '600', color: 'var(--green-dark)' }}>${client.totalSpent.toFixed(2)}</td>
                    <td>{lastResDate === 'Invalid Date' ? 'N/A' : lastResDate}</td>
                  </tr>
                );
              })
            ) : (
              <tr>
                <td colSpan="4" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>
                  <Users size={48} style={{ margin: '0 auto 16px auto', opacity: 0.5 }} />
                  No hay clientes registrados aún. Espera a recibir reservas.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default ClientsManager;

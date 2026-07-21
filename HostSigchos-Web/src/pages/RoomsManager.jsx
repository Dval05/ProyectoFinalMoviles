import React, { useState } from 'react';
import { BedDouble, Image as ImageIcon, Edit2 } from 'lucide-react';
import { useAppContext } from '../context/AppContext';

const RoomsManager = () => {
  const { rooms, toggleRoomStatus, editRoom } = useAppContext();
  const [selectedRoom, setSelectedRoom] = useState(null);
  const [closeDate, setCloseDate] = useState('');
  
  const [editingRoom, setEditingRoom] = useState(null);
  const [editFormData, setEditFormData] = useState({
    tipo: '',
    descripcion: '',
    precioPorNoche: 0,
    capacidad: 1,
    cantidadTotal: 1
  });

  // Filtros
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('Todas');
  const [minPrice, setMinPrice] = useState('');
  const [maxPrice, setMaxPrice] = useState('');

  const filteredRooms = rooms.filter(room => {
    let matchText = true;
    if (searchTerm) {
      matchText = room.tipo?.toLowerCase().includes(searchTerm.toLowerCase()) || 
                  room.descripcion?.toLowerCase().includes(searchTerm.toLowerCase());
    }

    let matchStatus = true;
    if (statusFilter !== 'Todas') {
      if (statusFilter === 'Disponibles') matchStatus = room.disponible === true;
      if (statusFilter === 'Cerradas') matchStatus = room.disponible === false;
    }

    let matchPrice = true;
    if (minPrice) matchPrice = matchPrice && (room.precioPorNoche >= Number(minPrice));
    if (maxPrice) matchPrice = matchPrice && (room.precioPorNoche <= Number(maxPrice));

    return matchText && matchStatus && matchPrice;
  });

  const handleToggle = (room) => {
    if (room.disponible) {
      setSelectedRoom(room);
      setCloseDate('');
    } else {
      toggleRoomStatus(room.id, true);
    }
  };

  const handleCloseRoom = (e) => {
    e.preventDefault();
    if (selectedRoom && closeDate) {
      toggleRoomStatus(selectedRoom.id, false, closeDate);
      setSelectedRoom(null);
    }
  };

  const handleEditClick = (room) => {
    setEditingRoom(room);
    setEditFormData({
      tipo: room.tipo || '',
      descripcion: room.descripcion || '',
      precioPorNoche: room.precioPorNoche || 0,
      capacidad: room.capacidad || 1,
      cantidadTotal: room.cantidadTotal || 1
    });
  };

  const handleEditSubmit = async (e) => {
    e.preventDefault();
    if (editingRoom) {
      await editRoom(editingRoom.id, {
        ...editFormData,
        precioPorNoche: Number(editFormData.precioPorNoche),
        capacidad: Number(editFormData.capacidad),
        cantidadTotal: Number(editFormData.cantidadTotal)
      });
      setEditingRoom(null);
    }
  };

  return (
    <div className="animate-fade-in">
      <header className="dashboard-topbar">
        <div>
          <h1 className="page-title">Gestión de Habitaciones</h1>
          <p className="page-subtitle">Habilita o deshabilita habitaciones para reservas.</p>
        </div>
      </header>

      <div className="card" style={{ marginBottom: '24px', padding: '16px', display: 'flex', gap: '16px', flexWrap: 'wrap', alignItems: 'flex-end' }}>
        <div className="input-group" style={{ marginBottom: 0, flex: '1 1 200px' }}>
          <label htmlFor="filter-room" className="input-label" style={{ fontSize: '0.85rem' }}>Buscar habitación</label>
          <input id="filter-room" type="text" className="input-field" placeholder="Tipo o descripción..." value={searchTerm} onChange={e => setSearchTerm(e.target.value)} />
        </div>
        <div className="input-group" style={{ marginBottom: 0, flex: '1 1 150px' }}>
          <label htmlFor="filter-status" className="input-label" style={{ fontSize: '0.85rem' }}>Estado</label>
          <select id="filter-status" className="input-field" value={statusFilter} onChange={e => setStatusFilter(e.target.value)}>
            <option>Todas</option>
            <option>Disponibles</option>
            <option>Cerradas</option>
          </select>
        </div>
        <div className="input-group" style={{ marginBottom: 0, flex: '1 1 120px' }}>
          <label htmlFor="filter-min-price" className="input-label" style={{ fontSize: '0.85rem' }}>Precio Mín.</label>
          <input id="filter-min-price" type="number" min="0" className="input-field" placeholder="$" value={minPrice} onChange={e => setMinPrice(e.target.value)} />
        </div>
        <div className="input-group" style={{ marginBottom: 0, flex: '1 1 120px' }}>
          <label htmlFor="filter-max-price" className="input-label" style={{ fontSize: '0.85rem' }}>Precio Máx.</label>
          <input id="filter-max-price" type="number" min="0" className="input-field" placeholder="$" value={maxPrice} onChange={e => setMaxPrice(e.target.value)} />
        </div>
        <div style={{ flex: '0 0 auto' }}>
          <button className="btn btn-outline" onClick={() => { setSearchTerm(''); setStatusFilter('Todas'); setMinPrice(''); setMaxPrice(''); }}>Limpiar</button>
        </div>
      </div>

      {selectedRoom && (
        <div className="card" style={{ padding: '24px', marginBottom: '24px', borderLeft: '4px solid var(--primary-color)' }}>
          <h3>Cerrar habitación: {selectedRoom.tipo}</h3>
          <form onSubmit={handleCloseRoom} style={{ display: 'flex', gap: '16px', marginTop: '16px', alignItems: 'flex-end' }}>
            <div className="input-group" style={{ marginBottom: 0 }}>
              <label htmlFor="close-date" className="input-label">Cerrada hasta la fecha:</label>
              <input 
                id="close-date"
                type="date" 
                className="input-field" 
                value={closeDate} 
                onChange={(e) => setCloseDate(e.target.value)}
                required 
              />
            </div>
            <button type="submit" className="btn btn-primary">Confirmar Cierre</button>
            <button type="button" className="btn btn-outline" onClick={() => setSelectedRoom(null)}>Cancelar</button>
          </form>
        </div>
      )}

      {editingRoom && (
        <div style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: 'rgba(0,0,0,0.6)', zIndex: 1000, display: 'flex', alignItems: 'center', justifyContent: 'center', backdropFilter: 'blur(3px)' }}>
          <div className="card" style={{ width: '100%', maxWidth: '500px', padding: '32px', backgroundColor: '#ffffff', boxShadow: '0 20px 40px rgba(0,0,0,0.3)', borderRadius: '16px', border: '1px solid #e0e0e0', maxHeight: '90vh', overflowY: 'auto' }}>
            <h2 style={{ marginBottom: '20px', fontSize: '1.6rem', fontWeight: 'bold', color: '#1a1a1a', borderBottom: '2px solid #f0f0f0', paddingBottom: '10px' }}>
              Editar Habitación
            </h2>
            <form onSubmit={handleEditSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div className="input-group">
                <label htmlFor="edit-tipo" className="input-label">Tipo / Nombre</label>
                <input 
                  id="edit-tipo"
                  type="text" 
                  className="input-field" 
                  value={editFormData.tipo} 
                  onChange={(e) => setEditFormData({...editFormData, tipo: e.target.value})}
                  required 
                />
              </div>
              <div className="input-group">
                <label htmlFor="edit-desc" className="input-label">Descripción</label>
                <textarea 
                  id="edit-desc"
                  className="input-field" 
                  rows="3"
                  value={editFormData.descripcion} 
                  onChange={(e) => setEditFormData({...editFormData, descripcion: e.target.value})}
                  required 
                />
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                <div className="input-group">
                  <label htmlFor="edit-precio" className="input-label">Precio por Noche ($)</label>
                  <input 
                    id="edit-precio"
                    type="number" 
                    min="0"
                    step="0.01"
                    className="input-field" 
                    value={editFormData.precioPorNoche} 
                    onChange={(e) => setEditFormData({...editFormData, precioPorNoche: e.target.value})}
                    required 
                  />
                </div>
                <div className="input-group">
                  <label htmlFor="edit-cap" className="input-label">Capacidad (pers.)</label>
                  <input 
                    id="edit-cap"
                    type="number" 
                    min="1"
                    className="input-field" 
                    value={editFormData.capacidad} 
                    onChange={(e) => setEditFormData({...editFormData, capacidad: e.target.value})}
                    required 
                  />
                </div>
                <div className="input-group">
                  <label htmlFor="edit-total" className="input-label">Total Habitaciones</label>
                  <input 
                    id="edit-total"
                    type="number" 
                    min="1"
                    className="input-field" 
                    value={editFormData.cantidadTotal} 
                    onChange={(e) => setEditFormData({...editFormData, cantidadTotal: e.target.value})}
                    required 
                  />
                </div>
              </div>
              <div style={{ marginTop: '16px', display: 'flex', justifyContent: 'flex-end', gap: '12px' }}>
                <button type="button" className="btn btn-outline" onClick={() => setEditingRoom(null)}>Cancelar</button>
                <button type="submit" className="btn btn-primary">Guardar Cambios</button>
              </div>
            </form>
          </div>
        </div>
      )}

      <div className="stats-grid" style={{ gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))' }}>
        {filteredRooms.map(room => {
          const mainImage = room.imagenes && room.imagenes.length > 0 ? room.imagenes[0] : null;
          
          return (
            <div key={room.id} className="card stat-card" style={{ flexDirection: 'column', alignItems: 'flex-start', padding: 0, overflow: 'hidden' }}>
              
              {/* Image Header */}
              <div style={{ width: '100%', height: '180px', backgroundColor: '#f0f0f0', position: 'relative' }}>
                {mainImage ? (
                  <img src={mainImage} alt={room.tipo} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                ) : (
                  <div style={{ display: 'flex', width: '100%', height: '100%', alignItems: 'center', justifyContent: 'center', color: '#999' }}>
                    <ImageIcon size={48} />
                  </div>
                )}
                <div style={{ position: 'absolute', top: '12px', right: '12px' }}>
                  <span className={`status-badge ${room.disponible ? 'confirmed' : 'pending'}`} style={{ backgroundColor: room.disponible ? undefined : 'rgba(231, 76, 60, 0.9)', color: room.disponible ? undefined : 'white', boxShadow: '0 2px 4px rgba(0,0,0,0.2)' }}>
                    {room.disponible ? 'Disponible' : 'Cerrada'}
                  </span>
                </div>
              </div>

              {/* Content Body */}
              <div style={{ padding: '20px', width: '100%', display: 'flex', flexDirection: 'column', flex: 1 }}>
                <div className="stat-info" style={{ width: '100%', marginBottom: 'auto' }}>
                  <h3 style={{ fontSize: '1.2rem', display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <BedDouble size={20} className="text-primary" />
                    {room.tipo}
                  </h3>
                  <p style={{ color: 'var(--text-secondary)', margin: '8px 0', fontSize: '0.9rem', display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
                    {room.descripcion}
                  </p>
                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px', marginTop: '12px' }}>
                    <span style={{ fontWeight: 600, fontSize: '1.1rem' }}>${room.precioPorNoche} <span style={{fontSize: '0.8rem', fontWeight: 'normal', color: 'var(--text-secondary)'}}>/noche</span></span>
                    <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', textAlign: 'right' }}>Cap: {room.capacidad} pers.</span>
                    <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>Disp: {room.cantidadTotal || 1} hab.</span>
                  </div>
                  {!room.disponible && room.closedUntil && (
                    <p style={{ color: '#e74c3c', marginTop: '12px', fontSize: '0.85rem', fontWeight: 600 }}>
                      Cerrada hasta: {room.closedUntil}
                    </p>
                  )}
                </div>

                <div style={{ display: 'flex', gap: '8px', marginTop: '20px' }}>
                  <button 
                    className={`btn ${room.disponible ? 'btn-outline' : 'btn-primary'}`} 
                    style={{ flex: 1, padding: '8px' }}
                    onClick={() => handleToggle(room)}
                  >
                    {room.disponible ? 'Deshabilitar' : 'Habilitar'}
                  </button>
                  <button 
                    className="btn btn-primary"
                    style={{ padding: '8px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                    onClick={() => handleEditClick(room)}
                    title="Editar Habitación"
                  >
                    <Edit2 size={18} />
                  </button>
                </div>
              </div>
            </div>
          );
        })}
        {filteredRooms.length === 0 && (
          <div style={{ gridColumn: '1 / -1', padding: '40px', textAlign: 'center', color: 'var(--text-secondary)' }}>
            <p>No se encontraron habitaciones. Asegúrate de crearlas en la base de datos.</p>
          </div>
        )}
      </div>
    </div>
  );
};

export default RoomsManager;

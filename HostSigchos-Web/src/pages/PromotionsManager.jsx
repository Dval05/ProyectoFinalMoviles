import React, { useState } from 'react';
import { Tag, Trash2, Plus, CheckSquare, Square } from 'lucide-react';
import { useAppContext } from '../context/AppContext';

const PromotionsManager = () => {
  const { promotions, addPromotion, deletePromotion, rooms } = useAppContext();
  
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [discount, setDiscount] = useState('');
  const [expiryDate, setExpiryDate] = useState('');
  const [selectedRooms, setSelectedRooms] = useState([]);
  const [selectAll, setSelectAll] = useState(false);

  const handleToggleRoom = (roomId) => {
    if (selectedRooms.includes(roomId)) {
      setSelectedRooms(selectedRooms.filter(id => id !== roomId));
      setSelectAll(false);
    } else {
      const newSelection = [...selectedRooms, roomId];
      setSelectedRooms(newSelection);
      if (newSelection.length === rooms.length) {
        setSelectAll(true);
      }
    }
  };

  const handleToggleAll = () => {
    if (selectAll) {
      setSelectAll(false);
      setSelectedRooms([]);
    } else {
      setSelectAll(true);
      setSelectedRooms(rooms.map(r => r.id));
    }
  };

  const handleAddPromotion = (e) => {
    e.preventDefault();
    if (title && description && discount && expiryDate && selectedRooms.length > 0) {
      addPromotion({
        title,
        description,
        discount: Number(discount),
        expiryDate,
        habitacionesAplicables: selectedRooms
      });
      setTitle('');
      setDescription('');
      setDiscount('');
      setExpiryDate('');
      setSelectedRooms([]);
      setSelectAll(false);
    } else if (selectedRooms.length === 0) {
      alert("Por favor, selecciona al menos una habitación para la promoción.");
    }
  };

  return (
    <div className="animate-fade-in">
      <header className="dashboard-topbar">
        <div>
          <h1 className="page-title">Gestión de Promociones</h1>
          <p className="page-subtitle">Crea y administra ofertas para tus clientes.</p>
        </div>
      </header>

      <div style={{ display: 'grid', gridTemplateColumns: '1.2fr 1.8fr', gap: '32px' }}>
        {/* Add Promotion Form */}
        <div className="card" style={{ padding: '24px', height: 'fit-content' }}>
          <h3 style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '24px' }}>
            <Plus size={20} className="text-primary" />
            Nueva Promoción
          </h3>
          <form onSubmit={handleAddPromotion}>
            <div className="input-group">
              <label htmlFor="promo-title" className="input-label">Título</label>
              <input 
                id="promo-title"
                type="text" 
                className="input-field" 
                placeholder="Ej: Oferta de Verano"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                required
              />
            </div>
            
            <div className="input-group">
              <label htmlFor="promo-desc" className="input-label">Descripción</label>
              <textarea 
                id="promo-desc"
                className="input-field" 
                placeholder="Detalles de la promoción..."
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                style={{ resize: 'vertical', minHeight: '80px' }}
                required
              />
            </div>
            
            <div className="input-group" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
              <div>
                <label htmlFor="promo-discount" className="input-label">Descuento (%)</label>
                <input 
                  id="promo-discount"
                  type="number" 
                  className="input-field" 
                  placeholder="Ej: 15"
                  min="1" max="100"
                  value={discount}
                  onChange={(e) => setDiscount(e.target.value)}
                  required
                />
              </div>
              <div>
                <label htmlFor="promo-expiry" className="input-label">Válido Hasta</label>
                <input 
                  id="promo-expiry"
                  type="date" 
                  className="input-field" 
                  value={expiryDate}
                  onChange={(e) => setExpiryDate(e.target.value)}
                  required
                />
              </div>
            </div>

            {/* Room Selection */}
            <div className="input-group">
              <div className="input-label" style={{marginBottom: '8px'}}>Aplica a Habitaciones:</div>
              <div style={{ padding: '12px', border: '1px solid var(--border-color)', borderRadius: '8px', maxHeight: '180px', overflowY: 'auto' }}>
                <button 
                  type="button"
                  style={{ display: 'flex', width: '100%', background: 'none', border: 'none', alignItems: 'center', gap: '8px', padding: '8px 0', borderBottom: '1px solid #eee', cursor: 'pointer', fontWeight: 'bold' }}
                  onClick={handleToggleAll}
                >
                  {selectAll ? <CheckSquare size={18} className="text-primary" /> : <Square size={18} color="#ccc" />}
                  <span>Seleccionar Todas</span>
                </button>
                {rooms.map(room => (
                  <button 
                    type="button"
                    key={room.id} 
                    style={{ display: 'flex', width: '100%', background: 'none', border: 'none', alignItems: 'center', gap: '12px', padding: '8px 0', cursor: 'pointer' }}
                    onClick={() => handleToggleRoom(room.id)}
                  >
                    {selectedRooms.includes(room.id) ? <CheckSquare size={18} className="text-primary" /> : <Square size={18} color="#ccc" />}
                    
                    {room.imagenes && room.imagenes.length > 0 ? (
                      <img src={room.imagenes[0]} alt={room.tipo} style={{ width: '40px', height: '40px', borderRadius: '4px', objectFit: 'cover' }} />
                    ) : (
                      <div style={{ width: '40px', height: '40px', borderRadius: '4px', backgroundColor: '#eee', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <Tag size={16} color="#aaa" />
                      </div>
                    )}
                    
                    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-start' }}>
                      <span>{room.tipo}</span>
                      <span style={{color: '#888', fontSize: '0.85em'}}>${room.precioPorNoche} por noche</span>
                    </div>
                  </button>
                ))}
                {rooms.length === 0 && (
                  <p style={{ color: '#888', fontSize: '0.9em', padding: '8px 0' }}>No hay habitaciones creadas.</p>
                )}
              </div>
            </div>

            <button type="submit" className="btn btn-primary" style={{ width: '100%', marginTop: '16px' }} disabled={rooms.length === 0}>
              Crear Promoción
            </button>
          </form>
        </div>

        {/* Promotions List */}
        <div>
          <h3 style={{ marginBottom: '24px' }}>Promociones Activas</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {promotions.length > 0 ? (
              promotions.map(promo => {
                const isAllRooms = promo.habitacionesAplicables?.length === rooms.length && rooms.length > 0;
                
                return (
                <div key={promo.id} className="card" style={{ padding: '20px', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                  <div style={{ width: '100%', paddingRight: '16px' }}>
                    <h4 style={{ fontSize: '1.2rem', display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--primary-dark)' }}>
                      <Tag size={18} color="var(--primary-color)"/>
                      {promo.title}
                      <span style={{ backgroundColor: 'rgba(27,81,51,0.1)', color: 'var(--primary-color)', padding: '2px 8px', borderRadius: '12px', fontSize: '0.8rem', fontWeight: 'bold' }}>
                        -{promo.discount}%
                      </span>
                    </h4>
                    <p style={{ color: 'var(--text-secondary)', margin: '8px 0' }}>{promo.description}</p>
                    
                    <div style={{ backgroundColor: '#f9f9f9', padding: '12px', borderRadius: '8px', marginTop: '12px' }}>
                      <p style={{ fontSize: '0.85rem', fontWeight: 600, marginBottom: '8px' }}>Habitaciones que aplican:</p>
                      <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
                        {isAllRooms ? (
                          <span style={{ fontSize: '0.8rem', backgroundColor: '#e2f0e9', color: '#1B5133', padding: '4px 8px', borderRadius: '4px' }}>
                            Todas las habitaciones
                          </span>
                        ) : (
                          promo.habitacionesAplicables?.map(roomId => {
                            const roomObj = rooms.find(r => r.id === roomId);
                            const roomName = roomObj?.tipo || 'Habitación eliminada';
                            const roomImg = roomObj?.imagenes && roomObj.imagenes.length > 0 ? roomObj.imagenes[0] : null;
                            
                            return (
                              <div key={roomId} style={{ display: 'flex', alignItems: 'center', gap: '6px', backgroundColor: '#e2f0e9', padding: '4px 8px', borderRadius: '4px' }}>
                                {roomImg && <img src={roomImg} alt={roomName} style={{ width: '20px', height: '20px', borderRadius: '2px', objectFit: 'cover' }} />}
                                <span style={{ fontSize: '0.8rem', color: '#1B5133' }}>
                                  {roomName}
                                </span>
                              </div>
                            )
                          })
                        )}
                        {(!promo.habitacionesAplicables || promo.habitacionesAplicables.length === 0) && (
                          <span style={{ fontSize: '0.8rem', color: '#888' }}>Ninguna</span>
                        )}
                      </div>
                    </div>
                    
                    <p style={{ fontSize: '0.85rem', fontWeight: 600, marginTop: '12px' }}>Expira: {promo.expiryDate}</p>
                  </div>
                  <button 
                    onClick={() => deletePromotion(promo.id)}
                    className="btn btn-outline" 
                    style={{ padding: '8px', borderColor: '#e74c3c', color: '#e74c3c', flexShrink: 0 }}
                    title="Eliminar Promoción"
                  >
                    <Trash2 size={18} />
                  </button>
                </div>
              )})
            ) : (
              <div className="card" style={{ padding: '40px', textAlign: 'center', color: 'var(--text-secondary)' }}>
                <Tag size={48} style={{ opacity: 0.2, margin: '0 auto 16px auto' }} />
                <p>No hay promociones activas.</p>
                <p style={{ fontSize: '0.9rem' }}>Usa el formulario para crear una nueva.</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default PromotionsManager;

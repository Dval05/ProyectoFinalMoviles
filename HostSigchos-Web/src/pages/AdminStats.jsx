import React, { useMemo } from 'react';
import { TrendingUp, DollarSign, Activity, Award } from 'lucide-react';
import { useAppContext } from '../context/AppContext';

const AdminStats = () => {
  const { allReservations, allHosterias } = useAppContext();

  const statsData = useMemo(() => {
    let totalIngresos = 0;
    let ingresosConfirmados = 0;
    
    // Agrupar ingresos por hostería
    const ingresosPorHosteria = {};
    
    // Agrupar ingresos por mes (simplificado)
    const ingresosPorMes = {
      'Ene': 0, 'Feb': 0, 'Mar': 0, 'Abr': 0, 'May': 0, 'Jun': 0,
      'Jul': 0, 'Ago': 0, 'Sep': 0, 'Oct': 0, 'Nov': 0, 'Dic': 0
    };

    allReservations.forEach(res => {
      const total = Number.parseFloat(res.precioTotal) || 0;
      totalIngresos += total;
      
      const estado = (res.estado || '').toLowerCase();
      if (estado === 'confirmada') {
        ingresosConfirmados += total;
      }
      
      // Hostería stats
      if (res.hosteriaId) {
        if (!ingresosPorHosteria[res.hosteriaId]) {
          ingresosPorHosteria[res.hosteriaId] = 0;
        }
        ingresosPorHosteria[res.hosteriaId] += total;
      }

      // Mes stats (aproximado usando fechaCreacion)
      if (res.fechaCreacion) {
        const dateObj = res.fechaCreacion.toDate ? res.fechaCreacion.toDate() : new Date(res.fechaCreacion);
        if (!Number.isNaN(dateObj.valueOf())) {
          const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
          const mesStr = meses[dateObj.getMonth()];
          ingresosPorMes[mesStr] += total;
        }
      }
    });

    // Top Hosterias por ingresos
    const topHosterias = Object.keys(ingresosPorHosteria)
      .map(id => {
        const hosteria = allHosterias.find(h => h.id === id);
        return {
          nombre: hosteria ? hosteria.nombre : 'Desconocida',
          ingresos: ingresosPorHosteria[id]
        };
      })
      .sort((a, b) => b.ingresos - a.ingresos)
      .slice(0, 5);

    // Max mensual para gráfico
    const maxMes = Math.max(...Object.values(ingresosPorMes), 1);

    return {
      totalIngresos,
      ingresosConfirmados,
      topHosterias,
      ingresosPorMes,
      maxMes
    };
  }, [allReservations, allHosterias]);

  const getBadgeColor = (index) => {
    if (index === 0) return '#f1c40f'; // Oro
    if (index === 1) return '#bdc3c7'; // Plata
    if (index === 2) return '#cd7f32'; // Bronce
    return 'var(--primary-color)';
  };

  return (
    <div className="animate-fade-in">
      <header className="dashboard-topbar">
        <div>
          <h1 className="page-title">Módulo de Estadísticas y Finanzas</h1>
          <p className="page-subtitle">Análisis detallado de ingresos y rendimiento global del sistema.</p>
        </div>
      </header>

      {/* KPI Cards */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '20px', marginTop: '24px' }}>
        <div className="card" style={{ padding: '24px', borderLeft: '4px solid #2ecc71' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div>
              <h4 style={{ margin: 0, color: 'var(--text-secondary)', fontSize: '0.9rem' }}>Ingresos Totales (Confirmados)</h4>
              <h2 style={{ margin: '8px 0 0 0', fontSize: '2.5rem', color: '#2c3e50' }}>${statsData.ingresosConfirmados.toFixed(2)}</h2>
            </div>
            <div style={{ padding: '16px', backgroundColor: 'rgba(46, 204, 113, 0.1)', borderRadius: '50%', color: '#2ecc71' }}>
              <DollarSign size={28} />
            </div>
          </div>
        </div>
        
        <div className="card" style={{ padding: '24px', borderLeft: '4px solid #3498db' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div>
              <h4 style={{ margin: 0, color: 'var(--text-secondary)', fontSize: '0.9rem' }}>Volumen Bruto (Todas las Reservas)</h4>
              <h2 style={{ margin: '8px 0 0 0', fontSize: '2.5rem', color: '#2c3e50' }}>${statsData.totalIngresos.toFixed(2)}</h2>
            </div>
            <div style={{ padding: '16px', backgroundColor: 'rgba(52, 152, 219, 0.1)', borderRadius: '50%', color: '#3498db' }}>
              <TrendingUp size={28} />
            </div>
          </div>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '24px', marginTop: '24px' }}>
        {/* Gráfico de Barras Mensual (CSS puro) */}
        <div className="card" style={{ padding: '24px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '24px' }}>
            <Activity size={20} color="var(--primary-color)" />
            <h3 style={{ margin: 0 }}>Tendencia de Ingresos Mensuales</h3>
          </div>
          
          <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', height: '250px', gap: '8px', paddingBottom: '10px', borderBottom: '1px solid #eee' }}>
            {Object.keys(statsData.ingresosPorMes).map(mes => {
              const valor = statsData.ingresosPorMes[mes];
              const heightPercent = valor > 0 ? (valor / statsData.maxMes) * 100 : 2; // minimo 2% para ver la barra
              return (
                <div key={mes} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', flex: 1, gap: '8px' }}>
                  <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', fontWeight: 'bold' }}>
                    {valor > 0 ? `$${valor.toFixed(0)}` : ''}
                  </div>
                  <div 
                    style={{ 
                      width: '100%', 
                      maxWidth: '40px', 
                      height: `${heightPercent}%`, 
                      backgroundColor: valor > 0 ? 'var(--primary-color)' : '#f0f0f0',
                      borderRadius: '4px 4px 0 0',
                      transition: 'height 0.5s ease'
                    }} 
                    title={`$${valor.toFixed(2)}`}
                  />
                  <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>{mes}</div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Top Hosterias */}
        <div className="card" style={{ padding: '24px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '24px' }}>
            <Award size={20} color="#f39c12" />
            <h3 style={{ margin: 0 }}>Top 5 Hosterías (Ganancias)</h3>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {statsData.topHosterias.length > 0 ? (
              statsData.topHosterias.map((hosteria, index) => (
                <div key={hosteria.nombre || index} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px', backgroundColor: '#f9f9f9', borderRadius: '8px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                    <div style={{ width: '28px', height: '28px', borderRadius: '50%', backgroundColor: getBadgeColor(index), color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold', fontSize: '0.85rem' }}>
                      {index + 1}
                    </div>
                    <span style={{ fontWeight: '500' }}>{hosteria.nombre}</span>
                  </div>
                  <span style={{ fontWeight: 'bold', color: '#2ecc71' }}>${hosteria.ingresos.toFixed(2)}</span>
                </div>
              ))
            ) : (
              <p style={{ textAlign: 'center', color: 'var(--text-secondary)' }}>No hay datos suficientes.</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default AdminStats;

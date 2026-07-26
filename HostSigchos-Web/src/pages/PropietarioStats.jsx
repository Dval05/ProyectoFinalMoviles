import React, { useMemo } from 'react';
import { TrendingUp, DollarSign, Activity } from 'lucide-react';
import { useAppContext } from '../context/AppContext';

const PropietarioStats = () => {
  const { reservations } = useAppContext();

  const statsData = useMemo(() => {
    let totalIngresos = 0;
    let ingresosConfirmados = 0;
    
    // Agrupar ingresos por mes (simplificado)
    const ingresosPorMes = {
      'Ene': 0, 'Feb': 0, 'Mar': 0, 'Abr': 0, 'May': 0, 'Jun': 0,
      'Jul': 0, 'Ago': 0, 'Sep': 0, 'Oct': 0, 'Nov': 0, 'Dic': 0
    };

    reservations.forEach(res => {
      const total = Number.parseFloat(res.precioTotal) || 0;
      totalIngresos += total;
      
      const estado = (res.estado || '').toLowerCase();
      if (estado === 'confirmada') {
        ingresosConfirmados += total;
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

    // Max mensual para gráfico
    const maxMes = Math.max(...Object.values(ingresosPorMes), 1);

    return {
      totalIngresos,
      ingresosConfirmados,
      ingresosPorMes,
      maxMes
    };
  }, [reservations]);

  return (
    <div className="animate-fade-in">
      <header className="dashboard-topbar">
        <div>
          <h1 className="page-title">Estadísticas de mi Hostería</h1>
          <p className="page-subtitle">Análisis detallado de tus ingresos y reservas.</p>
        </div>
      </header>

      {/* KPI Cards */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '20px', marginTop: '24px' }}>
        <div className="card" style={{ padding: '24px', borderLeft: '4px solid #2ecc71' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div>
              <h4 style={{ margin: 0, color: 'var(--text-secondary)', fontSize: '0.9rem' }}>Ingresos Confirmados</h4>
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
              <h4 style={{ margin: 0, color: 'var(--text-secondary)', fontSize: '0.9rem' }}>Volumen Bruto (Todas)</h4>
              <h2 style={{ margin: '8px 0 0 0', fontSize: '2.5rem', color: '#2c3e50' }}>${statsData.totalIngresos.toFixed(2)}</h2>
            </div>
            <div style={{ padding: '16px', backgroundColor: 'rgba(52, 152, 219, 0.1)', borderRadius: '50%', color: '#3498db' }}>
              <TrendingUp size={28} />
            </div>
          </div>
        </div>
      </div>

      <div style={{ marginTop: '24px' }}>
        {/* Gráfico de Barras Mensual (CSS puro) */}
        <div className="card" style={{ padding: '24px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '24px' }}>
            <Activity size={20} color="var(--primary-color)" />
            <h3 style={{ margin: 0 }}>Tendencia de Ingresos Mensuales</h3>
          </div>
          
          <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', height: '300px', gap: '8px', paddingBottom: '10px', borderBottom: '1px solid #eee' }}>
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
                      maxWidth: '50px', 
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
      </div>
    </div>
  );
};

export default PropietarioStats;

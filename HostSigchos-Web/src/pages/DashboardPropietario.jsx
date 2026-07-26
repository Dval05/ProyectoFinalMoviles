import React from 'react';
import { NavLink, Outlet, useNavigate } from 'react-router-dom';
import { Home, Calendar, Users, Settings, LogOut, BedDouble, Tag, BarChart2 } from 'lucide-react';
import { useAppContext } from '../context/AppContext';
import logoUrl from '../assets/logo.png';
import './Dashboard.css';

const DashboardPropietario = () => {
  const navigate = useNavigate();
  const { logout } = useAppContext();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <div className="dashboard-layout animate-fade-in">
      {/* Sidebar */}
      <aside className="sidebar">
        <div className="sidebar-header" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '8px' }}>
          <img src={logoUrl} alt="HostSigchos Logo" style={{ height: '48px', objectFit: 'contain' }} />
          <h2 style={{ fontSize: '1.4rem', margin: 0 }}>HostSigchos</h2>
          <p className="role-badge">Portal de Gestión</p>
        </div>
        <nav className="sidebar-nav">
          <NavLink to="/dashboard" end className={({ isActive }) => isActive ? "nav-item active" : "nav-item"}>
            <Home size={20}/> Inicio
          </NavLink>
          <NavLink to="/dashboard/habitaciones" className={({ isActive }) => isActive ? "nav-item active" : "nav-item"}>
            <BedDouble size={20}/> Habitaciones
          </NavLink>
          <NavLink to="/dashboard/reservas" className={({ isActive }) => isActive ? "nav-item active" : "nav-item"}>
            <Calendar size={20}/> Reservas
          </NavLink>
          <NavLink to="/dashboard/promociones" className={({ isActive }) => isActive ? "nav-item active" : "nav-item"}>
            <Tag size={20}/> Promociones
          </NavLink>
          <NavLink to="/dashboard/clientes" className={({ isActive }) => isActive ? "nav-item active" : "nav-item"}>
            <Users size={20}/> Clientes
          </NavLink>
          <NavLink to="/dashboard/estadisticas" className={({ isActive }) => isActive ? "nav-item active" : "nav-item"}>
            <BarChart2 size={20}/> Estadísticas
          </NavLink>
          <NavLink to="/dashboard/configuracion" className={({ isActive }) => isActive ? "nav-item active" : "nav-item"}>
            <Settings size={20}/> Configuración
          </NavLink>
        </nav>
        <div className="sidebar-footer">
          <button onClick={handleLogout} className="btn-logout">
            <LogOut size={20}/> Cerrar Sesión
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <main className="dashboard-content">
        <Outlet />
      </main>
    </div>
  );
};

export default DashboardPropietario;

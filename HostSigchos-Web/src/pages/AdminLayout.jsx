import React from 'react';
import { NavLink, Outlet, useNavigate } from 'react-router-dom';
import { Home, LogOut, ShieldAlert, Building, Calendar, Users, BarChart2 } from 'lucide-react';
import { useAppContext } from '../context/AppContext';
import './Dashboard.css';

const AdminLayout = () => {
  const navigate = useNavigate();
  const { logout, isSuperAdmin } = useAppContext();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <div className="dashboard-layout animate-fade-in">
      {/* Sidebar */}
      <aside className="sidebar">
        <div className="sidebar-header">
          <h2>HostSigchos</h2>
          <p className="role-badge" style={{ backgroundColor: '#e74c3c', color: '#fff' }}>Admin Global</p>
        </div>
        <nav className="sidebar-nav">
          <NavLink to="/admin" end className={({ isActive }) => isActive ? "nav-item active" : "nav-item"}>
            <Home size={20}/> Vista General
          </NavLink>
          
          <NavLink to="/admin/hosterias" className={({ isActive }) => isActive ? "nav-item active" : "nav-item"}>
            <Building size={20}/> Hosterías
          </NavLink>
          
          <NavLink to="/admin/reservas" className={({ isActive }) => isActive ? "nav-item active" : "nav-item"}>
            <Calendar size={20}/> Reservas
          </NavLink>
          
          <NavLink to="/admin/usuarios" className={({ isActive }) => isActive ? "nav-item active" : "nav-item"}>
            <Users size={20}/> Usuarios
          </NavLink>
          
          <NavLink to="/admin/estadisticas" className={({ isActive }) => isActive ? "nav-item active" : "nav-item"}>
            <BarChart2 size={20}/> Estadísticas
          </NavLink>
          
          {isSuperAdmin && (
            <NavLink to="/admin/administradores" className={({ isActive }) => isActive ? "nav-item active" : "nav-item"}>
              <ShieldAlert size={20}/> Admins
            </NavLink>
          )}
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

export default AdminLayout;

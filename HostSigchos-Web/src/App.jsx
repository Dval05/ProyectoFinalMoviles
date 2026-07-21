import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import PropTypes from 'prop-types';
import { AppProvider, useAppContext } from './context/AppContext';
import LandingPage from './pages/LandingPage';
import LoginPage from './pages/LoginPage';
import DashboardPropietario from './pages/DashboardPropietario';
import DashboardInicio from './pages/DashboardInicio';
import RoomsManager from './pages/RoomsManager';
import ReservationsManager from './pages/ReservationsManager';
import PromotionsManager from './pages/PromotionsManager';
import ClientsManager from './pages/ClientsManager';
import SettingsManager from './pages/SettingsManager';
import AdminLayout from './pages/AdminLayout';
import SystemAdminDashboard from './pages/SystemAdminDashboard';
import ManageAdmins from './pages/ManageAdmins';
import AdminHosterias from './pages/AdminHosterias';
import AdminReservations from './pages/AdminReservations';
import AdminUsers from './pages/AdminUsers';
import AdminStats from './pages/AdminStats';

// Protected Route Component
const ProtectedRoute = ({ children }) => {
  const { user } = useAppContext();
  if (!user) {
    return <Navigate to="/login" replace />;
  }
  return children;
};
ProtectedRoute.propTypes = {
  children: PropTypes.node.isRequired,
};

const AdminRoute = ({ children }) => {
  const { user, role } = useAppContext();
  if (!user || role !== 'admin') {
    return <Navigate to="/login" replace />;
  }
  return children;
};
AdminRoute.propTypes = {
  children: PropTypes.node.isRequired,
};

function AppRoutes() {
  return (
    <Routes>
      <Route path="/" element={<LandingPage />} />
      <Route path="/login" element={<LoginPage />} />
      <Route 
        path="/dashboard" 
        element={
          <ProtectedRoute>
            <DashboardPropietario />
          </ProtectedRoute>
        }
      >
        <Route index element={<DashboardInicio />} />
        <Route path="habitaciones" element={<RoomsManager />} />
        <Route path="reservas" element={<ReservationsManager />} />
        <Route path="promociones" element={<PromotionsManager />} />
        <Route path="clientes" element={<ClientsManager />} />
        <Route path="configuracion" element={<SettingsManager />} />
      </Route>
      <Route 
        path="/admin" 
        element={
          <AdminRoute>
            <AdminLayout />
          </AdminRoute>
        }
      >
        <Route index element={<SystemAdminDashboard />} />
        <Route path="hosterias" element={<AdminHosterias />} />
        <Route path="reservas" element={<AdminReservations />} />
        <Route path="usuarios" element={<AdminUsers />} />
        <Route path="estadisticas" element={<AdminStats />} />
        <Route path="administradores" element={<ManageAdmins />} />
      </Route>
    </Routes>
  );
}

function App() {
  return (
    <AppProvider>
      <Router>
        <div className="app-layout">
          <main className="main-content">
            <AppRoutes />
          </main>
        </div>
      </Router>
    </AppProvider>
  );
}

export default App;

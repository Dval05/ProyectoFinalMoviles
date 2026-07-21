import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Mail, Lock, ArrowLeft, AlertCircle } from 'lucide-react';
import { useAppContext } from '../context/AppContext';
import './LoginPage.css';

const LoginPage = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  const { login, user, role } = useAppContext();

  // If already logged in, redirect
  useEffect(() => {
    if (user) {
      if (role === 'admin') {
        navigate('/admin');
      } else {
        navigate('/dashboard');
      }
    }
  }, [user, role, navigate]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    
    const result = await login(email, password);
    if (result.success) {
      if (result.role === 'admin') {
        navigate('/admin');
      } else {
        navigate('/dashboard');
      }
    } else {
      setError(result.error || 'Ocurrió un error al iniciar sesión.');
    }
    
    setLoading(false);
  };

  return (
    <div className="login-page animate-fade-in">
      <div className="login-container container">
        <div className="login-card glass-panel">
          <Link to="/" className="back-link">
            <ArrowLeft size={20} /> Volver
          </Link>
          
          <div className="login-header">
            <h2>Portal Propietario</h2>
            <p>Ingresa para administrar tu hostería</p>
          </div>

          {error && (
            <div className="error-message" style={{ color: '#dc3545', display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '16px', padding: '10px', backgroundColor: 'rgba(220,53,69,0.1)', borderRadius: '8px' }}>
              <AlertCircle size={16} />
              <span>{error}</span>
            </div>
          )}

          <form onSubmit={handleSubmit} className="login-form">
            <div className="input-group">
              <label htmlFor="email" className="input-label">Correo Electrónico</label>
              <div className="input-with-icon">
                <Mail className="input-icon" size={20} />
                <input 
                  id="email"
                  type="email" 
                  className="input-field" 
                  placeholder="Ej: propietario@hosteria.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                />
              </div>
            </div>

            <div className="input-group">
              <label htmlFor="password" className="input-label">
                Contraseña
              </label>
              <div className="input-with-icon">
                <Lock className="input-icon" size={20} />
                <input 
                  id="password"
                  type="password" 
                  className="input-field" 
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                />
              </div>
            </div>

            <div className="form-actions">
              <button type="button" className="forgot-password">¿Olvidaste tu contraseña?</button>
            </div>

            <button type="submit" className="btn btn-primary login-btn" disabled={loading}>
              {loading ? "Iniciando sesión..." : "Iniciar Sesión"}
            </button>
          </form>

          <div className="login-footer">
            <p>¿No tienes una cuenta? Contacta con el administrador.</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;

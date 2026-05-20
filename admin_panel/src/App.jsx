import React, { useState, useEffect } from 'react';
import {
  LayoutDashboard,
  Users,
  ShoppingBag,
  PlusCircle,
  LogOut,
  ShieldCheck,
  ChevronRight,
  ChevronDown,
  DollarSign,
  TrendingUp,
  ShoppingCart,
  Plus,
  Trash2,
  MapPin,
  RefreshCw,
  Lock,
  Phone
} from 'lucide-react';

const API_BASE = 'http://localhost:5000/api';

export default function App() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [token, setToken] = useState(localStorage.getItem('admin_token') || '');
  const [adminUser, setAdminUser] = useState(JSON.parse(localStorage.getItem('admin_user') || 'null'));

  // Login form state
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');

  // Notification state
  const [alert, setAlert] = useState({ type: '', message: '' });
  const [loading, setLoading] = useState(false);

  // Data states
  const [statsData, setStatsData] = useState(null);
  const [vendors, setVendors] = useState([]);
  const [orders, setOrders] = useState([]);
  const [products, setProducts] = useState([]);
  const [categories, setCategories] = useState([]);

  // UI states
  const [searchQuery, setSearchQuery] = useState('');
  const [expandedOrders, setExpandedOrders] = useState({});
  const [newCategoryName, setNewCategoryName] = useState('');
  const [newCategoryImg, setNewCategoryImg] = useState('');

  const showToast = (type, message) => {
    setAlert({ type, message });
    setTimeout(() => setAlert({ type: '', message: '' }), 4000);
  };

  const isAuthenticated = !!(token && adminUser && adminUser.role === 'admin');

  const apiCall = async (endpoint, options = {}) => {
    const headers = {
      'Content-Type': 'application/json',
      ...(token ? { 'Authorization': `Bearer ${token}` } : {})
    };
    const response = await fetch(`${API_BASE}${endpoint}`, {
      ...options,
      headers: { ...headers, ...(options.headers || {}) }
    });
    const data = await response.json();
    if (!response.ok) throw new Error(data.message || 'Request failed');
    return data;
  };

  const refreshData = async () => {
    if (!isAuthenticated) return;
    setLoading(true);
    try {
      if (activeTab === 'dashboard') {
        const res = await apiCall('/admin/stats');
        setStatsData(res);
      } else if (activeTab === 'vendors') {
        const res = await apiCall('/admin/vendors');
        setVendors(res.vendors || []);
      } else if (activeTab === 'orders') {
        const res = await apiCall('/admin/orders');
        setOrders(res.orders || []);
      } else if (activeTab === 'products') {
        const res = await apiCall('/admin/products');
        setProducts(res.products || []);
      } else if (activeTab === 'categories') {
        const res = await apiCall('/categories');
        setCategories(res.categories || []);
      }
    } catch (err) {
      showToast('danger', err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { refreshData(); }, [activeTab, token]);

  // SECURE LOGIN — Phone + Password only
  const handleLogin = async (e) => {
    e.preventDefault();
    if (!phone || phone.length < 10) return showToast('warning', 'Enter a valid 10-digit phone number');
    if (!password) return showToast('warning', 'Password is required');
    setLoading(true);
    try {
      const res = await apiCall('/admin/login', {
        method: 'POST',
        body: JSON.stringify({ phone, password })
      });
      localStorage.setItem('admin_token', res.token);
      localStorage.setItem('admin_user', JSON.stringify(res.user));
      setToken(res.token);
      setAdminUser(res.user);
      showToast('success', 'Welcome to the Admin Panel!');
    } catch (err) {
      showToast('danger', err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('admin_token');
    localStorage.removeItem('admin_user');
    setToken('');
    setAdminUser(null);
    setPhone('');
    setPassword('');
  };

  // Vendor actions
  const handleVendorApproval = async (vendorId, approve) => {
    try {
      const res = await apiCall(`/admin/vendors/${vendorId}/approve`, {
        method: 'PUT',
        body: JSON.stringify({ isApproved: approve })
      });
      showToast('success', res.message);
      setVendors(v => v.map(x => x._id === vendorId ? { ...x, isApproved: approve } : x));
    } catch (err) { showToast('danger', err.message); }
  };

  // Order status update
  const handleUpdateOrderStatus = async (orderId, newStatus) => {
    try {
      await apiCall(`/admin/orders/${orderId}/status`, {
        method: 'PUT',
        body: JSON.stringify({ orderStatus: newStatus })
      });
      showToast('success', 'Order status updated');
      setOrders(o => o.map(x => x._id === orderId ? { ...x, orderStatus: newStatus } : x));
    } catch (err) { showToast('danger', err.message); }
  };

  // Delete product
  const handleDeleteProduct = async (productId) => {
    if (!window.confirm('Delete this product from the global catalog?')) return;
    try {
      const res = await apiCall(`/admin/products/${productId}`, { method: 'DELETE' });
      showToast('success', res.message);
      setProducts(p => p.filter(x => x._id !== productId));
    } catch (err) { showToast('danger', err.message); }
  };

  // Add category
  const handleAddCategory = async (e) => {
    e.preventDefault();
    if (!newCategoryName) return showToast('warning', 'Category name is required');
    setLoading(true);
    try {
      const res = await apiCall('/admin/categories', {
        method: 'POST',
        body: JSON.stringify({ name: newCategoryName, image: newCategoryImg || '' })
      });
      showToast('success', res.message);
      setCategories(c => [...c, res.category]);
      setNewCategoryName('');
      setNewCategoryImg('');
    } catch (err) { showToast('danger', err.message); }
    finally { setLoading(false); }
  };

  // Delete category
  const handleDeleteCategory = async (catId) => {
    if (!window.confirm('Delete this category?')) return;
    try {
      const res = await apiCall(`/admin/categories/${catId}`, { method: 'DELETE' });
      showToast('success', res.message);
      setCategories(c => c.filter(x => x._id !== catId));
    } catch (err) { showToast('danger', err.message); }
  };

  const toggleOrderExpand = (id) => setExpandedOrders(prev => ({ ...prev, [id]: !prev[id] }));

  // Toast Component
  const Toast = () => alert.message ? (
    <div style={{
      position: 'fixed', top: '20px', right: '20px', zIndex: 9999,
      padding: '14px 20px', borderRadius: '12px', color: 'white',
      fontWeight: '600', fontSize: '14px', boxShadow: '0 4px 20px rgba(0,0,0,0.4)',
      backgroundColor: alert.type === 'success' ? '#10b981' : alert.type === 'warning' ? '#f59e0b' : '#ef4444',
      maxWidth: '360px', lineHeight: '1.4'
    }}>
      {alert.message}
    </div>
  ) : null;

  // ─────────────────────────────────────────────
  // LOGIN SCREEN
  // ─────────────────────────────────────────────
  if (!isAuthenticated) {
    return (
      <div className="login-container">
        <Toast />
        <div className="login-card glass-panel">
          <div className="login-header">
            <div style={{
              display: 'inline-flex', padding: '18px',
              background: 'var(--primary-glow)', color: 'var(--primary)',
              borderRadius: '50%', marginBottom: '8px'
            }}>
              <ShieldCheck size={40} />
            </div>
            <h1 className="login-title">RiFresh Admin</h1>
            <p className="login-subtitle">Secure administration portal — authorized access only</p>
          </div>

          <form onSubmit={handleLogin}>
            <div className="form-group">
              <label className="form-label">Admin Phone Number</label>
              <div style={{ position: 'relative' }}>
                <span style={{
                  position: 'absolute', left: '14px', top: '50%',
                  transform: 'translateY(-50%)', color: 'var(--text-muted)'
                }}>
                  <Phone size={16} />
                </span>
                <input
                  type="tel"
                  placeholder="10-digit registered number"
                  className="input-field"
                  style={{ paddingLeft: '40px' }}
                  value={phone}
                  onChange={e => setPhone(e.target.value.replace(/\D/g, '').slice(0, 10))}
                  disabled={loading}
                  autoComplete="off"
                />
              </div>
            </div>

            <div className="form-group">
              <label className="form-label">Admin Password</label>
              <div style={{ position: 'relative' }}>
                <span style={{
                  position: 'absolute', left: '14px', top: '50%',
                  transform: 'translateY(-50%)', color: 'var(--text-muted)'
                }}>
                  <Lock size={16} />
                </span>
                <input
                  type="password"
                  placeholder="Enter your admin password"
                  className="input-field"
                  style={{ paddingLeft: '40px' }}
                  value={password}
                  onChange={e => setPassword(e.target.value)}
                  disabled={loading}
                  autoComplete="current-password"
                />
              </div>
            </div>

            <button type="submit" className="btn btn-primary" disabled={loading}>
              {loading ? 'Authenticating...' : 'Login to Admin Panel'}
            </button>
          </form>

          <p style={{
            textAlign: 'center', marginTop: '24px', fontSize: '12px',
            color: 'var(--text-muted)', lineHeight: '1.6'
          }}>
            🔒 This portal is restricted to authorized administrators only.<br />
            Unauthorized access attempts are logged and monitored.
          </p>
        </div>
      </div>
    );
  }

  // ─────────────────────────────────────────────
  // MAIN DASHBOARD LAYOUT
  // ─────────────────────────────────────────────
  return (
    <div className="app-container">
      <Toast />

      {/* SIDEBAR */}
      <aside className="sidebar">
        <div className="sidebar-brand">
          <div className="sidebar-logo">
            <ShieldCheck size={26} />
            <span>RiFresh Admin</span>
          </div>
        </div>

        <ul className="sidebar-menu">
          {[
            { id: 'dashboard', icon: <LayoutDashboard size={20} />, label: 'Dashboard' },
            { id: 'vendors',   icon: <Users size={20} />,           label: 'Vendors' },
            { id: 'orders',    icon: <ShoppingCart size={20} />,    label: 'Orders' },
            { id: 'products',  icon: <ShoppingBag size={20} />,     label: 'Products' },
            { id: 'categories',icon: <PlusCircle size={20} />,      label: 'Categories' },
          ].map(item => (
            <li key={item.id}>
              <div
                className={`sidebar-item ${activeTab === item.id ? 'active' : ''}`}
                onClick={() => { setActiveTab(item.id); setSearchQuery(''); }}
              >
                {item.icon}
                <span>{item.label}</span>
              </div>
            </li>
          ))}
        </ul>

        <div className="sidebar-profile">
          <div className="avatar">
            {(adminUser?.name || 'A').charAt(0).toUpperCase()}
          </div>
          <div className="profile-info">
            <div className="profile-name">{adminUser?.name || 'Administrator'}</div>
            <div className="profile-role">{adminUser?.phone}</div>
          </div>
          <button className="logout-btn" onClick={handleLogout} title="Log Out">
            <LogOut size={20} />
          </button>
        </div>
      </aside>

      {/* MAIN CONTENT */}
      <main className="main-wrapper">
        <header className="top-bar">
          <h1 className="page-title" style={{ textTransform: 'capitalize' }}>
            {activeTab === 'dashboard' ? 'Dashboard Overview' :
             activeTab === 'vendors' ? 'Vendor Management' :
             activeTab === 'orders' ? 'Order Processing' :
             activeTab === 'products' ? 'Product Catalog' : 'Category Manager'}
          </h1>
          <div className="top-actions">
            <button
              onClick={refreshData}
              className="btn btn-outline"
              style={{ padding: '8px 14px', width: 'auto', fontSize: '13px', gap: '6px' }}
              disabled={loading}
            >
              <RefreshCw size={14} style={loading ? { animation: 'spin 1s linear infinite' } : {}} />
              Refresh
            </button>
            <div className="live-indicator">
              <span className="pulse-dot"></span>
              Live
            </div>
          </div>
        </header>

        <div className="content-container">
          {loading && (
            <div className="spinner-container" style={{ minHeight: '400px' }}>
              <div className="spinner"></div>
              <p style={{ color: 'var(--text-secondary)', marginTop: '12px' }}>Loading data...</p>
            </div>
          )}

          {!loading && (
            <>
              {/* ── DASHBOARD ── */}
              {activeTab === 'dashboard' && statsData && (
                <div>
                  <div className="stats-grid">
                    {[
                      { label: 'Total Revenue', value: `₹${(statsData.stats?.totalRevenue || 0).toLocaleString('en-IN')}`, icon: <DollarSign size={22}/>, color: '#10b981', bg: 'rgba(16,185,129,0.1)', sub: 'From delivered orders' },
                      { label: 'Total Orders', value: statsData.stats?.totalOrders || 0, icon: <ShoppingCart size={22}/>, color: '#6366f1', bg: 'rgba(99,102,241,0.1)', sub: 'All customer placements' },
                      { label: 'Active Vendors', value: statsData.stats?.totalVendors || 0, icon: <Users size={22}/>, color: '#f59e0b', bg: 'rgba(245,158,11,0.1)', sub: 'Registered farmers' },
                      { label: 'Products Listed', value: statsData.stats?.totalProducts || 0, icon: <ShoppingBag size={22}/>, color: '#3b82f6', bg: 'rgba(59,130,246,0.1)', sub: 'Live catalog size' },
                    ].map((s, i) => (
                      <div className="glass-card" key={i}>
                        <div className="stat-icon" style={{ background: s.bg, color: s.color }}>{s.icon}</div>
                        <div className="stat-value">{s.value}</div>
                        <div className="stat-label">{s.label}</div>
                        <div style={{ fontSize: '11px', color: s.color, marginTop: '6px', fontWeight: 600 }}>{s.sub}</div>
                      </div>
                    ))}
                  </div>

                  <div className="dashboard-grid">
                    {/* SVG Donut Chart */}
                    <div className="glass-card">
                      <div className="section-header">
                        <h2 className="section-title">Order Status Distribution</h2>
                      </div>
                      <div className="chart-container" style={{ flexDirection: 'row', gap: '32px', justifyContent: 'flex-start', padding: '8px 20px' }}>
                        {(() => {
                          const dist = statsData.stats?.orderStatusDistribution || {};
                          const total = Object.values(dist).reduce((a, b) => a + b, 0) || 1;
                          const segments = [
                            { percent: ((dist.delivered||0)/total)*100, color: '#10b981', label: 'Delivered', val: dist.delivered||0 },
                            { percent: ((dist.pending||0)/total)*100,   color: '#f59e0b', label: 'Pending',   val: dist.pending||0 },
                            { percent: (((dist.accepted||0)+(dist.packed||0)+(dist.out_for_delivery||0))/total)*100, color: '#3b82f6', label: 'Processing', val: (dist.accepted||0)+(dist.packed||0)+(dist.out_for_delivery||0) },
                            { percent: ((dist.cancelled||0)/total)*100, color: '#ef4444', label: 'Cancelled', val: dist.cancelled||0 },
                          ];
                          let offset = 0;
                          return (
                            <>
                              <svg width="180" height="180" viewBox="0 0 42 42" style={{ transform: 'rotate(-90deg)', flexShrink: 0 }}>
                                <circle cx="21" cy="21" r="15.9" fill="transparent" stroke="rgba(255,255,255,0.03)" strokeWidth="5"/>
                                {segments.map((seg, idx) => {
                                  if (seg.percent === 0) return null;
                                  const dash = `${seg.percent} ${100 - seg.percent}`;
                                  const off = 100 - offset;
                                  offset += seg.percent;
                                  return <circle key={idx} cx="21" cy="21" r="15.9" fill="transparent" stroke={seg.color} strokeWidth="5" strokeDasharray={dash} strokeDashoffset={off}/>;
                                })}
                                <text x="21" y="22" textAnchor="middle" fill="white" fontSize="5" fontWeight="bold" style={{ transform: 'rotate(90deg)', transformOrigin: '50% 50%' }}>{total}</text>
                              </svg>
                              <div style={{ display: 'flex', flexDirection: 'column', gap: '10px', justifyContent: 'center' }}>
                                {segments.map((s, i) => (
                                  <div key={i} style={{ display: 'flex', alignItems: 'center', gap: '10px', fontSize: '13px' }}>
                                    <span style={{ width: '10px', height: '10px', borderRadius: '50%', background: s.color, flexShrink: 0 }}/>
                                    <span style={{ color: 'var(--text-secondary)' }}>{s.label}</span>
                                    <strong style={{ color: 'white', marginLeft: 'auto' }}>{s.val} <span style={{ color: 'var(--text-muted)', fontWeight: 400 }}>({Math.round((s.val/total)*100)}%)</span></strong>
                                  </div>
                                ))}
                              </div>
                            </>
                          );
                        })()}
                      </div>
                    </div>

                    {/* Recent vendor applications */}
                    <div className="glass-card">
                      <div className="section-header">
                        <h2 className="section-title">Recent Vendors</h2>
                      </div>
                      <div className="activity-list">
                        {!statsData.recentVendors?.length
                          ? <div className="no-data-card">No vendor applications yet</div>
                          : statsData.recentVendors.map(v => (
                            <div className="activity-item" key={v._id}>
                              <div className="activity-meta">
                                <div className="avatar" style={{ width: '32px', height: '32px', fontSize: '12px' }}>
                                  {(v.shopName||'S').charAt(0).toUpperCase()}
                                </div>
                                <div className="activity-details">
                                  <span className="activity-title">{v.shopName}</span>
                                  <span className="activity-subtitle">{v.ownerName} • {v.phone}</span>
                                </div>
                              </div>
                              <span className={`badge ${v.isApproved ? 'badge-success' : 'badge-warning'}`}>
                                {v.isApproved ? 'Approved' : 'Pending'}
                              </span>
                            </div>
                          ))
                        }
                      </div>
                    </div>
                  </div>

                  {/* Recent orders table */}
                  <div className="glass-card" style={{ marginTop: '0' }}>
                    <div className="section-header">
                      <h2 className="section-title">Recent Orders</h2>
                      <button onClick={() => setActiveTab('orders')} className="btn btn-outline" style={{ width: 'auto', padding: '6px 14px', fontSize: '13px' }}>
                        View All
                      </button>
                    </div>
                    <div className="data-table-container">
                      <table className="data-table">
                        <thead>
                          <tr>
                            <th>Order ID</th><th>Customer</th><th>Shop</th><th>Amount</th><th>Payment</th><th>Status</th>
                          </tr>
                        </thead>
                        <tbody>
                          {!statsData.recentOrders?.length
                            ? <tr><td colSpan="6" style={{ color: 'var(--text-secondary)', padding: '24px', textAlign: 'center' }}>No orders yet</td></tr>
                            : statsData.recentOrders.map(o => (
                              <tr key={o._id}>
                                <td style={{ fontFamily: 'monospace', color: 'var(--text-secondary)', fontSize: '12px' }}>#{o._id.slice(-6).toUpperCase()}</td>
                                <td>{o.customerId?.name || '—'}</td>
                                <td>{o.vendorId?.shopName || '—'}</td>
                                <td style={{ fontWeight: 700, color: 'var(--primary)' }}>₹{o.totalAmount}</td>
                                <td><span className="badge badge-info" style={{ fontSize: '11px' }}>{o.paymentMethod}</span></td>
                                <td>
                                  <span className={`badge ${o.orderStatus === 'delivered' ? 'badge-success' : o.orderStatus === 'cancelled' ? 'badge-danger' : 'badge-warning'}`}>
                                    {o.orderStatus}
                                  </span>
                                </td>
                              </tr>
                            ))
                          }
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>
              )}

              {/* ── VENDORS ── */}
              {activeTab === 'vendors' && (
                <div className="glass-card">
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                    <h2 className="section-title">Vendor Directory ({vendors.length})</h2>
                    <input type="text" placeholder="Search shops or owners..." className="input-field" style={{ maxWidth: '320px' }} value={searchQuery} onChange={e => setSearchQuery(e.target.value)} />
                  </div>
                  <div className="data-table-container">
                    <table className="data-table">
                      <thead>
                        <tr><th>Shop</th><th>Owner</th><th>Phone</th><th>Radius</th><th>Rating</th><th>Status</th><th>Actions</th></tr>
                      </thead>
                      <tbody>
                        {vendors
                          .filter(v => v.shopName?.toLowerCase().includes(searchQuery.toLowerCase()) || v.ownerName?.toLowerCase().includes(searchQuery.toLowerCase()) || v.phone?.includes(searchQuery))
                          .map(v => (
                            <tr key={v._id}>
                              <td style={{ fontWeight: 700, color: 'white' }}>{v.shopName}</td>
                              <td>{v.ownerName}</td>
                              <td style={{ fontFamily: 'monospace' }}>{v.phone}</td>
                              <td>{v.serviceRadius || 10} km</td>
                              <td>⭐ {v.rating || 0}</td>
                              <td>
                                <span className={`badge ${v.isApproved ? 'badge-success' : 'badge-warning'}`}>
                                  {v.isApproved ? 'Approved' : 'Pending'}
                                </span>
                              </td>
                              <td>
                                {!v.isApproved
                                  ? <button onClick={() => handleVendorApproval(v._id, true)} className="btn btn-primary" style={{ width: 'auto', padding: '6px 12px', fontSize: '12px' }}>Approve</button>
                                  : <button onClick={() => handleVendorApproval(v._id, false)} className="btn btn-danger" style={{ width: 'auto', padding: '6px 12px', fontSize: '12px' }}>Suspend</button>
                                }
                              </td>
                            </tr>
                          ))
                        }
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* ── ORDERS ── */}
              {activeTab === 'orders' && (
                <div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                    <h2 className="section-title">All Orders ({orders.length})</h2>
                    <input type="text" placeholder="Search by customer or order ID..." className="input-field" style={{ maxWidth: '320px' }} value={searchQuery} onChange={e => setSearchQuery(e.target.value)} />
                  </div>
                  {orders
                    .filter(o => o._id.includes(searchQuery) || o.customerId?.name?.toLowerCase().includes(searchQuery.toLowerCase()) || o.customerId?.phone?.includes(searchQuery))
                    .map(o => {
                      const expanded = !!expandedOrders[o._id];
                      return (
                        <div className={`order-card ${expanded ? 'expanded' : ''}`} key={o._id}>
                          <div className="order-header-row" onClick={() => toggleOrderExpand(o._id)}>
                            <div className="order-brief">
                              <div>
                                <span style={{ fontSize: '10px', color: 'var(--text-secondary)', display: 'block', textTransform: 'uppercase', fontWeight: 700, letterSpacing: '0.5px' }}>Order ID</span>
                                <strong style={{ fontFamily: 'monospace', fontSize: '13px' }}>#{o._id.slice(-8).toUpperCase()}</strong>
                              </div>
                              <div>
                                <span style={{ fontSize: '10px', color: 'var(--text-secondary)', display: 'block', textTransform: 'uppercase', fontWeight: 700, letterSpacing: '0.5px' }}>Customer</span>
                                <span>{o.customerId?.name || '—'} · {o.customerId?.phone}</span>
                              </div>
                              <div>
                                <span style={{ fontSize: '10px', color: 'var(--text-secondary)', display: 'block', textTransform: 'uppercase', fontWeight: 700, letterSpacing: '0.5px' }}>Store</span>
                                <span>{o.vendorId?.shopName || '—'}</span>
                              </div>
                              <div>
                                <span style={{ fontSize: '10px', color: 'var(--text-secondary)', display: 'block', textTransform: 'uppercase', fontWeight: 700, letterSpacing: '0.5px' }}>Total</span>
                                <strong style={{ color: 'var(--primary)' }}>₹{o.totalAmount}</strong>
                              </div>
                            </div>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
                              <span className={`badge ${o.orderStatus === 'delivered' ? 'badge-success' : o.orderStatus === 'cancelled' ? 'badge-danger' : 'badge-warning'}`}>
                                {o.orderStatus}
                              </span>
                              {expanded ? <ChevronDown size={16}/> : <ChevronRight size={16}/>}
                            </div>
                          </div>

                          {expanded && (
                            <div className="order-details-block">
                              <div>
                                <h4 className="form-label" style={{ marginBottom: '12px' }}>Items</h4>
                                <div className="order-products-list">
                                  {o.products?.map((item, idx) => (
                                    <div className="order-product-row" key={idx}>
                                      <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                                        {item.productId?.images?.[0] && (
                                          <img src={item.productId.images[0].startsWith('http') ? item.productId.images[0] : `http://localhost:5000/${item.productId.images[0]}`}
                                            alt="" style={{ width: '38px', height: '38px', borderRadius: '6px', objectFit: 'cover' }} />
                                        )}
                                        <div>
                                          <strong style={{ fontSize: '13px' }}>{item.productId?.productName || 'Deleted Product'}</strong>
                                          <span style={{ display: 'block', fontSize: '11px', color: 'var(--text-secondary)' }}>{item.productId?.weight} {item.productId?.unit}</span>
                                        </div>
                                      </div>
                                      <div style={{ textAlign: 'right' }}>
                                        <span style={{ color: 'var(--text-secondary)', fontSize: '12px' }}>₹{item.price} × {item.quantity}</span>
                                        <strong style={{ display: 'block' }}>₹{item.price * item.quantity}</strong>
                                      </div>
                                    </div>
                                  ))}
                                </div>
                                <div style={{ marginTop: '16px', display: 'flex', gap: '8px', alignItems: 'flex-start' }}>
                                  <MapPin size={15} style={{ color: '#ef4444', flexShrink: 0, marginTop: '2px' }} />
                                  <span style={{ fontSize: '13px', lineHeight: '1.5' }}>{o.deliveryAddress?.fullAddress || 'No address'}</span>
                                </div>
                              </div>

                              <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                                <div className="order-actions-box">
                                  <span className="address-label">Update Status</span>
                                  <select value={o.orderStatus} onChange={e => handleUpdateOrderStatus(o._id, e.target.value)} className="order-status-select">
                                    <option value="pending">Pending</option>
                                    <option value="accepted">Accepted</option>
                                    <option value="packed">Packed</option>
                                    <option value="out_for_delivery">Out for Delivery</option>
                                    <option value="delivered">Delivered</option>
                                    <option value="cancelled">Cancelled</option>
                                  </select>
                                </div>
                                <div className="order-actions-box">
                                  <span className="address-label">Payment Info</span>
                                  <div style={{ fontSize: '13px', display: 'flex', flexDirection: 'column', gap: '8px' }}>
                                    <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                                      <span>Method</span><strong style={{ textTransform: 'uppercase' }}>{o.paymentMethod}</strong>
                                    </div>
                                    <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                                      <span>Status</span>
                                      <span className={`badge ${o.paymentStatus === 'paid' ? 'badge-success' : 'badge-warning'}`} style={{ fontSize: '10px', padding: '2px 8px' }}>{o.paymentStatus}</span>
                                    </div>
                                    <div style={{ borderTop: '1px solid var(--border)', paddingTop: '8px', display: 'flex', justifyContent: 'space-between', fontWeight: 700, color: 'white' }}>
                                      <span>Total</span><span>₹{o.totalAmount}</span>
                                    </div>
                                  </div>
                                </div>
                              </div>
                            </div>
                          )}
                        </div>
                      );
                    })
                  }
                  {orders.length === 0 && <div className="no-data-card">No orders in system yet</div>}
                </div>
              )}

              {/* ── PRODUCTS ── */}
              {activeTab === 'products' && (
                <div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                    <h2 className="section-title">Product Catalog ({products.length})</h2>
                    <input type="text" placeholder="Search products..." className="input-field" style={{ maxWidth: '320px' }} value={searchQuery} onChange={e => setSearchQuery(e.target.value)} />
                  </div>
                  <div className="catalog-grid">
                    {products
                      .filter(p => p.productName?.toLowerCase().includes(searchQuery.toLowerCase()))
                      .map(p => (
                        <div className="glass-card product-card" key={p._id}>
                          <div className="product-img-wrapper">
                            {p.images?.[0]
                              ? <img src={p.images[0].startsWith('http') ? p.images[0] : `http://localhost:5000/${p.images[0]}`} alt={p.productName} className="product-img" />
                              : <div style={{ height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-muted)', fontSize: '13px' }}>No Image</div>
                            }
                            <span className={`badge product-badge ${p.isAvailable ? 'badge-success' : 'badge-danger'}`}>
                              {p.isAvailable ? 'In Stock' : 'Out of Stock'}
                            </span>
                          </div>
                          <div className="product-info">
                            <span className="product-vendor">{p.vendorId?.shopName || 'Unknown Shop'}</span>
                            <h3 className="product-name">{p.productName}</h3>
                            <div className="product-prices">
                              <span className="selling-price">₹{p.sellingPrice}</span>
                              {p.mrpPrice > p.sellingPrice && <span className="mrp-price">₹{p.mrpPrice}</span>}
                            </div>
                            <div className="product-meta">
                              <span>{p.categoryId?.name || 'Uncategorized'}</span>
                              <span>{p.weight} {p.unit}</span>
                            </div>
                            <div className="product-actions">
                              <button onClick={() => handleDeleteProduct(p._id)} className="btn btn-danger" style={{ padding: '8px', fontSize: '13px', gap: '6px' }}>
                                <Trash2 size={14}/> Delete Product
                              </button>
                            </div>
                          </div>
                        </div>
                      ))
                    }
                    {products.length === 0 && <div className="no-data-card" style={{ gridColumn: '1/-1' }}>No products in catalog</div>}
                  </div>
                </div>
              )}

              {/* ── CATEGORIES ── */}
              {activeTab === 'categories' && (
                <div className="category-manager-layout">
                  <div className="glass-card">
                    <h3 className="section-title" style={{ marginBottom: '20px' }}>Add New Category</h3>
                    <form onSubmit={handleAddCategory}>
                      <div className="form-group">
                        <label className="form-label">Category Name</label>
                        <input type="text" placeholder="e.g. Fresh Mushrooms" className="input-field" value={newCategoryName} onChange={e => setNewCategoryName(e.target.value)} disabled={loading} />
                      </div>
                      <div className="form-group">
                        <label className="form-label">Image URL (Optional)</label>
                        <input type="url" placeholder="https://..." className="input-field" value={newCategoryImg} onChange={e => setNewCategoryImg(e.target.value)} disabled={loading} />
                      </div>
                      <button type="submit" className="btn btn-primary" disabled={loading}>
                        <Plus size={16}/> {loading ? 'Creating...' : 'Create Category'}
                      </button>
                    </form>
                  </div>

                  <div className="glass-card">
                    <h3 className="section-title" style={{ marginBottom: '20px' }}>All Categories ({categories.length})</h3>
                    <div className="data-table-container">
                      <table className="data-table">
                        <thead>
                          <tr><th>Image</th><th>Name</th><th>Status</th><th>Delete</th></tr>
                        </thead>
                        <tbody>
                          {categories.length === 0
                            ? <tr><td colSpan="4" style={{ color: 'var(--text-secondary)', textAlign: 'center', padding: '24px' }}>No categories</td></tr>
                            : categories.map(c => (
                              <tr key={c._id}>
                                <td>
                                  {c.image
                                    ? <img src={c.image.startsWith('http') ? c.image : `http://localhost:5000/${c.image}`} alt={c.name} className="category-row-img" />
                                    : <div className="category-row-img" style={{ background: '#1e2230', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '10px', color: 'var(--text-muted)' }}>—</div>
                                  }
                                </td>
                                <td style={{ fontWeight: 600, color: 'white' }}>{c.name}</td>
                                <td><span className="badge badge-success">Active</span></td>
                                <td>
                                  <button onClick={() => handleDeleteCategory(c._id)} className="logout-btn" title="Delete" style={{ color: 'var(--danger)' }}>
                                    <Trash2 size={16}/>
                                  </button>
                                </td>
                              </tr>
                            ))
                          }
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>
              )}
            </>
          )}
        </div>
      </main>
    </div>
  );
}

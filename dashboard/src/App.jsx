import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import ErrorBoundary from './components/ErrorBoundary'
import Layout from './components/Layout'
import Dashboard from './pages/Dashboard'
import Pharmacies from './pages/Pharmacies'
import Products from './pages/Products'
import Reports from './pages/Reports'
import { supabase } from './lib/supabase'

function App() {
  // Check if Supabase is configured
  if (!supabase) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
        <div className="max-w-md w-full bg-white rounded-xl shadow-lg p-6 border border-red-200">
          <h1 className="text-xl font-bold text-gray-900 mb-4">Configuration Error</h1>
          <p className="text-gray-600 mb-4">
            Supabase credentials are missing. Please check your <code className="bg-gray-100 px-2 py-1 rounded">.env</code> file.
          </p>
          <div className="bg-gray-50 p-3 rounded-lg mb-4">
            <p className="text-sm font-mono text-gray-700">
              VITE_SUPABASE_URL: {import.meta.env.VITE_SUPABASE_URL ? '✅ Set' : '❌ Missing'}
            </p>
            <p className="text-sm font-mono text-gray-700">
              VITE_SUPABASE_ANON_KEY: {import.meta.env.VITE_SUPABASE_ANON_KEY ? '✅ Set' : '❌ Missing'}
            </p>
          </div>
          <p className="text-sm text-gray-500">
            Make sure your <code className="bg-gray-100 px-2 py-1 rounded">.env</code> file exists in the dashboard directory with the correct variables.
          </p>
        </div>
      </div>
    )
  }

  return (
    <ErrorBoundary>
      <Router>
        <Layout>
          <Routes>
            <Route path="/" element={<Navigate to="/dashboard" replace />} />
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/pharmacies" element={<Pharmacies />} />
            <Route path="/products" element={<Products />} />
            <Route path="/reports" element={<Reports />} />
          </Routes>
        </Layout>
      </Router>
    </ErrorBoundary>
  )
}

export default App


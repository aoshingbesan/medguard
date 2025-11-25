import { useEffect, useState } from 'react'
import { Navigate } from 'react-router-dom'
import { supabase } from '../lib/supabase'

const PublicRoute = ({ children }) => {
  const [loading, setLoading] = useState(true)
  const [authenticated, setAuthenticated] = useState(false)

  useEffect(() => {
    const checkAuth = async () => {
      if (!supabase) {
        setLoading(false)
        return
      }

      try {
        const { data: { session } } = await supabase.auth.getSession()
        setAuthenticated(!!session)
      } catch (error) {
        console.error('Error checking auth:', error)
        setAuthenticated(false)
      } finally {
        setLoading(false)
      }
    }

    checkAuth()

    // Listen for auth state changes
    if (supabase) {
      const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
        setAuthenticated(!!session)
      })

      return () => {
        subscription.unsubscribe()
      }
    }
  }, [])

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading...</p>
        </div>
      </div>
    )
  }

  // If user is authenticated, redirect to dashboard
  if (authenticated) {
    return <Navigate to="/dashboard" replace />
  }

  // If not authenticated, show the public route (login page)
  return children
}

export default PublicRoute


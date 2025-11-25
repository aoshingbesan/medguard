import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import { Users, CheckCircle, XCircle, FileText, TrendingUp } from 'lucide-react'

const Dashboard = () => {
  if (!supabase) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <p className="text-red-600 mb-2">Supabase not configured</p>
          <p className="text-gray-600 text-sm">Please check your .env file</p>
        </div>
      </div>
    )
  }
  const [stats, setStats] = useState({
    totalUsers: 0,
    verifiedDrugs: 0,
    unverifiedDrugs: 0,
    totalReports: 0,
    loading: true
  })

  useEffect(() => {
    fetchStats()
  }, [])

  const fetchStats = async () => {
    try {
      // Run all queries in parallel for faster loading
      const [usersResult, verifiedResult, unverifiedResult, reportsResult] = await Promise.all([
        supabase
          .from('user_sessions')
          .select('*', { count: 'exact', head: true }),
        supabase
          .from('verification_events')
          .select('*', { count: 'exact', head: true })
          .eq('verification_result', 'verified'),
        supabase
          .from('verification_events')
          .select('*', { count: 'exact', head: true })
          .eq('verification_result', 'unverified'),
        supabase
          .from('reports')
          .select('*', { count: 'exact', head: true })
      ])

      // Extract counts, default to 0 on error
      const totalUsers = usersResult.error ? 0 : (usersResult.count || 0)
      const verifiedCount = verifiedResult.error ? 0 : (verifiedResult.count || 0)
      const unverifiedCount = unverifiedResult.error ? 0 : (unverifiedResult.count || 0)
      const totalReports = reportsResult.error ? 0 : (reportsResult.count || 0)

      setStats({
        totalUsers,
        verifiedDrugs: verifiedCount,
        unverifiedDrugs: unverifiedCount,
        totalReports,
        loading: false
      })
    } catch (error) {
      setStats(prev => ({ ...prev, loading: false }))
    }
  }

  const statCards = [
    {
      title: 'Total Users',
      value: stats.totalUsers,
      icon: Users,
      color: 'bg-primary-600',
      bgColor: 'bg-primary-50',
      textColor: 'text-primary-700'
    },
    {
      title: 'Verified Scans/Entries',
      value: stats.verifiedDrugs,
      icon: CheckCircle,
      color: 'bg-green-500',
      bgColor: 'bg-green-50',
      textColor: 'text-green-700'
    },
    {
      title: 'Unverified Scans/Entries',
      value: stats.unverifiedDrugs,
      icon: XCircle,
      color: 'bg-orange-500',
      bgColor: 'bg-orange-50',
      textColor: 'text-orange-700'
    },
    {
      title: 'Total Reports',
      value: stats.totalReports,
      icon: FileText,
      color: 'bg-purple-500',
      bgColor: 'bg-purple-50',
      textColor: 'text-purple-700'
    },
  ]

  if (stats.loading) {
    return (
      <div className="flex flex-col items-center justify-center h-64 space-y-4">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
        <p className="text-gray-600 text-sm">Loading dashboard data...</p>
        <p className="text-gray-500 text-xs">If this takes too long, check RLS policies in Supabase</p>
      </div>
    )
  }

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-600 mt-2">Overview of MedGuard system statistics</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {statCards.map((stat, index) => {
          const Icon = stat.icon
          return (
            <div
              key={index}
              className={`${stat.bgColor} rounded-xl p-6 shadow-sm border border-gray-200`}
            >
              <div className="flex items-center justify-between">
                <div>
                  <p className={`text-sm font-medium ${stat.textColor} mb-1`}>
                    {stat.title}
                  </p>
                  <p className={`text-3xl font-bold ${stat.textColor}`}>
                    {stat.value.toLocaleString()}
                  </p>
                </div>
                <div className={`${stat.color} p-3 rounded-lg`}>
                  <Icon className="text-white" size={24} />
                </div>
              </div>
            </div>
          )
        })}
      </div>

      {/* Additional Info */}
      <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
        <div className="flex items-center gap-3 mb-4">
          <TrendingUp className="text-primary-600" size={24} />
          <h2 className="text-xl font-semibold text-gray-900">System Status</h2>
        </div>
        <div className="space-y-3">
          <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
            <span className="text-gray-700">Database Connection</span>
            <span className="px-3 py-1 bg-green-100 text-green-700 rounded-full text-sm font-medium">
              Connected
            </span>
          </div>
          <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
            <span className="text-gray-700">Verification Rate</span>
            <span className="text-gray-900 font-semibold">
              {stats.verifiedDrugs > 0
                ? ((stats.verifiedDrugs / (stats.verifiedDrugs + stats.unverifiedDrugs)) * 100).toFixed(1)
                : 0}%
            </span>
          </div>
          <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
            <span className="text-gray-700">Pending Reports</span>
            <span className="text-gray-900 font-semibold">{stats.unverifiedDrugs}</span>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Dashboard


import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import { AlertCircle, MapPin, Calendar, Package, CheckCircle, XCircle, Eye, X } from 'lucide-react'

const Reports = () => {
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
  const [reports, setReports] = useState([])
  const [loading, setLoading] = useState(true)
  const [selectedReport, setSelectedReport] = useState(null)
  const [filterStatus, setFilterStatus] = useState('all')

  useEffect(() => {
    fetchReports()
  }, [filterStatus])

  const fetchReports = async () => {
    try {
      let query = supabase
        .from('reports')
        .select('*')
        .order('created_at', { ascending: false })

      if (filterStatus !== 'all') {
        query = query.eq('status', filterStatus)
      }

      const { data, error } = await query

      if (error) throw error
      
      // Debug: Log first report to see what data we're getting
      if (data && data.length > 0) {
        console.log('📦 Sample report data from backend:', data[0])
        console.log('📦 Latitude:', data[0].latitude, 'Type:', typeof data[0].latitude)
        console.log('📦 Longitude:', data[0].longitude, 'Type:', typeof data[0].longitude)
      }
      
      setReports(data || [])
    } catch (error) {
      console.error('Error fetching reports:', error)
      alert('Error fetching reports: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const handleStatusUpdate = async (reportId, newStatus) => {
    try {
      const { error } = await supabase
        .from('reports')
        .update({ status: newStatus })
        .eq('id', reportId)

      if (error) throw error
      alert('Report status updated successfully!')
      fetchReports()
    } catch (error) {
      console.error('Error updating report status:', error)
      alert('Error updating report status: ' + error.message)
    }
  }

  const getStatusBadge = (status) => {
    const statusConfig = {
      pending: { color: 'bg-yellow-100 text-yellow-800', icon: AlertCircle },
      resolved: { color: 'bg-green-100 text-green-800', icon: CheckCircle },
      rejected: { color: 'bg-red-100 text-red-800', icon: XCircle }
    }

    const config = statusConfig[status] || statusConfig.pending
    const Icon = config.icon

    return (
      <span className={`inline-flex items-center gap-1 px-2 py-1 text-xs font-medium rounded-full ${config.color}`}>
        <Icon size={14} />
        {status.charAt(0).toUpperCase() + status.slice(1)}
      </span>
    )
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Reports</h1>
          <p className="text-gray-600 mt-2">View and manage unverified drug reports</p>
        </div>
        <div className="flex gap-2">
          <select
            value={filterStatus}
            onChange={(e) => setFilterStatus(e.target.value)}
            className="px-4 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
          >
            <option value="all">All Reports</option>
            <option value="pending">Pending</option>
            <option value="resolved">Resolved</option>
            <option value="rejected">Rejected</option>
          </select>
        </div>
      </div>

      {/* Reports List */}
      <div className="space-y-4">
        {reports.map((report) => (
          <div
            key={report.id}
            className="bg-white rounded-xl p-6 shadow-sm border border-gray-200 hover:shadow-md transition-shadow"
          >
            <div className="flex items-start justify-between">
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-3">
                  {getStatusBadge(report.status)}
                  <span className="text-sm text-gray-500">
                    {new Date(report.created_at).toLocaleString()}
                  </span>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                  <div>
                    <h3 className="text-lg font-semibold text-gray-900 mb-2 flex items-center gap-2">
                      <Package size={20} className="text-primary-600" />
                      Drug Information
                    </h3>
                    <div className="space-y-1 text-sm">
                      <div><span className="font-medium">GTIN:</span> {report.gtin || 'N/A'}</div>
                      <div><span className="font-medium">Product:</span> {report.product_name || report.product || 'N/A'}</div>
                      <div><span className="font-medium">Generic Name:</span> {report.generic_name || 'N/A'}</div>
                      <div><span className="font-medium">Manufacturer:</span> {report.manufacturer || 'N/A'}</div>
                    </div>
                  </div>

                  <div>
                    <h3 className="text-lg font-semibold text-gray-900 mb-2 flex items-center gap-2">
                      <MapPin size={20} className="text-primary-600" />
                      Location Information
                    </h3>
                    <div className="space-y-1 text-sm">
                      <div>
                        <span className="font-medium">Latitude:</span> {
                          report.latitude !== null && report.latitude !== undefined 
                            ? typeof report.latitude === 'number' 
                              ? report.latitude.toFixed(6) 
                              : parseFloat(report.latitude).toFixed(6)
                            : 'N/A'
                        }
                      </div>
                      <div>
                        <span className="font-medium">Longitude:</span> {
                          report.longitude !== null && report.longitude !== undefined 
                            ? typeof report.longitude === 'number' 
                              ? report.longitude.toFixed(6) 
                              : parseFloat(report.longitude).toFixed(6)
                            : 'N/A'
                        }
                      </div>
                      {report.address && (
                        <div><span className="font-medium">Address:</span> {report.address}</div>
                      )}
                      {report.google_maps_link && (
                        <div>
                          <a
                            href={report.google_maps_link}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-primary-600 hover:underline"
                          >
                            View on Google Maps
                          </a>
                        </div>
                      )}
                    </div>
                  </div>
                </div>

                {report.photo_url && (
                  <div className="mb-4">
                    <h3 className="text-sm font-medium text-gray-700 mb-2">Photo</h3>
                    <img
                      src={report.photo_url}
                      alt="Report photo"
                      className="max-w-xs rounded-lg border border-gray-200"
                    />
                  </div>
                )}

                {report.notes && (
                  <div className="mb-4">
                    <h3 className="text-sm font-medium text-gray-700 mb-1">Notes</h3>
                    <p className="text-sm text-gray-600 bg-gray-50 p-3 rounded-lg">{report.notes}</p>
                  </div>
                )}
              </div>

              <div className="flex flex-col gap-2 ml-4">
                <button
                  onClick={() => setSelectedReport(report)}
                  className="px-3 py-2 text-sm bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 flex items-center gap-2"
                >
                  <Eye size={16} />
                  View Details
                </button>
                {report.status === 'pending' && (
                  <div className="flex flex-col gap-2">
                    <button
                      onClick={() => handleStatusUpdate(report.id, 'resolved')}
                      className="px-3 py-2 text-sm bg-green-100 text-green-700 rounded-lg hover:bg-green-200"
                    >
                      Mark Resolved
                    </button>
                    <button
                      onClick={() => handleStatusUpdate(report.id, 'rejected')}
                      className="px-3 py-2 text-sm bg-red-100 text-red-700 rounded-lg hover:bg-red-200"
                    >
                      Reject
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>

      {reports.length === 0 && (
        <div className="text-center py-12 text-gray-500 bg-white rounded-xl border border-gray-200">
          No reports found
        </div>
      )}

      {/* Report Detail Modal */}
      {selectedReport && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl p-6 w-full max-w-3xl max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-2xl font-bold text-gray-900">Report Details</h2>
              <button
                onClick={() => setSelectedReport(null)}
                className="text-gray-400 hover:text-gray-600"
              >
                <X size={24} />
              </button>
            </div>

            <div className="space-y-4">
              <div>
                <h3 className="font-semibold text-gray-900 mb-2">Drug Information</h3>
                <div className="bg-gray-50 p-4 rounded-lg space-y-2 text-sm">
                  <div><span className="font-medium">GTIN:</span> {selectedReport.gtin || 'N/A'}</div>
                  <div><span className="font-medium">Product:</span> {selectedReport.product_name || selectedReport.product || 'N/A'}</div>
                  <div><span className="font-medium">Generic Name:</span> {selectedReport.generic_name || 'N/A'}</div>
                  <div><span className="font-medium">Manufacturer:</span> {selectedReport.manufacturer || 'N/A'}</div>
                </div>
              </div>

              <div>
                <h3 className="font-semibold text-gray-900 mb-2">Location</h3>
                <div className="bg-gray-50 p-4 rounded-lg space-y-2 text-sm">
                  <div>
                    <span className="font-medium">Latitude:</span> {
                      selectedReport.latitude !== null && selectedReport.latitude !== undefined 
                        ? typeof selectedReport.latitude === 'number' 
                          ? selectedReport.latitude.toFixed(6) 
                          : parseFloat(selectedReport.latitude).toFixed(6)
                        : 'N/A'
                    }
                  </div>
                  <div>
                    <span className="font-medium">Longitude:</span> {
                      selectedReport.longitude !== null && selectedReport.longitude !== undefined 
                        ? typeof selectedReport.longitude === 'number' 
                          ? selectedReport.longitude.toFixed(6) 
                          : parseFloat(selectedReport.longitude).toFixed(6)
                        : 'N/A'
                    }
                  </div>
                  <div>
                    <span className="font-medium">Coordinates:</span> {
                      selectedReport.latitude !== null && selectedReport.latitude !== undefined && 
                      selectedReport.longitude !== null && selectedReport.longitude !== undefined
                        ? `${typeof selectedReport.latitude === 'number' ? selectedReport.latitude.toFixed(6) : parseFloat(selectedReport.latitude).toFixed(6)}, ${typeof selectedReport.longitude === 'number' ? selectedReport.longitude.toFixed(6) : parseFloat(selectedReport.longitude).toFixed(6)}`
                        : 'N/A'
                    }
                  </div>
                  {selectedReport.address && (
                    <div><span className="font-medium">Address:</span> {selectedReport.address}</div>
                  )}
                  {selectedReport.google_maps_link && (
                    <div>
                      <a
                        href={selectedReport.google_maps_link}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-primary-600 hover:underline"
                      >
                        Open in Google Maps
                      </a>
                    </div>
                  )}
                </div>
              </div>

              {selectedReport.photo_url && (
                <div>
                  <h3 className="font-semibold text-gray-900 mb-2">Photo</h3>
                  <img
                    src={selectedReport.photo_url}
                    alt="Report photo"
                    className="max-w-full rounded-lg border border-gray-200"
                  />
                </div>
              )}

              <div>
                <h3 className="font-semibold text-gray-900 mb-2">Report Metadata</h3>
                <div className="bg-gray-50 p-4 rounded-lg space-y-2 text-sm">
                  <div><span className="font-medium">Status:</span> {getStatusBadge(selectedReport.status)}</div>
                  <div><span className="font-medium">Submitted:</span> {new Date(selectedReport.created_at).toLocaleString()}</div>
                  {selectedReport.updated_at && (
                    <div><span className="font-medium">Last Updated:</span> {new Date(selectedReport.updated_at).toLocaleString()}</div>
                  )}
                </div>
              </div>

              {selectedReport.status === 'pending' && (
                <div className="flex gap-3 pt-4">
                  <button
                    onClick={() => {
                      handleStatusUpdate(selectedReport.id, 'resolved')
                      setSelectedReport(null)
                    }}
                    className="flex-1 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
                  >
                    Mark as Resolved
                  </button>
                  <button
                    onClick={() => {
                      handleStatusUpdate(selectedReport.id, 'rejected')
                      setSelectedReport(null)
                    }}
                    className="flex-1 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
                  >
                    Reject Report
                  </button>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default Reports


import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import { AlertCircle, MapPin, Calendar, Package, CheckCircle, XCircle, Eye, X, ExternalLink, FileText, Building2, Map } from 'lucide-react'

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
  const [viewingImage, setViewingImage] = useState(null)

  useEffect(() => {
    fetchReports()
  }, [filterStatus])

  const fetchReports = async () => {
    // Set a timeout to prevent infinite loading
    const timeoutId = setTimeout(() => {
      console.warn('⚠️ Fetch reports timeout - setting loading to false')
      setLoading(false)
      setReports([])
    }, 10000) // 10 second timeout

    try {
      console.log('🔄 Fetching reports...', { filterStatus })
      
      if (!supabase) {
        console.error('❌ Supabase not configured')
        clearTimeout(timeoutId)
        setLoading(false)
        setReports([])
        return
      }

      let query = supabase
        .from('reports')
        .select('*')
        .order('created_at', { ascending: false })

      if (filterStatus !== 'all') {
        query = query.eq('status', filterStatus)
      }

      console.log('📤 Executing query...')
      const { data, error, count } = await query
      clearTimeout(timeoutId)

      if (error) {
        console.error('❌ Error fetching reports:', error)
        console.error('Error details:', {
          message: error.message,
          code: error.code,
          details: error.details,
          hint: error.hint
        })
        setReports([])
        setLoading(false)
        // Show user-friendly error message
        if (error.code === 'PGRST116' || error.message?.includes('permission') || error.message?.includes('RLS')) {
          console.error('🔒 RLS Policy Error - Reports table access denied')
          alert('Access denied. Please check Row Level Security policies for the reports table.')
        } else {
          alert('Error fetching reports: ' + error.message)
        }
        return
      }
      
      console.log('✅ Query completed')
      console.log('📊 Response data:', data)
      console.log('📊 Data type:', typeof data)
      console.log('📊 Is array:', Array.isArray(data))
      console.log('📊 Data length:', data?.length)
      console.log('📊 First item:', data?.[0])
      
      if (data && Array.isArray(data)) {
        console.log('✅ Reports fetched successfully:', data.length, 'reports')
        setReports(data)
      } else {
        console.warn('⚠️ Unexpected data format:', data)
        setReports([])
      }
      setLoading(false)
    } catch (error) {
      clearTimeout(timeoutId)
      console.error('❌ Fatal error fetching reports:', error)
      setReports([])
      setLoading(false)
      alert('Error fetching reports: ' + (error.message || 'Unknown error'))
    }
  }

  const handleStatusUpdate = async (reportId, newStatus) => {
    try {
      console.log('🔄 Updating report status:', { reportId, newStatus })
      
      const { data, error } = await supabase
        .from('reports')
        .update({ status: newStatus })
        .eq('id', reportId)
        .select()

      if (error) {
        console.error('❌ Error updating report status:', error)
        console.error('Error details:', {
          message: error.message,
          code: error.code,
          details: error.details,
          hint: error.hint
        })
        throw error
      }
      
      console.log('✅ Report status updated:', data)
      alert('Report status updated successfully!')
      fetchReports()
      if (selectedReport && selectedReport.id === reportId) {
        setSelectedReport({ ...selectedReport, status: newStatus })
      }
    } catch (error) {
      console.error('❌ Fatal error updating report status:', error)
      alert('Error updating report status: ' + (error.message || 'Unknown error'))
    }
  }

  const getStatusBadge = (status) => {
    const statusConfig = {
      pending: { 
        color: 'bg-yellow-50 text-yellow-700 border-yellow-200', 
        icon: AlertCircle
      },
      resolved: { 
        color: 'bg-green-50 text-green-700 border-green-200', 
        icon: CheckCircle
      },
      rejected: { 
        color: 'bg-red-50 text-red-700 border-red-200', 
        icon: XCircle
      }
    }

    const config = statusConfig[status] || statusConfig.pending
    const Icon = config.icon

    return (
      <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 text-xs font-medium rounded border ${config.color}`}>
        <Icon size={12} />
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
          <h1 className="text-2xl font-semibold text-gray-900">Reports</h1>
          <p className="text-gray-500 text-sm mt-1">Manage drug verification reports</p>
        </div>
          <select
            value={filterStatus}
            onChange={(e) => setFilterStatus(e.target.value)}
          className="px-3 py-2 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 outline-none text-sm"
          >
            <option value="all">All Reports</option>
            <option value="pending">Pending</option>
            <option value="resolved">Resolved</option>
            <option value="rejected">Rejected</option>
          </select>
      </div>

      {/* Reports Table */}
      <div className="bg-white border border-gray-200 rounded-lg overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">ID</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Status</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">GTIN</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Product</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Date</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
        {reports.map((report) => (
                <tr key={report.id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-mono text-gray-900">#{report.id}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                  {getStatusBadge(report.status)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-mono text-gray-900">{report.gtin || 'N/A'}</td>
                  <td className="px-6 py-4 text-sm text-gray-900">
                    {report.product_name || report.product || 'N/A'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {new Date(report.created_at).toLocaleDateString('en-US', { 
                      month: 'short', 
                      day: 'numeric', 
                      year: 'numeric'
                    })}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm">
                <button
                  onClick={() => setSelectedReport(report)}
                      className="text-primary-600 hover:text-primary-700 font-medium flex items-center gap-1.5"
                >
                      <Eye size={16} />
                  View
                </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          </div>
      </div>

      {reports.length === 0 && (
        <div className="text-center py-12 bg-white border border-gray-200 rounded-lg">
          <FileText className="mx-auto h-12 w-12 text-gray-400 mb-4" />
          <h3 className="text-sm font-medium text-gray-900 mb-1">No reports found</h3>
          <p className="text-sm text-gray-500">
              {filterStatus === 'all' 
                ? "There are no reports in the system yet."
                : `There are no ${filterStatus} reports at this time.`}
            </p>
        </div>
      )}

      {/* Report Detail Modal */}
      {selectedReport && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4" onClick={() => setSelectedReport(null)}>
          <div 
            className="bg-white rounded-lg shadow-xl w-full max-w-3xl max-h-[90vh] overflow-hidden flex flex-col"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Modal Header */}
            <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between bg-white">
              <div>
                <h2 className="text-lg font-semibold text-gray-900">Report Details</h2>
                <p className="text-sm text-gray-500 mt-0.5">ID: #{selectedReport.id}</p>
              </div>
              <button
                onClick={() => setSelectedReport(null)}
                className="text-gray-400 hover:text-gray-600 transition-colors"
              >
                <X size={20} />
              </button>
            </div>

            {/* Modal Content */}
            <div className="overflow-y-auto flex-1 p-6 space-y-6">
              {/* Photo */}
                {selectedReport.photo_url && (
                  <div>
                  <h3 className="text-sm font-semibold text-gray-900 mb-3">Photo Evidence</h3>
                  <div className="border border-gray-200 rounded-lg overflow-hidden bg-gray-50">
                    <div
                      onClick={() => setViewingImage(selectedReport.photo_url)}
                      className="block cursor-pointer hover:opacity-90 transition-opacity"
                    >
                      <img
                        src={selectedReport.photo_url}
                        alt="Report photo"
                        className="w-full max-h-64 object-contain"
                        onError={(e) => {
                          e.target.style.display = 'none'
                        }}
                      />
                    </div>
                    <div className="px-3 py-2 bg-gray-100 border-t border-gray-200 text-xs text-gray-600 flex items-center justify-between">
                      <span>Click image to view full size</span>
                      <ExternalLink size={12} className="text-gray-400" />
                    </div>
                    </div>
                  </div>
                )}

                {/* Drug Information */}
                <div>
                <h3 className="text-sm font-semibold text-gray-900 mb-3 flex items-center gap-2">
                  <Package size={16} className="text-gray-600" />
                    Drug Information
                  </h3>
                <div className="bg-gray-50 border border-gray-200 rounded-lg p-4 space-y-3">
                    <div className="grid grid-cols-2 gap-4">
                    <div>
                      <span className="text-xs text-gray-500 block mb-1">GTIN</span>
                      <p className="text-sm font-mono text-gray-900">{selectedReport.gtin || 'N/A'}</p>
                    </div>
                    {(selectedReport.product_name || selectedReport.product) && (
                      <div>
                        <span className="text-xs text-gray-500 block mb-1">Product Name</span>
                        <p className="text-sm text-gray-900">{selectedReport.product_name || selectedReport.product}</p>
                      </div>
                    )}
                        </div>
                  <div className="grid grid-cols-2 gap-4 pt-3 border-t border-gray-200">
                      {selectedReport.generic_name && (
                        <div>
                        <span className="text-xs text-gray-500 block mb-1">Generic Name</span>
                        <p className="text-sm text-gray-900">{selectedReport.generic_name}</p>
                        </div>
                      )}
                      {selectedReport.manufacturer && (
                        <div>
                        <span className="text-xs text-gray-500 block mb-1">Manufacturer</span>
                        <p className="text-sm text-gray-900 flex items-center gap-1">
                          <Building2 size={14} className="text-gray-400" />
                            {selectedReport.manufacturer}
                          </p>
                        </div>
                      )}
                    </div>
                  </div>
                </div>

                {/* Location Information */}
                {(selectedReport.latitude || selectedReport.longitude || selectedReport.address) && (
                  <div>
                  <h3 className="text-sm font-semibold text-gray-900 mb-3 flex items-center gap-2">
                    <MapPin size={16} className="text-gray-600" />
                    Location
                    </h3>
                  <div className="bg-gray-50 border border-gray-200 rounded-lg p-4 space-y-3">
                      {selectedReport.address && (
                        <div>
                        <span className="text-xs text-gray-500 block mb-1">Address</span>
                        <p className="text-sm text-gray-900">{selectedReport.address}</p>
                        </div>
                      )}
                      {(selectedReport.latitude || selectedReport.longitude) && (
                        <div>
                        <span className="text-xs text-gray-500 block mb-1">Coordinates</span>
                        <p className="text-sm font-mono text-gray-900">
                            {selectedReport.latitude !== null && selectedReport.latitude !== undefined 
                              ? (typeof selectedReport.latitude === 'number' ? selectedReport.latitude.toFixed(6) : parseFloat(selectedReport.latitude).toFixed(6))
                              : 'N/A'}, {selectedReport.longitude !== null && selectedReport.longitude !== undefined 
                              ? (typeof selectedReport.longitude === 'number' ? selectedReport.longitude.toFixed(6) : parseFloat(selectedReport.longitude).toFixed(6))
                              : 'N/A'}
                          </p>
                        </div>
                      )}
                      {selectedReport.google_maps_link && (
                        <a
                          href={selectedReport.google_maps_link}
                          target="_blank"
                          rel="noopener noreferrer"
                        className="inline-flex items-center gap-1.5 mt-2 px-3 py-1.5 bg-gray-900 text-white text-xs font-medium rounded hover:bg-gray-800 transition-colors"
                        >
                        <Map size={14} />
                          Open in Google Maps
                        <ExternalLink size={12} />
                        </a>
                      )}
                    </div>
                  </div>
                )}

                {/* Notes */}
                {selectedReport.notes && (
                  <div>
                  <h3 className="text-sm font-semibold text-gray-900 mb-3 flex items-center gap-2">
                    <FileText size={16} className="text-gray-600" />
                    Notes
                    </h3>
                  <div className="bg-gray-50 border border-gray-200 rounded-lg p-4">
                    <p className="text-sm text-gray-900 leading-relaxed">{selectedReport.notes}</p>
                    </div>
                  </div>
                )}

              {/* Metadata */}
                <div>
                <h3 className="text-sm font-semibold text-gray-900 mb-3">Metadata</h3>
                <div className="bg-gray-50 border border-gray-200 rounded-lg p-4 space-y-2">
                    <div className="flex items-center justify-between">
                    <span className="text-xs text-gray-500">Status</span>
                      {getStatusBadge(selectedReport.status)}
                    </div>
                  <div className="flex items-center justify-between pt-2 border-t border-gray-200">
                    <span className="text-xs text-gray-500">Submitted</span>
                    <span className="text-sm text-gray-900 flex items-center gap-1">
                      <Calendar size={12} className="text-gray-400" />
                        {new Date(selectedReport.created_at).toLocaleString()}
                      </span>
                    </div>
                    {selectedReport.updated_at && (
                      <div className="flex items-center justify-between">
                      <span className="text-xs text-gray-500">Last Updated</span>
                      <span className="text-sm text-gray-900 flex items-center gap-1">
                        <Calendar size={12} className="text-gray-400" />
                          {new Date(selectedReport.updated_at).toLocaleString()}
                        </span>
                      </div>
                    )}
                  </div>
                </div>
              </div>

              {/* Modal Footer */}
              {selectedReport.status === 'pending' && (
                <div className="border-t border-gray-200 px-6 py-4 bg-gray-50 flex gap-3">
                  <button
                    onClick={() => {
                      handleStatusUpdate(selectedReport.id, 'resolved')
                      setSelectedReport(null)
                    }}
                  className="flex-1 px-4 py-2 bg-green-600 text-white text-sm font-medium rounded hover:bg-green-700 transition-colors flex items-center justify-center gap-2"
                  >
                  <CheckCircle size={16} />
                  Mark Resolved
                  </button>
                  <button
                    onClick={() => {
                      handleStatusUpdate(selectedReport.id, 'rejected')
                      setSelectedReport(null)
                    }}
                  className="flex-1 px-4 py-2 bg-red-600 text-white text-sm font-medium rounded hover:bg-red-700 transition-colors flex items-center justify-center gap-2"
                  >
                  <XCircle size={16} />
                  Reject
                  </button>
                </div>
              )}
          </div>
        </div>
      )}

      {/* Image Lightbox Modal */}
      {viewingImage && (
        <div 
          className="fixed inset-0 bg-black/90 flex items-center justify-center z-50 p-4"
          onClick={() => setViewingImage(null)}
        >
          <div className="relative max-w-7xl max-h-full w-full h-full flex items-center justify-center">
            <button
              onClick={() => setViewingImage(null)}
              className="absolute top-4 right-4 text-white hover:text-gray-300 transition-colors z-10 bg-black/50 rounded-full p-2"
            >
              <X size={24} />
            </button>
            <img
              src={viewingImage}
              alt="Full size report photo"
              className="max-w-full max-h-full object-contain"
              onClick={(e) => e.stopPropagation()}
              onError={(e) => {
                e.target.style.display = 'none'
                const errorDiv = e.target.nextSibling
                if (errorDiv) errorDiv.style.display = 'flex'
              }}
            />
            <div className="hidden absolute inset-0 items-center justify-center bg-black/50">
              <div className="text-center text-white">
                <p className="text-lg mb-2">Image unavailable</p>
                <p className="text-sm text-gray-300">Unable to load image</p>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default Reports

import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import { AlertCircle, MapPin, Calendar, Package, CheckCircle, XCircle, Eye, X, ExternalLink, Image as ImageIcon, FileText, Building2, Map } from 'lucide-react'

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
      pending: { 
        color: 'bg-yellow-100 text-yellow-800 border-yellow-200', 
        icon: AlertCircle,
        gradient: 'from-yellow-400 to-yellow-500'
      },
      resolved: { 
        color: 'bg-green-100 text-green-800 border-green-200', 
        icon: CheckCircle,
        gradient: 'from-green-400 to-green-500'
      },
      rejected: { 
        color: 'bg-red-100 text-red-800 border-red-200', 
        icon: XCircle,
        gradient: 'from-red-400 to-red-500'
      }
    }

    const config = statusConfig[status] || statusConfig.pending
    const Icon = config.icon

    return (
      <span className={`inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold rounded-full border ${config.color} shadow-sm`}>
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
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {reports.map((report) => (
          <div
            key={report.id}
            className="bg-white rounded-2xl shadow-lg border border-gray-100 hover:shadow-xl transition-all duration-300 overflow-hidden group"
          >
            {/* Header with Status */}
            <div className="bg-gradient-to-r from-gray-50 to-gray-100 px-6 py-4 border-b border-gray-200">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  {getStatusBadge(report.status)}
                  <span className="text-xs text-gray-500 flex items-center gap-1">
                    <Calendar size={14} />
                    {new Date(report.created_at).toLocaleDateString('en-US', { 
                      month: 'short', 
                      day: 'numeric', 
                      year: 'numeric',
                      hour: '2-digit',
                      minute: '2-digit'
                    })}
                  </span>
                </div>
                <button
                  onClick={() => setSelectedReport(report)}
                  className="px-3 py-1.5 text-xs font-medium text-primary-600 bg-primary-50 rounded-lg hover:bg-primary-100 transition-colors flex items-center gap-1.5"
                >
                  <Eye size={14} />
                  View
                </button>
              </div>
            </div>

            {/* Content */}
            <div className="p-6">
              {/* Photo Preview */}
              {report.photo_url && (
                <div className="mb-6 -mx-6 -mt-4">
                  <div className="relative h-48 bg-gray-100 overflow-hidden">
                    <img
                      src={report.photo_url}
                      alt="Report photo"
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                      onError={(e) => {
                        e.target.style.display = 'none'
                        e.target.nextSibling.style.display = 'flex'
                      }}
                    />
                    <div className="hidden absolute inset-0 items-center justify-center bg-gray-100">
                      <div className="text-center">
                        <ImageIcon size={32} className="text-gray-400 mx-auto mb-2" />
                        <p className="text-sm text-gray-500">Image unavailable</p>
                      </div>
                    </div>
                    <div className="absolute top-2 right-2 bg-black/50 backdrop-blur-sm text-white px-2 py-1 rounded text-xs flex items-center gap-1">
                      <ImageIcon size={12} />
                      Photo
                    </div>
                  </div>
                </div>
              )}

              {/* Drug Information Card */}
              <div className="mb-4 p-4 bg-gradient-to-br from-blue-50 to-indigo-50 rounded-xl border border-blue-100">
                <div className="flex items-center gap-2 mb-3">
                  <div className="p-2 bg-blue-100 rounded-lg">
                    <Package size={18} className="text-blue-600" />
                  </div>
                  <h3 className="font-semibold text-gray-900">Drug Information</h3>
                </div>
                <div className="space-y-2.5 text-sm">
                  <div className="flex items-start gap-2">
                    <span className="font-semibold text-gray-800 min-w-[90px]">GTIN:</span>
                    <span className="text-gray-900 font-mono text-xs font-bold bg-white px-2 py-1 rounded border border-gray-200">{report.gtin || 'N/A'}</span>
                  </div>
                  {report.product_name || report.product ? (
                    <div className="flex items-start gap-2">
                      <span className="font-semibold text-gray-800 min-w-[90px]">Product:</span>
                      <span className="text-gray-900 font-medium">{report.product_name || report.product}</span>
                    </div>
                  ) : null}
                  {report.generic_name && (
                    <div className="flex items-start gap-2">
                      <span className="font-semibold text-gray-800 min-w-[90px]">Generic:</span>
                      <span className="text-gray-900 font-medium">{report.generic_name}</span>
                    </div>
                  )}
                  {report.manufacturer && (
                    <div className="flex items-start gap-2">
                      <span className="font-semibold text-gray-800 min-w-[90px]">Manufacturer:</span>
                      <span className="text-gray-900 font-medium flex items-center gap-1">
                        <Building2 size={14} className="text-gray-600" />
                        {report.manufacturer}
                      </span>
                    </div>
                  )}
                </div>
              </div>

              {/* Location Information Card */}
              {(report.latitude || report.longitude || report.address) && (
                <div className="mb-4 p-4 bg-gradient-to-br from-green-50 to-emerald-50 rounded-xl border border-green-100">
                  <div className="flex items-center gap-2 mb-3">
                    <div className="p-2 bg-green-100 rounded-lg">
                      <MapPin size={18} className="text-green-600" />
                    </div>
                    <h3 className="font-semibold text-gray-900">Location</h3>
                  </div>
                  <div className="space-y-2.5 text-sm">
                    {report.address && (
                      <div className="flex items-start gap-2">
                        <span className="font-semibold text-gray-800 min-w-[90px]">Address:</span>
                        <span className="text-gray-900 font-medium">{report.address}</span>
                      </div>
                    )}
                    {(report.latitude || report.longitude) && (
                      <div className="flex items-center gap-2">
                        <span className="font-semibold text-gray-800 min-w-[90px]">Coordinates:</span>
                        <span className="text-gray-900 font-mono text-xs font-semibold bg-white px-2 py-1 rounded border border-gray-200">
                          {report.latitude !== null && report.latitude !== undefined 
                            ? (typeof report.latitude === 'number' ? report.latitude.toFixed(6) : parseFloat(report.latitude).toFixed(6))
                            : 'N/A'}, {report.longitude !== null && report.longitude !== undefined 
                            ? (typeof report.longitude === 'number' ? report.longitude.toFixed(6) : parseFloat(report.longitude).toFixed(6))
                            : 'N/A'}
                        </span>
                      </div>
                    )}
                    {report.google_maps_link && (
                      <a
                        href={report.google_maps_link}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex items-center gap-1.5 mt-2 px-3 py-1.5 bg-green-600 text-white text-xs font-medium rounded-lg hover:bg-green-700 transition-colors"
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
              {report.notes && (
                <div className="mb-4 p-4 bg-amber-50 rounded-xl border border-amber-100">
                  <div className="flex items-center gap-2 mb-2">
                    <FileText size={16} className="text-amber-600" />
                    <h3 className="font-semibold text-gray-900 text-sm">Notes</h3>
                  </div>
                  <p className="text-sm text-gray-800 font-medium leading-relaxed">{report.notes}</p>
                </div>
              )}

              {/* Action Buttons */}
              {report.status === 'pending' && (
                <div className="flex gap-2 pt-4 border-t border-gray-200">
                  <button
                    onClick={() => handleStatusUpdate(report.id, 'resolved')}
                    className="flex-1 px-4 py-2.5 bg-gradient-to-r from-green-500 to-green-600 text-white text-sm font-medium rounded-lg hover:from-green-600 hover:to-green-700 transition-all shadow-sm hover:shadow-md flex items-center justify-center gap-2"
                  >
                    <CheckCircle size={16} />
                    Mark Resolved
                  </button>
                  <button
                    onClick={() => handleStatusUpdate(report.id, 'rejected')}
                    className="flex-1 px-4 py-2.5 bg-gradient-to-r from-red-500 to-red-600 text-white text-sm font-medium rounded-lg hover:from-red-600 hover:to-red-700 transition-all shadow-sm hover:shadow-md flex items-center justify-center gap-2"
                  >
                    <XCircle size={16} />
                    Reject
                  </button>
                </div>
              )}
            </div>
          </div>
        ))}
      </div>

      {reports.length === 0 && (
        <div className="text-center py-16 bg-white rounded-2xl border-2 border-dashed border-gray-200">
          <div className="max-w-md mx-auto">
            <div className="w-20 h-20 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
              <FileText size={40} className="text-gray-400" />
            </div>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">No Reports Found</h3>
            <p className="text-gray-500">
              {filterStatus === 'all' 
                ? "There are no reports in the system yet."
                : `There are no ${filterStatus} reports at this time.`}
            </p>
          </div>
        </div>
      )}

      {/* Report Detail Modal */}
      {selectedReport && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4" onClick={() => setSelectedReport(null)}>
          <div 
            className="bg-white rounded-2xl shadow-2xl w-full max-w-4xl max-h-[90vh] overflow-hidden flex flex-col"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Modal Header */}
            <div className="bg-gradient-to-r from-primary-600 to-primary-700 px-6 py-4 flex items-center justify-between">
              <div>
                <h2 className="text-2xl font-bold text-white">Report Details</h2>
                <p className="text-primary-100 text-sm mt-1">ID: #{selectedReport.id}</p>
              </div>
              <button
                onClick={() => setSelectedReport(null)}
                className="text-white/80 hover:text-white p-2 hover:bg-white/10 rounded-lg transition-colors"
              >
                <X size={24} />
              </button>
            </div>

            {/* Modal Content */}
            <div className="overflow-y-auto flex-1 p-6">

              <div className="space-y-6">
                {/* Photo Section */}
                {selectedReport.photo_url && (
                  <div>
                    <h3 className="font-semibold text-gray-900 mb-3 flex items-center gap-2">
                      <ImageIcon size={20} className="text-primary-600" />
                      Photo Evidence
                    </h3>
                    <div className="relative rounded-xl overflow-hidden border-2 border-gray-200 bg-gray-100">
                      <img
                        src={selectedReport.photo_url}
                        alt="Report photo"
                        className="w-full max-h-96 object-contain"
                        onError={(e) => {
                          e.target.style.display = 'none'
                          e.target.nextSibling.style.display = 'flex'
                        }}
                      />
                      <div className="hidden absolute inset-0 items-center justify-center bg-gray-100">
                        <div className="text-center">
                          <ImageIcon size={48} className="text-gray-400 mx-auto mb-2" />
                          <p className="text-gray-500">Image unavailable</p>
                        </div>
                      </div>
                    </div>
                  </div>
                )}

                {/* Drug Information */}
                <div>
                  <h3 className="font-semibold text-gray-900 mb-3 flex items-center gap-2">
                    <Package size={20} className="text-primary-600" />
                    Drug Information
                  </h3>
                  <div className="bg-gradient-to-br from-blue-50 to-indigo-50 p-5 rounded-xl border border-blue-100 space-y-3">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <span className="text-xs font-semibold text-gray-700 uppercase tracking-wide block mb-1.5">GTIN</span>
                        <p className="text-lg font-mono font-bold text-gray-900">{selectedReport.gtin || 'N/A'}</p>
                      </div>
                      {selectedReport.product_name || selectedReport.product ? (
                        <div>
                          <span className="text-xs font-semibold text-gray-700 uppercase tracking-wide block mb-1.5">Product Name</span>
                          <p className="text-lg font-bold text-gray-900">{selectedReport.product_name || selectedReport.product}</p>
                        </div>
                      ) : null}
                    </div>
                    <div className="grid grid-cols-2 gap-4 pt-3 border-t border-blue-200">
                      {selectedReport.generic_name && (
                        <div>
                          <span className="text-xs font-semibold text-gray-700 uppercase tracking-wide block mb-1.5">Generic Name</span>
                          <p className="text-base font-medium text-gray-900">{selectedReport.generic_name}</p>
                        </div>
                      )}
                      {selectedReport.manufacturer && (
                        <div>
                          <span className="text-xs font-semibold text-gray-700 uppercase tracking-wide block mb-1.5">Manufacturer</span>
                          <p className="text-base font-medium text-gray-900 flex items-center gap-1">
                            <Building2 size={16} className="text-gray-600" />
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
                    <h3 className="font-semibold text-gray-900 mb-3 flex items-center gap-2">
                      <MapPin size={20} className="text-primary-600" />
                      Location Information
                    </h3>
                    <div className="bg-gradient-to-br from-green-50 to-emerald-50 p-5 rounded-xl border border-green-100 space-y-3">
                      {selectedReport.address && (
                        <div>
                          <span className="text-xs font-semibold text-gray-700 uppercase tracking-wide block mb-1.5">Address</span>
                          <p className="text-base font-medium text-gray-900">{selectedReport.address}</p>
                        </div>
                      )}
                      {(selectedReport.latitude || selectedReport.longitude) && (
                        <div>
                          <span className="text-xs font-semibold text-gray-700 uppercase tracking-wide block mb-1.5">Coordinates</span>
                          <p className="text-base font-mono font-semibold text-gray-900">
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
                          className="inline-flex items-center gap-2 mt-3 px-4 py-2.5 bg-green-600 text-white font-medium rounded-lg hover:bg-green-700 transition-colors"
                        >
                          <Map size={18} />
                          Open in Google Maps
                          <ExternalLink size={16} />
                        </a>
                      )}
                    </div>
                  </div>
                )}

                {/* Notes */}
                {selectedReport.notes && (
                  <div>
                    <h3 className="font-semibold text-gray-900 mb-3 flex items-center gap-2">
                      <FileText size={20} className="text-primary-600" />
                      Additional Notes
                    </h3>
                    <div className="bg-amber-50 p-5 rounded-xl border border-amber-100">
                      <p className="text-gray-800 font-medium leading-relaxed">{selectedReport.notes}</p>
                    </div>
                  </div>
                )}

                {/* Report Metadata */}
                <div>
                  <h3 className="font-semibold text-gray-900 mb-3">Report Metadata</h3>
                  <div className="bg-gray-50 p-5 rounded-xl border border-gray-200 space-y-3">
                    <div className="flex items-center justify-between">
                      <span className="text-sm font-semibold text-gray-700">Status</span>
                      {getStatusBadge(selectedReport.status)}
                    </div>
                    <div className="flex items-center justify-between pt-3 border-t border-gray-200">
                      <span className="text-sm font-semibold text-gray-700">Submitted</span>
                      <span className="text-sm font-medium text-gray-900 flex items-center gap-1">
                        <Calendar size={14} className="text-gray-600" />
                        {new Date(selectedReport.created_at).toLocaleString()}
                      </span>
                    </div>
                    {selectedReport.updated_at && (
                      <div className="flex items-center justify-between">
                        <span className="text-sm font-semibold text-gray-700">Last Updated</span>
                        <span className="text-sm font-medium text-gray-900 flex items-center gap-1">
                          <Calendar size={14} className="text-gray-600" />
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
                    className="flex-1 px-6 py-3 bg-gradient-to-r from-green-500 to-green-600 text-white font-medium rounded-lg hover:from-green-600 hover:to-green-700 transition-all shadow-md hover:shadow-lg flex items-center justify-center gap-2"
                  >
                    <CheckCircle size={18} />
                    Mark as Resolved
                  </button>
                  <button
                    onClick={() => {
                      handleStatusUpdate(selectedReport.id, 'rejected')
                      setSelectedReport(null)
                    }}
                    className="flex-1 px-6 py-3 bg-gradient-to-r from-red-500 to-red-600 text-white font-medium rounded-lg hover:from-red-600 hover:to-red-700 transition-all shadow-md hover:shadow-lg flex items-center justify-center gap-2"
                  >
                    <XCircle size={18} />
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


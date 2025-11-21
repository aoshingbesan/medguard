import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import { Plus, Edit, Trash2, Search, MapPin, Phone, Mail } from 'lucide-react'

const Pharmacies = () => {
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
  const [pharmacies, setPharmacies] = useState([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [showModal, setShowModal] = useState(false)
  const [editingPharmacy, setEditingPharmacy] = useState(null)
  const [formData, setFormData] = useState({
    name: '',
    address: '',
    phone: '',
    email: '',
    district: '',
    sector: '',
    cell: '',
    latitude: '',
    longitude: '',
    google_maps_link: '',
    is_verified: true
  })

  useEffect(() => {
    fetchPharmacies()
  }, [])

  const fetchPharmacies = async () => {
    try {
      const { data, error } = await supabase
        .from('pharmacies')
        .select('*')
        .order('name')

      if (error) throw error
      setPharmacies(data || [])
    } catch (error) {
      console.error('Error fetching pharmacies:', error)
      alert('Error fetching pharmacies: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    try {
      if (editingPharmacy) {
        const { data, error } = await supabase
          .from('pharmacies')
          .update(formData)
          .eq('id', editingPharmacy.id)
          .select()

        if (error) {
          console.error('Update error details:', {
            message: error.message,
            details: error.details,
            hint: error.hint,
            code: error.code,
            formData
          })
          throw error
        }
        
        if (!data || data.length === 0) {
          alert('No pharmacy was updated. The pharmacy may not exist or you may not have permission.')
          return
        }
        
        alert('Pharmacy updated successfully!')
      } else {
        const { data, error } = await supabase
          .from('pharmacies')
          .insert([formData])
          .select()

        if (error) {
          console.error('Insert error details:', {
            message: error.message,
            details: error.details,
            hint: error.hint,
            code: error.code,
            formData
          })
          throw error
        }
        
        alert('Pharmacy added successfully!')
      }

      setShowModal(false)
      setEditingPharmacy(null)
      resetForm()
      fetchPharmacies()
    } catch (error) {
      console.error('Error saving pharmacy:', error)
      const errorMessage = error.message || 'Unknown error occurred'
      const errorHint = error.hint ? `\n\nHint: ${error.hint}` : ''
      const errorCode = error.code ? `\n\nError Code: ${error.code}` : ''
      alert(`Error saving pharmacy: ${errorMessage}${errorHint}${errorCode}\n\nIf this persists, check your Supabase RLS policies.`)
    }
  }

  const handleEdit = (pharmacy) => {
    setEditingPharmacy(pharmacy)
    setFormData({
      name: pharmacy.name || '',
      address: pharmacy.address || '',
      phone: pharmacy.phone || '',
      email: pharmacy.email || '',
      district: pharmacy.district || '',
      sector: pharmacy.sector || '',
      cell: pharmacy.cell || '',
      latitude: pharmacy.latitude?.toString() || '',
      longitude: pharmacy.longitude?.toString() || '',
      google_maps_link: pharmacy.google_maps_link || '',
      is_verified: pharmacy.is_verified ?? true
    })
    setShowModal(true)
  }

  const handleDelete = async (id) => {
    if (!confirm('Are you sure you want to delete this pharmacy?')) return

    try {
      const { data, error } = await supabase
        .from('pharmacies')
        .delete()
        .eq('id', id)
        .select()

      if (error) {
        console.error('Delete error details:', {
          message: error.message,
          details: error.details,
          hint: error.hint,
          code: error.code
        })
        throw error
      }
      
      if (data && data.length === 0) {
        alert('No pharmacy was deleted. The pharmacy may not exist or you may not have permission.')
        return
      }
      
      alert('Pharmacy deleted successfully!')
      fetchPharmacies()
    } catch (error) {
      console.error('Error deleting pharmacy:', error)
      const errorMessage = error.message || 'Unknown error occurred'
      const errorHint = error.hint ? `\n\nHint: ${error.hint}` : ''
      const errorCode = error.code ? `\n\nError Code: ${error.code}` : ''
      alert(`Error deleting pharmacy: ${errorMessage}${errorHint}${errorCode}\n\nIf this persists, check your Supabase RLS policies.`)
    }
  }

  const resetForm = () => {
    setFormData({
      name: '',
      address: '',
      phone: '',
      email: '',
      district: '',
      sector: '',
      cell: '',
      latitude: '',
      longitude: '',
      google_maps_link: '',
      is_verified: true
    })
  }

  const filteredPharmacies = pharmacies.filter(pharmacy =>
    pharmacy.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    pharmacy.address?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    pharmacy.district?.toLowerCase().includes(searchTerm.toLowerCase())
  )

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
          <h1 className="text-3xl font-bold text-gray-900">Pharmacies</h1>
          <p className="text-gray-600 mt-2">Manage verified pharmacies in the system</p>
        </div>
        <button
          onClick={() => {
            resetForm()
            setEditingPharmacy(null)
            setShowModal(true)
          }}
          className="flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
        >
          <Plus size={20} />
          Add Pharmacy
        </button>
      </div>

      {/* Search */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={20} />
        <input
          type="text"
          placeholder="Search pharmacies..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="w-full pl-10 pr-4 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
        />
      </div>

      {/* Pharmacies Table */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Name
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Location
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Contact
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredPharmacies.map((pharmacy) => (
                <tr key={pharmacy.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{pharmacy.name}</div>
                    <div className="text-sm text-gray-500">{pharmacy.address}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center gap-2 text-sm text-gray-900">
                      <MapPin size={16} className="text-gray-400" />
                      <span>{pharmacy.district}, {pharmacy.sector}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex flex-col gap-1 text-sm text-gray-900">
                      {pharmacy.phone && (
                        <div className="flex items-center gap-2">
                          <Phone size={14} className="text-gray-400" />
                          <span>{pharmacy.phone}</span>
                        </div>
                      )}
                      {pharmacy.email && (
                        <div className="flex items-center gap-2">
                          <Mail size={14} className="text-gray-400" />
                          <span>{pharmacy.email}</span>
                        </div>
                      )}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                      pharmacy.is_verified
                        ? 'bg-green-100 text-green-800'
                        : 'bg-gray-100 text-gray-800'
                    }`}>
                      {pharmacy.is_verified ? 'Verified' : 'Unverified'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <div className="flex items-center justify-end gap-2">
                      <button
                        onClick={() => handleEdit(pharmacy)}
                        className="text-primary-600 hover:text-primary-900"
                      >
                        <Edit size={18} />
                      </button>
                      <button
                        onClick={() => handleDelete(pharmacy.id)}
                        className="text-red-600 hover:text-red-900"
                      >
                        <Trash2 size={18} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {filteredPharmacies.length === 0 && (
          <div className="text-center py-12 text-gray-500">
            No pharmacies found
          </div>
        )}
      </div>

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
            <h2 className="text-2xl font-bold text-gray-900 mb-4">
              {editingPharmacy ? 'Edit Pharmacy' : 'Add New Pharmacy'}
            </h2>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Name *
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    District
                  </label>
                  <input
                    type="text"
                    value={formData.district}
                    onChange={(e) => setFormData({ ...formData, district: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div className="col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Address
                  </label>
                  <input
                    type="text"
                    value={formData.address}
                    onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Sector
                  </label>
                  <input
                    type="text"
                    value={formData.sector}
                    onChange={(e) => setFormData({ ...formData, sector: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Cell
                  </label>
                  <input
                    type="text"
                    value={formData.cell}
                    onChange={(e) => setFormData({ ...formData, cell: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Phone
                  </label>
                  <input
                    type="tel"
                    value={formData.phone}
                    onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Email
                  </label>
                  <input
                    type="email"
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Latitude
                  </label>
                  <input
                    type="number"
                    step="any"
                    value={formData.latitude}
                    onChange={(e) => setFormData({ ...formData, latitude: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Longitude
                  </label>
                  <input
                    type="number"
                    step="any"
                    value={formData.longitude}
                    onChange={(e) => setFormData({ ...formData, longitude: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div className="col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Google Maps Link
                  </label>
                  <input
                    type="url"
                    value={formData.google_maps_link}
                    onChange={(e) => setFormData({ ...formData, google_maps_link: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="flex items-center gap-2">
                    <input
                      type="checkbox"
                      checked={formData.is_verified}
                      onChange={(e) => setFormData({ ...formData, is_verified: e.target.checked })}
                      className="rounded"
                    />
                    <span className="text-sm font-medium text-gray-700">Verified</span>
                  </label>
                </div>
              </div>
              <div className="flex gap-3 pt-4">
                <button
                  type="submit"
                  className="flex-1 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700"
                >
                  {editingPharmacy ? 'Update' : 'Add'} Pharmacy
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setShowModal(false)
                    setEditingPharmacy(null)
                    resetForm()
                  }}
                  className="flex-1 px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300"
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}

export default Pharmacies


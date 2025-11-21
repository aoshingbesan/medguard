import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import { Plus, Edit, Trash2, Search, Package, Eye, X } from 'lucide-react'

const Products = () => {
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
  const [products, setProducts] = useState([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [showModal, setShowModal] = useState(false)
  const [showDetailsModal, setShowDetailsModal] = useState(false)
  const [selectedProduct, setSelectedProduct] = useState(null)
  const [editingProduct, setEditingProduct] = useState(null)
  const [formData, setFormData] = useState({
    gtin: '',
    product_name: '',
    brand: '',
    generic_name: '',
    manufacturer: '',
    country: '',
    registration_no: '',
    registration_date: '',
    license_expiry_date: '',
    dosage_form: '',
    strength: '',
    pack_size: '',
    expiry_date: '',
    shelf_life: '',
    packaging_type: '',
    marketing_authorization_holder: '',
    local_technical_representative: ''
  })

  useEffect(() => {
    fetchProducts()
  }, [])

  const fetchProducts = async () => {
    try {
      // Fetch all columns from products table
      const { data, error } = await supabase
        .from('products')
        .select('*')
        .order('id', { ascending: true })

      if (error) throw error
      
      // Debug: Log first product to see what columns we're getting
      if (data && data.length > 0) {
        console.log('📦 Sample product data from backend:', data[0])
        console.log('📦 All column names:', Object.keys(data[0]))
      }
      
      setProducts(data || [])
    } catch (error) {
      console.error('Error fetching products:', error)
      alert('Error fetching products: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    try {
      // Prepare data for insert/update - use actual database column names from schema
      // Actual column names: product_brand_name, generic_name, manufacturer_name, 
      // manufacturer_country, registration_no, registration_date, license_expiry_date, dosage_form, 
      // dosage_strength, pack_size, shelf_life, packaging_type, marketing_authorization_holder, local_technical_representative
      const dataToSave = {}
      
      // All fields are required
      dataToSave.gtin = formData.gtin
      dataToSave.product_brand_name = formData.product_name
      dataToSave.generic_name = formData.generic_name
      dataToSave.manufacturer_name = formData.manufacturer
      dataToSave.manufacturer_country = formData.country
      dataToSave.registration_no = formData.registration_no
      dataToSave.registration_date = formData.registration_date
      dataToSave.license_expiry_date = formData.license_expiry_date
      dataToSave.dosage_form = formData.dosage_form
      dataToSave.dosage_strength = formData.strength
      dataToSave.pack_size = formData.pack_size
      dataToSave.shelf_life = formData.shelf_life
      dataToSave.packaging_type = formData.packaging_type
      dataToSave.marketing_authorization_holder = formData.marketing_authorization_holder
      dataToSave.local_technical_representative = formData.local_technical_representative

      if (editingProduct) {
        let data, error
        
        // Try update
        const result = await supabase
          .from('products')
          .update(dataToSave)
          .eq('id', editingProduct.id)
          .select()
        
        data = result.data
        error = result.error

        // If error is about missing column, log it for debugging
        if (error && error.message && error.message.includes("Could not find") && error.message.includes("column")) {
          console.error('Column error - check database schema matches expected columns:', error.message)
        }

        if (error) {
          console.error('Update error details:', {
            message: error.message,
            details: error.details,
            hint: error.hint,
            code: error.code,
            dataToSave
          })
          throw error
        }
        
        if (!data || data.length === 0) {
          alert('No product was updated. The product may not exist or you may not have permission.')
          return
        }
        
        alert('Product updated successfully!')
      } else {
        let data, error
        
        // Try insert
        const result = await supabase
          .from('products')
          .insert([dataToSave])
          .select()
        
        data = result.data
        error = result.error

        // If error is about missing column, log it for debugging
        if (error && error.message && error.message.includes("Could not find") && error.message.includes("column")) {
          console.error('Column error - check database schema matches expected columns:', error.message)
        }

        if (error) {
          console.error('Insert error details:', {
            message: error.message,
            details: error.details,
            hint: error.hint,
            code: error.code,
            dataToSave
          })
          throw error
        }
        
        alert('Product added successfully!')
      }

      setShowModal(false)
      setEditingProduct(null)
      resetForm()
      fetchProducts()
    } catch (error) {
      console.error('Error saving product:', error)
      const errorMessage = error.message || 'Unknown error occurred'
      const errorHint = error.hint ? `\n\nHint: ${error.hint}` : ''
      const errorCode = error.code ? `\n\nError Code: ${error.code}` : ''
      alert(`Error saving product: ${errorMessage}${errorHint}${errorCode}\n\nIf this persists, check your Supabase RLS policies.`)
    }
  }

  const handleEdit = (product) => {
    // Debug: Log all product fields
    console.log('📝 Editing product with all fields:', product)
    console.log('📝 Available fields:', Object.keys(product))
    
    setEditingProduct(product)
    
    // Helper function to get value from multiple possible keys
    const getValue = (obj, ...keys) => {
      for (const key of keys) {
        if (obj[key] !== null && obj[key] !== undefined && obj[key] !== '') {
          return obj[key]
        }
      }
      return ''
    }
    
    setFormData({
      gtin: getValue(product, 'gtin') || '',
      product_name: getValue(product, 'product_brand_name', 'product_name', 'name', 'product', 'Product Name') || '',
      brand: getValue(product, 'brand', 'Brand', 'product_brand_name') || '',
      generic_name: getValue(product, 'generic_name', 'genericName', 'Generic Name') || '',
      manufacturer: getValue(product, 'manufacturer_name', 'manufacturer', 'Manufacturer') || '',
      country: getValue(product, 'manufacturer_country', 'country', 'Country') || '',
      registration_no: getValue(product, 'registration_no', 'rfda_reg_no', 'registration_number', 'Registration No') || '',
      registration_date: getValue(product, 'registration_date', 'Registration Date') || '',
      license_expiry_date: getValue(product, 'expiry_date', 'license_expiry_date', 'licenseExpiryDate', 'License Expiry Date') || '',
      dosage_form: getValue(product, 'dosage_form', 'dosageForm', 'Dosage Form') || '',
      strength: getValue(product, 'dosage_strength', 'strength', 'Strength') || '',
      pack_size: getValue(product, 'pack_size', 'packSize', 'Pack Size') || '',
      expiry_date: getValue(product, 'expiry_date', 'expiryDate', 'Expiry Date') || '',
      shelf_life: getValue(product, 'shelf_life', 'shelfLife', 'Shelf Life') || '',
      packaging_type: getValue(product, 'packaging_type', 'packagingType', 'Packaging Type') || '',
      marketing_authorization_holder: getValue(product, 'marketing_authorization_holder', 'marketing_auth_holder', 'marketingAuthHolder', 'Marketing Auth Holder') || '',
      local_technical_representative: getValue(product, 'local_technical_representative', 'local_tech_rep', 'localTechRep', 'Local Tech Rep') || ''
    })
    setShowModal(true)
  }

  const handleDelete = async (id) => {
    if (!confirm('Are you sure you want to delete this product?')) return

    try {
      const { data, error } = await supabase
        .from('products')
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
        alert('No product was deleted. The product may not exist or you may not have permission.')
        return
      }
      
      alert('Product deleted successfully!')
      fetchProducts()
    } catch (error) {
      console.error('Error deleting product:', error)
      const errorMessage = error.message || 'Unknown error occurred'
      const errorHint = error.hint ? `\n\nHint: ${error.hint}` : ''
      const errorCode = error.code ? `\n\nError Code: ${error.code}` : ''
      alert(`Error deleting product: ${errorMessage}${errorHint}${errorCode}\n\nIf this persists, check your Supabase RLS policies.`)
    }
  }

  const resetForm = () => {
    setFormData({
      gtin: '',
      product_name: '',
      brand: '',
      generic_name: '',
      manufacturer: '',
      country: '',
      registration_no: '',
      registration_date: '',
      license_expiry_date: '',
      dosage_form: '',
      strength: '',
      pack_size: '',
      expiry_date: '',
      shelf_life: '',
      packaging_type: '',
      marketing_authorization_holder: '',
      local_technical_representative: ''
    })
  }

  // Helper function to get value from multiple possible column names
  const getFieldValue = (product, ...possibleKeys) => {
    for (const key of possibleKeys) {
      if (product[key] !== null && product[key] !== undefined && product[key] !== '') {
        return product[key]
      }
    }
    return null
  }

  // Helper to get product name (handles actual database column names)
  const getProductName = (product) => {
    return getFieldValue(product, 'product_brand_name', 'product_name', 'name', 'product', 'Product Name', 'brand') || 'N/A'
  }

  // Helper to get brand
  const getBrand = (product) => {
    return getFieldValue(product, 'brand', 'Brand', 'product_brand_name')
  }

  // Helper to get manufacturer
  const getManufacturer = (product) => {
    return getFieldValue(product, 'manufacturer_name', 'manufacturer', 'Manufacturer') || 'N/A'
  }

  // Helper to get country
  const getCountry = (product) => {
    return getFieldValue(product, 'manufacturer_country', 'country', 'Country')
  }

  // Helper to get strength
  const getStrength = (product) => {
    return getFieldValue(product, 'dosage_strength', 'strength', 'Strength')
  }

  // Helper to get license expiry date
  const getLicenseExpiryDate = (product) => {
    return getFieldValue(product, 'expiry_date', 'license_expiry_date', 'licenseExpiryDate', 'License Expiry Date')
  }

  const filteredProducts = products.filter(product => {
    const searchLower = searchTerm.toLowerCase()
    const productName = (getProductName(product) || '').toLowerCase()
    const gtin = (product.gtin || '').toLowerCase()
    const brand = (getBrand(product) || '').toLowerCase()
    const genericName = (getFieldValue(product, 'generic_name', 'genericName', 'Generic Name') || '').toLowerCase()
    const manufacturer = (getManufacturer(product) || '').toLowerCase()
    
    return productName.includes(searchLower) ||
           gtin.includes(searchLower) ||
           brand.includes(searchLower) ||
           genericName.includes(searchLower) ||
           manufacturer.includes(searchLower)
  })

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
          <h1 className="text-3xl font-bold text-gray-900">Products</h1>
          <p className="text-gray-600 mt-2">Manage verified drug products in the system</p>
        </div>
        <button
          onClick={() => {
            resetForm()
            setEditingProduct(null)
            setShowModal(true)
          }}
          className="flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
        >
          <Plus size={20} />
          Add Product
        </button>
      </div>

      {/* Search */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={20} />
        <input
          type="text"
          placeholder="Search products by name, GTIN, brand, or generic name..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="w-full pl-10 pr-4 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
        />
      </div>

      {/* Products Table */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Product
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  GTIN
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Manufacturer
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Registration
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Dosage & Strength
                </th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredProducts.map((product) => (
                <tr key={product.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4">
                    <div className="text-sm font-medium text-gray-900">
                      {getProductName(product)}
                    </div>
                    {getBrand(product) && (
                      <div className="text-xs text-gray-500 mt-1">Brand: {getBrand(product)}</div>
                    )}
                    {getFieldValue(product, 'generic_name', 'genericName', 'Generic Name') && (
                      <div className="text-sm text-gray-500">{getFieldValue(product, 'generic_name', 'genericName', 'Generic Name')}</div>
                    )}
                    {getStrength(product) && (
                      <div className="text-xs text-gray-400 mt-1">Strength: {getStrength(product)}</div>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900 font-mono">{product.gtin}</div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-sm text-gray-900">
                      {getManufacturer(product)}
                    </div>
                    {getCountry(product) && (
                      <div className="text-xs text-gray-500">
                        {getCountry(product)}
                      </div>
                    )}
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-sm text-gray-900">
                      {getFieldValue(product, 'registration_no', 'rfda_reg_no', 'registration_number', 'Registration No') || 'N/A'}
                    </div>
                    {getLicenseExpiryDate(product) && (
                      <div className="text-xs text-gray-500">
                        Expires: {new Date(getLicenseExpiryDate(product)).toLocaleDateString()}
                      </div>
                    )}
                    {!getLicenseExpiryDate(product) && (
                      <div className="text-xs text-gray-400">No expiry date</div>
                    )}
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-sm text-gray-900">{product.dosage_form || 'N/A'}</div>
                    {getStrength(product) && (
                      <div className="text-xs text-gray-500">Strength: {getStrength(product)}</div>
                    )}
                    {product.pack_size && (
                      <div className="text-xs text-gray-500">Pack: {product.pack_size}</div>
                    )}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <div className="flex items-center justify-end gap-2">
                      <button
                        onClick={() => {
                          setSelectedProduct(product)
                          setShowDetailsModal(true)
                        }}
                        className="text-primary-600 hover:text-primary-700"
                        title="View Details"
                      >
                        <Eye size={18} />
                      </button>
                      <button
                        onClick={() => handleEdit(product)}
                        className="text-primary-600 hover:text-primary-900"
                        title="Edit"
                      >
                        <Edit size={18} />
                      </button>
                      <button
                        onClick={() => handleDelete(product.id)}
                        className="text-red-600 hover:text-red-900"
                        title="Delete"
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
        {filteredProducts.length === 0 && (
          <div className="text-center py-12 text-gray-500">
            No products found
          </div>
        )}
      </div>

      {/* Product Details Modal */}
      {showDetailsModal && selectedProduct && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl p-6 w-full max-w-4xl max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-2xl font-bold text-gray-900">Product Details</h2>
              <button
                onClick={() => {
                  setShowDetailsModal(false)
                  setSelectedProduct(null)
                }}
                className="text-gray-400 hover:text-gray-600"
              >
                <X size={24} />
              </button>
            </div>

            <div className="space-y-6">
              {/* Basic Information */}
              <div>
                <h3 className="text-lg font-semibold text-gray-900 mb-3 flex items-center gap-2">
                  <Package className="text-primary-600" size={20} />
                  Basic Information
                </h3>
                <div className="grid grid-cols-2 gap-4 bg-gray-50 p-4 rounded-lg">
                  <div>
                    <label className="text-sm font-medium text-gray-500">GTIN</label>
                    <p className="text-sm text-gray-900 font-mono mt-1">{selectedProduct.gtin || 'N/A'}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Product Name</label>
                    <p className="text-sm text-gray-900 mt-1">
                      {getProductName(selectedProduct)}
                    </p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Brand</label>
                    <p className="text-sm text-gray-900 mt-1">
                      {getBrand(selectedProduct) || 'N/A'}
                    </p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Generic Name</label>
                    <p className="text-sm text-gray-900 mt-1">
                      {selectedProduct.generic_name || selectedProduct.genericName || selectedProduct['Generic Name'] || 'N/A'}
                    </p>
                  </div>
                </div>
              </div>

              {/* Manufacturer Information */}
              <div>
                <h3 className="text-lg font-semibold text-gray-900 mb-3">Manufacturer Information</h3>
                <div className="grid grid-cols-2 gap-4 bg-gray-50 p-4 rounded-lg">
                  <div>
                    <label className="text-sm font-medium text-gray-500">Manufacturer</label>
                    <p className="text-sm text-gray-900 mt-1">
                      {getManufacturer(selectedProduct)}
                    </p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Country</label>
                    <p className="text-sm text-gray-900 mt-1">
                      {getCountry(selectedProduct) || 'N/A'}
                    </p>
                  </div>
                </div>
              </div>

              {/* Registration Information */}
              <div>
                <h3 className="text-lg font-semibold text-gray-900 mb-3">Registration Information</h3>
                <div className="grid grid-cols-2 gap-4 bg-gray-50 p-4 rounded-lg">
                  <div>
                    <label className="text-sm font-medium text-gray-500">Registration Number</label>
                    <p className="text-sm text-gray-900 mt-1">
                      {selectedProduct.registration_no || selectedProduct.rfda_reg_no || 'N/A'}
                    </p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Registration Date</label>
                    <p className="text-sm text-gray-900 mt-1">
                      {selectedProduct.registration_date 
                        ? new Date(selectedProduct.registration_date).toLocaleDateString() 
                        : 'N/A'}
                    </p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">License Expiry Date</label>
                    <p className="text-sm text-gray-900 mt-1">
                      {getLicenseExpiryDate(selectedProduct)
                        ? new Date(getLicenseExpiryDate(selectedProduct)).toLocaleDateString() 
                        : 'N/A'}
                    </p>
                  </div>
                </div>
              </div>

              {/* Product Specifications */}
              <div>
                <h3 className="text-lg font-semibold text-gray-900 mb-3">Product Specifications</h3>
                <div className="grid grid-cols-2 gap-4 bg-gray-50 p-4 rounded-lg">
                  <div>
                    <label className="text-sm font-medium text-gray-500">Dosage Form</label>
                    <p className="text-sm text-gray-900 mt-1">{selectedProduct.dosage_form || 'N/A'}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Strength</label>
                    <p className="text-sm text-gray-900 mt-1">{getStrength(selectedProduct) || 'N/A'}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Pack Size</label>
                    <p className="text-sm text-gray-900 mt-1">{selectedProduct.pack_size || 'N/A'}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Packaging Type</label>
                    <p className="text-sm text-gray-900 mt-1">{selectedProduct.packaging_type || 'N/A'}</p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Expiry Date</label>
                    <p className="text-sm text-gray-900 mt-1">
                      {selectedProduct.expiry_date 
                        ? new Date(selectedProduct.expiry_date).toLocaleDateString() 
                        : 'N/A'}
                    </p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Shelf Life</label>
                    <p className="text-sm text-gray-900 mt-1">{selectedProduct.shelf_life || 'N/A'}</p>
                  </div>
                </div>
              </div>

              {/* Authorization Information */}
              <div>
                <h3 className="text-lg font-semibold text-gray-900 mb-3">Authorization Information</h3>
                <div className="grid grid-cols-1 gap-4 bg-gray-50 p-4 rounded-lg">
                  <div>
                    <label className="text-sm font-medium text-gray-500">Marketing Authorization Holder</label>
                    <p className="text-sm text-gray-900 mt-1">
                      {selectedProduct.marketing_authorization_holder || selectedProduct.marketing_auth_holder || 'N/A'}
                    </p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Local Technical Representative</label>
                    <p className="text-sm text-gray-900 mt-1">
                      {selectedProduct.local_technical_representative || selectedProduct.local_tech_rep || 'N/A'}
                    </p>
                  </div>
                </div>
              </div>

              {/* Metadata */}
              <div>
                <h3 className="text-lg font-semibold text-gray-900 mb-3">Metadata</h3>
                <div className="grid grid-cols-2 gap-4 bg-gray-50 p-4 rounded-lg">
                  <div>
                    <label className="text-sm font-medium text-gray-500">Created At</label>
                    <p className="text-sm text-gray-900 mt-1">
                      {selectedProduct.created_at 
                        ? new Date(selectedProduct.created_at).toLocaleString() 
                        : 'N/A'}
                    </p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Updated At</label>
                    <p className="text-sm text-gray-900 mt-1">
                      {selectedProduct.updated_at 
                        ? new Date(selectedProduct.updated_at).toLocaleString() 
                        : 'N/A'}
                    </p>
                  </div>
                  <div>
                    <label className="text-sm font-medium text-gray-500">Product ID</label>
                    <p className="text-sm text-gray-900 font-mono mt-1">{selectedProduct.id || 'N/A'}</p>
                  </div>
                </div>
              </div>

              {/* Raw Data (for debugging) */}
              <details className="mt-4">
                <summary className="text-sm font-medium text-gray-700 cursor-pointer hover:text-gray-900">
                  View Raw Data (Debug)
                </summary>
                <div className="mt-2 bg-gray-900 text-gray-100 p-4 rounded-lg overflow-auto max-h-64">
                  <pre className="text-xs">
                    {JSON.stringify(selectedProduct, null, 2)}
                  </pre>
                </div>
              </details>

              {/* Actions */}
              <div className="flex gap-3 pt-4">
                <button
                  onClick={() => {
                    setShowDetailsModal(false)
                    handleEdit(selectedProduct)
                  }}
                  className="flex-1 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700"
                >
                  Edit Product
                </button>
                <button
                  onClick={() => {
                    setShowDetailsModal(false)
                    setSelectedProduct(null)
                  }}
                  className="flex-1 px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300"
                >
                  Close
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Add/Edit Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl p-6 w-full max-w-4xl max-h-[90vh] overflow-y-auto">
            <h2 className="text-2xl font-bold text-gray-900 mb-4">
              {editingProduct ? 'Edit Product' : 'Add New Product'}
            </h2>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    GTIN *
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.gtin}
                    onChange={(e) => setFormData({ ...formData, gtin: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Product Name *
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.product_name}
                    onChange={(e) => setFormData({ ...formData, product_name: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Brand *
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.brand}
                    onChange={(e) => setFormData({ ...formData, brand: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Generic Name *
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.generic_name}
                    onChange={(e) => setFormData({ ...formData, generic_name: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Manufacturer *
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.manufacturer}
                    onChange={(e) => setFormData({ ...formData, manufacturer: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Country *
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.country}
                    onChange={(e) => setFormData({ ...formData, country: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Registration Number *
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.registration_no}
                    onChange={(e) => setFormData({ ...formData, registration_no: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Registration Date *
                  </label>
                  <input
                    type="date"
                    required
                    value={formData.registration_date}
                    onChange={(e) => setFormData({ ...formData, registration_date: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    License Expiry Date *
                  </label>
                  <input
                    type="date"
                    required
                    value={formData.license_expiry_date}
                    onChange={(e) => setFormData({ ...formData, license_expiry_date: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Dosage Form *
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.dosage_form}
                    onChange={(e) => setFormData({ ...formData, dosage_form: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Strength *
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.strength}
                    onChange={(e) => setFormData({ ...formData, strength: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Pack Size *
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.pack_size}
                    onChange={(e) => setFormData({ ...formData, pack_size: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Expiry Date *
                  </label>
                  <input
                    type="date"
                    required
                    value={formData.expiry_date}
                    onChange={(e) => setFormData({ ...formData, expiry_date: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Shelf Life *
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.shelf_life}
                    onChange={(e) => setFormData({ ...formData, shelf_life: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Packaging Type *
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.packaging_type}
                    onChange={(e) => setFormData({ ...formData, packaging_type: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div className="col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Marketing Authorization Holder *
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.marketing_authorization_holder}
                    onChange={(e) => setFormData({ ...formData, marketing_authorization_holder: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
                <div className="col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Local Technical Representative *
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.local_technical_representative}
                    onChange={(e) => setFormData({ ...formData, local_technical_representative: e.target.value })}
                    className="w-full px-3 py-2 bg-white border border-gray-400 rounded-lg focus:ring-2 focus:ring-primary-500 text-black"
                  />
                </div>
              </div>
              <div className="flex gap-3 pt-4">
                <button
                  type="submit"
                  className="flex-1 px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700"
                >
                  {editingProduct ? 'Update' : 'Add'} Product
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setShowModal(false)
                    setEditingProduct(null)
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

export default Products


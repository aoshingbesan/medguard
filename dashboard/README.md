# MedGuard Admin Dashboard

A React-based admin dashboard for managing the MedGuard mobile app backend. This dashboard allows administrators to manage pharmacies, products, view statistics, and handle unverified drug reports.

## Features

- **Dashboard Overview**: View system statistics including:
  - Total users
  - Verified drugs count
  - Unverified drugs count
  - Total reports

- **Pharmacy Management**: 
  - Add, edit, and delete pharmacies
  - Search and filter pharmacies
  - View pharmacy details (location, contact info, etc.)

- **Product Management**:
  - Add, edit, and delete drug products
  - Search products by name, GTIN, brand, or generic name
  - Manage product details (manufacturer, registration, expiry dates, etc.)

- **Reports Management**:
  - View all unverified drug reports
  - Filter reports by status (pending, resolved, rejected)
  - Update report status
  - View detailed report information including location and photos

## Prerequisites

- Node.js 18+ and npm/yarn
- Supabase account with MedGuard database set up
- Supabase project URL and anon key

## Installation

1. **Navigate to the dashboard directory**:
   ```bash
   cd dashboard
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Set up environment variables**:
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and add your Supabase credentials:
   ```env
   VITE_SUPABASE_URL=your_supabase_project_url
   VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

## Database Setup

Before using the dashboard, ensure your Supabase database has the following tables:

### 1. Products Table
Already exists in your database. The dashboard will work with the existing `products` table.

### 2. Pharmacies Table
Already exists in your database. The dashboard will work with the existing `pharmacies` table.

### 3. Reports Table (NEW)
You need to create a `reports` table to store unverified drug reports. Run this SQL in your Supabase SQL Editor:

```sql
CREATE TABLE IF NOT EXISTS reports (
  id BIGSERIAL PRIMARY KEY,
  gtin TEXT,
  product_name TEXT,
  product TEXT,
  generic_name TEXT,
  manufacturer TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  address TEXT,
  google_maps_link TEXT,
  photo_url TEXT,
  notes TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'resolved', 'rejected')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_reports_status ON reports(status);
CREATE INDEX idx_reports_created_at ON reports(created_at);
```

### 4. Users Table (Optional)
If you want to track user count, you can create a users table or use Supabase Auth. For now, the dashboard shows 0 users if no users table exists.

## Running the Dashboard

1. **Start the development server**:
   ```bash
   npm run dev
   ```

2. **Open your browser**:
   The dashboard will open at `http://localhost:3000`

## Building for Production

```bash
npm run build
```

The production build will be in the `dist` directory.

## Project Structure

```
dashboard/
├── src/
│   ├── components/
│   │   └── Layout.jsx          # Main layout with sidebar navigation
│   ├── pages/
│   │   ├── Dashboard.jsx        # Dashboard overview with statistics
│   │   ├── Pharmacies.jsx      # Pharmacy management
│   │   ├── Products.jsx        # Product management
│   │   └── Reports.jsx         # Reports management
│   ├── lib/
│   │   └── supabase.js         # Supabase client configuration
│   ├── App.jsx                 # Main app component with routing
│   ├── main.jsx                # Entry point
│   └── index.css               # Global styles
├── package.json
├── vite.config.js
├── tailwind.config.js
└── README.md
```

## Usage

### Managing Pharmacies

1. Navigate to the **Pharmacies** page
2. Click **Add Pharmacy** to add a new pharmacy
3. Fill in the pharmacy details (name, address, contact info, location)
4. Click **Add Pharmacy** to save
5. Use the search bar to find specific pharmacies
6. Click the edit icon to modify a pharmacy
7. Click the delete icon to remove a pharmacy

### Managing Products

1. Navigate to the **Products** page
2. Click **Add Product** to add a new drug product
3. Fill in the product details (GTIN, name, manufacturer, registration info, etc.)
4. Click **Add Product** to save
5. Use the search bar to find products by name, GTIN, brand, or generic name
6. Click the edit icon to modify a product
7. Click the delete icon to remove a product

### Managing Reports

1. Navigate to the **Reports** page
2. View all unverified drug reports submitted by mobile app users
3. Use the filter dropdown to view reports by status
4. Click **View Details** to see full report information
5. For pending reports, you can:
   - Mark as **Resolved** if the drug has been verified and added to the database
   - **Reject** if the report is invalid

## Integration with Mobile App

The mobile app should be updated to save reports to the Supabase `reports` table instead of (or in addition to) sending emails. Update the `rfda_report_screen.dart` file to include:

```dart
// After capturing location and photo, save to Supabase
await _supabase.from('reports').insert({
  'gtin': widget.drugData['gtin'],
  'product_name': widget.drugData['product'],
  'generic_name': widget.drugData['genericName'],
  'manufacturer': widget.drugData['manufacturer'],
  'latitude': _currentPosition!.latitude,
  'longitude': _currentPosition!.longitude,
  'address': _address,
  'google_maps_link': 'https://maps.google.com/?q=${_currentPosition!.latitude},${_currentPosition!.longitude}',
  'photo_url': photoUrl, // Upload photo to Supabase Storage first
  'status': 'pending',
});
```

## Technologies Used

- **React 18**: UI framework
- **React Router**: Client-side routing
- **Supabase JS**: Backend database client
- **Tailwind CSS**: Styling
- **Vite**: Build tool and dev server
- **Lucide React**: Icons

## Troubleshooting

### Database Connection Errors

- Verify your Supabase URL and anon key in `.env`
- Check that your Supabase project is active
- Ensure the required tables exist in your database

### Reports Not Showing

- Ensure the `reports` table has been created
- Check that the mobile app is saving reports to Supabase
- Verify RLS (Row Level Security) policies allow reading reports

### Cannot Add/Edit Items

- Check Supabase RLS policies allow insert/update operations
- Verify you're using the correct table names
- Check browser console for specific error messages

## License

This project is part of the MedGuard application and follows the same license.



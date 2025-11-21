# MedGuard Admin Dashboard - Setup Guide

## Quick Start

### 1. Install Dependencies

```bash
cd dashboard
npm install
```

### 2. Configure Environment Variables

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and add your Supabase credentials:
   ```env
   VITE_SUPABASE_URL=https://your-project-id.supabase.co
   VITE_SUPABASE_ANON_KEY=your-anon-key-here
   ```

   To get your Supabase credentials:
   - Go to your Supabase project dashboard
   - Navigate to **Settings** → **API**
   - Copy the **Project URL** and **anon/public** key

### 3. Set Up Database Tables

Before using the dashboard, ensure your Supabase database has the required tables:

#### Existing Tables (Already in your database)
- ✅ `products` - Already exists
- ✅ `pharmacies` - Already exists

#### New Table Required
- ⚠️ `reports` - You need to create this table

**To create the reports table:**

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Run the SQL script from `database/reports_table.sql`:

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

CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON reports(created_at);
CREATE INDEX IF NOT EXISTS idx_reports_gtin ON reports(gtin);
```

### 4. Configure Row Level Security (RLS)

The dashboard needs access to your Supabase tables. Configure RLS policies:

**⚠️ IMPORTANT: If delete/update operations are not working, run the fix script!**

**Quick Fix (Recommended):**
1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Open and run the script: `database/fix_rls_policies.sql`
   - This script will properly configure RLS policies for both `products` and `pharmacies` tables
   - It includes verification queries to confirm the policies are set correctly

**Option 1: Allow all operations (for admin dashboard)**
```sql
-- For products table
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for admin" ON products FOR ALL USING (true) WITH CHECK (true);

-- For pharmacies table
ALTER TABLE pharmacies ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for admin" ON pharmacies FOR ALL USING (true) WITH CHECK (true);

-- For reports table (already included in reports_table.sql)
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for admin" ON reports FOR ALL USING (true) WITH CHECK (true);
```

**Option 2: Use service role key (more secure)**
- Use the service role key instead of anon key for admin operations
- This bypasses RLS policies
- Update `.env` with `VITE_SUPABASE_SERVICE_KEY` instead of `VITE_SUPABASE_ANON_KEY`
- **Note:** If using service role key, update `dashboard/src/lib/supabase.js` to use `VITE_SUPABASE_SERVICE_KEY`

### 5. Run the Dashboard

```bash
npm run dev
```

The dashboard will open at `http://localhost:3000`

## Updating Mobile App to Save Reports

To enable the mobile app to save reports to Supabase, update `frontend/lib/rfda_report_screen.dart`:

1. Add Supabase storage bucket for photos (optional but recommended)
2. Update the `_sendReport` function to save to Supabase:

```dart
// After capturing location and photo
try {
  // Upload photo to Supabase Storage (optional)
  String? photoUrl;
  if (_capturedImage != null) {
    final file = File(_capturedImage!.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _supabase.storage
        .from('report-photos')
        .upload(fileName, file);
    
    photoUrl = _supabase.storage
        .from('report-photos')
        .getPublicUrl(fileName);
  }

  // Save report to Supabase
  await _supabase.from('reports').insert({
    'gtin': widget.drugData['gtin'] ?? '',
    'product_name': widget.drugData['product'] ?? '',
    'generic_name': widget.drugData['genericName'] ?? '',
    'manufacturer': widget.drugData['manufacturer'] ?? '',
    'latitude': _currentPosition!.latitude,
    'longitude': _currentPosition!.longitude,
    'address': _address ?? '',
    'google_maps_link': 'https://maps.google.com/?q=${_currentPosition!.latitude},${_currentPosition!.longitude}',
    'photo_url': photoUrl ?? '',
    'status': 'pending',
  });

  // Show success message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Report submitted successfully')),
  );
  
  Navigator.pop(context);
} catch (e) {
  // Handle error
  setState(() {
    _error = 'Failed to submit report: $e';
  });
}
```

## Troubleshooting

### Dashboard won't connect to Supabase

- ✅ Check `.env` file exists and has correct values
- ✅ Verify Supabase URL and key are correct
- ✅ Ensure Supabase project is active
- ✅ Check browser console for specific errors

### Cannot add/edit pharmacies or products

- ✅ Check RLS policies allow insert/update operations
- ✅ Verify table names match exactly (`products`, `pharmacies`)
- ✅ Check browser console for specific error messages
- ✅ Ensure you're using the correct Supabase key (anon key or service role key)

### Reports not showing

- ✅ Verify `reports` table exists in Supabase
- ✅ Check RLS policies allow reading reports
- ✅ Ensure mobile app is saving reports to Supabase
- ✅ Check reports table has data: `SELECT * FROM reports;`

### Statistics showing 0

- ✅ Verify tables have data
- ✅ Check RLS policies allow counting
- ✅ For user count, you may need to create a users table or use Supabase Auth

## Next Steps

1. ✅ Set up environment variables
2. ✅ Create reports table in Supabase
3. ✅ Configure RLS policies
4. ✅ Update mobile app to save reports
5. ✅ Test dashboard functionality
6. ✅ Deploy dashboard (optional)

## Deployment

To deploy the dashboard:

```bash
npm run build
```

The production build will be in the `dist` directory. You can deploy this to:
- Vercel
- Netlify
- GitHub Pages
- Any static hosting service

Remember to set environment variables in your hosting platform!



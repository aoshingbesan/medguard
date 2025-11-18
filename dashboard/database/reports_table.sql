-- Create reports table for storing unverified drug reports from mobile app
-- Run this SQL in your Supabase SQL Editor

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

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON reports(created_at);
CREATE INDEX IF NOT EXISTS idx_reports_gtin ON reports(gtin);

-- Create a function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to update updated_at on row update
CREATE TRIGGER update_reports_updated_at BEFORE UPDATE ON reports
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all operations (adjust based on your security needs)
-- For admin dashboard, you may want to allow all operations
CREATE POLICY "Allow all operations for authenticated users" ON reports
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- Alternative: More restrictive policy (uncomment if needed)
-- CREATE POLICY "Allow read for authenticated users" ON reports
--     FOR SELECT
--     USING (true);
-- 
-- CREATE POLICY "Allow insert for authenticated users" ON reports
--     FOR INSERT
--     WITH CHECK (true);
-- 
-- CREATE POLICY "Allow update for authenticated users" ON reports
--     FOR UPDATE
--     USING (true)
--     WITH CHECK (true);
-- 
-- CREATE POLICY "Allow delete for authenticated users" ON reports
--     FOR DELETE
--     USING (true);



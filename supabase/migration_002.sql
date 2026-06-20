-- Add display_name and resource_type columns to favorites table
ALTER TABLE favorites ADD COLUMN IF NOT EXISTS display_name TEXT;
ALTER TABLE favorites ADD COLUMN IF NOT EXISTS resource_type TEXT;

-- Add folder_path column to favorites table
ALTER TABLE favorites ADD COLUMN IF NOT EXISTS folder_path TEXT;

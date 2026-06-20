-- Add username column to profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS username TEXT;

-- Create OTP tracking table for rate-limiting and re-verification
CREATE TABLE IF NOT EXISTS otp_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('password_reset', 'email_change')),
  attempts INTEGER DEFAULT 0,
  expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '10 minutes'),
  used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE otp_requests ENABLE ROW LEVEL SECURITY;

-- Users can read their own OTP requests
CREATE POLICY "Users can read own OTP requests"
  ON otp_requests FOR SELECT
  USING (auth.jwt() ->> 'email' = email);

-- Users can insert OTP requests for their own email
CREATE POLICY "Users can insert own OTP requests"
  ON otp_requests FOR INSERT
  WITH CHECK (auth.jwt() ->> 'email' = email);

-- Users can update own OTP requests (increment attempts)
CREATE POLICY "Users can update own OTP requests"
  ON otp_requests FOR UPDATE
  USING (auth.jwt() ->> 'email' = email);

-- Storage RLS policies for avatars bucket (run after creating the bucket in dashboard)
-- CREATE POLICY "Avatar images are publicly viewable"
--   ON storage.objects FOR SELECT
--   USING (bucket_id = 'avatars');

-- CREATE POLICY "Users can upload their own avatar"
--   ON storage.objects FOR INSERT
--   WITH CHECK (
--     bucket_id = 'avatars'
--     AND auth.role() = 'authenticated'
--     AND (storage.foldername(name))[1] = auth.uid()::text
--   );

-- CREATE POLICY "Users can update own avatar"
--   ON storage.objects FOR UPDATE
--   USING (
--     bucket_id = 'avatars'
--     AND (storage.foldername(name))[1] = auth.uid()::text
--   );

-- CREATE POLICY "Users can delete own avatar"
--   ON storage.objects FOR DELETE
--   USING (
--     bucket_id = 'avatars'
--     AND (storage.foldername(name))[1] = auth.uid()::text
--   );

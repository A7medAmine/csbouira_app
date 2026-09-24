-- Migration 004: security hardening
--
-- 1. Leaderboard integrity: clients can no longer INSERT into `uploads`
--    directly (anyone with the public anon key could insert thousands of rows
--    and top the leaderboard). The app now calls `record_upload`, which
--    validates input and rate-limits per user.
--
--    NOTE: this limits abuse but does not prove a file was really uploaded.
--    The complete fix is to have the Apps Script upload backend insert the
--    row with the service-role key after the Drive upload succeeds, and then
--    revoke EXECUTE on record_upload from `authenticated`.
--
-- 2. Profiles are created by a trigger on auth.users, so signup works even
--    when email confirmation is enabled (no session yet, so a client-side
--    insert is rejected by RLS).
--
-- 3. otp_requests: users could UPDATE their own rows and reset `attempts`.
--    The app does not use this table; the UPDATE policy is dropped.

-- 1. uploads --------------------------------------------------------------

DROP POLICY IF EXISTS "Users can insert their own uploads" ON public.uploads;

CREATE OR REPLACE FUNCTION public.record_upload(
  p_file_name   TEXT,
  p_module_name TEXT,
  p_grade       TEXT,
  p_semester    TEXT,
  p_file_type   TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_recent  INTEGER;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated' USING ERRCODE = '42501';
  END IF;

  IF coalesce(length(p_file_name), 0)   NOT BETWEEN 1 AND 255
     OR coalesce(length(p_module_name), 0) NOT BETWEEN 1 AND 255
     OR coalesce(length(p_grade), 0)       NOT BETWEEN 1 AND 50
     OR coalesce(length(p_semester), 0)    NOT BETWEEN 1 AND 10
     OR p_file_type NOT IN ('Cours', 'Summary', 'TP', 'TD', 'Test', 'Exam', 'Other')
  THEN
    RAISE EXCEPTION 'Invalid upload metadata' USING ERRCODE = '22023';
  END IF;

  -- Serialize concurrent calls for the same user so the rate limit holds.
  PERFORM pg_advisory_xact_lock(hashtext(v_user_id::TEXT));

  SELECT count(*) INTO v_recent
  FROM public.uploads
  WHERE user_id = v_user_id
    AND created_at > now() - INTERVAL '1 hour';

  IF v_recent >= 20 THEN
    RAISE EXCEPTION 'Upload rate limit exceeded' USING ERRCODE = '54000';
  END IF;

  INSERT INTO public.uploads (user_id, file_name, module_name, grade, semester, file_type)
  VALUES (v_user_id, p_file_name, p_module_name, p_grade, p_semester, p_file_type);
END;
$$;

REVOKE ALL ON FUNCTION public.record_upload(TEXT, TEXT, TEXT, TEXT, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.record_upload(TEXT, TEXT, TEXT, TEXT, TEXT) TO authenticated;

-- 2. profiles -------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email, avatar_url)
  VALUES (
    NEW.id,
    coalesce(
      nullif(NEW.raw_user_meta_data ->> 'full_name', ''),
      nullif(NEW.raw_user_meta_data ->> 'name', ''),
      NEW.email,
      'User'
    ),
    coalesce(NEW.email, ''),
    coalesce(
      NEW.raw_user_meta_data ->> 'avatar_url',
      NEW.raw_user_meta_data ->> 'picture'
    )
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Backfill profiles for accounts that signed up while the client-side insert
-- was failing.
INSERT INTO public.profiles (id, full_name, email)
SELECT
  u.id,
  coalesce(nullif(u.raw_user_meta_data ->> 'full_name', ''), u.email, 'User'),
  coalesce(u.email, '')
FROM auth.users u
LEFT JOIN public.profiles p ON p.id = u.id
WHERE p.id IS NULL;

-- 3. otp_requests ---------------------------------------------------------

-- The table only exists if migration_002 was applied.
DO $$
BEGIN
  IF to_regclass('public.otp_requests') IS NOT NULL THEN
    DROP POLICY IF EXISTS "Users can update own OTP requests" ON public.otp_requests;
  END IF;
END;
$$;

-- Trigger functions must not be callable through the REST API.
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM PUBLIC, anon, authenticated;

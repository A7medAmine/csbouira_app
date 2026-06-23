-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Users can read their own profile
CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

-- Users can insert their own profile
CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- Create favorites table for server-side management
CREATE TABLE IF NOT EXISTS favorites (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  item_type TEXT NOT NULL,
  item_path TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, item_type, item_path)
);

ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own favorites"
  ON favorites FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own favorites"
  ON favorites FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own favorites"
  ON favorites FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Upload tracking
CREATE TABLE IF NOT EXISTS uploads (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  file_name text not null,
  module_name text not null,
  grade text not null,
  semester text not null,
  file_type text not null,
  created_at timestamptz default now() not null
);

alter table uploads enable row level security;

create policy "Users can view their own uploads" on uploads
  for select using (auth.uid() = user_id);

create policy "Users can insert their own uploads" on uploads
  for insert with check (auth.uid() = user_id);

-- Leaderboard: expose aggregated upload counts (bypass RLS via SECURITY DEFINER)

create or replace function get_leaderboard(limit_count integer default 20)
returns table(
  user_id uuid,
  full_name text,
  avatar_url text,
  upload_count bigint,
  rank bigint
)
language plpgsql
security definer
set search_path = ''
as $$
begin
  return query
  select
    p.id,
    p.full_name,
    p.avatar_url,
    count(u.id),
    row_number() over (order by count(u.id) desc)
  from public.profiles p
  join public.uploads u on u.user_id = p.id
  group by p.id, p.full_name, p.avatar_url
  having count(u.id) > 0
  order by upload_count desc
  limit limit_count;
end;
$$;

create or replace function get_user_rank(p_user_id uuid)
returns table(
  user_rank bigint,
  upload_count bigint
)
language plpgsql
security definer
set search_path = ''
as $$
begin
  return query
  select ranked.rank, ranked.upload_count
  from (
    select
      p.id,
      count(u.id) as upload_count,
      row_number() over (order by count(u.id) desc) as rank
    from public.profiles p
    join public.uploads u on u.user_id = p.id
    group by p.id
    having count(u.id) > 0
  ) ranked
  where ranked.id = p_user_id;
end;
$$;

grant execute on function get_leaderboard to anon, authenticated;
grant execute on function get_user_rank to anon, authenticated;

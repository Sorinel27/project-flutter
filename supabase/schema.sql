-- Minimal user profile table for a class project.
-- Run this in Supabase SQL Editor.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  full_name text,
  avatar_url text,
  updated_at timestamptz default now()
);

alter table public.profiles enable row level security;

-- Users can read their own profile
create policy "Profiles are viewable by owner" on public.profiles
for select
to authenticated
using (auth.uid() = id);

-- Users can insert their own profile
create policy "Users can insert own profile" on public.profiles
for insert
to authenticated
with check (auth.uid() = id);

-- Users can update their own profile
create policy "Users can update own profile" on public.profiles
for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

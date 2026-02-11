-- Enable UUID extension if not already enabled
create extension if not exists "uuid-ossp";

-- Table: CinemApp_user_interactions
create table if not exists "CinemApp_user_interactions" (
    id uuid primary key default uuid_generate_v4(),
    profile_id text not null, -- Can be uuid if using strict auth, using text for flexibility as per prompt
    movie_id integer not null, -- TMDB Movie ID
    status text check (status in ('watched', 'ignored')),
    updated_at timestamp with time zone default now(),
    
    unique(profile_id, movie_id) -- Ensure one interaction per movie per user
);

-- Table: CinemApp_daily_selections
create table if not exists "CinemApp_daily_selections" (
    id uuid primary key default uuid_generate_v4(),
    profile_id text not null,
    date date not null,
    movie_ids jsonb not null, -- Array of integer movie IDs
    created_at timestamp with time zone default now(),
    
    unique(profile_id, date) -- One selection per user per day
);

-- Enable RLS (Row Level Security) - Best Practice, even if we just use anon key for now
alter table "CinemApp_user_interactions" enable row level security;
alter table "CinemApp_daily_selections" enable row level security;

-- Policies (Open for anon for this specific task requirements, but in prod should be stricter)
-- For the purpose of this task, we will allow all operations for anon if they match the profile_id (conceptually)
-- Since we don't have a real auth system specified, we verify profile_id in client logic, 
-- but for RLS we might just allow all for the anon role for simplicity as per instructions to not overcomplicate auth 
-- if not strictly requested, but "No simplification" suggests robust.
-- However, without Supabase Auth involved, we can't easily check auth.uid().
-- So we will create a policy that allows everything for the anon role.
create policy "Enable all access for anon" on "CinemApp_user_interactions"
as permissive for all
to anon
using (true)
with check (true);

create policy "Enable all access for anon" on "CinemApp_daily_selections"
as permissive for all
to anon
using (true)
with check (true);

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- PROFILES (Links to auth.users)
create table profiles (
  id uuid references auth.users not null primary key,
  email text,
  role text check (role in ('manager', 'employee')) default 'employee',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- LEADS (The core data)
create table leads (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users not null, -- Owner of the lead
  name text,
  email text,
  company text,
  role text,
  phone text,
  enrichment_status text check (enrichment_status in ('pending', 'enriched', 'failed')) default 'pending',
  enrichment_data jsonb, -- Stores the AI summary
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- AUDIT LOGS (Compliance & Governance)
create table audit_logs (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users,
  action text not null, -- e.g., 'Enrichment Requested'
  details text, -- e.g., 'Lead ID: 123'
  data_hash text, -- Proof of what was sent (for scrubbing verification)
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- ROW LEVEL SECURITY (RLS) POLICY

-- 1. Profiles: Users can read their own profile.
alter table profiles enable row level security;
create policy "Users can view own profile" on profiles for select using (auth.uid() = id);

-- 2. Leads:
-- Managers: Can view ALL leads.
-- Employees: Can view ONLY their own leads.
alter table leads enable row level security;

create policy "Employees view own leads" on leads for select
using (auth.uid() = user_id);

create policy "Managers view all leads" on leads for select
using (
  exists (
    select 1 from profiles
    where id = auth.uid() and role = 'manager'
  )
);

create policy "Users insert own leads" on leads for insert
with check (auth.uid() = user_id);

create policy "Users update own leads" on leads for update
using (
  auth.uid() = user_id or
  exists (select 1 from profiles where id = auth.uid() and role = 'manager')
);

-- 3. Audit Logs:
-- Read: Only Managers.
-- Insert: System/Functions can insert (authenticated users triggering actions).
alter table audit_logs enable row level security;

create policy "Managers view audit logs" on audit_logs for select
using (
  exists (
    select 1 from profiles
    where id = auth.uid() and role = 'manager'
  )
);

create policy "Users can insert audit logs" on audit_logs for insert
with check (auth.uid() = user_id);

-- TRIGGER: Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, role)
  values (new.id, new.email, 'employee'); -- Default to employee
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

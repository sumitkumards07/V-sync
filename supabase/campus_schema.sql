create extension if not exists pgcrypto;

create table if not exists public.mess_menus (
  id uuid primary key default gen_random_uuid(),
  served_on date not null,
  meal_type text not null,
  meal_order int not null default 0,
  title text not null,
  items jsonb not null default '[]'::jsonb,
  rating int,
  created_at timestamptz not null default now()
);

create index if not exists mess_menus_served_on_idx
  on public.mess_menus (served_on, meal_order);

create table if not exists public.travel_buddies (
  id uuid primary key default gen_random_uuid(),
  route text not null,
  trip_date timestamptz not null,
  available_seats int not null check (available_seats >= 0),
  total_seats int not null check (total_seats > 0),
  contact_phone text,
  created_at timestamptz not null default now()
);

create index if not exists travel_buddies_trip_date_idx
  on public.travel_buddies (trip_date);

create table if not exists public.lost_found_posts (
  id uuid primary key default gen_random_uuid(),
  type text not null check (type in ('lost', 'found')),
  title text not null,
  location text not null,
  image_url text,
  is_hidden boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists lost_found_posts_created_at_idx
  on public.lost_found_posts (created_at desc);

alter table public.mess_menus enable row level security;
alter table public.travel_buddies enable row level security;
alter table public.lost_found_posts enable row level security;

drop policy if exists "public read mess menus" on public.mess_menus;
create policy "public read mess menus"
on public.mess_menus
for select
to anon, authenticated
using (true);

drop policy if exists "public read travel buddies" on public.travel_buddies;
create policy "public read travel buddies"
on public.travel_buddies
for select
to anon, authenticated
using (true);

drop policy if exists "public read visible lost found posts" on public.lost_found_posts;
create policy "public read visible lost found posts"
on public.lost_found_posts
for select
to anon, authenticated
using (is_hidden = false);

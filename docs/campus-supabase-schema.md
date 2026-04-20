# Campus Supabase Schema

Only the `Campus` feature set should use Supabase. VTOP and academic data remain fully device-local.

## Runtime setup

Run the app with:

```bash
flutter run \
  --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

The app also accepts your existing web-style variable names:

```bash
flutter run \
  --dart-define=NEXT_PUBLIC_SUPABASE_URL=YOUR_SUPABASE_URL \
  --dart-define=NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

Only pass the project URL and the publishable/anon key to the mobile app. Do not embed the Postgres connection string or database password in client code.

Exam schedule is fetched from VTOP on-device and is not stored in Supabase.

## Suggested tables

### `mess_menus`

```sql
create table public.mess_menus (
  id uuid primary key default gen_random_uuid(),
  served_on date not null,
  meal_type text not null,
  meal_order int not null default 0,
  title text not null,
  items jsonb not null default '[]'::jsonb,
  rating int,
  created_at timestamptz not null default now()
);
```

### `travel_buddies`

```sql
create table public.travel_buddies (
  id uuid primary key default gen_random_uuid(),
  route text not null,
  trip_date timestamptz not null,
  available_seats int not null,
  total_seats int not null,
  contact_phone text,
  created_at timestamptz not null default now()
);
```

### `lost_found_posts`

```sql
create table public.lost_found_posts (
  id uuid primary key default gen_random_uuid(),
  type text not null check (type in ('lost', 'found')),
  title text not null,
  location text not null,
  image_url text,
  is_hidden boolean not null default false,
  created_at timestamptz not null default now()
);
```

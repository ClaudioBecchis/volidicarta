-- ============================================================
-- BookShelf Community - Schema Supabase
-- Incolla questo nel SQL Editor del tuo progetto Supabase
-- ============================================================

-- Tabella profili utenti
create table if not exists profiles (
  id uuid references auth.users on delete cascade primary key,
  username text unique not null,
  created_at timestamptz default now()
);

-- Tabella recensioni pubbliche
create table if not exists public_reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade not null,
  username text not null,
  book_id text not null,
  book_title text not null,
  book_author text not null,
  book_cover_url text,
  book_publisher text,
  book_year text,
  book_genre text,
  rating int not null check (rating between 1 and 5),
  review_title text,
  review_body text,
  read_date text,
  likes_count int default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(user_id, book_id)
);

-- Tabella likes
create table if not exists likes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade not null,
  review_id uuid references public_reviews(id) on delete cascade not null,
  created_at timestamptz default now(),
  unique(user_id, review_id)
);

-- ── Row Level Security ───────────────────────────────────────

alter table profiles enable row level security;
alter table public_reviews enable row level security;
alter table likes enable row level security;

-- Profiles: tutti possono leggere, solo il proprietario può modificare
create policy "profiles_select" on profiles for select using (true);
create policy "profiles_insert" on profiles for insert with check (auth.uid() = id);
create policy "profiles_update" on profiles for update using (auth.uid() = id);

-- Public reviews: tutti possono leggere, autenticati possono inserire/modificare/eliminare i propri
create policy "reviews_select" on public_reviews for select using (true);
create policy "reviews_insert" on public_reviews for insert with check (auth.uid() = user_id);
create policy "reviews_update" on public_reviews for update using (auth.uid() = user_id);
create policy "reviews_delete" on public_reviews for delete using (auth.uid() = user_id);

-- Likes: tutti possono leggere, autenticati possono inserire/eliminare i propri
create policy "likes_select" on likes for select using (true);
create policy "likes_insert" on likes for insert with check (auth.uid() = user_id);
create policy "likes_delete" on likes for delete using (auth.uid() = user_id);

-- ── Funzione per aggiornare likes_count ─────────────────────

create or replace function update_likes_count()
returns trigger as $$
begin
  if TG_OP = 'INSERT' then
    update public_reviews set likes_count = likes_count + 1 where id = NEW.review_id;
  elsif TG_OP = 'DELETE' then
    update public_reviews set likes_count = greatest(0, likes_count - 1) where id = OLD.review_id;
  end if;
  return null;
end;
$$ language plpgsql security definer set search_path = '';

create trigger likes_count_trigger
after insert or delete on likes
for each row execute function update_likes_count();

-- ── Indici per performance ───────────────────────────────────

create index if not exists idx_reviews_created on public_reviews(created_at desc);
create index if not exists idx_reviews_user on public_reviews(user_id);
create index if not exists idx_likes_review on likes(review_id);
create index if not exists idx_likes_user on likes(user_id);

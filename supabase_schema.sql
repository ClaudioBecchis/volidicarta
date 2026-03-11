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


-- ═══════════════════════════════════════════════════════════════════════════
-- FORUM
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Tabelle ──────────────────────────────────────────────────────────────

create table if not exists forum_threads (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  username text not null,
  title text not null,
  body text,
  category text not null default 'Generale',
  created_at timestamptz default now(),
  replies_count int default 0,
  likes_count int default 0
);

create table if not exists forum_replies (
  id uuid default gen_random_uuid() primary key,
  thread_id uuid references forum_threads on delete cascade not null,
  user_id uuid references auth.users not null,
  username text not null,
  body text not null,
  created_at timestamptz default now(),
  likes_count int default 0
);

create table if not exists forum_thread_likes (
  user_id uuid references auth.users not null,
  thread_id uuid references forum_threads on delete cascade not null,
  primary key (user_id, thread_id)
);

create table if not exists forum_reply_likes (
  user_id uuid references auth.users not null,
  reply_id uuid references forum_replies on delete cascade not null,
  primary key (user_id, reply_id)
);

-- ── RLS ──────────────────────────────────────────────────────────────────

alter table forum_threads enable row level security;
alter table forum_replies enable row level security;
alter table forum_thread_likes enable row level security;
alter table forum_reply_likes enable row level security;

-- forum_threads
create policy "ft_select" on forum_threads for select using (true);
create policy "ft_insert" on forum_threads for insert with check (auth.uid() = user_id);
create policy "ft_delete" on forum_threads for delete using (auth.uid() = user_id);

-- forum_replies
create policy "fr_select" on forum_replies for select using (true);
create policy "fr_insert" on forum_replies for insert with check (auth.uid() = user_id);
create policy "fr_delete" on forum_replies for delete using (auth.uid() = user_id);

-- forum_thread_likes
create policy "ftl_select" on forum_thread_likes for select using (true);
create policy "ftl_insert" on forum_thread_likes for insert with check (auth.uid() = user_id);
create policy "ftl_delete" on forum_thread_likes for delete using (auth.uid() = user_id);

-- forum_reply_likes
create policy "frl_select" on forum_reply_likes for select using (true);
create policy "frl_insert" on forum_reply_likes for insert with check (auth.uid() = user_id);
create policy "frl_delete" on forum_reply_likes for delete using (auth.uid() = user_id);

-- ── Funzioni per aggiornare contatori ────────────────────────────────────

create or replace function update_forum_thread_likes_count()
returns trigger as $$
begin
  if TG_OP = 'INSERT' then
    update forum_threads set likes_count = likes_count + 1 where id = NEW.thread_id;
  elsif TG_OP = 'DELETE' then
    update forum_threads set likes_count = greatest(0, likes_count - 1) where id = OLD.thread_id;
  end if;
  return null;
end;
$$ language plpgsql security definer set search_path = '';

create trigger forum_thread_likes_count_trigger
after insert or delete on forum_thread_likes
for each row execute function update_forum_thread_likes_count();

create or replace function update_forum_reply_likes_count()
returns trigger as $$
begin
  if TG_OP = 'INSERT' then
    update forum_replies set likes_count = likes_count + 1 where id = NEW.reply_id;
  elsif TG_OP = 'DELETE' then
    update forum_replies set likes_count = greatest(0, likes_count - 1) where id = OLD.reply_id;
  end if;
  return null;
end;
$$ language plpgsql security definer set search_path = '';

create trigger forum_reply_likes_count_trigger
after insert or delete on forum_reply_likes
for each row execute function update_forum_reply_likes_count();

-- ── RPC per replies_count ─────────────────────────────────────────────────

create or replace function increment_replies_count(thread_id_param uuid)
returns void as $$
  update forum_threads set replies_count = replies_count + 1 where id = thread_id_param;
$$ language sql security definer set search_path = '';

create or replace function decrement_replies_count(thread_id_param uuid)
returns void as $$
  update forum_threads set replies_count = greatest(0, replies_count - 1) where id = thread_id_param;
$$ language sql security definer set search_path = '';

-- ── Indici ────────────────────────────────────────────────────────────────

create index if not exists idx_forum_threads_created on forum_threads(created_at desc);
create index if not exists idx_forum_threads_category on forum_threads(category);
create index if not exists idx_forum_replies_thread on forum_replies(thread_id, created_at);
create index if not exists idx_forum_thread_likes_thread on forum_thread_likes(thread_id);
create index if not exists idx_forum_reply_likes_reply on forum_reply_likes(reply_id);


-- ═══════════════════════════════════════════════════════════════════════════
-- IS_ADMIN (permessi amministratore)
-- ═══════════════════════════════════════════════════════════════════════════

alter table profiles add column if not exists is_admin boolean default false;

-- ═══════════════════════════════════════════════════════════════════════════
-- USER REVIEWS (backup cloud recensioni private)
-- ═══════════════════════════════════════════════════════════════════════════

create table if not exists user_reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade not null,
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
  start_date text,
  end_date text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(user_id, book_id)
);

alter table user_reviews enable row level security;

-- Solo il proprietario può vedere/modificare le proprie recensioni private
create policy "ur_select" on user_reviews for select using (auth.uid() = user_id);
create policy "ur_insert" on user_reviews for insert with check (auth.uid() = user_id);
create policy "ur_update" on user_reviews for update using (auth.uid() = user_id);
create policy "ur_delete" on user_reviews for delete using (auth.uid() = user_id);

create index if not exists idx_user_reviews_user on user_reviews(user_id, updated_at desc);

-- ═══════════════════════════════════════════════════════════════════════════
-- USER PRESENCE (utenti online)
-- ═══════════════════════════════════════════════════════════════════════════

-- Aggiunge last_seen alla tabella profiles
alter table profiles add column if not exists last_seen timestamptz;

-- RPC: aggiorna last_seen dell'utente corrente
create or replace function update_presence()
returns void as $$
  update profiles set last_seen = now() where id = auth.uid();
$$ language sql security definer set search_path = '';

-- RPC: restituisce contatori community
create or replace function get_community_stats()
returns json as $$
  select json_build_object(
    'total_users', (select count(*) from profiles),
    'online_users', (select count(*) from profiles where last_seen > now() - interval '5 minutes')
  );
$$ language sql security invoker set search_path = '';

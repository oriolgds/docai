-- Create user_queries_limit table for tracking daily query limits
create table if not exists public.user_queries_limit (
  user_id uuid not null references auth.users(id) on delete cascade,
  query_date date not null,
  remaining_queries integer not null default 5,
  constraint user_queries_limit_pkey primary key (user_id, query_date)
) tablespace pg_default;

-- Create index for efficient date-based queries
create index if not exists idx_user_queries_limit_date 
  on public.user_queries_limit using btree (query_date) 
  tablespace pg_default;

-- Enable Row Level Security
alter table public.user_queries_limit enable row level security;

-- Policy: Users can only view their own query limits
create policy "Users can view own query limits"
  on public.user_queries_limit
  for select
  using (auth.uid() = user_id);

-- Policy: Users can insert their own query limits
create policy "Users can insert own query limits"
  on public.user_queries_limit
  for insert
  with check (auth.uid() = user_id);

-- Policy: Users can update their own query limits
create policy "Users can update own query limits"
  on public.user_queries_limit
  for update
  using (auth.uid() = user_id);

-- Optional: Function to clean up old query limit records (older than 30 days)
create or replace function cleanup_old_query_limits()
returns void
language plpgsql
security definer
as $$
begin
  delete from public.user_queries_limit
  where query_date < current_date - interval '30 days';
end;
$$;

-- Optional: Create a scheduled job to run cleanup weekly
-- Note: This requires pg_cron extension to be enabled
-- select cron.schedule('cleanup-query-limits', '0 0 * * 0', 'select cleanup_old_query_limits()');

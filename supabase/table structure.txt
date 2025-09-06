create table public.user_queries_limit (
  user_id uuid not null,
  query_date date not null,
  remaining_queries integer not null default 5,
  constraint user_queries_limit_pkey primary key (user_id, query_date)
) TABLESPACE pg_default;

create index IF not exists idx_user_queries_limit_date on public.user_queries_limit using btree (query_date) TABLESPACE pg_default;
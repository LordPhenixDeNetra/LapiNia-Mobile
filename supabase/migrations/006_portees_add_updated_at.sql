alter table public.portees
add column if not exists updated_at timestamptz;

update public.portees
set updated_at = coalesce(updated_at, created_at)
where updated_at is null;

alter table public.portees
alter column updated_at set default now();

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_portees_updated_at on public.portees;

create trigger trg_portees_updated_at
before update on public.portees
for each row execute function public.set_updated_at();


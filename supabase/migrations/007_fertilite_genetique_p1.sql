alter table public.lapins
add column if not exists score_fertilite integer check (score_fertilite between 0 and 100);

create index if not exists idx_lapins_user_score_fertilite
on public.lapins(user_id, score_fertilite);

alter table public.alertes
drop constraint if exists alertes_type_check;

alter table public.alertes
add constraint alertes_type_check check (
  type in (
    'MISE_BAS',
    'STOCK_BAS',
    'VACCINATION',
    'PESEE',
    'SANTE',
    'EPIDEMIE',
    'FINANCE',
    'FERTILITE'
  )
);

create index if not exists idx_alertes_type on public.alertes(type);

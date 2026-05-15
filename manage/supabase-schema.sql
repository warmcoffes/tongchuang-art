create extension if not exists pgcrypto;

create table if not exists public.students (
  id uuid primary key default gen_random_uuid(),
  student_name text not null,
  contact_name text not null,
  phone text not null,
  person_type text not null check (person_type in ('child', 'adult')),
  age integer,
  course_name text not null,
  total_lessons integer not null default 0 check (total_lessons >= 0),
  remaining_lessons integer not null default 0 check (remaining_lessons >= 0),
  start_date date,
  expiry_date date,
  note text,
  status text not null default 'active' check (status in ('active', 'low_lessons', 'expired', 'stopped')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students(id) on delete cascade,
  amount numeric(10,2) not null check (amount >= 0),
  method text not null,
  paid_at timestamptz not null default now(),
  note text,
  created_at timestamptz not null default now()
);

create table if not exists public.lesson_logs (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students(id) on delete cascade,
  action_type text not null check (action_type in ('checkin', 'leave', 'makeup', 'adjust')),
  lesson_delta integer not null,
  note text,
  created_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_students_updated_at on public.students;
create trigger trg_students_updated_at
before update on public.students
for each row
execute function public.set_updated_at();

create or replace function public.apply_lesson_log()
returns trigger
language plpgsql
as $$
begin
  update public.students
  set remaining_lessons = greatest(remaining_lessons + new.lesson_delta, 0)
  where id = new.student_id;

  update public.students
  set status = case
    when expiry_date is not null and expiry_date < current_date then 'expired'
    when remaining_lessons <= 2 then 'low_lessons'
    when status = 'stopped' then 'stopped'
    else 'active'
  end
  where id = new.student_id;

  return new;
end;
$$;

drop trigger if exists trg_apply_lesson_log on public.lesson_logs;
create trigger trg_apply_lesson_log
after insert on public.lesson_logs
for each row
execute function public.apply_lesson_log();

alter table public.students enable row level security;
alter table public.payments enable row level security;
alter table public.lesson_logs enable row level security;

create policy "authenticated full access students"
on public.students
for all
to authenticated
using (true)
with check (true);

create policy "authenticated full access payments"
on public.payments
for all
to authenticated
using (true)
with check (true);

create policy "authenticated full access lesson_logs"
on public.lesson_logs
for all
to authenticated
using (true)
with check (true);

grant select, insert, update, delete on public.students to authenticated;
grant select, insert, update, delete on public.payments to authenticated;
grant select, insert, update, delete on public.lesson_logs to authenticated;

create index if not exists idx_students_phone on public.students(phone);
create index if not exists idx_students_name on public.students(student_name);
create index if not exists idx_students_contact on public.students(contact_name);
create index if not exists idx_payments_student_id on public.payments(student_id);
create index if not exists idx_lesson_logs_student_id on public.lesson_logs(student_id);

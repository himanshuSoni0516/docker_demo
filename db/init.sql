create role web_anon nologin;

create table public.tasks (
  id serial primary key,
  title text not null,
  done boolean not null default false
);

insert into public.tasks (title) values
  ('Learn Docker'),
  ('Ship the app'),
  ('Invoice the client');

grant usage on schema public to web_anon;
grant select, insert, update, delete on public.tasks to web_anon;
grant usage, select on sequence tasks_id_seq to web_anon;
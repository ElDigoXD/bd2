-- Implementa en nuestra BD un TRIGGER que registre en una
-- tabla auxiliar todos las operaciones de borrado y
-- actualización de datos en una cualquiera de las tablas
-- de nuestro esquema, guardando operación, usuario, fecha
-- y clave primaria afectada.

create table aux_centro (
	id_aux_centro serial primary key
	,id_centro int
	,fecha timestamp
	,usuario varchar
	,operacion varchar
);

create or replace function audit_centro() 
	returns trigger
	language plpgsql
	as 
$$
begin
	INSERT INTO aux_centro (
    id_centro
    ,fecha
    ,usuario
    ,operacion
  )
	VALUES (
   old.id_centro
   ,now()
   ,user
   ,TG_OP
   );	
	return new;
end;
$$;
	
create or replace trigger audit_centro 
  before update or delete
  on centro
  for each row
  execute PROCEDURE audit_centro();

select * from aux_centro;

UPDATE public.centro
  SET  nombre='Facultadeaasdss'
  WHERE id_centro=1;

select * from aux_centro;

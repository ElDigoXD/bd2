-- Implementa en nuestra BD un TRIGGER que impida borrar
-- datos en una de nuestras tablas.

create or replace trigger evitar_borrado_centro
before delete on centro
for each row
signal sqlstate '45000'
set message_text = 'Eliminar registros de esta tabla no esta permitido';

delete from p1.centro;
-- Crear una vista que incluya las 10 asignaturas con mayor
-- y menor tasa de éxito en el Grado en Ingeniería
-- informática tanto de EINA como de EUPT.

create view vista_tasa_exito as
(select tasa_exito, asignatura.nombre as asignatura, centro.nombre as centro
from asignatura
left join estudio using (id_estudio)
left join centro using (id_centro)
where 
  tasa_exito is not null 
  and estudio.nombre = 'Grado: Ingeniería Informática'
  and centro.nombre = 'Escuela Universitaria Politécnica de Teruel'
ORDER BY tasa_exito desc
limit 10)

union all

(select tasa_exito, asignatura.nombre as asignatura, centro.nombre as centro
from asignatura
left join estudio using (id_estudio)
left join centro using (id_centro)
where 
  tasa_exito is not null 
  and estudio.nombre = 'Grado: Ingeniería Informática'
  and centro.nombre = 'Escuela Universitaria Politécnica de Teruel'
ORDER BY tasa_exito asc
limit 10)

union all

(select tasa_exito, asignatura.nombre as asignatura, centro.nombre as centro
from asignatura
left join estudio using (id_estudio)
left join centro using (id_centro)
where 
  tasa_exito is not null 
  and estudio.nombre = 'Grado: Ingeniería Informática'
  and centro.nombre = 'Escuela de Ingeniería y Arquitectura'
ORDER BY tasa_exito desc
limit 10)

union all

(select tasa_exito, asignatura.nombre as asignatura, centro.nombre as centro
from asignatura
left join estudio using (id_estudio)
left join centro using (id_centro)
where 
  tasa_exito is not null 
  and estudio.nombre = 'Grado: Ingeniería Informática'
  and centro.nombre = 'Escuela de Ingeniería y Arquitectura'
ORDER BY tasa_exito asc
limit 10);

select * from vista_tasa_exito;
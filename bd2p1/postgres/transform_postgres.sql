-- solo grados

DELETE FROM public.tmp_egresados
	WHERE tipo_estudio != 'Grado';

delete from tmp_oferta_y_ocupacion
	WHERE tipo_estudio != 'Grado';

delete from tmp_rendimiento
	WHERE tipo_estudio != 'Grado';

delete from tmp_resultados
WHERE tipo_estudio != 'Grado';

-- "Rendimiento por asignatura y titulación. Deseamos disponer de los datos de los grados de EINA y EUPT."

delete from tmp_rendimiento
where centro != 'Escuela de Ingeniería y Arquitectura' and centro != 'Escuela Universitaria Politécnica de Teruel';

----------------------------------------------
-- Cargar los centros
insert into centro(nombre, localidad)
SELECT distinct oyo.centro as nombre, oyo.localidad as localidad 
FROM public.tmp_oferta_y_ocupacion as oyo;

-- Cargar las mobilidades
insert into public.convenio_de_movilidad(
    curso
  , id_centro
  , programa
  , area_estudios
  , pais
  , universidad
  , plazas_ofertadas
  , plazas_asignadas)
select 
    curso_academico::int as curso
  , cen.id_centro as id_centro
  , nombre_programa_movilidad as programa
  , nombre_area_estudios_mov as area_estudios
  , pais_universidad_acuerdo as pais
  , universidad_acuerdo as universidad
  , plazas_ofertadas_alumnos::int as plazas_ofertadas
  , plazas_asignadas_alumnos_out::int as plazas_asignadas
from public.tmp_mobilidad
   , public.centro as cen
where in_out = 'OUT'
  and cen.nombre = centro;

-- Cargar estudios
INSERT INTO public.estudio(nombre, id_centro)
select
    estudio
  , cen.id_centro
from public.tmp_oferta_y_ocupacion
   , public.centro as cen
where cen.nombre = centro
group by estudio, cen.id_centro;

-- Cargar estudios por curso
insert into public.estudio_por_curso(
     curso
  ,  id_estudio
  ,  tasa_de_exitos
  ,  nota_de_corte
  ,  plazas_ofertadas
  ,  plazas_ocupadas
  ,  abandonos_voluntarios)
select 
  oyo.curso_academico::int
  , e.id_estudio::int
  , r.tasa_exito::float
  , ndc.nota_corte_definitiva_julio::float
  , oyo.plazas_ofertadas::int
  , oyo.plazas_matriculadas::int
  , sum(alumnos_interrumpen_estudios::int) 
from tmp_oferta_y_ocupacion as oyo
left join tmp_resultados r
  on r.centro = oyo.centro
 and r.curso_academico = oyo.curso_academico
 and substring(oyo.estudio from 8) = substring(r.estudio from 3)
left join centro cen
  on cen.nombre = oyo.centro
left join estudio e
  on e.id_centro = cen.id_centro
 and e.nombre = oyo.estudio
left join tmp_notas_de_corte ndc
  on ndc.centro = oyo.centro
 and ndc.estudio = oyo.estudio
 and ndc.curso_academico = oyo.curso_academico
left join tmp_egresados egr
  on egr.curso_academico = oyo.curso_academico
 and egr.estudio = oyo.estudio
 and egr.localidad = cen.localidad
group by 
    egr.localidad
  , egr.estudio
  , egr.curso_academico
  , oyo.curso_academico::int
  , e.id_estudio::int
  , r.tasa_exito::float
  , ndc.nota_corte_definitiva_julio::float
  , oyo.plazas_ofertadas::int
  , oyo.plazas_matriculadas::int;

-- Cargar asignaturas
insert into public.asignatura (
  id_estudio 
  ,nombre 
  ,tasa_exito 
)
select id_estudio, asignatura, avg(tasa_exito::float)
FROM tmp_rendimiento
left join centro cen
  on cen.nombre = centro
left join estudio e
  on e.id_centro = cen.id_centro
 and e.nombre = estudio
GROUP BY 
  id_estudio
  , asignatura;
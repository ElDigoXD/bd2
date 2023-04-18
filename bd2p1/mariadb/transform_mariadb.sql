-- solo grados

DELETE FROM tmp_egresados
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
SELECT distinct 
  oyo.centro as nombre
  , oyo.localidad as localidad
FROM tmp_oferta_y_ocupacion as oyo;

-- Cargar las mobilidades
insert into convenio_de_movilidad(
    curso
  , id_centro
  , programa
  , area_estudios
  , pais
  , universidad
  , plazas_ofertadas
  , plazas_asignadas)
select 
    cast(curso_academico as int) as curso
  , cen.id_centro as id_centro
  , nombre_programa_movilidad as programa
  , nombre_area_estudios_mov as area_estudios
  , pais_universidad_acuerdo as pais
  , universidad_acuerdo as universidad
  , cast(plazas_ofertadas_alumnos as int) as plazas_ofertadas
  , cast(plazas_asignadas_alumnos_out as int) as plazas_asignadas
from tmp_mobilidad
   , centro as cen
where in_out = 'OUT'
  and cen.nombre = centro;

-- Cargar estudios
INSERT INTO estudio(nombre, id_centro)
select
    estudio
  , cen.id_centro
from tmp_oferta_y_ocupacion
   , centro as cen
where cen.nombre = centro
group by estudio, cen.id_centro;

-- Cargar estudios por curso
SET @@SQL_MODE = REPLACE(@@SQL_MODE, 'STRICT_TRANS_TABLES', '');

insert into estudio_por_curso(
     curso
  ,  id_estudio
  ,  tasa_de_exitos
  ,  nota_de_corte
  ,  plazas_ofertadas
  ,  plazas_ocupadas
  ,  abandonos_voluntarios)

select 
  cast(oyo.curso_academico as int)
  , cast(e.id_estudio as int)
  , cast(r.tasa_exito as float)
  , cast(ndc.nota_corte_definitiva_julio as float)
  , cast(oyo.plazas_ofertadas as int)
  , cast(oyo.plazas_matriculadas as int)
  , sum(cast(alumnos_interrumpen_estudios as int)) 
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
  , oyo.curso_academico
  , e.id_estudio
  , r.tasa_exito
  , ndc.nota_corte_definitiva_julio
  , oyo.plazas_ofertadas 
  , oyo.plazas_matriculadas;

-- Cargar asignaturas
insert into asignatura (
  id_estudio 
  ,nombre 
  ,tasa_exito)
select id_estudio, asignatura, avg(cast(tasa_exito as float))
FROM tmp_rendimiento
left join centro cen
  on cen.nombre = centro
left join estudio e
  on e.id_centro = cen.id_centro
 and e.nombre = estudio
GROUP BY 
  id_estudio
  , asignatura;
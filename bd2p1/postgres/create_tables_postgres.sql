create table estudio_por_curso (
  id_estudio_por_curso serial primary key
  ,curso int 
  ,id_estudio int 
  ,tasa_de_exitos float
  ,nota_de_corte float
  ,plazas_ofertadas int 
  ,plazas_ocupadas int 
  ,abandonos_voluntarios int
);

create table estudio (
    id_estudio serial primary key
    ,nombre varchar
    ,id_centro int
);

create table centro (
    id_centro serial primary key
    ,nombre varchar
    ,localidad varchar
);

create table convenio_de_movilidad (
    id_convenio_de_movilidad serial primary key
    ,curso int 
    ,id_centro int
    ,programa varchar
    ,area_estudios varchar
    ,pais varchar
    ,universidad varchar
    ,plazas_ofertadas int 
    ,plazas_asignadas int
);

create table asignatura (
    id_asignatura serial primary key
    ,nombre varchar
    ,tasa_exito float
    ,id_estudio int
);


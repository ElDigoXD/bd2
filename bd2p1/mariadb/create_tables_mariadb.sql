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
    ,nombre varchar(255)
    ,id_centro int
);


create table centro (
    id_centro serial primary key
    ,nombre varchar(255)
    ,localidad varchar(255)
);

create table convenio_de_movilidad (
    id_convenio_de_movilidad serial primary key
    ,curso int 
    ,id_centro int
    ,programa varchar(255)
    ,area_estudios varchar(255)
    ,pais varchar(255)
    ,universidad varchar(255)
    ,plazas_ofertadas int 
    ,plazas_asignadas int
);

create table asignatura (
    id_asignatura serial primary key
    ,nombre varchar(255)
    ,tasa_exito float
    ,id_estudio int
);

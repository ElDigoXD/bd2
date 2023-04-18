# Argumentos para la conexión a través de la cli
psql_args=(
  p1
  -h localhost
  -U p1_user
  -P pager=0
)
# Argumentos para la conexión a través de la cli como root
psql_args_management=(
  postgres
  -h localhost
  -U postgres
)
# Vuelve a crear la base de datos y su usuario
function init_db() {

  
  # Elimina y crea la bbdd
  psql "${psql_args_management[@]}" -c "\
  drop database if exists p1;"
  psql "${psql_args_management[@]}" -c "\
  create database p1;"

  # Crea el usuario con permisos
  psql "${psql_args_management[@]}" -c "\
  drop user if exists p1_user;
  create user p1_user with password 'postgres';"
  
  psql p1 -h localhost -U postgres -c "\
  grant all privileges on schema public to p1_user;"
}

# Id de los archivos requeridos
files=(
  # ● Oferta y ocupación de plazas (de estudios de grado).
  108270 # 21
   96835 # 20
   87665 # 19

  # ● Resultados de las titulaciones (de estudios de grado).
  118234 # 21
  107369 # 20
   95644 # 19

  # ● Notas de corte definitivas del cupo general a estudios de grado.
  109322 # 21
   98173 # 20
   87663 # 19

  # ● Acuerdos de movilidad de estudiantes ERASMUS y SICUE.
  107373 # 21
   95648 # 20
   83980 # 19
  
  # ● Alumnos egresados por titulación.
  118236 # 21
  107371 # 20
   95646 # 19

  # ● Rendimiento por asignatura y titulación.
  118235 # 21
  107370 # 20
   95645 # 19
)

# Descarga los archivos
if [ $(ls data | wc -l) -ne 18 ]
then
  echo "descargando archivos:"
  mkdir data
  for file in ${files[@]}
  do
    printf "  %+6s\n" "$file"
    wget "https://zaguan.unizar.es/record/$file/files/CSV.csv" -O data/$file -q
  done

  # Limpia los datos de un archivo con errores
  grep -e ';Grado;' data/118235 >> data/aux
  mv data/aux data/118235
else
  echo "archivos ya descargados"
fi

# Inicializa la base de datos y sus tablas
init_db
psql "${psql_args[@]}" -f "create_tmp_tables_postgres.sql"

# Inserta los datos en csv a la base de datos sin normalizar
function copy_from_csv() {
  table=$1
  files=${@:2}

  for file in $files
  do
    psql "${psql_args[@]}" -c "\copy $table FROM 'data/$file' DELIMITER ';' CSV HEADER"
  done
}

copy_from_csv "tmp_oferta_y_ocupacion" 108270 96835 87665 
copy_from_csv "tmp_resultados" 118234 107369 95644 
copy_from_csv "tmp_notas_de_corte" 109322 98173 87663 
copy_from_csv "tmp_mobilidad" 107373 95648 83980
copy_from_csv "tmp_egresados" 118236 107371 95646
copy_from_csv "tmp_rendimiento" 118235 107370 95645


# Filtra y normaliza los datos
psql "${psql_args[@]}" -f "create_tables_postgres.sql"
psql "${psql_args[@]}" -f "transform_postgres.sql"

# Elimina las tablas auxiliares
## psql "${psql_args[@]}" -f "delete_tmp_tables_postgres.sql"

# Crea (y ejecuta) el trigger
psql "${psql_args[@]}" -f "trigger_postgres.sql"

# Crea (y consulta) la vista
psql "${psql_args[@]}" -f "vista_postgres.sql" 

# Lanza las consultas
psql "${psql_args[@]}" -f "consulta_1_postgres.sql"
psql "${psql_args[@]}" -f "consulta_2_postgres.sql"

# Crea el usuario profesor de solo lectura
  psql "${psql_args_management[@]}" -c "\
drop user if exists profesor;
create user profesor with password 'postgres';"

psql p1 -h localhost -U postgres -c "\
grant select on all tables in schema public to profesor;"
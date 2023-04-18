# Argumentos para la conexión a través de la cli
mariadb_args=(
  p1
  -h 127.0.0.1
  -u p1_user
  -pmariadb
   -v
)

# Argumentos para la conexión a través de la cli como root
mariadb_args_management=(
  mariadb
  -h 127.0.0.1
  -u root
  -pmariadb
  # -v
)

# Vuelve a crear la base de datos y su usuario
function init_db() {


  # Elimina y crea la bbdd
  mariadb "${mariadb_args_management[@]}" -e \
  "drop database if exists p1;"
  mariadb "${mariadb_args_management[@]}" -e \
  "create database p1;"

  # Crea el usuario con permisos
  mariadb "${mariadb_args_management[@]}" -e "\
  use p1; \
  drop user if exists p1_user; \
  create user 'p1_user'@'%' identified by 'mariadb'; \
  grant all privileges on p1.* to 'p1_user'@'%'; \
  flush privileges;"
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
mariadb "${mariadb_args[@]}" < "create_tmp_tables_mariadb.sql"

# Inserta los datos en csv a la base de datos sin normalizar
function copy_from_csv() {
  table=$1
  files=${@:2}

  for file in $files
  do
    mariadb "${mariadb_args[@]}" -e \
    "LOAD DATA LOCAL INFILE 'data/$file' \
    INTO TABLE $table \
    CHARACTER SET UTF8 \
    FIELDS TERMINATED BY ';' \
    IGNORE 1 LINES;" 
  done
}

copy_from_csv "tmp_oferta_y_ocupacion" 108270 96835 87665 
copy_from_csv "tmp_resultados" 118234 107369 95644 
copy_from_csv "tmp_notas_de_corte" 109322 98173 87663 
copy_from_csv "tmp_mobilidad" 107373 95648 83980
copy_from_csv "tmp_egresados" 118236 107371 95646
copy_from_csv "tmp_rendimiento" 118235 107370 95645



# Filtra y normaliza los datos
mariadb "${mariadb_args[@]}" < "create_tables_mariadb.sql"
mariadb "${mariadb_args[@]}" < "transform_mariadb.sql"

# Elimina las tablas auxiliares
mariadb "${mariadb_args[@]}" < "delete_tmp_tables_mariadb.sql"


# Crea el trigger
mariadb "${mariadb_args[@]}" < "trigger_mariadb.sql"


# Lanza las consultas
mariadb "${mariadb_args[@]}" < "consulta_1_mariadb.sql"
mariadb "${mariadb_args[@]}" < "consulta_2_mariadb.sql"

# Crea el usuario profesor de solo lectura
mariadb "${mariadb_args_management[@]}" -e "\
use p1; \
drop user if exists profesor; \
create user 'profesor'@'%' identified by 'mariadb'; \
grant select on p1.* to 'profesor'@'%'; \
flush privileges; \
SELECT User FROM mysql.user; \
"
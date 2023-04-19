# Práctica 1 bd2

## Instrucciones de uso

Todos los usuarios tienen como contraseña el nombre del SGBD (postgres -> postgres y mariadb -> mariadb).

Los archivos necesarios se descargarán en una subcarpeta "data" si no existen todavía (para evitar los tiempos de descarga).

### PostgreSQL

Entrar en la carpeta "postgres" y ejecutar el script.

```sh
PGPASSWORD=postgres bash postgres.sh
```

### MariaDB/MySQL

Entrar en la carpeta "mariadb" y ejecutar el script.
En el caso de que el cliente sea mysql es necesario editar el script y sustituir el comando `mariadb` por `mysql`, añadir el parámetro `--local-infile=1` a la lista  `mariadb_args` y eliminar el comentario `----------------` del archivo `transform_mariadb.sql`

```sh
bash mariadb.sh
```

# Práctica 2 bd2

## Instrucciones de uso

El usuario y contraseña de la bd es 'root' y 'mariadb' respectivamente.

El puerto de la bd es el 3307 (se ejecuta en un contenedor docker, con el puerto 3306 exportado como 3307).

Para ejecutar el programa, ejecutar el script en el entorno virtual:

```bash
source venv/bin/activate
python __init__.py
```
Para iniciar el contenedor si se ha parado (como root):

```bash
docker-compose up -d
``` 

Para descargar las dependencias necesarias (no es necesario en la maquina virtual):

```bash
# Crea un entorno virtual
python3 -m virtualenv venv

# Entra en el entorno
source venv/bin/activate

# Instala los requerimientos
pip install -r requirements.txt
```

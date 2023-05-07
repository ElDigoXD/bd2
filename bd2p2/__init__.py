# coding: utf-8
from sqlalchemy import Table, create_engine, insert, select
from sqlalchemy.engine import ScalarResult
from sqlalchemy.orm import Session

from .models import City, Country, User
import .models

global session
global engine


def main():
  
  username = "root"
  password = "mariadb"
  address = "127.0.0.1"
  port = 3307
  schema = "sakila"
  
  global engine
  global session

  engine = create_engine(f"mariadb+mariadbconnector://{username}:{password}@{address}:{port}/{schema}", echo=False)
  session = Session(engine)
  menu_string = """Menú principal:
  1. Crear país
  2. Listar países
  3. Eliminar país
  4. Crear ciudad
  5. Listar ciudades
  6. Eliminar ciudad
  7. Crear tabla usuarios
  8. Borrar tabla usuarios
  9. Mostrar estructura tabla
  10. Probar todos (sin listar)
  0. Salir"""
  while True:
    print(menu_string)

    option_str = input("Opción: ")
    option =int(option_str) if option_str.isdecimal() else -1 
    if option == 1:
      crear_país()
    elif option == 2:
      listar_países()
    elif option == 3:
      eliminar_país()
    elif option == 4:
      crear_ciudad()
    elif option == 5:
      listar_ciudades()
    elif option == 6:
      eliminar_ciudad()
    elif option == 7:
      crear_tabla_usuarios()
    elif option == 8:
      borrar_tabla_usuarios()
    elif option == 9:
      mostrar_estructura_tabla()
    elif option == 10:
      probar_todos()
    elif option == 0:
      break
    else:
      print("Opción no soportada.")    


def crear_país(country_id=None, country_name=None):
  country_id = input("Id del país: ") if country_id is None else country_id
  country_name = input("Nombre del país: ") if country_name is None else country_name

  try:
    query = insert(Country).values({"country_id": country_id, "country": country_name})
    session.execute(query)
    print(f"El país '{country_name} ha sido creado con id '{country_id}'")
  except:
    print(f"No se ha podido crear el país '{country_name}', el id '{country_id}' ya existe.")


def listar_países():
  query = select(Country)
  results = session.scalars(query)
  [print(str(result)) for result in results]


def eliminar_país(country_name=None):
  country_name = input() if country_name is None else country_name

  query = (
      select(Country)
      .where(Country.country == country_name)
  )
  result: ScalarResult = session.scalars(query)
  countries = result.all()

  if len(countries) < 1:
    print(f"No se ha encontrado el país '{country_name}'.")
    return

  try:
    session.query(Country).filter(Country.country == country_name).delete()
    print(f"Eliminado el país '{countries[0].country}'.")
  except:
    print(f"El país '{countries[0].country}' no se ha podido eliminar debido" +
          " a restricciones de clave ajena. (Una o más ciudades dependen del país.)")


def crear_ciudad(city_id=None, city_name=None, country_name=None):
  country_name = input("Nombre del país: ") if country_name is None else country_name
  result_countries: list[Country] = session.query(Country).filter(Country.country == country_name).all()
  if len(result_countries) != 1:
    print(f"Se han encontrado {len(result_countries)} países llamados '{country_name}', operación cancelada.")
    return

  city_id = input("Id de la ciudad: ") if city_id is None else city_id
  city_name = input("Nombre de la ciudad: ") if city_name is None else city_name

  try:
    query = insert(City).values({"city_id": city_id, "city": city_name,
                                 "country_id": result_countries[0].country_id})
    session.execute(query)
    print(f"La ciudad '{city_name} del país '{result_countries[0].country}' ha sido creada con id '{city_id}'")
  except:
    print(f"No se ha podido crear la ciudad '{city_name}', el id '{city_id}' ya existe.")


def listar_ciudades():
  query = select(City)
  results = session.scalars(query)
  [print(str(result)) for result in results]


def eliminar_ciudad(city_id=None):
  city_id = input() if city_id is None else city_id

  city: City = session.query(City).filter(City.city_id == city_id).first()

  if city is None:
    print(f"No se ha encontrado la ciudad con el id '{city_id}'.")
    return

  try:
    session.query(City).filter(City.city_id == city_id).delete()
    print(f"Eliminada la ciudad '{city.city}'.")
  except:
    print(f"La ciudad '{city.city}' no se ha podido eliminar debido" +
          " a restricciones de clave ajena. (Una o más direcciones dependen de la ciudad.)")


def crear_tabla_usuarios():
  global engine
  models.Base.metadata.create_all(engine)
  print("Tabla 'User' creada.")


def borrar_tabla_usuarios():
  global engine
  try:
    User.__table__.drop(engine)
    print("Tabla 'User' eliminada.")
  except:
    print("La tabla 'User' no existe, no se ha podido borrar.")


def mostrar_estructura_tabla():
  global engine
  table: Table = User.__table__
  print("Estructura de la tabla User:")
  [print(f"  {repr(x)}") for x in table.columns]
  [print(f"  {x}") for x in table.constraints]

def probar_todos():
  crear_tabla_usuarios()
  mostrar_estructura_tabla()
  borrar_tabla_usuarios()

  crear_país("112", "zz")
  crear_ciudad("601", "zz", "zz")
  eliminar_ciudad("601")
  eliminar_país("zz")
  
if __name__ == "__main__":
  main()


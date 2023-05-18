---
title: "Mongodb"
subtitle: "Bases de datos 2. Práctica 3"
author: "Diego Sanz Fuertes | 825015"

date: "20 de Mayo de 2023"
toc: true  
toc-own-page: true
header-left: |
  ![](/home/diego/resources/eupt.png){width=5cm}
lang: es-ES
titlepage: true

output:
 pdf:
  template: eisvogel
  output: output.pdf
  from: markdown
  listings: true
  citeproc: true
---
# Parámetros de conexión

## Usuarios
- Para el profesor:
	- username: `profesor`
	- password: `profesor`

- Para el alumno (o si no funciona el anterior)
	- username: `825015`
	- password: `ds`

## Servidor
URI: `mongodb+srv://profesor:profesor@cluster0.yjwagc3.mongodb.net/sakila`

## Mongosh

```sh
mongosh "mongodb+srv://profesor:profesor@cluster0.yjwagc3.mongodb.net/sakila" --apiVersion 1
```

## Mongoimport

```
mongoimport --uri mongodb+srv://profesor:profesor@cluster0.yjwagc3.mongodb.net/sakila <args>
```

# Ejercicios
## 1

> Instrucción Mongo Shell que obtenga el rating más habitual en las películas en las que participa SANDRA PECK.

Mongo shell: 

```js
db.getCollection('films').aggregate([
  {
    $match: {
      "Actors": { $elemMatch: { "First name": "SANDRA", "Last name": "PECK" } }
    }
  },
  {
    $group: {
      _id: "$Rating",
      count: { $sum: 1 }
    }
  },
  {
    $sort: { count: -1 }
  },
  { 
    $limit: 1 
  },
  {
    $project: {
      _id: 0,
      rating: "$_id",
    }
  }
])
```

Resultado:

```json
[{"rating": "G"}]
```

## 2

>Instrucción Mongo Shell que obtenga un listado con título, categoría y duración de las películas que ha alquilado WENDY HARRISON.

Mongo shell: 

```js
db.getCollection('customers').aggregate([
  {
    $match: {
      "First Name": "WENDY",
      "Last Name": "HARRISON"
    },
  },
  {
    $lookup: {
      from: "films",
      localField: "Rentals.filmId",
      foreignField: "_id",
      as: "Rentals.Film"
    }
  },
  {
    $unwind: "$Rentals.Film"
  },
  {
    $replaceRoot: {
      newRoot: "$Rentals.Film"
    }
  },
  {
    $project: {
      _id:0,
      Title:1,
      Category:1,
      Length:1
    }
  }
])
```

Resultado:

```json
[ {"Category": "Music",
    "Length": "136",
    "Title": "ALASKA PHANTOM"},
  {"Category": "Drama",
    "Length": "175",
    "Title": "BEAUTY GREASE"},
  {"Category": "Sports",
    "Length": "70",
    "Title": "CHANCE RESURRECTION"},
  {"Category": "Children",
    "Length": "143",
    "Title": "CLOCKWORK PARADISE"},
  {"Category": "Children",
    "Length": "143",
    "Title": "CROOKED FROGMEN"},
  {"Category": "Travel",
    "Length": "141",
    "Title": "DISCIPLE MOTHER"},
  {"Category": "Classics",
    "Length": "176",
    "Title": "DRACULA CRYSTAL"},
  {"Category": "Games",
    "Length": "100",
    "Title": "GUN BONNIE"},
  {"Category": "Music",
    "Length": "47",
    "Title": "HANOVER GALAXY"},
  {"Category": "Games",
    "Length": "181",
    "Title": "HAUNTING PIANIST"},
  {"Category": "Foreign",
    "Length": "75",
    "Title": "HELLFIGHTERS SIERRA"},
  {"Category": "Classics",
    "Length": "100",
    "Title": "HYDE DOCTOR"},
  {"Category": "Foreign",
    "Length": "59",
    "Title": "JET NEIGHBORS"},
  {"Category": "Classics",
    "Length": "110",
    "Title": "LEAGUE HELLFIGHTERS"},
  {"Category": "Action",
    "Length": "86",
    "Title": "MIDNIGHT WESTWARD"},
  {"Category": "Documentary",
    "Length": "74",
    "Title": "MODERN DORADO"},
  {"Category": "Travel",
    "Length": "79",
    "Title": "MOULIN WAKE"},
  {"Category": "Animation",
    "Length": "115",
    "Title": "OSCAR GOLD"},
  {"Category": "Documentary",
    "Length": "144",
    "Title": "PACIFIC AMISTAD"},
  {"Category": "Music",
    "Length": "118",
    "Title": "PERSONAL LADYBUGS"}]
```

## 3

>Instrucción Mongo Shell que obtenga un listado con el título de las ocho películas de género musical con más alquileres.

Mongo shell:

```js
db.getCollection('customers').aggregate([
  {
    $lookup: {
      from: "films",
      localField: "Rentals.filmId",
      foreignField: "_id",
      as: "Rentals.Film"
    }
  },
  {
    $unwind: "$Rentals.Film"
  },
  {
    $replaceRoot: {
      newRoot: "$Rentals.Film"
    }
  },
  {
    $match: {
      "Category": "Music"
    }
  },
  {
    $group: {
      _id: { id: "$_id", title: "$Title" },
      count: {
        $sum: 1
      },
    }
  },
  {
    $sort: {
      count: -1
    }
  },
  {
    $limit: 8
  },
  {
    $project: {
      _id:0,
      title: "$_id.title",
      //count: 1
    }
  },
])
```

Resultado: 

```json
[ {"title": "SCALAWAG DUCK"},
  {"title": "CONFIDENTIAL INTERVIEW"},
  {"title": "GREATEST NORTH"},
  {"title": "ENEMY ODDS"},
  {"title": "BOOGIE AMELIE"},
  {"title": "DEER VIRGINIAN"},
  {"title": "TELEGRAPH VOYAGE"},
  {"title": "DORADO NOTTING"}]
```

## 4 

>Instrucción Mongo Shell que crea una vista con las películas de género musical y las personas que los han alquilado.

Mongo shell:

```js
// Elimina la vista si existe
db.musical.drop()
// Crea la vista
db.createView(
  "musical",
  "customers",
  [
    {
      $unwind: "$Rentals"
    },
    {
      $lookup: {
        from: "films",
        localField: "Rentals.filmId",
        foreignField: "_id",
        as: "Film"
      }
    },

    {
      $match: {
        "Film.Category": "Music"
      }
    },
    {
      $unwind: "$Film"
    },
    {
      $group: {
        _id: "$Film",
        "customers": {
          $addToSet: {
            "_id": "$_id",
            "First Name": "$First Name",
            "Last Name": "$Last Name",
          }
        }
      }
    }
  ],
)
// Llama a la vista 
// (el primero solo porque el output es muy grande)
db.musical.find({})
```

Resultado:

```json
{
  "_id": {
    "_id": 516,
    "Actors": [
      { "First name": "TOM",
        "Last name": "MCKELLEN",
        "actorId": 38},
      { "First name": "ANGELA",
        "Last name": "HUDSON",
        "actorId": 65},
      { "First name": "PENELOPE",
        "Last name": "CRONYN",
        "actorId": 104},
      { "First name": "CATE",
        "Last name": "MCQUEEN",
        "actorId": 128}
    ],
    "Category": "Music",
    "Description": "A Awe-Inspiring Epistle of a Pioneer And a Student who must Outgun a Crocodile in The Outback",
    "Length": "59",
    "Rating": "PG",
    "Rental Duration": "7",
    "Replacement Cost": "18.99",
    "Special Features": "Commentaries,Deleted Scenes",
    "Title": "LEGEND JEDI"
  },
  "customers": [
    { "_id": 181,
      "First Name": "ANA",
      "Last Name": "BRADLEY"},
    { "_id": 7,
      "First Name": "MARIA",
      "Last Name": "MILLER"},
    { "_id": 576,
      "First Name": "MORRIS",
      "Last Name": "MCCARTER"},
    { "_id": 326,
      "First Name": "JOSE",
      "Last Name": "ANDREW"},
    { "_id": 206,
      "First Name": "TERRI",
      "Last Name": "VASQUEZ"},
    { "_id": 300,
      "First Name": "JOHN",
      "Last Name": "FARNSWORTH"},
    { "_id": 334,
      "First Name": "RAYMOND",
      "Last Name": "MCWHORTER"},
    { "_id": 289,
      "First Name": "VIOLET",
      "Last Name": "RODRIQUEZ"},
    { "_id": 409,
      "First Name": "RODNEY",
      "Last Name": "MOELLER" }]}
```
## 5

>Importar a vuestra BD como dos colecciones los datos de: 
>Colección oferta_unizar y  notas_corte_unizar.

### Oferta

Importar los datos:

```sh
wget https://zaguan.unizar.es/record/108270/files/JSON.json

mongoimport --uri mongodb+srv://profesor:profesor@cluster0.yjwagc3.mongodb.net/sakila --collection oferta_unizar --type json --file JSON.json
```

Formatear la estructura:

```js
db.oferta_unizar.aggregate([
  {
    $project: {
      "_id": 0
    }
  },
  {
    $unwind: "$datos"
  },
  {
    $replaceRoot: {
      newRoot: "$datos"
    }
  },
  {
    $out: "oferta_unizar"
  }
])
```

### Notas de corte

Importar los datos:

```sh
wget https://zaguan.unizar.es/record/109322/files/JSON.json

mongoimport --uri mongodb+srv://profesor:profesor@cluster0.yjwagc3.mongodb.net/sakila --collection notas_corte_unizar --type json --file JSON.json
```

Formatear la estructura:

```js
db.notas_corte_unizar.aggregate([
  {
    $project: {
      "_id": 0
    }
  },
  {
    $unwind: "$datos"
  },
  {
    $replaceRoot: {
      newRoot: "$datos"
    }
  },
  {
    $out: "notas_corte_unizar"
  }
])
```

## 6

>Añadir a la colección notas_corte_unizar los campos numéricos nota_corte_julio y nota_corte_septiembre que será el resultado de convertir a número los datos de NOTA_CORTE_DEFINITIVA_JULIO y NOTA_CORTE_DEFINITIVA_SEPTIEMBRE, que por defecto se importan como texto.

>NOTA: A mi me salen como números pero los he transformado de todas formas.

Mongo shell: 

```js
db.notas_corte_unizar.aggregate([
  {
    $addFields: {
      "nota_corte_julio": {
        $toDouble: "$NOTA_CORTE_DEFINITIVA_JULIO"
      },
      "nota_corte_septiembre": {
        $toDouble: "$NOTA_CORTE_DEFINITIVA_SEPTIEMBRE"
      }
    },
  },
  {
    $out: "notas_corte_unizar"
  }
])
```

Resultado: Se puede ver en el siguiente punto

## 7

>Crear una vista o una nueva colección, llamada oferta_unizar_con_notas que combine los datos de ambas colecciones.

Mongo shell: 

```js
db.oferta_unizar.aggregate([
  {
    $lookup: {
      from: "notas_corte_unizar",
      let: {
        centro: "$CENTRO",
        estudio: "$ESTUDIO"
      },
      pipeline: [
        {
          $match: {
            $expr: {
              $and: [
                {
                  $eq: [
                    "$CENTRO",
                    "$$centro"
                  ]
                },
                {
                  $eq: [
                    "$ESTUDIO",
                    "$$estudio"
                  ]
                }
              ]
            }
          }
        }
      ],
      as: "result"
    }
  },
  {
    $unwind: "$result"
  },
  {
    $replaceWith: {
      $mergeObjects: [
        "$result",
        "$$ROOT"
      ]
    }
  },
  {
    $project: {
      "result": 0,
      "_id": 0,
    }
  }
])
```

Resultado: (limit 3)

```json
[ { "CENTRO": "Escuela Politécnica Superior",
    "NOTA_CORTE_DEFINITIVA_JULIO": 5,
    "NOTA_CORTE_DEFINITIVA_SEPTIEMBRE": 5,
    "LOCALIDAD": "Huesca",
    "FECHA_ACTUALIZACION": "2022/10/30 06:00:20.000",
    "CURSO_ACADEMICO": 2021,
    "PRELA_CONVO_NOTA_DEF": null,
    "ESTUDIO": "Grado: Ciencias Ambientales",
    "nota_corte_julio": 5,
    "nota_corte_septiembre": 5,
    "TIPO_CENTRO": "Facultad",
    "PLAZAS_SOLICITADAS": 337,
    "INDICE_OCUPACION": 68.51851851851852,
    "PLAZAS_OFERTADAS": 54,
    "TIPO_ESTUDIO": "Grado",
    "PLAZAS_MATRICULADAS": 37
  },
  {
    "CENTRO": "Facultad de Ciencias de la Salud",
    "NOTA_CORTE_DEFINITIVA_JULIO": 11.766,
    "NOTA_CORTE_DEFINITIVA_SEPTIEMBRE": null,
    "LOCALIDAD": "Zaragoza",
    "FECHA_ACTUALIZACION": "2022/10/30 06:00:20.000",
    "CURSO_ACADEMICO": 2021,
    "PRELA_CONVO_NOTA_DEF": null,
    "ESTUDIO": "Grado: Enfermería",
    "nota_corte_julio": 11.766,
    "nota_corte_septiembre": null,
    "TIPO_CENTRO": "Facultad",
    "PLAZAS_SOLICITADAS": 3959,
    "INDICE_OCUPACION": 100,
    "PLAZAS_OFERTADAS": 176,
    "TIPO_ESTUDIO": "Grado",
    "PLAZAS_MATRICULADAS": 176
  },
  {
    "CENTRO": "Escuela Universitaria de Enfermería San Jorge de Huesca",
    "NOTA_CORTE_DEFINITIVA_JULIO": 11.154,
    "NOTA_CORTE_DEFINITIVA_SEPTIEMBRE": null,
    "LOCALIDAD": "Huesca",
    "FECHA_ACTUALIZACION": "2022/10/30 06:00:20.000",
    "CURSO_ACADEMICO": 2021,
    "PRELA_CONVO_NOTA_DEF": null,
    "ESTUDIO": "Grado: Enfermería",
    "nota_corte_julio": 11.154,
    "nota_corte_septiembre": null,
    "TIPO_CENTRO": "Centro adscrito",
    "PLAZAS_SOLICITADAS": 3313,
    "INDICE_OCUPACION": 100,
    "PLAZAS_OFERTADAS": 59,
    "TIPO_ESTUDIO": "Grado",
    "PLAZAS_MATRICULADAS": 59}]
```


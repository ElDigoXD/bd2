-- Lanza consulta SQL que devuelva la universidad que más
-- alumnos recibe de cada centro en el 2021.
-- NOTA: En caso de empate se muestran más de uno

select nombre_centro, universidad, alumnos
FROM 
  (SELECT 
    universidad
    , sum(plazas_asignadas) as alumnos
    , centro.nombre as nombre_centro
    , RANK() OVER (PARTITION BY centro.nombre ORDER BY sum(plazas_asignadas) desc) as ranking
  from convenio_de_movilidad
  LEFT JOIN centro using (id_centro)
  where curso = '2021'
  group by 
    universidad
    , centro.nombre) as sub
where ranking <= 1
ORDER BY alumnos DESC;
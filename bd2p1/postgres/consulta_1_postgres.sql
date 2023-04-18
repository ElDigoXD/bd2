-- Lanza consulta SQL que devuelva los dos estudios de cada
-- localidad con mayor índice de ocupación en el 2021.
-- NOTA: En caso de empate se muestran más de dos

select localidad, nombre, indice_de_ocupacion from
  (select 
    (plazas_ocupadas::float/plazas_ofertadas) as indice_de_ocupacion 
    , estudio.nombre as nombre
    , centro.localidad as localidad
    , RANK() OVER (PARTITION BY localidad ORDER BY (plazas_ocupadas::float/plazas_ofertadas) desc) as ranking

  from estudio_por_curso
  LEFT JOIN estudio using (id_estudio)
  LEFT JOIN centro using (id_centro)
  where 
    curso = 2021) as sub
where ranking <= 2
ORDER BY localidad, ranking asc;
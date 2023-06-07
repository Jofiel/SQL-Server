--El primer paso es revisar la tabla que se va a ajustar para validar las columnas y valores que tiene
select * from bpmfct

--El segundo paso es ubicar los valores a actualizar

--En este caso puede ser filtrado por vendedor
select * from bprclvnd where l4nvnd =3290 

--O puede ser filtrado por cliente
select * from bprclvnd where l2ncln in (10151, 11245,1276,
15999,
16010,
16031,
16040,
16059,
16060,
16120,
16160,
16322,
16368,
16372,
16437,
16460,
16516,
16518,
16590,
16719,
16756,
16757,
16783,
16795,
16947,
16967,
17018,
17038,
17112,
17501,
17892,
18092,
18152,
18525)


--Una vez que ubiques bien los archivos genera la funcion de actualización

UPDATE 'TABLA' SET 'COLUMNA' = 'VALOR FINAL' WHERE 'CONDICIONALES'

--update bprclvnd set l4nvnd = 3290 where l4nvnd =1164
11245,
11276,
15999,
16010,
16031,
16040,
16059,
16060,
16120,
16160,
16322,
16368,
16372,
16437,
16460,
16516,
16518,
16590,
16719,
16756,
16757,
16783,
16795,
16947,
16967,
17018,
17038,
17112,
17501,
17892,
18092,
18152,
18525)
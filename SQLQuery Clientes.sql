select distinct a.l2ncln AS 'ID Ctl', a.v0nclnnmb AS 'Cliente',CASE WHEN a.c0nestact = 'S' THEN 'Activo' ELSE 'Inactivo' END AS Estatus, 
c.v0nestddsc AS 'Estado' from bpccln a
left join bp1clndr b on a.e1neno=b.e1neno and a.l2ncln=b.l2ncln
left join bpcestd c on c.e1nestd=b.e0nestd
where b.c0nbndoms = 'S' and a.nSubSubEnt <> 320 and a.nSubSubEnt <> 440 and a.c0nestact = 'S'


--Detalle de la tabla de facturas por cliente
select * from bpmntc where l0ncln = 13864

-- Detalle de la tabla de subentidades
select * from bpcSubSubEnt

--Detalle
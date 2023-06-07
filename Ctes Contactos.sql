select cont.Nombre,cont.l2ncln,cont.[Cuenta  (Cliente)],cont.Móvil,cont.[Teléfono de Oficina],cont.[Teléfono de casa],cont.[Teléfono Alternativo],cont.[Tel Nom],
cont.Cargo,cont.IDCARG,cont.Correo
from (select distinct b.v0nnmbrpr Nombre,a.l2ncln,a.v0sclnrzn as 'Cuenta  (Cliente)',case f.v0ndscttlf when 'OFICINA' then d.v0nnmrtlf end 'Teléfono de Oficina'
,case f.v0ndscttlf when 'MOVIL' then d.v0nnmrtlf end 'Móvil'
,case f.v0ndscttlf when 'DOMICILIO' then d.v0nnmrtlf end 'Teléfono de casa'
,case when f.v0ndscttlf in ('FAX','CONMUTADOR','LOCALIZADOR','BODEGA','TIENDA','MATRIZ') then d.v0nnmrtlf end 'Teléfono Alternativo'
,case when f.v0ndscttlf in ('FAX','CONMUTADOR','LOCALIZADOR','BODEGA','TIENDA','MATRIZ') then f.v0ndscttlf end 'Tel Nom'
,d.v0nnmrtlf Telefono,f.v0ndscttlf T_Telefono,c.v0nnmbtrpr Cargo,c.e1ntprpr IDCARG,b.v0scrrrpr Correo from bpccln a
inner join Bp2clnrp b on a.e1neno=b.e1nenocln and a.l2ncln=b.l2ncln --detalle de contactos con cliente
inner join bpctprpr c on b.e0ntprpr=c.e1ntprpr --Tipo de representante 
inner join Bp2clntl d on d.e1nenocln=a.e1neno and d.l2ncln=a.l2ncln --detalle telefono
inner join bpctptlf f on f.e1ncdttlf=d.e0ntptlf --catalogo de tipo de telefono
right join (select distinct l0neor,e0nenoeor from bpmfct where f0nfchfct>'31-12-2020' and e0nenoeor=1) j on j.l0neor=a.l2ncln and j.e0nenoeor=a.e1neno
where a.c0nestact='S' and a.nSubSubEnt <> 50) Cont

 

--sin ventas
select cont.Nombre,cont.l2ncln,cont.[Cuenta  (Cliente)],cont.Móvil,cont.[Teléfono de Oficina],cont.[Teléfono de casa],cont.[Teléfono Alternativo],cont.[Tel Nom],
cont.Cargo,cont.IDCARG,cont.Correo
from (select distinct b.v0nnmbrpr Nombre,a.l2ncln,a.v0sclnrzn as 'Cuenta  (Cliente)',case f.v0ndscttlf when 'OFICINA' then d.v0nnmrtlf end 'Teléfono de Oficina'
,case f.v0ndscttlf when 'MOVIL' then d.v0nnmrtlf end 'Móvil'
,case f.v0ndscttlf when 'DOMICILIO' then d.v0nnmrtlf end 'Teléfono de casa'
,case when f.v0ndscttlf in ('FAX','CONMUTADOR','LOCALIZADOR','BODEGA','TIENDA','MATRIZ') then d.v0nnmrtlf end 'Teléfono Alternativo'
,case when f.v0ndscttlf in ('FAX','CONMUTADOR','LOCALIZADOR','BODEGA','TIENDA','MATRIZ') then f.v0ndscttlf end 'Tel Nom'
,d.v0nnmrtlf Telefono,f.v0ndscttlf T_Telefono,c.v0nnmbtrpr Cargo,c.e1ntprpr IDCARG,b.v0scrrrpr Correo from bpccln a
inner join Bp2clnrp b on a.e1neno=b.e1nenocln and a.l2ncln=b.l2ncln --detalle de contactos con cliente
inner join bpctprpr c on b.e0ntprpr=c.e1ntprpr --Tipo de representante 
right join Bp2clntl d on d.e1nenocln=a.e1neno and d.l2ncln=a.l2ncln --detalle telefono
inner join bpctptlf f on f.e1ncdttlf=d.e0ntptlf --catalogo de tipo de telefono
where a.c0nestact='S') Cont
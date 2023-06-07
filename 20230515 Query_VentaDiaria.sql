--select case when  vp3.SubEntidad='ME SUPERMAYOREO' then  'SUPERMAYOREO' else vp3.SubEntidad end 'subEntidad2',vp3.SubEntidad,(sum(vp3.MB)-sum(vp3.MBF)-sum(vp3.MBP))-((sum(vp3.MB_NC)-sum(vp3.MBF_NC)-sum(vp3.MBP_NC))+(sum(vp3.MB_DV)-sum(vp3.MBF_DV)-sum(vp3.MBP_DV)))
--from (
select d1.SubEntidad,d1.f0nfchfct,d1.l2ncln,d1.v0nclnnmb,d1.ValorDiv,d1.EquivDiv,
case when d1.v0nclnnmb like 'V E N T A  G L O B A L  R E B E C C A  P I C K' then d1.MB when d1.v0nclnnmb like '%G L O B A L%' then 0 else d1.MB end MB,
case when d1.v0nclnnmb like 'V E N T A  G L O B A L  R E B E C C A  P I C K' then d1.MBP when d1.v0nclnnmb like '%G L O B A L%' then 0 else d1.MBP end MBP,
case when d1.v0nclnnmb like 'V E N T A  G L O B A L  R E B E C C A  P I C K' then d1.MBF when d1.v0nclnnmb like '%G L O B A L%' then 0 else d1.MBF end MBF,
'M_DV'=0,--sum(isnull(nt2.d0nmntbrt,0)) M_DV, --MONTO BRUTO DEVOLUCIONES
'MB_DV'=0,--sum(isnull((nt2.d0n0mntbrt*nt2.d0neqvdvs)*-1,0)) MB_DV, --MONTO BRUTO DEVOLUCIONES
--sum(isnull((case 
--	when nt2.e0ndvs='2' 
--	then nt2.d0nmntdopp*redvs.d0neqv
--	else nt2.d0nmntdopp
'MBF_DV'=0,--end)*-1,0)) MBF_DV, --MONTO VRUTO POR FOLIO DEVOLUCIONES
--sum(isnull((case 
--	when nt2.e0ndvs='2' 
--	then nt2.d0nmntdop*redvs.d0neqv
--	else nt2.d0nmntdop
'MBP_DV'=0,--end)*-1,0)) MBP_DV, --MONTO BRUTO PRODUCTO DEVOLUSIONES
sum(isnull(nt1.d0nmntbrt,0)) M_NC, --MONTO BRUTO POR NOTA DE CRÉDITO
sum(isnull((nt1.d0nmntbrt*nt1.d0neqvdvs)*-1,0)) MB_NC,--MONTO BRUTO POR NOTA DE CREDITO
sum(isnull((case
	when nt1.e0ndvs='2'
	then nt1.d0nmntdopp*redvs.d0neqv
	else nt1.d0nmntdopp
end)*-1,0)) MBF_NC, --MONTO BRUTO FOLIO MST FIX NOTA DE CREDITO
sum(isnull((case 
	when nt1.e0ndvs='2' 
	then nt1.d0nmntdop*redvs.d0neqv --[Equivalencias entre Divisas]
	else nt1.d0nmntdop
end)*-1,0)) MBP_NC --MONTO BRUTO POR PRODUCTO NOTA DE CREDITO
from (select sse.cDescSSEnt SubEntidad,--NOMBRE DE SUBENTIDAD - BASE SUBENTIDAD 
fct.f0nfchfct, --FECHA DE FACTURA
cl.l2ncln,--#CLIENTE
cl.v0nclnnmb,--NOMBRE DE CLIENTE
avg(redvs.d0neqv) as 'ValorDiv',--CODIGO DE DIVISA
avg(fct.d0neqvdvs) as 'EquivDiv', --EQUIVALENCIA DE DIVISA
sum(fct.d0nmntbrt) as 'MontoBruto',--MONTO BRUTO
sum(isnull((case 
	when fct.e0ndvs='2'	 --Cuando el ID de Divisa sea igual a 2
	then fct.d0nmntbrt*(redvs.d0neqv) --Multiplica el MontoBruto por la Equivalencia De Divisa
	else fct.d0nmntbrt
end),0)) MB, --MONTO BRUTO MST FIX LINEA DE VENTAS
sum(isnull((case 
	when fct.e0ndvs='2' --Cuando el ID de Divisa sea igual a 2
	then fct.d0nmntdopp*(redvs.d0neqv) --Multiplica el Descuento de Producto por la Equivalencia De Divisa
	else fct.d0nmntdopp
end)*-1,0)) MBP, --MONTO BRUTO POR PRODUCTO MST FIX LINEA DE VENTAS
sum(isnull((case 
	when fct.e0ndvs='2' --Cuando el ID de Divisa sea igual a 2
	then fct.d0nmntdop*(redvs.d0neqv - fct.d0neqvdvs) --Multiplica el Descuento de Folio por la Equivalencia De Divisa
	else fct.d0nmntdop
end)*-1,0)) MBF --MONTO BRUTO POR FOLIO MST FIX LINEA DE VENTA --5555555555555555555555555
from bpccln cl --BASE CLIENTES
left join (select a.*,
			case 
			when e0nenoeor=1 and a.l0neor=15524 and a.e0nenoeor=1 then 10 
			when a.e1nseofct=1 and a.l0neor=15655 and a.e0nenoeor=1 then 10
			when a.e1nseofct=1 and a.l0neor=1528 and a.e0nenoeor=1 then 10
			when a.e1nseofct=1 and a.e0nenoeor=1 then cl.nSubSubEnt --CALCULO DE SUBSUBENTIDAD
			when e1nseofct=2 then 20 
			when e1nseofct=3 then 30 
			when e1nseofct=4 then 40 
			when e1nseofct=5 then 50 
			when e1nseofct=6 then 60 
			when e1nseofct=7 then 70 
			when e1nseofct=29 then 290 
			when e1nseofct=30 then 300 
			when e1nseofct=31 then 310 
			when e1nseofct=32 then 320 
			when e1nseofct=34 then 340 
			when e1nseofct=39 then 390 
			when e1nseofct=40 then 400 
			when e1nseofct=41 then 410 
			when e1nseofct=43 then 430 
			when e1nseofct=44 then 440 
			when e1nseofct=45 then 450 
			when e1nseofct=46 then 460 
			when e1nseofct=48 then 480
			when e1nseofct=50 then 500
			when e1nseofct=51 then 510
			when e1nseofct=52 then 520
			when e1nseofct=53 then 530
			when e1nseofct=54 then 540
			when e1nseofct=55 then 550
			else e1nseofct
			end IDSSEOp
			from bpmfct a
			left join bpccln cl on a.e0nenoeor=cl.e1neno and a.l0neor=cl.l2ncln where a.c0nbndact='S') fct on fct.e0nenoeor=cl.e1neno and fct.l0neor=cl.l2ncln --LINEA DE LAS VENTAS (FACTURAS)
left join bpcSubSubEnt sse on sse.nSubEntidad=fct.e1nseofct and fct.IDSSEOp=sse.nSubSubEnt --BASE SUBSUBENTIDAD
left join (select * from bpreqdvs where e1ndvs1=2) redvs on Dateadd(day,-1,fct.f0nfchfct)=redvs.f0nfchinvg --BASE RELACION EQUIVALENCIAS
where fct.f0nfchfct>='01-01-2023' group by sse.cDescSSEnt,fct.f0nfchfct,cl.l2ncln,cl.v0nclnnmb) d1
left join (select nt.e0nenocln,nt.f0nfchntc,nt.l0ncln,avg(nt.e0ndvs) e0ndvs,avg(nt.d0neqvdvs) d0neqvdvs,sum(nt.d0nmntafc) d0nmntbrt,sum(nt.d0nmntdop) d0nmntdop,sum(nt.d0nmntdopp) d0nmntdopp --notas de crédito
from bpmntc nt where nt.e0nenocln=1 and nt.c0nbndact='S' and cBndAutCxc='S' and cBndAutGte='S' group by nt.e0nenocln,nt.f0nfchntc,nt.l0ncln) nt1 --NOTAS DE CREDITO
on d1.f0nfchfct=nt1.f0nfchntc and d1.l2ncln=nt1.l0ncln --notas de crédito
left join (select * from bpreqdvs where e1ndvs1=2) redvs on Dateadd(day,-1,nt1.f0nfchntc)=redvs.f0nfchinvg
--left join (select rd.l4nfoldvc,dv.e0nenoeor,dv.f0nfchdvc,dv.l0neor,avg(dv.e0ndvs) e0ndvs,avg(dv.d0neqvdvs) d0neqvdvs,sum(dv.d0nmntbrt) d0nmntbrt,sum(dv.d0nmntdop) d0nmntdop,sum(dv.d0nmntdopp) d0nmntdopp 
--from bpmdvc dv inner join (select distinct e3nseodvc, l4nfoldvc, 'DvcConNtc' as DvcConNtc from dbo.bprmncdc) rd on rd.e3nseodvc=dv.e1nseodvc and rd.l4nfoldvc=dv.l2nfoldvc where dv.e0nenoeor=1 and dv.c0nbndact='S' group by dv.e0nenoeor,dv.f0nfchdvc,dv.l0neor,rd.l4nfoldvc having l4nfoldvc is null) nt2
--on d1.f0nfchfct=nt2.f0nfchdvc and d1.l2ncln=nt2.l0neor
group by d1.SubEntidad,d1.f0nfchfct,d1.l2ncln,d1.v0nclnnmb,d1.ValorDiv,d1.EquivDiv,d1.MontoBruto,d1.MB,d1.MBP,d1.MBF
--NOTAS DE CRÉDITO
union all
select sse.cDescSSEnt SubEntidad,
ntne.f0nfchntc,ntne.l0ncln l2ncln,cl.v0nclnnmb,redvs.d0neqv 'ValorDiv',ntne.d0neqvdvs 'EquivDiv','MB'=0,'MBP'=0,'MBF'=0,'M_DV'=0,'MB_DV'=0,'MBF_DV'=0,'MBP_DV'=0,ntne.d0nmntbrt 'M_NC',
isnull((case 
	when ntne.e0ndvs='2'	 --Cuando el ID de Divisa sea igual a 2
	then ntne.d0nmntbrt*(redvs.d0neqv) --Multiplica el MontoBruto por la Equivalencia De Divisa
	else ntne.d0nmntbrt
end)*-1,0) 'MB_NC',
isnull((case 
	when ntne.e0ndvs='2' --Cuando el ID de Divisa sea igual a 2
	then ntne.d0nmntdopp*(redvs.d0neqv) --Multiplica el Descuento de Producto por la Equivalencia De Divisa
	else ntne.d0nmntdopp
end)*-1,0) 'MBF_NC', --MONTO BRUTO POR FOLIO MST FIX LINEA DE VENTA
isnull((case 
	when ntne.e0ndvs='2' --Cuando el ID de Divisa sea igual a 2
	then ntne.d0nmntdop*(redvs.d0neqv - ntne.d0neqvdvs) --Multiplica el Descuento de Folio por la Equivalencia De Divisa
	else ntne.d0nmntdop
end)*-1,0) 'MBP_NC' --MONTO BRUTO POR PRODUCTO MST FIX LINEA DE VENTAS 
from (select nt1.e0nenocln,nt1.f0nfchntc,nt1.e0ndvs,nt1.l0ncln,nt1.d0neqvdvs,nt1.d0nmntbrt,nt1.d0nmntdop,nt1.d0nmntdopp from (select ft.f0nfchfct,ft.l0neor,sum(ft.d0nmntbrt) d0nmntbrt from bpmfct ft group by ft.f0nfchfct,ft.l0neor) ft1
right join (select nt.e0nenocln,nt.f0nfchntc,nt.l0ncln,avg(nt.e0ndvs) e0ndvs,avg(nt.d0neqvdvs) d0neqvdvs,sum(nt.d0nmntafc) d0nmntbrt,sum(nt.d0nmntdop) d0nmntdop,sum(nt.d0nmntdopp) d0nmntdopp 
from bpmntc nt where nt.e0nenocln=1 and nt.c0nbndact='S' and cBndAutCxc='S' and cBndAutGte='S' group by nt.e0nenocln,nt.f0nfchntc,nt.l0ncln) nt1
on ft1.f0nfchfct=nt1.f0nfchntc and ft1.l0neor=nt1.l0ncln
where ft1.f0nfchfct is null) ntne
left join bpccln cl on cl.l2ncln=ntne.l0ncln and ntne.e0nenocln=cl.e1neno
left join bpcSubSubEnt sse on sse.nSubSubEnt=cl.nSubSubEnt
left join (select * from bpreqdvs where e1ndvs1=2) redvs on Dateadd(day,-1,ntne.f0nfchntc)=redvs.f0nfchinvg
where ntne.f0nfchntc>='01-01-2023'
--)vp3 
--group by vp3.SubEntidad

SELECT ID_Pat=A.l0nptr, ID_Cln=A.l2ncln, Cliente=A.v0nclnnmb, Patrocinador=A.e0nenoptr, Monto_Credito=A.d0slmtcrd, Dias_Cred=B.e0ndiscrd,
CLN_Condicion_pago=v0ndsccp, Estado=C.v0nestddsc, Agente=D.v0nemplnmb, MOnto_Neto=E.d0nmnetfcp
FROM bpccln A, bpccndpg B, bpcestd C, bpcempl D, bp1cnrfc E, bp1clndr F
where A.c0nestact = 'S'	
and v0ndsccp <> 'SIN CONDICION DE PAGO'
and B.e1ncdcp = A.e0ncndpag
and F.e0nestd = C.e1nestd



select SEO=G.e1nseocxc,ID_Pat=A.l0nptr, ID_Cln=A.l2ncln, Cliente=A.v0nclnnmb, Monto_Credito=A.d0slmtcrd, Dias_Cred=B.e0ndiscrd, Condicion_pago=v0ndsccp, C.e0nestd, /*CLN_Calle=C.v0scll,*/
Estado=D.v0nestddsc/*, Agente=E.v0nemplnmb, MOnto_Neto=F.d0nmnetfcp*/
from bpccln A,bpccndpg B, Bp1clndr C, bpcestd D/*, bpcempl E, bp1cnrfc F*/, bpmcxc G
where A.c0nestact='S' and v0ndsccp <> 'PAGO POR ADELANTADO'
and B.e1ncdcp = A.e0ncndpag
and A.e1neno = C.e1neno     
and A.l2ncln = C.l2ncln 
and C.e0nestd = D.e1nestd
and C.l2ncln = A.l2ncln
and C.c0nbndoms = 'S'
--and A.e1neno = E.e1neno


select * from bp1clndr

select * from bpmcxc
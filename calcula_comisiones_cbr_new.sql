USE [BPSelanusa]
GO
/****** Object:  StoredProcedure [dbo].[calcula_comisiones_cbr_new]    Script Date: 23/01/2023 01:04:15 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:			Alberto Lamadrid Mtz
-- Create date:		26/Jun/2007
-- Modifier:		Germán A. Castillo G.
-- Modified date:	15/Ene/2014
-- Description:		Proceso para el cálculo de comisiones cobranza
-- =============================================
ALTER PROCEDURE [dbo].[calcula_comisiones_cbr_new] (
@seo Int, @agente Int, @fec_ini datetime, @fec_fin datetime, @stt_cms char(1), @cms_cero char(1) )
AS
BEGIN
Declare 
	@ciclo   int,
	@pdc_seo int, 
	@pdc_fol int, 
	@fct_fgn datetime,
	@fct_fpg datetime,
	@fct_env datetime,
	@fct_plz int,
	@pdc_tpd char(1), 
	@fct_seo int, 
	@fct_fol numeric(7,0), 
	@fct_org char(1), 
	@fct_dsc decimal(9,6),
	@clc_cms decimal(9,6),
	@fct_prd char(10),
	@cta_row int,
	@pdc_lsp int,
	@pdc_pmd char(1),
	@fct_pfn decimal(14,2),
	@fct_rcb decimal(9,6),
	@cli_seo int, 
	@cli_num int, 
	@fct_prb varchar(17),
	@clc_mcm decimal(14,2),
	@fct_cbr decimal(14,2), 
	@fct_imp decimal(14,2),
	@e_delta decimal(14,2),
	@prc_net decimal(14,2),
	@renglon int,
	@cond    int,
    @dscncc  decimal(14,2),
	@cms_asg int, 
	@plz_ini int,
	@plz_fin int,
	@fct_cxc numeric(7,0),
	@fct_rfr varchar(17)

SET NOCOUNT ON;
--Tabla temporal que agrupa a todas las facturas que son candidatas para el cálculo de comisiones
Truncate Table tmp_fac_base_cms
--Drop table tmp_fac_base
--Create table tmp_fac_base (
--	cli_seo Int, 1
--	cli_num Int, 2
--	pdc_seo Int, 3
--	pdc_fol Int, 4
--	pdc_tpd char(1), 5
--	cxc_fol Int, 6
--	fct_seo Int, 7
--	fct_fol Int, 8
--	fct_ref varchar(20), 9
--	fct_imp decimal(14,2), 10
--	fct_cbr decimal(14,2), 11
--	fct_fgn Datetime, 12
--	fct_fpg Datetime, 13
--	fct_env Datetime, 14
--	fct_plz int, 15
--	fct_mcm decimal(14,2) 16
--	 )

--Tabla Temporal que tiene el detalle de los productos de las facturas a calcular la comisión
Truncate Table tmp_fac_base_det_cms
----Drop table tmp_fac_base_det
--Create table tmp_fac_base_det (
--	cli_seo Int,
--	cli_num Int,
--	pdc_seo Int,
--	pdc_fol Int,
--	pdc_tpd char(1),
--	cxc_fol Int,
--	fct_seo Int,
--	fct_fol Int,
--	fct_ref varchar(20),
--	fct_imp decimal(14,2),
--	fct_cbr decimal(14,2),
--	fct_fgn Datetime,
--	fct_fpg Datetime,
--	fct_env Datetime,
--	fct_plz int,
--	clc_mcm decimal(14,2),
--	fct_org char(1),
--	fct_prb varchar(17),
--	fct_prd char(10)  null,
--	fct_dsc decimal(9,6),
--	clc_cms decimal(9,6),
--	clc_row int,
--	pdc_pmd char(1),
--	pdc_lsp int,
--	fct_pfn decimal(14,2),
--	fct_rcb decimal(9,6),
--	fct_fci datetime,
--	fct_fcf datetime,
--	cms_asg int
--	 )

--Obtiene todas las facturas que son candidatas a generar comisión, de acuerdo al agente y fechas de clientes
Insert into tmp_fac_base_cms
SELECT bpmcxc.e0nenoeor, bpmcxc.l0neor, bprmpdfc.e1nseopdc, bprmpdfc.l2nfolpdc, bpmpdc.c0ntipsrt,
          bpmcxc.l2nfolcxc, bpmfct.e1nseofct, bpmfct.l2nfolfct, bpmfct.v0srfrfct, 
               ((bpmfct.d0nmntnet - bpmfct.d0nmntiva)*bpmpdc.d0neqvdvs) Total_importe,
          Sum(((bp1cxccb.d0nmntcbr*bpmpdc.d0neqvdvs) * ((bpmfct.d0nmntnet - bpmfct.d0nmntiva)*bpmpdc.d0neqvdvs)) / (bpmfct.d0nmntnet*bpmpdc.d0neqvdvs))/*fct_cbr*/,
          bpmfct.f0nfchfct, max(bpmcxc.f0sfchpagt), Null, 0, 0
  FROM bp1cxccb, bpmcbr, bpmcxc, bpmfct, bprmpdfc, bpmpdc, bpctippg
WHERE ( bpmfct.e1nseofct   = bpmcxc.e0nseodcm ) AND  
      ( bpmfct.f0nfchfct  >= year(getdate())-1 ) AND
      ( bpmfct.l2nfolfct   = bpmcxc.l0nfoldcm ) AND  
--     Datos de Cobranza y Cuentas por Cobrar
      ( bpmcxc.e0nseodcm   = bpmfct.e1nseofct ) AND  
      ( bpmcxc.l0nfoldcm   = bpmfct.l2nfolfct ) AND
      ( bp1cxccb.e1nseocxc = bpmcxc.e1nseocxc ) AND  
      ( bp1cxccb.l2nfolcxc = bpmcxc.l2nfolcxc ) AND 
      ( bpmcbr.e1nseocbr   = bp1cxccb.e3nseocbr ) AND  
      ( bpmcbr.l2nfolcbr   = bp1cxccb.l4nfolcbr ) AND
--  Datos del Pedido y Factura
      ( bpmpdc.e1nseopdc   = bprmpdfc.e1nseopdc ) AND  
      ( bpmpdc.l2nfolpdc   = bprmpdfc.l2nfolpdc ) AND  
      ( bprmpdfc.e4nseofct = bpmfct.e1nseofct ) AND  
      ( bprmpdfc.l5nfolfct = bpmfct.l2nfolfct ) AND  
-- Datos para condiciones
      ( bpmcbr.e0ntipdcm in ( Select e1ntippag From bpctippg Where e0ntipafc = 2 And e0ntipbnc In ( 6, 3, 5, 7, 4) And e1ntippag Not In (19,/*9,*/30)) Or (bpmcbr.e0ntipdcm = 19 And bpmcbr.c0nestcbr = 'T') ) AND  
      ( bpmcxc.c0nbndact   = 'S' ) AND  
      ( bpmcxc.d0nmntsld   = 0 ) AND  
      ( bpmcxc.c0sclccms   = 'N' ) AND  
      ( bpmfct.e1nseofct   = @seo ) AND  
      ( bpmfct.l0nvnd      = @agente ) AND  
	  --Quita abonos que no generan comision
	  ( bpctippg.e1ntippag Not In (20,21,27) ) AND
   	  ( bpmcbr.e0ntipdcm = bpctippg.e1ntippag ) AND
	  --
	  --	( bpmcxc.v0srfrdcm IN ( 'AEI274046','AEI274077','AEI274108','AEI274109','AEI274110','AEI274111' )  ) and
      ( bpmcxc.f0sfchpagt between @fec_ini And @fec_fin ) AND
      ( bpmfct.l2nfolfct Not In (Select l2nfolcxc From bprcxccmsdet Where bprcxccmsdet.e1nseocxc = bpmfct.e1nseofct And bprcxccmsdet.l0numvnd = @agente And bprcxccmsdet.c3tipdoc = 'F' And bprcxccmsdet.c0sestcbr = 'P' )  )
Group By 
bpmcxc.e0nenoeor, bpmcxc.l0neor, bprmpdfc.e1nseopdc, bprmpdfc.l2nfolpdc, bpmpdc.c0ntipsrt,
bpmcxc.l2nfolcxc, bpmfct.e1nseofct, bpmfct.l2nfolfct, bpmfct.v0srfrfct, 
bpmfct.d0nmntnet, bpmfct.d0nmntiva, bpmfct.f0nfchfct, bpmpdc.d0neqvdvs

Union All

SELECT distinct bpmcxc.e0nenoeor, bpmcxc.l0neor, bprmpdfc.e1nseopdc, bprmpdfc.l2nfolpdc, bpmpdc.c0ntipsrt,
bpmcxc.l2nfolcxc, bpmfct.e1nseofct, bpmfct.l2nfolfct, bpmfct.v0srfrfct, ((bpmfct.d0nmntnet - bpmfct.d0nmntiva)*bpmpdc.d0neqvdvs) Total_importe,
Sum(((bp1cxccb.d0nmntcbr*bpmpdc.d0neqvdvs) * ((bpmfct.d0nmntnet - bpmfct.d0nmntiva)*bpmpdc.d0neqvdvs)) / (bpmfct.d0nmntnet*bpmpdc.d0neqvdvs))/*fct_cbr*/,
bpmfct.f0nfchfct, Max(bpmcbr.f0sfchdcm)/*max(bpmcxc.f0sfchpagt)*/, Null, 0, 0/*,bpmcbr.l2nfolcbr,bpmcbr.e0ntipdcm, bpmcbr.f0sfchdcm*/
  FROM bp1cxccb, bpmcbr, bpmcxc, bpmfct, bprmpdfc, bpmpdc, bpctippg --, bprcxccmsdet
WHERE ( bpmfct.e1nseofct   = bpmcxc.e0nseodcm ) AND  
       ( bpmfct.f0nfchfct  >= year(getdate())-1 ) AND
       ( bpmfct.l2nfolfct   = bpmcxc.l0nfoldcm ) AND  
--     Datos de Cobranza y Cuentas por Cobrar
       ( bpmcxc.e0nseodcm   = bpmfct.e1nseofct   ) AND  
       ( bpmcxc.l0nfoldcm   = bpmfct.l2nfolfct   ) AND
       ( bp1cxccb.e1nseocxc = bpmcxc.e1nseocxc   ) AND  
       ( bp1cxccb.l2nfolcxc = bpmcxc.l2nfolcxc   ) AND 
       ( bpmcbr.e1nseocbr   = bp1cxccb.e3nseocbr ) AND  
       ( bpmcbr.l2nfolcbr   = bp1cxccb.l4nfolcbr ) AND
--  Datos del Pedido y Factura
       ( bpmpdc.e1nseopdc   = bprmpdfc.e1nseopdc ) AND  
       ( bpmpdc.l2nfolpdc   = bprmpdfc.l2nfolpdc ) AND  
       ( bprmpdfc.e4nseofct = bpmfct.e1nseofct ) AND  
       ( bprmpdfc.l5nfolfct = bpmfct.l2nfolfct ) AND  
-- Datos para condiciones
       ( bpmcbr.e0ntipdcm in ( Select e1ntippag From bpctippg Where e0ntipafc = 2 And e0ntipbnc In ( 6, 3, 5, 7, 4) And e1ntippag In (9,30) ) ) AND  
       ( bpmcxc.c0nbndact   = 'S' ) AND  
       ( bpmcxc.d0nmntsld   = 0 ) AND  
       ( bpmcxc.c0sclccms   = 'N' ) AND  
       ( bpmfct.e1nseofct   = @seo ) AND  
       ( bpmfct.l0nvnd      = @agente ) AND  
	   --Quita abonos que no genera comision
	   ( bpctippg.e1ntippag Not In (20,21,27) ) AND
   	   ( bpmcbr.e0ntipdcm = bpctippg.e1ntippag ) AND
	    --
		--	( bpmcxc.v0srfrdcm IN ( 'AEI274046','AEI274077','AEI274108','AEI274109','AEI274110','AEI274111' )  ) and
       ( bpmcxc.f0sfchpagt between @fec_ini And @fec_fin ) AND
       ( bpmfct.l2nfolfct Not In (Select l2nfolcxc From bprcxccmsdet Where e1nseocxc = bpmfct.e1nseofct And l0numvnd = @agente And c3tipdoc = 'F' And bprcxccmsdet.c0sestcbr = 'P' ) ) 
          AND ( bpmfct.l2nfolfct Not In (SELECT bpmfct.l2nfolfct 
                FROM bp1cxccb, bpmcbr, bpmcxc, bpmfct, bprmpdfc, bpmpdc, bpctippg 
                WHERE ( bpmfct.e1nseofct   = bpmcxc.e0nseodcm ) AND 
                    ( bpmfct.f0nfchfct >= year(getdate())-1 ) AND
                    ( bpmfct.l2nfolfct   = bpmcxc.l0nfoldcm ) AND  
                    ( bpmcxc.e0nseodcm   = bpmfct.e1nseofct ) AND  
                    ( bpmcxc.l0nfoldcm   = bpmfct.l2nfolfct ) AND
                    ( bp1cxccb.e1nseocxc = bpmcxc.e1nseocxc ) AND  
                    ( bp1cxccb.l2nfolcxc = bpmcxc.l2nfolcxc ) AND 
                    ( bpmcbr.e1nseocbr   = bp1cxccb.e3nseocbr ) AND  
                    ( bpmcbr.l2nfolcbr   = bp1cxccb.l4nfolcbr ) AND
                    ( bpmpdc.e1nseopdc   = bprmpdfc.e1nseopdc ) AND  
                    ( bpmpdc.l2nfolpdc   = bprmpdfc.l2nfolpdc ) AND  
                    ( bprmpdfc.e4nseofct = bpmfct.e1nseofct ) AND  
                    ( bprmpdfc.l5nfolfct = bpmfct.l2nfolfct ) AND  
                    ( bpmcbr.e0ntipdcm in ( Select e1ntippag From bpctippg Where e0ntipafc = 2 And e0ntipbnc In ( 6, 3, 5, 7, 4) And e1ntippag Not In (19,/*9,*/30)) Or (bpmcbr.e0ntipdcm = 19 And bpmcbr.c0nestcbr = 'T') ) AND  
                    ( bpmcxc.c0nbndact   = 'S' ) AND  
                    ( bpmcxc.d0nmntsld   = 0 ) AND  
                    ( bpmcxc.c0sclccms   = 'N' ) AND  
                    ( bpmfct.e1nseofct   = @seo ) AND  
                    ( bpmfct.l0nvnd      = @agente ) AND
					--Quita abonos que no genera comision
					( bpctippg.e1ntippag Not In (20,21,27) ) AND
   					( bpmcbr.e0ntipdcm = bpctippg.e1ntippag ) AND  
					--
                    ( bpmcxc.f0sfchpagt between @fec_ini And @fec_fin ) AND
                    ( bpmfct.l2nfolfct Not In (Select l2nfolcxc From bprcxccmsdet Where e1nseocxc = bpmfct.e1nseofct And l0numvnd = @agente And c3tipdoc = 'F' And bprcxccmsdet.c0sestcbr = 'P' ))))
Group By 
       bpmcxc.e0nenoeor, bpmcxc.l0neor, bprmpdfc.e1nseopdc, bprmpdfc.l2nfolpdc, bpmpdc.c0ntipsrt,
       bpmcxc.l2nfolcxc, bpmfct.e1nseofct, bpmfct.l2nfolfct, bpmfct.v0srfrfct, 
       bpmfct.d0nmntnet, bpmfct.d0nmntiva, bpmfct.f0nfchfct, bpmpdc.d0neqvdvs
Order By l2nfolfct

--Cursor para el cálculo de la fecha de envío y los días de plazo que lleva con respecto al pago de clientes
Declare act_fec_env cursor for 
	Select pdc_seo, pdc_fol, fct_fgn, fct_fpg, fct_ref  from tmp_fac_base_cms

Select @ciclo = 0

Open act_fec_env
While @ciclo = 0
   Begin 
	fetch act_fec_env into @pdc_seo, @pdc_fol, @fct_fgn, @fct_fpg, @fct_rfr
	Select @ciclo = @@fetch_status 

	--Obtiene la fecha de envío, en caso de no haber se toma la de generación 
	Select @fct_env  = 0 
	Select @fct_env  =  MIN( f0nfchopr) from bphpdcop 
	 where e1nseopdc = @pdc_seo and l2nfolpdc = @pdc_fol and (e0nestopr = 12 Or e0nestopr = 23)
     order by 1

	--Cálculo de los días de plazo con respecto al envío de la factura
	SELECT @fct_plz = 0
	Select @fct_plz  = Datediff( dd, @fct_env, @fct_fpg )

	--Para el caso de los pagos por adelantado
	If @fct_plz <= 0  select @fct_plz = 1

	Update tmp_fac_base_cms set fct_env = @fct_env, fct_plz = @fct_plz
	 where pdc_seo = @pdc_seo and pdc_fol = @pdc_fol AND fct_ref = @fct_rfr
	 SELECT @fct_plz = 0
   End 
Close act_fec_env
Deallocate act_fec_env

Select @ciclo = 0
SELECT @fct_plz = 0

-- Obtiene el detalle de los productos a calcular la comisión considerando los tiempos de los plazos
Truncate table tmp_fac_base_det_cms
Insert into tmp_fac_base_det_cms
Select tmp_fac_base_cms.*, c0nbndorg, v0scdprbs, v1nprd, Case When fctdt.d0nmntbrt = 0 then 1 
	   When fctdt.d0nmntbrt > 0 then Round((1-(((fctdt.d0nmntnet*bpmpdc.d0neqvdvs)-(fctdt.d0nmntiva*bpmpdc.d0neqvdvs))/(fctdt.d0nmntbrt*bpmpdc.d0neqvdvs))),4)*100 End/*Porc_Descto*/,
       0/*clc_cms*/, 0/*clc_row*/, 'X'/*pdc_pmd*/, -1/*pdc_lsp*/, (((fctdt.d0nmntnet*bpmpdc.d0neqvdvs)-(fctdt.d0nmntiva*bpmpdc.d0neqvdvs)))/*Sub_total*/, 0/*fct_rcb*/,
	   @fec_ini, @fec_fin, 0/*cms_asg*/
  from bp1fctpr fctdt, bpcprd, tmp_fac_base_cms, bpmfct, bpmpdc, bprmpdfc 
 where fctdt.e1nseofct = fct_seo 
   and fctdt.l2nfolfct = fct_fol
   and v1nprd    = v0nprd
   and bpmfct.e1nseofct = fctdt.e1nseofct
   and bpmfct.l2nfolfct = fctdt.l2nfolfct
   And bpmpdc.e1nseopdc = bprmpdfc.e1nseopdc 
   And bpmpdc.l2nfolpdc = bprmpdfc.l2nfolpdc
   And bpmfct.e1nseofct = bprmpdfc.e4nseofct
   And bpmfct.l2nfolfct = bprmpdfc.l5nfolfct

-- Cursor para evaluar registro por registro el tipo de comisión a considerar a nivel producto   
Declare asig_com Cursor For
 Select e0nlstprc, s0tipped, isnull(v0prdbas,''), d0prccms, Convert(Int, d0plzini), Convert(Int, d0plzfin), e1neno, l2ncln
   from bpcmsvc_new
  where c1stipdoc = 'C'
    and (d0fchini <= @fec_ini
    and  d0fchfin >= @fec_fin )
	and c0bndact = 'S'
  Order by d0fchini, d0fchfin, s0tipped desc, e0nlstprc desc, v0prdbas desc, d0plzini asc

Select @ciclo = 0
Open  asig_com
While @ciclo = 0
   Begin 

	fetch asig_com into @pdc_lsp, @pdc_tpd, @fct_prb, @clc_cms, @plz_ini, @plz_fin, @cli_seo, @cli_num

	Select @ciclo = @@fetch_status 
	If @@FETCH_STATUS < 0
	Break

	
	if @fct_prb <> '' /* and @pdc_lsp > 0  */
		Begin
		Update tmp_fac_base_det_cms set clc_cms = @clc_cms, 
		clc_mcm = Round((fct_cbr/fct_imp) * fct_pfn * ((@clc_cms)/100),4)
		 where pdc_tpd = @pdc_tpd 
		   and fct_prb like @fct_prb +'%' 
           and clc_cms = 0 
		   and fct_plz between @plz_ini and @plz_fin
		End

/*	if @fct_prb <> '' and @pdc_lsp = 0  
		Begin
		Update tmp_fac_base_det_cms   set clc_cms = @clc_cms, 
		clc_mcm = Round((fct_cbr/fct_imp) * fct_pfn * ((@clc_cms)/100),2)
		 where pdc_tpd = @pdc_tpd 
		   and fct_prb like @fct_prb +'%' 
           and clc_cms = 0 
		   and fct_plz between @plz_ini and @plz_fin
		End
*/
	if @fct_prb = '' and @pdc_tpd = 'T'/*@pdc_lsp > 0  */
		Begin
		Update tmp_fac_base_det_cms set clc_cms = @clc_cms, 
		clc_mcm = Round((fct_cbr/fct_imp) * fct_pfn * ((@clc_cms)/100),4)
		 where pdc_tpd = @pdc_tpd 
		   and clc_cms = 0 
		   and fct_plz between @plz_ini and @plz_fin
		End

	if @fct_prb = '' and @pdc_tpd = 'N' and @cli_num = 0/*@pdc_lsp = 0  */
		Begin
		Update tmp_fac_base_det_cms   set clc_cms = @clc_cms, 
		clc_mcm = Round((fct_cbr/fct_imp) * fct_pfn * ((@clc_cms)/100),4) 
		 where pdc_tpd = @pdc_tpd 
           and clc_cms = 0 
		   and fct_plz between @plz_ini and @plz_fin
		End
	
	if @fct_prb = '' and @pdc_tpd = 'N' and @cli_num > 0/*@pdc_lsp = 0  */
		Begin
		Update tmp_fac_base_det_cms   set clc_cms = @clc_cms, 
		clc_mcm = Round((fct_cbr/fct_imp) * fct_pfn * ((@clc_cms)/100),4) 
		 where pdc_tpd = @pdc_tpd 
		   and cli_seo = @cli_seo
		   and cli_num = @cli_num
           and clc_cms = 0 
		   and fct_plz between @plz_ini and @plz_ini
		End

   End 

Close asig_com
Deallocate asig_com


--Select clc_mcm = Round((fct_cbr/fct_imp) * fct_pfn * ((clc_cms)/100),2)
Update tmp_fac_base_det_cms set fct_rcb = fct_cbr/fct_imp, 
	clc_mcm = Round((fct_cbr/fct_imp) * fct_pfn * ((clc_cms)/100),4)
--where fct_seo = @fct_seo and fct_fol = @fct_fol and fct_prd = @fct_prd


Declare asig_com_cbr Cursor For
Select fct_seo, fct_fol, sum(clc_mcm), max(fct_env), max(fct_plz), max(fct_cbr) 
  from tmp_fac_base_det_cms 
 group by fct_seo, fct_fol
 order by 1,2


Select @ciclo = 0
Open  asig_com_cbr
While @ciclo = 0
   Begin 
	fetch asig_com_cbr into @fct_seo, @fct_fol, @clc_mcm, @fct_env, @fct_plz, @fct_cbr

	Select @ciclo = @@fetch_status 
	If @@FETCH_STATUS < 0
	Break

	Update tmp_fac_base_cms set fct_mcm = @clc_mcm
     where fct_seo = @fct_seo and cxc_fol = @fct_fol

--	Update bprcxccms set c0sestcbr = @stt_cms, c0dimpcbr = @clc_mcm, d0ffeccbr = getdate(), 
--		   d0ffecenv = @fct_env, c0dplzcbr = @fct_plz, c0dcbrefe = @fct_cbr
--	 where e1nseocxc = @fct_seo
--	   and l2nfolcxc = @fct_fol
--       and c0sestcbr <> 'P'

	Update bprcxccmsdet set c0sestcbr = @stt_cms, c0dimpcbr = @clc_mcm, d0ffeccbr = getdate(), 
		   d0ffecenv = @fct_env, c0dplzcbr = @fct_plz, c0dcbrefe = @fct_cbr
	  from bprcxccmsdet
	 where e1nseocxc = @fct_seo 
	   and l2nfolcxc = @fct_fol
	   and c3tipdoc = 'F'
       and c0sestcbr <> 'P'


   end
Close asig_com_cbr
Deallocate asig_com_cbr

SELECT @fct_plz = 0

/*******************************************************/
Declare asig_com_cbr_imp Cursor For
Select fct_seo, fct_fol, clc_cms, max(fct_plz), max(fct_imp),max(fct_cbr) , cms_asg
  from tmp_fac_base_det_cms 
 group by fct_seo, fct_fol,clc_cms, cms_asg
 order by 1,2


Select @ciclo = 0
Open  asig_com_cbr_imp
While @ciclo = 0
   Begin 
	fetch asig_com_cbr_imp into @fct_seo, @fct_fol, @clc_cms, @fct_plz, @fct_imp, @fct_cbr ,@cms_asg

	Select @ciclo = @@fetch_status 
	If @@FETCH_STATUS < 0
	Break
		Update tmp_fac_base_det_cms set cms_asg = Round((fct_cbr) *((clc_cms)/100),4)
	   	 where fct_seo = @fct_seo and fct_fol = @fct_fol
	End
Close asig_com_cbr_imp
Deallocate asig_com_cbr_imp

--Inserta las facturas que aun no tienen la comision por venta
Insert into bprcxccmsdet 
Select fct_seo, fct_fol, 'F', @seo, @agente, 'N', 0, getdate(), 'C', 0, null, Null, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
 From tmp_fac_base_cms, bpmfct
 Where fct_seo = bpmfct.e1nseofct 
   and fct_fol = bpmfct.l2nfolfct
--   and fct_mcm <> 0
   and bpmfct.l2nfolfct not in (Select l2nfolcxc from bprcxccmsdet where bpmfct.e1nseofct = bprcxccmsdet.e1nseocxc )
order by 1, 2


/*Guarda la comision en la cobranza */
Declare asig_Imp_Com_cbr Cursor For

Select fct_seo,fct_fol,fct_prd,clc_cms,clc_mcm,fct_plz
  from tmp_fac_base_det_cms 
  Where clc_cms <> 0
 order by 1,2

Select @ciclo = 0
Open  asig_Imp_Com_cbr
While @ciclo = 0
   Begin 
	fetch asig_Imp_Com_cbr into @fct_seo, @fct_fol, @fct_prd, @clc_cms, @clc_mcm, @fct_plz

	Select @ciclo = @@fetch_status 
	If @@FETCH_STATUS < 0
	Break

		/*Lo actualiza para Catálogo General*/
		Update bprcxccmsdet
		   Set d1nprcncmscbr = @clc_cms, 
		       c0dplzcbr = @fct_plz,
			   d2nmntcmscbr = (Select Sum(clc_mcm) 
								 From bp1fctpr fctd,tmp_fac_base_det_cms tmpcms, bprcxccmsdet rcms
								Where tmpcms.fct_seo = fctd.e1nseofct
								  And tmpcms.fct_fol = fctd.l2nfolfct
								  And tmpcms.fct_seo = rcms.e1nseocxc
								  And tmpcms.fct_fol = rcms.l2nfolcxc
								  And fctd.e1nseofct = rcms.e1nseocxc
								  And fctd.l2nfolfct = rcms.l2nfolcxc
								  And tmpcms.fct_seo = @fct_seo
								  And tmpcms.fct_fol = @fct_fol
								  And tmpcms.fct_prd = v0nprd
								  And SubString(fct_prd,1,3) <> 'TIM'
								Group By e1nseofct,l2nfolfct )
		  From bp1fctpr fctd,tmp_fac_base_det_cms tmpcms, bprcxccmsdet rcms
		 Where tmpcms.fct_seo = fctd.e1nseofct
		   And tmpcms.fct_fol = fctd.l2nfolfct
		   And tmpcms.fct_seo = rcms.e1nseocxc
		   And tmpcms.fct_fol = rcms.l2nfolcxc
	       And fctd.e1nseofct = rcms.e1nseocxc
		   And fctd.l2nfolfct = rcms.l2nfolcxc
		   And tmpcms.fct_seo = @fct_seo
		   And tmpcms.fct_fol = @fct_fol
		   And tmpcms.fct_prd = v0nprd
		   And SubString(fct_prd,1,3) <> 'TIM'

		/*Lo actualiza para Catálgo TIM*/
		Update bprcxccmsdet
		   Set d1nprcncmscbr = @clc_cms,
		       c0dplzcbr = @fct_plz,
			   d3nmntcmscbrtim = (Select Sum(clc_mcm) 
			                        From bp1fctpr fctd,tmp_fac_base_det_cms tmpcms, bprcxccmsdet rcms
								   Where tmpcms.fct_seo = fctd.e1nseofct
									 And tmpcms.fct_fol = fctd.l2nfolfct
									 And tmpcms.fct_seo = rcms.e1nseocxc
									 And tmpcms.fct_fol = rcms.l2nfolcxc
									 And fctd.e1nseofct = rcms.e1nseocxc
									 And fctd.l2nfolfct = rcms.l2nfolcxc
									 And tmpcms.fct_seo = @fct_seo
									 And tmpcms.fct_fol = @fct_fol
									 And tmpcms.fct_prd = v0nprd
									 And SubString(fct_prd,1,3) = 'TIM'
								   Group By e1nseofct,l2nfolfct ) 
		  From bp1fctpr fctd,tmp_fac_base_det_cms tmpcms, bprcxccmsdet rcms
		 Where tmpcms.fct_seo = fctd.e1nseofct
		   And tmpcms.fct_fol = fctd.l2nfolfct
		   And tmpcms.fct_seo = rcms.e1nseocxc
		   And tmpcms.fct_fol = rcms.l2nfolcxc
	       And fctd.e1nseofct = rcms.e1nseocxc
		   And fctd.l2nfolfct = rcms.l2nfolcxc
		   And tmpcms.fct_seo = @fct_seo
		   And tmpcms.fct_fol = @fct_fol
		   And tmpcms.fct_prd = v0nprd
		   And SubString(fct_prd,1,3) = 'TIM'
		
	End
Close asig_Imp_Com_cbr
Deallocate asig_Imp_Com_cbr

--Update tmp_fac_base set fct_mcm = isnull(fct_mcm,0) + @clc_mcm
-- where fct_seo = @fct_seo and fct_fol = @fct_fol 

--Update bp1fctpr set d0nmntcms = clc_mcm 
-- from tmp_fac_base_det, bp1fctpr
-- where e1nseofct = fct_seo 
--   and l2nfolfct = fct_fol
--   and v0nprd    = fct_prd 
--
--Update bpmfct set d0nmntcmsp = fct_mcm, d0nprcncms =  Round(fct_mcm / fct_cbr,4)
--  from bpmfct fct, tmp_fac_base 
-- where e1nseofct = fct_seo 
--   and l2nfolfct = fct_fol
--
--Update bpmcxc 
--   set f0sfchdcm = fct_env
--  from bpmcxc cxc, tmp_fac_base 
-- where e1nseocxc = fct_seo 
--   and l2nfolcxc = cxc_fol
--
--
--If (@stt_cms = 'S') and (@cms_cero = 'S')
--	Begin
--		Update bpmcxc 
--		   set c0sclccms = @stt_cms, 
--			   f0sfchdcm = fct_env
--		  from bpmcxc cxc, tmp_fac_base 
--		 where e1nseocxc = fct_seo 
--		   and l2nfolcxc = cxc_fol
--	End
--
--If (@stt_cms = 'S') and (@cms_cero = 'N')
--	Begin
--		Update bpmcxc 
--		   set c0sclccms = @stt_cms, 
--			   f0sfchdcm = fct_env
--		  from bpmcxc cxc, tmp_fac_base 
--		 where e1nseocxc = fct_seo 
--		   and l2nfolcxc = cxc_fol
--		   and fct_mcm > 0
--	End


END
Return;

select 'Order' as UnderTitle,
FirmID, FirmName, SiteID, SiteName, Title, DocNum as ID, null as CarModel, null as CarModelNum,
null as InsuranceCompany_isNULL, null as NotEmployee, null as ClientCategoryID, null as ClientCategoryDescr, null as ClientID, null as InsuranceCompanyID, null as ClientDescr,
DetType as TypeID, DetailType as Type, ManageCodeID, ManageCodeDescr, null as Qty, cast(JobQty as decimal(30,2)) as JobQty, null as PartQty, null as OtherQty,
cast(JobNDSAmount as decimal(30,2)) as JobNDSAmount, cast(PartNDSAmount as decimal(30,2)) as PartNDSAmount, cast(JobAndPartNDSAmount as decimal(30,2)) as GeneralAmount,
null as Amount1Auto3HangDiscount, null as Amount8AddDetail, null as NetCostNDs, null as Saldo, null as AmountWithoutNDs, null as NetCostWithoutNDs, null as Avizo,
 null as Revenue, null as Revenue2JobAnd4Other, null as Revenue3Part,
cast(ISNULL(abs(NatCostWithoutKIM),0) as decimal(30,2)) as NatCostWithoutKIM, cast(ISNULL(abs(NatCostWithKIM),0) as decimal(30,2)) as NatCostWithKIM,
/*ISNULL(abs(NatCostFromPartMovement),0) as NatCostFromPartMovement, ISNULL(abs(NatCostFromPartMovementNot),0) as NatCostFromPartMovementNot,*/
cast(ISNULL(abs(NatCostWithoutKIM),0) + ISNULL(abs(NatCostWithKIM),0) + ISNULL(abs(NatCostFromPartMovement),0) + ISNULL(abs(NatCostFromPartMovementNot),0) as decimal(30,2)) as NatCost,
 cast(JobAndPartNDSAmount - (ISNULL(abs(NatCostWithoutKIM),0) + ISNULL(abs(NatCostWithKIM),0) + ISNULL(abs(NatCostFromPartMovement),0) + ISNULL(abs(NatCostFromPartMovementNot),0)) as decimal(30,2)) as Income,
null as MargaNDs, null as Marga
from
(
select
oo.DocNum, ood.ID, ood.VRD_DetType AS DetType
, (case
when ood.VRD_DetType=1 then 'Заголовок'
when ood.VRD_DetType=2 then 'Работа'
when ood.VRD_DetType=3 then 'Запчасть'
when ood.VRD_DetType=4 then 'Др.услуга'
when ood.VRD_DetType=5 then 'Текст'
when ood.VRD_DetType=6 then 'Комментарий'
else '' end) as DetailType, (select Descr from VRD_B_PayMethod  WITH(NOLOCK) where ID=ood.VRD_ID_B_PayMethod) as ManageCodeID, (select Presentation from VRD_B_PayMethod  WITH(NOLOCK) where ID=ood.VRD_ID_B_PayMethod) as ManageCodeDescr
, oo.VRD_ID_B_Firm as FirmID, (select Presentation from VRD_B_Firm  WITH(NOLOCK) where ID=oo.VRD_ID_B_Firm) as FirmName, oo.VRD_ID_B_Site as SiteID, (select Presentation from VRD_B_Site  WITH(NOLOCK) where ID=oo.VRD_ID_B_Site) as SiteName
, 'Дооснащение новых а/м за счет ОП' as Title
, 0 as JobQty,  0  as JobNDSAmount, 0 as PartNDSAmount, 0  as JobAndPartNDSAmount
, (case when VRD_DetType = 4 and (ood.VRD_Code not like 'КиМ%' or (ood.VRD_Code is null and VRD_NetCostTotalLocal>0)) then VRD_NetCostTotalLocal else 0 end) as NatCostWithoutKIM
, (case when VRD_DetType = 4 and ood.VRD_Code like 'КиМ%' then 0.8 * VRD_NetCostTotalLocal else 0 end) as NatCostWithKIM
,
iif(ood.VRD_DetType = 3,
(select sum(VRD_AvgAmountLocal)/Sum(pm3.VRD_Qty)*ood.VRD_Qty from VRD_OutOrder oo3 WITH(NOLOCK) inner join VRD_OutOrderDet ood3 WITH(NOLOCK) on oo3.ID=ood3.VRD_ID_OutOrder inner join VRD_PartMovement pm3 WITH(NOLOCK) on pm3.VRD_ID_OutOrderDet=ood3.ID where DocNum in
(select ii2.VRD_SupplierRefNum
from VRD_OutInvoice oi2  WITH(NOLOCK) inner join VRD_OutOrderDet ood2  WITH(NOLOCK) on ood2.VRD_ID_OutInvoice=oi2.ID inner join VRD_OutOrder oo2 WITH(NOLOCK) on oi2.VRD_ID_OutOrder=oo2.ID inner join VRD_PartMovement pm2  WITH(NOLOCK) on pm2.VRD_ID_OutOrderDet=ood2.ID inner join VRD_IncomeInvoice ii2  WITH(NOLOCK) on ii2.ID=pm2.VRD_ID_OrigIncomeInvoice
where ood2.ID=ood.ID and ood2.VRD_DetType = 3 and (select Presentation from VRD_IncomeInvoice  WITH(NOLOCK) where ID=pm2.VRD_ID_OrigIncomeInvoice) like 'вн%')
and VRD_ID_B_SparePart in
(select pm2.VRD_ID_B_SparePart
from VRD_OutInvoice oi2  WITH(NOLOCK) inner join VRD_OutOrderDet ood2  WITH(NOLOCK) on ood2.VRD_ID_OutInvoice=oi2.ID inner join VRD_OutOrder oo2  WITH(NOLOCK) on oi2.VRD_ID_OutOrder=oo2.ID inner join VRD_PartMovement pm2  WITH(NOLOCK) on pm2.VRD_ID_OutOrderDet=ood2.ID inner join VRD_IncomeInvoice ii2  WITH(NOLOCK) on ii2.ID=pm2.VRD_ID_OrigIncomeInvoice
where ood2.ID=ood.ID and ood2.VRD_DetType = 3 and (select Presentation from VRD_IncomeInvoice  WITH(NOLOCK) where ID=pm2.VRD_ID_OrigIncomeInvoice) like 'вн%')
), 0) as NatCostFromPartMovement
,
iif(ood.VRD_DetType = 3,
(select sum(VRD_AvgAmountLocal)
from VRD_OutInvoice oi2  WITH(NOLOCK) inner join VRD_OutOrderDet ood2  WITH(NOLOCK) on ood2.VRD_ID_OutInvoice=oi2.ID inner join VRD_OutOrder oo2  WITH(NOLOCK) on oi2.VRD_ID_OutOrder=oo2.ID inner join VRD_PartMovement pm2  WITH(NOLOCK) on pm2.VRD_ID_OutOrderDet=ood2.ID
where ood2.ID=ood.ID and ood2.VRD_DetType = 3 and (select Presentation from VRD_IncomeInvoice WITH(NOLOCK) where ID=pm2.VRD_ID_OrigIncomeInvoice) not like 'вн%')
, 0)  as NatCostFromPartMovementNot

from VRD_OutInvoice oi  WITH(NOLOCK) inner join VRD_OutOrderDet ood  WITH(NOLOCK) on ood.VRD_ID_OutInvoice=oi.ID inner join VRD_OutOrder oo  WITH(NOLOCK) on oi.VRD_ID_OutOrder=oo.ID inner join VRD_PartMovement pm WITH(NOLOCK) on pm.VRD_ID_OutOrderDet=ood.ID
where (select Descr from VRD_B_PayMethod where ID=ood.VRD_ID_B_PayMethod) in (025) and oo.VRD_ID_B_Site in (select ID from VRD_B_Site  WITH(NOLOCK) where Flg_Deleted=0) and oo.VRD_Status=3 and ood.VRD_DetType in (2,3,4)  and ood.VRD_Title not like '%франшиз%'
and oi.VRD_PayType=2 and oo.DocNum not like 'вн%' and oo.VRD_ClientText not like '%Карс Фэмили%'and oo.VRD_ClientText not like '%Коррекция остатков%'  and oo.VRD_ID_B_ProfitCenter in (1005, 1001) and oi.DocDate between @PerDate1 and cast(convert(char(8), @PerDate2, 112) + ' 23:59:59.99' as datetime)
union
select
oo.DocNum, ood.ID,  ood.VRD_DetType AS DetType
, (case
when ood.VRD_DetType=1 then 'Заголовок'
when ood.VRD_DetType=2 then 'Работа'
when ood.VRD_DetType=3 then 'Запчасть'
when ood.VRD_DetType=4 then 'Др.услуга'
when ood.VRD_DetType=5 then 'Текст'
when ood.VRD_DetType=6 then 'Комментарий'
else '' end) as DetailType, (select Descr from VRD_B_PayMethod  WITH(NOLOCK) where ID=ood.VRD_ID_B_PayMethod) as ManageCodeID, (select Presentation from VRD_B_PayMethod  WITH(NOLOCK) where ID=ood.VRD_ID_B_PayMethod) as ManageCodeDescr
, oo.VRD_ID_B_Firm as FirmID, (select Presentation from VRD_B_Firm  WITH(NOLOCK) where ID=oo.VRD_ID_B_Firm) as FirmName, oo.VRD_ID_B_Site as SiteID, (select Presentation from VRD_B_Site WITH(NOLOCK)  where ID=oo.VRD_ID_B_Site) as SiteName
, (case
when (select Descr from VRD_B_PayMethod where ID=ood.VRD_ID_B_PayMethod)='001' then 'Розица сервис'
when (select Descr from VRD_B_PayMethod where ID=ood.VRD_ID_B_PayMethod)='006' then 'Розица сервис'
when (select Descr from VRD_B_PayMethod where ID=ood.VRD_ID_B_PayMethod)='008' then 'Розица сервис'
when (select Descr from VRD_B_PayMethod where ID=ood.VRD_ID_B_PayMethod)='009' then 'Гарантия'
when (select Descr from VRD_B_PayMethod where ID=ood.VRD_ID_B_PayMethod)='026' then 'Дооснащение новых а/м'
when (select Descr from VRD_B_PayMethod where ID=ood.VRD_ID_B_PayMethod)='050' then 'Розничная/оптовая продажа з/ч'
when (select Descr from VRD_B_PayMethod where ID=ood.VRD_ID_B_PayMethod)='002' then 'Розничная/оптовая продажа з/ч'
else '' end
) as Title
, (case when ood.VRD_DetType in (2) then ood.VRD_Qty else 0 end) as JobQty, (case when ood.VRD_DetType in (2,4) then VRD_Amount else 0 end) as JobNDSAmount, (case when ood.VRD_DetType=3 then VRD_Amount else 0 end) as PartNDSAmount, (case when ood.VRD_DetType in (2,3,4) then VRD_Amount else 0 end) as JobAndPartNDSAmount
, (case when VRD_DetType = 4 and (ood.VRD_Code not like 'КиМ%' or (ood.VRD_Code is null and VRD_NetCostTotalLocal>0)) then VRD_NetCostTotalLocal else 0 end) as NatCostWithoutKIM
, (case when VRD_DetType = 4 and ood.VRD_Code like 'КиМ%' then 0.8 * VRD_NetCostTotalLocal else 0 end) as NatCostWithKIM
,
iif(ood.VRD_DetType = 3,
(select sum(VRD_AvgAmountLocal)/Sum(pm3.VRD_Qty)*ood.VRD_Qty from VRD_OutOrder oo3 WITH(NOLOCK) inner join VRD_OutOrderDet ood3 WITH(NOLOCK) on oo3.ID=ood3.VRD_ID_OutOrder inner join VRD_PartMovement pm3 WITH(NOLOCK) on pm3.VRD_ID_OutOrderDet=ood3.ID where DocNum in
(select ii2.VRD_SupplierRefNum
from VRD_OutInvoice oi2  WITH(NOLOCK) inner join VRD_OutOrderDet ood2 WITH(NOLOCK) on ood2.VRD_ID_OutInvoice=oi2.ID inner join VRD_OutOrder oo2 WITH(NOLOCK) on oi2.VRD_ID_OutOrder=oo2.ID inner join VRD_PartMovement pm2 WITH(NOLOCK) on pm2.VRD_ID_OutOrderDet=ood2.ID inner join VRD_IncomeInvoice ii2 WITH(NOLOCK) on ii2.ID=pm2.VRD_ID_OrigIncomeInvoice
where ood2.ID=ood.ID and ood2.VRD_DetType = 3 and (select Presentation from VRD_IncomeInvoice WITH(NOLOCK) where ID=pm2.VRD_ID_OrigIncomeInvoice) like 'вн%')
and VRD_ID_B_SparePart in
(select pm2.VRD_ID_B_SparePart
from VRD_OutInvoice oi2 WITH(NOLOCK)  inner join VRD_OutOrderDet ood2 WITH(NOLOCK) on ood2.VRD_ID_OutInvoice=oi2.ID inner join VRD_OutOrder oo2 WITH(NOLOCK) on  oi2.VRD_ID_OutOrder=oo2.ID inner join VRD_PartMovement pm2 WITH(NOLOCK) on pm2.VRD_ID_OutOrderDet=ood2.ID inner join VRD_IncomeInvoice ii2 WITH(NOLOCK) on ii2.ID=pm2.VRD_ID_OrigIncomeInvoice
where ood2.ID=ood.ID and ood2.VRD_DetType = 3 and (select Presentation from VRD_IncomeInvoice WITH(NOLOCK) where ID=pm2.VRD_ID_OrigIncomeInvoice) like 'вн%')
), 0) as NatCostFromPartMovement
,
iif(ood.VRD_DetType = 3,
(select sum(VRD_AvgAmountLocal)
from VRD_OutInvoice oi2  WITH(NOLOCK) inner join VRD_OutOrderDet ood2 WITH(NOLOCK) on ood2.VRD_ID_OutInvoice=oi2.ID inner join VRD_OutOrder oo2 WITH(NOLOCK) on oi2.VRD_ID_OutOrder=oo2.ID inner join VRD_PartMovement pm2 WITH(NOLOCK) on pm2.VRD_ID_OutOrderDet=ood2.ID
where ood2.ID=ood.ID and ood2.VRD_DetType = 3 and (select Presentation from VRD_IncomeInvoice  WITH(NOLOCK) where ID=pm2.VRD_ID_OrigIncomeInvoice) not like 'вн%')
, 0)  as NatCostFromPartMovementNot

from VRD_OutInvoice oi  WITH(NOLOCK) inner join VRD_OutOrderDet ood  WITH(NOLOCK) on ood.VRD_ID_OutInvoice=oi.ID inner join VRD_OutOrder oo  WITH(NOLOCK) on oi.VRD_ID_OutOrder=oo.ID
where (select Descr from VRD_B_PayMethod  WITH(NOLOCK) where ID=ood.VRD_ID_B_PayMethod) in (001,006,008, 009, 026, 050,002) and oo.VRD_ID_B_Site in (select ID from VRD_B_Site  WITH(NOLOCK) where Flg_Deleted=0) and oo.VRD_Status=3 and ood.VRD_DetType in (2,3,4)  and ood.VRD_Title not like '%франшиз%'
and oi.VRD_PayType!=2 and oo.DocNum not like 'вн%' and oo.VRD_ClientText not like '%Карс Фэмили%'and oo.VRD_ClientText not like '%Коррекция остатков%'  and oo.VRD_ID_B_ProfitCenter in (1005, 1001) and oi.DocDate between @PerDate1 and cast(convert(char(8), @PerDate2, 112) + ' 23:59:59.99' as datetime)
and ((select Descr from VRD_B_ClientCategory  WITH(NOLOCK)  where ID=(select VRD_ID_B_ClientCategory   from B_Client  WITH(NOLOCK) where ID=oo.VRD_ID_B_Client))<>'Сотрудник' or (select Descr from VRD_B_ClientCategory  WITH(NOLOCK) where ID=(select VRD_ID_B_ClientCategory from B_Client WITH(NOLOCK)  where ID=oo.VRD_ID_B_Client)) is null )
union
select
oo.DocNum, ood.ID,  ood.VRD_DetType AS DetType
, (case
when ood.VRD_DetType=1 then 'Заголовок'
when ood.VRD_DetType=2 then 'Работа'
when ood.VRD_DetType=3 then 'Запчасть'
when ood.VRD_DetType=4 then 'Др.услуга'
when ood.VRD_DetType=5 then 'Текст'
when ood.VRD_DetType=6 then 'Комментарий'
else '' end) as DetailType, (select Descr from VRD_B_PayMethod WITH(NOLOCK)  where ID=ood.VRD_ID_B_PayMethod) as ManageCodeID, (select Presentation from VRD_B_PayMethod where ID=ood.VRD_ID_B_PayMethod) as ManageCodeDescr
, oo.VRD_ID_B_Firm as FirmID, (select Presentation from VRD_B_Firm WITH(NOLOCK)  where ID=oo.VRD_ID_B_Firm) as FirmName, oo.VRD_ID_B_Site as SiteID, (select Presentation from VRD_B_Site  WITH(NOLOCK) where ID=oo.VRD_ID_B_Site) as SiteName
, (case when (select Descr from VRD_B_ClientCategory where ID=(select VRD_ID_B_ClientCategory from B_Client  WITH(NOLOCK) where ID=oo.VRD_ID_B_Client))='Сотрудник' then  'Сотрудник' else '' end) as Title
, (case when VRD_DetType in (2) then ood.VRD_Qty else 0 end) as JobQty, (case when VRD_DetType in (2,4) then VRD_Amount else 0 end) as JobNDSAmount, (case when VRD_DetType=3 then VRD_Amount else 0 end) as PartNDSAmount, (case when VRD_DetType in (2,3,4) then VRD_Amount else 0 end) as JobAndPartNDSAmount
, (case when VRD_DetType = 4 and (ood.VRD_Code not like 'КиМ%' or (ood.VRD_Code is null and VRD_NetCostTotalLocal>0)) then VRD_NetCostTotalLocal else 0 end) as NatCostWithoutKIM
, (case when VRD_DetType = 4 and ood.VRD_Code like 'КиМ%' then 0.8 * VRD_NetCostTotalLocal else 0 end) as NatCostWithKIM
,
iif(ood.VRD_DetType = 3,
(select sum(VRD_AvgAmountLocal)/Sum(pm3.VRD_Qty)*ood.VRD_Qty from VRD_OutOrder oo3 WITH(NOLOCK) inner join VRD_OutOrderDet ood3 WITH(NOLOCK) on oo3.ID=ood3.VRD_ID_OutOrder inner join VRD_PartMovement pm3 WITH(NOLOCK) on pm3.VRD_ID_OutOrderDet=ood3.ID where DocNum in
(select ii2.VRD_SupplierRefNum
from VRD_OutInvoice oi2 WITH(NOLOCK)  inner join VRD_OutOrderDet ood2  WITH(NOLOCK) on ood2.VRD_ID_OutInvoice=oi2.ID inner join VRD_OutOrder oo2  WITH(NOLOCK) on oi2.VRD_ID_OutOrder=oo2.ID inner join VRD_PartMovement pm2 WITH(NOLOCK) on pm2.VRD_ID_OutOrderDet=ood2.ID inner join VRD_IncomeInvoice ii2 WITH(NOLOCK) on ii2.ID=pm2.VRD_ID_OrigIncomeInvoice
where ood2.ID=ood.ID and ood2.VRD_DetType = 3 and (select Presentation from VRD_IncomeInvoice WITH(NOLOCK)  where ID=pm2.VRD_ID_OrigIncomeInvoice) like 'вн%')
and VRD_ID_B_SparePart in
(select pm2.VRD_ID_B_SparePart
from VRD_OutInvoice oi2 WITH(NOLOCK)  inner join VRD_OutOrderDet ood2  WITH(NOLOCK) on ood2.VRD_ID_OutInvoice=oi2.ID inner join VRD_OutOrder oo2  WITH(NOLOCK) on oi2.VRD_ID_OutOrder=oo2.ID inner join VRD_PartMovement pm2 WITH(NOLOCK) on pm2.VRD_ID_OutOrderDet=ood2.ID inner join VRD_IncomeInvoice ii2 WITH(NOLOCK) on ii2.ID=pm2.VRD_ID_OrigIncomeInvoice
where ood2.ID=ood.ID and ood2.VRD_DetType = 3 and (select Presentation from VRD_IncomeInvoice WITH(NOLOCK)  where ID=pm2.VRD_ID_OrigIncomeInvoice) like 'вн%')
), 0) as NatCostFromPartMovement
,
iif(ood.VRD_DetType = 3,
(select sum(VRD_AvgAmountLocal)
from VRD_OutInvoice oi2  WITH(NOLOCK) inner join VRD_OutOrderDet ood2 WITH(NOLOCK) on ood2.VRD_ID_OutInvoice=oi2.ID inner join VRD_OutOrder oo2 WITH(NOLOCK) on oi2.VRD_ID_OutOrder=oo2.ID inner join VRD_PartMovement pm2 WITH(NOLOCK) on pm2.VRD_ID_OutOrderDet=ood2.ID
where ood2.ID=ood.ID and ood2.VRD_DetType = 3 and (select Presentation from VRD_IncomeInvoice  WITH(NOLOCK) where ID=pm2.VRD_ID_OrigIncomeInvoice) not like 'вн%')
, 0)  as NatCostFromPartMovementNot

from VRD_OutInvoice oi  WITH(NOLOCK) inner join VRD_OutOrderDet ood  WITH(NOLOCK) on ood.VRD_ID_OutInvoice=oi.ID inner join VRD_OutOrder oo  WITH(NOLOCK) on oi.VRD_ID_OutOrder=oo.ID
where (select Descr from VRD_B_ClientCategory WITH(NOLOCK)  where ID=(select VRD_ID_B_ClientCategory from B_Client WITH(NOLOCK)  where ID=oo.VRD_ID_B_Client)) is not null and
oo.VRD_ID_B_Site in (select ID from VRD_B_Site  WITH(NOLOCK) where Flg_Deleted=0) and oo.VRD_Status=3 and ood.VRD_DetType in (2,3,4) and  
ood.VRD_Title not like '%франшиз%'
and oi.VRD_PayType!=2 and oo.DocNum not like 'вн%' and oo.VRD_ClientText not like '%Карс Фэмили%' and oo.VRD_ClientText not like '%Коррекция остатков%' and oo.VRD_ID_B_ProfitCenter in (1005, 1001) and oi.DocDate
between @PerDate1 and cast(convert(char(8), @PerDate2, 112) + ' 23:59:59.99' as datetime)
) as T

UNION ALL

select 'UsedCar' as UnderTitle,
FirmID, (select Presentation from VRD_B_Firm where ID=FirmID) as FirmName, SiteID, (select Presentation from VRD_B_Site where ID=SiteID) as SiteName,
 null as Title, csDocNum as ID, null as CarModel, null as CarModelNum, null as InsuranceCompany_isNULL, null as NotEmployee, null as ClientCategoryID, null as ClientCategoryDescr,
  null as ClientID, null as InsuranceCompanyID, null as ClientDescr, VRD_ReceiveType as TypeID,
  (case when VRD_ReceiveType=4 then 'Выкуп' when VRD_ReceiveType=2 then 'Комиссия' else '' end) as Type, null as ManageCodeID, null as ManageCodeDescr, count(distinct csDocNum) as Qty, null as JobQty, null as PartQty, null as OtherQty, null as JobNDsAmount, null as PartNDsAmount, sum(VRD_AmountLocal) as GeneralAmount, null as Amount1Auto3HangDiscount, null as Amount8AddDetail, sum(NetCost) as NetCostNDs, null as Saldo, null as AmountWithoutNDs, null as NetCostWithoutNDs, null as Avizo, null as Revenue, null as Revenue2JobAnd4Other, null as Revenue3Part, null as NatCostWithoutKIM, null as NatCostWithKIM, null as NatCost, null as Income, cast(sum(Marga) as decimal(10,2)) as MargaNDs, cast(sum(MargaExVAT) as decimal(10,2)) as Marga
from
(select (select VRD_ID_B_Firm from VRD_CarSale where ID=csd.VRD_ID_CarSale) as FirmID,
(select VRD_ID_B_Site from VRD_CarSale WITH(NOLOCK)  where ID=csd.VRD_ID_CarSale) as SiteID, (select DocNum from VRD_CarSale where ID=csd.VRD_ID_CarSale) as csDocNum,
VRD_ReceiveType, VRD_CarSaleDetType, VRD_AmountLocal, csd.VRD_NetCostLocalCalc as NetCost, (VRD_AmountLocal-VRD_NetCostLocalCalc) as Marga,
 (VRD_AmountLocalExVAT-VRD_NetCostLocalCalcNoVat) as MargaExVAT from VRD_UsedCar uc inner join VRD_CarSaleDetail csd on uc.VRD_ID_CarSale=csd.VRD_ID_CarSale where (select VRD_ID_B_Site from VRD_CarSale where ID=csd.VRD_ID_CarSale) in
  (select ID from VRD_B_Site where Flg_Deleted=0) and VRD_ReceiveType in (2,4) and VRD_DSold between @PerDate1 and cast(convert(char(8), @PerDate2, 112) + ' 23:59:59.99' as datetime)) as T
group by FirmID, SiteID, VRD_ReceiveType, csDocNum

UNION ALL

select 'NewCar' as UnderTitle,
FirmID, (select Presentation from VRD_B_Firm where ID=FirmID) as FirmName, SiteID, (select Presentation from VRD_B_Site  WITH(NOLOCK) where ID=SiteID) as SiteName, null as Title, null as ID, CarModel, null as CarModelNum,
null as InsuranceCompany_isNULL, null as NotEmployee, null as ClientCategoryID, null as ClientCategoryDescr, null as ClientID, null as InsuranceCompanyID, null as ClientDescr,
DetType as TypeID, (case
when DetType=1 then 'Автомобиль'
when DetType=2 then 'Доп.услуга'
when DetType=3 then 'Ручная скидка'
when DetType=4 then 'Процент по кредиту'
when DetType=5 then 'Автомобиль в зачет'
when DetType=6 then 'Предпродажные расходы'
when DetType=7 then 'Автоскидка'
when DetType=8 then 'Дооборудование'
when DetType=9 then 'Стандартная скидка'
when DetType=10 then 'Переоборудование'
when DetType=11 then 'Скидка на дооборудование'
when DetType=12 then 'Скидка бонусами'
when DetType=14 then 'НДС с комиссии'
else '' end) as Type, null as ManageCodeID, null as ManageCodeDescr,
(case when DetType=1 then sum(Existing) else 0 end) as Qty,
null as JobQty, null as PartQty, null as OtherQty, null as JobNDSAmount, null as PartNDSAmount,
sum(AmountNDs) as GeneralAmount,
sum(case when DetType in (1,3) then AmountNDs else 0 end) as Amount1Auto3HangDiscount,
sum(case when DetType in (8) then AmountNDs else 0 end) as Amount8AddDetail,
/*sum(NetCostNDS8) as NetCostNDS8, sum(NatCostWithoutKIM) as NatCostWithoutKIM, sum(NatCostWithKIM) as NatCostWithKIM, sum(NatCostFromPartMovement) as NatCostFromPartMovement, sum(NatCostFromPartMovementNot) as NatCostFromPartMovement,*/
/*sum(ISNULL(abs(NetCostNDS8),0) + ISNULL(abs(NatCostWithoutKIM),0) + ISNULL(abs(NatCostWithKIM),0) + ISNULL(abs(NatCostFromPartMovement),0) + ISNULL(abs(NatCostFromPartMovementNot),0) ) as NetCostNDs, */
sum(ISNULL(NetCostNDS8,0) + ISNULL(NatCostWithoutKIM,0) + ISNULL(NatCostWithKIM,0) + ISNULL(NatCostFromPartMovement,0) + ISNULL(NatCostFromPartMovementNot,0) ) as NetCostNDs, sum(Saldo) as Saldo, sum(AmountWithoutNDs) as AmountWithoutNDs,
iif(DetType=2
, sum(ISNULL(NetCostNDS8,0) + ISNULL(NatCostWithoutKIM,0) + ISNULL(NatCostWithKIM,0) + ISNULL(NatCostFromPartMovement,0) + ISNULL(NatCostFromPartMovementNot,0) )
, sum(ISNULL(NetCostNDS8woNDS,0) + ISNULL(NatCostWithoutKIMwoNDS,0) + ISNULL(NatCostWithKIMwoNDS,0) + ISNULL(NatCostFromPartMovementwoNDS,0) + ISNULL(NatCostFromPartMovementNotwoNDS,0) ) ) as NetCostWithoutNDs,
sum(Avizo) as Avizo, null as Revenue, null as Revenue2JobAnd4Other, null as Revenue3Part, null as NatCostWithoutKIM, null as NatCostWithKIM, null as NatCost, null as Income, null as MargaNDs, null as Marga

from (

select
cs.VRD_ID_B_Firm as FirmID, cs.VRD_ID_B_Site as SiteID, cs.ID as CarSale_ID, csd.ID as CarSaleDet_ID, csd.VRD_CarSaleDetType as DetType, c.ID as Car_ID, (select Presentation from VRD_B_CarModel where ID=(select VRD_ID_B_CarModel from VRD_CarOrder where ID=cs.VRD_ID_CarOrder)) as CarModel
, (case when ((csd.VRD_AmountLocal+csd.VRD_NetCostLocalFact+csd.VRD_AmountLocalExVAT+csd.VRD_NetCostLocalFactNoVat)=0 or (csd.VRD_AmountLocal is null and csd.VRD_NetCostLocalFact is null and csd.VRD_AmountLocalExVAT is null and csd.VRD_NetCostLocalFactNoVat is null)) and csd.VRD_CarSaleDetType != 1  then 0 else 1 end) as Existing
, csd.VRD_AmountLocal as AmountNDs
,
(case when (csd.VRD_CarSaleDetType!=8 and csd.VRD_CarSaleDetType!=10) then csd.VRD_NetCostLocalFact else 0 end) NetCostNDS8
,
(case when (csd.VRD_CarSaleDetType!=8 and csd.VRD_CarSaleDetType!=10 ) then csd.VRD_NetCostLocalFactNoVat else 0 end) NetCostNDS8woNDS
,
(case when csd.VRD_CarSaleDetType=8 then (select sum(VRD_NetCostTotalLocal)  from  VRD_OutOrderDet ood1
where ood1.VRD_ForeignID is not null and ood1.VRD_DetType = 4 and ood1.VRD_ID_OutOrder in (select VRD_ID_OutOrder from VRD_CarSaleExtraGear where VRD_ID_CarSale=cs.ID and VRD_ExtraGearPaymentMethod in (1,2))
and (ood1.VRD_Code not like 'КиМ%' or (ood1.VRD_Code is null and ood1.VRD_NetCostTotalLocal>0)))
else
(case when csd.VRD_CarSaleDetType=10 then (select sum(VRD_NetCostTotalLocal)  from  VRD_OutOrderDet ood1
where ood1.VRD_ForeignID is not null and ood1.VRD_DetType = 4 and ood1.VRD_ID_OutOrder in (select VRD_ID_OutOrder from VRD_CarOrderExtraGear where   VRD_ID_CarOrder in(select VRD_ID_CarOrder from VRD_Carsale where ID=cs.ID))
and (ood1.VRD_Code not like 'КиМ%' or (ood1.VRD_Code is null and ood1.VRD_NetCostTotalLocal>0)))
else 0 end)
end) as NatCostWithoutKIM
,
(case when csd.VRD_CarSaleDetType=8 then (select sum(VRD_NetCostTotalLocalNoVat)  from  VRD_OutOrderDet ood1
where ood1.VRD_ForeignID is not null and ood1.VRD_DetType = 4 and ood1.VRD_ID_OutOrder in (select VRD_ID_OutOrder from VRD_CarSaleExtraGear where VRD_ID_CarSale=cs.ID and VRD_ExtraGearPaymentMethod in (1,2))
and (ood1.VRD_Code not like 'КиМ%' or (ood1.VRD_Code is null and ood1.VRD_NetCostTotalLocalNoVat>0)))
else
(case when csd.VRD_CarSaleDetType=10 then (select sum(VRD_NetCostTotalLocalNoVat)  from  VRD_OutOrderDet ood1
where ood1.VRD_ForeignID is not null and ood1.VRD_DetType = 4 and ood1.VRD_ID_OutOrder in (select VRD_ID_OutOrder from VRD_CarOrderExtraGear where   VRD_ID_CarOrder in(select VRD_ID_CarOrder from VRD_Carsale where ID=cs.ID))
and (ood1.VRD_Code not like 'КиМ%' or (ood1.VRD_Code is null and ood1.VRD_NetCostTotalLocalNoVat>0)))
else 0 end)
end) as NatCostWithoutKIMwoNDS
,
(case when csd.VRD_CarSaleDetType=8 then (select sum(0.8 *VRD_NetCostTotalLocal)  from  VRD_OutOrderDet ood1
where ood1.VRD_ForeignID is not null and ood1.VRD_DetType = 4 and ood1.VRD_ID_OutOrder in (select VRD_ID_OutOrder from VRD_CarSaleExtraGear where VRD_ID_CarSale=cs.ID and VRD_ExtraGearPaymentMethod in (1,2))
and (ood1.VRD_Code like 'КиМ%' or (ood1.VRD_Code is null and ood1.VRD_NetCostTotalLocal>0)))
else
(case when csd.VRD_CarSaleDetType=10 then (select sum(0.8 *VRD_NetCostTotalLocal)  from  VRD_OutOrderDet ood1
where ood1.VRD_ForeignID is not null and ood1.VRD_DetType = 4 and ood1.VRD_ID_OutOrder in (select VRD_ID_OutOrder from VRD_CarOrderExtraGear where   VRD_ID_CarOrder in(select VRD_ID_CarOrder from VRD_Carsale where ID=cs.ID))
and (ood1.VRD_Code like 'КиМ%' or (ood1.VRD_Code is null and ood1.VRD_NetCostTotalLocal>0)))
else 0 end)
end) as NatCostWithKIM
,
(case when csd.VRD_CarSaleDetType=8 then (select sum(0.8 *VRD_NetCostTotalLocalNoVat)  from  VRD_OutOrderDet ood1
where ood1.VRD_ForeignID is not null and ood1.VRD_DetType = 4 and ood1.VRD_ID_OutOrder in (select VRD_ID_OutOrder from VRD_CarSaleExtraGear where VRD_ID_CarSale=cs.ID and VRD_ExtraGearPaymentMethod in (1,2))
and (ood1.VRD_Code like 'КиМ%' or (ood1.VRD_Code is null and ood1.VRD_NetCostTotalLocalNoVat>0)))
else
(case when csd.VRD_CarSaleDetType=10 then (select sum(0.8 *VRD_NetCostTotalLocalNoVat)  from  VRD_OutOrderDet ood1
where ood1.VRD_ForeignID is not null and ood1.VRD_DetType = 4 and ood1.VRD_ID_OutOrder in (select VRD_ID_OutOrder from VRD_CarOrderExtraGear where   VRD_ID_CarOrder in(select VRD_ID_CarOrder from VRD_Carsale where ID=cs.ID))
and (ood1.VRD_Code like 'КиМ%' or (ood1.VRD_Code is null and ood1.VRD_NetCostTotalLocalNoVat>0)))
else 0 end)
end) as NatCostWithKIMwoNDS
,

iif(csd.VRD_CarSaleDetType=8 , abs(
(select sum(total) from  
(select
(select sum(VRD_AvgAmountLocal)/Sum(pm3.VRD_Qty)*ood1.VRD_Qty
from VRD_OutOrder oo3 inner join VRD_OutOrderDet ood3 on oo3.ID=ood3.VRD_ID_OutOrder inner join VRD_PartMovement pm3 on pm3.VRD_ID_OutOrderDet=ood3.ID
where
DocNum in
(select ii2.VRD_SupplierRefNum
from VRD_OutInvoice oi2 inner join VRD_OutOrderDet ood2 on ood2.VRD_ID_OutInvoice=oi2.ID inner join VRD_OutOrder oo2 on oi2.VRD_ID_OutOrder=oo2.ID inner join
VRD_PartMovement pm2 on pm2.VRD_ID_OutOrderDet=ood2.ID inner join VRD_IncomeInvoice ii2 on ii2.ID=pm2.VRD_ID_OrigIncomeInvoice
where ood2.ID=ood1.ID and ood2.VRD_DetType = 3 and (select Presentation from VRD_IncomeInvoice where ID=pm2.VRD_ID_OrigIncomeInvoice) like 'вн%')
and VRD_ID_B_SparePart in
(select pm2.VRD_ID_B_SparePart
from VRD_OutInvoice oi2 inner join VRD_OutOrderDet ood2 on ood2.VRD_ID_OutInvoice=oi2.ID inner join VRD_OutOrder oo2 on oi2.VRD_ID_OutOrder=oo2.ID inner join
VRD_PartMovement pm2 on pm2.VRD_ID_OutOrderDet=ood2.ID inner join VRD_IncomeInvoice ii2 on ii2.ID=pm2.VRD_ID_OrigIncomeInvoice
where ood2.ID=ood1.ID and ood2.VRD_DetType = 3 and (select Presentation from VRD_IncomeInvoice where ID=pm2.VRD_ID_OrigIncomeInvoice) like 'вн%')
) as total
from  VRD_OutOrderDet ood1
where  ood1.VRD_DetType = 3 and ood1.VRD_ID_OutOrder
in( select VRD_ID_OutOrder from VRD_CarSaleExtraGear where  VRD_ExtraGearPaymentMethod in (1,2) and  VRD_ID_CarSale=cs.ID)) tbl
)) ,
iif(csd.VRD_CarSaleDetType=10 , abs(
(select sum(total) from  
(select
(select sum(VRD_AvgAmountLocal)/Sum(pm3.VRD_Qty)*ood1.VRD_Qty
from VRD_OutOrder oo3 inner join VRD_OutOrderDet ood3 on oo3.ID=ood3.VRD_ID_OutOrder inner join VRD_PartMovement pm3 on pm3.VRD_ID_OutOrderDet=ood3.ID
where
DocNum in
(select ii2.VRD_SupplierRefNum
from VRD_OutInvoice oi2 inner join VRD_OutOrderDet ood2 on ood2.VRD_ID_OutInvoice=oi2.ID inner join VRD_OutOrder oo2 on oi2.VRD_ID_OutOrder=oo2.ID inner join
VRD_PartMovement pm2 on pm2.VRD_ID_OutOrderDet=ood2.ID inner join VRD_IncomeInvoice ii2 on ii2.ID=pm2.VRD_ID_OrigIncomeInvoice
where ood2.ID=ood1.ID and ood2.VRD_DetType = 3 and (select Presentation from VRD_IncomeInvoice where ID=pm2.VRD_ID_OrigIncomeInvoice) like 'вн%')
and VRD_ID_B_SparePart in
(select pm2.VRD_ID_B_SparePart
from VRD_OutInvoice oi2 inner join VRD_OutOrderDet ood2 on ood2.VRD_ID_OutInvoice=oi2.ID inner join VRD_OutOrder oo2 on oi2.VRD_ID_OutOrder=oo2.ID inner join
VRD_PartMovement pm2 on pm2.VRD_ID_OutOrderDet=ood2.ID inner join VRD_IncomeInvoice ii2 on ii2.ID=pm2.VRD_ID_OrigIncomeInvoice
where ood2.ID=ood1.ID and ood2.VRD_DetType = 3 and (select Presentation from VRD_IncomeInvoice where ID=pm2.VRD_ID_OrigIncomeInvoice) like 'вн%')
) as total
from  VRD_OutOrderDet ood1
where  ood1.VRD_DetType = 3 and ood1.VRD_ID_OutOrder
in( select VRD_ID_OutOrder from VRD_CarOrderExtraGear where   VRD_ID_CarOrder in(select VRD_ID_CarOrder from VRD_Carsale where ID=cs.ID))) tbl
)) , 0)
) as NatCostFromPartMovement
,
iif(csd.VRD_CarSaleDetType=8 , abs(
(select sum(total) from  
(select
(select sum(VRD_AvgAmountLocalExVAT)/Sum(pm3.VRD_Qty)*ood1.VRD_Qty
from VRD_OutOrder oo3 inner join VRD_OutOrderDet ood3 on oo3.ID=ood3.VRD_ID_OutOrder inner join VRD_PartMovement pm3 on pm3.VRD_ID_OutOrderDet=ood3.ID
where
DocNum in
(select ii2.VRD_SupplierRefNum
from VRD_OutInvoice oi2 inner join VRD_OutOrderDet ood2 on ood2.VRD_ID_OutInvoice=oi2.ID inner join VRD_OutOrder oo2 on oi2.VRD_ID_OutOrder=oo2.ID inner join
VRD_PartMovement pm2 on pm2.VRD_ID_OutOrderDet=ood2.ID inner join VRD_IncomeInvoice ii2 on ii2.ID=pm2.VRD_ID_OrigIncomeInvoice
where ood2.ID=ood1.ID and ood2.VRD_DetType = 3 and (select Presentation from VRD_IncomeInvoice where ID=pm2.VRD_ID_OrigIncomeInvoice) like 'вн%')
and VRD_ID_B_SparePart in
(select pm2.VRD_ID_B_SparePart
from VRD_OutInvoice oi2 inner join VRD_OutOrderDet ood2 on ood2.VRD_ID_OutInvoice=oi2.ID inner join VRD_OutOrder oo2 on oi2.VRD_ID_OutOrder=oo2.ID inner join
VRD_PartMovement pm2 on pm2.VRD_ID_OutOrderDet=ood2.ID inner join VRD_IncomeInvoice ii2 on ii2.ID=pm2.VRD_ID_OrigIncomeInvoice
where ood2.ID=ood1.ID and ood2.VRD_DetType = 3 and (select Presentation from VRD_IncomeInvoice where ID=pm2.VRD_ID_OrigIncomeInvoice) like 'вн%')
) as total
from  VRD_OutOrderDet ood1
where  ood1.VRD_DetType = 3 and ood1.VRD_ID_OutOrder
in( select VRD_ID_OutOrder from VRD_CarSaleExtraGear where  VRD_ExtraGearPaymentMethod in (1,2) and  VRD_ID_CarSale=cs.ID)) tbl
)) ,
iif(csd.VRD_CarSaleDetType=10 , abs(
(select sum(total) from  
(select
(select sum(VRD_AvgAmountLocalExVAT)/Sum(pm3.VRD_Qty)*ood1.VRD_Qty
from VRD_OutOrder oo3 inner join VRD_OutOrderDet ood3 on oo3.ID=ood3.VRD_ID_OutOrder inner join VRD_PartMovement pm3 on pm3.VRD_ID_OutOrderDet=ood3.ID
where
DocNum in
(select ii2.VRD_SupplierRefNum
from VRD_OutInvoice oi2 inner join VRD_OutOrderDet ood2 on ood2.VRD_ID_OutInvoice=oi2.ID inner join VRD_OutOrder oo2 on oi2.VRD_ID_OutOrder=oo2.ID inner join
VRD_PartMovement pm2 on pm2.VRD_ID_OutOrderDet=ood2.ID inner join VRD_IncomeInvoice ii2 on ii2.ID=pm2.VRD_ID_OrigIncomeInvoice
where ood2.ID=ood1.ID and ood2.VRD_DetType = 3 and (select Presentation from VRD_IncomeInvoice where ID=pm2.VRD_ID_OrigIncomeInvoice) like 'вн%')
and VRD_ID_B_SparePart in
(select pm2.VRD_ID_B_SparePart
from VRD_OutInvoice oi2 inner join VRD_OutOrderDet ood2 on ood2.VRD_ID_OutInvoice=oi2.ID inner join VRD_OutOrder oo2 on oi2.VRD_ID_OutOrder=oo2.ID inner join
VRD_PartMovement pm2 on pm2.VRD_ID_OutOrderDet=ood2.ID inner join VRD_IncomeInvoice ii2 on ii2.ID=pm2.VRD_ID_OrigIncomeInvoice
where ood2.ID=ood1.ID and ood2.VRD_DetType = 3 and (select Presentation from VRD_IncomeInvoice where ID=pm2.VRD_ID_OrigIncomeInvoice) like 'вн%')
) as total
from  VRD_OutOrderDet ood1
where  ood1.VRD_DetType = 3 and ood1.VRD_ID_OutOrder
in( select VRD_ID_OutOrder from VRD_CarOrderExtraGear where    VRD_ID_CarOrder in(select VRD_ID_CarOrder from VRD_Carsale where ID=cs.ID))) tbl
)) , 0)
) as NatCostFromPartMovementwoNDS
,
iif(csd.VRD_CarSaleDetType=8 , abs(
(select sum(total2) from
(select sum(VRD_AvgAmountLocal) as total2
from VRD_OutOrderDet ood2 inner join VRD_PartMovement pm2 on pm2.VRD_ID_OutOrderDet=ood2.ID
where ood2.VRD_DetType = 3 and
(select Presentation from VRD_IncomeInvoice where ID=pm2.VRD_ID_OrigIncomeInvoice) not like 'вн%'
and ood2.VRD_ID_OutOrder in (select VRD_ID_OutOrder from VRD_CarSaleExtraGear where VRD_ID_CarSale=cs.ID and VRD_ExtraGearPaymentMethod in (1,2))
) tbl3
))
,
iif(csd.VRD_CarSaleDetType=10 , abs(
(select sum(total2) from
(select sum(VRD_AvgAmountLocal) as total2
from VRD_OutOrderDet ood2 inner join VRD_PartMovement pm2 on pm2.VRD_ID_OutOrderDet=ood2.ID
where ood2.VRD_DetType = 3 and
(select Presentation from VRD_IncomeInvoice where ID=pm2.VRD_ID_OrigIncomeInvoice) not like 'вн%'
and ood2.VRD_ID_OutOrder in (select VRD_ID_OutOrder from VRD_CarOrderExtraGear where VRD_ID_CarOrder in(select VRD_ID_CarOrder from VRD_Carsale where ID=cs.ID) )
) tbl3
))
, 0)
) as NatCostFromPartMovementNot
,
iif(csd.VRD_CarSaleDetType=8 , abs(
(select sum(total2) from
(select sum(VRD_AvgAmountLocalExVAT) as total2
from VRD_OutOrderDet ood2 inner join VRD_PartMovement pm2 on pm2.VRD_ID_OutOrderDet=ood2.ID
where ood2.VRD_DetType = 3 and
(select Presentation from VRD_IncomeInvoice where ID=pm2.VRD_ID_OrigIncomeInvoice) not like 'вн%'
and ood2.VRD_ID_OutOrder in (select VRD_ID_OutOrder from VRD_CarSaleExtraGear where VRD_ID_CarSale=cs.ID and VRD_ExtraGearPaymentMethod in (1,2))
) tbl3
))
,
iif(csd.VRD_CarSaleDetType=10 , abs(
(select sum(total2) from
(select sum(VRD_AvgAmountLocalExVAT) as total2
from VRD_OutOrderDet ood2 inner join VRD_PartMovement pm2 on pm2.VRD_ID_OutOrderDet=ood2.ID
where ood2.VRD_DetType = 3 and
(select Presentation from VRD_IncomeInvoice where ID=pm2.VRD_ID_OrigIncomeInvoice) not like 'вн%'
and ood2.VRD_ID_OutOrder in (select VRD_ID_OutOrder from VRD_CarOrderExtraGear where VRD_ID_CarOrder in(select VRD_ID_CarOrder from VRD_Carsale where ID=cs.ID))
) tbl3
))
, 0)) as NatCostFromPartMovementNotwoNDS


, iif(csd.VRD_CarSaleDetType=8, (select csd.VRD_AmountLocal - sum(VRD_NetCostTotalLocal) from VRD_OutOrderDet where VRD_ID_OutOrder in (select VRD_ID_OutOrder from VRD_CarSaleExtraGear where VRD_ID_CarSale=cs.ID and VRD_ExtraGearPaymentMethod in (1,2)) and VRD_DetType!=2), (csd.VRD_AmountLocal - ISNULL(csd.VRD_NetCostLocalFact,0))) as Saldo, csd.VRD_AmountLocalExVAT as AmountWithoutNDs, iif(csd.VRD_CarSaleDetType=8, (select sum(VRD_NetCostTotalLocalNoVAT) from VRD_OutOrderDet where VRD_ID_OutOrder in (select VRD_ID_OutOrder from VRD_CarSaleExtraGear where VRD_ID_CarSale=cs.ID and VRD_ExtraGearPaymentMethod=1) and VRD_DetType!=2), csd.VRD_NetCostLocalFactNoVat) as NetCostWithoutNDs, iif(csd.VRD_CarSaleDetType=9, VRD_NetCostLocalCalcNoVat, 0) as Avizo
, (case when csd.VRD_CarSaleDetType=1 then csd.VRD_AmountLocal else 0 end) as AutoAmountNDs, (case when csd.VRD_CarSaleDetType=3 then csd.VRD_AmountLocal else 0 end) as HangDiscountAmountNDs, (case when csd.VRD_CarSaleDetType=8 then csd.VRD_AmountLocal else 0 end) as AddDetailsAmountNDs
from VRD_CarSale as cs inner join VRD_CarSaleDetail as csd on cs.ID=csd.VRD_ID_CarSale inner join B_Car as c on cs.VRD_ID_CarOrder=c.ID
where cs.VRD_ID_B_Firm in (select ID from VRD_B_Firm where Flg_Deleted=0) and cs.VRD_ID_B_Site in (select ID from VRD_B_Site where Flg_Deleted=0)
and cs.VRD_ID_UsedCar is null and VRD_Status=2 and cs.VRD_DSold between @PerDate1 and cast(convert(char(8), @PerDate2, 112) + ' 23:59:59.99' as datetime)
) as T
where  DetType<15 and DetType>0 and CarModel!=''
group by FirmID, SiteID, CarModel, DetType
UNION ALL

select 'MKC' as UnderTitle,FirmID , (select Presentation from VRD_B_Firm where ID=FirmID) as FirmName, SiteID, (select Presentation from VRD_B_Site where ID=SiteID) as SiteName,
(case
when InsuranceCompany_isNULL=1 and NotEmployee=1 then 'Розничные клиенты'
when InsuranceCompany_isNULL=0 and NotEmployee=1 then 'Страховая компания'
when InsuranceCompany_isNULL=1 and NotEmployee=0 then 'Сотрудник'
else '' end) as Title
, null as ID, null as CarModel, null as CarModelNum, InsuranceCompany_isNULL, NotEmployee
, ClientCategoryID, ClientCategoryDescr, ClientID, VRD_ID_B_InsuranceCompany, (select Presentation from B_Client where ID=ClientID) as ClientDescr
, DetType as TypeID, DetailType as Type, ManageCodeID, ManageCodeDescr
, cast(QtyJob as decimal(30,2)) as Qty, cast(QtyJob as decimal(30,2)) as JobQty, cast(QtyPart as decimal(30,2)) as PartQty, cast(QtyOther as decimal(30,2)) as OtherQty
, null as JobNDsAmount, null as PartNDsAmount, null as GeneralAmount, null as Amount1Auto3HangDiscount, null as Amount8AddDetail
, null as NetCostNDs, null as Saldo, null as AmountWithoutNDs, null as NetCostWithoutNDs, null as Avizo
, cast(VRD_Amount as decimal(30,2)) as Revenue, (case when DetType in (2,4) then cast(VRD_Amount as decimal(30,2)) else 0 end) as Revenue2JobAnd4Other, (case when DetType in (3) then cast(VRD_Amount as decimal(30,2)) else 0 end) as Revenue3Part
, cast(ISNULL(abs(NatCostTotalWithoutKIM),0) as decimal(30,2)) as NatCostWithoutKIM, cast(ISNULL(abs(NatCostTotalWithKIM),0) as decimal(30,2)) as NatCostWithKIM, cast(ISNULL(abs(NatCostTotalWithoutKIM),0) + ISNULL(abs(NatCostTotalWithKIM),0) + ISNULL(abs(NatCostFromPartMovement),0) + ISNULL(abs(NatCostFromPartMovementNot),0) as decimal(30,2)) as NatCost
, cast((ISNULL(VRD_Amount,0) - (ISNULL(NatCostTotalWithoutKIM,0) + ISNULL(NatCostTotalWithKIM,0))) as decimal(30,2)) as Income
, null as MargaNDs, null as Marga
from (select
(case when VRD_ID_B_InsuranceCompany is null then 1 else 0 end) as InsuranceCompany_isNULL
, oo.VRD_ID_B_Firm as FirmID
, oo.VRD_ID_B_Site as SiteID
, (case when (select VRD_ID_B_ClientCategory from B_Client where ID=oo.VRD_ID_B_Client)=(select ID from VRD_B_ClientCategory where Descr='Сотрудник') then 0 else 1 end) as NotEmployee
, oi.VRD_ID_B_Client as ClientID
, VRD_ID_B_InsuranceCompany
, (select VRD_ID_B_ClientCategory from B_Client where ID=oi.VRD_ID_B_Client) as ClientCategoryID
, (select Descr from VRD_B_ClientCategory where ID=(select VRD_ID_B_ClientCategory from B_Client where ID=oi.VRD_ID_B_Client)) as ClientCategoryDescr
, ood.VRD_DetType AS DetType
, (case
when ood.VRD_DetType=1 then 'Заголовок'
when ood.VRD_DetType=2 then 'Работа'
when ood.VRD_DetType=3 then 'Запчасть'
when ood.VRD_DetType=4 then 'Др.услуга'
when ood.VRD_DetType=5 then 'Текст'
when ood.VRD_DetType=6 then 'Комментарий'
else '' end) as DetailType
, ood.VRD_ID_B_PayMethod as ManageCodeID
, (select Presentation from VRD_B_PayMethod where ID=ood.VRD_ID_B_PayMethod) as ManageCodeDescr
, (case when VRD_DetType=2 then VRD_Qty else 0 end) as QtyJob
, (case when VRD_DetType=3 then VRD_Qty else 0 end) as QtyPart
, (case when VRD_DetType=4 then VRD_Qty else 0 end) as QtyOther
, VRD_Amount
, (case when VRD_DetType = 4 and (ood.VRD_Code not like 'КиМ%' or (ood.VRD_Code is null and VRD_NetCostTotalLocal>0)) then VRD_NetCostTotalLocal else 0 end) as NatCostTotalWithoutKIM
, (case when VRD_DetType = 4 and ood.VRD_Code like 'КиМ%' then 0.8 * VRD_NetCostTotalLocal else 0 end) as NatCostTotalWithKIM
,
(select sum(VRD_AvgAmountLocal)/Sum(pm3.VRD_Qty)*ood.VRD_Qty from VRD_OutOrder oo3 inner join VRD_OutOrderDet ood3 on oo3.ID=ood3.VRD_ID_OutOrder inner join VRD_PartMovement pm3 on pm3.VRD_ID_OutOrderDet=ood3.ID where DocNum in
(select ii2.VRD_SupplierRefNum
from VRD_OutInvoice oi2 inner join VRD_OutOrderDet ood2 on ood2.VRD_ID_OutInvoice=oi2.ID inner join VRD_OutOrder oo2 on oi2.VRD_ID_OutOrder=oo2.ID inner join VRD_PartMovement pm2 on pm2.VRD_ID_OutOrderDet=ood2.ID inner join VRD_IncomeInvoice ii2 on ii2.ID=pm2.VRD_ID_OrigIncomeInvoice
where ood2.ID=ood.ID and VRD_DetType = 3 and (select Presentation from VRD_IncomeInvoice where ID=pm2.VRD_ID_OrigIncomeInvoice) like 'вн%')
and VRD_ID_B_SparePart in
(select pm2.VRD_ID_B_SparePart
from VRD_OutInvoice oi2 inner join VRD_OutOrderDet ood2 on ood2.VRD_ID_OutInvoice=oi2.ID inner join VRD_OutOrder oo2 on oi2.VRD_ID_OutOrder=oo2.ID inner join VRD_PartMovement pm2 on pm2.VRD_ID_OutOrderDet=ood2.ID inner join VRD_IncomeInvoice ii2 on ii2.ID=pm2.VRD_ID_OrigIncomeInvoice
where ood2.ID=ood.ID and VRD_DetType = 3 and (select Presentation from VRD_IncomeInvoice where ID=pm2.VRD_ID_OrigIncomeInvoice) like 'вн%')
) as NatCostFromPartMovement
,
(select sum(VRD_AvgAmountLocal)
from VRD_OutInvoice oi2 inner join VRD_OutOrderDet ood2 on ood2.VRD_ID_OutInvoice=oi2.ID inner join VRD_OutOrder oo2 on oi2.VRD_ID_OutOrder=oo2.ID inner join VRD_PartMovement pm2 on pm2.VRD_ID_OutOrderDet=ood2.ID
where ood2.ID=ood.ID and VRD_DetType = 3 and (select Presentation from VRD_IncomeInvoice where ID=pm2.VRD_ID_OrigIncomeInvoice) not like 'вн%') as NatCostFromPartMovementNot

from VRD_OutInvoice oi
inner join VRD_OutOrderDet ood on oi.ID=ood.VRD_ID_OutInvoice
inner join VRD_OutOrder oo on oi.VRD_ID_OutOrder=oo.ID
where oo.VRD_ID_B_Site in (select ID from VRD_B_Site where Flg_Deleted=0) and oo.VRD_Status=3 and ood.VRD_DetType in (2,3,4)  and ood.VRD_Title not like '%франшиз%' and oi.VRD_PayType!=2 and oo.DocNum not like 'вн%' and oo.VRD_ClientText not like '%Карс Фэмили%' and oo.VRD_ID_B_ProfitCenter in (1003) and oi.DocDate between @PerDate1 and cast(convert(char(8), @PerDate2, 112) + ' 23:59:59.99' as datetime)
) as T
where ISNULL(VRD_Amount,0) + ISNULL(NatCostTotalWithoutKIM,0) + ISNULL(NatCostTotalWithKIM,0)<>0

UNION ALL
select UnderTitle, FirmID, FirmName, SiteID, SiteName, Title, ID, CarModel, CarModelNum, InsuranceCompany_isNULL, NotEmployee, ClientCategoryID, ClientCategoryDescr, ClientID, InsuranceCompanyID, ClientDescr,
TypeID, Type, ManageCodeID, (case when ManageCodeDescr='Geely' then 'М2О' when ManageCodeDescr='Volvo' then 'Карс-Фэмили' else '' end) as ManageCodeDescr, Qty, JobQty, PartQty, OtherQty, JobNDSAmount, PartNDSAmount,
iif(CarModel='Geely', GeneralAmount*0.2, GeneralAmount) as GeneralAmount
, Amount1Auto3HangDiscount, Amount8AddDetail, NetCostNDs, Saldo, AmountWithoutNDs, NetCostWithoutNDs, Avizo, Revenue, Revenue2JobAnd4Other, Revenue3Part, NatCostWithoutKIM, NatCostWithKIM, NatCost, Income, MargaNDs, Marga
from (
select
'Finance' as UnderTitle, ic.DocNum, IPC.VRD_AmountLocal,VRD_InsuranceAmount,
VRD_ID_B_Firm as FirmID, (select Presentation from VRD_B_Firm where ID=VRD_ID_B_Firm) as FirmName, VRD_ID_B_Site as SiteID,
(select Presentation from VRD_B_Site where ID=VRD_ID_B_Site) as SiteName,
'Страхование' as Title, null as ID,
(select Descr from VRD_B_Make where ID=VRD_ID_B_Make) as CarModel, VRD_ID_B_Make as CarModelNum,
null as InsuranceCompany_isNULL, null as NotEmployee, null as ClientCategoryID, null as ClientCategoryDescr, null as ClientID, null as InsuranceCompanyID, null as ClientDescr,
--VRD_ID_B_InsuranceType as TypeID, (select Presentation from VRD_B_InsuranceType where ID=VRD_ID_B_InsuranceType) as Type, null as ManageCodeID,
null as TypeID, null as Type, null as ManageCodeID,
(select Presentation from VRD_B_Make where ID=(
select distinct VRD_ID_B_Make from VRD_B_SiteMake where Flg_Deleted=0 and VRD_ID_B_OORetailFirm=ISNULL((
select VRD_ID_B_Firm from VRD_CarSale where ID=(select distinct VRD_ID_CarSale from B_Car where VRD_VIN = ic.VRD_VIN))
, (select ID from VRD_B_Firm where Descr='Карс Фэмили')))) as ManageCodeDescr,
null as Qty, null as JobQty, null as PartQty, null as OtherQty, null as JobNDSAmount, null as PartNDSAmount,
IPC.VRD_AmountLocal*(VRD_CommissionPct+ISNULL(VRD_StdAddCommisionPct,0))/100 as GeneralAmount,
null as Amount1Auto3HangDiscount, null as Amount8AddDetail, null as NetCostNDs, null as Saldo, null as AmountWithoutNDs, null as NetCostWithoutNDs, null as Avizo, null as Revenue, null as Revenue2JobAnd4Other, null as Revenue3Part, null as NatCostWithoutKIM, null as NatCostWithKIM, null as NatCost, null as Income, null as MargaNDs, null as Marga,
(case when bic.Presentation != 'АО "АльфаСтрахование" Санкт-Петербургский филиал' then 1 else 0 end) as case02multiplication
from VRD_InsuranceContract ic inner join VRD_B_InsuranceCompany bic on ic.VRD_ID_B_InsuranceCompany=bic.ID  left join VRD_InsurancePayment IPC on IC.ID=IPC.VRD_ID_InsuranceContract
where VRD_Status in (2,3) and VRD_PaymentDate between @PerDate1 and cast(convert(char(8), @PerDate2, 112) + ' 23:59:59.99' as datetime)
) as T

UNION ALL

select UnderTitle, FirmID, FirmName, SiteID, SiteName, Title, ID, CarModel, CarModelNum, InsuranceCompany_isNULL, NotEmployee, ClientCategoryID, ClientCategoryDescr, ClientID, InsuranceCompanyID, ClientDescr,
TypeID, Type, ManageCodeID, (case when ManageCodeDescr='Geely' then 'М2О' when ManageCodeDescr='Volvo' then 'Карс-Фэмили' else '' end) as ManageCodeDescr, Qty, JobQty, PartQty, OtherQty, JobNDSAmount, PartNDSAmount,
iif(ManageCodeDescr='Geely', GeneralAmount*0.2, GeneralAmount) as GeneralAmount
, Amount1Auto3HangDiscount, Amount8AddDetail, NetCostNDs, Saldo, AmountWithoutNDs, NetCostWithoutNDs, Avizo, Revenue, Revenue2JobAnd4Other, Revenue3Part, NatCostWithoutKIM, NatCostWithKIM, NatCost, Income, MargaNDs, Marga
from (
select
'Finance' as UnderTitle,
VRD_ID_B_Firm as FirmID, (select Presentation from VRD_B_Firm where ID=VRD_ID_B_Firm) as FirmName, VRD_ID_B_Site as SiteID, (select Presentation from VRD_B_Site where ID=VRD_ID_B_Site) as SiteName,
(case when VRD_CreditContractType=1 then 'Кредит' when VRD_CreditContractType=2 then 'Лизинг' else '' end) as Title, null as ID,
(select Descr from VRD_B_Make where ID=VRD_ID_B_Make) as CarModel, VRD_ID_B_Make as CarModelNum,
null as InsuranceCompany_isNULL, null as NotEmployee, null as ClientCategoryID, null as ClientCategoryDescr, null as ClientID, null as InsuranceCompanyID, null as ClientDescr,
null as TypeID, null as Type, null as ManageCodeID,
(select Presentation from VRD_B_Make where ID=(
select distinct VRD_ID_B_Make from VRD_B_SiteMake where Flg_Deleted=0 and VRD_ID_B_OORetailFirm=ISNULL(
(select VRD_ID_B_Firm from VRD_CarSale where ID=VRD_ID_CarSale), (select ID from VRD_B_Firm where Descr='Карс Фэмили')
)
)) as ManageCodeDescr,
null as Qty, null as JobQty, null as PartQty, null as OtherQty, null as JobNDSAmount, null as PartNDSAmount,
VRD_CommAmount as GeneralAmount,
null as Amount1Auto3HangDiscount, null as Amount8AddDetail, null as NetCostNDs, null as Saldo, null as AmountWithoutNDs, null as NetCostWithoutNDs, null as Avizo, null as Revenue, null as Revenue2JobAnd4Other, null as Revenue3Part, null as NatCostWithoutKIM, null as NatCostWithKIM, null as NatCost, null as Income, null as MargaNDs, null as Marga
from VRD_CreditContract cc inner join VRD_CreditContractResult ccr on cc.ID=ccr.VRD_ID_CreditContract where  VRD_Status in (3,5) and VRD_DTContractSigned between @PerDate1 and cast(convert(char(8), @PerDate2, 112) + ' 23:59:59.99' as datetime)
) as T


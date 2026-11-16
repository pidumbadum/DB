select top 5 * from vendors;
select top 5 * from vendorgroup;
select top 5 * from conversionvendors;
select top 5 * from ordervendorinfo;
select top 5 * from bm_ManufactureOrders;

-- Ищем все колонки, содержащие "vendor" в названии, по всем таблицам базы
select 
    table_name as 'Таблица',
    column_name as 'Колонка',
    data_type as 'Тип данных',
    is_nullable as 'Nullable'
from information_schema.columns
where column_name like '%vendor%'
  and table_name in (
      -- Список уже проанализированных таблиц + таблица vendors
      'product',
      'pricelist',
      'bm_StorageOperations',
      'bm_StorageOperations_Table',
      'bm_JournalBarnetDocs',
      'journal',
      'bm_Journal_Details',
      'vendors',
      'vendorgroup',
      'clients'
  )
order by table_name, column_name;

-- Таблица               Колонка        Тип данных  Nullable  
-- --------------------  -------------  ----------  ----------
-- bm_StorageOperations  VendorID       bigint      YES       
-- journal               vendorid       varchar     YES       
-- pricelist             vendorid       bigint      YES       
-- product               vendorid       bigint      YES       
-- vendorgroup           vendorgroupid  int         NO        

-- при эьоом прямых ссфлок нет, но их могли просто не добавитть, подозреваю, что если я проверю связи, то найду пару новых, но большая часть окажет битой

select 
    'product → vendors' as связь,
    (select count(distinct vendorid) from product where vendorid is not null and vendorid > 0) as уникальных_vendorid,
    (select count(*) from vendors) as всего_в_vendors,
    (select count(*) from product p 
    left join vendors v on p.vendorid = v.id 
    where v.id is null and p.vendorid is not null and p.vendorid > 0) as висячих_ссылок;

select 
    'pricelist → vendors' as связь,
    (select count(distinct vendorid) from pricelist where vendorid is not null and vendorid > 0) as уникальных_vendorid,
    (select count(*) from vendors) as всего_в_vendors,
    (select count(*) from pricelist pl 
    left join vendors v on pl.vendorid = v.id 
    where v.id is null and pl.vendorid is not null and pl.vendorid > 0) as висячих_ссылок;

select 
    'bm_StorageOperations → vendors' as связь,
    (select count(distinct VendorID) from bm_StorageOperations where VendorID is not null and VendorID > 0) as уникальных_VendorID,
    (select count(*) from vendors) as всего_в_vendors,
    (select count(*) from bm_StorageOperations so 
    left join vendors v on so.VendorID = v.id 
    where v.id is null and so.VendorID is not null and so.VendorID > 0) as висячих_ссылок;

-- Посмотрим значения в journal.vendorid
select top 20
    vendorid,
    count(*) as количество_записей
from journal
where vendorid is not null and vendorid <> ''
group by vendorid
order by количество_записей desc;

-- как итог имеет смысл только связь с bm_StorageOperations
-- для провки выведу инфомацию о поставщиках из bm_StorageOperations
select 
    v.id as 'ID поставщика',
    v.firstname as 'Название',
    vg.description as 'Группа',
    count(*) as 'Всего операций',
    count(distinct so.ProductID) as 'Уникальных товаров',
    sum(so.Amount) as 'Общая сумма',
    sum(case when so.OperationID = 1 then so.Amount else 0 end) as 'Сумма поступлений',
    min(so.DateAdd) as 'Первая операция',
    max(so.DateAdd) as 'Последняя операция'
from bm_StorageOperations so
join vendors v on so.VendorID = v.id
left join vendorgroup vg on v.clientgroup = vg.vendorgroupid
where so.VendorID > 0
group by v.id, v.firstname, vg.description
order by 'Общая сумма' desc;
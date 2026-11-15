-- Структура таблицы bm_StorageOperations
select 
    column_name as 'имя колонки',
    data_type as 'тип данных',
    character_maximum_length as 'длина',
    is_nullable as 'можно null',
    column_default as 'значение по умолчанию'
from information_schema.columns
where table_name = 'bm_StorageOperations'
order by ordinal_position;

-- связи с таблицей bm_StorageOperations
-- сслается                 колонка     таблица назначения              колонка назначения
-- dbo.bm_StorageOperations	DocumentID	dbo.bm_JournalBarnetDocs	    ID
-- dbo.bm_StorageOperations	OperationID	dbo.bm_StorageOperationsType	ID
-- dbo.bm_StorageOperations	ProductID	dbo.product	                    id
-- dbo.bm_StorageOperations	StorageID	dbo.storages	                id
-- итого 4 связи, их нужно проверить 

-- СКРИПТЫ ПРВЕРКИ СВЯЗЕЙ
--------------------------------------------------
-- Проверяем связь bm_StorageOperations.ProductID -> product.ID
select 
    'Всего записей в bm_StorageOperations' as метрика,
    count(*) as значение
from bm_StorageOperations
union all
select 
    'Уникальных ProductID в bm_StorageOperations',
    count(distinct ProductID)
from bm_StorageOperations
union all
select 
    'Всего записей в product',
    count(*)
from product
union all
select 
    'ProductID из bm_StorageOperations, которых НЕТ в product',
    count(*)
from bm_StorageOperations so
left join product p on so.ProductID = p.ID
where p.ID is null;

-- Проверяем связь bm_StorageOperations.OperationID -> bm_StorageOperationsType.ID
select 
    'Уникальных OperationID в bm_StorageOperations' as метрика,
    count(distinct OperationID) as значение
from bm_StorageOperations

union all

select 
    'Всего записей в bm_StorageOperationsType',
    count(*)
from bm_StorageOperationsType

union all

select 
    'OperationID, которых НЕТ в bm_StorageOperationsType',
    count(*)
from bm_StorageOperations so
left join bm_StorageOperationsType sot on so.OperationID = sot.ID
where sot.ID is null;

-- Проверяем связь bm_StorageOperations.StorageID -> storages.ID
select 
    'Уникальных StorageID в bm_StorageOperations' as метрика,
    count(distinct StorageID) as значение
from bm_StorageOperations

union all

select 
    'Всего записей в storages',
    count(*)
from storages

union all

select 
    'StorageID, которых НЕТ в storages',
    count(*)
from bm_StorageOperations so
left join storages s on so.StorageID = s.ID
where s.ID is null;

-- Проверяем связь bm_StorageOperations.DocumentID -> bm_JournalBarnetDocs.ID
select 
    'Уникальных DocumentID в bm_StorageOperations' as метрика,
    count(distinct DocumentID) as значение
from bm_StorageOperations

union all

select 
    'Всего записей в bm_JournalBarnetDocs',
    count(*)
from bm_JournalBarnetDocs

union all

select 
    'DocumentID, которых НЕТ в bm_JournalBarnetDocs',
    count(*)
from bm_StorageOperations so
left join bm_JournalBarnetDocs jbd on so.DocumentID = jbd.ID
where jbd.ID is null;

-- исходя из результата единственной не оправдавшей себя связью является -- dbo.bm_StorageOperations	StorageID	dbo.storages
-- необходимо проанализировать остальные таблицы в целом, чтобы понимать контекст связи. 

-- связи с таблицей bm_JournalBarnetDocs 
-- dbo.bm_CashOperations	DocumentID	dbo.bm_JournalBarnetDocs	ID
-- dbo.bm_JournalBarnetDocs	CompanyID	dbo.bm_Companies	ID
-- dbo.bm_JournalBarnetDocs	JournalID	dbo.bm_JournalType	ID
-- dbo.bm_JournalBarnetDocs	DocumentTypeID	dbo.bm_JournalTypeDocuments	ID
-- dbo.bm_JournalBarnetDocs	ShiftID	dbo.bm_ShiftsOperations	ID
-- dbo.bm_JournalBarnetDocs_Actions	DocumentID	dbo.bm_JournalBarnetDocs	ID
-- dbo.bm_JournalBarnetDocs_Info	ParentID	dbo.bm_JournalBarnetDocs	ID
-- dbo.bm_ManufactureOrders	DocumentID	dbo.bm_JournalBarnetDocs	ID
-- dbo.bm_PaymentOperations	DocumentID	dbo.bm_JournalBarnetDocs	ID
-- dbo.bm_StorageOperations	DocumentID	dbo.bm_JournalBarnetDocs	ID
-- dbo.bm_StorageOperations_Table	DocumentID	dbo.bm_JournalBarnetDocs	ID
-- dbo.hotel_registr	DocumentID	dbo.bm_JournalBarnetDocs	ID
-- dbo.pricelist	DocumentID	dbo.bm_JournalBarnetDocs	ID
-- dbo.recipe	DocumentID	dbo.bm_JournalBarnetDocs	ID


-- ПРОВЕРКА ПОДЛИННОСТИ СВЯЗЕЙ С ТАБЛИЦЕЙ bm_JournalBarnetDocs
---------------------------------------------------------------------
-- Проверка всех связей bm_JournalBarnetDocs
-- Для каждой связи показываем: сколько уникальных ID в дочерней таблице, 
-- сколько из них есть в журнале, сколько "висячих"

-- 1. bm_Companies (CompanyID -> ID)
select 'bm_Companies' as таблица, 
       (select count(distinct CompanyID) from bm_JournalBarnetDocs where CompanyID is not null) as уникальных_в_журнале,
       (select count(*) from bm_Companies) as всего_в_справочнике,
       (select count(*) from bm_JournalBarnetDocs j left join bm_Companies c on j.CompanyID = c.ID where c.ID is null and j.CompanyID is not null) as висячих_ссылок

union all

-- 2. bm_JournalType (JournalID -> ID)
select 'bm_JournalType', 
       (select count(distinct JournalID) from bm_JournalBarnetDocs where JournalID is not null),
       (select count(*) from bm_JournalType),
       (select count(*) from bm_JournalBarnetDocs j left join bm_JournalType jt on j.JournalID = jt.ID where jt.ID is null and j.JournalID is not null)

union all

-- 3. bm_JournalTypeDocuments (DocumentTypeID -> ID)
select 'bm_JournalTypeDocuments', 
       (select count(distinct DocumentTypeID) from bm_JournalBarnetDocs where DocumentTypeID is not null),
       (select count(*) from bm_JournalTypeDocuments),
       (select count(*) from bm_JournalBarnetDocs j left join bm_JournalTypeDocuments jtd on j.DocumentTypeID = jtd.ID where jtd.ID is null and j.DocumentTypeID is not null)

union all

-- 4. bm_ShiftsOperations (ShiftID -> ID)
select 'bm_ShiftsOperations', 
       (select count(distinct ShiftID) from bm_JournalBarnetDocs where ShiftID is not null),
       (select count(*) from bm_ShiftsOperations),
       (select count(*) from bm_JournalBarnetDocs j left join bm_ShiftsOperations so on j.ShiftID = so.ID where so.ID is null and j.ShiftID is not null)

union all

-- 5. bm_CashOperations (DocumentID -> ID)
select 'bm_CashOperations', 
       (select count(distinct DocumentID) from bm_CashOperations where DocumentID is not null),
       (select count(*) from bm_JournalBarnetDocs),
       (select count(*) from bm_CashOperations co left join bm_JournalBarnetDocs j on co.DocumentID = j.ID where j.ID is null and co.DocumentID is not null)

union all

-- 6. bm_PaymentOperations (DocumentID -> ID)
select 'bm_PaymentOperations', 
       (select count(distinct DocumentID) from bm_PaymentOperations where DocumentID is not null),
       (select count(*) from bm_JournalBarnetDocs),
       (select count(*) from bm_PaymentOperations po left join bm_JournalBarnetDocs j on po.DocumentID = j.ID where j.ID is null and po.DocumentID is not null)

union all

-- 7. bm_StorageOperations_Table (DocumentID -> ID)
select 'bm_StorageOperations_Table', 
       (select count(distinct DocumentID) from bm_StorageOperations_Table where DocumentID is not null),
       (select count(*) from bm_JournalBarnetDocs),
       (select count(*) from bm_StorageOperations_Table sot left join bm_JournalBarnetDocs j on sot.DocumentID = j.ID where j.ID is null and sot.DocumentID is not null)

union all

-- 8. bm_JournalBarnetDocs_Actions (DocumentID -> ID)
select 'bm_JournalBarnetDocs_Actions', 
       (select count(distinct DocumentID) from bm_JournalBarnetDocs_Actions where DocumentID is not null),
       (select count(*) from bm_JournalBarnetDocs),
       (select count(*) from bm_JournalBarnetDocs_Actions a left join bm_JournalBarnetDocs j on a.DocumentID = j.ID where j.ID is null and a.DocumentID is not null)

union all

-- 9. bm_JournalBarnetDocs_Info (ParentID -> ID)
select 'bm_JournalBarnetDocs_Info', 
       (select count(distinct ParentID) from bm_JournalBarnetDocs_Info where ParentID is not null),
       (select count(*) from bm_JournalBarnetDocs),
       (select count(*) from bm_JournalBarnetDocs_Info i left join bm_JournalBarnetDocs j on i.ParentID = j.ID where j.ID is null and i.ParentID is not null)

union all

-- 10. bm_ManufactureOrders (DocumentID -> ID)
select 'bm_ManufactureOrders', 
       (select count(distinct DocumentID) from bm_ManufactureOrders where DocumentID is not null),
       (select count(*) from bm_JournalBarnetDocs),
       (select count(*) from bm_ManufactureOrders mo left join bm_JournalBarnetDocs j on mo.DocumentID = j.ID where j.ID is null and mo.DocumentID is not null)

union all

-- 11. hotel_registr (DocumentID -> ID)
select 'hotel_registr', 
       (select count(distinct DocumentID) from hotel_registr where DocumentID is not null),
       (select count(*) from bm_JournalBarnetDocs),
       (select count(*) from hotel_registr hr left join bm_JournalBarnetDocs j on hr.DocumentID = j.ID where j.ID is null and hr.DocumentID is not null)

union all

-- 12. pricelist (DocumentID -> ID)
select 'pricelist', 
       (select count(distinct DocumentID) from pricelist where DocumentID is not null),
       (select count(*) from bm_JournalBarnetDocs),
       (select count(*) from pricelist p left join bm_JournalBarnetDocs j on p.DocumentID = j.ID where j.ID is null and p.DocumentID is not null)

union all

-- 13. recipe (DocumentID -> ID)
select 'recipe', 
       (select count(distinct DocumentID) from recipe where DocumentID is not null),
       (select count(*) from bm_JournalBarnetDocs),
       (select count(*) from recipe r left join bm_JournalBarnetDocs j on r.DocumentID = j.ID where j.ID is null and r.DocumentID is not null);

-- Проверяем, есть ли данные в подозрительных таблицах
select 
    t.name as таблица,
    sum(p.rows) as количество_строк
from sys.tables t
join sys.partitions p on t.object_id = p.object_id
where t.is_ms_shipped = 0
  and p.index_id in (0, 1)
  and t.name in (
      'bm_CashOperations',
      'bm_PaymentOperations',
      'bm_JournalBarnetDocs_Actions',
      'bm_JournalBarnetDocs_Info',
      'bm_ManufactureOrders',
      'hotel_registr'
  )
group by t.name
order by t.name;
-- неа, нет
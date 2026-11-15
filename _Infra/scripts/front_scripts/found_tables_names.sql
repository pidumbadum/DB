-- 1. Закупки
select 
    table_name 'Таблтцы связанные с поставками'
from information_schema.tables 
where table_type = 'base table'
  and (table_name like '%purchase%' or table_name like '%buy%' 
       or table_name like '%order%' or table_name like '%supply%')
order by table_name;
-- из них не пустые только periodforordering orders и только orders имеет связи с дргуими таблиицами

select 
    t.name as table_name,
    sum(p.rows) as количество_строк
from sys.tables t
join sys.partitions p on t.object_id = p.object_id
where (
      t.name like '%sale%' or t.name like '%sell%' 
      or t.name like '%customer%' or t.name like '%client%'
  )
group by t.name
having sum(p.rows) > 0 -- оставляем только те, где сумма строк больше нуля
order by t.name;
-- clientgroup	16
-- clients	2988
-- webclients	4

-- 3. Поставщики
select 
    t.name as 'имя таблицы',
    sum(p.rows) 'количество строк'
from sys.tables t 
join sys.partitions p on t.object_id = p.object_id
where (t.name like '%supplier%' or t.name like '%vendor%' 
       or t.name like '%provider%')
group by t.name HAVING sum(p.rows) > 0
order by t.name; 
-- vendorgroup 2
-- vendors 63

-- 4. Персонал
select 
    t.name 'имя таблицы',
    sum(p.rows) 'сумма строк'
from sys.tables t 
join sys.partitions p on t.object_id = p.object_id
where (t.name like '%stock%' or t.name like '%inventory%' 
       or t.name like '%balance%' or t.name like '%warehouse%' 
       or t.name like '%store%' or t.name like '%remnant%')
group by t.name having sum(p.rows) > 0
order by t.name;
-- lngstock	1797
-- lngstockr	2121
-- reportslngstock	62
-- stockperiod	56

-- 5. Остатки
select 
    t.name 'имя таблицы',
    sum(p.rows) 'сумма строк'
from sys.tables t 
join sys.partitions p on t.object_id = p.object_id
where (t.name like '%stock%' or t.name like '%inventory%' 
       or t.name like '%balance%' or t.name like '%warehouse%' 
       or t.name like '%store%' or t.name like '%remnant%')
group by t.name having sum(p.rows) > 0
order by t.name;
-- lngstock	1797
-- lngstockr	2121
-- reportslngstock	62
-- stockperiod	56

select 
    t.name 'имя таблицы',
    sum(p.rows) 'сумма строк'
from sys.tables t 
join sys.partitions p on t.object_id = p.object_id
group by t.name having sum(p.rows) > 1
order by sum(p.rows) desc;

select 
    t.name 'имя таблицы'
from sys.tables t;

select 
    t.name 'имя таблицы',
    sum(p.rows) 'сумма строк'
from sys.tables t 
join sys.partitions p on t.object_id = p.object_id
group by t.name having sum(p.rows) = 1
order by t.name;


select 
    schema_name(tp.schema_id) + '.' + tp.name as parent_table,
    cp.name as parent_column,
    schema_name(tr.schema_id) + '.' + tr.name as referenced_table,
    cr.name as referenced_column
from sys.foreign_keys fk
join sys.tables tp on fk.parent_object_id = tp.object_id
join sys.tables tr on fk.referenced_object_id = tr.object_id
join sys.foreign_key_columns fkc on fk.object_id = fkc.constraint_object_id
join sys.columns cp on fkc.parent_column_id = cp.column_id and cp.object_id = tp.object_id
join sys.columns cr on fkc.referenced_column_id = cr.column_id and cr.object_id = tr.object_id
where tp.name = 'bm_JournalBarnetDocs' or tr.name = 'bm_JournalBarnetDocs'
order by parent_table, referenced_table;
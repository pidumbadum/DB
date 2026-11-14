-- 1. Закупки
select table_name 'Таблтцы связанные с поставками'
from information_schema.tables 
where table_type = 'base table'
  and (table_name like '%purchase%' or table_name like '%buy%' 
       or table_name like '%order%' or table_name like '%supply%')
order by table_name;
-- из них не пустые только periodforordering orders и только orders имеет связи с дргуими таблиицами

-- 2. Продажи
select table_name 'Таблтцы связанные с продажами' 
from information_schema.tables 
where table_type = 'base table'
  and (table_name like '%sale%' or table_name like '%sell%' 
       or table_name like '%customer%' or table_name like '%client%')
order by table_name;
-- clientgroup

-- 3. Поставщики
select table_name 'Таблтцы связанные с поставщиками'
from information_schema.tables 
where table_type = 'base table'
  and (table_name like '%supplier%' or table_name like '%vendor%' 
       or table_name like '%provider%')
order by table_name;

-- 4. Персонал
select table_name 'Таблтцы связанные с персоналом'
from information_schema.tables 
where table_type = 'base table'
  and (table_name like '%employee%' or table_name like '%staff%' 
       or table_name like '%worker%' or table_name like '%person%' 
       or table_name like '%hr%' or table_name like '%user%')
order by table_name;

-- 5. Остатки
select table_name 'Таблтцы связанные с остатками'
from information_schema.tables 
where table_type = 'base table'
  and (table_name like '%stock%' or table_name like '%inventory%' 
       or table_name like '%balance%' or table_name like '%warehouse%' 
       or table_name like '%store%' or table_name like '%remnant%')
order by table_name;

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
where tp.name = 'periodforordering' or tr.name = 'periodforordering'
order by parent_table, referenced_table;


-- Связи только для таблиц с данными (не пустых)
select 
    schema_name(tp.schema_id) + '.' + tp.name as parent_table,
    cp.name as parent_column,
    p_tp.rows as parent_rows,
    schema_name(tr.schema_id) + '.' + tr.name as referenced_table,
    cr.name as referenced_column,
    p_tr.rows as referenced_rows
from sys.foreign_keys fk
join sys.tables tp on fk.parent_object_id = tp.object_id
join sys.tables tr on fk.referenced_object_id = tr.object_id
join sys.foreign_key_columns fkc on fk.object_id = fkc.constraint_object_id
join sys.columns cp on fkc.parent_column_id = cp.column_id and cp.object_id = tp.object_id
join sys.columns cr on fkc.referenced_column_id = cr.column_id and cr.object_id = tr.object_id
-- Добавляем проверку количества строк через sys.partitions
join sys.partitions p_tp on tp.object_id = p_tp.object_id and p_tp.index_id in (0, 1)
join sys.partitions p_tr on tr.object_id = p_tr.object_id and p_tr.index_id in (0, 1)
where 
    p_tp.rows > 0   -- parent таблица не пустая
    and p_tr.rows > 0   -- referenced таблица не пустая
    and (
        (tp.name like '%purchase%' or tp.name like '%buy%' or tp.name like '%order%' or tp.name like '%supply%'
         or tp.name like '%sale%' or tp.name like '%sell%' or tp.name like '%customer%' or tp.name like '%client%'
         or tp.name like '%supplier%' or tp.name like '%vendor%' or tp.name like '%provider%'
         or tp.name like '%employee%' or tp.name like '%staff%' or tp.name like '%worker%' or tp.name like '%person%'
         or tp.name like '%stock%' or tp.name like '%inventory%' or tp.name like '%balance%' or tp.name like '%warehouse%')
        or
        (tr.name like '%purchase%' or tr.name like '%buy%' or tr.name like '%order%' or tr.name like '%supply%'
         or tr.name like '%sale%' or tr.name like '%sell%' or tr.name like '%customer%' or tr.name like '%client%'
         or tr.name like '%supplier%' or tr.name like '%vendor%' or tr.name like '%provider%'
         or tr.name like '%employee%' or tr.name like '%staff%' or tr.name like '%worker%' or tr.name like '%person%'
         or tr.name like '%stock%' or tr.name like '%inventory%' or tr.name like '%balance%' or tr.name like '%warehouse%')
    )
order by parent_table, referenced_table;
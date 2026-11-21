-- - SQL запросы для выборки ресурсов (MSSQL)
----------------------------------------------------

-- 1. единицы измерения
select 'insert into dim_ranges(external_id, name, factor ) values ('
    + cast(id as varchar(max)) + ','''
    + [sizeid] + ''','
    + cast(portionrate as varchar(max)) + ');' as sql
from [size];

--   2. категории  
select 'insert into dim_categories(external_id, name, parent_id) values ('
    + cast(id as varchar(max)) + ','''
    + replace(isnull(description,''), '''', '''''') + ''','
    + cast(isnull(parentid,0) as varchar(max)) + ');' as sql
from category;

--   3. группы поставщиков  
select 'insert into dim_vendor_groups(external_id, name) values ('
    + cast(vendorgroupid as varchar(max)) + ','''
    + replace(isnull(description,''), '''', '''''') + ''');' as sql
from vendorgroup;

--   4. поставщики  
select 'insert into dim_vendors(external_id, name, inn, kpp, ogrn, group_id) values ('
    + cast(id as varchar(max)) + ','''
    + replace(isnull(firstname,''), '''', '''''') + ''','''
    + replace(isnull(inn,''), '''', '''''') + ''','''
    + replace(isnull(kpp,''), '''', '''''') + ''','''
    + replace(isnull(ogrn,''), '''', '''''') + ''','
    + cast(isnull(clientgroup,0) as varchar(max)) + ');' as sql
from vendors;

--   5. номенклатура  
select 'insert into dim_products(external_id, name, vendor_id, category_id, subcategory_id, base_cost) values ('
    + cast(id as varchar(max)) + ','''
    + replace(isnull(description,''), '''', '''''') + ''','
    + cast(isnull(vendorid,0) as varchar(max)) + ','
    + cast(isnull(categoryid,0) as varchar(max)) + ','
    + cast(isnull(subcategoryid,0) as varchar(max)) + ','
    + cast(isnull(cost,0) as varchar(max)) + ');' as sql
from product;

--   6. актуальные цены (последняя запись по dateeff для каждой пары товар+группа)  
with last_prices as (
    select id, productid, groupid, basecost,
        row_number() over(partition by productid, groupid order by dateeff desc) as rn
    from pricelist
    where basecost > 0
)
select 'insert into dim_prices(external_id, product_id, price_group_id, price) values ('
    + cast(id as varchar(max)) + ','
    + cast(productid as varchar(max)) + ','
    + cast(groupid as varchar(max)) + ','
    + cast(basecost as varchar(max)) + ');' as sql
from last_prices
where rn = 1;

--   7. типы операций хранения  
select 'insert into dim_operation_types(external_id, name, factor) values ('
    + cast(id as varchar(max)) + ','''
    + replace(isnull(description,''), '''', '''''') + ''','
    + cast(isnull(factor,0) as varchar(max)) + ');' as sql
from bm_storageoperationstype;

--   8. типы транзакций  
select 'insert into dim_transaction_types(external_id, group_id, preview_group_type, name) values ('
    + cast(transtypeid as varchar(max)) + ','
    + cast(isnull(transgroupid,0) as varchar(max)) + ','''
    + replace(isnull(previewgrouptype,''), '''', '''''') + ''','''
    + replace(isnull(description,''), '''', '''''') + ''');' as sql
from transtype;

--   9. группы цен  
select 'insert into dim_price_groups(external_id, name, date_start) values ('
    + cast(pricegroupid as varchar(max)) + ','''
    + replace(isnull(description,''), '''', '''''') + ''','
    + case when datestart is null then 'null'
           else '''' + convert(varchar(19), datestart, 120) + '''' end + ');' as sql
from pricegroup;

--   10. типы документов  
select 'insert into dim_document_types(external_id, name) values ('
    + cast(id as varchar(max)) + ','''
    + replace(isnull(description,''), '''', '''''') + ''');' as sql
from bm_JournalTypeDocuments;

--   11. типы журналов  
select 'insert into dim_journal_types(external_id, name) values ('
    + cast(id as varchar(max)) + ','''
    + replace(isnull(journalname,''), '''', '''''') + ''');' as sql
from bm_journaltype;

--   12. персонал  
select 'insert into dim_personnel(external_id, last_name, first_name, middle_name, full_name, security_access, flag_pos, flag_reports) values ('
    + cast(personid as varchar(max)) + ','''
    + replace(isnull(lastname,''), '''', '''''') + ''','''
    + replace(isnull(firstname,''), '''', '''''') + ''','''
    + replace(isnull(middlename,''), '''', '''''') + ''','''
    + replace(isnull(lastname + ' ' + isnull(firstname,'') + ' ' + isnull(middlename,''), ''), '''', '''''') + ''','
    + cast(isnull(securityaccess,0) as varchar(max)) + ','
    + cast(isnull(flagpos,0) as varchar(max)) + ','
    + cast(isnull(flagreports,0) as varchar(max)) + ');' as sql
from personnel;

--   13. склады  
select 'insert into dim_storages(external_id, name) values ('
    + cast(id as varchar(max)) + ','''
    + replace(isnull(description,''), '''', '''''') + ''');' as sql
from storages;

--   14. рецептуры  
select 'insert into dim_recipes(external_id, recipe_product_id, ingredient_product_id, size_id, portion, cooking_loss) values ('
    + cast(id as varchar(max)) + ','
    + cast(recipeid as varchar(max)) + ','
    + cast(ingredientid as varchar(max)) + ','
    + cast(isnull(sizeid,0) as varchar(max)) + ','
    + cast(isnull(portion,0) as varchar(max)) + ','
    + cast(isnull(cookingloss,0) as varchar(max)) + ');' as sql
from recipe;
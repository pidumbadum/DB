select top 1 * from bm_StorageOperations where OperationID = 1;
select top 15 * from bm_StorageOperations where Quantity > 0;
select count(*) from bm_StorageOperations where count > 0 and OperationID = 1 and VendorID > 0;

--инетерса ради 
select top 10
    sto.ID as 'ID операции',
    stot.Description as 'Описание складской опрации',
    jbd.ID  as 'Айди из журнала',
    jt.JournalName as 'Навзание журнала',
    jtd.[Description] as 'Оипсание типа документа из журнаал'
from bm_StorageOperations sto
left join bm_StorageOperationsType stot on sto.OperationID = stot.ID
LEFT JOIN bm_JournalBarnetDocs jbd on sto.DocumentID = jbd.ID 
LEFT JOIN bm_JournalType jt on jbd.JournalID = jt.ID
LEFT JOIN bm_JournalTypeDocuments jtd on jbd.DocumentTypeID = jtd.ID 
;

-- генератор фактов закупок
select 
    'insert into fact_purchases(product_id, range_id, category_id, vendor_id, quantity, amount, insert_date) values ('
    + cast(so.ProductID as varchar(max)) + ','
    + cast(isnull(so.RangeID, 0) as varchar(max)) + ','
    + cast(isnull(p.CategoryID, 0) as varchar(max)) + ','
    + cast(isnull(so.VendorID, 0) as varchar(max)) + ','
    + cast(isnull(so.count, 0) as varchar(max)) + ','
    + cast(isnull(so.Amount, 0) as varchar(max)) + ','
    + '''' + convert(varchar(19), so.DateAdd, 120) + ''''
    + ');' as sql
from bm_StorageOperations so
left join product p on so.ProductID = p.id
where so.OperationID = 1 and so.VendorID > 0;
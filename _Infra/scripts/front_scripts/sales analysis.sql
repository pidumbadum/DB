-- В этом сриктпе будет исследоваться таблица journal detail, по предположением являющаяся журналом продаж

-- Проверка всех связей bm_Journal_Details

-- 1. Связь SourceID -> journal.transnumber
select 
    'journal (по transnumber)' as таблица,
    (select count(distinct SourceID) from bm_Journal_Details where SourceID is not null) as уникальных_в_jurnal_detail,
    (select count(distinct transnumber) from journal where transnumber is not null) as уникальных_в_связанной_таблице,
    (select count(*) from bm_Journal_Details jd left join journal j on jd.SourceID = j.transnumber where j.transnumber is null and jd.SourceID is not null) as висячих_ссылок

union all

-- 2. Связь ProductID -> product.id
select 
    'product (ProductID)',
    (select count(distinct ProductID) from bm_Journal_Details where ProductID is not null),
    (select count(*) from product),
    (select count(*) from bm_Journal_Details jd left join product p on jd.ProductID = p.id where p.id is null and jd.ProductID is not null)

union all

-- 3. Связь BludoID -> product.id
select 
    'product (BludoID)',
    (select count(distinct BludoID) from bm_Journal_Details where BludoID is not null),
    (select count(*) from product),
    (select count(*) from bm_Journal_Details jd left join product p on jd.BludoID = p.id where p.id is null and jd.BludoID is not null)

union all

-- 4. Связь RangeID -> size.ID
select 
    'size',
    (select count(distinct RangeID) from bm_Journal_Details where RangeID is not null),
    (select count(*) from size),
    (select count(*) from bm_Journal_Details jd left join size s on jd.RangeID = s.ID where s.ID is null and jd.RangeID is not null);

-- все связи действительные 

-- непонятно, что является продажами - journal ли jornal_details по названию второе должно быть дополнением первого, но почему 
-- jornal_details объемнее и имеет больше связей? 

-- проверка совпадающих значений в jornal_details и journal
select jd.ID from bm_Journal_Details jd
join journal j on j.id = jd.id;

-- jornal_details ссылается на journal по номеру транзакции и они оба имеют данные о чеке, 
-- значит journal - основная таблица, и она содержит как чек в целом так и все транзакции содержащиеся в нем 
-- в дальнейшем для аннализа продаж необходимо использовать именно journal

-- Сколько строк приходится на один чек в среднем
select 
    count(*) as всего_строк_в_journal,
    count(distinct transnumber) as уникальных_transnumber,
    count(distinct receiptn) as уникальных_чеков,
    cast(count(*) as float) / nullif(count(distinct receiptn), 0) as среднее_позиций_на_чек
from journal
where receiptn <> 0; -- 0 помечаются внутренние транзакции судя по всему 

-- Проверка связи journal.transtype -> transtype.transtypeid
select 
    'transtype' as связь,
    (select count(distinct transtype) from journal where transtype is not null) as уникальных_в_journal,
    (select count(*) from transtype) as всего_в_справочнике,
    (select count(*) from journal j left join transtype t on j.transtype = t.transtypeid where t.transtypeid is null and j.transtype is not null) as висячих_ссылок;
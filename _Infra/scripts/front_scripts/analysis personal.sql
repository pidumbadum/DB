
select top 5 * from bm_PersonnelSecurity;
select top 5 * from bm_SecurityObjects;
select count(*) from bm_PersonnelSecurity;
select count(*) from bm_SecurityObjects;

select top 5 * from personnel;
select top 5 * from personnelmessages;
select top 5 * from vw_Personnel;
select top 5 * from vw_PersonnelJobInfo;
select top 5 * from bm_BonusHistory;

select 
    p.personid 'айди сотрудника',
    lastname + firstname as 'Фамилия имя',
    SecurityName as 'должность'
from vw_Personnel p
join vw_PersonnelJobInfo pji on p.personid = pji.personid;

select 
    SecurityName
from vw_Personnel p
join vw_PersonnelJobInfo pji on p.personid = pji.personid
where SecurityName != 'Сотрудник';


-- Ищем колонки персонала в уже известных нам ключевых таблицах
select 
    table_name as 'Таблица',
    column_name as 'Колонка',
    data_type as 'Тип данных'
from information_schema.columns
where table_name in (
    'journal', 
    'bm_StorageOperations', 
    'bm_JournalBarnetDocs', 
    'bm_Journal_Details', 
    'product', 
    'pricelist'
)
and (
    column_name like '%person%' 
    or column_name like '%login%'
    -- or column_name like '%id%'
    or column_name like '%personal%'
    or column_name like '%user%' 
    or column_name like '%staff%' 
    or column_name like '%employee%'
)
order by table_name, column_name;

-- проверка возможных связей 
-- 1. Связь bm_JournalBarnetDocs.PersonID -> personnel.personid
select 
    'bm_JournalBarnetDocs → personnel (по PersonID)' as связь,
    (select count(distinct PersonID) from bm_JournalBarnetDocs where PersonID is not null and PersonID > 0) as уникальных_ID,
    (select count(*) from personnel) as всего_сотрудников,
    (select count(*) from bm_JournalBarnetDocs jbd left join personnel p on jbd.PersonID = p.personid where p.personid is null and jbd.PersonID is not null and jbd.PersonID > 0) as висячих_ссылок

union all

-- 2. Связь journal.loginbar -> personnel.personid
select 
    'journal → personnel (по loginbar)',
    (select count(distinct loginbar) from journal where loginbar is not null and loginbar <> ''),
    (select count(distinct personid) from personnel where personid is not null and personid <> ''),
    (select count(*) from journal j left join personnel p on j.loginbar = p.personid where p.personid is null and j.loginbar is not null and j.loginbar <> '')

union all

-- 3. Связь journal.loginid -> personnel.personid
select 
    'journal → personnel (по loginid)',
    (select count(distinct loginid) from journal where loginid is not null and loginid <> ''),
    (select count(distinct personid) from personnel where personid is not null and personid <> ''),
    (select count(*) from journal j left join personnel p on j.loginid = p.personid where p.personid is null and j.loginid is not null and j.loginid <> '');

-- Проверка связи bm_BonusHistory.PersonID -> personnel.personid
select 
    'bm_BonusHistory -> personnel (по PersonID)' as связь,
    (select count(distinct PersonID) from bm_BonusHistory where PersonID is not null and PersonID > 0) as уникальных_PersonID,
    (select count(*) from personnel) as всего_сотрудников,
    (select count(*) from bm_BonusHistory bh left join personnel p on bh.PersonID = p.personid where p.personid is null and bh.PersonID is not null and bh.PersonID > 0) as висячих_ссылок;

-- парочка запроса для понимания контекста 
select top 15
    p.firstname + ' ' + p.lastname as 'Сотрудник',
    p.securityaccess as 'ID уровня доступа',
    count(distinct j.receiptn) as 'Количество чеков',
    sum(j.amount) as 'Сумма продаж'
from journal j
join personnel p on j.loginid = p.personid
where j.receiptn <> 0
  and j.transtype in (101, 301)
group by p.firstname, p.lastname, p.securityaccess
order by 'Сумма продаж' desc;

select top 15
    p.firstname + ' ' + p.lastname as 'Сотрудник',
    p.securityaccess as 'ID уровня доступа',
    jtd.description as 'Тип документа',
    count(*) as 'Количество документов'
from bm_JournalBarnetDocs jbd
join personnel p on jbd.PersonID = p.personid
left join bm_JournalTypeDocuments jtd on jbd.DocumentTypeID = jtd.ID
where jbd.PersonID > 0
group by p.firstname, p.lastname, p.securityaccess, jtd.description
order by 'Количество документов' desc;

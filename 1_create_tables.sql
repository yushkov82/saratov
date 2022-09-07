create table whs.saratov_article
(id   integer
,name varchar2(1024 char)
,id_group integer);
/
create table whs.saratov_article_calc
(id   integer
,name varchar2(1024 char)
,id_group integer
,note varchar2(4000 char));
/
create table whs.saratov_article_lnk
(id        integer
,name      varchar2(8 char)
,rwn       integer
,r_count   integer
,str_count integer
,rwn_name  integer
);
/
create unique index saratov_article_calc_id_uidx on whs.saratov_article_calc(id);
create unique index saratov_article_id_uidx on whs.saratov_article(id);

create index saratov_article_lnk_id_uidx on whs.saratov_article_lnk(id, name, rwn_name);
create index saratov_article_lnk_name_uidx on whs.saratov_article_lnk(name, id);

create or replace view whs.saratov_article_vw
 as
 select a.id, a.name, a.id_group
   from  whs.saratov_article a
  union all
 select a.id, a.name, a.id_group
   from  whs.saratov_article_calc a;

declare
  i       integer;
  l_str   whs.saratov_article_calc.name%type;
  l_len   integer;
begin
  execute immediate 'truncate table whs.saratov_article_lnk';
  for cc in (
    select a1.id
         , Regexp_Replace(Regexp_Replace(translate(upper(name), 'ETYOPAHKXCBM', 'ЕТУОРАНКХСВМ'), '\W', ' '), '\d', ' ')||' ' name
      from whs.saratov_article_vw a1
     --where rownum < 20
             )
  loop
    for c1 in (
      select name
           , rownum lvl
           , sum(length(name) - 1) over (partition by 1 order by 1) r_count
        from (  
            SELECT regexp_substr(cc.name, '[^ ]+', 1, level) name
              from dual
            CONNECT BY instr(cc.name, ' ', 1, level - 1) > 0
             )
        where name is not null and length(name) > 2 and instr(name, ' ') = 0      
               )
    loop
      l_len := length(c1.name) - 1;
      insert into whs.saratov_article_lnk (id, name, rwn, r_count, str_count, rwn_name)
      select cc.id
           , name
           , row_number() over (partition by name order by name) rwn
           , c1.r_count
           , count(1) over (partition by 1 order by 1) r_count
           , c1.lvl
        from (
      select substr(c1.name, level, 3) name
        from dual
       connect by level < l_len);     
    end loop;            
    commit;
  end loop;  

  --delete from whs.saratov_article_lnk where name is null;  
  commit;                 
end;
/

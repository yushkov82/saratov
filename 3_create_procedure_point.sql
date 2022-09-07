create or replace procedure p_point4 (p_id in integer)
  is
  l_percent number:=10; 
  l_exists  integer;
  l_count   integer;
begin
  l_exists := 0;
  l_count := 0;

  for cc in (
    with tab_1 as(
        --находим товары с совпадением и указываем все/% совпадения
        select /*+MATERIALIZE parallel(16)*/
               l1.id
             , sum(1/(l1.r_count + l0.r_count)) r_point
         from whs.saratov_article_lnk l0
            , whs.saratov_article_lnk l1
         where l0.id = p_id
           and l0.name = l1.name
           and l0.rwn = l1.rwn
          group by l1.id
            --order by r_point desc
            --fetch first 30 rows only
                )
      , tab_2 as (
       --берем только записи где совпадения больше 20%
        select /*+parallel(16)*/t2.id
             , t1.r_point
             , t2.id_group
             , dense_rank() over (order by t1.r_point desc) rwn
             , t2.name
          from tab_1 t1
             , whs.saratov_article_vw  t2  
         where t1.id = t2.id
           and t2.id_group is not null    
           --and t1.r_point >= 0.1
                 )
      , tab_3 as (
        --берем тоько два самых больших совпадения
          select /*+parallel(16)*/
                 r_point
               , id_group
               , count(1) r_count
            from tab_2 
           where rwn = 1 
           group by r_point, id_group 
           order by r_point desc, r_count desc
           fetch first 2 rows only
                 )
      select r_point, id_group, r_count
        from tab_3
             )
  loop
    
    if    l_exists = 0 then
      update whs.saratov_article_calc
         set id_group = cc.id_group
       where id = p_id;
    elsif l_exists = 1 and l_count*(1-l_percent)/100 <= cc.r_count then
      update whs.saratov_article_calc
         set note = 'count_1 = '||l_count||'; count_2 = '||cc.r_count||';'
       where id = p_id;      
    end if;
    
    l_exists := 1;
    l_count := cc.r_count;     
    exit;         
  end loop;                 
  
  if l_exists = 0 then
    update whs.saratov_article_calc
       set note = 'не найдено'
         , id_group = nvl2(name, 10, null)
     where id = p_id;          
  end if;  
  commit;
end;       
/

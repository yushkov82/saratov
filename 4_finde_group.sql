BEGIN
  for cc in (
      select id, name
        from whs.saratov_article_calc t1
       where t1.id_group is null
            )
  loop              
    whs.p_point4(cc.id);
  end loop;
END;
/

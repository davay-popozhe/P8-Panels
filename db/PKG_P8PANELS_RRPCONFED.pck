create or replace package PKG_P8PANELS_RRPCONFED as

  /* Получение разделов регламентированного отчёта */
  procedure RRPCONF_GET_SECTIONS
  (
    NRN_RRPCONF             in number,  -- Ид. нстройки форм регламентированного отчёта
    COUT                    out clob    -- Список разделов
  );

  /* Добавление раздела регламентированного отчёта */
  procedure RRPCONFSCTN_INSERT
  (
    NPRN                    in number,   -- Ид. настройки форм регламентированного отчёта
    SCODE                   in varchar2, -- Мнемокод
    SNAME                   in varchar2, -- Наименование
    NRN                     out number   -- Ид. созданной записи
  );
  
  /* Исправление раздела регламентированного отчёта */
  procedure RRPCONFSCTN_UPDATE
  (
    NRN                     in number,   -- Ид. раздела
    SCODE                   in varchar2, -- Мнемокод раздела
    SNAME                   in varchar2  -- Наименование раздела
  );
  
  /* Удаление раздела регламентированного отчёта */
  procedure RRPCONFSCTN_DELETE
  (
    NRN                     in number   -- Ид. раздела
  );
  
  /* Получение кодов настройки, раздела и показателя раздела по ид. показателя раздела */
  procedure RRPCONFSCTNMRK_GET_CODES
  (
    NRN                     in number,    -- Ид. показателя раздела
    SRRPCONF                out varchar2, -- Код настройки формы регламентированного отчёта
    SRRPCONFSCTN            out varchar2, -- Код раздела
    SRRPCONFSCTNMRK         out varchar2  -- Код показателя раздела
  );
  
  /* Добавление показателя раздела регламентированного отчёта */
  procedure RRPCONFSCTNMRK_INSERT
  (
    NPRN                    in number,   -- Ид. раздела
    SCODE                   in varchar2, -- Мнемокод показателя раздела
    SNAME                   in varchar2, -- Наименование показателя раздела
    SCOLCODE                in varchar2, -- Мнемокод графы
    SCOLVER                 in varchar2, -- Мнемокод редакции графы
    SROWCODE                in varchar2, -- Мнемокод строки
    SROWVER                 in varchar2, -- Мнемокод редакции строки
    NRN                     out number   -- Ид. созданной записи
  );
  
  /* Исправление показателя раздела регламентированного отчёта */
  procedure RRPCONFSCTNMRK_UPDATE
  (
    NRN                     in number,  -- Ид. показателя раздела            
    SNAME                   in varchar2 -- Новое наименование
  );
  
  /* Удаление показателя раздела регламентированного отчёта */
  procedure RRPCONFSCTNMRK_DELETE
  (        
    NRN                     in number   -- Ид. показателя раздела
  );
  
  /* Формирование кода и наименования показателя раздела регламентированного отчёта */
  procedure RRPCONFSCTNMRK_GET_CODE_NAME
  ( 
    SSCTNCODE               in varchar2,  -- Мнемокод раздела  
    SROWCODE                in varchar2,  -- Мнемокод строки
    NROWVER                 in number,    -- Ид. редакции строки
    SCOLUMNCODE             in varchar2,  -- Мнемокод графы
    NCOLUMNVER              in number,    -- Ид. редакции графы
    SCODE                   out varchar2, -- Мнемокод показателя раздела
    SNAME                   out varchar2  -- Наименование показателя раздела    
  );

end PKG_P8PANELS_RRPCONFED;
/
create or replace package body PKG_P8PANELS_RRPCONFED as

  /* Получение разделов регламентированного отчёта */
  procedure RRPCONF_GET_SECTIONS
  (
    NRN_RRPCONF             in number,                      -- Ид. нстройки форм регламентированного отчёта
    COUT                    out clob                        -- Список разделов
  )
  is
    NVERSION                PKG_STD.TREF;                   -- Рег. номер версии словаря контрагентов    
    RDG                     PKG_P8PANELS_VISUAL.TDATA_GRID; -- Описание таблицы
    RDG_ROW                 PKG_P8PANELS_VISUAL.TROW;       -- Строка таблицы
    CDG                     clob;                           -- XML данных раздела
    CCURCLOB                clob;                           -- XML текущего раздела
    NCURRN                  PKG_STD.TREF;                   -- Ид. текущего раздела
    SCURCODE                PKG_STD.TSTRING;                -- Мнемокод текущего раздела
    SCURNAME                PKG_STD.TSTRING;                -- Наименование текущего раздела
    SCUR_ROW                PKG_STD.TSTRING := 'default';   -- Текущая строка таблицы
    CXML                    PKG_CONTVALLOC2NS.TCONTAINER;   -- Контейнер для данных XML
    
    /* Курсор с отбором показателей раздела по ид. раздела */
    cursor C1 (NSCTN_RN in number) is
      select T.RN NRN, 
             T.PRN NPRN, 
             T.RRPCONF NRRPCONF, 
             T.RRPPRM NRRPPRM, 
             T.CODE SCODE, 
             T.NAME SNAME, 
             R.CODE SROW_CODE, 
             R.NAME SROW_NAME,
             C.CODE SCOLUMN_CODE,
             C.NAME SCOLUMN_NAME
        from RRPCONFSCTNMRK T,
             RRPROW         R,
             RRPCOLUMN      C
       where T.PRN in (select T2.RN 
                         from RRPCONFSCTN T2 
                        where T2.PRN = NRN_RRPCONF
                          and T2.VERSION = NVERSION)
         and T.VERSION = NVERSION
         and T.RRPROW = R.RN (+)
         and T.RRPCOLUMN = C.RN (+)
         and T.PRN = NSCTN_RN
       order by T.CODE;
    
    /* Курсор с отбором граф раздела по ид. раздела */     
    cursor CN (NSCTN_RN in number) is
      select distinct(C.CODE) SCOLUMN_CODE, 
             C.NAME SCOLUMN_NAME
        from RRPCONFSCTNMRK T,
             RRPCOLUMN      C
       where T.PRN in (select T2.RN 
                         from RRPCONFSCTN T2 
                        where T2.PRN = NRN_RRPCONF
                          and T2.VERSION = NVERSION)
         and T.VERSION = NVERSION
         and T.RRPCOLUMN = C.RN (+)
         and T.PRN = NSCTN_RN
       order by SCOLUMN_CODE;
  begin
    /* Очистка контейнера */
    PKG_CONTVALLOC2NS.PURGE(RCONTAINER => CXML);
    /* Определение версии раздела */
    NVERSION := GET_SESSION_VERSION(SUNITCODE => 'RRPConfig');
    /* Цикл по разделам настройки форм регламентированного отчёта */
    for C in (select T.RN      NRN,
                     T.VERSION NVERSION,
                     T.CRN     NCRN,
                     T.PRN     NPRN,
                     T.CODE    SCODE,
                     T.NAME    SNAME
                from RRPCONFSCTN T
               where T.PRN = NRN_RRPCONF
                 and T.VERSION = NVERSION)
    loop
      /* Инициализируем таблицу данных */
      RDG := PKG_P8PANELS_VISUAL.TDATA_GRID_MAKE(BFIXED_HEADER => true, NFIXED_COLUMNS => 1);
      /* Формируем структуру заголовка */
      PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                                 SNAME      => 'SROW_NAME',
                                                 SCAPTION   => 'Наименование строки',
                                                 SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                                 NWIDTH     => 150);
      /* Цикл формирования колонок с графами */
      for CL in CN(C.NRN)
      loop
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                                   SNAME      => 'SCOL_' || CL.SCOLUMN_CODE,
                                                   SCAPTION   => CL.SCOLUMN_NAME,
                                                   SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR);
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                                   SNAME      => 'NRN_' || CL.SCOLUMN_CODE,
                                                   SCAPTION   => CL.SCOLUMN_NAME || ' Идентификаторы',
                                                   SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                                   BVISIBLE   => false);
      end loop;
      /* Для нового раздела очищаем переменную кода строки */
      SCUR_ROW := 'default';
      /* Инициализируем строку */
      RDG_ROW := PKG_P8PANELS_VISUAL.TROW_MAKE();
      /* Цикл заполнения строк данными о показателях раздела */
      for CR in C1(C.NRN)
      loop
        /* Если новая строка */
        if (SCUR_ROW != CR.SROW_CODE) then
          /* Если строка не первая */
          if (SCUR_ROW != 'default') then
            /* Добавим строку для раздела */
            PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW);
            /* Инициализируем новую строку */
            RDG_ROW := PKG_P8PANELS_VISUAL.TROW_MAKE();
          end if;
          /* Запоминаем мнемокод новой строки */
          SCUR_ROW := CR.SROW_CODE;
          /* Заполняем наименование строки */
          PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'SROW_NAME', SVALUE => CR.SROW_NAME);
        end if;
        /* Заполняем наименование показателя раздела */
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'SCOL_' || CR.SCOLUMN_CODE, SVALUE => CR.SNAME);
        /* Заполняем ид. показателя раздела */
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NRN_' || CR.SCOLUMN_CODE, NVALUE => CR.NRN);
      end loop;
      /* Добавим последнюю строку для раздела */
      PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW);
      /* Сериализуем описание */
      CDG := PKG_P8PANELS_VISUAL.TDATA_GRID_TO_XML(RDATA_GRID => RDG, NINCLUDE_DEF => 1);
      /* Заполняем контейнер данными о разделе */
      PKG_CONTVALLOC2NS.PUTS(RCONTAINER => CXML, NTABID => C.NRN, SROWID => C.NRN || '_CODE', SVALUE => C.SCODE);
      PKG_CONTVALLOC2NS.PUTS(RCONTAINER => CXML, NTABID => C.NRN, SROWID => C.NRN || '_NAME', SVALUE => C.SNAME);
      PKG_CONTVALLOC2NS.PUTLC(RCONTAINER => CXML, NTABID => C.NRN, SROWID => C.NRN || '_CLOB', LCVALUE => CDG);
    end loop;
    /* Формируем XML с данными */
    PKG_XFAST.PROLOGUE(ITYPE => PKG_XFAST.CONTENT_);
    PKG_XFAST.DOWN_NODE(SNAME => 'DATA');
    /* Цикл по контейнеру с данными о разделах */
    for X in 1 .. PKG_CONTVALLOC2NS.COUNT_(RCONTAINER => CXML)
    loop
      /* Ид. раздела */
      if (X = 1) then
        NCURRN := PKG_CONTVALLOC2NS.FIRST_(RCONTAINER => CXML);
      else
        NCURRN := PKG_CONTVALLOC2NS.NEXT_(RCONTAINER => CXML, NTABID => NCURRN);
      end if;
      /* Мнемокод раздела */
      SCURCODE := PKG_CONTVALLOC2NS.GETS(RCONTAINER => CXML, NTABID => NCURRN, SROWID => NCURRN || '_CODE');
      /* Наименование раздела */
      SCURNAME := PKG_CONTVALLOC2NS.GETS(RCONTAINER => CXML, NTABID => NCURRN, SROWID => NCURRN || '_NAME');
      /* Clob с показателями раздела */
      CCURCLOB := PKG_CONTVALLOC2NS.GETLC(RCONTAINER => CXML, NTABID => NCURRN, SROWID => NCURRN || '_CLOB');
      /* Формирование элемента XML с данными о разделе */
      PKG_XFAST.DOWN_NODE(SNAME => 'SECTIONS');
      PKG_XFAST.ATTR(SNAME => 'NRN', NVALUE => NCURRN);
      PKG_XFAST.ATTR(SNAME => 'SCODE', SVALUE => SCURCODE);
      PKG_XFAST.ATTR(SNAME => 'SNAME', SVALUE => SCURNAME);
      PKG_XFAST.VALUE_XML(LCVALUE => CCURCLOB);
      PKG_XFAST.UP();
    end loop;
    PKG_XFAST.UP();
    /* Сериализуем описание */
    COUT := PKG_XFAST.SERIALIZE_TO_CLOB();
    PKG_XFAST.EPILOGUE();
    /* Очистка контейнера */
    PKG_CONTVALLOC2NS.PURGE(RCONTAINER => CXML);
  end RRPCONF_GET_SECTIONS;

  /* Добавление раздела регламентированного отчёта */
  procedure RRPCONFSCTN_INSERT
  (
    NPRN                    in number,                             -- Ид. настройки форм регламентированного отчёта
    SCODE                   in varchar2,                           -- Мнемокод
    SNAME                   in varchar2,                           -- Наименование
    NRN                     out number                             -- Ид. созданной записи
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Рег. номер организации
  begin
    P_RRPCONFSCTN_INSERT(NCOMPANY            => NCOMPANY,
                         NPRN                => NPRN,
                         SCODE               => SCODE,
                         SNAME               => SNAME,
                         SRRPCONFSCTN        => null,
                         SRRPPRMGRP          => null,
                         SNOTE               => null,
                         NHTML_HIDE          => 0,
                         NHTML_HIDE_NAME_COL => 0,
                         NHTML_MAKE_HIER_GRP => 0,
                         SCLSF_CODE          => null,
                         NLINKS_UPDATE       => 0,
                         NDUP_RN             => null,
                         NRN                 => NRN);
  end RRPCONFSCTN_INSERT;
  
  /* Исправление раздела регламентированного отчёта */
  procedure RRPCONFSCTN_UPDATE
  (
    NRN                     in number,                             -- Ид. раздела
    SCODE                   in varchar2,                           -- Мнемокод раздела
    SNAME                   in varchar2                            -- Наименование раздела
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Рег. номер организации
    RES                     RRPCONFSCTN%rowtype;                   -- Запись раздела настройки формы регламентированного отчета
  begin
    RES := GET_RRPCONFSCTN_ID(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, NRN => NRN);
    P_RRPCONFSCTN_UPDATE(NRN                 => NRN,
                         NCOMPANY            => NCOMPANY,
                         SCODE               => SCODE,
                         SNAME               => SNAME,
                         SRRPCONFSCTN        => RES.RRPCONFSCTN,
                         SRRPPRMGRP          => RES.RRPPRMGRP,
                         SNOTE               => RES.NOTE,
                         NHTML_HIDE          => RES.HTML_HIDE,
                         NHTML_HIDE_NAME_COL => RES.HTML_HIDE_NAME_COL,
                         NHTML_MAKE_HIER_GRP => RES.HTML_MAKE_HIER_GRP,
                         SCLSF_CODE          => RES.CLSF_CODE,
                         NFORMULA_UPDATE     => 0,
                         NMARK_UPDATE        => 0);
  end RRPCONFSCTN_UPDATE;
  
  /* Удаление раздела регламентированного отчёта */
  procedure RRPCONFSCTN_DELETE
  (
    NRN                     in number                              -- Ид. раздела
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Рег. номер организации
  begin
    P_RRPCONFSCTN_DELETE(NRN => NRN, NCOMPANY => NCOMPANY);
  end RRPCONFSCTN_DELETE;
  
  /* Получение кодов настройки, раздела и показателя раздела по ид. показателя раздела */
  procedure RRPCONFSCTNMRK_GET_CODES
  (
    NRN                     in number,                                                     -- Ид. показателя раздела
    SRRPCONF                out varchar2,                                                  -- Код настройки формы регламентированного отчёта
    SRRPCONFSCTN            out varchar2,                                                  -- Код раздела
    SRRPCONFSCTNMRK         out varchar2                                                   -- Код показателя раздела
  )
  is
    NVERSION                PKG_STD.TREF := GET_SESSION_VERSION(SUNITCODE => 'RRPConfig'); -- Версия раздела 
  begin
    select R.CODE,
           RS.CODE,
           RSM.CODE
      into SRRPCONF,
           SRRPCONFSCTN,
           SRRPCONFSCTNMRK
      from RRPCONF        R,
           RRPCONFSCTN    RS,
           RRPCONFSCTNMRK RSM
     where R.RN in (select RRPCONF
                      from RRPCONFSCTNMRK
                     where RN = NRN
                       and VERSION = NVERSION)
       and RS.RN in (select PRN
                       from RRPCONFSCTNMRK
                      where RN = NRN
                        and VERSION = NVERSION)
       and RSM.RN = NRN;
  exception
    when NO_DATA_FOUND then
      P_EXCEPTION(0, 'По выбранному показателю раздела не найдено данных.');
    when TOO_MANY_ROWS then
      P_EXCEPTION(0,
                  'По выбранному показателю раздела найдено несколько записей.');
  end RRPCONFSCTNMRK_GET_CODES;
  
  /* Добавление показателя раздела регламентированного отчёта */
  procedure RRPCONFSCTNMRK_INSERT
  (
    NPRN                    in number,                             -- Ид. раздела
    SCODE                   in varchar2,                           -- Мнемокод показателя раздела
    SNAME                   in varchar2,                           -- Наименование показателя раздела
    SCOLCODE                in varchar2,                           -- Мнемокод графы
    SCOLVER                 in varchar2,                           -- Мнемокод редакции графы
    SROWCODE                in varchar2,                           -- Мнемокод строки
    SROWVER                 in varchar2,                           -- Мнемокод редакции строки
    NRN                     out number                             -- Ид. созданной записи
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Рег. номер организации
    NCOUNT                  PKG_STD.TNUMBER;                       -- Счётчик показателей раздела
  begin
    NCOUNT := F_RRPCONFSCTNMRK_NEXT_NUMB(NCOMPANY => NCOMPANY, NPRN => NPRN);
    P_RRPCONFSCTNMRK_INSERT(NCOMPANY           => NCOMPANY,
                            NPRN               => NPRN,
                            NNUMB              => NCOUNT + 1,
                            SCODE              => SCODE,
                            SNAME              => SNAME,
                            SRRPROW            => SROWCODE,
                            SRRPVERSION_ROW    => SROWVER,
                            SRRPCOLUMN         => SCOLCODE,
                            SRRPVERSION_COLUMN => SCOLVER,
                            SPKG_ROW           => null,
                            SPRC_ROW           => null,
                            SPKG_COL           => null,
                            SPRC_COL           => null,
                            SRRPPRM            => null,
                            NIGNORE_ZOOM       => 0,
                            NIGNORE_SHARP      => 0,
                            SCLSF_CODE         => null,
                            SNOTE              => null,
                            NDUP_RN            => null,
                            NRN                => NRN);
  end RRPCONFSCTNMRK_INSERT;
  
  /* Исправление показателя раздела регламентированного отчёта */
  procedure RRPCONFSCTNMRK_UPDATE
  (
    NRN                     in number,                             -- Ид. показателя раздела            
    SNAME                   in varchar2                            -- Новое наименование
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Рег. номер организации
    RESSCTNMRK              RRPCONFSCTNMRK%rowtype;                -- Запись настройки показателя регламентированного отчета
    RESROW                  RRPROW%rowtype;                        -- Запись строки регламентированного отчета
    RESCOLUMN               RRPCOLUMN%rowtype;                     -- Запись графы регламентированного отчета
    SROWVER                 PKG_STD.TSTRING;                       -- Мнемокод редакции строки
    SCOLVER                 PKG_STD.TSTRING;                       -- Мнемокод редакции графы
  begin
    /* Получение записи параметра раздела */
    RESSCTNMRK := GET_RRPCONFSCTNMRK_ID(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, NRN => NRN);
    /* Получение записи строки */
    RESROW := GET_RRPROW_ID(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, NRN => RESSCTNMRK.RRPROW);
    /* Получение записи графы */
    RESCOLUMN := GET_RRPCOLUMN_ID(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, NRN => RESSCTNMRK.RRPCOLUMN);
    /* Получение мнемокода редакции строки */
    SROWVER := GET_RRPVERSION_CODE_ID(NFLAG_SMART => 0, NRN => RESROW.RRPVERSION);
    /* Получение мнемокода редакции графы */
    SCOLVER := GET_RRPVERSION_CODE_ID(NFLAG_SMART => 0, NRN => RESCOLUMN.RRPVERSION);
    P_RRPCONFSCTNMRK_UPDATE(NRN                => NRN,
                            NCOMPANY           => NCOMPANY,
                            NNUMB              => RESSCTNMRK.NUMB,
                            SCODE              => RESSCTNMRK.CODE,
                            SNAME              => SNAME,
                            SRRPROW            => RESROW.CODE,
                            SRRPVERSION_ROW    => SROWVER,
                            SRRPCOLUMN         => RESCOLUMN.CODE,
                            SRRPVERSION_COLUMN => SCOLVER,
                            SPKG_ROW           => RESSCTNMRK.PKG_ROW,
                            SPRC_ROW           => RESSCTNMRK.PRC_ROW,
                            SPKG_COL           => RESSCTNMRK.PKG_COL,
                            SPRC_COL           => RESSCTNMRK.PRC_COL,
                            SRRPPRM            => RESSCTNMRK.RRPPRM,
                            NIGNORE_ZOOM       => RESSCTNMRK.IGNORE_ZOOM,
                            NIGNORE_SHARP      => RESSCTNMRK.IGNORE_SHARP,
                            SCLSF_CODE         => RESSCTNMRK.CLSF_CODE,
                            NFORMULA_UPDATE    => 0,
                            SNOTE              => RESSCTNMRK.NOTE);
  end RRPCONFSCTNMRK_UPDATE;
  
  /* Удаление показателя раздела регламентированного отчёта */
  procedure RRPCONFSCTNMRK_DELETE
  (        
    NRN                     in number                              -- Ид. показателя раздела
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Рег. номер организации
  begin
    P_RRPCONFSCTNMRK_DELETE(NCOMPANY => NCOMPANY, NRN => NRN);
  end RRPCONFSCTNMRK_DELETE;
  
  /* Формирование кода и наименования показателя раздела регламентированного отчёта */
  procedure RRPCONFSCTNMRK_GET_CODE_NAME
  ( 
    SSCTNCODE               in varchar2,                           -- Мнемокод раздела  
    SROWCODE                in varchar2,                           -- Мнемокод строки
    NROWVER                 in number,                             -- Ид. редакции строки
    SCOLUMNCODE             in varchar2,                           -- Мнемокод графы
    NCOLUMNVER              in number,                             -- Ид. редакции графы
    SCODE                   out varchar2,                          -- Мнемокод показателя раздела
    SNAME                   out varchar2                           -- Наименование показателя раздела    
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Рег. номер организации
    NROWRN                  PKG_STD.TREF;                          -- Ид. строки
    NCOLUMNRN               PKG_STD.TREF;                          -- Ид. графы
  begin
    P_RRPCONFSCTNMRK_MAKE_CODE(SRRPCONFSCTN => SSCTNCODE,
                               SRRPROW      => SROWCODE,
                               SRRPCOLUMN   => SCOLUMNCODE,
                               SCODE        => SCODE);
    FIND_RRPROW_CODE(NFLAG_SMART  => 0,
                     NFLAG_OPTION => 0,
                     NCOMPANY     => NCOMPANY,
                     NRRPVERSION  => NROWVER,
                     SCODE        => SROWCODE,
                     NRN          => NROWRN);
    FIND_RRPCOLUMN_CODE(NFLAG_SMART  => 0,
                        NFLAG_OPTION => 0,
                        NCOMPANY     => NCOMPANY,
                        NRRPVERSION  => NCOLUMNVER,
                        SCODE        => SCOLUMNCODE,
                        NRN          => NCOLUMNRN);
    P_RRPCONFSCTNMRK_MAKE_NAME(NCOMPANY            => NCOMPANY,
                               NRRPROW             => NROWRN,
                               NRRPCOLUMN          => NCOLUMNRN,
                               NCHANGE_NAME        => 1,
                               NCHANGE_NAME_PARENT => 0,
                               SNAME               => SNAME);
  end RRPCONFSCTNMRK_GET_CODE_NAME;
  
end PKG_P8PANELS_RRPCONFED;
/

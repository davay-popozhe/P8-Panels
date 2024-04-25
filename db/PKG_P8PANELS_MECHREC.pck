create or replace package PKG_P8PANELS_MECHREC as
  
  /* Получение таблицы ПиП на основании маршрутного листа, связанных со спецификацией плана */
  procedure INCOMEFROMDEPS_DG_GET
  (
    NFCPRODPLANSP           in number,  -- Рег. номер связанной спецификации плана
    NTYPE                   in number,  -- Тип спецификации плана (2 - Не включать "Состояние", 3 - включать)
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    CORDERS                 in clob,    -- Сортировки
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
  );

  /* Получение строк комплектации на основании маршрутного листа */
  procedure FCDELIVERYLISTSP_DG_GET
  (
    NFCROUTLST              in number,  -- Рег. номер маршрутного листа
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    CORDERS                 in clob,    -- Сортировки
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
  );

  /* Получение товарных запасов на основании маршрутного листа */
  procedure GOODSPARTIES_DG_GET
  (
    NFCROUTLST              in number, -- Рег. номер маршрутного листа
    NPAGE_NUMBER            in number, -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number, -- Количество записей на странице (0 - все)
    CORDERS                 in clob,   -- Сортировки
    NINCLUDE_DEF            in number, -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob   -- Сериализованная таблица данных
  );

  /* Получение таблицы маршрутных листов, связанных со спецификацией плана с учетом типа */
  procedure FCROUTLST_DG_GET
  (
    NFCPRODPLANSP           in number,  -- Рег. номер связанной спецификации плана
    NTYPE                   in number,  -- Тип спецификации плана (0 - Деталь, 1 - Изделие/сборочная единица, 3/4 - ПиП)
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    CORDERS                 in clob,    -- Сортировки
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
  );

  /* Получение списка спецификаций планов и отчетов производства изделий для диаграммы Ганта */
  procedure FCPRODPLANSP_GET
  (
    NCRN                    in number,                     -- Рег. номер каталога
    NLEVEL                  in number := null,             -- Уровень отбора
    SSORT_FIELD             in varchar2 := 'DREP_DATE_TO', -- Поле сортировки
    COUT                    out clob,                      -- Список задач
    NMAX_LEVEL              out number                     -- Максимальный уровень иерархии
  );

  /* Инициализация каталогов раздела "Планы и отчеты производства изделий"  */
  procedure ACATALOG_INIT
  (
    COUT                    out clob    -- Список каталогов раздела "Планы и отчеты производства изделий"
  );

end PKG_P8PANELS_MECHREC;
/
create or replace package body PKG_P8PANELS_MECHREC as

  /* Константы - цвета отображения */
  SBG_COLOR_RED             constant PKG_STD.TSTRING := '#ff000080'; -- Цвет заливки красный
  SBG_COLOR_YELLOW          constant PKG_STD.TSTRING := '#e0db4480'; -- Цвет заливки желтый
  SBG_COLOR_GREEN           constant PKG_STD.TSTRING := '#90ee9080'; -- Цвет заливки зеленый
  SBG_COLOR_GREY            constant PKG_STD.TSTRING := '#d3d3d380'; -- Цвет заливки серый
  SBG_COLOR_BLACK           constant PKG_STD.TSTRING := '#00000080'; -- Цвет заливки черный
  STEXT_COLOR_ORANGE        constant PKG_STD.TSTRING := '#FF8C00';   -- Цвет текста оранжевый
  STEXT_COLOR_GREY          constant PKG_STD.TSTRING := '#555';      -- Цвет текста серый

  /* Константы - параметры отборов планов */
  NFCPRODPLAN_CATEGORY      constant PKG_STD.TNUMBER := 1;      -- Категория планов "Производственная программа"
  NFCPRODPLAN_STATUS        constant PKG_STD.TNUMBER := 2;      -- Статус планов "Утвержден"
  SFCPRODPLAN_TYPE          constant PKG_STD.TSTRING := 'План'; -- Тип планов (мнемокод состояния)

  /* Константы - дополнительные атрибуты */
  STASK_ATTR_START_FACT     constant PKG_STD.TSTRING := 'start_fact';  -- Запущено
  STASK_ATTR_MAIN_QUANT     constant PKG_STD.TSTRING := 'main_quant';  -- Количество план
  STASK_ATTR_REL_FACT       constant PKG_STD.TSTRING := 'rel_fact';    -- Количество сдано
  STASK_ATTR_REP_DATE_TO    constant PKG_STD.TSTRING := 'rep_date_to'; -- Дата выпуска план
  STASK_ATTR_DL             constant PKG_STD.TSTRING := 'detail_list'; -- Связанные документы
  STASK_ATTR_TYPE           constant PKG_STD.TSTRING := 'type';        -- Тип (0 - Деталь, 1 - Изделие/сборочная единица)
  STASK_ATTR_MEAS           constant PKG_STD.TSTRING := 'meas';        -- Единица измнения

  /* Инциализация списка маршрутных листов (с иерархией) */
  procedure UTL_FCROUTLST_IDENT_INIT
  (
    NFCPRODPLANSP           in number, -- Рег. номер связанной спецификации плана
    NIDENT                  out number -- Идентификатор отмеченных записей
  )
  is
    /* Рекурсивная процедура формирования списка маршрутных листов */
    procedure PUT_FCROUTLST
    (
      NIDENT          in number,       -- Идентификатор отмеченных записей
      NFCROUTLST      in number        -- Рег. номер маршрутного листа
    )
    is
      NTMP            PKG_STD.TNUMBER; -- Буфер
    begin
      /* Добавление в список */
      begin
        P_SELECTLIST_INSERT(NIDENT => NIDENT, NDOCUMENT => NFCROUTLST, SUNITCODE => 'CostRouteLists', NRN => NTMP);
      exception
        when others then
          return;
      end;
      /* Маршрутные листы, связанные со строками добавленного */
      for RLST in (select distinct L.OUT_DOCUMENT as RN
                     from FCROUTLSTSP LS,
                          DOCLINKS    L
                    where LS.PRN = NFCROUTLST
                      and L.IN_DOCUMENT = LS.RN
                      and L.IN_UNITCODE = 'CostRouteListsSpecs'
                      and L.OUT_UNITCODE = 'CostRouteLists')
      loop
        /* Добавляем по данному листу */
        PUT_FCROUTLST(NIDENT => NIDENT, NFCROUTLST => RLST.RN);
      end loop;
    end PUT_FCROUTLST;
  begin
    /* Генерируем идентификатор */
    NIDENT := GEN_IDENT();
    /* Цикл по связанным напрямую маршрутным листам */
    for RLST in (select D.RN
                   from FCROUTLST D
                  where D.RN in (select L.OUT_DOCUMENT
                                   from DOCLINKS L
                                  where L.IN_DOCUMENT = NFCPRODPLANSP
                                    and L.IN_UNITCODE = 'CostProductPlansSpecs'
                                    and L.OUT_UNITCODE = 'CostRouteLists'))
    loop
      /* Рекурсивная процедура формирования списка маршрутных листов */
      PUT_FCROUTLST(NIDENT => NIDENT, NFCROUTLST => RLST.RN);
    end loop;
  end UTL_FCROUTLST_IDENT_INIT;

  /* Проверка наличия связанных маршрутных листов */
  function LINK_FCROUTLST_CHECK
  (
    NCOMPANY                in number,        -- Рег. номер организации
    NFCPRODPLANSP           in number,        -- Рег. номер спецификации плана
    NSTATE                  in number := null -- Состояние маршрутного листа
  ) return                  number            -- Наличие связанного МЛ (0 - нет, 1 - есть)
  is
    NRESULT                 PKG_STD.TNUMBER;  -- Наличие связанного МЛ (0 - нет, 1 - есть)
  begin
    begin
      select 1
        into NRESULT
        from DUAL
       where exists (select null
                from DOCLINKS  L,
                     FCROUTLST F
               where L.IN_DOCUMENT = NFCPRODPLANSP
                 and L.IN_UNITCODE = 'CostProductPlansSpecs'
                 and L.IN_COMPANY = NCOMPANY
                 and L.OUT_UNITCODE = 'CostRouteLists'
                 and L.OUT_COMPANY = NCOMPANY
                 and F.RN = L.OUT_DOCUMENT
                 and ((NSTATE is null) or ((NSTATE is not null) and (F.STATE = NSTATE)))
                 and ROWNUM = 1);
    exception
      when others then
        NRESULT := 0;
    end;
    /* Возвращаем результат */
    return NRESULT;
  end LINK_FCROUTLST_CHECK;

  /* Проверка наличия связанных приходов из подразделений */
  function LINK_INCOMEFROMDEPS_CHECK
  (
    NCOMPANY                in number,        -- Рег. номер организации
    NFCPRODPLANSP           in number,        -- Рег. номер спецификации плана
    NSTATE                  in number := null -- Состояние ПиП
  ) return                  number            -- Наличие связанного ПиП (0 - нет, 1 - есть)
  is
    NRESULT                 PKG_STD.TNUMBER;  -- Наличие связанного ПиП (0 - нет, 1 - есть)
    NFCROUTLST_IDENT        PKG_STD.TREF;     -- Рег. номер идентификатора отмеченных записей маршрутных листов
  begin
    /* Инициализируем список маршрутных листов */
    UTL_FCROUTLST_IDENT_INIT(NFCPRODPLANSP => NFCPRODPLANSP, NIDENT => NFCROUTLST_IDENT);
    /* Проверяем наличие */
    begin
      select 1
        into NRESULT
        from DUAL
       where exists (select null
                from DOCLINKS       L,
                     INCOMEFROMDEPS F
               where L.IN_DOCUMENT = NFCPRODPLANSP
                 and L.IN_UNITCODE = 'CostProductPlansSpecs'
                 and L.OUT_UNITCODE = 'IncomFromDeps'
                 and L.OUT_COMPANY = NCOMPANY
                 and F.RN = L.OUT_DOCUMENT
                 and F.COMPANY = NCOMPANY
                 and ((NSTATE is null) or ((NSTATE is not null) and (F.DOC_STATE = NSTATE)))
                 and ROWNUM = 1)
          or exists (select null
                from INCOMEFROMDEPS F
               where F.RN in (select L.OUT_DOCUMENT
                                from SELECTLIST SL,
                                     DOCLINKS   L
                               where SL.IDENT = NFCROUTLST_IDENT
                                 and SL.UNITCODE = 'CostRouteLists'
                                 and L.IN_DOCUMENT = SL.DOCUMENT
                                 and L.IN_UNITCODE = 'CostRouteLists'
                                 and L.OUT_UNITCODE = 'IncomFromDeps'));
    exception
      when others then
        NRESULT := 0;
    end;
    /* Очищаем отмеченные маршрутные листы */
    P_SELECTLIST_CLEAR(NIDENT => NFCROUTLST_IDENT);
    /* Возвращаем результат */
    return NRESULT;
  exception
    when others then
      /* Очищаем отмеченные маршрутные листы */
      P_SELECTLIST_CLEAR(NIDENT => NFCROUTLST_IDENT);
      raise;
  end LINK_INCOMEFROMDEPS_CHECK;

  /* Получение таблицы ПиП на основании маршрутного листа, связанных со спецификацией плана */
  procedure INCOMEFROMDEPS_DG_GET
  (
    NFCPRODPLANSP           in number,                             -- Рег. номер связанной спецификации плана
    NTYPE                   in number,                             -- Тип спецификации плана (2 - Не включать "Состояние", 3 - включать)
    NPAGE_NUMBER            in number,                             -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,                             -- Количество записей на странице (0 - все)
    CORDERS                 in clob,                               -- Сортировки
    NINCLUDE_DEF            in number,                             -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob                               -- Сериализованная таблица данных
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
    RO                      PKG_P8PANELS_VISUAL.TORDERS;           -- Сортировки
    RDG                     PKG_P8PANELS_VISUAL.TDATA_GRID;        -- Описание таблицы
    RDG_ROW                 PKG_P8PANELS_VISUAL.TROW;              -- Строка таблицы
    NROW_FROM               PKG_STD.TREF;                          -- Номер строки с
    NROW_TO                 PKG_STD.TREF;                          -- Номер строки по
    CSQL                    clob;                                  -- Буфер для запроса
    ICURSOR                 integer;                               -- Курсор для исполнения запроса
    NFCROUTLST_IDENT        PKG_STD.TREF;                          -- Рег. номер идентификатора отмеченных записей маршрутных листов
  begin
    /* Читем сортировки */
    RO := PKG_P8PANELS_VISUAL.TORDERS_FROM_XML(CORDERS => CORDERS);
    /* Преобразуем номер и размер страницы в номер строк с и по */
    PKG_P8PANELS_VISUAL.UTL_ROWS_LIMITS_CALC(NPAGE_NUMBER => NPAGE_NUMBER,
                                             NPAGE_SIZE   => NPAGE_SIZE,
                                             NROW_FROM    => NROW_FROM,
                                             NROW_TO      => NROW_TO);
    /* Инициализируем таблицу данных */
    RDG := PKG_P8PANELS_VISUAL.TDATA_GRID_MAKE();
    /* Описываем колонки таблицы данных */
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NRN',
                                               SCAPTION   => 'Рег. номер',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SDOC_INFO',
                                               SCAPTION   => 'Накладная',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true);
    /* Если тип = 3, то необходимо включать состояние */
    if (NTYPE = 3) then
      PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                                 SNAME      => 'SDOC_STATE',
                                                 SCAPTION   => 'Состояние',
                                                 SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                                 BVISIBLE   => true);
    end if;
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DWORK_DATE',
                                               SCAPTION   => 'Дата сдачи',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SDOC_VALID_INFO',
                                               SCAPTION   => 'Маршрутный лист',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SOUT_DEPARTMENT',
                                               SCAPTION   => 'Сдающий цех',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SSTORE',
                                               SCAPTION   => 'Склад цеха потребителя',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NQUANT_FACT',
                                               SCAPTION   => 'Количество сдано',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    /* Инициализируем список маршрутных листов */
    UTL_FCROUTLST_IDENT_INIT(NFCPRODPLANSP => NFCPRODPLANSP, NIDENT => NFCROUTLST_IDENT);
    /* Обходим данные */
    begin
      /* Добавляем подсказку совместимости */
      CSQL := PKG_SQL_BUILD.COMPATIBLE(SSQL => CSQL);
      /* Формируем запрос */
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => 'select *');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '  from (select D.*,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.SQLROWNUM() || ' NROW');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '          from (select T.RN NRN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       DT.DOCCODE ||');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       '', '' || TRIM(T.DOC_PREF) ||');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       ''-'' || TRIM(T.DOC_NUMB) ||');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       '', '' || TO_CHAR(T.DOC_DATE, ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'dd.mm.yyyy') || ') as SDOC_INFO,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       case T.DOC_STATE');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                         when 0 then');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'Не отработан'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                         when 1 then');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'Отработан как план'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                         when 2 then');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'Отработан как факт'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                         else');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           null');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       end SDOC_STATE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.WORK_DATE DWORK_DATE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       DTV.DOCCODE ||');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       '', '' || T.VALID_DOCNUMB || ');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       '', '' || TO_CHAR(T.VALID_DOCDATE, ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'dd.mm.yyyy') || ') as SDOC_VALID_INFO,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       D.CODE SOUT_DEPARTMENT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       S.AZS_NUMBER SSTORE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       (select SUM(SP.QUANT_FACT)');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                          from INCOMEFROMDEPSSPEC SP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                         where SP.PRN = T.RN) NQUANT_FACT');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  from INCOMEFROMDEPS T left outer join DOCTYPES DTV on T.VALID_DOCTYPE = DTV.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       left outer join INS_DEPARTMENT D on T.OUT_DEPARTMENT = D.RN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       DOCTYPES DT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       AZSAZSLISTMT S');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                 where ((T.RN in (select L.OUT_DOCUMENT');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                    from DOCLINKS L');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                   where L.IN_DOCUMENT = :NFCPRODPLANSP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                     and L.IN_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostProductPlansSpecs'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                     and L.OUT_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'IncomFromDeps') || '))');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                        or (T.RN in (select L.OUT_DOCUMENT');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                       from SELECTLIST SL,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                            DOCLINKS   L');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                      where SL.IDENT       = :NFCROUTLST_IDENT');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                        and SL.UNITCODE    = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostRouteLists'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                        and L.IN_DOCUMENT  = SL."DOCUMENT"');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                        and L.IN_UNITCODE  = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostRouteLists'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                        and L.OUT_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'IncomFromDeps') || ')))');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T.COMPANY = :NCOMPANY');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T.DOC_TYPE = DT.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T.STORE = S.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                %ORDER_BY%) D) F');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => ' where F.NROW between :NROW_FROM and :NROW_TO');
      /* Учтём сортировки */
      PKG_P8PANELS_VISUAL.TORDERS_SET_QUERY(RDATA_GRID => RDG, RORDERS => RO, SPATTERN => '%ORDER_BY%', CSQL => CSQL);
      /* Разбираем его */
      ICURSOR := PKG_SQL_DML.OPEN_CURSOR(SWHAT => 'SELECT');
      PKG_SQL_DML.PARSE(ICURSOR => ICURSOR, SQUERY => CSQL);
      /* Делаем подстановку параметров */
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NCOMPANY', NVALUE => NCOMPANY);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_FROM', NVALUE => NROW_FROM);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_TO', NVALUE => NROW_TO);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NFCPRODPLANSP', NVALUE => NFCPRODPLANSP);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NFCROUTLST_IDENT', NVALUE => NFCROUTLST_IDENT);
      /* Описываем структуру записи курсора */
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 1);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 2);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 3);
      PKG_SQL_DML.DEFINE_COLUMN_DATE(ICURSOR => ICURSOR, IPOSITION => 4);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 5);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 6);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 7);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 8);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 9);
      /* Делаем выборку */
      if (PKG_SQL_DML.EXECUTE(ICURSOR => ICURSOR) = 0) then
        null;
      end if;
      /* Обходим выбранные записи */
      while (PKG_SQL_DML.FETCH_ROWS(ICURSOR => ICURSOR) > 0)
      loop
        /* Добавляем колонки с данными */
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NRN',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 1,
                                              BCLEAR    => true);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SDOC_INFO',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 2);
        /* Если тип = 3, то необходимо включать состояние */
        if (NTYPE = 3) then
          PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                                SNAME     => 'SDOC_STATE',
                                                ICURSOR   => ICURSOR,
                                                NPOSITION => 3);
        end if;
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLD(RROW      => RDG_ROW,
                                              SNAME     => 'DWORK_DATE',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 4);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SDOC_VALID_INFO',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 5);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SOUT_DEPARTMENT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 6);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SSTORE', ICURSOR => ICURSOR, NPOSITION => 7);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NQUANT_FACT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 8);
        /* Добавляем строку в таблицу */
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW);
      end loop;
    exception
      when others then
        PKG_SQL_DML.CLOSE_CURSOR(ICURSOR => ICURSOR);
        raise;
    end;
    /* Очищаем отмеченные маршрутные листы */
    P_SELECTLIST_CLEAR(NIDENT => NFCROUTLST_IDENT);
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TDATA_GRID_TO_XML(RDATA_GRID => RDG, NINCLUDE_DEF => NINCLUDE_DEF);
  exception
    when others then
      /* Очищаем отмеченные маршрутные листы */
      P_SELECTLIST_CLEAR(NIDENT => NFCROUTLST_IDENT);
      raise;
  end INCOMEFROMDEPS_DG_GET;

  /* Получение таблицы строк комплектации на основании маршрутного листа */
  procedure FCDELIVERYLISTSP_DG_GET
  (
    NFCROUTLST              in number,                             -- Рег. номер маршрутного листа
    NPAGE_NUMBER            in number,                             -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,                             -- Количество записей на странице (0 - все)
    CORDERS                 in clob,                               -- Сортировки
    NINCLUDE_DEF            in number,                             -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob                               -- Сериализованная таблица данных
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
    RO                      PKG_P8PANELS_VISUAL.TORDERS;           -- Сортировки
    RDG                     PKG_P8PANELS_VISUAL.TDATA_GRID;        -- Описание таблицы
    RDG_ROW                 PKG_P8PANELS_VISUAL.TROW;              -- Строка таблицы
    NROW_FROM               PKG_STD.TREF;                          -- Номер строки с
    NROW_TO                 PKG_STD.TREF;                          -- Номер строки по
    CSQL                    clob;                                  -- Буфер для запроса
    ICURSOR                 integer;                               -- Курсор для исполнения запроса
  begin
    /* Читем сортировки */
    RO := PKG_P8PANELS_VISUAL.TORDERS_FROM_XML(CORDERS => CORDERS);
    /* Преобразуем номер и размер страницы в номер строк с и по */
    PKG_P8PANELS_VISUAL.UTL_ROWS_LIMITS_CALC(NPAGE_NUMBER => NPAGE_NUMBER,
                                             NPAGE_SIZE   => NPAGE_SIZE,
                                             NROW_FROM    => NROW_FROM,
                                             NROW_TO      => NROW_TO);
    /* Инициализируем таблицу данных */
    RDG := PKG_P8PANELS_VISUAL.TDATA_GRID_MAKE();
    /* Описываем колонки таблицы данных */
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NRN',
                                               SCAPTION   => 'Рег. номер',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SMATRESPL_CODE',
                                               SCAPTION   => 'Обозначение',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SMATRESPL_NAME',
                                               SCAPTION   => 'Наименование',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NPROD_QUANT',
                                               SCAPTION   => 'Применяемость',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NQUANT_PLAN',
                                               SCAPTION   => 'Количество план',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NREST',
                                               SCAPTION   => 'Остаток',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NQUANT_FACT',
                                               SCAPTION   => 'Скомплектовано',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DRES_DATE_TO',
                                               SCAPTION   => 'Зарезервировано',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               BVISIBLE   => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SMATRESPL_NOMEN',
                                               SCAPTION   => 'Номенклатура',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true);
    /* Обходим данные */
    begin
      /* Добавляем подсказку совместимости */
      CSQL := PKG_SQL_BUILD.COMPATIBLE(SSQL => CSQL);
      /* Формируем запрос */
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => 'select *');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '  from (select D.*,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.SQLROWNUM() || ' NROW');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '          from (select min(T.RN) NRN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.RES_DATE_TO DRES_DATE_TO,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       NP.NOMEN_CODE SMATRESPL_NOMEN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       CP.CODE SMATRESPL_CODE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       CP."NAME" SMATRESPL_NAME,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.PROD_QUANT NPROD_QUANT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       sum(T.QUANT_PLAN) NQUANT_PLAN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.REST NREST,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       sum(T.QUANT_FACT) NQUANT_FACT');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  from DOCLINKS DL,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       FCDELIVERYLIST TL,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       FCDELIVERYLISTSP T,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       FCMATRESOURCE CP left outer join DICNOMNS NP on CP.NOMENCLATURE = NP.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                 where DL.IN_DOCUMENT = :NFCROUTLST');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and DL.IN_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostRouteLists'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and DL.OUT_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostDeliveryLists'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and TL.RN = DL.OUT_DOCUMENT');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and TL.COMPANY = :NCOMPANY');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T.PRN = TL.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T.MATRESPL = CP.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and exists (select null from V_USERPRIV UP where (UP."CATALOG" = T.CRN))');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and exists (select null');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 from V_USERPRIV UP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                where UP.JUR_PERS = T.JUR_PERS');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostDeliveryLists') || ')');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                 group by T.RES_DATE_TO, NP.NOMEN_CODE, CP.CODE, CP."NAME", T.PROD_QUANT, T.REST');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                 %ORDER_BY%) D) F');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => ' where F.NROW between :NROW_FROM and :NROW_TO');
      /* Учтём сортировки */
      PKG_P8PANELS_VISUAL.TORDERS_SET_QUERY(RDATA_GRID => RDG, RORDERS => RO, SPATTERN => '%ORDER_BY%', CSQL => CSQL);
      /* Разбираем его */
      ICURSOR := PKG_SQL_DML.OPEN_CURSOR(SWHAT => 'SELECT');
      PKG_SQL_DML.PARSE(ICURSOR => ICURSOR, SQUERY => CSQL);
      /* Делаем подстановку параметров */
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NCOMPANY', NVALUE => NCOMPANY);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_FROM', NVALUE => NROW_FROM);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_TO', NVALUE => NROW_TO);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NFCROUTLST', NVALUE => NFCROUTLST);
      /* Описываем структуру записи курсора */
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 1);
      PKG_SQL_DML.DEFINE_COLUMN_DATE(ICURSOR => ICURSOR, IPOSITION => 2);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 3);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 4);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 5);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 6);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 7);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 8);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 9);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 10);
      /* Делаем выборку */
      if (PKG_SQL_DML.EXECUTE(ICURSOR => ICURSOR) = 0) then
        null;
      end if;
      /* Обходим выбранные записи */
      while (PKG_SQL_DML.FETCH_ROWS(ICURSOR => ICURSOR) > 0)
      loop
        /* Добавляем колонки с данными */
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NRN',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 1,
                                              BCLEAR    => true);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLD(RROW      => RDG_ROW,
                                              SNAME     => 'DRES_DATE_TO',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 2);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SMATRESPL_NOMEN',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 3);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SMATRESPL_CODE',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 4);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SMATRESPL_NAME',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 5);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NPROD_QUANT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 6);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NQUANT_PLAN',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 7);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW => RDG_ROW, SNAME => 'NREST', ICURSOR => ICURSOR, NPOSITION => 8);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NQUANT_FACT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 9);
        /* Добавляем строку в таблицу */
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW);
      end loop;
    exception
      when others then
        PKG_SQL_DML.CLOSE_CURSOR(ICURSOR => ICURSOR);
        raise;
    end;
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TDATA_GRID_TO_XML(RDATA_GRID => RDG, NINCLUDE_DEF => NINCLUDE_DEF);
  end FCDELIVERYLISTSP_DG_GET;

  /* Получение таблицы товарных запасов на основании маршрутного листа */
  procedure GOODSPARTIES_DG_GET
  (
    NFCROUTLST              in number,                             -- Рег. номер маршрутного листа
    NPAGE_NUMBER            in number,                             -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,                             -- Количество записей на странице (0 - все)
    CORDERS                 in clob,                               -- Сортировки
    NINCLUDE_DEF            in number,                             -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob                               -- Сериализованная таблица данных
  )
  is
    NSTORAGE                PKG_STD.TREF;                          -- Рег. номер склада списания
    NSTORAGE_IN             PKG_STD.TREF;                          -- Рег. номер склада получения
    NNOMENCLATURE           PKG_STD.TREF;                          -- Рег. номер номенклатуры основного материала
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
    RO                      PKG_P8PANELS_VISUAL.TORDERS;           -- Сортировки
    RDG                     PKG_P8PANELS_VISUAL.TDATA_GRID;        -- Описание таблицы
    RDG_ROW                 PKG_P8PANELS_VISUAL.TROW;              -- Строка таблицы
    NROW_FROM               PKG_STD.TREF;                          -- Номер строки с
    NROW_TO                 PKG_STD.TREF;                          -- Номер строки по
    CSQL                    clob;                                  -- Буфер для запроса
    ICURSOR                 integer;                               -- Курсор для исполнения запроса
    DDATE                   PKG_STD.TLDATE;                        -- Дата с/по
  begin
    /* Считываем информацию из маршрутного листа */
    begin
      select T.STORAGE,
             T.STORAGE_IN,
             F.NOMENCLATURE
        into NSTORAGE,
             NSTORAGE_IN,
             NNOMENCLATURE
        from FCROUTLST     T,
             FCMATRESOURCE F
       where T.MATRES_PLAN = F.RN(+)
         and T.RN = NFCROUTLST;
    exception
      when others then
        NSTORAGE      := null;
        NSTORAGE_IN   := null;
        NNOMENCLATURE := null;
    end;
    /* Если номенклатура не указана */
    if ((NNOMENCLATURE is null) or ((NSTORAGE is null) and (NSTORAGE_IN is null))) then
      /* Не идем дальше */
      return;
    end if;
    /* Инициализируем даты */
    DDATE := TRUNC(sysdate);
    /* Читем сортировки */
    RO := PKG_P8PANELS_VISUAL.TORDERS_FROM_XML(CORDERS => CORDERS);
    /* Преобразуем номер и размер страницы в номер строк с и по */
    PKG_P8PANELS_VISUAL.UTL_ROWS_LIMITS_CALC(NPAGE_NUMBER => NPAGE_NUMBER,
                                             NPAGE_SIZE   => NPAGE_SIZE,
                                             NROW_FROM    => NROW_FROM,
                                             NROW_TO      => NROW_TO);
    /* Описываем колонки таблицы данных */
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SINDOC',
                                               SCAPTION   => 'Партия',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SSTORE',
                                               SCAPTION   => 'Склад',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NSALE',
                                               SCAPTION   => 'К продаже',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NRESTFACT',
                                               SCAPTION   => 'Фактический остаток',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NRESERV',
                                               SCAPTION   => 'Резерв',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true,
                                               BFILTER    => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SPRICEMEAS',
                                               SCAPTION   => 'Единица измерения',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    /* Обходим данные */
    begin
      /* Добавляем подсказку совместимости */
      CSQL := PKG_SQL_BUILD.COMPATIBLE(SSQL => CSQL);
      /* Формируем запрос */
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => 'select *');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '  from (select D.*,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.SQLROWNUM() || ' NROW');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '          from (select I.CODE SINDOC,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       AZ.AZS_NUMBER SSTORE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       least(H.MIN_RESTPLAN,H.MIN_RESTFACT) NSALE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       H.RESTFACT NRESTFACT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       H.RESERV NRESERV,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       case coalesce(GRP.NMEASTYPE, 0)');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                         when 0 then MU1.MEAS_MNEMO');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                         when 1 then MU2.MEAS_MNEMO');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                         when 2 then MU3.MEAS_MNEMO');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       end SPRICEMEAS');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  from GOODSPARTIES G,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       NOMMODIF MF,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       DICNOMNS NOM left outer join DICMUNTS MU2 on NOM.UMEAS_ALT = MU2.RN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       GOODSSUPPLYHIST H left outer join NOMNMODIFPACK PAC on H.NOMNMODIFPACK = PAC.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       left outer join NOMNPACK NPAC on PAC.NOMENPACK = NPAC.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       left outer join DICMUNTS MU3 on NPAC.UMEAS = MU3.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       left outer join V_GOODSSUPPLY_REGPRICE GRP on H.RN = GRP.NGOODSSUPPLYHIST,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       INCOMDOC I,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       GOODSSUPPLY S,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       DICMUNTS MU1,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       AZSAZSLISTMT AZ');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                 where G.COMPANY = :NCOMPANY');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and G.NOMMODIF = MF.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and NOM.RN = MF.PRN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and NOM.RN = :NNOMENCLATURE');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and I.RN = G.INDOC');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and S.PRN = G.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and (((:NSTORAGE is not null) and (S.STORE = :NSTORAGE)) or ((:NSTORAGE_IN is not null) and (S.STORE = :NSTORAGE_IN)))');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and H.PRN = S.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and AZ.RN = S.STORE');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and H.DATE_FROM <= :DDATE');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and (H.DATE_TO >= :DDATE or H.DATE_TO is null)');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and NOM.UMEAS_MAIN = MU1.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and H.RESTFACT <> ' || PKG_SQL_BUILD.WRAP_NUM(NVALUE => 0));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and exists (select ' || PKG_SQL_BUILD.SET_HINT(SHINT => 'INDEX(UP I_USERPRIV_JUR_PERS_ROLEID)') || ' null');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 from USERPRIV UP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                where UP.JUR_PERS = G.JUR_PERS');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'GoodsParties'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.ROLEID in (select ' || PKG_SQL_BUILD.SET_HINT(SHINT => 'INDEX(UR I_USERROLES_AUTHID_FK)') || ' UR.ROLEID');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                      from USERROLES UR');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                     where UR.AUTHID = UTILIZER())');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                union all');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               select ' || PKG_SQL_BUILD.SET_HINT(SHINT => 'INDEX(UP I_USERPRIV_JUR_PERS_AUTHID)') || ' null');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 from USERPRIV UP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                where UP.JUR_PERS = G.JUR_PERS');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'GoodsParties'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.AUTHID   = UTILIZER())');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                %ORDER_BY%) D) F');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => ' where F.NROW between :NROW_FROM and :NROW_TO');
      /* Учтём сортировки */
      PKG_P8PANELS_VISUAL.TORDERS_SET_QUERY(RDATA_GRID => RDG, RORDERS => RO, SPATTERN => '%ORDER_BY%', CSQL => CSQL);
      /* Разбираем его */
      ICURSOR := PKG_SQL_DML.OPEN_CURSOR(SWHAT => 'SELECT');
      PKG_SQL_DML.PARSE(ICURSOR => ICURSOR, SQUERY => CSQL);
      /* Делаем подстановку параметров */
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NCOMPANY', NVALUE => NCOMPANY);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_FROM', NVALUE => NROW_FROM);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_TO', NVALUE => NROW_TO);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NNOMENCLATURE', NVALUE => NNOMENCLATURE);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NSTORAGE', NVALUE => NSTORAGE);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NSTORAGE_IN', NVALUE => NSTORAGE_IN);
      PKG_SQL_DML.BIND_VARIABLE_DATE(ICURSOR => ICURSOR, SNAME => 'DDATE', DVALUE => DDATE);
      /* Описываем структуру записи курсора */
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 1);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 2);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 3);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 4);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 5);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 6);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 7);
      /* Делаем выборку */
      if (PKG_SQL_DML.EXECUTE(ICURSOR => ICURSOR) = 0) then
        null;
      end if;
      /* Обходим выбранные записи */
      while (PKG_SQL_DML.FETCH_ROWS(ICURSOR => ICURSOR) > 0)
      loop
        /* Добавляем колонки с данными */
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SINDOC',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 1,
                                              BCLEAR    => true);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SSTORE', ICURSOR => ICURSOR, NPOSITION => 2);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW => RDG_ROW, SNAME => 'NSALE', ICURSOR => ICURSOR, NPOSITION => 3);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NRESTFACT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 4);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW => RDG_ROW, SNAME => 'NRESERV', ICURSOR => ICURSOR, NPOSITION => 5);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SPRICEMEAS',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 6);
        /* Добавляем строку в таблицу */
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW);
      end loop;
    exception
      when others then
        PKG_SQL_DML.CLOSE_CURSOR(ICURSOR => ICURSOR);
        raise;
    end;
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TDATA_GRID_TO_XML(RDATA_GRID => RDG, NINCLUDE_DEF => NINCLUDE_DEF);
  end GOODSPARTIES_DG_GET;

  /* Получение таблицы маршрутных листов, связанных со спецификацией плана (по детали) */
  procedure FCROUTLST_DG_BY_DTL
  (
    NFCPRODPLANSP           in number,                             -- Рег. номер связанной спецификации плана
    NPAGE_NUMBER            in number,                             -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,                             -- Количество записей на странице (0 - все)
    CORDERS                 in clob,                               -- Сортировки
    NINCLUDE_DEF            in number,                             -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob                               -- Сериализованная таблица данных
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
    RO                      PKG_P8PANELS_VISUAL.TORDERS;           -- Сортировки
    RDG                     PKG_P8PANELS_VISUAL.TDATA_GRID;        -- Описание таблицы
    RDG_ROW                 PKG_P8PANELS_VISUAL.TROW;              -- Строка таблицы
    NROW_FROM               PKG_STD.TREF;                          -- Номер строки с
    NROW_TO                 PKG_STD.TREF;                          -- Номер строки по
    CSQL                    clob;                                  -- Буфер для запроса
    ICURSOR                 integer;                               -- Курсор для исполнения запроса
  begin
    /* Читем сортировки */
    RO := PKG_P8PANELS_VISUAL.TORDERS_FROM_XML(CORDERS => CORDERS);
    /* Преобразуем номер и размер страницы в номер строк с и по */
    PKG_P8PANELS_VISUAL.UTL_ROWS_LIMITS_CALC(NPAGE_NUMBER => NPAGE_NUMBER,
                                             NPAGE_SIZE   => NPAGE_SIZE,
                                             NROW_FROM    => NROW_FROM,
                                             NROW_TO      => NROW_TO);
    /* Инициализируем таблицу данных */
    RDG := PKG_P8PANELS_VISUAL.TDATA_GRID_MAKE();
    /* Описываем колонки таблицы данных */
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NRN',
                                               SCAPTION   => 'Рег. номер',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SDOCPREF',
                                               SCAPTION   => 'Префикс',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SDOCNUMB',
                                               SCAPTION   => 'Номер',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DEXEC_DATE',
                                               SCAPTION   => 'Дата запуска',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SMATRES_PLAN_NOMEN',
                                               SCAPTION   => 'Номенклатура основного материала',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SMATRES_PLAN_NAME',
                                               SCAPTION   => 'Наименование основного материала',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NQUANT',
                                               SCAPTION   => 'Количество запуска',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NQUANT_PLAN',
                                               SCAPTION   => 'Выдать по норме',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    /* Обходим данные */
    begin
      /* Добавляем подсказку совместимости */
      CSQL := PKG_SQL_BUILD.COMPATIBLE(SSQL => CSQL);
      /* Формируем запрос */
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => 'select *');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '  from (select D.*,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.SQLROWNUM() || ' NROW');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '          from (select T.RN NRN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.DOCPREF SDOCPREF,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.DOCNUMB SDOCNUMB,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.EXEC_DATE DEXEC_DATE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       (select NM2.NOMEN_CODE from DICNOMNS NM2 where F3.NOMENCLATURE = NM2.RN) SMATRES_PLAN_NOMEN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       F3."NAME" SMATRES_PLAN_NAME,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.QUANT NQUANT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.QUANT_PLAN NQUANT_PLAN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  from FCROUTLST T');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       left outer join FCMATRESOURCE F3 on T.MATRES_PLAN = F3.RN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       DOCLINKS DL');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                 where DL.IN_DOCUMENT = :NFCPRODPLANSP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and DL.IN_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostProductPlansSpecs'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and DL.OUT_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostRouteLists'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T.RN = DL.OUT_DOCUMENT');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T.COMPANY = :NCOMPANY');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T."STATE" = ' || PKG_SQL_BUILD.WRAP_NUM(NVALUE => 0));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and exists (select ' || PKG_SQL_BUILD.SET_HINT(SHINT => 'INDEX(UP I_USERPRIV_CATALOG_ROLEID)') || ' null');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 from USERPRIV UP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                where UP."CATALOG" = T.CRN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.ROLEID in (select ' || PKG_SQL_BUILD.SET_HINT(SHINT => 'INDEX(UR I_USERROLES_AUTHID_FK)') || ' UR.ROLEID');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                      from USERROLES UR');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                     where UR.AUTHID = UTILIZER())');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                union all');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               select ' || PKG_SQL_BUILD.SET_HINT(SHINT => 'INDEX(UP I_USERPRIV_CATALOG_AUTHID)') || ' null');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 from USERPRIV UP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                where UP."CATALOG" = T.CRN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.AUTHID  = UTILIZER())');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and exists (select ' || PKG_SQL_BUILD.SET_HINT(SHINT => 'INDEX(UP I_USERPRIV_JUR_PERS_ROLEID)') || ' null');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 from USERPRIV UP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                where UP.JUR_PERS = T.JUR_PERS');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostRouteLists'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.ROLEID in (select ' || PKG_SQL_BUILD.SET_HINT(SHINT => 'INDEX(UR I_USERROLES_AUTHID_FK)') || ' UR.ROLEID');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                      from USERROLES UR');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                     where UR.AUTHID = UTILIZER())');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                union all');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               select ' || PKG_SQL_BUILD.SET_HINT(SHINT => 'INDEX(UP I_USERPRIV_JUR_PERS_AUTHID)') || ' null');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 from USERPRIV UP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                where UP.JUR_PERS = T.JUR_PERS');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostRouteLists'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.AUTHID = UTILIZER())');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                %ORDER_BY%) D) F');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => ' where F.NROW between :NROW_FROM and :NROW_TO');
      /* Учтём сортировки */
      PKG_P8PANELS_VISUAL.TORDERS_SET_QUERY(RDATA_GRID => RDG, RORDERS => RO, SPATTERN => '%ORDER_BY%', CSQL => CSQL);
      /* Разбираем его */
      ICURSOR := PKG_SQL_DML.OPEN_CURSOR(SWHAT => 'SELECT');
      PKG_SQL_DML.PARSE(ICURSOR => ICURSOR, SQUERY => CSQL);
      /* Делаем подстановку параметров */
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NCOMPANY', NVALUE => NCOMPANY);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_FROM', NVALUE => NROW_FROM);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_TO', NVALUE => NROW_TO);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NFCPRODPLANSP', NVALUE => NFCPRODPLANSP);
      /* Описываем структуру записи курсора */
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 1);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 2);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 3);
      PKG_SQL_DML.DEFINE_COLUMN_DATE(ICURSOR => ICURSOR, IPOSITION => 4);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 5);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 6);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 7);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 8);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 9);
      /* Делаем выборку */
      if (PKG_SQL_DML.EXECUTE(ICURSOR => ICURSOR) = 0) then
        null;
      end if;
      /* Обходим выбранные записи */
      while (PKG_SQL_DML.FETCH_ROWS(ICURSOR => ICURSOR) > 0)
      loop
        /* Добавляем колонки с данными */
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NRN',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 1,
                                              BCLEAR    => true);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SDOCPREF',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 2);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SDOCNUMB', ICURSOR => ICURSOR, NPOSITION => 3);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLD(RROW      => RDG_ROW,
                                              SNAME     => 'DEXEC_DATE',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 4);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SMATRES_PLAN_NOMEN',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 5);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SMATRES_PLAN_NAME',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 6);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NQUANT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 7);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NQUANT_PLAN',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 8);
        /* Добавляем строку в таблицу */
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW);
      end loop;
    exception
      when others then
        PKG_SQL_DML.CLOSE_CURSOR(ICURSOR => ICURSOR);
        raise;
    end;
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TDATA_GRID_TO_XML(RDATA_GRID => RDG, NINCLUDE_DEF => NINCLUDE_DEF);
  end FCROUTLST_DG_BY_DTL;

  /* Получение таблицы маршрутных листов, связанных со спецификацией плана (по изделию) */
  procedure FCROUTLST_DG_BY_PRDCT
  (
    NFCPRODPLANSP           in number,                             -- Рег. номер связанной спецификации плана
    NPAGE_NUMBER            in number,                             -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,                             -- Количество записей на странице (0 - все)
    CORDERS                 in clob,                               -- Сортировки
    NINCLUDE_DEF            in number,                             -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob                               -- Сериализованная таблица данных
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
    RO                      PKG_P8PANELS_VISUAL.TORDERS;           -- Сортировки
    RDG                     PKG_P8PANELS_VISUAL.TDATA_GRID;        -- Описание таблицы
    RDG_ROW                 PKG_P8PANELS_VISUAL.TROW;              -- Строка таблицы
    NROW_FROM               PKG_STD.TREF;                          -- Номер строки с
    NROW_TO                 PKG_STD.TREF;                          -- Номер строки по
    CSQL                    clob;                                  -- Буфер для запроса
    ICURSOR                 integer;                               -- Курсор для исполнения запроса
  begin
    /* Читем сортировки */
    RO := PKG_P8PANELS_VISUAL.TORDERS_FROM_XML(CORDERS => CORDERS);
    /* Преобразуем номер и размер страницы в номер строк с и по */
    PKG_P8PANELS_VISUAL.UTL_ROWS_LIMITS_CALC(NPAGE_NUMBER => NPAGE_NUMBER,
                                             NPAGE_SIZE   => NPAGE_SIZE,
                                             NROW_FROM    => NROW_FROM,
                                             NROW_TO      => NROW_TO);
    /* Инициализируем таблицу данных */
    RDG := PKG_P8PANELS_VISUAL.TDATA_GRID_MAKE();
    /* Описываем колонки таблицы данных */
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NRN',
                                               SCAPTION   => 'Рег. номер',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SDOCPREF',
                                               SCAPTION   => 'Префикс',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SDOCNUMB',
                                               SCAPTION   => 'Номер',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DEXEC_DATE',
                                               SCAPTION   => 'Дата запуска',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NQUANT',
                                               SCAPTION   => 'Количество запуска',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DREL_DATE',
                                               SCAPTION   => 'Дата выпуска',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NREL_QUANT',
                                               SCAPTION   => 'Количество выпуска',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    /* Обходим данные */
    begin
      /* Добавляем подсказку совместимости */
      CSQL := PKG_SQL_BUILD.COMPATIBLE(SSQL => CSQL);
      /* Формируем запрос */
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => 'select *');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '  from (select D.*,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.SQLROWNUM() || ' NROW');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '          from (select T.RN        NRN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.DOCPREF   SDOCPREF,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.DOCNUMB   SDOCNUMB,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.EXEC_DATE DEXEC_DATE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.QUANT     NQUANT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.REL_DATE  DREL_DATE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.REL_QUANT NREL_QUANT');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  from FCROUTLST T,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       DOCLINKS DL');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                 where DL.IN_DOCUMENT = :NFCPRODPLANSP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and DL.IN_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostProductPlansSpecs'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and DL.OUT_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostRouteLists'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T.RN = DL.OUT_DOCUMENT');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T.COMPANY = :NCOMPANY');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T."STATE" = ' || PKG_SQL_BUILD.WRAP_NUM(NVALUE => 0));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and exists (select ' || PKG_SQL_BUILD.SET_HINT(SHINT => 'INDEX(UP I_USERPRIV_CATALOG_ROLEID)') || ' null');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 from USERPRIV UP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                where UP."CATALOG" = T.CRN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.ROLEID in (select ' || PKG_SQL_BUILD.SET_HINT(SHINT => 'INDEX(UR I_USERROLES_AUTHID_FK)') || ' UR.ROLEID');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                      from USERROLES UR');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                     where UR.AUTHID = UTILIZER())');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                union all');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               select ' || PKG_SQL_BUILD.SET_HINT(SHINT => 'INDEX(UP I_USERPRIV_CATALOG_AUTHID)') || ' null');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 from USERPRIV UP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                where UP."CATALOG" = T.CRN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.AUTHID  = UTILIZER())');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and exists (select ' || PKG_SQL_BUILD.SET_HINT(SHINT => 'INDEX(UP I_USERPRIV_JUR_PERS_ROLEID)') || ' null');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 from USERPRIV UP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                where UP.JUR_PERS = T.JUR_PERS');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostRouteLists'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.ROLEID in (select ' || PKG_SQL_BUILD.SET_HINT(SHINT => 'INDEX(UR I_USERROLES_AUTHID_FK)') || ' UR.ROLEID');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                      from USERROLES UR');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                     where UR.AUTHID = UTILIZER())');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                union all');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               select ' || PKG_SQL_BUILD.SET_HINT(SHINT => 'INDEX(UP I_USERPRIV_JUR_PERS_AUTHID)') || ' null');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 from USERPRIV UP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                where UP.JUR_PERS = T.JUR_PERS');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostRouteLists'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.AUTHID = UTILIZER())');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                %ORDER_BY%) D) F');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => ' where F.NROW between :NROW_FROM and :NROW_TO');
      /* Учтём сортировки */
      PKG_P8PANELS_VISUAL.TORDERS_SET_QUERY(RDATA_GRID => RDG, RORDERS => RO, SPATTERN => '%ORDER_BY%', CSQL => CSQL);
      /* Разбираем его */
      ICURSOR := PKG_SQL_DML.OPEN_CURSOR(SWHAT => 'SELECT');
      PKG_SQL_DML.PARSE(ICURSOR => ICURSOR, SQUERY => CSQL);
      /* Делаем подстановку параметров */
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NCOMPANY', NVALUE => NCOMPANY);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_FROM', NVALUE => NROW_FROM);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_TO', NVALUE => NROW_TO);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NFCPRODPLANSP', NVALUE => NFCPRODPLANSP);
      /* Описываем структуру записи курсора */
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 1);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 2);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 3);
      PKG_SQL_DML.DEFINE_COLUMN_DATE(ICURSOR => ICURSOR, IPOSITION => 4);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 5);
      PKG_SQL_DML.DEFINE_COLUMN_DATE(ICURSOR => ICURSOR, IPOSITION => 6);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 7);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 8);
      /* Делаем выборку */
      if (PKG_SQL_DML.EXECUTE(ICURSOR => ICURSOR) = 0) then
        null;
      end if;
      /* Обходим выбранные записи */
      while (PKG_SQL_DML.FETCH_ROWS(ICURSOR => ICURSOR) > 0)
      loop
        /* Добавляем колонки с данными */
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NRN',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 1,
                                              BCLEAR    => true);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SDOCPREF',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 2);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SDOCNUMB', ICURSOR => ICURSOR, NPOSITION => 3);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLD(RROW      => RDG_ROW,
                                              SNAME     => 'DEXEC_DATE',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 4);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NQUANT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 5);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLD(RROW      => RDG_ROW,
                                              SNAME     => 'DREL_DATE',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 6);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NREL_QUANT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 7);
        /* Добавляем строку в таблицу */
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW);
      end loop;
    exception
      when others then
        PKG_SQL_DML.CLOSE_CURSOR(ICURSOR => ICURSOR);
        raise;
    end;
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TDATA_GRID_TO_XML(RDATA_GRID => RDG, NINCLUDE_DEF => NINCLUDE_DEF);
  end FCROUTLST_DG_BY_PRDCT;

  /* Получение таблицы маршрутных листов, связанных со спецификацией плана (для приходов) */
  procedure FCROUTLST_DG_BY_DEPS
  (
    NFCPRODPLANSP           in number,                             -- Рег. номер связанной спецификации плана
    NPAGE_NUMBER            in number,                             -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,                             -- Количество записей на странице (0 - все)
    CORDERS                 in clob,                               -- Сортировки
    NINCLUDE_DEF            in number,                             -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob                               -- Сериализованная таблица данных
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
    RO                      PKG_P8PANELS_VISUAL.TORDERS;           -- Сортировки
    RDG                     PKG_P8PANELS_VISUAL.TDATA_GRID;        -- Описание таблицы
    RDG_ROW                 PKG_P8PANELS_VISUAL.TROW;              -- Строка таблицы
    NROW_FROM               PKG_STD.TREF;                          -- Номер строки с
    NROW_TO                 PKG_STD.TREF;                          -- Номер строки по
    CSQL                    clob;                                  -- Буфер для запроса
    ICURSOR                 integer;                               -- Курсор для исполнения запроса
  begin
    /* Читем сортировки */
    RO := PKG_P8PANELS_VISUAL.TORDERS_FROM_XML(CORDERS => CORDERS);
    /* Преобразуем номер и размер страницы в номер строк с и по */
    PKG_P8PANELS_VISUAL.UTL_ROWS_LIMITS_CALC(NPAGE_NUMBER => NPAGE_NUMBER,
                                             NPAGE_SIZE   => NPAGE_SIZE,
                                             NROW_FROM    => NROW_FROM,
                                             NROW_TO      => NROW_TO);
    /* Инициализируем таблицу данных */
    RDG := PKG_P8PANELS_VISUAL.TDATA_GRID_MAKE();
    /* Описываем колонки таблицы данных */
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NRN',
                                               SCAPTION   => 'Рег. номер',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SDOCPREF',
                                               SCAPTION   => 'Префикс',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SDOCNUMB',
                                               SCAPTION   => 'Номер',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DEXEC_DATE',
                                               SCAPTION   => 'Дата запуска',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NQUANT',
                                               SCAPTION   => 'Количество запуска',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DREL_DATE',
                                               SCAPTION   => 'Дата выпуска',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NREL_QUANT',
                                               SCAPTION   => 'Количество выпуска',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NREL_QUANT',
                                               SCAPTION   => 'Количество выпуска',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NQUANT_FACT',
                                               SCAPTION   => 'Сдано',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NPROCENT',
                                               SCAPTION   => '% готовности',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    /* Обходим данные */
    begin
      /* Добавляем подсказку совместимости */
      CSQL := PKG_SQL_BUILD.COMPATIBLE(SSQL => CSQL);
      /* Формируем запрос */
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => 'select *');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '  from (select D.*,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.SQLROWNUM() || ' NROW');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '          from (select P.NRN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.SDOCPREF,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.SDOCNUMB,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.DEXEC_DATE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.NQUANT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.DREL_DATE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.NREL_QUANT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.NQUANT_FACT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       case when (P.NT_SHT_PLAN <> 0) then ROUND(P.NLABOUR_FACT / P.NT_SHT_PLAN * 100, 3) else 0 end NPROCENT');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  from (select T.RN        NRN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               T.DOCPREF   SDOCPREF,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               T.DOCNUMB   SDOCNUMB,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               T.EXEC_DATE DEXEC_DATE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               T.QUANT     NQUANT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               T.REL_DATE  DREL_DATE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               T.REL_QUANT NREL_QUANT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               (select SUM(SP.QUANT_FACT)');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  from DOCLINKS           D,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                       INCOMEFROMDEPSSPEC SP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 where D.IN_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostRouteLists'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                       and D.IN_DOCUMENT = T.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                       and D.OUT_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'IncomFromDeps'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                       and SP.PRN = D.OUT_DOCUMENT) NQUANT_FACT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               (select SUM(SP.LABOUR_FACT)');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  from FCROUTLSTSP SP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 where SP.PRN = T.RN) NLABOUR_FACT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               (select SUM(SP.T_SHT_PLAN)');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  from FCROUTLSTSP SP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 where SP.PRN = T.RN) NT_SHT_PLAN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                          from FCROUTLST T,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               DOCLINKS DL');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                         where DL.IN_DOCUMENT = :NFCPRODPLANSP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and DL.IN_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostProductPlansSpecs'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and DL.OUT_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostRouteLists'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and T.RN = DL.OUT_DOCUMENT');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and T.COMPANY = :NCOMPANY');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and T."STATE" = ' || PKG_SQL_BUILD.WRAP_NUM(NVALUE => 1));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and exists (select ' || PKG_SQL_BUILD.SET_HINT(SHINT =>  'INDEX(UP I_USERPRIV_CATALOG_ROLEID)') || ' null');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                         from USERPRIV UP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                        where UP."CATALOG" = T.CRN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                          and UP.ROLEID in (select ' || PKG_SQL_BUILD.SET_HINT(SHINT =>  'INDEX(UR I_USERROLES_AUTHID_FK)') || ' UR.ROLEID');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                              from USERROLES UR');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                             where UR.AUTHID = UTILIZER())');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                        union all');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                       select ' || PKG_SQL_BUILD.SET_HINT(SHINT =>  'INDEX(UP I_USERPRIV_CATALOG_AUTHID)') || ' null');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                         from USERPRIV UP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                        where UP."CATALOG" = T.CRN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                          and UP.AUTHID  = UTILIZER())');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and exists (select ' || PKG_SQL_BUILD.SET_HINT(SHINT =>  'INDEX(UP I_USERPRIV_JUR_PERS_ROLEID)') || ' null');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                         from USERPRIV UP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                        where UP.JUR_PERS = T.JUR_PERS');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                          and UP.UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostRouteLists'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                          and UP.ROLEID in (select ' || PKG_SQL_BUILD.SET_HINT(SHINT =>  'INDEX(UR I_USERROLES_AUTHID_FK)') || ' UR.ROLEID');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                              from USERROLES UR');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                             where UR.AUTHID = UTILIZER())');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                        union all');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                       select ' || PKG_SQL_BUILD.SET_HINT(SHINT =>  'INDEX(UP I_USERPRIV_JUR_PERS_AUTHID)') || ' null');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                         from USERPRIV UP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                        where UP.JUR_PERS = T.JUR_PERS');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                          and UP.UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostRouteLists'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                          and UP.AUTHID = UTILIZER())) P');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                %ORDER_BY%) D) F');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => ' where F.NROW between :NROW_FROM and :NROW_TO');
      /* Учтём сортировки */
      PKG_P8PANELS_VISUAL.TORDERS_SET_QUERY(RDATA_GRID => RDG, RORDERS => RO, SPATTERN => '%ORDER_BY%', CSQL => CSQL);
      /* Разбираем его */
      ICURSOR := PKG_SQL_DML.OPEN_CURSOR(SWHAT => 'SELECT');
      PKG_SQL_DML.PARSE(ICURSOR => ICURSOR, SQUERY => CSQL);
      /* Делаем подстановку параметров */
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NCOMPANY', NVALUE => NCOMPANY);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_FROM', NVALUE => NROW_FROM);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_TO', NVALUE => NROW_TO);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NFCPRODPLANSP', NVALUE => NFCPRODPLANSP);
      /* Описываем структуру записи курсора */
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 1);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 2);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 3);
      PKG_SQL_DML.DEFINE_COLUMN_DATE(ICURSOR => ICURSOR, IPOSITION => 4);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 5);
      PKG_SQL_DML.DEFINE_COLUMN_DATE(ICURSOR => ICURSOR, IPOSITION => 6);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 7);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 8);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 9);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 10);
      /* Делаем выборку */
      if (PKG_SQL_DML.EXECUTE(ICURSOR => ICURSOR) = 0) then
        null;
      end if;
      /* Обходим выбранные записи */
      while (PKG_SQL_DML.FETCH_ROWS(ICURSOR => ICURSOR) > 0)
      loop
        /* Добавляем колонки с данными */
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NRN',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 1,
                                              BCLEAR    => true);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SDOCPREF', ICURSOR => ICURSOR, NPOSITION => 2);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SDOCNUMB', ICURSOR => ICURSOR, NPOSITION => 3);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLD(RROW      => RDG_ROW,
                                              SNAME     => 'DEXEC_DATE',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 4);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW => RDG_ROW, SNAME => 'NQUANT', ICURSOR => ICURSOR, NPOSITION => 5);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLD(RROW      => RDG_ROW,
                                              SNAME     => 'DREL_DATE',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 6);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NREL_QUANT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 7);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NQUANT_FACT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 8);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW => RDG_ROW, SNAME => 'NPROCENT', ICURSOR => ICURSOR, NPOSITION => 9);
        /* Добавляем строку в таблицу */
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW);
      end loop;
    exception
      when others then
        PKG_SQL_DML.CLOSE_CURSOR(ICURSOR => ICURSOR);
        raise;
    end;
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TDATA_GRID_TO_XML(RDATA_GRID => RDG, NINCLUDE_DEF => NINCLUDE_DEF);
  end FCROUTLST_DG_BY_DEPS;

  /* Получение таблицы маршрутных листов, связанных со спецификацией плана с учетом типа */
  procedure FCROUTLST_DG_GET
  (
    NFCPRODPLANSP           in number,  -- Рег. номер связанной спецификации плана
    NTYPE                   in number,  -- Тип спецификации плана (0 - Деталь, 1 - Изделие/сборочная единица, 3/4 - ПиП)
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    CORDERS                 in clob,    -- Сортировки
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
  )
  is
  begin
    /* Выбираем сборку таблицы, исходя из типа спецификации плана */
    case
      /* Деталь */
      when (NTYPE = 0) then
        /* Получаем таблицу по детали */
        FCROUTLST_DG_BY_DTL(NFCPRODPLANSP => NFCPRODPLANSP,
                            NPAGE_NUMBER  => NPAGE_NUMBER,
                            NPAGE_SIZE    => NPAGE_SIZE,
                            CORDERS       => CORDERS,
                            NINCLUDE_DEF  => NINCLUDE_DEF,
                            COUT          => COUT);
      /* Изделие/сборочная единица */
      when (NTYPE = 1) then
        /* Получаем таблицу по изделию */
        FCROUTLST_DG_BY_PRDCT(NFCPRODPLANSP => NFCPRODPLANSP,
                              NPAGE_NUMBER  => NPAGE_NUMBER,
                              NPAGE_SIZE    => NPAGE_SIZE,
                              CORDERS       => CORDERS,
                              NINCLUDE_DEF  => NINCLUDE_DEF,
                              COUT          => COUT);
      /* Для приходов из подразделений */
      when ((NTYPE = 3) or (NTYPE = 4)) then
        /* Получаем таблицу по приходу */
        FCROUTLST_DG_BY_DEPS(NFCPRODPLANSP => NFCPRODPLANSP,
                             NPAGE_NUMBER  => NPAGE_NUMBER,
                             NPAGE_SIZE    => NPAGE_SIZE,
                             CORDERS       => CORDERS,
                             NINCLUDE_DEF  => NINCLUDE_DEF,
                             COUT          => COUT);
      else
        P_EXCEPTION(0,
                    'Не определен тип получения таблицы маршрутных листов.');
    end case;
  end FCROUTLST_DG_GET;
  
  /* Получение списка спецификаций планов и отчетов производства изделий для диаграммы Ганта */
  procedure FCPRODPLANSP_GET
  (
    NCRN                    in number,                             -- Рег. номер каталога
    NLEVEL                  in number := null,                     -- Уровень отбора
    SSORT_FIELD             in varchar2 := 'DREP_DATE_TO',         -- Поле сортировки
    COUT                    out clob,                              -- Список задач
    NMAX_LEVEL              out number                             -- Максимальный уровень иерархии
  )
  is
    /* Переменные */
    RG                      PKG_P8PANELS_VISUAL.TGANTT;            -- Описание диаграммы Ганта
    RGT                     PKG_P8PANELS_VISUAL.TGANTT_TASK;       -- Описание задачи для диаграммы
    BREAD_ONLY_DATES        boolean := false;                      -- Флаг доступности дат проекта только для чтения
    STASK_BG_COLOR          PKG_STD.TSTRING;                       -- Цвет заливки задачи
    STASK_TEXT_COLOR        PKG_STD.TSTRING;                       -- Цвет текста задачи
    STASK_BG_PROGRESS_COLOR PKG_STD.TSTRING;                       -- Цвет заливки прогресса задачи
    NTASK_PROGRESS          PKG_STD.TNUMBER;                       -- Прогресс выполнения задачи
    DDATE_FROM              PKG_STD.TLDATE;                        -- Дата запуска спецификации
    DDATE_TO                PKG_STD.TLDATE;                        -- Дата выпуска спецификации
    STASK_CAPTION           PKG_STD.TSTRING;                       -- Описание задачи в Ганте
    NTYPE                   PKG_STD.TNUMBER;                       -- Тип задачи (0/1 - для "Дата выпуска", 2/3/4 - для "Дата выпуска")
    SDETAIL_LIST            PKG_STD.TSTRING;                       -- Ссылки на детализацию
    SPLAN_TITLE             PKG_STD.TSTRING;                       -- Заголовок плана
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
    NTASK_CLASS             PKG_STD.TNUMBER;                       -- Класс задачи

    /* Объединение значений в строковое представление */
    function MAKE_INFO
    (
      SPROD_ORDER           in varchar2,     -- Заказ
      SNOMEN_NAME           in varchar2,     -- Наименование номенклатуры
      SSUBDIV_DLVR          in varchar2,     -- Сдающее подразделение
      NMAIN_QUANT           in number        -- Выпуск
    ) return                varchar2         -- Описание задачи в Ганте
    is
      SRESULT               PKG_STD.TSTRING; -- Описание задачи в Ганте
    begin
      /* Соединяем информацию */
      SRESULT := STRCOMBINE(SPROD_ORDER, SNOMEN_NAME, ', ');
      SRESULT := STRCOMBINE(SRESULT, SSUBDIV_DLVR, ', ');
      SRESULT := STRCOMBINE(SRESULT, TO_CHAR(NMAIN_QUANT), ', ');
      /* Возвращаем результат */
      return SRESULT;
    end MAKE_INFO;

    /* Считывание максимального уровня иерархии плана по каталогу */
    function PRODPLAN_MAX_LEVEL_GET
    (
      NCRN                    in number        -- Рег. номер каталога планов
    ) return                  number           -- Максимальный уровень иерархии
    is
      NRESULT                 PKG_STD.TNUMBER; -- Максимальный уровень иерархии
    begin
      /* Считываем максимальный уровень */
      begin
        select max(level)
          into NRESULT
          from (select T.RN,
                       T.UP_LEVEL
                  from FCPRODPLAN   P,
                       FCPRODPLANSP T,
                       FINSTATE     FS
                 where P.CRN = NCRN
                   and P.CATEGORY = NFCPRODPLAN_CATEGORY
                   and P.STATUS = NFCPRODPLAN_STATUS
                   and FS.RN = P.TYPE
                   and FS.CODE = SFCPRODPLAN_TYPE
                   and exists (select /*+ INDEX(UP I_USERPRIV_JUR_PERS_ROLEID) */
                         null
                          from USERPRIV UP
                         where UP.JUR_PERS = P.JUR_PERS
                           and UP.UNITCODE = 'CostProductPlans'
                           and UP.ROLEID in (select /*+ INDEX(UR I_USERROLES_AUTHID_FK) */
                                              UR.ROLEID
                                               from USERROLES UR
                                              where UR.AUTHID = UTILIZER())
                        union all
                        select /*+ INDEX(UP I_USERPRIV_JUR_PERS_AUTHID) */
                         null
                          from USERPRIV UP
                         where UP.JUR_PERS = P.JUR_PERS
                           and UP.UNITCODE = 'CostProductPlans'
                           and UP.AUTHID = UTILIZER())
                   and T.PRN = P.RN
                   and T.MAIN_QUANT > 0) TMP
        connect by prior TMP.RN = TMP.UP_LEVEL
         start with TMP.UP_LEVEL is null;
      exception
        when others then
          NRESULT := null;
      end;
      /* Возвращаем результат */
      return NRESULT;
    end PRODPLAN_MAX_LEVEL_GET;
  
    /* Определение дат спецификации плана */
    procedure FCPRODPLANSP_DATES_GET
    (
      DREP_DATE               in date,        -- Дата запуска спецификации
      DREP_DATE_TO            in date,        -- Дата выпуска спецификации
      DINCL_DATE              in date,        -- Дата включения в план спецификации
      DDATE_FROM              out date,       -- Итоговая дата запуска спецификации
      DDATE_TO                out date        -- Итоговая дата выпуска спецификации
    )
    is
    begin
      /* Если даты запуска и выпуска пусты */
      if ((DREP_DATE is null) and (DREP_DATE_TO is null)) then
        /* Указываем дату включения в план */
        DDATE_FROM := DINCL_DATE;
        DDATE_TO   := DINCL_DATE;
      else
        /* Указываем даты исходя из дат запуска/выпуска */
        DDATE_FROM := COALESCE(DREP_DATE, DREP_DATE_TO);
        DDATE_TO   := COALESCE(DREP_DATE_TO, DREP_DATE);
      end if;
    end FCPRODPLANSP_DATES_GET;

    /* Инициализация динамических атрибутов */
    procedure TASK_ATTRS_INIT
    (
      RG                    in out PKG_P8PANELS_VISUAL.TGANTT -- Описание диаграммы Ганта
    )
    is
    begin
      /* Добавим динамические атрибуты к спецификациям */
      PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_ATTR(RGANTT   => RG,
                                               SNAME    => STASK_ATTR_START_FACT,
                                               SCAPTION => 'Запущено');
      PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_ATTR(RGANTT   => RG,
                                               SNAME    => STASK_ATTR_MAIN_QUANT,
                                               SCAPTION => 'Количество план');
      PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_ATTR(RGANTT   => RG,
                                               SNAME    => STASK_ATTR_REL_FACT,
                                               SCAPTION => 'Количество сдано');
      PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_ATTR(RGANTT   => RG,
                                               SNAME    => STASK_ATTR_REP_DATE_TO,
                                               SCAPTION => 'Дата выпуска план');
      PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_ATTR(RGANTT   => RG,
                                               SNAME    => STASK_ATTR_DL,
                                               SCAPTION => 'Анализ отклонений');
      PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_ATTR(RGANTT => RG, SNAME => STASK_ATTR_TYPE, SCAPTION => 'Тип');
      PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_ATTR(RGANTT   => RG,
                                               SNAME    => STASK_ATTR_MEAS,
                                               SCAPTION => 'Единица измерения');
    end TASK_ATTRS_INIT;

    /* Заполнение значений динамических атрибутов */
    procedure TASK_ATTRS_FILL
    (
      RG                    in PKG_P8PANELS_VISUAL.TGANTT,                 -- Описание диаграммы Ганта
      RGT                   in out nocopy PKG_P8PANELS_VISUAL.TGANTT_TASK, -- Описание задачи для диаграммы
      NSTART_FACT           in number,                                     -- Запуск факт
      NMAIN_QUANT           in number,                                     -- Выпуск
      NREL_FACT             in number,                                     -- Выпуск факт
      DREP_DATE_TO          in date,                                       -- Дата выпуска
      NTYPE                 in number,                                     -- Тип (0 - Деталь, 1 - Изделие/сборочная единица)
      SDETAIL_LIST          in varchar2,                                   -- Ссылки на детализацию
      SMEAS                 in varchar2                                    -- Единица измерения
    )
    is
    begin
      /* Добавим доп. атрибуты */
      PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_ATTR_VAL(RGANTT => RG,
                                                   RTASK  => RGT,
                                                   SNAME  => STASK_ATTR_START_FACT,
                                                   SVALUE => TO_CHAR(NSTART_FACT),
                                                   BCLEAR => true);
      PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_ATTR_VAL(RGANTT => RG,
                                                   RTASK  => RGT,
                                                   SNAME  => STASK_ATTR_MAIN_QUANT,
                                                   SVALUE => TO_CHAR(NMAIN_QUANT));
      PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_ATTR_VAL(RGANTT => RG,
                                                   RTASK  => RGT,
                                                   SNAME  => STASK_ATTR_REL_FACT,
                                                   SVALUE => TO_CHAR(NREL_FACT));
      PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_ATTR_VAL(RGANTT => RG,
                                                   RTASK  => RGT,
                                                   SNAME  => STASK_ATTR_REP_DATE_TO,
                                                   SVALUE => TO_CHAR(DREP_DATE_TO, 'dd.mm.yyyy hh24:mi'));
      PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_ATTR_VAL(RGANTT => RG,
                                                   RTASK  => RGT,
                                                   SNAME  => STASK_ATTR_TYPE,
                                                   SVALUE => TO_CHAR(NTYPE));
      PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_ATTR_VAL(RGANTT => RG,
                                                   RTASK  => RGT,
                                                   SNAME  => STASK_ATTR_DL,
                                                   SVALUE => SDETAIL_LIST);
      PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_ATTR_VAL(RGANTT => RG,
                                                   RTASK  => RGT,
                                                   SNAME  => STASK_ATTR_MEAS,
                                                   SVALUE => SMEAS);
    end TASK_ATTRS_FILL;

    /* Инициализация цветов */
    procedure TASK_COLORS_INIT
    (
      RG                    in out PKG_P8PANELS_VISUAL.TGANTT -- Описание диаграммы Ганта
    )
    is
    begin
      /* Добавим описание цветов */
      PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_COLOR(RGANTT    => RG,
                                                SBG_COLOR => SBG_COLOR_RED,
                                                SDESC     => 'Для спецификаций планов и отчетов производства изделий с «Дефицит запуска» != 0 или ' ||
                                                             'не имеющих связей с разделами «Маршрутный лист» или «Приход из подразделения», а также «Дата запуска» меньше текущей.');
      PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_COLOR(RGANTT    => RG,
                                                SBG_COLOR => SBG_COLOR_YELLOW,
                                                SDESC     => 'Для спецификаций планов и отчетов производства изделий с «Дефицит запуска» = 0 и «Выпуск факт» = 0.');
      PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_COLOR(RGANTT      => RG,
                                                SBG_COLOR   => SBG_COLOR_GREEN,
                                                STEXT_COLOR => STEXT_COLOR_GREY,
                                                SDESC       => 'Для спецификаций планов и отчетов производства изделий с «Дефицит выпуска» = 0.');
      PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_COLOR(RGANTT             => RG,
                                                SBG_COLOR          => SBG_COLOR_GREEN,
                                                SBG_PROGRESS_COLOR => SBG_COLOR_YELLOW,
                                                STEXT_COLOR        => STEXT_COLOR_GREY,
                                                SDESC              => 'Для спецификаций планов и отчетов производства изделий с «Дефицит запуска» = 0 и «Выпуск факт» != 0. ');
      PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_COLOR(RGANTT      => RG,
                                                SBG_COLOR   => SBG_COLOR_BLACK,
                                                STEXT_COLOR => STEXT_COLOR_ORANGE,
                                                SDESC       => 'Для спецификаций планов и отчетов производства изделий с пустыми «Дата запуска» и «Дата выпуска» и не имеющих связей с разделами «Маршрутный лист» или «Приход из подразделения».');
      PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_COLOR(RGANTT    => RG,
                                                SBG_COLOR => SBG_COLOR_GREY,
                                                SDESC     => 'Для спецификаций планов и отчетов производства изделий не имеющих связей с разделами «Маршрутный лист» или «Приход из подразделения», а также «Дата запуска» больше текущей.');
    end TASK_COLORS_INIT;

    /* Опеределение класса задачи */
    function GET_TASK_CLASS
    (
      NDEFRESLIZ              in number,       -- Дефицит запуска
      NREL_FACT               in number,       -- Выпуск факт
      NDEFSTART               in number,       -- Дефицит выпуска
      DREP_DATE               in date,         -- Дата запуска спецификации
      DREP_DATE_TO            in date,         -- Дата выпуска спецификации
      NHAVE_LINK              in number := 0   -- Наличие связей с "Маршрутный лист" или "Приход из подразделения"
    ) return                  number           -- Класс задачи
    is
      NTASK_CLASS             PKG_STD.TNUMBER; -- Класс задачи
    begin
      /*
        Описание классов:
         0 - Без дефицита выпуска (последующий цвет "Зеленый")
         1 - С частичным дефицитом выпуска (последующий цвет "Желто-зелеый")
         2 - С полным дефицитом выпуска (последующий цвет "Желтый")
         3 - С дефицитом запуска или датой меньше текущей (последующий цвет "Красный")
         4 - Дата анализа еще не наступила (последующий цвет "Серый")
         5 - Задача без связи (последующий цвет "Черный")
      */
      /* Если одна из дат не указана */
      if ((DREP_DATE is null) or (DREP_DATE_TO is null)) then
        /* Если спецификация также не имеет связей */
        if (NHAVE_LINK = 0) then
          NTASK_CLASS := 5;
        end if;
      else
        /* Если нет связанных документов */
        if (NHAVE_LINK = 0) then
          /* Если дата запуска меньше текущей даты */
          if (DREP_DATE <= sysdate) then
            NTASK_CLASS := 3;
          end if;
          /* Если дата больше текущей даты */
          if (DREP_DATE > sysdate) then
            NTASK_CLASS := 4;
          end if;
        end if;
      end if;
      /* Если класс не определен */
      if (NTASK_CLASS is null) then
        /* Если дефицит запуска <> 0 */
        if (NDEFRESLIZ <> 0) then
          /* Если дефицит выпуска = 0 */
          if (NDEFSTART = 0) then
            NTASK_CLASS := 0;
          else
            NTASK_CLASS := 3;
          end if;
        else
          /* Если дефицит выпуска = 0 */
          if (NDEFSTART = 0) then
            NTASK_CLASS := 0;
          else
            /* Если дефицит запуска = 0 и выпуск факт = 0 */
            if ((NDEFRESLIZ = 0) and (NREL_FACT = 0)) then
              NTASK_CLASS := 2;
            end if;
            /* Если дефицит запуска = 0 и выпуск факт <> 0 */
            if ((NDEFRESLIZ = 0) and (NREL_FACT <> 0)) then
              NTASK_CLASS := 1;
            end if;
          end if;
        end if;
      end if;
      /* Возвращаем результат */
      return NTASK_CLASS;
    end GET_TASK_CLASS;

    /* Получение типа задачи */
    procedure GET_TASK_TYPE
    (
      NCOMPANY                in number,   -- Рег. номер организации
      SSORT_FIELD             in varchar2, -- Тип сортировки
      NFCPRODPLAN             in number,   -- Рег. номер плана
      NFCPRODPLANSP           in number,   -- Рег. номер спецификации плана
      NTASK_CLASS             in number,   -- Класс задачи
      NTYPE                   out number,  -- Тип задачи (0/1 - для "Дата выпуска", 2/3/4 - для "Дата выпуска")
      SDETAIL_LIST            out varchar2 -- Ссылки на детализацию
    )
    is
    begin
      /*
        Описание типов:
         0 - Маршрутные листы с развертыванием товарных запасов
         1 - Маршрутные листы с развертыванием комплектаций
         2 - Приход из подразделений
         3 - Приход из подразделений и маршрутные листы
         4 - Маршрутные листы
         null - Нет детализации
      */
      /* Исходим сортировка по "Дата запуска" */
      if (SSORT_FIELD = 'DREP_DATE') then
        /* Если цвет - красный */
        if (NTASK_CLASS = 3) then
          /* Проверяем деталь или изделие */
          begin
            select 1
              into NTYPE
              from DUAL
             where exists (select null
                      from FCPRODPLANSP SP
                     where SP.PRN = NFCPRODPLAN
                       and SP.UP_LEVEL = NFCPRODPLANSP);
          exception
            when others then
              NTYPE := 0;
          end;
          /* Проверяем наличие связей с маршрутными листами */
          if (LINK_FCROUTLST_CHECK(NCOMPANY => NCOMPANY, NFCPRODPLANSP => NFCPRODPLANSP, NSTATE => 0) = 0) then
            /* Указываем, что маршрутных листов нет */
            SDETAIL_LIST := 'Нет маршрутных листов';
            NTYPE        := null;
          else
            /* Указываем, что маршрутные листы есть */
            SDETAIL_LIST := 'Маршрутные листы';
          end if;
        else
          /* Не отображаем информацию о маршрутных листах */
          NTYPE        := null;
          SDETAIL_LIST := null;
        end if;
      else
        /* Исходим от класса */
        case
          /* Закрашен зеленым */
          when (NTASK_CLASS = 0) then
            /* Проверяем наличией связей с приходов из подразделений */
            if (LINK_INCOMEFROMDEPS_CHECK(NCOMPANY => NCOMPANY, NFCPRODPLANSP => NFCPRODPLANSP, NSTATE => 2) = 0) then
              /* Указываем, что приходов из подразделений нет */
              SDETAIL_LIST := 'Нет приходов из подразделений';
              NTYPE        := null;
            else
              /* Указываем, что приходы из подразделений есть */
              SDETAIL_LIST := 'Приход из подразделений';
              NTYPE        := 2;
            end if;
          /* Закрашен желто-зеленым */
          when (NTASK_CLASS = 1) then
            /* Проверяем наличией связей с приходов из подразделений */
            if (LINK_INCOMEFROMDEPS_CHECK(NCOMPANY => NCOMPANY, NFCPRODPLANSP => NFCPRODPLANSP) = 0) then
              /* Указываем, что приходов из подразделений нет */
              SDETAIL_LIST := 'Нет приходов из подразделений';
              NTYPE        := null;
            else
              /* Указываем, что приходы из подразделений есть */
              SDETAIL_LIST := 'Приход из подразделений';
              NTYPE        := 3;
            end if;
          /* Закрашен желтым или красным */
          when ((NTASK_CLASS = 2) or (NTASK_CLASS = 3)) then
            /* Проверяем наличие связей с маршрутными листами */
            if (LINK_FCROUTLST_CHECK(NCOMPANY => NCOMPANY, NFCPRODPLANSP => NFCPRODPLANSP, NSTATE => 1) = 0) then
              /* Указываем, что маршрутных листов нет */
              SDETAIL_LIST := 'Нет маршрутных листов';
              NTYPE        := null;
            else
              /* Указываем, что маршрутные листы есть */
              SDETAIL_LIST := 'Маршрутные листы';
              NTYPE        := 4;
            end if;
          /* Класс не поддерживается */
          else
            /* Для данных классов ничего не выводится */
            NTYPE        := null;
            SDETAIL_LIST := null;
        end case;
      end if;
    end GET_TASK_TYPE;

    /* Формирование цветовых характеристик для задачи */
    procedure GET_TASK_COLORS
    (
      NTASK_CLASS             in number,      -- Класс задачи
      STASK_BG_COLOR          out varchar2,   -- Цвет заливки спецификации
      STASK_BG_PROGRESS_COLOR out varchar2,   -- Цвет заливки прогресса спецификации
      STASK_TEXT_COLOR        in out varchar2 -- Цвет текста
    )
    is
    begin
      /* Исходим от класса задачи */
      case NTASK_CLASS
        /* Полностью зеленый */
        when 0 then
          STASK_BG_COLOR          := SBG_COLOR_GREEN;
          STASK_TEXT_COLOR        := STEXT_COLOR_GREY;
          STASK_BG_PROGRESS_COLOR := null;
        /* Частично зелёный, прогресс жёлтый */
        when 1 then
          STASK_BG_COLOR          := SBG_COLOR_GREEN;
          STASK_BG_PROGRESS_COLOR := SBG_COLOR_YELLOW;
          STASK_TEXT_COLOR        := STEXT_COLOR_GREY;
        /* Полностью жёлтый */
        when 2 then
          STASK_BG_COLOR          := SBG_COLOR_YELLOW;
          STASK_TEXT_COLOR        := null;
          STASK_BG_PROGRESS_COLOR := null;
        /* Полностью красный */
        when 3 then
          STASK_BG_COLOR          := SBG_COLOR_RED;
          STASK_TEXT_COLOR        := null;
          STASK_BG_PROGRESS_COLOR := null;
        /* Полностью серый */
        when 4 then
          STASK_BG_COLOR   := SBG_COLOR_GREY;
          STASK_TEXT_COLOR := null;
          STASK_BG_PROGRESS_COLOR := null;
        /* Полностью черный */
        when 5 then
          STASK_BG_COLOR   := SBG_COLOR_BLACK;
          STASK_TEXT_COLOR := STEXT_COLOR_ORANGE;
          STASK_BG_PROGRESS_COLOR := null;
        else
          /* Не определено */
          STASK_BG_COLOR   := null;
          STASK_TEXT_COLOR := null;
          STASK_BG_PROGRESS_COLOR := null;
      end case;
    end GET_TASK_COLORS;
  begin
    /* Определяем заголовок плана */
    FIND_ACATALOG_RN(NFLAG_SMART => 0,
                     NCOMPANY    => NCOMPANY,
                     NVERSION    => null,
                     SUNITCODE   => 'CostProductPlans',
                     NRN         => NCRN,
                     SNAME       => SPLAN_TITLE);
    /* Инициализируем диаграмму Ганта */
    RG := PKG_P8PANELS_VISUAL.TGANTT_MAKE(STITLE              => SPLAN_TITLE,
                                          NZOOM               => PKG_P8PANELS_VISUAL.NGANTT_ZOOM_DAY,
                                          BREAD_ONLY_DATES    => BREAD_ONLY_DATES,
                                          BREAD_ONLY_PROGRESS => true);
    /* Инициализируем динамические атрибуты к спецификациям */
    TASK_ATTRS_INIT(RG => RG);
    /* Инициализируем описания цветов */
    TASK_COLORS_INIT(RG => RG);
    /* Определяем максимальный уровень иерархии */
    NMAX_LEVEL := PRODPLAN_MAX_LEVEL_GET(NCRN => NCRN);
    /* Обходим данные */
    for C in (select TMP.*,
                     level NTASK_LEVEL
                from (select T.RN NRN,
                             T.PRN NPRN,
                             (select PORD.NUMB from FACEACC PORD where PORD.RN = T.PROD_ORDER) SPROD_ORDER,
                             T.REP_DATE DREP_DATE,
                             T.REP_DATE_TO DREP_DATE_TO,
                             T.INCL_DATE DINCL_DATE,
                             T.ROUTE SROUTE,
                             (FM.CODE || ', ' || FM.NAME) SNAME,
                             D.NOMEN_NAME SNOMEN_NAME,
                             T.START_FACT NSTART_FACT,
                             (T.QUANT_REST - T.START_FACT) NDEFRESLIZ,
                             T.REL_FACT NREL_FACT,
                             (T.MAIN_QUANT - T.REL_FACT) NDEFSTART,
                             T.MAIN_QUANT NMAIN_QUANT,
                             (select IDD.CODE from INS_DEPARTMENT IDD where IDD.RN = T.SUBDIV_DLVR) SSUBDIV_DLVR,
                             (select 1
                                from DUAL
                               where exists (select null
                                        from DOCLINKS L
                                       where L.IN_DOCUMENT = T.RN
                                         and L.IN_UNITCODE = 'CostProductPlansSpecs'
                                         and (L.OUT_UNITCODE = 'CostRouteLists' or L.OUT_UNITCODE = 'IncomFromDeps')
                                         and ROWNUM = 1)) NHAVE_LINK,
                             T.UP_LEVEL NUP_LEVEL,
                             case SSORT_FIELD
                               when 'DREP_DATE_TO' then
                                T.REP_DATE_TO
                               else
                                T.REP_DATE
                             end DORDER_DATE,
                             DM.MEAS_MNEMO SMEAS
                        from FCPRODPLAN    P,
                             FINSTATE      FS,
                             FCPRODPLANSP  T,
                             FCMATRESOURCE FM,
                             DICNOMNS      D,
                             DICMUNTS      DM
                       where P.CRN = NCRN
                         and P.CATEGORY = NFCPRODPLAN_CATEGORY
                         and P.STATUS = NFCPRODPLAN_STATUS
                         and FS.RN = P.TYPE
                         and FS.CODE = SFCPRODPLAN_TYPE
                         and exists
                       (select /*+ INDEX(UP I_USERPRIV_JUR_PERS_ROLEID) */
                               null
                                from USERPRIV UP
                               where UP.JUR_PERS = P.JUR_PERS
                                 and UP.UNITCODE = 'CostProductPlans'
                                 and UP.ROLEID in (select /*+ INDEX(UR I_USERROLES_AUTHID_FK) */
                                                    UR.ROLEID
                                                     from USERROLES UR
                                                    where UR.AUTHID = UTILIZER())
                              union all
                              select /*+ INDEX(UP I_USERPRIV_JUR_PERS_AUTHID) */
                               null
                                from USERPRIV UP
                               where UP.JUR_PERS = P.JUR_PERS
                                 and UP.UNITCODE = 'CostProductPlans'
                                 and UP.AUTHID = UTILIZER())
                         and T.PRN = P.RN
                         and T.MAIN_QUANT > 0
                         and ((T.REP_DATE is not null) or (T.REP_DATE_TO is not null) or (T.INCL_DATE is not null))
                         and FM.RN = T.MATRES
                         and D.RN = FM.NOMENCLATURE
                         and D.UMEAS_MAIN = DM.RN) TMP
               where ((NLEVEL is null) or ((NLEVEL is not null) and (level <= NLEVEL)))
              connect by prior TMP.NRN = TMP.NUP_LEVEL
               start with TMP.NUP_LEVEL is null
               order siblings by TMP.DORDER_DATE asc)
    loop
      /* Формируем описание задачи в Ганте */
      STASK_CAPTION := MAKE_INFO(SPROD_ORDER  => C.SPROD_ORDER,
                                 SNOMEN_NAME  => C.SNOMEN_NAME,
                                 SSUBDIV_DLVR => C.SSUBDIV_DLVR,
                                 NMAIN_QUANT  => C.NMAIN_QUANT);
      /* Определяем класс задачи */
      NTASK_CLASS := GET_TASK_CLASS(NDEFRESLIZ   => C.NDEFRESLIZ,
                                    NREL_FACT    => C.NREL_FACT,
                                    NDEFSTART    => C.NDEFSTART,
                                    DREP_DATE    => C.DREP_DATE,
                                    DREP_DATE_TO => C.DREP_DATE_TO,
                                    NHAVE_LINK   => COALESCE(C.NHAVE_LINK, 0));
      /* Инициализируем даты и цвет (если необходимо) */
      FCPRODPLANSP_DATES_GET(DREP_DATE    => C.DREP_DATE,
                             DREP_DATE_TO => C.DREP_DATE_TO,
                             DINCL_DATE   => C.DINCL_DATE,
                             DDATE_FROM   => DDATE_FROM,
                             DDATE_TO     => DDATE_TO);
      /* Формирование характеристик элемента ганта */
      GET_TASK_COLORS(NTASK_CLASS             => NTASK_CLASS,
                      STASK_BG_COLOR          => STASK_BG_COLOR,
                      STASK_BG_PROGRESS_COLOR => STASK_BG_PROGRESS_COLOR,
                      STASK_TEXT_COLOR        => STASK_TEXT_COLOR);
      /* Если класс задачи "1" */
      if (NTASK_CLASS = 1) then
        /* Определяем пропорции прогресса */
        NTASK_PROGRESS := ROUND(C.NREL_FACT / C.NMAIN_QUANT * 100);
      else
        /* Не требуется */
        NTASK_PROGRESS := null;
      end if;
      /* Сформируем основную спецификацию */
      RGT := PKG_P8PANELS_VISUAL.TGANTT_TASK_MAKE(NRN                 => C.NRN,
                                                  SNUMB               => COALESCE(C.SROUTE, 'Отсутствует'),
                                                  SCAPTION            => STASK_CAPTION,
                                                  SNAME               => C.SNAME,
                                                  DSTART              => DDATE_FROM,
                                                  DEND                => DDATE_TO,
                                                  NPROGRESS           => NTASK_PROGRESS,
                                                  SBG_COLOR           => STASK_BG_COLOR,
                                                  STEXT_COLOR         => STASK_TEXT_COLOR,
                                                  SBG_PROGRESS_COLOR  => STASK_BG_PROGRESS_COLOR,
                                                  BREAD_ONLY          => true,
                                                  BREAD_ONLY_DATES    => true,
                                                  BREAD_ONLY_PROGRESS => true);
      /* Определяем тип и ссылки на детализацию */
      GET_TASK_TYPE(NCOMPANY      => NCOMPANY,
                    SSORT_FIELD   => SSORT_FIELD,
                    NFCPRODPLAN   => C.NPRN,
                    NFCPRODPLANSP => C.NRN,
                    NTASK_CLASS   => NTASK_CLASS,
                    NTYPE         => NTYPE,
                    SDETAIL_LIST  => SDETAIL_LIST);
      /* Заполним значение динамических атрибутов */
      TASK_ATTRS_FILL(RG           => RG,
                      RGT          => RGT,
                      NSTART_FACT  => C.NSTART_FACT,
                      NMAIN_QUANT  => C.NMAIN_QUANT,
                      NREL_FACT    => C.NREL_FACT,
                      DREP_DATE_TO => C.DREP_DATE_TO,
                      NTYPE        => NTYPE,
                      SDETAIL_LIST => SDETAIL_LIST,
                      SMEAS        => C.SMEAS);
      /* Собираем зависимости */
      for LINK in (select T.RN
                     from FCPRODPLANSP T
                    where T.PRN = C.NPRN
                      and T.UP_LEVEL = C.NRN
                      and T.MAIN_QUANT > 0
                      and ((NLEVEL is null) or ((NLEVEL is not null) and (NLEVEL >= C.NTASK_LEVEL + 1))))
      loop
        /* Добавляем зависимости */
        PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_DEPENDENCY(RTASK => RGT, NDEPENDENCY => LINK.RN);
      end loop;
      /* Добавляем основную спецификацию в диаграмму */
      PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK(RGANTT => RG, RTASK => RGT);
    end loop;
    /* Формируем список */
    COUT := PKG_P8PANELS_VISUAL.TGANTT_TO_XML(RGANTT => RG);
  end FCPRODPLANSP_GET;

  /* Инициализация каталогов раздела "Планы и отчеты производства изделий"  */
  procedure ACATALOG_INIT
  (
    COUT                    out clob    -- Список каталогов раздела "Планы и отчеты производства изделий"
  )
  is
  begin
    /* Начинаем формирование XML */
    PKG_XFAST.PROLOGUE(ITYPE => PKG_XFAST.CONTENT_);
    /* Открываем корень */
    PKG_XFAST.DOWN_NODE(SNAME => 'XDATA');
    /* Цикл по планам и отчетам производства изделий */
    for REC in (select T.RN as NRN,
                       T.NAME as SNAME,
                       (select count(P.RN)
                          from FCPRODPLAN P,
                               FINSTATE   FS
                         where P.CRN = T.RN
                           and P.CATEGORY = NFCPRODPLAN_CATEGORY
                           and P.STATUS = NFCPRODPLAN_STATUS
                           and FS.RN = P.TYPE
                           and FS.CODE = SFCPRODPLAN_TYPE
                           and exists (select PSP.RN
                                  from FCPRODPLANSP PSP
                                 where PSP.PRN = P.RN
                                   and PSP.MAIN_QUANT > 0)
                           and exists (select /*+ INDEX(UP I_USERPRIV_JUR_PERS_ROLEID) */
                                 null
                                  from USERPRIV UP
                                 where UP.JUR_PERS = P.JUR_PERS
                                   and UP.UNITCODE = 'CostProductPlans'
                                   and UP.ROLEID in (select /*+ INDEX(UR I_USERROLES_AUTHID_FK) */
                                                      UR.ROLEID
                                                       from USERROLES UR
                                                      where UR.AUTHID = UTILIZER())
                                union all
                                select /*+ INDEX(UP I_USERPRIV_JUR_PERS_AUTHID) */
                                 null
                                  from USERPRIV UP
                                 where UP.JUR_PERS = P.JUR_PERS
                                   and UP.UNITCODE = 'CostProductPlans'
                                   and UP.AUTHID = UTILIZER())) as NCOUNT_DOCS
                  from ACATALOG T,
                       UNITLIST UL
                 where T.DOCNAME = 'CostProductPlans'
                   and T.SIGNS = 1
                   and T.DOCNAME = UL.UNITCODE
                   and (UL.SHOW_INACCESS_CTLG = 1 or exists
                        (select null from V_USERPRIV UP where UP.CATALOG = T.RN) or exists
                        (select null
                           from ACATALOG T1
                          where exists (select null from V_USERPRIV UP where UP.CATALOG = T1.RN)
                         connect by prior T1.RN = T1.CRN
                          start with T1.CRN = T.RN))
                 order by T.NAME asc)
    loop
      /* Открываем план */
      PKG_XFAST.DOWN_NODE(SNAME => 'XFCPRODPLAN_CRNS');
      /* Описываем план */
      PKG_XFAST.ATTR(SNAME => 'NRN', NVALUE => REC.NRN);
      PKG_XFAST.ATTR(SNAME => 'SNAME', SVALUE => REC.SNAME);
      PKG_XFAST.ATTR(SNAME => 'NCOUNT_DOCS', NVALUE => REC.NCOUNT_DOCS);
      /* Закрываем план */
      PKG_XFAST.UP();
    end loop;
    /* Закрываем корень */
    PKG_XFAST.UP();
    /* Сериализуем */
    COUT := PKG_XFAST.SERIALIZE_TO_CLOB();
    /* Завершаем формирование XML */
    PKG_XFAST.EPILOGUE();
  exception
    when others then
      /* Завершаем формирование XML */
      PKG_XFAST.EPILOGUE();
      /* Вернем ошибку */
      PKG_STATE.DIAGNOSTICS_STACKED();
      P_EXCEPTION(0, PKG_STATE.SQL_ERRM());
  end ACATALOG_INIT;

end PKG_P8PANELS_MECHREC;
/

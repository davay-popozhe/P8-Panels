create or replace package PKG_P8PANELS_MECHREC as

  /* Получение списка спецификаций планов и отчетов производства изделий для диаграммы Ганта */
  procedure FCPRODPLANSP_GET
  (
    NFCPRODPLAN             in number,         -- Рег. номер родителя
    NLEVEL                  in number := null, -- Уровень отбора
    COUT                    out clob,          -- Список проектов
    NMAX_LEVEL              out number         -- Максимальный уровень иерархии
  );
  
  /* Инициализация планов и отчетов производства изделий  */
  procedure PRODPLAN_INIT
  (
    COUT                    out clob    -- Список планов и отчетов производства изделий
  );

end PKG_P8PANELS_MECHREC;
/
create or replace package body PKG_P8PANELS_MECHREC as

  /* Константы - цвета отображения */
  SBG_COLOR_RED             constant PKG_STD.TSTRING := 'red';        -- Цвет заливки красный (Дефицит запуска != 0)
  SBG_COLOR_YELLOW          constant PKG_STD.TSTRING := '#e0db44';    -- Цвет заливки желтый (Дефицит» запуска = 0 и Выпуск факт = 0)
  SBG_COLOR_GREEN           constant PKG_STD.TSTRING := 'lightgreen'; -- Цвет заливки зеленый (Дефицит выпуска = 0)
  SBG_COLOR_BLACK           constant PKG_STD.TSTRING := 'black';      -- Цвет заливки черный (Нет дат и связей)
  STEXT_COLOR_ORANGE        constant PKG_STD.TSTRING := '#FF8C00';    -- Цвет текста для черной заливки (оранжевый)
  
  /* Константы - параметры отборов планов */
  NFCPRODPLAN_CATEGORY      constant PKG_STD.TNUMBER := 1;            -- Категория планов "Производственная программа"
  NFCPRODPLAN_STATUS        constant PKG_STD.TNUMBER := 2;            -- Статус планов "Утвержден"
  SFCPRODPLAN_TYPE          constant PKG_STD.TSTRING := 'План';       -- Тип планов (мнемокод состояния)
  
  /* Константы - дополнительные атрибуты */
  STASK_ATTR_DEFRESLIZ      constant PKG_STD.TSTRING := 'defresliz';  -- Дефицит запуска
  STASK_ATTR_REL_FACT       constant PKG_STD.TSTRING := 'rel_fact';   -- Выпуск факт
  STASK_ATTR_DEFSTART       constant PKG_STD.TSTRING := 'defstart';   -- Дефицит выпуска
  STASK_ATTR_LEVEL          constant PKG_STD.TSTRING := 'level';      -- Уровень

  /* Формирование характеристик спецификации в Ганте */
  procedure MAKE_GANT_ITEM
  (
    NDEFRESLIZ              in number,    -- Дефицит запуска
    NREL_FACT               in number,    -- Выпуск факт
    NDEFSTART               in number,    -- Дефицит выпуска
    STASK_BG_COLOR          out varchar2, -- Цвет заливки спецификации
    STASK_BG_PROGRESS_COLOR out varchar2, -- Цвет заливки прогресса спецификации 
    NTASK_PROGRESS          out number    -- Прогресс спецификации
  )
  is
  begin
    /* Если дефицит запуска <> 0 */
    if (NDEFRESLIZ <> 0) then
      /* Полностью красный */
      STASK_BG_COLOR          := SBG_COLOR_RED;
      STASK_BG_PROGRESS_COLOR := null;
      NTASK_PROGRESS          := null;
    else
      /* Если дефицит выпуска = 0 */
      if (NDEFSTART = 0) then
        /* Полностью зеленый */
        STASK_BG_COLOR          := SBG_COLOR_GREEN;
        STASK_BG_PROGRESS_COLOR := null;
        NTASK_PROGRESS          := null;
      else
        /* Если дефицит запуска = 0 и выпуск факт = 0 */
        if ((NDEFRESLIZ = 0) and (NREL_FACT = 0)) then
          /* Полностью жёлтый */
          STASK_BG_COLOR          := SBG_COLOR_YELLOW;
          STASK_BG_PROGRESS_COLOR := null;
          NTASK_PROGRESS          := null;
        end if;
        /* Если дефицит запуска = 0 и выпуск факт <> 0 */
        if ((NDEFRESLIZ = 0) and (NREL_FACT <> 0)) then
          /* Частично зелёный, прогресс жёлтый */
          STASK_BG_COLOR          := SBG_COLOR_GREEN;
          STASK_BG_PROGRESS_COLOR := SBG_COLOR_YELLOW;
          NTASK_PROGRESS          := 50;
        end if;
      end if;
    end if;
  end MAKE_GANT_ITEM;
  
  /* Считывание заголовка документа */
  function TITLE_GET
  (
    NRN                     in number        -- Рег. номер плана и отчета производства изделий
  ) return                  varchar2         -- Заголовок для отображения
  is
    SRESULT                 PKG_STD.TSTRING; -- Заголовок для отображения
    SDOC_INFO               PKG_STD.TSTRING; -- Информация о документе
    SJURPERSONS_CODE        PKG_STD.TSTRING; -- Мнемокод принадлежности
    SINS_DEPARTMENT_CODE    PKG_STD.TSTRING; -- Мнемокод подразделения
  begin
    /* Считываем информацию из плана */
    begin
      select D.DOCCODE || ', ' || trim(T.PREFIX) || '/' || trim(T.NUMB) || ', от ' || TO_CHAR(T.DOCDATE, 'dd.mm.yyyy') DOC_INFO,
             J.CODE,
             SD.CODE
        into SDOC_INFO,
             SJURPERSONS_CODE,
             SINS_DEPARTMENT_CODE
        from FCPRODPLAN     T,
             DOCTYPES       D,
             JURPERSONS     J,
             INS_DEPARTMENT SD
       where T.RN = NRN
         and D.RN = T.DOCTYPE
         and J.RN = T.JUR_PERS
         and SD.RN = T.SUBDIV;
    exception
      when others then
        return 'Нет информации.';
    end;
    /* Формируем заголовок */
    SRESULT := 'План и отчет производства изделия "' || SDOC_INFO || '", принадлежность "' || SJURPERSONS_CODE ||
               '", подразделение "' || SINS_DEPARTMENT_CODE || '"';
    /* Возвращаем результат */
    return SRESULT;
  end TITLE_GET;
  
  /* Считывание максимального уровня иерархии плана */
  function PRODPLAN_MAX_LEVEL_GET
  (
    NPRODPLAN               in number        -- Рег. номер плана
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
                from FCPRODPLANSP T
               where T.PRN = NPRODPLAN) TMP
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
    NHAVE_LINK              in number := 0, -- Наличие связей с "Маршрутный лист" или "Приход из подразделения"
    DDATE_FROM              out date,       -- Итоговая дата запуска спецификации
    DDATE_TO                out date,       -- Итоговая дата выпуска спецификации
    STASK_BG_COLOR          out varchar2,   -- Цвет элемента (черный, если даты не заданы и нет связи, иначе null)
    STASK_TEXT_COLOR        out varchar2,   -- Цвет текста элемента (хаки, если даты не заданы и нет связи, иначе null)
    NTASK_PROGRESS          out number      -- Прогресс элемента (проинициализирует null, если даты не заданы и нет связи)
  )
  is
  begin
    /* Проициниализируем цвет и прогресс */
    STASK_BG_COLOR   := null;
    NTASK_PROGRESS   := null;
    STASK_TEXT_COLOR := null;
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
    /* Если одна из дат не указана */
    if ((DREP_DATE is null) or (DREP_DATE_TO is null)) then
      /* Если спецификация также не имеет связей */
      if (NHAVE_LINK = 0) then
        /* Закрашиваем в черный */
        STASK_BG_COLOR   := SBG_COLOR_BLACK;
        STASK_TEXT_COLOR := STEXT_COLOR_ORANGE;
        NTASK_PROGRESS   := null;
      end if;
    end if;
  end FCPRODPLANSP_DATES_GET;

  /* Получение списка спецификаций планов и отчетов производства изделий для диаграммы Ганта */
  procedure FCPRODPLANSP_GET
  (
    NFCPRODPLAN             in number,                       -- Рег. номер родителя
    NLEVEL                  in number := null,               -- Уровень отбора
    COUT                    out clob,                        -- Список проектов
    NMAX_LEVEL              out number                       -- Максимальный уровень иерархии
  )
  is
    /* Переменные */
    RG                      PKG_P8PANELS_VISUAL.TGANTT;      -- Описание диаграммы Ганта
    RGT                     PKG_P8PANELS_VISUAL.TGANTT_TASK; -- Описание задачи для диаграммы
    BREAD_ONLY_DATES        boolean := false;                -- Флаг доступности дат проекта только для чтения
    STASK_BG_COLOR          PKG_STD.TSTRING;                 -- Цвет заливки задачи
    STASK_TEXT_COLOR        PKG_STD.TSTRING;                 -- Цвет текста задачи
    STASK_BG_PROGRESS_COLOR PKG_STD.TSTRING;                 -- Цвет заливки прогресса задачи
    NTASK_PROGRESS          PKG_STD.TNUMBER;                 -- Прогресс выполнения задачи
    DDATE_FROM              PKG_STD.TLDATE;                  -- Дата запуска спецификации
    DDATE_TO                PKG_STD.TLDATE;                  -- Дата выпуска спецификации
  begin
    /* Инициализируем диаграмму Ганта */
    RG := PKG_P8PANELS_VISUAL.TGANTT_MAKE(STITLE              => TITLE_GET(NRN => NFCPRODPLAN),
                                          NZOOM               => PKG_P8PANELS_VISUAL.NGANTT_ZOOM_DAY,
                                          BREAD_ONLY_DATES    => BREAD_ONLY_DATES,
                                          BREAD_ONLY_PROGRESS => true);
    /* Добавим динамические атрибуты к спецификациям */
    PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_ATTR(RGANTT   => RG,
                                             SNAME    => STASK_ATTR_DEFRESLIZ,
                                             SCAPTION => 'Дефицит запуска');
    PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_ATTR(RGANTT   => RG,
                                             SNAME    => STASK_ATTR_REL_FACT,
                                             SCAPTION => 'Выпуск факт');
    PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_ATTR(RGANTT   => RG,
                                             SNAME    => STASK_ATTR_DEFSTART,
                                             SCAPTION => 'Дефицит выпуска');
    PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_ATTR(RGANTT => RG, SNAME => STASK_ATTR_LEVEL, SCAPTION => 'Уровень');
    /* Добавим описание цветов */
    PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_COLOR(RGANTT    => RG,
                                              SBG_COLOR => SBG_COLOR_RED,
                                              SDESC     => 'Для спецификаций планов и отчетов производства изделий с «Дефицит запуска» != 0.');
    PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_COLOR(RGANTT    => RG,
                                              SBG_COLOR => SBG_COLOR_YELLOW,
                                              SDESC     => 'Для спецификаций планов и отчетов производства изделий с «Дефицит запуска» = 0 и «Выпуск факт» = 0.');
    PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_COLOR(RGANTT    => RG,
                                              SBG_COLOR => SBG_COLOR_GREEN,
                                              SDESC     => 'Для спецификаций планов и отчетов производства изделий с «Дефицит выпуска» = 0.');
    PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_COLOR(RGANTT             => RG,
                                              SBG_COLOR          => SBG_COLOR_GREEN,
                                              SBG_PROGRESS_COLOR => SBG_COLOR_YELLOW,
                                              SDESC              => 'Для спецификаций планов и отчетов производства изделий с «Дефицит запуска» = 0 и «Выпуск факт» != 0. ');
    PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_COLOR(RGANTT      => RG,
                                              SBG_COLOR   => SBG_COLOR_BLACK,
                                              STEXT_COLOR => STEXT_COLOR_ORANGE,
                                              SDESC       => 'Для спецификаций планов и отчетов производства изделий с пустыми «Дата запуска» и «Дата выпуска» и не имеющих связей с разделами «Маршрутный лист» или «Приход из подразделения».');
    /* Определяем максимальный уровень иерархии */
    NMAX_LEVEL := PRODPLAN_MAX_LEVEL_GET(NPRODPLAN => NFCPRODPLAN);
    /* Цикл по спецификации плана с учетом иерархии */
    for REC in (select TMP.*,
                       level
                  from (select T.RN,
                               T.REP_DATE,
                               T.REP_DATE_TO,
                               T.INCL_DATE,
                               T.ROUTE,
                               D.NOMEN_NAME,
                               (T.QUANT_REST - T.START_FACT) DEFRESLIZ,
                               T.REL_FACT,
                               (T.MAIN_QUANT - T.REL_FACT) DEFSTART,
                               (select 1
                                  from DUAL
                                 where exists
                                 (select null
                                          from DOCLINKS L
                                         where L.IN_DOCUMENT = T.RN
                                           and L.IN_UNITCODE = 'CostProductPlansSpecs'
                                           and (L.OUT_UNITCODE = 'CostRouteLists' or L.OUT_UNITCODE = 'IncomFromDeps')
                                           and ROWNUM = 1)) HAVE_LINK,
                               T.UP_LEVEL
                          from FCPRODPLANSP  T,
                               FCMATRESOURCE FM,
                               DICNOMNS      D
                         where T.PRN = NFCPRODPLAN
                           and ((T.REP_DATE is not null) or (T.REP_DATE_TO is not null) or (T.INCL_DATE is not null))
                           and FM.RN = T.MATRES
                           and D.RN = FM.NOMENCLATURE) TMP
                 where ((NLEVEL is null) or ((NLEVEL is not null) and (level <= NLEVEL)))
                connect by prior TMP.RN = TMP.UP_LEVEL
                 start with TMP.UP_LEVEL is null)
    loop
      /* Инициализируем даты и цвет (если необходимо) */
      FCPRODPLANSP_DATES_GET(DREP_DATE        => REC.REP_DATE,
                             DREP_DATE_TO     => REC.REP_DATE_TO,
                             DINCL_DATE       => REC.INCL_DATE,
                             NHAVE_LINK       => COALESCE(REC.HAVE_LINK, 0),
                             DDATE_FROM       => DDATE_FROM,
                             DDATE_TO         => DDATE_TO,
                             STASK_BG_COLOR   => STASK_BG_COLOR,
                             STASK_TEXT_COLOR => STASK_TEXT_COLOR,
                             NTASK_PROGRESS   => NTASK_PROGRESS);
      /* Если цвет изначально не указан и требуется анализирование */
      if (STASK_BG_COLOR is null) then
        /* Формирование характеристик элемента ганта */
        MAKE_GANT_ITEM(NDEFRESLIZ              => REC.DEFRESLIZ,
                       NREL_FACT               => REC.REL_FACT,
                       NDEFSTART               => REC.DEFSTART,
                       STASK_BG_COLOR          => STASK_BG_COLOR,
                       STASK_BG_PROGRESS_COLOR => STASK_BG_PROGRESS_COLOR,
                       NTASK_PROGRESS          => NTASK_PROGRESS);
      end if;
      /* Сформируем основную спецификацию */
      RGT := PKG_P8PANELS_VISUAL.TGANTT_TASK_MAKE(NRN                 => REC.RN,
                                                  SNUMB               => COALESCE(REC.ROUTE, 'Отсутствует'),
                                                  SCAPTION            => REC.NOMEN_NAME,
                                                  SNAME               => REC.NOMEN_NAME,
                                                  DSTART              => DDATE_FROM,
                                                  DEND                => DDATE_TO,
                                                  NPROGRESS           => NTASK_PROGRESS,
                                                  SBG_COLOR           => STASK_BG_COLOR,
                                                  STEXT_COLOR         => STASK_TEXT_COLOR,
                                                  SBG_PROGRESS_COLOR  => STASK_BG_PROGRESS_COLOR,
                                                  BREAD_ONLY          => true,
                                                  BREAD_ONLY_DATES    => true,
                                                  BREAD_ONLY_PROGRESS => true);
      /* Добавим доп. атрибуты */
      PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_ATTR_VAL(RGANTT => RG,
                                                   RTASK  => RGT,
                                                   SNAME  => STASK_ATTR_DEFRESLIZ,
                                                   SVALUE => TO_CHAR(REC.DEFRESLIZ),
                                                   BCLEAR => true);
      PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_ATTR_VAL(RGANTT => RG,
                                                   RTASK  => RGT,
                                                   SNAME  => STASK_ATTR_REL_FACT,
                                                   SVALUE => TO_CHAR(REC.REL_FACT));
      PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_ATTR_VAL(RGANTT => RG,
                                                   RTASK  => RGT,
                                                   SNAME  => STASK_ATTR_DEFSTART,
                                                   SVALUE => TO_CHAR(REC.DEFSTART));
      PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_ATTR_VAL(RGANTT => RG,
                                                   RTASK  => RGT,
                                                   SNAME  => STASK_ATTR_LEVEL,
                                                   SVALUE => REC.LEVEL);
      /* Собираем зависимости */
      for LINK in (select T.RN
                     from FCPRODPLANSP T
                    where T.PRN = NFCPRODPLAN
                      and T.UP_LEVEL = REC.RN
                      and ((NLEVEL is null) or ((NLEVEL is not null) and (NLEVEL >= REC.LEVEL + 1))))
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

  /* Инициализация планов и отчетов производства изделий  */
  procedure PRODPLAN_INIT
  (
    COUT                    out clob    -- Список планов и отчетов производства изделий
  )
  is
  begin
    /* Начинаем формирование XML */
    PKG_XFAST.PROLOGUE(ITYPE => PKG_XFAST.CONTENT_);
    /* Открываем корень */
    PKG_XFAST.DOWN_NODE(SNAME => 'XDATA');
    /* Цикл по планам и отчетам производства изделий */
    for REC in (select T.RN NRN,
                       D.DOCCODE || ', ' || trim(T.PREFIX) || '/' || trim(T.NUMB) || ', ' ||
                       TO_CHAR(T.DOCDATE, 'dd.mm.yyyy') SDOC_INFO
                  from FCPRODPLAN T,
                       DOCTYPES   D,
                       FINSTATE   FS
                 where T.CATEGORY = NFCPRODPLAN_CATEGORY
                   and T.STATUS = NFCPRODPLAN_STATUS
                   and D.RN = T.DOCTYPE
                   and FS.RN = T.TYPE
                   and FS.CODE = SFCPRODPLAN_TYPE
                   and exists (select /*+ INDEX(UP I_USERPRIV_CATALOG_ROLEID) */
                         null
                          from USERPRIV UP
                         where UP.CATALOG = T.CRN
                           and UP.ROLEID in (select /*+ INDEX(UR I_USERROLES_AUTHID_FK) */
                                              UR.ROLEID
                                               from USERROLES UR
                                              where UR.AUTHID = UTILIZER)
                        union all
                        select /*+ INDEX(UP I_USERPRIV_CATALOG_AUTHID) */
                         null
                          from USERPRIV UP
                         where UP.CATALOG = T.CRN
                           and UP.AUTHID = UTILIZER)
                   and exists (select /*+ INDEX(UP I_USERPRIV_JUR_PERS_ROLEID) */
                         null
                          from USERPRIV UP
                         where UP.JUR_PERS = T.JUR_PERS
                           and UP.UNITCODE = 'CostProductPlans'
                           and UP.ROLEID in (select /*+ INDEX(UR I_USERROLES_AUTHID_FK) */
                                              UR.ROLEID
                                               from USERROLES UR
                                              where UR.AUTHID = UTILIZER)
                        union all
                        select /*+ INDEX(UP I_USERPRIV_JUR_PERS_AUTHID) */
                         null
                          from USERPRIV UP
                         where UP.JUR_PERS = T.JUR_PERS
                           and UP.UNITCODE = 'CostProductPlans'
                           and UP.AUTHID = UTILIZER)
                 order by T.DOCDATE desc)
    loop
      /* Открываем план */
      PKG_XFAST.DOWN_NODE(SNAME => 'XFCPRODPLANS');
      /* Описываем план */
      PKG_XFAST.ATTR(SNAME => 'NRN', NVALUE => REC.NRN);
      PKG_XFAST.ATTR(SNAME => 'SDOC_INFO', SVALUE => REC.SDOC_INFO);
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
  end PRODPLAN_INIT;

end PKG_P8PANELS_MECHREC;
/

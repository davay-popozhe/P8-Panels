create or replace package PKG_P8PANELS_MECHREC as
  
  /* Получение списка спецификаций планов и отчетов производства изделий для диаграммы Ганта */
  procedure FCPRODPLANSP_GET
  (
    NCRN                    in number,                     -- Рег. номер каталога
    NLEVEL                  in number := null,             -- Уровень отбора
    SSORT_FIELD             in varchar2 := 'DREP_DATE_TO', -- Поле сортировки
    COUT                    out clob,                      -- Список проектов
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
  SBG_COLOR_RED             constant PKG_STD.TSTRING := 'red';        -- Цвет заливки красный (Дефицит запуска != 0)
  SBG_COLOR_YELLOW          constant PKG_STD.TSTRING := '#e0db44';    -- Цвет заливки желтый (Дефицит» запуска = 0 и Выпуск факт = 0)
  SBG_COLOR_GREEN           constant PKG_STD.TSTRING := 'lightgreen'; -- Цвет заливки зеленый (Дефицит выпуска = 0)
  SBG_COLOR_BLACK           constant PKG_STD.TSTRING := 'black';      -- Цвет заливки черный (Нет дат и связей)
  STEXT_COLOR_ORANGE        constant PKG_STD.TSTRING := '#FF8C00';    -- Цвет текста для черной заливки (оранжевый)
  
  /* Константы - параметры отборов планов */
  NFCPRODPLAN_CATEGORY      constant PKG_STD.TNUMBER := 1;      -- Категория планов "Производственная программа"
  NFCPRODPLAN_STATUS        constant PKG_STD.TNUMBER := 2;      -- Статус планов "Утвержден"
  SFCPRODPLAN_TYPE          constant PKG_STD.TSTRING := 'План'; -- Тип планов (мнемокод состояния)
  
  /* Константы - дополнительные атрибуты */
  STASK_ATTR_PROD_ORDER     constant PKG_STD.TSTRING := 'prod_order';  -- Заказ
  STASK_ATTR_SUBDIV_DLVR    constant PKG_STD.TSTRING := 'subdiv_dlvr'; -- Сдающее подразделение
  STASK_ATTR_MAIN_QUANT     constant PKG_STD.TSTRING := 'main_quant';  -- Выпуск
  STASK_ATTR_DEFRESLIZ      constant PKG_STD.TSTRING := 'defresliz';   -- Дефицит запуска
  STASK_ATTR_REL_FACT       constant PKG_STD.TSTRING := 'rel_fact';    -- Выпуск факт
  STASK_ATTR_DEFSTART       constant PKG_STD.TSTRING := 'defstart';    -- Дефицит выпуска
  STASK_ATTR_LEVEL          constant PKG_STD.TSTRING := 'level';       -- Уровень

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
      /* Если дефицит выпуска = 0 */
      if (NDEFSTART = 0) then
        /* Полностью зеленый */
        STASK_BG_COLOR          := SBG_COLOR_GREEN;
        STASK_BG_PROGRESS_COLOR := null;
        NTASK_PROGRESS          := null;
      else
        /* Полностью красный */
        STASK_BG_COLOR          := SBG_COLOR_RED;
        STASK_BG_PROGRESS_COLOR := null;
        NTASK_PROGRESS          := null;
      end if;
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
                 and T.PRN = P.RN) TMP
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
    NCRN                    in number,                       -- Рег. номер каталога
    NLEVEL                  in number := null,               -- Уровень отбора
    SSORT_FIELD             in varchar2 := 'DREP_DATE_TO',   -- Поле сортировки
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
    STASK_CAPTION           PKG_STD.TSTRING;                 -- Описание задачи в Ганте    
    
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
    
    /* Инициализация динамических атрибутов */
    procedure TASK_ATTRS_INIT
    (
      RG                    in out PKG_P8PANELS_VISUAL.TGANTT -- Описание диаграммы Ганта
    )
    is
    begin
      /* Добавим динамические атрибуты к спецификациям */
      PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_ATTR(RGANTT => RG, SNAME => STASK_ATTR_PROD_ORDER, SCAPTION => 'Заказ');
      PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_ATTR(RGANTT   => RG,
                                               SNAME    => STASK_ATTR_SUBDIV_DLVR,
                                               SCAPTION => 'Сдающее подразделение');
      PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_ATTR(RGANTT   => RG,
                                               SNAME    => STASK_ATTR_MAIN_QUANT,
                                               SCAPTION => 'Выпуск');
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
    end TASK_ATTRS_INIT;
    
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
    end TASK_COLORS_INIT;
    
    /* Заполнение значений динамических атрибутов */
    procedure FILL_TASK_ATTRS
    (
      RG                    in PKG_P8PANELS_VISUAL.TGANTT,                 -- Описание диаграммы Ганта
      RGT                   in out nocopy PKG_P8PANELS_VISUAL.TGANTT_TASK, -- Описание задачи для диаграммы
      SPROD_ORDER           in varchar2,                                   -- Заказ
      SSUBDIV_DLVR          in varchar2,                                   -- Сдающее подразделение
      NMAIN_QUANT           in number,                                     -- Выпуск
      NDEFRESLIZ            in number,                                     -- Дефицит запуска
      NREL_FACT             in number,                                     -- Выпуск факт
      NDEFSTART             in number,                                     -- Дефицит выпуска
      NLEVEL                in number                                      -- Уровень
    )
    is
    begin
      /* Добавим доп. атрибуты */
      PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_ATTR_VAL(RGANTT => RG,
                                                   RTASK  => RGT,
                                                   SNAME  => STASK_ATTR_PROD_ORDER,
                                                   SVALUE => SPROD_ORDER,
                                                   BCLEAR => true);
      PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_ATTR_VAL(RGANTT => RG,
                                                   RTASK  => RGT,
                                                   SNAME  => STASK_ATTR_SUBDIV_DLVR,
                                                   SVALUE => SSUBDIV_DLVR);
      PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_ATTR_VAL(RGANTT => RG,
                                                   RTASK  => RGT,
                                                   SNAME  => STASK_ATTR_MAIN_QUANT,
                                                   SVALUE => TO_CHAR(NMAIN_QUANT));
      PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_ATTR_VAL(RGANTT => RG,
                                                   RTASK  => RGT,
                                                   SNAME  => STASK_ATTR_DEFRESLIZ,
                                                   SVALUE => TO_CHAR(NDEFRESLIZ));
      PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_ATTR_VAL(RGANTT => RG,
                                                   RTASK  => RGT,
                                                   SNAME  => STASK_ATTR_REL_FACT,
                                                   SVALUE => TO_CHAR(NREL_FACT));
      PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_ATTR_VAL(RGANTT => RG,
                                                   RTASK  => RGT,
                                                   SNAME  => STASK_ATTR_DEFSTART,
                                                   SVALUE => TO_CHAR(NDEFSTART));
      PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_ATTR_VAL(RGANTT => RG,
                                                   RTASK  => RGT,
                                                   SNAME  => STASK_ATTR_LEVEL,
                                                   SVALUE => TO_CHAR(NLEVEL));
    end FILL_TASK_ATTRS;
  begin
    /* Инициализируем диаграмму Ганта */
    RG := PKG_P8PANELS_VISUAL.TGANTT_MAKE(STITLE              => 'Производственная программа',
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
                             D.NOMEN_NAME SNOMEN_NAME,
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
                             end DORDER_DATE
                        from FCPRODPLAN    P,
                             FINSTATE      FS,
                             FCPRODPLANSP  T,
                             FCMATRESOURCE FM,
                             DICNOMNS      D
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
                         and ((T.REP_DATE is not null) or (T.REP_DATE_TO is not null) or (T.INCL_DATE is not null))
                         and FM.RN = T.MATRES
                         and D.RN = FM.NOMENCLATURE) TMP
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
      /* Инициализируем даты и цвет (если необходимо) */
      FCPRODPLANSP_DATES_GET(DREP_DATE        => C.DREP_DATE,
                             DREP_DATE_TO     => C.DREP_DATE_TO,
                             DINCL_DATE       => C.DINCL_DATE,
                             NHAVE_LINK       => COALESCE(C.NHAVE_LINK, 0),
                             DDATE_FROM       => DDATE_FROM,
                             DDATE_TO         => DDATE_TO,
                             STASK_BG_COLOR   => STASK_BG_COLOR,
                             STASK_TEXT_COLOR => STASK_TEXT_COLOR,
                             NTASK_PROGRESS   => NTASK_PROGRESS);
      /* Если цвет изначально не указан и требуется анализирование */
      if (STASK_BG_COLOR is null) then
        /* Формирование характеристик элемента ганта */
        MAKE_GANT_ITEM(NDEFRESLIZ              => C.NDEFRESLIZ,
                       NREL_FACT               => C.NREL_FACT,
                       NDEFSTART               => C.NDEFSTART,
                       STASK_BG_COLOR          => STASK_BG_COLOR,
                       STASK_BG_PROGRESS_COLOR => STASK_BG_PROGRESS_COLOR,
                       NTASK_PROGRESS          => NTASK_PROGRESS);
      end if;
      /* Сформируем основную спецификацию */
      RGT := PKG_P8PANELS_VISUAL.TGANTT_TASK_MAKE(NRN                 => C.NRN,
                                                  SNUMB               => COALESCE(C.SROUTE, 'Отсутствует'),
                                                  SCAPTION            => STASK_CAPTION,
                                                  SNAME               => C.SNOMEN_NAME,
                                                  DSTART              => DDATE_FROM,
                                                  DEND                => DDATE_TO,
                                                  NPROGRESS           => NTASK_PROGRESS,
                                                  SBG_COLOR           => STASK_BG_COLOR,
                                                  STEXT_COLOR         => STASK_TEXT_COLOR,
                                                  SBG_PROGRESS_COLOR  => STASK_BG_PROGRESS_COLOR,
                                                  BREAD_ONLY          => true,
                                                  BREAD_ONLY_DATES    => true,
                                                  BREAD_ONLY_PROGRESS => true);
      /* Заполним значение динамических атрибутов */
      FILL_TASK_ATTRS(RG           => RG,
                      RGT          => RGT,
                      SPROD_ORDER  => C.SPROD_ORDER,
                      SSUBDIV_DLVR => C.SSUBDIV_DLVR,
                      NMAIN_QUANT  => C.NMAIN_QUANT,
                      NDEFRESLIZ   => C.NDEFRESLIZ,
                      NREL_FACT    => C.NREL_FACT,
                      NDEFSTART    => C.NDEFSTART,
                      NLEVEL       => C.NTASK_LEVEL);
      /* Собираем зависимости */
      for LINK in (select T.RN
                     from FCPRODPLANSP T
                    where T.PRN = C.NPRN
                      and T.UP_LEVEL = C.NRN
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
    for REC in (select T.RN   as NRN,
                       T.NAME as SNAME,
                       (select count(P.RN)
                          from FCPRODPLAN P,
                               FINSTATE   FS
                         where P.CRN = T.RN
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

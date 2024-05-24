create or replace package PKG_P8PANELS_MECHREC as

  /* Проверка соответствия подразделения документа подразделению пользователя */
  function UTL_SUBDIV_CHECK
  (
    NCOMPANY                in number,  -- Рег. номер организации
    NSUBDIV                 in number,  -- Рег. номер подразделения
    SUSER                   in varchar2 -- Имя пользователя    
  ) return                  number;     -- Подразделение подходит (0 - нет, 1 - да)
  
  /* Проверка соответствия подразделения документа подразделению пользователя (по иерархии) */
  function UTL_SUBDIV_HIER_CHECK
  (
    NCOMPANY                in number,  -- Рег. номер организации
    NSUBDIV                 in number,  -- Рег. номер подразделения
    SUSER                   in varchar2 -- Имя пользователя    
  ) return                  number;     -- Подразделение подходит (0 - нет, 1 - да)
  
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
    NFCROUTLST              in number,  -- Рег. номер маршрутного листа
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    CORDERS                 in clob,    -- Сортировки
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
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

  /* Инициализация каталогов раздела "Планы и отчеты производства изделий" для панели "Производственная программа" */
  procedure FCPRODPLAN_PP_CTLG_INIT
  (
    COUT                    out clob    -- Список каталогов раздела "Планы и отчеты производства изделий"
  );

  /* Изменение приоритета партии маршрутного листа */
  procedure FCROUTLST_PRIOR_PARTY_UPDATE
  (
    NFCROUTLST              in number,  -- Рег. номер маршрутного листа
    SPRIOR_PARTY            in varchar  -- Новое значение приоритета партии
  );
  
  /* Изменение заказа маршрутного листа */
  procedure FCROUTLST_FACEACC_UPDATE
  (
    NFCROUTLST              in number,  -- Рег. номер маршрутного листа
    SFACEACC_NUMB           in varchar, -- Номер заказа
    NFCPRODPLANSP           in number   -- Рег. номер строки плана
  );
  
  /* Получение таблицы маршрутных листов, связанных со спецификацией плана */
  procedure FCROUTLST_DEPT_DG_GET
  (
    NFCPRODPLANSP           in number,  -- Рег. номер связанной спецификации плана
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    CORDERS                 in clob,    -- Сортировки
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
  );
  
  /* Получение таблицы заказов маршрутного листа */
  procedure FCROUTLSTORD_DEPT_DG_GET
  (
    NFCROUTLST              in number,  -- Рег. номер маршрутного листа
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    CORDERS                 in clob,    -- Сортировки
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
  );

  /* Получение таблицы ПиП на основании маршрутного листа, связанных со спецификацией плана */
  procedure INCOMEFROMDEPS_DEPT_DG_GET
  (
    NFCPRODPLANSP           in number,  -- Рег. номер связанной спецификации плана
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    CORDERS                 in clob,    -- Сортировки
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
  );
  
  /* Получение таблицы спецификаций планов и отчетов производства изделий */
  procedure FCPRODPLANSP_DEPT_DG_GET
  (
    NFCPRODPLAN             in number,  -- Рег. номер планов и отчетов производства изделий
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    CORDERS                 in clob,    -- Сортировки
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
  );
  
  /* Инициализация записей раздела "Планы и отчеты производства изделий" */
  procedure FCPRODPLAN_DEPT_INIT
  (
    COUT                    out clob    -- Список записей раздела "Планы и отчеты производства изделий"
  );
  
  /* Добавление записи маршрутного листа в селектлисте */
  procedure SELECTLIST_FCROUTLST_ADD
  (
    NIDENT                  in number,  -- Идентификатор селектлиста
    NFCROUTLST              in number   -- Рег. номер маршрутного листа
  );
  
  /* Удаление записи маршрутного листа из селектлиста */
  procedure SELECTLIST_FCROUTLST_DEL
  (
    NIDENT                  in number,  -- Идентификатор селектлиста
    NFCROUTLST              in number   -- Рег. номер маршрутного листа
  );
  
  /* Выдать задание операции сменного задания */
  procedure FCJOBSSP_ISSUE
  (
    NFCJOBS                 in number,  -- Рег. номер сменного задания
    SFCJOBSSP_LIST          in varchar2 -- Список операций сменного задания
  );
  
  /* Исключение оборудования из операции сменного задания */
  procedure FCJOBSSP_EXC_FCEQUIPMENT
  (
    NFCEQUIPMENT            in number,  -- Рег. номер оборудования
    NFCJOBS                 in number,  -- Рег. номер сменного задания
    SFCJOBSSP_LIST          in varchar2 -- Список операций сменного задания
  );
  
  /* Включение оборудование в строку сменного задания */
  procedure FCJOBSSP_INC_FCEQUIPMENT
  (
    NFCEQUIPMENT            in number,  -- Рег. номер оборудования
    NFCJOBS                 in number,  -- Рег. номер сменного задания
    SFCJOBSSP_LIST          in varchar2 -- Список операций сменного задания
  );
  
  /* Получение таблицы оборудования подразделения */
  procedure FCEQUIPMENT_DG_GET
  (
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    CORDERS                 in clob,    -- Сортировки
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
  );
  
  /* Получение таблицы маршрутных листов спецификации сменного задания */
  procedure FCJOBSSP_FCROUTLST_DG_GET
  (
    NFCJOBS                 in number,  -- Рег. номер сменного задания
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    CORDERS                 in clob,    -- Сортировки
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
  );
  
  /* Получение спецификации сменного задания по отмеченным маршрутным листам */
  procedure FCJOBSSP_DG_GET
  (
    NFCJOBS                 in number,  -- Рег. номер сменного задания
    NIDENT                  in number,  -- Идентификатор процесса
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    CORDERS                 in clob,    -- Сортировки
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
  );
  
  /* Инициализация записей раздела "Планы и отчеты производства изделий" */
  procedure FCJOBS_INIT
  (
    COUT                    out clob    -- Список записей раздела "Сменные задания"
  );
  
  /* Получение загрузки цеха */
  procedure FCJOBS_DEP_LOAD_DG_GET
  (
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    CORDERS                 in clob,    -- Сортировки
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
  );
  
  /* Получение таблицы маршрутных листов, связанных с производственным составом */
  procedure FCROUTLST_DG_BY_PRDCMPSP_GET
  (
    NPRODCMPSP              in number,  -- Рег. номер производственного состава
    NFCPRODPLAN             in number,  -- Рег. номер план
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    CORDERS                 in clob,    -- Сортировки
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
  );
  
  /* Получение таблицы комплектовочных ведомостей, связанных с производственным составом */
  procedure FCDELIVSH_DG_BY_PRDCMPSP_GET
  (
    NPRODCMPSP              in number,  -- Рег. номер производственного состава
    NFCPRODPLAN             in number,  -- Рег. номер план
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    CORDERS                 in clob,    -- Сортировки
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
  );
  
  /* Получение таблицы записей "Планы и отчеты производства изделий" */
  procedure FCPRODPLAN_GET
  (
    NCRN                    in number,  -- Рег. номер каталога
    COUT                    out clob    -- Сериализованная таблица данных
  );
  
  /* Инициализация каталогов раздела "Планы и отчеты производства изделий" для панели "Мониторинг сборки изделий" */
  procedure FCPRODPLAN_AM_CTLG_INIT
  (
    COUT                    out clob    -- Список каталогов раздела "Планы и отчеты производства изделий"
  );

  /* Считывание деталей производственного состава */
  procedure FCPRODCMP_DETAILS_GET
  (
    NFCPRODPLAN             in number,  -- Рег. номер плана
    COUT                    out clob    -- Сериализованная таблица данных
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
  
  /* Константы - параметры отборов планов ("Производственная программа") */
  NFCPRODPLAN_CATEGORY      constant PKG_STD.TNUMBER := 1;      -- Категория планов "Производственная программа"
  NFCPRODPLAN_STATUS        constant PKG_STD.TNUMBER := 2;      -- Статус планов "Утвержден"
  SFCPRODPLAN_TYPE          constant PKG_STD.TSTRING := 'План'; -- Тип планов (мнемокод состояния)
  NMAX_TASKS                constant PKG_STD.TNUMBER := 10000;  -- Максимальное количество отображаемых задач
  
  /* Константы - классы задач плана ("Производственная программа") */
  NCLASS_WO_DEFICIT         constant PKG_STD.TNUMBER := 0; -- Без дефицита выпуска
  NCLASS_PART_DEFICIT       constant PKG_STD.TNUMBER := 1; -- С частичным дефицитом выпуска
  NCLASS_FULL_DEFICIT       constant PKG_STD.TNUMBER := 2; -- С полным дефицитом выпуска
  NCLASS_WITH_DEFICIT       constant PKG_STD.TNUMBER := 3; -- С дефицитом запуска или датой меньше текущей
  NCLASS_FUTURE_DATE        constant PKG_STD.TNUMBER := 4; -- Дата анализа еще не наступила
  NCLASS_WO_LINKS           constant PKG_STD.TNUMBER := 5; -- Задача без связи
  
  /* Константы - типы задач плана, содержание детализации ("Производственная программа") */
  NTASK_TYPE_RL_WITH_GP     constant PKG_STD.TNUMBER := 0;    -- Маршрутные листы с развертыванием товарных запасов
  NTASK_TYPE_RL_WITH_DL     constant PKG_STD.TNUMBER := 1;    -- Маршрутные листы с развертыванием комплектаций
  NTASK_TYPE_INC_DEPS       constant PKG_STD.TNUMBER := 2;    -- Приход из подразделений
  NTASK_TYPE_INC_DEPS_RL    constant PKG_STD.TNUMBER := 3;    -- Приход из подразделений и маршрутные листы
  NTASK_TYPE_RL             constant PKG_STD.TNUMBER := 4;    -- Маршрутные листы
  NTASK_TYPE_EMPTY          constant PKG_STD.TNUMBER := null; -- Нет детализации
  
  /* Константы - параметры отборов планов (Производственный план цеха) */
  NFCPRODPLAN_DEPT_CTGR     constant PKG_STD.TNUMBER := 2; -- Категория планов "Цеховой план"
  
  /* Константы - параметры отборов планов ("Мониторинг сборки изделий") */
  NFCPRODPLAN_CATEGORY_MON  constant PKG_STD.TNUMBER := 0;      -- Категория планов "Первичный документ"
  NFCPRODPLAN_STATUS_MON    constant PKG_STD.TNUMBER := 2;      -- Статус планов "Утвержден"
  SFCPRODPLAN_TYPE_MON      constant PKG_STD.TSTRING := 'План'; -- Тип планов (мнемокод состояния)
  
  /* Константы - параметры отборов ("Загрузка цеха") */
  SDICMUNTS_WD              constant PKG_STD.TSTRING := 'Ч/Ч'; -- Мнемокод ед. измерения нормочасов
  SDICMUNTS_HOUR            constant PKG_STD.TSTRING := 'Час'; -- Мнемокод ед. измерения часов
  
  /* Константы - параметры отборов сменных заданий */
  NFCJOBS_STATUS_WO         constant PKG_STD.TNUMBER := 1; -- Статус сменного задания "Отработан"

  /* Константы - дополнительные атрибуты */
  STASK_ATTR_START_FACT     constant PKG_STD.TSTRING := 'start_fact';  -- Запущено
  STASK_ATTR_MAIN_QUANT     constant PKG_STD.TSTRING := 'main_quant';  -- Количество план
  STASK_ATTR_REL_FACT       constant PKG_STD.TSTRING := 'rel_fact';    -- Количество сдано
  STASK_ATTR_REP_DATE_TO    constant PKG_STD.TSTRING := 'rep_date_to'; -- Дата выпуска план
  STASK_ATTR_DL             constant PKG_STD.TSTRING := 'detail_list'; -- Связанные документы
  STASK_ATTR_TYPE           constant PKG_STD.TSTRING := 'type';        -- Тип (0 - Деталь, 1 - Изделие/сборочная единица)
  STASK_ATTR_MEAS           constant PKG_STD.TSTRING := 'meas';        -- Единица измнения
  
  /* Константы - дополнительные параметры */
  SCOL_PATTERN_DATE         constant PKG_STD.TSTRING := 'dd_mm_yyyy'; -- Паттерн для динамической колонки граф ("день_месяц_год")
  
  /* Константы - типовые присоединённые документы */
  SFLINKTYPE_PREVIEW        constant PKG_STD.TSTRING := 'Предпросмотр';     -- Тип ПД для изображений предпросмотра
  SFLINKTYPE_SVG_MODEL      constant PKG_STD.TSTRING := 'Векторная модель'; -- Тип ПД для SVG-модели
  
  /* Константы - дополнительные свойства */
  SDP_MODEL_ID              constant PKG_STD.TSTRING := 'ПУДП.MODEL_ID';       -- Идентификатор в SVG-модели
  SDP_MODEL_BG_COLOR        constant PKG_STD.TSTRING := 'ПУДП.MODEL_BG_COLOR'; -- Цвет заливки в SVG-модели
    
  /* Экземпляр дня загрузки цеха */
  type TJOB_DAY is record
  (
    DDATE                   PKG_STD.TLDATE, -- Дата дня загрузки цеха
    NVALUE                  PKG_STD.TQUANT, -- Значение доли трудоемкости смены
    NTYPE                   PKG_STD.TNUMBER -- Тип дня (0 - выполняемый, 1 - выполненный)
  );

  /* Коллекция дней загрузки цеха */
  type TJOB_DAYS is table of TJOB_DAY;

  /* Добавление дня в коллекцию дней загрузки цеха */
  procedure TJOB_DAYS_ADD
  (
    TDAYS                   in out nocopy TJOB_DAYS, -- Коллекция дней загрузки цеха
    DDATE                   in date,                 -- Дата дня загрузки цеха
    NVALUE                  in number,               -- Значение доли трудоемкости смены
    NTYPE                   in number,               -- Тип дня (0 - выполняемый, 1 - выполненный)
    BCLEAR                  in boolean := false      -- Признак очистки результирующей коллекции перед добавлением таблицы
  )
  is
  begin
    /* Инициализируем коллекцию таблиц документа */
    if ((TDAYS is null) or (BCLEAR)) then
      TDAYS := TJOB_DAYS();
    end if;
    /* Добавляем таблицу к документу */
    TDAYS.EXTEND();
    TDAYS(TDAYS.LAST).DDATE := DDATE;
    TDAYS(TDAYS.LAST).NVALUE := NVALUE;
    TDAYS(TDAYS.LAST).NTYPE := NTYPE;
  end TJOB_DAYS_ADD; 
  
  /* Инциализация списка маршрутных листов (с иерархией) */
  procedure UTL_FCROUTLST_IDENT_INIT
  (
    NFCPRODPLANSP           in number,  -- Рег. номер связанной спецификации плана
    NIDENT                  out number  -- Идентификатор отмеченных записей
  )
  is
    /* Рекурсивная процедура формирования списка маршрутных листов */
    procedure PUT_FCROUTLST
    (
      NIDENT                in number,       -- Идентификатор отмеченных записей
      NFCROUTLST            in number        -- Рег. номер маршрутного листа
    )
    is
      NTMP                  PKG_STD.TNUMBER; -- Буфер
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
  
  /* Считывание записи маршрутного листа */
  procedure UTL_FCROUTLST_GET
  (
    NFCROUTLST              in number,            -- Рег. номер маршрутного листа
    RFCROUTLST              out FCROUTLST%rowtype -- Запись маршрутного листа
  )
  is
  begin
    /* Считываем запись маршрутного листа */
    begin
      select T.* into RFCROUTLST from FCROUTLST T where T.RN = NFCROUTLST;
    exception
      when others then
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0, NDOCUMENT => NFCROUTLST, SUNIT_TABLE => 'FCROUTLST');
    end;
  end UTL_FCROUTLST_GET;
  
  /* Получение мнемокода подразделения пользователя */
  function UTL_SUBDIV_CODE_GET
  (
    NCOMPANY                in number,       -- Рег. номер организации
    SUSER                   in varchar2      -- Имя пользователя
  ) return                  varchar2         -- Мнемокод подразделения пользователя
  is
    SRESULT                 PKG_STD.TSTRING; -- Мнемокод подразделения пользователя
    NVERSION                PKG_STD.TREF;    -- Версия контрагентов
  begin
    /* Считываем версию контрагентов */
    FIND_VERSION_BY_COMPANY(NCOMPANY => NCOMPANY, SUNITCODE => 'AGNLIST', NVERSION => NVERSION);
    /* Считываем мнемокод подразделения пользователя */
    begin
      select I.CODE
        into SRESULT
        from CLNPSPFM       C,
             CLNPSPFMTYPES  CT,
             INS_DEPARTMENT I
       where exists (select null
                from CLNPERSONS CP
               where exists (select null
                        from AGNLIST T
                       where T.PERS_AUTHID = SUSER
                         and CP.PERS_AGENT = T.RN
                         and T.VERSION = NVERSION)
                 and C.PERSRN = CP.RN
                 and CP.COMPANY = NCOMPANY)
         and C.COMPANY = NCOMPANY
         and C.BEGENG <= sysdate
         and (C.ENDENG >= sysdate or C.ENDENG is null)
         and C.CLNPSPFMTYPES = CT.RN
         and CT.IS_PRIMARY = 1
         and I.RN = C.DEPTRN
         and ROWNUM = 1;
    exception
      when others then
        SRESULT := null;
    end;
    /* Возвращаем результат */
    return SRESULT;
  end UTL_SUBDIV_CODE_GET;
  
  /* Проверка соответствия подразделения документа подразделению пользователя */
  function UTL_SUBDIV_CHECK
  (
    NCOMPANY                in number,       -- Рег. номер организации
    NSUBDIV                 in number,       -- Рег. номер подразделения
    SUSER                   in varchar2      -- Имя пользователя
  ) return                  number           -- Подразделение подходит (0 - нет, 1 - да)
  is
    NRESULT                 PKG_STD.TNUMBER; -- Подразделение подходит (0 - нет, 1 - да)
    NVERSION                PKG_STD.TREF;    -- Версия контрагентов
  begin
    /* Если рег. номер подразделения пустой */
    if (NSUBDIV is null) then
      /* Возвращаем 0 */
      return 0;
    end if;
    /* Считываем версию контрагентов */
    FIND_VERSION_BY_COMPANY(NCOMPANY => NCOMPANY, SUNITCODE => 'AGNLIST', NVERSION => NVERSION);
    /* Проверяем подразделение по исполнению сотрудника пользователя */
    begin
      select 1
        into NRESULT
        from DUAL
       where NSUBDIV in (select C.DEPTRN
                           from CLNPSPFM      C,
                                CLNPSPFMTYPES CT
                          where exists (select null
                                   from CLNPERSONS CP
                                  where exists (select null
                                           from AGNLIST T
                                          where T.PERS_AUTHID = SUSER
                                            and CP.PERS_AGENT = T.RN
                                            and T.VERSION = NVERSION)
                                    and C.PERSRN = CP.RN
                                    and CP.COMPANY = NCOMPANY)
                            and C.COMPANY = NCOMPANY
                            and C.BEGENG <= sysdate
                            and (C.ENDENG >= sysdate or C.ENDENG is null)
                            and C.CLNPSPFMTYPES = CT.RN
                            and CT.IS_PRIMARY = 1);
    exception
      when others then
        NRESULT := 0;
    end;
    /* Возвращаем результат */
    return NRESULT;
  end UTL_SUBDIV_CHECK;
  
  /* Проверка соответствия подразделения документа подразделению пользователя (по иерархии) */
  function UTL_SUBDIV_HIER_CHECK
  (
    NCOMPANY                in number,       -- Рег. номер организации
    NSUBDIV                 in number,       -- Рег. номер подразделения
    SUSER                   in varchar2      -- Имя пользователя    
  ) return                  number           -- Подразделение подходит (0 - нет, 1 - да)
  is
    NRESULT                 PKG_STD.TNUMBER; -- Подразделение подходит (0 - нет, 1 - да)
    NVERSION                PKG_STD.TREF;    -- Версия контрагентов
  begin
    /* Если рег. номер подразделения пустой */
    if (NSUBDIV is null) then
      /* Возвращаем 0 */
      return 0;
    end if;
    /* Считываем версию контрагентов */
    FIND_VERSION_BY_COMPANY(NCOMPANY => NCOMPANY, SUNITCODE => 'AGNLIST', NVERSION => NVERSION);
    /* Проверяем подразделение по исполнению сотрудника пользователя */
    begin
      select 1
        into NRESULT
        from DUAL
       where exists (select null
                from INS_DEPARTMENT T,
                     (select C.DEPTRN
                        from CLNPSPFM      C,
                             CLNPSPFMTYPES CT
                       where exists (select null
                                from CLNPERSONS CP
                               where exists (select null
                                        from AGNLIST T
                                       where T.PERS_AUTHID = SUSER
                                         and CP.PERS_AGENT = T.RN
                                         and T.VERSION = NVERSION)
                                 and C.PERSRN = CP.RN
                                 and CP.COMPANY = NCOMPANY)
                         and C.COMPANY = NCOMPANY
                         and C.BEGENG <= sysdate
                         and (C.ENDENG >= sysdate or C.ENDENG is null)
                         and C.CLNPSPFMTYPES = CT.RN
                         and CT.IS_PRIMARY = 1) TMP
               where T.RN = NSUBDIV
                 and ROWNUM = 1
               start with T.RN = TMP.DEPTRN
              connect by prior T.RN = T.PRN);
    exception
      when others then
        NRESULT := 0;
    end;
    /* Возвращаем результат */
    return NRESULT;
  end UTL_SUBDIV_HIER_CHECK;
    
  /* Проверка наличия оборудования */
  procedure UTL_FCEQUIPMENT_EXISTS
  (
    NFCEQUIPMENT            in number,       -- Рег. номер оборудования
    NCOMPANY                in number        -- Рег. номер организации
  )
  is
    NEXISTS                 PKG_STD.TNUMBER; -- Буфер
  begin
    /* Проверяем наличие оборудования */
    begin
      select T.RN
        into NEXISTS
        from FCEQUIPMENT T
       where T.RN = NFCEQUIPMENT
         and T.COMPANY = NCOMPANY;
    exception
      when others then
        P_EXCEPTION(0, 'Оборудование не найдено.');
    end;
  end UTL_FCEQUIPMENT_EXISTS;
  
  /* Поиск записи в селектлисте */
  function UTL_SELECTLIST_RN_GET
  (
    NIDENT                  in number,       -- Идентификатор селектлиста
    NFCROUTLST              in number,       -- Рег. номер маршрутного листа
    SUNITCODE               in varchar2,     -- Мнемокод раздела
    SACTIONCODE             in varchar2      -- Действие раздела
  ) return                  number           -- Рег. номер записи в селектлисте
  is
    NRESULT                 PKG_STD.TNUMBER; -- Рег. номер записи в селектлисте
  begin
    /* Считываем запись селеклиста */
    begin
      select T.RN
        into NRESULT
        from SELECTLIST T
       where T.IDENT = NIDENT
         and T.UNITCODE = SUNITCODE
         and T.DOCUMENT = NFCROUTLST
         and T.ACTIONCODE = SACTIONCODE;
    exception
      when others then
        NRESULT := null;
    end;
    /* Возвращаем результат */
    return NRESULT;
  end UTL_SELECTLIST_RN_GET;
  
  /* Считывание рег. номера основной спецификации плана из "Производственная программа" */
  function UTL_FCPRODPLANSP_MAIN_GET
  (
    NCOMPANY                in number,    -- Рег. номер организации
    NFCPRODPLANSP           in number     -- Рег. номер связанной спецификации плана
  ) return                  number        -- Рег. номер основной спецификации плана из "Производственная программа"
  is
    NRESULT                 PKG_STD.TREF; -- Рег. номер основной спецификации плана из "Производственная программа"
  begin
    /* Поиск связанной спецификации из "Производственная программа" */
    begin
      select S.RN
        into NRESULT
        from DOCLINKS     T,
             FCPRODPLANSP S,
             FCPRODPLAN   P
       where T.OUT_DOCUMENT = NFCPRODPLANSP
         and T.IN_UNITCODE = 'CostProductPlansSpecs'
         and T.OUT_UNITCODE = 'CostProductPlansSpecs'
         and S.RN = T.IN_DOCUMENT
         and P.RN = S.PRN
         and P.CATEGORY = 1
         and P.COMPANY = NCOMPANY
         and ROWNUM = 1;
    exception
      when others then
        NRESULT := null;
    end;
    /* Возвращаем результат */
    return NRESULT;
  end UTL_FCPRODPLANSP_MAIN_GET;
  
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
  
  /*
    Процедуры панели "Производственная программа"
  */

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
    /* Если тип "Приход из подразделений и маршрутные листы", то необходимо включать состояние */
    if (NTYPE = NTASK_TYPE_INC_DEPS_RL) then
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
        /* Если тип "Приход из подразделений и маршрутные листы", то необходимо включать состояние */
        if (NTYPE = NTASK_TYPE_INC_DEPS_RL) then
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
    NTYPE                   in number,  -- Тип спецификации плана (см. константы NTASK_TYPE_*)
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
      when (NTYPE = NTASK_TYPE_RL_WITH_GP) then
        /* Получаем таблицу по детали */
        FCROUTLST_DG_BY_DTL(NFCPRODPLANSP => NFCPRODPLANSP,
                            NPAGE_NUMBER  => NPAGE_NUMBER,
                            NPAGE_SIZE    => NPAGE_SIZE,
                            CORDERS       => CORDERS,
                            NINCLUDE_DEF  => NINCLUDE_DEF,
                            COUT          => COUT);
      /* Изделие/сборочная единица */
      when (NTYPE = NTASK_TYPE_RL_WITH_DL) then
        /* Получаем таблицу по изделию */
        FCROUTLST_DG_BY_PRDCT(NFCPRODPLANSP => NFCPRODPLANSP,
                              NPAGE_NUMBER  => NPAGE_NUMBER,
                              NPAGE_SIZE    => NPAGE_SIZE,
                              CORDERS       => CORDERS,
                              NINCLUDE_DEF  => NINCLUDE_DEF,
                              COUT          => COUT);
      /* Для приходов из подразделений */
      when ((NTYPE = NTASK_TYPE_INC_DEPS_RL) or (NTYPE = NTASK_TYPE_RL)) then
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
    NTYPE                   PKG_STD.TNUMBER;                       -- Тип задачи (см. константы NTASK_TYPE_*)
    SDETAIL_LIST            PKG_STD.TSTRING;                       -- Ссылки на детализацию
    SPLAN_TITLE             PKG_STD.TSTRING;                       -- Заголовок плана
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
    NTASK_CLASS             PKG_STD.TNUMBER;                       -- Класс задачи (см. константы NCLASS_*)
    NLEVEL_FILTER           PKG_STD.TNUMBER;                       -- Уровень для фильтра

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
      NCRN                  in number             -- Рег. номер каталога планов
    ) return                number                -- Максимальный уровень иерархии
    is
      NRESULT               PKG_STD.TNUMBER := 1; -- Максимальный уровень иерархии
      NTOTAL                PKG_STD.TNUMBER := 0; -- Сумма документов по проверяемому уровню
    begin
      /* Цикл по уровням каталога планов */
      for REC in (select level,
                         count(TMP.RN) COUNT_DOCS
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
                   start with TMP.UP_LEVEL is null
                   group by level
                   order by level)
      loop
        /* Получаем количество задач с учетом текущего уровня */
        NTOTAL := NTOTAL + REC.COUNT_DOCS;
        /* Если сумма документов по текущему уровню превышает максимальное количество задач */
        if (NTOTAL >= NMAX_TASKS) then
          /* Выходим из цикла */
          exit;
        end if;
        /* Указываем текущий уровень */
        NRESULT := REC.LEVEL;
      end loop;
      /* Возвращаем результат */
      return NRESULT;
    end PRODPLAN_MAX_LEVEL_GET;
  
    /* Определение дат спецификации плана */
    procedure FCPRODPLANSP_DATES_GET
    (
      DREP_DATE             in date,    -- Дата запуска спецификации
      DREP_DATE_TO          in date,    -- Дата выпуска спецификации
      DINCL_DATE            in date,    -- Дата включения в план спецификации
      DDATE_FROM            out date,   -- Итоговая дата запуска спецификации
      DDATE_TO              out date    -- Итоговая дата выпуска спецификации
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
      RG                    in out nocopy PKG_P8PANELS_VISUAL.TGANTT -- Описание диаграммы Ганта
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
      NTYPE                 in number,                                     -- Тип (см. константы NTASK_TYPE_*)
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
      RG                    in out nocopy PKG_P8PANELS_VISUAL.TGANTT -- Описание диаграммы Ганта
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
      NDEFRESLIZ            in number,       -- Дефицит запуска
      NREL_FACT             in number,       -- Выпуск факт
      NDEFSTART             in number,       -- Дефицит выпуска
      DREP_DATE             in date,         -- Дата запуска спецификации
      DREP_DATE_TO          in date,         -- Дата выпуска спецификации
      NHAVE_LINK            in number := 0   -- Наличие связей с "Маршрутный лист" или "Приход из подразделения"
    ) return                number           -- Класс задачи
    is
      NTASK_CLASS           PKG_STD.TNUMBER; -- Класс задачи (см. константы NCLASS*)
    begin
      /* Если одна из дат не указана */
      if ((DREP_DATE is null) or (DREP_DATE_TO is null)) then
        /* Если спецификация также не имеет связей */
        if (NHAVE_LINK = 0) then
          NTASK_CLASS := NCLASS_WO_LINKS;
        end if;
      else
        /* Если нет связанных документов */
        if (NHAVE_LINK = 0) then
          /* Если дата запуска меньше текущей даты */
          if (DREP_DATE <= sysdate) then
            NTASK_CLASS := NCLASS_WITH_DEFICIT;
          end if;
          /* Если дата больше текущей даты */
          if (DREP_DATE > sysdate) then
            NTASK_CLASS := NCLASS_FUTURE_DATE;
          end if;
        end if;
      end if;
      /* Если класс не определен */
      if (NTASK_CLASS is null) then
        /* Если дефицит запуска <> 0 */
        if (NDEFRESLIZ <> 0) then
          /* Если дефицит выпуска = 0 */
          if (NDEFSTART = 0) then
            NTASK_CLASS := NCLASS_WO_DEFICIT;
          else
            NTASK_CLASS := NCLASS_WITH_DEFICIT;
          end if;
        else
          /* Если дефицит выпуска = 0 */
          if (NDEFSTART = 0) then
            NTASK_CLASS := NCLASS_WO_DEFICIT;
          else
            /* Если дефицит запуска = 0 и выпуск факт = 0 */
            if ((NDEFRESLIZ = 0) and (NREL_FACT = 0)) then
              NTASK_CLASS := NCLASS_FULL_DEFICIT;
            end if;
            /* Если дефицит запуска = 0 и выпуск факт <> 0 */
            if ((NDEFRESLIZ = 0) and (NREL_FACT <> 0)) then
              NTASK_CLASS := NCLASS_PART_DEFICIT;
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
      NCOMPANY              in number,   -- Рег. номер организации
      SSORT_FIELD           in varchar2, -- Тип сортировки
      NFCPRODPLAN           in number,   -- Рег. номер плана
      NFCPRODPLANSP         in number,   -- Рег. номер спецификации плана
      NTASK_CLASS           in number,   -- Класс задачи (см. константы NCLASS_*)
      NTYPE                 out number,  -- Тип задачи (см. константы NTASK_TYPE_*)
      SDETAIL_LIST          out varchar2 -- Ссылки на детализацию
    )
    is
    begin
      /* Исходим сортировка по "Дата запуска" */
      if (SSORT_FIELD = 'DREP_DATE') then
        /* Если класс "С дефицитом запуска или датой меньше текущей" */
        if (NTASK_CLASS = NCLASS_WITH_DEFICIT) then
          /* Проверяем деталь или изделие */
          begin
            select NTASK_TYPE_RL_WITH_DL
              into NTYPE
              from DUAL
             where exists (select null
                      from FCPRODPLANSP SP
                     where SP.PRN = NFCPRODPLAN
                       and SP.UP_LEVEL = NFCPRODPLANSP);
          exception
            when others then
              NTYPE := NTASK_TYPE_RL_WITH_GP;
          end;
          /* Проверяем наличие связей с маршрутными листами */
          if (LINK_FCROUTLST_CHECK(NCOMPANY => NCOMPANY, NFCPRODPLANSP => NFCPRODPLANSP, NSTATE => 0) = 0) then
            /* Указываем, что маршрутных листов нет */
            SDETAIL_LIST := 'Нет маршрутных листов';
            NTYPE        := NTASK_TYPE_EMPTY;
          else
            /* Указываем, что маршрутные листы есть */
            SDETAIL_LIST := 'Маршрутные листы';
          end if;
        else
          /* Не отображаем информацию о маршрутных листах */
          NTYPE        := NTASK_TYPE_EMPTY;
          SDETAIL_LIST := null;
        end if;
      else
        /* Исходим от класса */
        case
          /* Если класс "Без дефицита выпуска" */
          when (NTASK_CLASS = NCLASS_WO_DEFICIT) then
            /* Проверяем наличией связей с приходов из подразделений */
            if (LINK_INCOMEFROMDEPS_CHECK(NCOMPANY => NCOMPANY, NFCPRODPLANSP => NFCPRODPLANSP, NSTATE => 2) = 0) then
              /* Указываем, что приходов из подразделений нет */
              SDETAIL_LIST := 'Нет приходов из подразделений';
              NTYPE        := NTASK_TYPE_EMPTY;
            else
              /* Указываем, что приходы из подразделений есть */
              SDETAIL_LIST := 'Приход из подразделений';
              NTYPE        := NTASK_TYPE_INC_DEPS;
            end if;
          /* Если класс "С частичным дефицитом выпуска" */
          when (NTASK_CLASS = NCLASS_PART_DEFICIT) then
            /* Проверяем наличией связей с приходов из подразделений */
            if (LINK_INCOMEFROMDEPS_CHECK(NCOMPANY => NCOMPANY, NFCPRODPLANSP => NFCPRODPLANSP) = 0) then
              /* Указываем, что приходов из подразделений нет */
              SDETAIL_LIST := 'Нет приходов из подразделений';
              NTYPE        := NTASK_TYPE_EMPTY;
            else
              /* Указываем, что приходы из подразделений есть */
              SDETAIL_LIST := 'Приход из подразделений';
              NTYPE        := NTASK_TYPE_INC_DEPS_RL;
            end if;
          /* Если класс "С дефицитом запуска или датой меньше текущей" или "С полным дефицитом выпуска" */
          when ((NTASK_CLASS = NCLASS_FULL_DEFICIT) or (NTASK_CLASS = NCLASS_WITH_DEFICIT)) then
            /* Проверяем наличие связей с маршрутными листами */
            if (LINK_FCROUTLST_CHECK(NCOMPANY => NCOMPANY, NFCPRODPLANSP => NFCPRODPLANSP, NSTATE => 1) = 0) then
              /* Указываем, что маршрутных листов нет */
              SDETAIL_LIST := 'Нет маршрутных листов';
              NTYPE        := NTASK_TYPE_EMPTY;
            else
              /* Указываем, что маршрутные листы есть */
              SDETAIL_LIST := 'Маршрутные листы';
              NTYPE        := NTASK_TYPE_RL;
            end if;
          /* Класс не поддерживается */
          else
            /* Для данных классов ничего не выводится */
            NTYPE        := NTASK_TYPE_EMPTY;
            SDETAIL_LIST := null;
        end case;
      end if;
    end GET_TASK_TYPE;

    /* Формирование цветовых характеристик для задачи */
    procedure GET_TASK_COLORS
    (
      NTASK_CLASS             in number,      -- Класс задачи (см. константы NCLASS_*)
      STASK_BG_COLOR          out varchar2,   -- Цвет заливки спецификации
      STASK_BG_PROGRESS_COLOR out varchar2,   -- Цвет заливки прогресса спецификации
      STASK_TEXT_COLOR        in out varchar2 -- Цвет текста
    )
    is
    begin
      /* Исходим от класса задачи */
      case NTASK_CLASS
        /* Без дефицита выпуска */
        when NCLASS_WO_DEFICIT then
          STASK_BG_COLOR          := SBG_COLOR_GREEN;
          STASK_TEXT_COLOR        := STEXT_COLOR_GREY;
          STASK_BG_PROGRESS_COLOR := null;
        /* С частичным дефицитом выпуска */
        when NCLASS_PART_DEFICIT then
          STASK_BG_COLOR          := SBG_COLOR_GREEN;
          STASK_BG_PROGRESS_COLOR := SBG_COLOR_YELLOW;
          STASK_TEXT_COLOR        := STEXT_COLOR_GREY;
        /* С полным дефицитом выпуска */
        when NCLASS_FULL_DEFICIT then
          STASK_BG_COLOR          := SBG_COLOR_YELLOW;
          STASK_TEXT_COLOR        := null;
          STASK_BG_PROGRESS_COLOR := null;
        /* С дефицитом запуска или датой меньше текущей */
        when NCLASS_WITH_DEFICIT then
          STASK_BG_COLOR          := SBG_COLOR_RED;
          STASK_TEXT_COLOR        := null;
          STASK_BG_PROGRESS_COLOR := null;
        /* Дата анализа еще не наступила */
        when NCLASS_FUTURE_DATE then
          STASK_BG_COLOR   := SBG_COLOR_GREY;
          STASK_TEXT_COLOR := null;
          STASK_BG_PROGRESS_COLOR := null;
        /* Задача без связи */
        when NCLASS_WO_LINKS then
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
    /* Определяем уровень фильтра */
    NLEVEL_FILTER := COALESCE(NLEVEL, NMAX_LEVEL);
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
               where level <= NLEVEL_FILTER
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
      /* Если класс задачи "С частичным дефицитом выпуска" */
      if (NTASK_CLASS = NCLASS_PART_DEFICIT) then
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
                      and NLEVEL_FILTER >= C.NTASK_LEVEL + 1)
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

  /* Инициализация каталогов раздела "Планы и отчеты производства изделий" для панели "Производственная программа" */
  procedure FCPRODPLAN_PP_CTLG_INIT
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
                           and P.COMPANY = GET_SESSION_COMPANY()
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
                   and T.COMPANY = GET_SESSION_COMPANY()
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
  end FCPRODPLAN_PP_CTLG_INIT;
  
  /*
    Процедуры панели "Производственный план цеха"
  */
  
  /* Изменение приоритета партии маршрутного листа */
  procedure FCROUTLST_PRIOR_PARTY_UPDATE
  (
    NFCROUTLST              in number,         -- Рег. номер маршрутного листа
    SPRIOR_PARTY            in varchar         -- Новое значение приоритета партии
  )
  is
    RFCROUTLST              FCROUTLST%rowtype; -- Запись маршрутного листа
  begin
    /* Дорабатывается */
    P_EXCEPTION(0, 'На стадии разработки.');
    /* Проверяем нет ли лишних символов */
    if ((SPRIOR_PARTY is not null) and (REGEXP_COUNT(SPRIOR_PARTY, '[^0123456789]+') > 0)) then
      P_EXCEPTION(0, 'Значение приоритета должно быть целым числом.');
    end if;
    /* Считываем запись маршрутного листа */
    UTL_FCROUTLST_GET(NFCROUTLST => NFCROUTLST, RFCROUTLST => RFCROUTLST);
    /* Исправляем приоритет партии */
    RFCROUTLST.PRIOR_PARTY := TO_NUMBER(SPRIOR_PARTY);
    /* Базовое исправление маршрутного листа */
    P_FCROUTLST_BASE_UPDATE(NRN            => RFCROUTLST.RN,
                            NCOMPANY       => RFCROUTLST.COMPANY,
                            NDOCTYPE       => RFCROUTLST.DOCTYPE,
                            SDOCPREF       => RFCROUTLST.DOCPREF,
                            SDOCNUMB       => RFCROUTLST.DOCNUMB,
                            DDOCDATE       => RFCROUTLST.DOCDATE,
                            SBARCODE       => RFCROUTLST.BARCODE,
                            NJUR_PERS      => RFCROUTLST.JUR_PERS,
                            NSTATE         => RFCROUTLST.STATE,
                            DCHANGE_DATE   => RFCROUTLST.CHANGE_DATE,
                            NFACEACC       => RFCROUTLST.FACEACC,
                            NPR_COND       => RFCROUTLST.PR_COND,
                            NMATRES        => RFCROUTLST.MATRES,
                            NNOMCLASSIF    => RFCROUTLST.NOMCLASSIF,
                            NARTICLE       => RFCROUTLST.ARTICLE,
                            NQUANT         => RFCROUTLST.QUANT,
                            NMATRES_PLAN   => RFCROUTLST.MATRES_PLAN,
                            NMEASURE_TYPE  => RFCROUTLST.MEASURE_TYPE,
                            NQUANT_PLAN    => RFCROUTLST.QUANT_PLAN,
                            NMATRES_FACT   => RFCROUTLST.MATRES_FACT,
                            NQUANT_FACT    => RFCROUTLST.QUANT_FACT,
                            DOUT_DATE      => RFCROUTLST.OUT_DATE,
                            NBLANK         => RFCROUTLST.BLANK,
                            NDETAILS_COUNT => RFCROUTLST.DETAILS_COUNT,
                            NSUPPLY        => RFCROUTLST.SUPPLY,
                            NSTORAGE       => RFCROUTLST.STORAGE,
                            NSTORAGE_IN    => RFCROUTLST.STORAGE_IN,
                            NPRODCMP       => RFCROUTLST.PRODCMP,
                            NPRODCMPSP     => RFCROUTLST.PRODCMPSP,
                            DREL_DATE      => RFCROUTLST.REL_DATE,
                            NREL_QUANT     => RFCROUTLST.REL_QUANT,
                            NPRIOR_ORDER   => RFCROUTLST.PRIOR_ORDER,
                            NPRIOR_PARTY   => RFCROUTLST.PRIOR_PARTY,
                            NROUTSHT       => RFCROUTLST.ROUTSHT,
                            NROUTE         => RFCROUTLST.ROUTE,
                            NCALC_SCHEME   => RFCROUTLST.CALC_SCHEME,
                            NPER_MATRES    => RFCROUTLST.PER_MATRES,
                            NCOST_ARTICLE  => RFCROUTLST.COST_ARTICLE,
                            NVALID_DOCTYPE => RFCROUTLST.VALID_DOCTYPE,
                            SVALID_DOCNUMB => RFCROUTLST.VALID_DOCNUMB,
                            DVALID_DOCDATE => RFCROUTLST.VALID_DOCDATE,
                            SNOTE          => RFCROUTLST.NOTE,
                            NPARTY         => RFCROUTLST.PARTY,
                            DEXEC_DATE     => RFCROUTLST.EXEC_DATE,
                            SSEP_NUMB      => RFCROUTLST.SEP_NUMB,
                            SINT_NUMB      => RFCROUTLST.INT_NUMB);
  end FCROUTLST_PRIOR_PARTY_UPDATE;
  
  /* Изменение заказа маршрутного листа */
  procedure FCROUTLST_FACEACC_UPDATE
  (
    NFCROUTLST              in number,         -- Рег. номер маршрутного листа
    SFACEACC_NUMB           in varchar,        -- Номер заказа
    NFCPRODPLANSP           in number          -- Рег. номер строки плана
  )
  is
    RFCROUTLST              FCROUTLST%rowtype; -- Запись маршрутного листа
    NFACEACC                PKG_STD.TREF;      -- Рег. номер лицевого счета
    
    /* Проверка наличия связей с другими строками плана */
    function FCROUTLST_CHECK_OTHER_PROD
    (
      NFCROUTLST            in number,       -- Рег. номер маршрутного листа
      NFCPRODPLANSP         in number        -- Рег. номер строки плана
    ) return                number           -- Наличие других связей (0 - нет, 1 - да)
    is
      NRESULT               PKG_STD.TNUMBER; -- Наличие других связей (0 - нет, 1 - да)
    begin
      /* Проверка наличия других связей */
      begin
        select 1
          into NRESULT
          from DUAL
         where exists (select null
                  from DOCLINKS D
                 where D.OUT_UNITCODE = 'CostRouteLists'
                   and D.OUT_DOCUMENT = NFCROUTLST
                   and D.IN_UNITCODE = 'CostProductPlansSpecs'
                   and D.IN_DOCUMENT <> NFCPRODPLANSP);
      exception
        when others then
          NRESULT := 0;
      end;
      /* Возвращаем результат */
      return NRESULT;
    end FCROUTLST_CHECK_OTHER_PROD;
  begin
    /* Дорабатывается */
    P_EXCEPTION(0, 'На стадии разработки.');
    /* Считываем запись маршрутного листа */
    UTL_FCROUTLST_GET(NFCROUTLST => NFCROUTLST, RFCROUTLST => RFCROUTLST);
    /* Определяем рег. номер лицевого счета */
    FIND_FACEACC_NUMB(NFLAG_SMART  => 0,
                      NFLAG_OPTION => 1,
                      NCOMPANY     => RFCROUTLST.COMPANY,
                      SNUMB        => SFACEACC_NUMB,
                      NRN          => NFACEACC);
    /* Если есть связи с другими строками плана */
    if (FCROUTLST_CHECK_OTHER_PROD(NFCROUTLST => NFCROUTLST, NFCPRODPLANSP => NFCPRODPLANSP) = 1) then
      null;
    end if;
  end FCROUTLST_FACEACC_UPDATE;
  
  /* Получение таблицы маршрутных листов, связанных со спецификацией плана */
  procedure FCROUTLST_DEPT_DG_GET
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
    NFCROUTLST_IDENT        PKG_STD.TREF;                          -- Рег. номер идентификатора отмеченных записей маршрутных листов
    NFCMATRESOURCE          PKG_STD.TREF;                          -- Рег. номер материального ресурса записи спецификации плана
    NFCROUTLST              PKG_STD.TREF;                          -- Рег. номер связанного маршрутного листа
    NFCPRODPLANSP_MAIN      PKG_STD.TREF;                          -- Рег. номер основного состава из "Производственная программа"
    NFCROUTLSTORD_QUANT     PKG_STD.TLNUMBER;                      -- Сумма "Количество" в спецификации "Заказы" маршрутного листа
    
    /* Считывание материального ресурса спецификации плана */
    function MATRES_RN_GET
    (
      NFCPRODPLANSP         in number     -- Рег. номер спецификации плана
    ) return                number        -- Рег. номер материального ресурса
    is
      NRESULT               PKG_STD.TREF; -- Рег. номер материального ресурса
    begin
      /* Считываем рег. номер материального ресурса */
      begin
        select T.MATRES into NRESULT from FCPRODPLANSP T where T.RN = NFCPRODPLANSP;
      exception
        when others then
          P_EXCEPTION(0,
                      'Ошибка считывания материального ресурса спецификации плана.');
      end;
      /* Возвращаем результат */
      return NRESULT;
    end MATRES_RN_GET;
    
    /* Проверка прямой связи между МЛ и спецификацией плана "Заказы" */
    function FCROUTLSTORD_QUANT_GET
    (
      NFCROUTLST            in number         -- Рег. номер маршрутного листа
    ) return                number            -- Сумма "Количество" в спецификации "Заказы"
    is
      NRESULT               PKG_STD.TLNUMBER; -- Сумма "Количество" в спецификации "Заказы"
    begin
      /* Считываем сумму "Количество" из спецификации "Заказы" */
      begin
        select COALESCE(sum(T.QUANT), 0) into NRESULT from FCROUTLSTORD T where T.PRN = NFCROUTLST;
      exception
        when others then
          NRESULT := 0;
      end;
      /* Возвращаем результат */
      return NRESULT;
    end FCROUTLSTORD_QUANT_GET;
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
                                               SCAPTION   => 'Документ (тип, №, дата)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NQUANT',
                                               SCAPTION   => 'Количество план',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NPROCENT',
                                               SCAPTION   => 'Готовность партии',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NPRIOR_PARTY',
                                               SCAPTION   => 'Приоритет партии',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SPROD_ORDER',
                                               SCAPTION   => 'Заказ',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    /*! Пока отключен */
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCHANGE_FACEACC',
                                               SCAPTION   => 'Изменить заказ',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false,
                                               BORDER     => true);
    /* Считываем рег. номер связанной спецификации из "Производственная программа" */
    NFCPRODPLANSP_MAIN := UTL_FCPRODPLANSP_MAIN_GET(NCOMPANY => NCOMPANY, NFCPRODPLANSP => NFCPRODPLANSP);
    /* Если спецификация производственной программы найдена */
    if (NFCPRODPLANSP_MAIN is not null) then
      /* Считывание материального ресурса спецификации плана */
      NFCMATRESOURCE := MATRES_RN_GET(NFCPRODPLANSP => NFCPRODPLANSP_MAIN);
      /* Инициализируем список маршрутных листов */
      UTL_FCROUTLST_IDENT_INIT(NFCPRODPLANSP => NFCPRODPLANSP_MAIN, NIDENT => NFCROUTLST_IDENT);
      /* Обходим данные */
      begin
        /* Добавляем подсказку совместимости */
        CSQL := PKG_SQL_BUILD.COMPATIBLE(SSQL => CSQL);
        /* Формируем запрос */
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => 'select *');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '  from (select D.*,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.SQLROWNUM() || ' NROW');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '          from (select P.NRN,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.SDOC_INFO,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.NQUANT,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       case when (P.NT_SHT_PLAN <> 0) then P.NLABOUR_FACT / P.NT_SHT_PLAN * 100 else 0 end NPROCENT,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.NPRIOR_PARTY,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.SPROD_ORDER');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  from (select T.RN           NRN,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               DT.DOCCODE ||');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               '', '' || TRIM(T.DOCPREF) ||');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               ''-'' || TRIM(T.DOCNUMB) ||');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               '', '' || TO_CHAR(T.DOCDATE, ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'dd.mm.yyyy') || ') as SDOC_INFO,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               T.QUANT        NQUANT,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               (select SUM(SP.LABOUR_FACT)');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  from FCROUTLSTSP SP');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 where SP.PRN = T.RN) NLABOUR_FACT,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               (select SUM(SP.T_SHT_PLAN)');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  from FCROUTLSTSP SP');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 where SP.PRN = T.RN) NT_SHT_PLAN,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               T.PRIOR_PARTY  NPRIOR_PARTY,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               (select F.NUMB from FACEACC F where T.FACEACC = F.RN ) SPROD_ORDER');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                          from FCROUTLST T,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               DOCTYPES DT');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                         where T.RN in (select SL.DOCUMENT');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                          from SELECTLIST SL');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                         where SL.IDENT = :NFCROUTLST_IDENT');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                           and SL.UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostRouteLists') || ')');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and T.COMPANY = :NCOMPANY');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and T."STATE" = ' || PKG_SQL_BUILD.WRAP_NUM(NVALUE => 1));
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and T.MATRES = :NFCMATRESOURCE');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and DT.RN = T.DOCTYPE');
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
        PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NFCROUTLST_IDENT', NVALUE => NFCROUTLST_IDENT);
        PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NFCMATRESOURCE', NVALUE => NFCMATRESOURCE);
        /* Описываем структуру записи курсора */
        PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 1);
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
          /* Читаем данные из курсора */
          PKG_SQL_DML.COLUMN_VALUE_NUM(ICURSOR => ICURSOR, IPOSITION => 1, NVALUE => NFCROUTLST);
          /* Добавляем колонку с рег. номером */
          PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NRN', NVALUE => NFCROUTLST, BCLEAR => true);
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
          /* Проверяем наличие прямой связи между МЛ и спецификацией плана */
          if (PKG_DOCLINKS.FIND(NFLAG_SMART       => 1,
                                SIN_UNITCODE      => 'CostProductPlansSpecs',
                                NIN_DOCUMENT      => NFCPRODPLANSP_MAIN,
                                NIN_PRN_DOCUMENT  => null,
                                SOUT_UNITCODE     => 'CostRouteLists',
                                NOUT_DOCUMENT     => NFCROUTLST,
                                NOUT_PRN_DOCUMENT => null) = 1) then
            /* Получаем сумму "Количество" из спецификации "Заказы" */
            NFCROUTLSTORD_QUANT := FCROUTLSTORD_QUANT_GET(NFCROUTLST => NFCROUTLST);
            /* Если сумма "Количество" в "Заказы" больше 0 */
            if (NFCROUTLSTORD_QUANT > 0) then
              /* Указываем её */
              PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NQUANT', NVALUE => NFCROUTLSTORD_QUANT);
            else
              /* Берем из заголовка МЛ */
              PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                                    SNAME     => 'NQUANT',
                                                    ICURSOR   => ICURSOR,
                                                    NPOSITION => 3);
            end if;
          else
            /* Указываем 0 */
            PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NQUANT', NVALUE => 0);
          end if;
          PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW => RDG_ROW, SNAME => 'NPROCENT', ICURSOR => ICURSOR, NPOSITION => 4);
          PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                                SNAME     => 'NPRIOR_PARTY',
                                                ICURSOR   => ICURSOR,
                                                NPOSITION => 5);
          PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                                SNAME     => 'SPROD_ORDER',
                                                ICURSOR   => ICURSOR,
                                                NPOSITION => 6);
          PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NCHANGE_FACEACC', SVALUE => null);
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
    end if;
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TDATA_GRID_TO_XML(RDATA_GRID => RDG, NINCLUDE_DEF => NINCLUDE_DEF);
  exception
    when others then
      /* Очищаем отмеченные маршрутные листы */
      P_SELECTLIST_CLEAR(NIDENT => NFCROUTLST_IDENT);
      raise;
  end FCROUTLST_DEPT_DG_GET;
  
  /* Получение таблицы заказов маршрутного листа */
  procedure FCROUTLSTORD_DEPT_DG_GET
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
    SPROD_ORDER             PKG_STD.TSTRING;                       -- Заказ МЛ
    NQUANT                  PKG_STD.TLNUMBER;                      -- Количество МЛ
    NPRIOR_ORDER            PKG_STD.TLNUMBER;                      -- Приоритет заказа МЛ
    
    /* Проверка наличия записей спецификации "Заказы" */
    function FCROUTLSTORD_EXISTS
    (
      NFCROUTLST            in number        -- Рег. номер маршрутного листа
    ) return                number           -- Наличие записей спецификации заказы (0 - нет, 1 - да)
    is
      NRESULT               PKG_STD.TNUMBER; -- Наличие записей спецификации заказы (0 - нет, 1 - да)
    begin
      /* Проверяем наличие */
      begin
        select 1
          into NRESULT
          from DUAL
         where exists (select null
                  from FCROUTLSTORD T
                 where T.PRN = NFCROUTLST
                   and ROWNUM = 1);
      exception
        when others then
          NRESULT := 0;
      end;
      /* Возвращаем результат */
      return NRESULT;
    end FCROUTLSTORD_EXISTS;
    
    /* Получение значений из заголовка МЛ */
    procedure FCROUTLST_INFO_GET
    (
      NFCROUTLST            in number,    -- Рег. номер маршрутного листа
      SPROD_ORDER           out varchar2, -- Заказ
      NQUANT                out number,   -- Количество
      NPRIOR_ORDER          out number    -- Приоритет заказа
    )
    is
    begin
      /* Считываем информацию из заголовка */
      begin
        select (select F.NUMB from FACEACC F where T.FACEACC = F.RN),
               T.QUANT,
               T.PRIOR_ORDER
          into SPROD_ORDER,
               NQUANT,
               NPRIOR_ORDER
          from FCROUTLST T
         where T.RN = NFCROUTLST;
      exception
        when others then
          SPROD_ORDER  := null;
          NQUANT       := null;
          NPRIOR_ORDER := null;
      end;
    end FCROUTLST_INFO_GET;
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
                                               SNAME      => 'SPROD_ORDER',
                                               SCAPTION   => 'Заказ',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NQUANT',
                                               SCAPTION   => 'Количество',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NPRIOR_ORDER',
                                               SCAPTION   => 'Приоритет заказа',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    /* Если у маршрутного листа есть записи спецификации "Заказы" - работаем по ним */
    if (FCROUTLSTORD_EXISTS(NFCROUTLST => NFCROUTLST) = 1) then
      /* Обходим данные */
      begin
        /* Добавляем подсказку совместимости */
        CSQL := PKG_SQL_BUILD.COMPATIBLE(SSQL => CSQL);
        /* Формируем запрос */
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => 'select *');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '  from (select D.*,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.SQLROWNUM() || ' NROW');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '          from (select T.RN          NRN,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       F.NUMB        SPROD_ORDER,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.QUANT       NQUANT,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.PRIOR_ORDER NPRIOR_ORDER,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  from FCROUTLSTORD T');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       left outer join FACEACC F on T.PROD_ORDER = F.RN');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                 where T.PRN = :NFCROUTLST');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T.COMPANY = :NCOMPANY');
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
        PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NFCROUTLST', NVALUE => NFCROUTLST);
        /* Описываем структуру записи курсора */
        PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 1);
        PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 2);
        PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 3);
        PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 4);
        PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 5);
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
                                                SNAME     => 'SPROD_ORDER',
                                                ICURSOR   => ICURSOR,
                                                NPOSITION => 2);
          PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW => RDG_ROW, SNAME => 'NQUANT', ICURSOR => ICURSOR, NPOSITION => 3);
          PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                                SNAME     => 'NPRIOR_ORDER',
                                                ICURSOR   => ICURSOR,
                                                NPOSITION => 4);
          /* Добавляем строку в таблицу */
          PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW);
        end loop;
      exception
        when others then
          PKG_SQL_DML.CLOSE_CURSOR(ICURSOR => ICURSOR);
          raise;
      end;
    else
      /* Считываем значения из заголовка МЛ */
      FCROUTLST_INFO_GET(NFCROUTLST   => NFCROUTLST,
                         SPROD_ORDER  => SPROD_ORDER,
                         NQUANT       => NQUANT,
                         NPRIOR_ORDER => NPRIOR_ORDER);
      /* Добавляем колонки с данными */
      PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NRN', NVALUE => NFCROUTLST, BCLEAR => true);
      PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'SPROD_ORDER', SVALUE => SPROD_ORDER);
      PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NQUANT', NVALUE => NQUANT);
      PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NPRIOR_ORDER', NVALUE => NPRIOR_ORDER);
      /* Добавляем строку в таблицу */
      PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW);
    end if;
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TDATA_GRID_TO_XML(RDATA_GRID => RDG, NINCLUDE_DEF => NINCLUDE_DEF);
  end FCROUTLSTORD_DEPT_DG_GET;
  
  /* Получение таблицы ПиП на основании маршрутного листа, связанных со спецификацией плана */
  procedure INCOMEFROMDEPS_DEPT_DG_GET
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
    NFCPRODPLANSP_MAIN      PKG_STD.TREF;                          -- Рег. номер основного состава из "Производственная программа"
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
                                               SCAPTION   => 'Документ (тип, №, дата)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NQUANT_FACT',
                                               SCAPTION   => 'Количество сдано',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DDUE_DATE',
                                               SCAPTION   => 'Дата сдачи',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    /* Считываем рег. номер связанной спецификации из "Производственная программа" */
    NFCPRODPLANSP_MAIN := UTL_FCPRODPLANSP_MAIN_GET(NCOMPANY => NCOMPANY, NFCPRODPLANSP => NFCPRODPLANSP);
    /* Если спецификация производственной программы найдена */
    if (NFCPRODPLANSP_MAIN is not null) then
      /* Инициализируем список маршрутных листов */
      UTL_FCROUTLST_IDENT_INIT(NFCPRODPLANSP => NFCPRODPLANSP_MAIN, NIDENT => NFCROUTLST_IDENT);
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
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       (select SUM(SP.QUANT_FACT)');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                          from INCOMEFROMDEPSSPEC SP');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                         where SP.PRN = T.RN) NQUANT_FACT,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                        T.WORK_DATE as DDUE_DATE');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  from INCOMEFROMDEPS T,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       DOCTYPES DT');
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
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                        and L.IN_DOCUMENT  = SL.DOCUMENT');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                        and L.IN_UNITCODE  = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostRouteLists'));
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                        and L.OUT_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'IncomFromDeps') || ')))');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T.COMPANY = :NCOMPANY');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T.DOC_TYPE = DT.RN');
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
        PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NFCPRODPLANSP', NVALUE => NFCPRODPLANSP_MAIN);
        PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NFCROUTLST_IDENT', NVALUE => NFCROUTLST_IDENT);
        /* Описываем структуру записи курсора */
        PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 1);
        PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 2);
        PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 3);
        PKG_SQL_DML.DEFINE_COLUMN_DATE(ICURSOR => ICURSOR, IPOSITION => 4);
        PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 5);
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
          PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                                SNAME     => 'NQUANT_FACT',
                                                ICURSOR   => ICURSOR,
                                                NPOSITION => 3);
          PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLD(RROW      => RDG_ROW,
                                                SNAME     => 'DDUE_DATE',
                                                ICURSOR   => ICURSOR,
                                                NPOSITION => 4);
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
    end if;
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TDATA_GRID_TO_XML(RDATA_GRID => RDG, NINCLUDE_DEF => NINCLUDE_DEF);
  exception
    when others then
      /* Очищаем отмеченные маршрутные листы */
      P_SELECTLIST_CLEAR(NIDENT => NFCROUTLST_IDENT);
      raise;
  end INCOMEFROMDEPS_DEPT_DG_GET;
  
  /* Получение таблицы спецификаций планов и отчетов производства изделий */
  procedure FCPRODPLANSP_DEPT_DG_GET
  (
    NFCPRODPLAN             in number,                             -- Рег. номер планов и отчетов производства изделий
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
    NFCPRODPLANSP           PKG_STD.TREF;                          -- Рег. номер спецификации плана
    DDATE                   PKG_STD.TLDATE := sysdate;             -- Текущая дата
    NSUM_PLAN               PKG_STD.TLNUMBER;                      -- Сумма плана по строке
    NSUM_FACT               PKG_STD.TLNUMBER;                      -- Сумма факта по строке
    DDATE_FROM              PKG_STD.TLDATE;                        -- Дата начала месяца
    DDATE_TO                PKG_STD.TLDATE;                        -- Дата окончания месяца
    NFCROUTLST_IDENT        PKG_STD.TREF;                          -- Рег. номер идентификатора отмеченных записей маршрутных листов
    NFCPRODPLANSP_MAIN      PKG_STD.TREF;                          -- Рег. номер основного состава из "Производственная программа"
    NMODIF                  PKG_STD.TREF;                          -- Рег. номер модификации
    
    /* Считывание номенклатуры по спецификации плана */
    function FCPRODPLANSP_MODIF_GET
    (
      NFCPRODPLANSP         in number     -- Рег. номер связанной спецификации плана
    ) return                number        -- Рег. номер модификации номенклатуры
    is
      NRESULT               PKG_STD.TREF; -- Рег. номер модификации номенклатуры
    begin
      /* Считываем рег. номер модификации спецификации плана */
      begin
        select F.NOMEN_MODIF
          into NRESULT
          from FCPRODPLANSP T,
               FCMATRESOURCE F
         where T.RN = NFCPRODPLANSP
           and F.RN = T.MATRES;
      exception
        when others then
          NRESULT := null;
      end;
      /* Возвращаем результат */
      return NRESULT;
    end FCPRODPLANSP_MODIF_GET;
    
    /* Инициализация дней месяца */
    procedure INIT_DAYS
    (
      RDG                   in out nocopy PKG_P8PANELS_VISUAL.TDATA_GRID, -- Описание таблицы
      DDATE_FROM            in date,                                      -- Дата начала месяца
      DDATE_TO              in date                                       -- Дата окончания месяца
    )
    is
      DDATE                 PKG_STD.TLDATE;                               -- Сформированная дата дня
      NMONTH                PKG_STD.TNUMBER;                              -- Текущий месяц
      NYEAR                 PKG_STD.TNUMBER;                              -- Текущий год
      SDATE_NAME            PKG_STD.TSTRING;                              -- Строковое представление даты для наименования колонки
      SPARENT_NAME          PKG_STD.TSTRING;                              -- Наименование родительской строки
    begin
      /* Считываем месяц и год текущей даты */
      NMONTH := D_MONTH(DDATE => sysdate);
      NYEAR  := D_YEAR(DDATE => sysdate);
      /* Цикл по дням месяца */
      for I in D_DAY(DDATE => DDATE_FROM) .. D_DAY(DDATE => DDATE_TO)
      loop
        /* Формируем дату дня */
        DDATE := TO_DATE(TO_CHAR(I) || '.' || TO_CHAR(NMONTH) || '.' || TO_CHAR(NYEAR), 'dd.mm.yyyy');
        /* Строковое представление даты для наименования колонки */
        SDATE_NAME := TO_CHAR(DDATE, SCOL_PATTERN_DATE);
        /* Формируем наименование родительской строки */
        SPARENT_NAME := 'N_' || SDATE_NAME || '_PLAN_FACT';
        /* Описываем родительскую колонку таблицы данных */
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                                   SNAME      => SPARENT_NAME,
                                                   SCAPTION   => LPAD(D_DAY(DDATE), 2, '0'),
                                                   SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                                   SPARENT    => 'NVALUE_BY_DAYS');
      end loop;
    end INIT_DAYS;
  begin
    /* Читем сортировки */
    RO := PKG_P8PANELS_VISUAL.TORDERS_FROM_XML(CORDERS => CORDERS);
    /* Преобразуем номер и размер страницы в номер строк с и по */
    PKG_P8PANELS_VISUAL.UTL_ROWS_LIMITS_CALC(NPAGE_NUMBER => NPAGE_NUMBER,
                                             NPAGE_SIZE   => NPAGE_SIZE,
                                             NROW_FROM    => NROW_FROM,
                                             NROW_TO      => NROW_TO);
    /* Инициализируем таблицу данных */
    RDG := PKG_P8PANELS_VISUAL.TDATA_GRID_MAKE(BFIXED_HEADER => true, NFIXED_COLUMNS => 6);
    /* Описываем колонки таблицы данных */
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NRN',
                                               SCAPTION   => 'Рег. номер',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SSTATUS',
                                               SCAPTION   => 'Статус',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SPROD_ORDER',
                                               SCAPTION   => 'Заказ',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true,
                                               SHINT      => 'Содержит ссылку на связанные сдаточные накладные.',
                                               NWIDTH     => 100);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SMATRES_CODE',
                                               SCAPTION   => 'Обозначение',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true,
                                               SHINT      => 'Содержит ссылку на связанные маршрутные листы.<br><br>' ||
                                                             'Цвет залики отражает следующие статусы:<br>' ||
                                                             '<b style="color:lightgreen">Зеленый</b> - "Факт" равен "План";<br>' ||
                                                             '<b style="color:lightblue">Голубой</b> - "План" меньше или равно "Факт" + "Запущено";<br>' ||
                                                             '<b style="color:#F0E68C">Желтый</b> - предыдущие условия не выполнены и на текущую дату сумма "Количество план" = 0 или меньше "План", то "Факт" больше или равно "План". ' ||
                                                             'Иначе сумма "Количество факт" больше или равно сумме "Количество план";<br>' ||
                                                             '<b style="color:lightcoral">Красный</b> - ни одно из предыдущих условий не выполнено.<br>',
                                               NWIDTH     => 120);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SMATRES_NAME',
                                               SCAPTION   => 'Наименование',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true,
                                               NWIDTH     => 200);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NMAIN_QUANT',
                                               SCAPTION   => 'План',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               NWIDTH     => 80);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NREL_FACT',
                                               SCAPTION   => 'Факт',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               NWIDTH     => 80);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NFCROUTLST_QUANT',
                                               SCAPTION   => 'Запущено',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               NWIDTH     => 80);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NVALUE_BY_DAYS',
                                               SCAPTION   => 'План/факт по дням',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               SHINT      => 'Значения по спецификации "График сдачи":<br>' ||
                                                             'Черный - значение "Количество план";<br>' ||
                                                             '<b style="color:blue">Синий</b> - значение "Количество факт".<br><br>' ||
                                                             'Заливка <b style="color:lightgrey">серым</b> определяет текущий день.');
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NSUM_PLAN',
                                               SCAPTION   => 'Сумма "Количество план"',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NSUM_FACT',
                                               SCAPTION   => 'Сумма "Количество факт"',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    /* Считываем первый и последний день месяца */
    P_FIRST_LAST_DAY(DCALCDATE => sysdate, DBGNDATE => DDATE_FROM, DENDDATE => DDATE_TO);
    /* Инициализация дней месяца */
    INIT_DAYS(RDG => RDG, DDATE_FROM => DDATE_FROM, DDATE_TO => DDATE_TO);
    /* Обходим данные */
    begin
      /* Добавляем подсказку совместимости */
      CSQL := PKG_SQL_BUILD.COMPATIBLE(SSQL => CSQL);
      /* Формируем запрос */
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => 'select *');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '  from (select D.*,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.SQLROWNUM() || ' NROW');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '          from (select T.RN NRN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       (select PORD.NUMB from FACEACC PORD where (PORD.RN = T.PROD_ORDER)) SPROD_ORDER,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       MRES.CODE SMATRES_CODE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       MRES."NAME" SMATRES_NAME,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.MAIN_QUANT NMAIN_QUANT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.REL_FACT NREL_FACT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       (select COALESCE(sum(F.QUANT), ' || PKG_SQL_BUILD.WRAP_NUM(NVALUE => 0) || ')');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                          from DOCLINKS  DL,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               DOCLINKS  L,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               FCROUTLST F');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                         where DL.OUT_DOCUMENT = T.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and DL.IN_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostProductPlansSpecs'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and DL.OUT_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostProductPlansSpecs'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and L.IN_DOCUMENT = DL.IN_DOCUMENT');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and L.IN_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostProductPlansSpecs'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and L.OUT_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostRouteLists'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and F.RN = L.OUT_DOCUMENT');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and F.STATE = ' || PKG_SQL_BUILD.WRAP_NUM(NVALUE => 1) || ') NFCROUTLST_QUANT');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  from FCPRODPLAN    P,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       FCPRODPLANSP  T,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       FCMATRESOURCE MRES');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                 where P.RN = :NFCPRODPLAN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and P.COMPANY = :NCOMPANY');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T.PRN = P.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T.MATRES = MRES.RN');
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
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.AUTHID = UTILIZER())');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and exists (select ' || PKG_SQL_BUILD.SET_HINT(SHINT => 'INDEX(UP I_USERPRIV_JUR_PERS_ROLEID)') || ' null');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 from USERPRIV UP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                where UP.JUR_PERS = T.JUR_PERS');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostProductPlans'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.ROLEID in (select ' || PKG_SQL_BUILD.SET_HINT(SHINT => 'INDEX(UR I_USERROLES_AUTHID_FK)') || ' UR.ROLEID');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                      from USERROLES UR');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                     where UR.AUTHID = UTILIZER())');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                union all');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               select ' || PKG_SQL_BUILD.SET_HINT(SHINT => 'INDEX(UP I_USERPRIV_JUR_PERS_AUTHID)') || ' null');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 from USERPRIV UP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                where UP.JUR_PERS = T.JUR_PERS');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostProductPlans'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  and UP.AUTHID = UTILIZER())');
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
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NFCPRODPLAN', NVALUE => NFCPRODPLAN);
      /* Описываем структуру записи курсора */
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 1);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 2);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 3);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 4);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 5);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 6);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 7);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 8);
      /* Делаем выборку */
      if (PKG_SQL_DML.EXECUTE(ICURSOR => ICURSOR) = 0) then
        null;
      end if;
      /* Обходим выбранные записи */
      while (PKG_SQL_DML.FETCH_ROWS(ICURSOR => ICURSOR) > 0)
      loop
        /* Читаем данные из курсора */
        PKG_SQL_DML.COLUMN_VALUE_NUM(ICURSOR => ICURSOR, IPOSITION => 1, NVALUE => NFCPRODPLANSP);
        /* Добавляем колонку с рег. номером */
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NRN', NVALUE => NFCPRODPLANSP, BCLEAR => true);
        /* Добавляем колонки с данными */
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SPROD_ORDER',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 2);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SMATRES_CODE',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 3);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SMATRES_NAME',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 4);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NMAIN_QUANT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 5);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NREL_FACT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 6);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NFCROUTLST_QUANT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 7);
        /* Считываем рег. номер связанной спецификации из "Производственная программа" */
        NFCPRODPLANSP_MAIN := UTL_FCPRODPLANSP_MAIN_GET(NCOMPANY => NCOMPANY, NFCPRODPLANSP => NFCPRODPLANSP);
        /* Если есть связанная спецификация из производственной программы */
        if (NFCPRODPLANSP_MAIN is not null) then
          /* Инициализируем список маршрутных листов */
          UTL_FCROUTLST_IDENT_INIT(NFCPRODPLANSP => NFCPRODPLANSP_MAIN, NIDENT => NFCROUTLST_IDENT);
          /* Считываем модификацию номенклатуры */
          NMODIF := FCPRODPLANSP_MODIF_GET(NFCPRODPLANSP => NFCPRODPLANSP_MAIN);
        end if;
        /* Обнуляем сумму "Количество план" и "Количество факт" по строке */
        NSUM_PLAN := 0;
        NSUM_FACT := 0;
        /* Добавляем значения по графику сдачи */
        for REC in (select TMP.DOC_DATE,
                           COALESCE(SUM(TMP.QUANT_PLAN), 0) QUANT_PLAN,
                           COALESCE(SUM(TMP.QUANT_FACT), 0) QUANT_FACT
                      from (select T.DOC_DATE,
                                   T.QUANT_PLAN,
                                   0 QUANT_FACT
                              from FCPRODPLANDLVSH T
                             where T.PRN = NFCPRODPLANSP
                               and T.DOC_DATE >= DDATE_FROM
                               and T.DOC_DATE <= DDATE_TO
                             union 
                            select D.WORK_DATE,
                                   0,
                                   SUM(S.QUANT_FACT)
                              from FCROUTLST FL,
                                   DOCLINKS  DL,
                                   INCOMEFROMDEPS D,
                                   INCOMEFROMDEPSSPEC S
                             where FL.RN in (select SL.DOCUMENT
                                               from SELECTLIST SL
                                              where SL.IDENT = NFCROUTLST_IDENT
                                                and SL.UNITCODE = 'CostRouteLists')
                               and FL.STATE = 1
                               and DL.IN_DOCUMENT = FL.RN
                               and DL.IN_UNITCODE = 'CostRouteLists'
                               and DL.OUT_UNITCODE = 'IncomFromDeps'
                               and D.RN = DL.OUT_DOCUMENT
                               and D.DOC_STATE = 2
                               and D.WORK_DATE >= DDATE_FROM
                               and D.WORK_DATE <= DDATE_TO
                               and S.PRN = D.RN
                               and S.NOMMODIF = NMODIF
                             group by D.WORK_DATE) TMP
                          group by TMP.DOC_DATE)
        loop
          /* Добавляем значение план/факт в соответствующую колонку */
          PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW   => RDG_ROW,
                                           SNAME  => 'N_' || TO_CHAR(REC.DOC_DATE, SCOL_PATTERN_DATE) || '_PLAN_FACT',
                                           SVALUE => TO_CHAR(REC.QUANT_PLAN) || '/' || TO_CHAR(REC.QUANT_FACT));
          /* Если это ранее текущей даты */
          if (REC.DOC_DATE <= DDATE) then
            /* Добавляем к сумме по строке */
            NSUM_PLAN := NSUM_PLAN + REC.QUANT_PLAN;
            NSUM_FACT := NSUM_FACT + REC.QUANT_FACT;
          end if;
        end loop;
        /* Добавляем колонки с суммами */
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NSUM_PLAN', NVALUE => NSUM_PLAN);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NSUM_FACT', NVALUE => NSUM_FACT);
        /* Добавляем строку в таблицу */
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW);
        /* Очищаем отмеченные маршрутные листы */
        P_SELECTLIST_CLEAR(NIDENT => NFCROUTLST_IDENT);
      end loop;
    exception
      when others then
        PKG_SQL_DML.CLOSE_CURSOR(ICURSOR => ICURSOR);
        /* Очищаем отмеченные маршрутные листы */
        P_SELECTLIST_CLEAR(NIDENT => NFCROUTLST_IDENT);
        raise;
    end;
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TDATA_GRID_TO_XML(RDATA_GRID => RDG, NINCLUDE_DEF => NINCLUDE_DEF);
  end FCPRODPLANSP_DEPT_DG_GET;
  
  /* Инициализация записей раздела "Планы и отчеты производства изделий" */
  procedure FCPRODPLAN_DEPT_INIT
  (
    COUT                    out clob                               -- Список записей раздела "Планы и отчеты производства изделий"
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
    NVERSION                PKG_STD.TREF;                          -- Версия контрагентов
  begin
    /* Считываем версию контрагентов */
    FIND_VERSION_BY_COMPANY(NCOMPANY => NCOMPANY, SUNITCODE => 'AGNLIST', NVERSION => NVERSION);
    /* Начинаем формирование XML */
    PKG_XFAST.PROLOGUE(ITYPE => PKG_XFAST.CONTENT_);
    /* Открываем корень */
    PKG_XFAST.DOWN_NODE(SNAME => 'XDATA');
    /* Цикл по планам и отчетам производства изделий */
    for REC in (select P.RN NRN,
                       DT.DOCCODE || ', ' || trim(P.PREFIX) || '-' || trim(P.NUMB) || ', ' ||
                       TO_CHAR(P.DOCDATE, 'dd.mm.yyyy') SDOC_INFO,
                       D.CODE as SSUBDIV,
                       E.CODE as SPERIOD
                  from FCPRODPLAN     P,
                       FINSTATE       FS,
                       DOCTYPES       DT,
                       INS_DEPARTMENT D,
                       ENPERIOD       E
                 where P.CATEGORY = NFCPRODPLAN_DEPT_CTGR
                   and P.STATUS = NFCPRODPLAN_STATUS
                   and P.COMPANY = NCOMPANY
                   and P.DOCDATE >= trunc(sysdate, 'mm')
                   and P.SUBDIV in (select C.DEPTRN
                                      from CLNPSPFM      C,
                                           CLNPSPFMTYPES CT
                                     where exists (select null
                                              from CLNPERSONS CP
                                             where exists (select null
                                                      from AGNLIST T
                                                     where T.PERS_AUTHID = UTILIZER()
                                                       and CP.PERS_AGENT = T.RN
                                                       and T.VERSION = NVERSION)
                                               and C.PERSRN = CP.RN
                                               and CP.COMPANY = NCOMPANY)
                                       and C.COMPANY = NCOMPANY
                                       and C.BEGENG <= sysdate
                                       and (C.ENDENG >= sysdate or C.ENDENG is null)
                                       and C.CLNPSPFMTYPES = CT.RN
                                       and CT.IS_PRIMARY = 1)
                   and FS.RN = P.TYPE
                   and FS.CODE = SFCPRODPLAN_TYPE
                   and D.RN = P.SUBDIV
                   and DT.RN = P.DOCTYPE
                   and E.RN = P.CALC_PERIOD
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
                 order by SDOC_INFO)
    loop
      /* Открываем план */
      PKG_XFAST.DOWN_NODE(SNAME => 'XFCPRODPLANS');
      /* Описываем план */
      PKG_XFAST.ATTR(SNAME => 'NRN', NVALUE => REC.NRN);
      PKG_XFAST.ATTR(SNAME => 'SDOC_INFO', SVALUE => REC.SDOC_INFO);
      PKG_XFAST.ATTR(SNAME => 'SSUBDIV', SVALUE => REC.SSUBDIV);
      PKG_XFAST.ATTR(SNAME => 'SPERIOD', SVALUE => REC.SPERIOD);
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
  end FCPRODPLAN_DEPT_INIT;
  
  /*
    Процедуры панели "Выдача сменного задания"
  */
  
  /* Добавление записи маршрутного листа в селектлисте */
  procedure SELECTLIST_FCROUTLST_ADD
  (
    NIDENT                  in number,       -- Идентификатор селектлиста
    NFCROUTLST              in number        -- Рег. номер маршрутного листа
  )
  is
    NRN                     PKG_STD.TSTRING; -- Рег. номер записи в селектлисте
  begin
    /* Считываем запись в селеклисте */
    NRN := UTL_SELECTLIST_RN_GET(NIDENT      => NIDENT,
                                 NFCROUTLST  => NFCROUTLST,
                                 SUNITCODE   => 'CostRouteLists',
                                 SACTIONCODE => 'P8PanelsJobManage');
    /* Если запись не найдена */
    if (NRN is null) then
      /* Добавляем запись в селектлист */
      P_SELECTLIST_BASE_INSERT(NIDENT       => NIDENT,
                               NCOMPANY     => null,
                               NDOCUMENT    => NFCROUTLST,
                               SUNITCODE    => 'CostRouteLists',
                               SACTIONCODE  => 'P8PanelsJobManage',
                               NCRN         => null,
                               NDOCUMENT1   => null,
                               SUNITCODE1   => null,
                               SACTIONCODE1 => null,
                               NRN          => NRN);
    end if;
  end SELECTLIST_FCROUTLST_ADD;
  
  /* Удаление записи маршрутного листа из селектлиста */
  procedure SELECTLIST_FCROUTLST_DEL
  (
    NIDENT                  in number,       -- Идентификатор селектлиста
    NFCROUTLST              in number        -- Рег. номер маршрутного листа
  )
  is
    NRN                     PKG_STD.TSTRING; -- Рег. номер записи в селектлисте
  begin
    /* Считываем запись в селеклисте */
    NRN := UTL_SELECTLIST_RN_GET(NIDENT      => NIDENT,
                                 NFCROUTLST  => NFCROUTLST,
                                 SUNITCODE   => 'CostRouteLists',
                                 SACTIONCODE => 'P8PanelsJobManage');
    /* Если запись найдена */
    if (NRN is not null) then
      /* Удаляем запись из селектлиста */
      P_SELECTLIST_BASE_DELETE(NRN => NRN);
    end if;
  end SELECTLIST_FCROUTLST_DEL;
  
  /* Выдать задание операции сменного задания */
  procedure FCJOBSSP_ISSUE
  (
    NFCJOBS                 in number,                             -- Рег. номер сменного задания
    SFCJOBSSP_LIST          in varchar2                            -- Список операций сменного задания
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
  begin
    /* Если список операций не указан */
    if (SFCJOBSSP_LIST is null) then
      P_EXCEPTION(0, 'Список операций не определен.');
    end if;
    /* Цикл по операциям сменного задания */
    for REC in (select T.*
                  from FCJOBSSP T
                 where T.PRN = NFCJOBS
                   and T.COMPANY = NCOMPANY
                   and T.RN in (select REGEXP_SUBSTR(SFCJOBSSP_LIST, '[^;]+', 1, level) NRN
                                  from DUAL
                                connect by INSTR(SFCJOBSSP_LIST, ';', 1, level - 1) > 0)
                   and T.BEG_FACT is null)
    loop
      /* Исключаем оборудование */
      P_FCJOBSSP_BASE_UPDATE(NRN            => REC.RN,
                             NCOMPANY       => REC.COMPANY,
                             SNUMB          => REC.NUMB,
                             NTBOPERMODESP  => REC.TBOPERMODESP,
                             SBARCODE       => REC.BARCODE,
                             NFACEACC       => REC.FACEACC,
                             NMATRES        => REC.MATRES,
                             NNOMCLASSIF    => REC.NOMCLASSIF,
                             NARTICLE       => REC.ARTICLE,
                             NFCROUTSHTSP   => REC.FCROUTSHTSP,
                             SOPER_NUMB     => REC.OPER_NUMB,
                             NOPER_TPS      => REC.OPER_TPS,
                             SOPER_UK       => REC.OPER_UK,
                             NSIGN_CONTRL   => REC.SIGN_CONTRL,
                             NMANPOWER      => REC.MANPOWER,
                             NCATEGORY      => REC.CATEGORY,
                             DBEG_PLAN      => REC.BEG_PLAN,
                             DEND_PLAN      => REC.END_PLAN,
                             DBEG_FACT      => REC.BEG_FACT,
                             DEND_FACT      => REC.END_FACT,
                             NQUANT_PLAN    => REC.QUANT_PLAN,
                             NQUANT_FACT    => REC.QUANT_FACT,
                             NNORM          => REC.NORM,
                             NT_SHT_FACT    => REC.T_SHT_FACT,
                             NT_PZ_PLAN     => REC.T_PZ_PLAN,
                             NT_PZ_FACT     => REC.T_PZ_FACT,
                             NT_VSP_PLAN    => REC.T_VSP_PLAN,
                             NT_VSP_FACT    => REC.T_VSP_FACT,
                             NT_O_PLAN      => REC.T_O_PLAN,
                             NT_O_FACT      => REC.T_O_FACT,
                             NNORM_TYPE     => REC.NORM_TYPE,
                             NSIGN_P_R      => REC.SIGN_P_R,
                             NLABOUR_PLAN   => REC.LABOUR_PLAN,
                             NLABOUR_FACT   => REC.LABOUR_FACT,
                             NCOST_PLAN     => REC.COST_PLAN,
                             NCOST_FACT     => REC.COST_FACT,
                             NCOST_FOR      => REC.COST_FOR,
                             NCURNAMES      => REC.CURNAMES,
                             NPERFORM_PLAN  => REC.PERFORM_PLAN,
                             NPERFORM_FACT  => REC.PERFORM_FACT,
                             NSTAFFGRP_PLAN => REC.STAFFGRP_PLAN,
                             NSTAFFGRP_FACT => REC.STAFFGRP_FACT,
                             NEQUIP_PLAN    => REC.EQUIP_PLAN,
                             NEQUIP_FACT    => REC.EQUIP_PLAN,
                             NLOSTTYPE      => REC.LOSTTYPE,
                             NLOSTDEFL      => REC.LOSTDEFL,
                             NFOREMAN       => REC.FOREMAN,
                             NINSPECTOR     => REC.INSPECTOR,
                             DOTK_DATE      => REC.OTK_DATE,
                             NSUBDIV        => REC.SUBDIV,
                             NEQCONFIG      => REC.EQCONFIG,
                             SNOTE          => REC.NOTE,
                             NMUNIT         => REC.MUNIT);
    end loop;
  end FCJOBSSP_ISSUE;
  
  /* Исключение оборудования из операции сменного задания */
  procedure FCJOBSSP_EXC_FCEQUIPMENT
  (
    NFCEQUIPMENT            in number,                             -- Рег. номер оборудования
    NFCJOBS                 in number,                             -- Рег. номер сменного задания
    SFCJOBSSP_LIST          in varchar2                            -- Список операций сменного задания
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
  begin
    /* Если оборудование выбрано */
    if (NFCEQUIPMENT is not null) then
      /* Проверяем наличие оборудования */
      UTL_FCEQUIPMENT_EXISTS(NFCEQUIPMENT => NFCEQUIPMENT, NCOMPANY => NCOMPANY);
    else
      P_EXCEPTION(0, 'Оборудование не определено.');
    end if;
    /* Если список операций не указан */
    if (SFCJOBSSP_LIST is null) then
      P_EXCEPTION(0, 'Список операций не определен.');
    end if;
    /* Цикл по операциям сменного задания */
    for REC in (select T.*
                  from FCJOBSSP T
                 where T.PRN = NFCJOBS
                   and T.COMPANY = NCOMPANY
                   and T.RN in (select REGEXP_SUBSTR(SFCJOBSSP_LIST, '[^;]+', 1, level) NRN
                                  from DUAL
                                connect by INSTR(SFCJOBSSP_LIST, ';', 1, level - 1) > 0)
                   and T.EQUIP_PLAN = NFCEQUIPMENT)
    loop
      /* Если дата начала факт указана */
      if (REC.BEG_FACT is not null) then
        P_EXCEPTION(0, 'Операция "%s" исполняется.', REC.OPER_NUMB);
      end if;
      /* Исключаем оборудование */
      P_FCJOBSSP_BASE_UPDATE(NRN            => REC.RN,
                             NCOMPANY       => REC.COMPANY,
                             SNUMB          => REC.NUMB,
                             NTBOPERMODESP  => REC.TBOPERMODESP,
                             SBARCODE       => REC.BARCODE,
                             NFACEACC       => REC.FACEACC,
                             NMATRES        => REC.MATRES,
                             NNOMCLASSIF    => REC.NOMCLASSIF,
                             NARTICLE       => REC.ARTICLE,
                             NFCROUTSHTSP   => REC.FCROUTSHTSP,
                             SOPER_NUMB     => REC.OPER_NUMB,
                             NOPER_TPS      => REC.OPER_TPS,
                             SOPER_UK       => REC.OPER_UK,
                             NSIGN_CONTRL   => REC.SIGN_CONTRL,
                             NMANPOWER      => REC.MANPOWER,
                             NCATEGORY      => REC.CATEGORY,
                             DBEG_PLAN      => REC.BEG_PLAN,
                             DEND_PLAN      => REC.END_PLAN,
                             DBEG_FACT      => REC.BEG_FACT,
                             DEND_FACT      => REC.END_FACT,
                             NQUANT_PLAN    => REC.QUANT_PLAN,
                             NQUANT_FACT    => REC.QUANT_FACT,
                             NNORM          => REC.NORM,
                             NT_SHT_FACT    => REC.T_SHT_FACT,
                             NT_PZ_PLAN     => REC.T_PZ_PLAN,
                             NT_PZ_FACT     => REC.T_PZ_FACT,
                             NT_VSP_PLAN    => REC.T_VSP_PLAN,
                             NT_VSP_FACT    => REC.T_VSP_FACT,
                             NT_O_PLAN      => REC.T_O_PLAN,
                             NT_O_FACT      => REC.T_O_FACT,
                             NNORM_TYPE     => REC.NORM_TYPE,
                             NSIGN_P_R      => REC.SIGN_P_R,
                             NLABOUR_PLAN   => REC.LABOUR_PLAN,
                             NLABOUR_FACT   => REC.LABOUR_FACT,
                             NCOST_PLAN     => REC.COST_PLAN,
                             NCOST_FACT     => REC.COST_FACT,
                             NCOST_FOR      => REC.COST_FOR,
                             NCURNAMES      => REC.CURNAMES,
                             NPERFORM_PLAN  => REC.PERFORM_PLAN,
                             NPERFORM_FACT  => REC.PERFORM_FACT,
                             NSTAFFGRP_PLAN => REC.STAFFGRP_PLAN,
                             NSTAFFGRP_FACT => REC.STAFFGRP_FACT,
                             NEQUIP_PLAN    => null,
                             NEQUIP_FACT    => REC.EQUIP_FACT,
                             NLOSTTYPE      => REC.LOSTTYPE,
                             NLOSTDEFL      => REC.LOSTDEFL,
                             NFOREMAN       => REC.FOREMAN,
                             NINSPECTOR     => REC.INSPECTOR,
                             DOTK_DATE      => REC.OTK_DATE,
                             NSUBDIV        => REC.SUBDIV,
                             NEQCONFIG      => REC.EQCONFIG,
                             SNOTE          => REC.NOTE,
                             NMUNIT         => REC.MUNIT);
    end loop;
  end FCJOBSSP_EXC_FCEQUIPMENT;
  
  /* Включение оборудование в строку сменного задания */
  procedure FCJOBSSP_INC_FCEQUIPMENT
  (
    NFCEQUIPMENT            in number,                             -- Рег. номер оборудования
    NFCJOBS                 in number,                             -- Рег. номер сменного задания
    SFCJOBSSP_LIST          in varchar2                            -- Список операций сменного задания
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
  begin
    /* Если оборудование выбрано */
    if (NFCEQUIPMENT is not null) then
      /* Проверяем наличие оборудования */
      UTL_FCEQUIPMENT_EXISTS(NFCEQUIPMENT => NFCEQUIPMENT, NCOMPANY => NCOMPANY);
    else
      P_EXCEPTION(0, 'Оборудование не определено.');
    end if;
    /* Если список операций не указан */
    if (SFCJOBSSP_LIST is null) then
      P_EXCEPTION(0, 'Список операций не определен.');
    end if;
    /* Цикл по операциям сменного задания */
    for REC in (select T.*
                  from FCJOBSSP T
                 where T.PRN = NFCJOBS
                   and T.COMPANY = NCOMPANY
                   and T.RN in (select REGEXP_SUBSTR(SFCJOBSSP_LIST, '[^;]+', 1, level) NRN
                                  from DUAL
                                connect by INSTR(SFCJOBSSP_LIST, ';', 1, level - 1) > 0))
    loop
      /* Если дата начала факт указана */
      if (REC.BEG_FACT is not null) then
        P_EXCEPTION(0, 'Операция "%s" исполняется.', REC.OPER_NUMB);
      end if;
      /* Включаем в задание */
      P_FCJOBSSP_BASE_UPDATE(NRN            => REC.RN,
                             NCOMPANY       => REC.COMPANY,
                             SNUMB          => REC.NUMB,
                             NTBOPERMODESP  => REC.TBOPERMODESP,
                             SBARCODE       => REC.BARCODE,
                             NFACEACC       => REC.FACEACC,
                             NMATRES        => REC.MATRES,
                             NNOMCLASSIF    => REC.NOMCLASSIF,
                             NARTICLE       => REC.ARTICLE,
                             NFCROUTSHTSP   => REC.FCROUTSHTSP,
                             SOPER_NUMB     => REC.OPER_NUMB,
                             NOPER_TPS      => REC.OPER_TPS,
                             SOPER_UK       => REC.OPER_UK,
                             NSIGN_CONTRL   => REC.SIGN_CONTRL,
                             NMANPOWER      => REC.MANPOWER,
                             NCATEGORY      => REC.CATEGORY,
                             DBEG_PLAN      => REC.BEG_PLAN,
                             DEND_PLAN      => REC.END_PLAN,
                             DBEG_FACT      => REC.BEG_FACT,
                             DEND_FACT      => REC.END_FACT,
                             NQUANT_PLAN    => REC.QUANT_PLAN,
                             NQUANT_FACT    => REC.QUANT_FACT,
                             NNORM          => REC.NORM,
                             NT_SHT_FACT    => REC.T_SHT_FACT,
                             NT_PZ_PLAN     => REC.T_PZ_PLAN,
                             NT_PZ_FACT     => REC.T_PZ_FACT,
                             NT_VSP_PLAN    => REC.T_VSP_PLAN,
                             NT_VSP_FACT    => REC.T_VSP_FACT,
                             NT_O_PLAN      => REC.T_O_PLAN,
                             NT_O_FACT      => REC.T_O_FACT,
                             NNORM_TYPE     => REC.NORM_TYPE,
                             NSIGN_P_R      => REC.SIGN_P_R,
                             NLABOUR_PLAN   => REC.LABOUR_PLAN,
                             NLABOUR_FACT   => REC.LABOUR_FACT,
                             NCOST_PLAN     => REC.COST_PLAN,
                             NCOST_FACT     => REC.COST_FACT,
                             NCOST_FOR      => REC.COST_FOR,
                             NCURNAMES      => REC.CURNAMES,
                             NPERFORM_PLAN  => REC.PERFORM_PLAN,
                             NPERFORM_FACT  => REC.PERFORM_FACT,
                             NSTAFFGRP_PLAN => REC.STAFFGRP_PLAN,
                             NSTAFFGRP_FACT => REC.STAFFGRP_FACT,
                             NEQUIP_PLAN    => NFCEQUIPMENT,
                             NEQUIP_FACT    => REC.EQUIP_FACT,
                             NLOSTTYPE      => REC.LOSTTYPE,
                             NLOSTDEFL      => REC.LOSTDEFL,
                             NFOREMAN       => REC.FOREMAN,
                             NINSPECTOR     => REC.INSPECTOR,
                             DOTK_DATE      => REC.OTK_DATE,
                             NSUBDIV        => REC.SUBDIV,
                             NEQCONFIG      => REC.EQCONFIG,
                             SNOTE          => REC.NOTE,
                             NMUNIT         => REC.MUNIT);
    end loop;
  end FCJOBSSP_INC_FCEQUIPMENT;
  
  /* Получение таблицы оборудования подразделения */
  procedure FCEQUIPMENT_DG_GET
  (
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
    NVERSION                PKG_STD.TREF;                          -- Версия контрагентов
  begin
    /* Считываем версию контрагентов */
    FIND_VERSION_BY_COMPANY(NCOMPANY => NCOMPANY, SUNITCODE => 'AGNLIST', NVERSION => NVERSION);
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
                                               SNAME      => 'NSELECT',
                                               SCAPTION   => 'Выбран',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SCODE',
                                               SCAPTION   => 'Код',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SNAME',
                                               SCAPTION   => 'Наименование',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NLOADING',
                                               SCAPTION   => 'Загрузка',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCOEFF',
                                               SCAPTION   => 'Норматив загрузки',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    /* Обходим данные */
    begin
      /* Добавляем подсказку совместимости */
      CSQL := PKG_SQL_BUILD.COMPATIBLE(SSQL => CSQL);
      /* Формируем запрос */
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => 'select *');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '  from (select D.*,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.SQLROWNUM() || ' NROW');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '          from (select T.RN   NRN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.CODE SCODE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.NAME SNAME,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       (select SUM(case');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                     when S.MUNIT is not null then');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                       ROUND(F_DICMUNTS_BASE_RECALC_QUANT(' || PKG_SQL_BUILD.WRAP_NUM(NVALUE => 0) || ',');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                                          :NCOMPANY,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                                          S.MUNIT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                                          S.LABOUR_PLAN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                                          F.TIME_MUNIT), 3)');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                     else');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                       ' || PKG_SQL_BUILD.WRAP_NUM(NVALUE => 0));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                   end)');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                          from FCEQUIPMENT F');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               left outer join FCJOBSSP S on S.EQUIP_PLAN = F.RN and S.WORK_DATE is null');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               left outer join FCJOBS J on J.RN = S.PRN and F.SUBDIV = J.SUBDIV');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                         where F.RN = T.RN) NLOADING,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.COEFF NCOEFF');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  from FCEQUIPMENT T');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                 where T.COMPANY = :NCOMPANY');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T.SUBDIV is not null');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and PKG_P8PANELS_MECHREC.UTL_SUBDIV_CHECK(T.COMPANY, T.SUBDIV, UTILIZER()) = ' || PKG_SQL_BUILD.WRAP_NUM(NVALUE => 1));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and exists (select null from V_USERPRIV UP where UP."CATALOG" = T.CRN)');
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
      /*PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NVERSION', NVALUE => NVERSION);
      PKG_SQL_DML.BIND_VARIABLE_DATE(ICURSOR => ICURSOR, SNAME => 'DDATE', DVALUE => sysdate);*/
      /* Описываем структуру записи курсора */
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 1);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 2);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 3);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 4);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 5);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 6);
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
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NSELECT', NVALUE => 0);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SCODE',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 2);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SNAME',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 3);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NLOADING',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 4);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NCOEFF',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 5);
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
  end FCEQUIPMENT_DG_GET;
  
  /* Получение таблицы маршрутных листов спецификации сменного задания */
  procedure FCJOBSSP_FCROUTLST_DG_GET
  (
    NFCJOBS                 in number,                             -- Рег. номер сменного задания
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
                                               SNAME      => 'NSELECT',
                                               SCAPTION   => 'Выбран',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SFCROUTLST_INFO',
                                               SCAPTION   => 'Номер МЛ',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SMATRES',
                                               SCAPTION   => 'Материальный ресурс',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NPRIOR_ORDER',
                                               SCAPTION   => 'Приоритет',
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
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '          from (select F.RN NRN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       PKG_DOCUMENT.MAKE_NUMBER(F.DOCTYPE, F.DOCPREF, F.DOCNUMB, F.DOCDATE) SFCROUTLST_INFO,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       F2.CODE || '', '' || F2.NAME SMATRES,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       F.PRIOR_ORDER NPRIOR_ORDER');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  from FCROUTLST F,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       FCMATRESOURCE F2');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                 where F.RN in (select FL.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  from FCJOBSSP JS,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                       FCROUTLST FL,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                       FCROUTLSTSP SP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 where JS.PRN = :NFCJOBS');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                   and JS.COMPANY = :NCOMPANY');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                   and SP.RN = (select ' || PKG_SQL_BUILD.SET_HINT(SHINT => 'INDEX(L I_DOCLINKS_OUT_DOCUMENT)') || ' MAX(L.IN_DOCUMENT)');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                  from DOCLINKS  L');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                 where L.OUT_DOCUMENT = JS.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                   and L.OUT_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostJobsSpecs'));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                   and L.IN_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostRouteListsSpecs') || ')');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                   and SP.STATE = ' || PKG_SQL_BUILD.WRAP_NUM(NVALUE => 0));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                   and PKG_P8PANELS_MECHREC.UTL_SUBDIV_CHECK(SP.COMPANY, SP.SUBDIV, UTILIZER()) = ' || PKG_SQL_BUILD.WRAP_NUM(NVALUE => 1));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                   and FL.RN = SP.PRN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                   and exists (select null from V_USERPRIV UP where UP."CATALOG" = JS.CRN)');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                   and exists (select null from V_USERPRIV UP where UP.JUR_PERS = JS.JUR_PERS and UP.UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostJobs') || ') ');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 group by FL.RN)');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and F2.RN = F.MATRES');
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
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NFCJOBS', NVALUE => NFCJOBS);
      /* Описываем структуру записи курсора */
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 1);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 2);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 3);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 4);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 5);
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
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NSELECT', NVALUE => 0);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SFCROUTLST_INFO',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 2);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SMATRES',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 3);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NPRIOR_ORDER',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 4);
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
  end FCJOBSSP_FCROUTLST_DG_GET;
  
  /* Получение спецификации сменного задания по отмеченным маршрутным листам */
  procedure FCJOBSSP_DG_GET
  (
    NFCJOBS                 in number,                             -- Рег. номер сменного задания
    NIDENT                  in number,                             -- Идентификатор процесса
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
                                               SNAME      => 'NSELECT',
                                               SCAPTION   => 'Выбран',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SOPER_NUMB',
                                               SCAPTION   => 'Номер операции',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SOPER_NAME',
                                               SCAPTION   => 'Наименование операции',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NISSUED',
                                               SCAPTION   => 'Выдано',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NISSUE',
                                               SCAPTION   => 'Выдать',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               BORDER     => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NEQUIP_PLAN',
                                               SCAPTION   => 'Рег. номер оборудования план',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false,
                                               BORDER     => true);
    /* Если список выбраныых маршрутных листов не пустой */
    if (NIDENT is not null) then
    --if (SFCROUTLST_LIST is not null) then
      /* Обходим данные */
      begin
        /* Добавляем подсказку совместимости */
        CSQL := PKG_SQL_BUILD.COMPATIBLE(SSQL => CSQL);
        /* Формируем запрос */
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => 'select *');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '  from (select D.*,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.SQLROWNUM() || ' NROW');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '          from (select TMP.NRN,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       TMP.SOPER_NUMB,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       TMP.SOPER_NAME,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       TMP.NISSUED,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       TMP.NQUANT_PLAN - TMP.NQUANT_FACT - TMP.NISSUED NISSUE,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       TMP.NEQUIP_PLAN');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  from (select ' || PKG_SQL_BUILD.SET_HINT(SHINT => 'INDEX(L I_DOCLINKS_OUT_DOCUMENT)') || ' T.RN NRN,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               T.OPER_NUMB SOPER_NUMB,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               (select coalesce(O.NAME, T.OPER_UK) from FCOPERTYPES O where T.OPER_TPS = O.RN) SOPER_NAME,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               (select sum(S.QUANT_PLAN)');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  from FCJOBSSP S,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                       DOCLINKS DL');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 where S.PRN = T.PRN');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                   and S.WORK_DATE is null');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                   and DL.OUT_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostJobsSpecs'));
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                   and DL.IN_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostRouteLists'));
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                   and DL.IN_DOCUMENT = L.IN_DOCUMENT');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                   and DL.OUT_DOCUMENT = S.RN) NISSUED,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               T.QUANT_PLAN as NQUANT_PLAN,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               T.QUANT_FACT as NQUANT_FACT,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               T.EQUIP_PLAN as NEQUIP_PLAN');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                          from FCJOBSSP T,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               DOCLINKS L');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                         where T.PRN = :NFCJOBS');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and T.COMPANY = :NCOMPANY');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and L.OUT_UNITCODE =  ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostJobsSpecs'));
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and L.IN_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostRouteLists'));
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and L.IN_DOCUMENT in (select SL."DOCUMENT"');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                   from SELECTLIST SL');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                  where SL.IDENT = :NIDENT');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                    and SL.UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostRouteLists'));
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                    and SL.ACTIONCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'P8PanelsJobManage') || ')');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and T.RN = L.OUT_DOCUMENT');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and exists ( select null from V_USERPRIV UP where UP."CATALOG" = T.CRN )');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                           and exists ( select null from V_USERPRIV UP where UP.JUR_PERS = T.JUR_PERS and UP.UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostJobs') || ' )) TMP ');
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
        PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NFCJOBS', NVALUE => NFCJOBS);
        PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NIDENT', NVALUE => NIDENT);
        /* Описываем структуру записи курсора */
        PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 1);
        PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 2);
        PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 3);
        PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 4);
        PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 5);
        PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 6);
        PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 7);
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
          PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NSELECT', NVALUE => 0);
          PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                                SNAME     => 'SOPER_NUMB',
                                                ICURSOR   => ICURSOR,
                                                NPOSITION => 2);
          PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                                SNAME     => 'SOPER_NAME',
                                                ICURSOR   => ICURSOR,
                                                NPOSITION => 3);
          PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                                SNAME     => 'NISSUED',
                                                ICURSOR   => ICURSOR,
                                                NPOSITION => 4);
          PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                                SNAME     => 'NISSUE',
                                                ICURSOR   => ICURSOR,
                                                NPOSITION => 5);
          PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                                SNAME     => 'NEQUIP_PLAN',
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
    end if;
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TDATA_GRID_TO_XML(RDATA_GRID => RDG, NINCLUDE_DEF => NINCLUDE_DEF);
  end FCJOBSSP_DG_GET;
  
  /* Инициализация записей раздела "Планы и отчеты производства изделий" */
  procedure FCJOBS_INIT
  (
    COUT                    out clob                               -- Список записей раздела "Сменные задания"
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
    SUTILIZER               PKG_STD.TSTRING := UTILIZER();         -- Пользователь сеанса
    NVERSION                PKG_STD.TREF;                          -- Версия контрагентов
    NPROCESS_IDENT          PKG_STD.TREF;                          -- Идентификатор процесса
  begin
    /* Считываем версию контрагентов */
    FIND_VERSION_BY_COMPANY(NCOMPANY => NCOMPANY, SUNITCODE => 'AGNLIST', NVERSION => NVERSION);
    /* Генерируем идентификатор процесса */
    NPROCESS_IDENT := GEN_IDENT();
    /* Начинаем формирование XML */
    PKG_XFAST.PROLOGUE(ITYPE => PKG_XFAST.CONTENT_);
    /* Открываем корень */
    PKG_XFAST.DOWN_NODE(SNAME => 'XDATA');
    /* Цикл по планам и отчетам производства изделий */
    for REC in (select T.RN NRN,
                       DT.DOCCODE || ', ' || trim(T.DOCPREF) || '-' || trim(T.DOCNUMB) || ', ' ||
                       TO_CHAR(T.DOCDATE, 'dd.mm.yyyy') SDOC_INFO,
                       INS.CODE SSUBDIV,
                       case
                         when PER.RN is not null then
                           TO_CHAR(T.DOCDATE, 'dd.mm.yyyy') || ' ' || TN2S(PER.BEG_TIME) || ' - ' || TN2S(PER.END_TIME)
                         else
                           TO_CHAR(T.DOCDATE, 'dd.mm.yyyy')
                       end SPERIOD
                  from FCJOBS T,
                       DOCTYPES DT,
                       INS_DEPARTMENT INS,
                       TBOPERMODESP   PER
                 where T.COMPANY = NCOMPANY
                   and T.STATE <> NFCJOBS_STATUS_WO
                   and DT.RN = T.DOCTYPE
                   and T.SUBDIV = INS.RN (+)
                   and T.TBOPERMODESP = PER.RN (+)
                   and PKG_P8PANELS_MECHREC.UTL_SUBDIV_CHECK(T.COMPANY, T.SUBDIV, SUTILIZER) = 1
                   and exists (select null from V_USERPRIV UP where UP.CATALOG = T.CRN)
                   and exists (select null from V_USERPRIV UP where UP.JUR_PERS = T.JUR_PERS and UP.UNITCODE = 'CostJobs')
                 order by SDOC_INFO)
    loop
      /* Открываем план */
      PKG_XFAST.DOWN_NODE(SNAME => 'XFCJOBS');
      /* Описываем план */
      PKG_XFAST.ATTR(SNAME => 'NRN', NVALUE => REC.NRN);
      PKG_XFAST.ATTR(SNAME => 'SDOC_INFO', SVALUE => REC.SDOC_INFO);
      PKG_XFAST.ATTR(SNAME => 'SSUBDIV', SVALUE => REC.SSUBDIV);
      PKG_XFAST.ATTR(SNAME => 'SPERIOD', SVALUE => REC.SPERIOD);
      /* Закрываем план */
      PKG_XFAST.UP();
    end loop;
    /* Открываем дополнительную информацию */
    PKG_XFAST.DOWN_NODE(SNAME => 'XINFO');
    /* Описываем идентификатор процесса */
    PKG_XFAST.ATTR(SNAME => 'NPROCESS_IDENT', NVALUE => NPROCESS_IDENT);
    /* Закрываем дополнительную информацию */
    PKG_XFAST.UP();
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
  end FCJOBS_INIT;
  
  /*
    Процедуры панели "Загрузка цеха"
  */
  
  /* Получение загрузки цеха */
  procedure FCJOBS_DEP_LOAD_DG_GET
  (
    NPAGE_NUMBER            in number,                             -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,                             -- Количество записей на странице (0 - все)
    CORDERS                 in clob,                               -- Сортировки
    NINCLUDE_DEF            in number,                             -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob                               -- Сериализованная таблица данных
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
    SUTILIZER               PKG_STD.TSTRING := UTILIZER();         -- Пользователь сеанса
    RO                      PKG_P8PANELS_VISUAL.TORDERS;           -- Сортировки
    RDG                     PKG_P8PANELS_VISUAL.TDATA_GRID;        -- Описание таблицы
    RDG_ROW                 PKG_P8PANELS_VISUAL.TROW;              -- Строка таблицы
    NROW_FROM               PKG_STD.TREF;                          -- Номер строки с
    NROW_TO                 PKG_STD.TREF;                          -- Номер строки по
    CSQL                    clob;                                  -- Буфер для запроса
    ICURSOR                 integer;                               -- Курсор для исполнения запроса
    DDATE_FROM              PKG_STD.TLDATE;                        -- Дата начала месяца
    DDATE_TO                PKG_STD.TLDATE;                        -- Дата окончания месяца
    DDATE                   PKG_STD.TLDATE;                        -- Дата для расчетов
    NDICMUNTS_WD            PKG_STD.TREF;                          -- Рег. номер единицы измерения нормочасов
    NDICMUNTS_HOUR          PKG_STD.TREF;                          -- Рег. номер единицы измерения часа
    NFCEQUIPMENT            PKG_STD.TREF;                          -- Рег. номер оборудования
    TDAYS                   TJOB_DAYS;                             -- Коллекция дней месяца
    NINDEX                  PKG_STD.TNUMBER;                       -- Индекс даты в коллекции дат
    
    /* Считывание индекса коллекции дней */
    function TDAYS_INDEX_GET
    (
      TDAYS                 in TJOB_DAYS, -- Коллекция дней
      DDATE                 in date       -- Дата дня
    ) return                number        -- Индекс дня в коллекции
    is
    begin
      /* Цикл по дням месяца */
      for I in TDAYS.FIRST..TDAYS.LAST
      loop
        /* Если это искомый день */
        if (TDAYS(I).DDATE = TRUNC(DDATE)) then
          /* Возвращаем индекс */
          return I;
        end if;
      end loop;
      /* Возвращаем null */
      return null;
    end TDAYS_INDEX_GET;
    
    /* Инициализация дней месяца */
    procedure DAYS_INIT
    (
      RDG                   in out nocopy PKG_P8PANELS_VISUAL.TDATA_GRID, -- Описание таблицы
      TJOB_DAYS             in out nocopy TJOB_DAYS,                      -- Коллекция дней месяца
      DDATE_FROM            in date,                                      -- Дата начала месяца
      DDATE_TO              in date                                       -- Дата окончания месяца
    )
    is
      DDATE                 PKG_STD.TLDATE;                               -- Сформированная дата дня
      NMONTH                PKG_STD.TNUMBER;                              -- Текущий месяц
      NYEAR                 PKG_STD.TNUMBER;                              -- Текущий год
      SDATE_NAME            PKG_STD.TSTRING;                              -- Строковое представление даты для наименования колонки
    begin
      /* Считываем месяц и год текущей даты */
      NMONTH := D_MONTH(DDATE => sysdate);
      NYEAR  := D_YEAR(DDATE => sysdate);
      /* Цикл по дням месяца */
      for I in D_DAY(DDATE => DDATE_FROM) .. D_DAY(DDATE => DDATE_TO)
      loop
        /* Формируем дату дня */
        DDATE := TO_DATE(TO_CHAR(I) || '.' || TO_CHAR(NMONTH) || '.' || TO_CHAR(NYEAR), 'dd.mm.yyyy');
        /* Строковое представление даты для наименования колонки */
        SDATE_NAME := TO_CHAR(DDATE, SCOL_PATTERN_DATE);
        /* Описываем родительскую колонку таблицы данных */
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                                   SNAME      => 'N_' || TO_CHAR(DDATE, SCOL_PATTERN_DATE) || '_VALUE',
                                                   SCAPTION   => LPAD(D_DAY(DDATE), 2, '0'),
                                                   SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                                   SPARENT    => 'NVALUE_BY_DAYS');
        /* Описываем родительскую колонку таблицы данных */
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                                   SNAME      => 'N_' || TO_CHAR(DDATE, SCOL_PATTERN_DATE) || '_TYPE',
                                                   SCAPTION   => LPAD(D_DAY(DDATE), 2, '0'),
                                                   SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                                   BVISIBLE   => false,
                                                   SPARENT    => 'NVALUE_BY_DAYS');
        /* Добавляем день в коллекцию */
        TJOB_DAYS_ADD(TDAYS => TJOB_DAYS, DDATE => DDATE, NVALUE => 0, NTYPE => null);
      end loop;
    end DAYS_INIT;
    
    /* Заполнение нормы трудоемкости дней месяца */
    procedure DAYS_FILL
    (
      TDAYS                 in out nocopy TJOB_DAYS, -- Коллекци дней месяца
      DDATE                 in out date,             -- Начальный день строки СЗ
      DBEG_FACT             in date,                 -- Дата начала факт
      DDATE_TO              in date,                 -- Дата окончания месяца
      NLABOUR_FACT_FULL     in number,               -- Норма факт строки СЗ
      NLABOUR_PLAN_FULL     in number,               -- Норма план строки СЗ (с учетом нормы факт)
      NWORK_HOURS           in number                -- Количество рабочих часов смены
    )
    is
      NHOURS_LEFT           PKG_STD.TLNUMBER;        -- Количество оставшихся часов в дне
      NMAX_OF_DAY           PKG_STD.TQUANT;          -- Максимальное количество рабочих часов в дне
      NLABOUR_FACT          PKG_STD.TQUANT;          -- Оставшаяся трудоемкость факт
      NLABOUR_PLAN          PKG_STD.TQUANT;          -- Оставшаяся трудоемкость план
      NLABOUR_BY_DAY        PKG_STD.TQUANT;          -- Суммарная трудоемкость за день (в доли смены)
      NDAY_TYPE             PKG_STD.TNUMBER;         -- Тип дня (0 - выполняемый, 1 - выполненный)
      NINDEX                PKG_STD.TNUMBER;         -- Индекс даты в коллекции дат
    begin
      /* Указываем изначальные план и факт */
      NLABOUR_FACT := NLABOUR_FACT_FULL;
      NLABOUR_PLAN := NLABOUR_PLAN_FULL;
      /* Необходимо погасть факт и план */
      while (((NLABOUR_FACT <> 0) or (NLABOUR_PLAN <> 0)) and (DDATE <= DDATE_TO))
      loop
        /* Обнуляем трудоемкость в доли смены за день */
        NLABOUR_BY_DAY := 0;
        /* Считываем индекс коллеции текущего дня */
        NINDEX := TDAYS_INDEX_GET(TDAYS => TDAYS, DDATE => DDATE);
        /* Изначально всегда "Выполнено" */
        NDAY_TYPE := 1;
        /* Определяем количество оставшихся часов в дне */
        NHOURS_LEFT := (TRUNC(DDATE + 1) - DDATE) * 24;
        /* Если в текущем дне еще есть время */
        if (TDAYS(NINDEX).NVALUE <> 1) then
          /* Если день пустой */
          if (TDAYS(NINDEX).NVALUE = 0) then
            /* Определяем возможное указание часов (относительно оставшегося времени дня или часов в смене) */
            NMAX_OF_DAY := LEAST(NHOURS_LEFT, NWORK_HOURS);
          else
            /* Определяем количество оставшегося времени в дне */
            NMAX_OF_DAY := ((1 - TDAYS(NINDEX).NVALUE) * NWORK_HOURS);
            /* Определяем возможное указание часов (относительно оставшегося времени дня или заполненного времени дня) */
            NMAX_OF_DAY := LEAST(NHOURS_LEFT, NMAX_OF_DAY);
          end if;
          /* Если указана дата начала факт и осталась трудоемкость факт */
          if ((DBEG_FACT is not null) and (NLABOUR_FACT > 0)) then
            /* Если в данный день невозможно отметить весь факт */
            if (NLABOUR_FACT > NMAX_OF_DAY) then
              /* Вычитаем из суммарного факта трудоемкость дня */
              NLABOUR_FACT   := NLABOUR_FACT - NMAX_OF_DAY;
              NLABOUR_BY_DAY := NMAX_OF_DAY;
            else
              /* Добавляем трудоемкость факта и обнуляем суммарный факт */
              NLABOUR_BY_DAY := NLABOUR_BY_DAY + NLABOUR_FACT;
              NLABOUR_FACT   := 0;
            end if;
          end if;
          /* Если осталось время дня и есть план */
          if ((NMAX_OF_DAY > NLABOUR_BY_DAY) and (NLABOUR_PLAN > 0)) then
            /* Это день плана */
            NDAY_TYPE := 0;
            /* Если в данный день невозможно отметить всё */
            if (NLABOUR_PLAN > (NMAX_OF_DAY - NLABOUR_BY_DAY)) then
              /* Вычитаем из суммарного плана оставшуюсь часть дня */
              NLABOUR_PLAN   := NLABOUR_PLAN - (NMAX_OF_DAY - NLABOUR_BY_DAY);
              NLABOUR_BY_DAY := NMAX_OF_DAY;
            else
              /* Добавляем трудоемкость плана и обнуляем суммарный план */
              NLABOUR_BY_DAY := NLABOUR_BY_DAY + NLABOUR_PLAN;
              NLABOUR_PLAN   := 0;
            end if;
          end if;
          /* Если рабочего времени не осталось */
          if (NMAX_OF_DAY = 0) then
            /* Указываем целый день */
            TDAYS(NINDEX).NVALUE := 1;
          else
            /* Добавляем по текущему дню */
            TDAYS(NINDEX).NVALUE := TDAYS(NINDEX).NVALUE + (NLABOUR_BY_DAY / NWORK_HOURS);
          end if;
          /* Указываем тип дня */
          TDAYS(NINDEX).NTYPE := NDAY_TYPE;
        end if;
        /* Указываем следующий день */
        DDATE := TRUNC(DDATE + 1);
      end loop;
    end DAYS_FILL;
    
    /* Добавление информации в итоговый результат */
    procedure ADD_INFO
    (
      NCOMPANY              in number,   -- Рег. номер организации
      SUTILIZER             in varchar2, -- Имя пользователя
      COUT                  in out clob  -- Сериализованная таблица данных
    )
    is
    begin
      /* Начинаем формирование XML */
      PKG_XFAST.PROLOGUE(ITYPE => PKG_XFAST.CONTENT_);
      /* Открываем корень */
      PKG_XFAST.DOWN_NODE(SNAME => 'XDATA');
      /* Открываем план */
      PKG_XFAST.DOWN_NODE(SNAME => 'XFCJOBS');
      /* Описываем план */
      PKG_XFAST.VALUE_XML(LCVALUE => COUT);
      /* Закрываем план */
      PKG_XFAST.UP();
      /* Открываем дополнительную информацию */
      PKG_XFAST.DOWN_NODE(SNAME => 'XINFO');
      /* Описываем мнемокод подразделения */
      PKG_XFAST.ATTR(SNAME => 'SSUBDIV', SVALUE => UTL_SUBDIV_CODE_GET(NCOMPANY => NCOMPANY, SUSER => SUTILIZER));
      /* Закрываем дополнительную информацию */
      PKG_XFAST.UP();
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
    end;
  begin
    /* Читем сортировки */
    RO := PKG_P8PANELS_VISUAL.TORDERS_FROM_XML(CORDERS => CORDERS);
    /* Преобразуем номер и размер страницы в номер строк с и по */
    PKG_P8PANELS_VISUAL.UTL_ROWS_LIMITS_CALC(NPAGE_NUMBER => NPAGE_NUMBER,
                                             NPAGE_SIZE   => NPAGE_SIZE,
                                             NROW_FROM    => NROW_FROM,
                                             NROW_TO      => NROW_TO);
    /* Инициализируем таблицу данных */
    RDG := PKG_P8PANELS_VISUAL.TDATA_GRID_MAKE(BFIXED_HEADER => true, NFIXED_COLUMNS => 5);
    /* Описываем колонки таблицы данных */
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NRN',
                                               SCAPTION   => 'Рег. номер',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SCODE',
                                               SCAPTION   => 'Мнемокод',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               NWIDTH     => 100);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SNAME',
                                               SCAPTION   => 'Наименование',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               NWIDTH     => 200);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SSUBDIV',
                                               SCAPTION   => 'Участок',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true,
                                               NWIDTH     => 80);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NPROCENT_LOAD',
                                               SCAPTION   => 'Загрузка (%)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               NWIDTH     => 80);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NLOAD',
                                               SCAPTION   => 'Загрузка (н/ч)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true,
                                               NWIDTH     => 80);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NVALUE_BY_DAYS',
                                               SCAPTION   => 'Загрузка по дням',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true);
    /* Считываем первый и последний день месяца */
    P_FIRST_LAST_DAY(DCALCDATE => sysdate, DBGNDATE => DDATE_FROM, DENDDATE => DDATE_TO);
    /* Считываем единицу измерения нормочасов */
    FIND_DICMUNTS_CODE(NFLAG_SMART  => 0,
                       NFLAG_OPTION => 0,
                       NCOMPANY     => NCOMPANY,
                       SMEAS_MNEMO  => SDICMUNTS_WD,
                       NRN          => NDICMUNTS_WD);
    /* Считываем единицу измерения часа */
    FIND_DICMUNTS_CODE(NFLAG_SMART  => 0,
                       NFLAG_OPTION => 0,
                       NCOMPANY     => NCOMPANY,
                       SMEAS_MNEMO  => SDICMUNTS_HOUR,
                       NRN          => NDICMUNTS_HOUR);
    /* Инициализируем дни месяца */
    DAYS_INIT(RDG => RDG, TJOB_DAYS => TDAYS, DDATE_FROM => DDATE_FROM, DDATE_TO => DDATE_TO);
    /* Обходим данные */
    begin
      /* Добавляем подсказку совместимости */
      CSQL := PKG_SQL_BUILD.COMPATIBLE(SSQL => CSQL);
      /* Формируем запрос */
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => 'select *');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '  from (select D.*,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.SQLROWNUM() || ' NROW');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '          from (select EQ.RN NRN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       EQ.CODE SCODE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       EQ.NAME SNAME,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       I.CODE SSUBDIV,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       ROUND(sum(case');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               when JS.WORK_DATE is not null then');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 JS.LABOUR_FACT');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               else');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 ' || PKG_SQL_BUILD.WRAP_NUM(NVALUE => 0));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               end) / ' || PKG_SQL_BUILD.WRAP_NUM(NVALUE => 60));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                    / ' || PKG_SQL_BUILD.WRAP_NUM(NVALUE => 160) || ', 3) NPROCENT_LOAD,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       ROUND(sum(case');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                             when JS.WORK_DATE is null then');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               F_DICMUNTS_BASE_RECALC_QUANT(0,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                            T.COMPANY,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                            JS.MUNIT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                            JS.LABOUR_PLAN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                            :NDICMUNTS)');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                             else');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                               ' || PKG_SQL_BUILD.WRAP_NUM(NVALUE => 0));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                             end), 3) NLOAD');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  from FCJOBS         T,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       FCJOBSSP       JS,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       FCEQUIPMENT    EQ,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       INS_DEPARTMENT I');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                 where T.COMPANY = :NCOMPANY');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T.DOCDATE >= :DDATE_FROM');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T.DOCDATE <= :DDATE_TO');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and PKG_P8PANELS_MECHREC.UTL_SUBDIV_HIER_CHECK(T.COMPANY, T.SUBDIV, UTILIZER()) = ' || PKG_SQL_BUILD.WRAP_NUM(NVALUE => 1));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and JS.PRN = T.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and EQ.RN = JS.EQUIP_PLAN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and I.RN = T.SUBDIV');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and exists ( select null from V_USERPRIV UP where UP."CATALOG" = T.CRN )');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                 group by EQ.RN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                          EQ.CODE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                          EQ.NAME,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                          I.CODE');
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
      PKG_SQL_DML.BIND_VARIABLE_DATE(ICURSOR => ICURSOR, SNAME => 'DDATE_FROM', DVALUE => DDATE_FROM);
      PKG_SQL_DML.BIND_VARIABLE_DATE(ICURSOR => ICURSOR, SNAME => 'DDATE_TO', DVALUE => DDATE_TO);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NDICMUNTS', NVALUE => NDICMUNTS_WD);
      /* Описываем структуру записи курсора */
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 1);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 2);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 3);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 4);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 5);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 6);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 7);
      /* Делаем выборку */
      if (PKG_SQL_DML.EXECUTE(ICURSOR => ICURSOR) = 0) then
        null;
      end if;
      /* Обходим выбранные записи */
      while (PKG_SQL_DML.FETCH_ROWS(ICURSOR => ICURSOR) > 0)
      loop
        /* Считываем рег. номер оборудования */
        PKG_SQL_DML.COLUMN_VALUE_NUM(ICURSOR => ICURSOR, IPOSITION => 1, NVALUE => NFCEQUIPMENT);
        /* Добавляем колонки с данными */
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NRN', NVALUE => NFCEQUIPMENT, BCLEAR => true);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SCODE', ICURSOR => ICURSOR, NPOSITION => 2);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SNAME', ICURSOR => ICURSOR, NPOSITION => 3);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SSUBDIV', ICURSOR => ICURSOR, NPOSITION => 4);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NPROCENT_LOAD',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 5);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW => RDG_ROW, SNAME => 'NLOAD', ICURSOR => ICURSOR, NPOSITION => 6);
        /* Обходим загруженность по дням */
        for REC in (select max(TMP.WORK_HOURS) NWORK_HOURS,
                           TMP.BEG_DATE DBEG_DATE,
                           SUM(TMP.LABOUR_PLAN) NLABOUR_PLAN,
                           SUM(TMP.LABOUR_FACT) NLABOUR_FACT
                      from (select BO.RN TBOPERMODESP,
                                   case BO.SIGN_SHIFT
                                     when 0 then
                                      (BO.END_TIME - BO.BEG_TIME) * 24
                                     else
                                      (BO.END_TIME + 1 - BO.BEG_TIME) * 24
                                   end WORK_HOURS,
                                   TRUNC(COALESCE(T.BEG_FACT, T.BEG_PLAN)) BEG_DATE,
                                   F_DICMUNTS_BASE_RECALC_QUANT(0, T.COMPANY, T.MUNIT, T.LABOUR_PLAN, NDICMUNTS_HOUR) LABOUR_PLAN,
                                   F_DICMUNTS_BASE_RECALC_QUANT(0, T.COMPANY, T.MUNIT, T.LABOUR_FACT, NDICMUNTS_HOUR) LABOUR_FACT
                              from FCJOBSSP     T,
                                   FCJOBS       J,
                                   TBOPERMODESP BO
                             where T.COMPANY = NCOMPANY
                               and J.RN = T.PRN
                               and T.BEG_PLAN is not null
                               and T.BEG_PLAN <= DDATE_TO
                               and T.BEG_PLAN >= DDATE_FROM
                               and PKG_P8PANELS_MECHREC.UTL_SUBDIV_HIER_CHECK(J.COMPANY, J.SUBDIV, SUTILIZER) = 1
                               and T.EQUIP_PLAN = NFCEQUIPMENT
                               and BO.RN = COALESCE(J.TBOPERMODESP, T.TBOPERMODESP)
                             order by T.BEG_FACT) TMP
                     group by TMP.BEG_DATE
                     order by TMP.BEG_DATE)
        loop
          /* Считываем индекс коллеции текущего дня */
          NINDEX := TDAYS_INDEX_GET(TDAYS => TDAYS, DDATE => REC.DBEG_DATE);
          /* Если факта меньше, чем плана */
          if (REC.NLABOUR_FACT < REC.NLABOUR_PLAN) then
            /* Тип дня - невыполненный */
            TDAYS(NINDEX).NTYPE := 0;
          else
            /* Тип дня - невыполненный */
            TDAYS(NINDEX).NTYPE := 1;
          end if;
          /* Если часов трудоемкости больше рабочего времени */
          if (REC.NLABOUR_PLAN > REC.NWORK_HOURS) then
            /* Указываем полную смену */
            TDAYS(NINDEX).NVALUE := 1;
          else
            /* Указываем долю трудоемкости на смену */
            TDAYS(NINDEX).NVALUE := REC.NLABOUR_PLAN / REC.NWORK_HOURS;
          end if;
        end loop;
        /* Обходим все дни */
        for I in TDAYS.FIRST .. TDAYS.LAST
        loop
          /* Отмечаем значение дня */
          PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW   => RDG_ROW,
                                           SNAME  => 'N_' || TO_CHAR(TDAYS(I).DDATE, SCOL_PATTERN_DATE) || '_VALUE',
                                           NVALUE => ROUND(TDAYS(I).NVALUE, 3));
          /* Отмечаем тип дня */
          PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW   => RDG_ROW,
                                           SNAME  => 'N_' || TO_CHAR(TDAYS(I).DDATE, SCOL_PATTERN_DATE) || '_TYPE',
                                           NVALUE => TDAYS(I).NTYPE);
          /* Обнуляем значения дня */
          TDAYS(I).NVALUE := 0;
          TDAYS(I).NTYPE := null;
        end loop;
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
    /* Добавление информации в итоговый результат */
    ADD_INFO(NCOMPANY => NCOMPANY, SUTILIZER => SUTILIZER, COUT => COUT);
  end FCJOBS_DEP_LOAD_DG_GET;
  
  /*
    Процедуры панели "Мониторинг сборки изделий"
  */
    
  /* Считывание рег. номера спецификации связанного плана */
  function FCPRODPLANSP_LINKED_GET
  (
    NPRODCMPSP              in number,    -- Рег. номер производственного состава
    NFCPRODPLAN             in number     -- Рег. номер план
  ) return                  number        -- Рег. номер спецификации связанного плана
  is
    NRESULT                 PKG_STD.TREF; -- Рег. номер спецификации связанного плана
  begin
    /* Считываем запись */
    begin
      select S.RN
        into NRESULT
        from FCPRODPLAN   T,
             FCPRODPLANSP S
       where T.RN = (select P.RN
                       from DOCLINKS   L,
                            FCPRODPLAN P
                      where L.IN_DOCUMENT = NFCPRODPLAN
                        and L.IN_UNITCODE = 'CostProductPlans'
                        and L.OUT_UNITCODE = 'CostProductPlans'
                        and P.RN = L.OUT_DOCUMENT
                        and P.CATEGORY = 1
                        and ROWNUM = 1)
         and S.PRN = T.RN
         and S.PRODCMPSP = NPRODCMPSP;
    exception
      when others then
        NRESULT := null;
    end;
    /* Возвращаем результат */
    return NRESULT;
  end FCPRODPLANSP_LINKED_GET;
  
  /* Получение таблицы маршрутных листов, связанных с производственным составом */
  procedure FCROUTLST_DG_BY_PRDCMPSP_GET
  (
    NPRODCMPSP              in number,                             -- Рег. номер производственного состава
    NFCPRODPLAN             in number,                             -- Рег. номер план
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
    NFCPRODPLANSP           PKG_STD.TREF;                          -- Рег. номер спецификации связанного плана
    NFCROUTLST_IDENT        PKG_STD.TREF;                          -- Рег. номер идентификатора отмеченных записей маршрутных листов
    NDICMUNTS_WD            PKG_STD.TREF;                          -- Рег. номер ед. измерения нормочасов
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
                                               SNAME      => 'SNUMB',
                                               SCAPTION   => '% п/п',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SOPERATION',
                                               SCAPTION   => 'Содержание работ',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SEXECUTOR',
                                               SCAPTION   => 'Исполнитель',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NREMN_LABOUR',
                                               SCAPTION   => 'Остаточная трудоемкость, в н/ч',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true);
    /* Считываем рег. номер спецификации связанного плана */
    NFCPRODPLANSP := FCPRODPLANSP_LINKED_GET(NPRODCMPSP  => NPRODCMPSP, NFCPRODPLAN => NFCPRODPLAN);    
    /* Если спецификация считалась */
    if (NFCPRODPLANSP is not null) then
      /* Инициализируем список маршрутных листов */
      UTL_FCROUTLST_IDENT_INIT(NFCPRODPLANSP => NFCPRODPLANSP, NIDENT => NFCROUTLST_IDENT);
      /* Считываем единицу измерения нормочасов */
      FIND_DICMUNTS_CODE(NFLAG_SMART  => 0,
                         NFLAG_OPTION => 0,
                         NCOMPANY     => NCOMPANY,
                         SMEAS_MNEMO  => SDICMUNTS_WD,
                         NRN          => NDICMUNTS_WD);
      begin
        /* Добавляем подсказку совместимости */
        CSQL := PKG_SQL_BUILD.COMPATIBLE(SSQL => CSQL);
        /* Формируем запрос */
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => 'select *');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '  from (select D.*,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.SQLROWNUM() || ' NROW');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '          from (select SF.RN NRN,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       TRIM(SH.NUMB) SNUMB,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       COALESCE(SH.OPER_UK, FT.NAME) SOPERATION,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       (select I.CODE from INS_DEPARTMENT I where SF.SUBDIV = I.RN) SEXECUTOR,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       ROUND(F_DICMUNTS_BASE_RECALC_QUANT(' || PKG_SQL_BUILD.WRAP_NUM(NVALUE => 0) || ',');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                          :NCOMPANY,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                          SF.MUNIT,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                          SF.T_SHT_PLAN - SF.LABOUR_FACT,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                                          :NDICMUNTS_WD), 3) NREMN_LABOUR'); 
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  from FCROUTLST F,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       FCROUTLSTSP SF,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       FCROUTSHTSP SH left outer join FCOPERTYPES FT on SH.OPER_TPS = FT.RN');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                 where F.RN in (select SL."DOCUMENT"');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                  from SELECTLIST SL');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                 where SL.IDENT    = :NFCROUTLST_IDENT');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                                   and SL.UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostRouteLists') || ')');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and SF.PRN = F.RN');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and SH.RN = SF.FCROUTSHTSP');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and F.COMPANY = :NCOMPANY');
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
        PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NDICMUNTS_WD', NVALUE => NDICMUNTS_WD);
        PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NFCROUTLST_IDENT', NVALUE => NFCROUTLST_IDENT);
        /* Описываем структуру записи курсора */
        PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 1);
        PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 2);
        PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 3);
        PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 4);
        PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 5);
        PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 6);
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
                                                SNAME     => 'SNUMB',
                                                ICURSOR   => ICURSOR,
                                                NPOSITION => 2);
          PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                                SNAME     => 'SOPERATION',
                                                ICURSOR   => ICURSOR,
                                                NPOSITION => 3);
          PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                                SNAME     => 'SEXECUTOR',
                                                ICURSOR   => ICURSOR,
                                                NPOSITION => 4);
          PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                                SNAME     => 'NREMN_LABOUR',
                                                ICURSOR   => ICURSOR,
                                                NPOSITION => 5);
          /* Добавляем строку в таблицу */
          PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW);
        end loop;
      exception
        when others then
          PKG_SQL_DML.CLOSE_CURSOR(ICURSOR => ICURSOR);
          raise;
      end;
    end if;
    /* Очищаем отмеченные маршрутные листы */
    P_SELECTLIST_CLEAR(NIDENT => NFCROUTLST_IDENT);
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TDATA_GRID_TO_XML(RDATA_GRID => RDG, NINCLUDE_DEF => NINCLUDE_DEF);
  exception
    when others then
      /* Очищаем отмеченные маршрутные листы */
      P_SELECTLIST_CLEAR(NIDENT => NFCROUTLST_IDENT);
      raise;
  end FCROUTLST_DG_BY_PRDCMPSP_GET;
  
  /* Получение таблицы комплектовочных ведомостей, связанных с производственным составом */
  procedure FCDELIVSH_DG_BY_PRDCMPSP_GET
  (
    NPRODCMPSP              in number,                             -- Рег. номер производственного состава
    NFCPRODPLAN             in number,                             -- Рег. номер план
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
    NFCPRODPLANSP           PKG_STD.TREF;                          -- Рег. номер спецификации связанного плана
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
                                               SNAME      => 'SSUBDIV',
                                               SCAPTION   => 'Цех',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SNOMEN',
                                               SCAPTION   => 'Номенклатура',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NQUANT_PROD',
                                               SCAPTION   => 'Применяемость на одно ВС',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SPROVIDER',
                                               SCAPTION   => 'Поставщик',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NDEFICIT',
                                               SCAPTION   => 'Дефицит',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => true);
    /* Считываем рег. номер спецификации связанного плана */
    NFCPRODPLANSP := FCPRODPLANSP_LINKED_GET(NPRODCMPSP  => NPRODCMPSP, NFCPRODPLAN => NFCPRODPLAN);
    /* Если спецификация считалась */
    if (NFCPRODPLANSP is not null) then
      begin
        /* Добавляем подсказку совместимости */
        CSQL := PKG_SQL_BUILD.COMPATIBLE(SSQL => CSQL);
        /* Формируем запрос */
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => 'select *');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '  from (select D.*,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.SQLROWNUM() || ' NROW');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '          from (select T.RN NRN,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       (select I.CODE from INS_DEPARTMENT I where T.SUBDIV = I.RN) SSUBDIV,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       NM.NOMEN_NAME SNOMEN,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.QUANT_PROD NQUANT_PROD,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       (select I2.CODE from INS_DEPARTMENT I2 where T.PR_SUBDIV = I2.RN) SPROVIDER,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       T.DEFICIT NDEFICIT');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  from DOCLINKS D,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       FCDELIVSHSP T,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       FCMATRESOURCE F,');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       DICNOMNS NM');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                 where D.IN_DOCUMENT = :NFCPRODPLANSP');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and D.IN_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostProductPlansSpecs'));
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and D.OUT_UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostDeliverySheets'));
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T.PRN = D.OUT_DOCUMENT');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T.COMPANY = :NCOMPANY');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and T.MATRES = F.RN');
        PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and F.NOMENCLATURE = NM.RN');
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
        PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 4);
        PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 5);
        PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 6);
        PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 7);
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
                                                SNAME     => 'SSUBDIV',
                                                ICURSOR   => ICURSOR,
                                                NPOSITION => 2);
          PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                                SNAME     => 'SNOMEN',
                                                ICURSOR   => ICURSOR,
                                                NPOSITION => 3);
          PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                                SNAME     => 'NQUANT_PROD',
                                                ICURSOR   => ICURSOR,
                                                NPOSITION => 4);
          PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                                SNAME     => 'SPROVIDER',
                                                ICURSOR   => ICURSOR,
                                                NPOSITION => 5);
          PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                                SNAME     => 'NDEFICIT',
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
    end if;
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TDATA_GRID_TO_XML(RDATA_GRID => RDG, NINCLUDE_DEF => NINCLUDE_DEF);
  end FCDELIVSH_DG_BY_PRDCMPSP_GET;
  
  /* Получение изображения для записи "Планы и отчеты производства изделий" */
  function FCPRODPLAN_IMAGE_GET
  (
    NRN                     in number,  -- Рег. номер записи плана производства изделий
    SFLINKTYPE              in varchar2 -- Код типа присоединённого документа изображения (см. константы SFLINKTYPE_*)
  ) return                  blob        -- Данные считанного изображения (null - если ничего не найдено)
  is
  begin
    /* Найдем изображение */
    for IMG in (select M.BDATA
                  from FILELINKS      M,
                       FILELINKSUNITS U,
                       FLINKTYPES     FLT
                 where M.FILE_TYPE = FLT.RN
                   and FLT.CODE = SFLINKTYPE
                   and U.TABLE_PRN = NRN
                   and U.UNITCODE = 'CostProductPlans'
                   and M.RN = U.FILELINKS_PRN
                   and M.BDATA is not null
                   and ROWNUM = 1)
    loop
      /* Вернём его */
      return IMG.BDATA;
    end loop;
    /* Ничего не нашли */
    return null;
  end FCPRODPLAN_IMAGE_GET;
  
  /* Получение таблицы записей "Планы и отчеты производства изделий" */
  procedure FCPRODPLAN_GET
  (
    NCRN                    in number,        -- Рег. номер каталога
    COUT                    out clob          -- Сериализованная таблица данных
  )
  is
    NPROGRESS               PKG_STD.TLNUMBER; -- Прогресс плана
    
    /* Получение номера плана из примечания */
    function NUMB_BY_NOTE_GET
    (
      SNOTE                 in varchar2 -- Примечание
    ) return                varchar2    -- Номер плана
    is
    begin
      /* Возвращаем результат */
      return trim(SUBSTR(SNOTE, INSTR(SNOTE, '№') + 1, LENGTH(SNOTE)));
    end NUMB_BY_NOTE_GET;
    
    /* Получение детализации по прогрессу */
    function DETAIL_BY_PROGRESS_GET
    (
      NPROGRESS             in number        -- Прогресс
    ) return                varchar2         -- Детализация по прогрессу
    is
      SRESULT               PKG_STD.TSTRING; -- Детализация по прогрессу
    begin
      /* Определяем детализацию по прогрессу */
      case
        when (NPROGRESS >= 70) then
          SRESULT := 'Основная сборка: Стыковка агрегатов выполнена';
        when (NPROGRESS >= 40) then
          SRESULT := 'Изготовление агрегатов: Фюзеляж и ОЧК не переданы в цех ОС';
        when (NPROGRESS >= 10) then
          SRESULT := 'Изготовление ДСЕ: Фюзеляж и ОЧК не укомлектованы ДСЕ';
        else
          SRESULT := 'Изготовление ДСЕ не начато';
      end case;
      /* Возвращаем результат */
      return SRESULT;
    end DETAIL_BY_PROGRESS_GET;
  begin
    /* Начинаем формирование XML */
    PKG_XFAST.PROLOGUE(ITYPE => PKG_XFAST.CONTENT_);
    /* Открываем корень */
    PKG_XFAST.DOWN_NODE(SNAME => 'XDATA');
    /* Цикл по планам и отчетам производства изделий */
    for REC in (select P.RN NRN,
                       P.NOTE SNOTE,
                       D_YEAR(EN.STARTDATE) NYEAR,
                       COALESCE(sum(SP.LABOUR_FACT), 0) NLABOUR_FACT,
                       COALESCE(sum(SP.LABOUR_PLAN), 0) NLABOUR_PLAN
                  from FCPRODPLAN P
                  left outer join FCPRODPLANSP SP
                    on P.RN = SP.PRN
                   and ((SP.LABOUR_PLAN is not null) or (SP.LABOUR_FACT is not null)), FINSTATE FS, ENPERIOD EN
                 where P.CRN = NCRN
                   and P.CATEGORY = NFCPRODPLAN_CATEGORY_MON
                   and P.STATUS = NFCPRODPLAN_STATUS_MON
                   and FS.RN = P.TYPE
                   and FS.CODE = SFCPRODPLAN_TYPE_MON
                   and EN.RN = P.CALC_PERIOD
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
                 group by P.RN,
                          P.NOTE,
                          EN.STARTDATE
                 order by EN.STARTDATE asc)
    loop
      /* Открываем план */
      PKG_XFAST.DOWN_NODE(SNAME => 'XFCPRODPLAN_INFO');
      /* Описываем план */
      PKG_XFAST.ATTR(SNAME => 'NRN', NVALUE => REC.NRN);
      PKG_XFAST.ATTR(SNAME => 'SNUMB', SVALUE => NUMB_BY_NOTE_GET(SNOTE => REC.SNOTE));
      /* Определяем прогресс */
      if (REC.NLABOUR_PLAN = 0) then
        /* Не можем определить прогресс */
        NPROGRESS := 0;
      else
        /* Если факта нет */
        if (REC.NLABOUR_FACT = 0) then
          /* Не можем определить прогресс */
          NPROGRESS := 0;
        else
          /* Определим прогресс */
          NPROGRESS := ROUND(REC.NLABOUR_FACT / REC.NLABOUR_PLAN * 100, 2);
        end if;
      end if;
      PKG_XFAST.ATTR(SNAME => 'NPROGRESS', NVALUE => NPROGRESS);
      PKG_XFAST.ATTR(SNAME => 'SDETAIL', SVALUE => DETAIL_BY_PROGRESS_GET(NPROGRESS => NPROGRESS));
      PKG_XFAST.ATTR(SNAME => 'NYEAR', NVALUE => REC.NYEAR);
      PKG_XFAST.DOWN_NODE(SNAME => 'BIMAGE');
      PKG_XFAST.VALUE(LBVALUE => FCPRODPLAN_IMAGE_GET(NRN => REC.NRN, SFLINKTYPE => SFLINKTYPE_PREVIEW));
      PKG_XFAST.UP();
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
  end FCPRODPLAN_GET;
  
  /* Инициализация каталогов раздела "Планы и отчеты производства изделий" для панели "Мониторинг сборки изделий"  */
  procedure FCPRODPLAN_AM_CTLG_INIT
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
    for REC in (select TMP.NRN,
                       TMP.SNAME,
                       count(P.RN) NCOUNT_DOCS,
                       min(D_YEAR(ENP.STARTDATE)) NMIN_YEAR,
                       max(D_YEAR(ENP.ENDDATE)) NMAX_YEAR
                  from (select T.RN   as NRN,
                               T.NAME as SNAME
                          from ACATALOG T,
                               UNITLIST UL
                         where T.DOCNAME = 'CostProductPlans'
                           and T.COMPANY = GET_SESSION_COMPANY()
                           and T.SIGNS = 1
                           and T.DOCNAME = UL.UNITCODE
                           and (UL.SHOW_INACCESS_CTLG = 1 or exists
                                (select null from V_USERPRIV UP where UP.CATALOG = T.RN) or exists
                                (select null
                                   from ACATALOG T1
                                  where exists (select null from V_USERPRIV UP where UP.CATALOG = T1.RN)
                                 connect by prior T1.RN = T1.CRN
                                  start with T1.CRN = T.RN))
                         order by T.NAME asc) TMP
                  left outer join FCPRODPLAN P
                    on TMP.NRN = P.CRN
                   and P.CATEGORY = NFCPRODPLAN_CATEGORY_MON
                   and P.STATUS = NFCPRODPLAN_STATUS_MON
                   and P.COMPANY = GET_SESSION_COMPANY()
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
                  left outer join FINSTATE FS
                    on P.TYPE = FS.RN
                   and FS.CODE = SFCPRODPLAN_TYPE_MON
                  left join ENPERIOD ENP
                    on P.CALC_PERIOD = ENP.RN
                 group by TMP.NRN,
                          TMP.SNAME
                 order by TMP.SNAME asc)
    loop
      /* Открываем план */
      PKG_XFAST.DOWN_NODE(SNAME => 'XFCPRODPLAN_CRNS');
      /* Описываем план */
      PKG_XFAST.ATTR(SNAME => 'NRN', NVALUE => REC.NRN);
      PKG_XFAST.ATTR(SNAME => 'SNAME', SVALUE => REC.SNAME);
      PKG_XFAST.ATTR(SNAME => 'NCOUNT_DOCS', NVALUE => REC.NCOUNT_DOCS);
      PKG_XFAST.ATTR(SNAME => 'NMIN_YEAR', NVALUE => REC.NMIN_YEAR);
      PKG_XFAST.ATTR(SNAME => 'NMAX_YEAR', NVALUE => REC.NMAX_YEAR);
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
  end FCPRODPLAN_AM_CTLG_INIT;

  /* Считывание деталей производственного состава */
  procedure FCPRODCMP_DETAILS_GET
  (
    NFCPRODPLAN             in number,                             -- Рег. номер плана
    COUT                    out clob                               -- Сериализованная таблица данных
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
    NDP_MODEL_ID            PKG_STD.TREF;                          -- Рег. номер свойства "Идентификатор в SVG-модели"
    NDP_MODEL_BG_COLOR      PKG_STD.TREF;                          -- Рег. номер свойства "Цвет заливки в SVG-модели"
    NFCPRODPLANSP           PKG_STD.TREF;                          -- Рег. номер связанной спецификации плана
  begin
    /* Начинаем формирование XML */
    PKG_XFAST.PROLOGUE(ITYPE => PKG_XFAST.CONTENT_);
    /* Считываем свойства детали для её позиционирования в модели */
    FIND_DOCS_PROPS_CODE_EX(NFLAG_SMART => 1,
                            NCOMPVERS   => NCOMPANY,
                            SUNITCODE   => 'CostProductCompositionSpec',
                            SPROPCODE   => SDP_MODEL_ID,
                            NRN         => NDP_MODEL_ID);
    FIND_DOCS_PROPS_CODE_EX(NFLAG_SMART => 1,
                            NCOMPVERS   => NCOMPANY,
                            SUNITCODE   => 'CostProductCompositionSpec',
                            SPROPCODE   => SDP_MODEL_BG_COLOR,
                            NRN         => NDP_MODEL_BG_COLOR);
    /* Открываем корень */
    PKG_XFAST.DOWN_NODE(SNAME => 'XDATA');
    /* Векторная модель */
    PKG_XFAST.DOWN_NODE(SNAME => 'BMODEL');
    PKG_XFAST.VALUE(LBVALUE => FCPRODPLAN_IMAGE_GET(NRN => NFCPRODPLAN, SFLINKTYPE => SFLINKTYPE_SVG_MODEL));
    PKG_XFAST.UP();
    /* Цикл по планам и отчетам производства изделий */
    for REC in (select S.RN NRN,
                       (select F.NAME from FCMATRESOURCE F where F.RN = S.MTR_RES) SNAME,
                       PV_MID.STR_VALUE SMODEL_ID,
                       (select PV_MFC.STR_VALUE
                          from DOCS_PROPS_VALS PV_MFC
                         where PV_MFC.UNIT_RN = S.RN
                           and PV_MFC.DOCS_PROP_RN = NDP_MODEL_BG_COLOR) SMODEL_BG_COLOR
                  from FCPRODPLANSP    T,
                       FCPRODCMPSP     S,
                       DOCS_PROPS_VALS PV_MID
                 where T.PRN = NFCPRODPLAN
                   and S.PRN = T.PRODCMP
                   and PV_MID.UNIT_RN = S.RN
                   and PV_MID.DOCS_PROP_RN = NDP_MODEL_ID)
    loop
      /* Получаем рег. номер связанной спецификации плана */
      NFCPRODPLANSP := FCPRODPLANSP_LINKED_GET(NPRODCMPSP => REC.NRN, NFCPRODPLAN => NFCPRODPLAN);
      /* Открываем план */
      PKG_XFAST.DOWN_NODE(SNAME => 'XFCPRODCMP');
      /* Описываем план */
      PKG_XFAST.ATTR(SNAME => 'NRN', NVALUE => REC.NRN);
      PKG_XFAST.ATTR(SNAME => 'SNAME', SVALUE => REC.SNAME);
      PKG_XFAST.ATTR(SNAME => 'SMODEL_ID', SVALUE => REC.SMODEL_ID);
      PKG_XFAST.ATTR(SNAME => 'SMODEL_BG_COLOR', SVALUE => REC.SMODEL_BG_COLOR);
      PKG_XFAST.ATTR(SNAME => 'NFCPRODPLANSP', NVALUE => NFCPRODPLANSP);
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
  end FCPRODCMP_DETAILS_GET;

end PKG_P8PANELS_MECHREC;
/

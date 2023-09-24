create or replace package PKG_P8PANELS_PROJECTS as

  /* Типы данных - статьи этапа проекта */
  type TSTAGE_ART is record
  (
    NRN                     FPDARTCL.RN%type,   -- Рег. номер статьи
    SCODE                   FPDARTCL.CODE%type, -- Код статьи
    SNAME                   FPDARTCL.NAME%type, -- Наименование статьи
    NPLAN                   PKG_STD.TNUMBER,    -- Плановое значение по статье
    NCOST_FACT              PKG_STD.TNUMBER,    -- Фактические затраты (null - не подлежит контролю затрат)
    NCOST_DIFF              PKG_STD.TNUMBER,    -- Отклонение по затратам (null - не подлежит контролю затрат)
    NCTRL_COST              PKG_STD.TNUMBER,    -- Контроль затрат (null - не подлежит контролю затрат, 0 - без отклонений, 1 - есть отклонения)
    NCONTR                  PKG_STD.TNUMBER,    -- Законтрактовано (null - не подлежит контролю контрактации)
    NCONTR_LEFT             PKG_STD.TNUMBER,    -- Остаток к контрактации (null - не подлежит контролю контрактации)
    NCTRL_CONTR             PKG_STD.TNUMBER     -- Контроль контрактации (null - не подлежит контролю контрактации, 0 - без отклонений, 1 - есть отклонения)
  );
  
  /* Типы данных - коллекция статей этапа проекта */
  type TSTAGE_ARTS is table of TSTAGE_ART; 

  /* Отбор проектов */
  procedure COND;

  /* Получение рег. номера документа основания (договора) проекта */
  function GET_DOC_OSN_LNK_DOCUMENT
  (
    NRN                     in number   -- Рег. номер проекта
  ) return                  number;     -- Рег. номер документа основания (договора)

  /* Подбор платежей финансирования проекта */
  procedure SELECT_FIN
  (
    NRN                     in number, -- Рег. номер проекта
    NDIRECTION              in number, -- Направление (0 - приход, 1 - расход)
    NIDENT                  out number -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  );
  
  /* Получение суммы входящего финансирования проекта */
  function GET_FIN_IN
  (
    NRN                     in number   -- Рег. номер проекта
  ) return                  number;     -- Сумма входящего финансирования проекта

  /* Получение суммы исходящего финансирования проекта */
  function GET_FIN_OUT
  (
    NRN                     in number   -- Рег. номер проекта
  ) return                  number;     -- Сумма исходяшего финансирования проекта

  /* Получение состояния финансирования проекта */
  function GET_CTRL_FIN
  (
    NRN                     in number   -- Рег. номер проекта
  ) return                  number;     -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)

  /* Получение состояния контрактации проекта */
  function GET_CTRL_CONTR
  (
    NRN                     in number   -- Рег. номер проекта
  ) return                  number;     -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)

  /* Получение состояния соисполнения проекта */
  function GET_CTRL_COEXEC
  (
    NRN                     in number   -- Рег. номер проекта
  ) return                  number;     -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)

  /* Получение состояния сроков проекта */
  function GET_CTRL_PERIOD
  (
    NRN                     in number   -- Рег. номер проекта
  ) return                  number;     -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  
  /* Получение состояния затрат проекта */
  function GET_CTRL_COST
  (
    NRN                     in number   -- Рег. номер проекта
  ) return                  number;     -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  
  /* Получение состояния актирования проекта */
  function GET_CTRL_ACT
  (
    NRN                     in number   -- Рег. номер проекта
  ) return                  number;     -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)

  /* Список проектов */
  procedure LIST
  (
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    CFILTERS                in clob,    -- Фильтры
    CORDERS                 in clob,    -- Сортировки
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
  );
  
  /* Отбор этапов проектов */
  procedure STAGES_COND;
  
  
  /* Подбор платежей финансирования этапа проекта */
  procedure STAGES_SELECT_FIN
  (
    NPRN                    in number := null, -- Рег. номер проекта (null - не отбирать по проекту)
    NRN                     in number := null, -- Рег. номер этапа проекта (null - не отбирать по этапу)
    NDIRECTION              in number,         -- Направление (0 - приход, 1 - расход)
    NIDENT                  out number         -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  );
  
  /* Получение суммы входящего финансирования этапа проекта */
  function STAGES_GET_FIN_IN
  (
    NRN                     in number   -- Рег. номер этапа проекта
  ) return                  number;     -- Сумма входящего финансирования проекта

  /* Получение суммы исходящего финансирования этапа проекта */
  function STAGES_GET_FIN_OUT
  (
    NRN                     in number   -- Рег. номер этапа проекта
  ) return                  number;     -- Сумма исходяшего финансирования проекта

  /* Получение состояния финансирования этапа проекта */
  function STAGES_GET_CTRL_FIN
  (
    NRN                     in number   -- Рег. номер этапа проекта
  ) return                  number;     -- Состояние (0 - без отклонений, 1 - есть отклонения)

  /* Получение состояния контрактации этапа проекта */
  function STAGES_GET_CTRL_CONTR
  (
    NRN                     in number   -- Рег. номер этапа проекта
  ) return                  number;     -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)

  /* Получение состояния соисполнения этапа проекта */
  function STAGES_GET_CTRL_COEXEC
  (
    NRN                     in number   -- Рег. номер этапа проекта
  ) return                  number;     -- Состояние (0 - без отклонений, 1 - есть отклонения)
  
  /* Получение состояния сроков этапа проекта */
  function STAGES_GET_CTRL_PERIOD
  (
    NRN                     in number   -- Рег. номер этапа проекта
  ) return                  number;     -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  
  /* Получение состояния затрат этапа проекта */
  function STAGES_GET_CTRL_COST
  (
    NRN                     in number   -- Рег. номер этапа проекта
  ) return                  number;     -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  
  /* Получение состояния актирования этапа проекта */
  function STAGES_GET_CTRL_ACT
  (
    NRN                     in number   -- Рег. номер этапа проекта
  ) return                  number;     -- Состояние (0 - без отклонений, 1 - есть отклонения)
  
  /* Получение остатка срока исполнения этапа проекта */
  function STAGES_GET_DAYS_LEFT
  (
    NRN                     in number   -- Рег. номер этапа проекта
  ) return                  number;     -- Количество дней (null - не определено)
  
  /* Подбор записей журнала затрат этапа проекта */
  procedure STAGES_SELECT_COST_FACT
  (
    NRN                     in number,  -- Рег. номер этапа проекта (null - не отбирать по этапу)
    NIDENT                  out number  -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  );
  
  /* Получение суммы фактических затрат этапа проекта */
  function STAGES_GET_COST_FACT
  (
    NRN                     in number   -- Рег. номер этапа проекта
  ) return                  number;     -- Сумма фактических затрат

  /* Получение суммы реализации этапа проекта */
  function STAGES_GET_SUMM_REALIZ
  (
    NRN                     in number,  -- Рег. номер этапа проекта
    NFPDARTCL_REALIZ        in number   -- Рег. номер статьи калькуляции для реализации
  ) return                  number;     -- Сумма реализации
  
  /* Список этапов */
  procedure STAGES_LIST
  (
    NPRN                    in number,  -- Рег. номер проекта
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    CFILTERS                in clob,    -- Фильтры
    CORDERS                 in clob,    -- Сортировки
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
  );
  
  /* Подбор записей журнала затрат по статье калькуляции этапа проекта */
  procedure STAGE_ARTS_SELECT_COST_FACT
  (
    NSTAGE                  in number,         -- Рег. номер этапа проекта
    NFPDARTCL               in number := null, -- Рег. номер статьи затрат (null - по всем)
    NFINFLOW_TYPE           in number := null, -- Вид движения по статье (null - по всем, 0 - остаток, 1 - приход, 2 - расход)
    NIDENT                  out number         -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  );
  
  /* Получение суммы-факт по статье калькуляции этапа проекта */
  function STAGE_ARTS_GET_COST_FACT
  (
    NSTAGE                  in number,         -- Рег. номер этапа проекта
    NFPDARTCL               in number := null, -- Рег. номер статьи калькуляции (null - по всем)
    NFINFLOW_TYPE           in number := null  -- Вид движения по статье (null - по всем, 0 - остаток, 1 - приход, 2 - расход)
  ) return                  number;            -- Сумма-факт по статье
  
  /* Подбор записей договоров с соисполнителями по статье калькуляции этапа проекта */
  procedure STAGE_ARTS_SELECT_CONTR
  (
    NSTAGE                  in number,         -- Рег. номер этапа проекта
    NFPDARTCL               in number := null, -- Рег. номер статьи затрат (null - по всем)
    NIDENT                  out number         -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  );
  
  /* Получение списка статей этапа проекта */
  procedure STAGE_ARTS_GET
  (
    NSTAGE                  in number,      -- Рег. номер этапа проекта  
    NINC_COST               in number := 0, -- Включить сведения о затратах (0 - нет, 1 - да)
    NINC_CONTR              in number := 0, -- Включить сведения о контрактации (0 - нет, 1 - да)
    RSTAGE_ARTS             out TSTAGE_ARTS -- Список статей этапа проекта
  );
  
  /* Список статей калькуляции этапа проекта */
  procedure STAGE_ARTS_LIST
  (
    NSTAGE                  in number,  -- Рег. номер этапа проекта
    CFILTERS                in clob,    -- Фильтры
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
  );

  /* Список договоров этапа проекта */
  procedure STAGE_CONTRACTS_COND;

  /* Список договоров этапа проекта */
  procedure STAGE_CONTRACTS_LIST
  (
    NSTAGE                  in number,  -- Рег. номер этапа проекта
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    CFILTERS                in clob,    -- Фильтры
    CORDERS                 in clob,    -- Сортировки
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
  );

end PKG_P8PANELS_PROJECTS;
/
create or replace package body PKG_P8PANELS_PROJECTS as

/*
TODO: owner="root" created="20.09.2023"
text="ПРАВА ДОСТУПА!!!!"
*/
  /* Константы - предопределённые значения */
  SYES                        constant PKG_STD.TSTRING := 'Да';              -- Да
  NDAYS_LEFT_LIMIT            constant PKG_STD.TNUMBER := 30;                -- Лимит отстатка дней для контроля сроков
  SFPDARTCL_REALIZ            constant PKG_STD.TSTRING := '14 Цена без НДС'; -- Мнемокод статьи калькуляции для учёта реализации

  /* Считывание записи проекта */
  function GET
  (
    NRN                     in number        -- Рег. номер проекта
  ) return                  PROJECT%rowtype  -- Запись проекта
  is
    RRES                    PROJECT%rowtype; -- Буфер для результата
  begin
    select P.* into RRES from PROJECT P where P.RN = NRN;
    return RRES;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0, NDOCUMENT => NRN, SUNIT_TABLE => 'PROJECT');
  end GET;

  /* Отбор проектов */
  procedure COND
  as
  begin
    /* Установка главной таблицы */
    PKG_COND_BROKER.SET_TABLE(STABLE_NAME => 'PROJECT');
    /* Тип проекта */
    PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'CODE',
                                       SCONDITION_NAME => 'EDPROJECTTYPE',
                                       SJOINS          => 'PRJTYPE <- RN;PRJTYPE');
    /* Мнемокод */
    PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME => 'CODE', SCONDITION_NAME => 'EDMNEMO');
    /* Наименование */
    PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME => 'NAME', SCONDITION_NAME => 'EDNAME');
    /* Услованое наименование */
    PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME => 'NAME_USL', SCONDITION_NAME => 'EDNAME_USL');
    /* Дата начала план */
    PKG_COND_BROKER.ADD_CONDITION_BETWEEN(SCOLUMN_NAME         => 'BEGPLAN',
                                          SCONDITION_NAME_FROM => 'EDPLANBEGFrom',
                                          SCONDITION_NAME_TO   => 'EDPLANBEGTo');
    /* Дата окончания план */
    PKG_COND_BROKER.ADD_CONDITION_BETWEEN(SCOLUMN_NAME         => 'ENDPLAN',
                                          SCONDITION_NAME_FROM => 'EDPLANENDFrom',
                                          SCONDITION_NAME_TO   => 'EDPLANENDTo');
    /* Состояние */
    PKG_COND_BROKER.ADD_CONDITION_ENUM(SCOLUMN_NAME => 'STATE', SCONDITION_NAME => 'CGSTATE');
    /* Заказчик */
    PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'AGNABBR',
                                       SCONDITION_NAME => 'EDEXT_CUST',
                                       SJOINS          => 'EXT_CUST <- RN;AGNLIST');
    /* Контроль финансирования */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_FIN') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => 'PKG_P8PANELS_PROJECTS.GET_CTRL_FIN(RN) = :EDCTRL_FIN');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_FIN',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_FIN'));
    end if;  
    /* Контроль контрактации */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_CONTR') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => 'PKG_P8PANELS_PROJECTS.GET_CTRL_CONTR(RN) = :EDCTRL_CONTR');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_CONTR',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_CONTR'));
    end if;
    /* Контроль соисполнения */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_COEXEC') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => 'PKG_P8PANELS_PROJECTS.GET_CTRL_COEXEC(RN) = :EDCTRL_COEXEC');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_COEXEC',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_COEXEC'));
    end if;
    /* Контроль сроков */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_PERIOD') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => 'PKG_P8PANELS_PROJECTS.GET_CTRL_PERIOD(RN) = :EDCTRL_PERIOD');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_PERIOD',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_PERIOD'));
    end if;
    /* Контроль затрат */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_COST') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => 'PKG_P8PANELS_PROJECTS.GET_CTRL_COST(RN) = :EDCTRL_COST');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_COST',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_COST'));
    end if;
    /* Контроль актирования */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_ACT') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => 'PKG_P8PANELS_PROJECTS.GET_CTRL_ACT(RN) = :EDCTRL_ACT');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_ACT',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_ACT'));
    end if;
  end COND;
  
  /* Получение рег. номера документа основания (договора) проекта */
  function GET_DOC_OSN_LNK_DOCUMENT
  (
    NRN                     in number   -- Рег. номер проекта
  ) return                  number      -- Рег. номер документа основания (договора)
  is
  begin
    /* Подберём договор с заказчиком по ЛС этапа проекта */
    for C in (select CN.RN
                from PROJECTSTAGE PS,
                     STAGES       S,
                     CONTRACTS    CN
               where PS.PRN = NRN
                 and PS.FACEACCCUST = S.FACEACC
                 and S.PRN = CN.RN
               group by CN.RN)
    loop
      /* Вернём первый найденный */
      return C.RN;
    end loop;
    /* Ничего не нашли */
    return null;
  end GET_DOC_OSN_LNK_DOCUMENT;

  /* Подбор платежей финансирования проекта */
  procedure SELECT_FIN
  (
    NRN                     in number, -- Рег. номер проекта
    NDIRECTION              in number, -- Направление (0 - приход, 1 - расход)
    NIDENT                  out number -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  )
  is
  begin
    /* Подберём платежи */
    STAGES_SELECT_FIN(NPRN => NRN, NDIRECTION => NDIRECTION, NIDENT => NIDENT);
  end SELECT_FIN;

  /* Получение суммы входящего финансирования проекта */
  function GET_FIN_IN
  (
    NRN                     in number             -- Рег. номер проекта
  ) return                  number                -- Сумма входящего финансирования проекта
  is
    NRES                    PKG_STD.TNUMBER := 0; -- Буфер для результата
  begin
    /* Обходим этапы и считаем */
    for C in (select PS.RN from PROJECTSTAGE PS where PS.PRN = NRN)
    loop
      NRES := NRES + STAGES_GET_FIN_IN(NRN => C.RN);
    end loop;
    /* Возвращаем результат */
    return NRES;
  end GET_FIN_IN;

  /* Получение суммы исходящего финансирования проекта */
  function GET_FIN_OUT
  (
    NRN                     in number             -- Рег. номер проекта
  ) return                  number                -- Сумма исходяшего финансирования проекта
  is
    NRES                    PKG_STD.TNUMBER := 0; -- Буфер для результата
  begin
    /* Обходим этапы и считаем */
    for C in (select PS.RN from PROJECTSTAGE PS where PS.PRN = NRN)
    loop
      NRES := NRES + STAGES_GET_FIN_OUT(NRN => C.RN);
    end loop;
    /* Возвращаем результат */
    return NRES;
  end GET_FIN_OUT;

  /* Получение состояния финансирования проекта */
  function GET_CTRL_FIN
  (
    NRN                     in number         -- Рег. номер проекта
  ) return                  number            -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  is
    BFOUND                  boolean := false; -- Флаг наличия этапов
  begin
    /* Обходим этапы */
    for C in (select PS.RN from PROJECTSTAGE PS where PS.PRN = NRN)
    loop
      /* Выставим флаг наличия этапов */
      BFOUND := true;
      /* Если у этапа есть отклонение - оно есть и у проекта */
      if (STAGES_GET_CTRL_FIN(NRN => C.RN) = 1) then
        return 1;
      end if;
    end loop;
    /* Если мы здесь - отклонений нет */
    if (BFOUND) then
      return 0;
    else
      return null;
    end if;
  end GET_CTRL_FIN;

  /* Получение состояния контрактации проекта */
  function GET_CTRL_CONTR
  (
    NRN                     in number            -- Рег. номер проекта
  ) return                  number               -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  is
    NSTAGE_CTRL             PKG_STD.TNUMBER;     -- Состояние этапа
    NCNT_STAGES             PKG_STD.TNUMBER :=0; -- Количество этапов
    NCNT_NULL               PKG_STD.TNUMBER :=0; -- Количество "безконтрольных" этапов
  begin
    /* Обходим этапы */
    for C in (select PS.RN from PROJECTSTAGE PS where PS.PRN = NRN)
    loop
      /* Увеличим счётчик этапов */
      NCNT_STAGES := NCNT_STAGES + 1;
      /* Получим состояние этапа */
      NSTAGE_CTRL := STAGES_GET_CTRL_CONTR(NRN => C.RN);
      /* Подсчитаем количество "безконтрольных" */
      if (NSTAGE_CTRL is null) then
        NCNT_NULL := NCNT_NULL + 1;
      end if;
      /* Если у этапа есть отклонение - оно есть и у проекта */
      if (NSTAGE_CTRL = 1) then
        return 1;
      end if;
    end loop;
    /* Если ни один этап не подлежит контролю - то и состояние проекта тоже */
    if (NCNT_NULL = NCNT_STAGES) then
      return null;
    end if;
    /* Если мы здесь - отклонений нет */
    if (NCNT_STAGES > 0) then
      return 0;
    else
      /* Нет этапов и нет контроля */
      return null;
    end if;
  end GET_CTRL_CONTR;

  /* Получение состояния соисполнения проекта */
  function GET_CTRL_COEXEC
  (
    NRN                     in number         -- Рег. номер проекта
  ) return                  number            -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  is
    BFOUND                  boolean := false; -- Флаг наличия этапов  
  begin
    /* Обходим этапы */
    for C in (select PS.RN from PROJECTSTAGE PS where PS.PRN = NRN)
    loop
      /* Выставим флаг наличия этапов */
      BFOUND := true;
      /* Если у этапа есть отклонение - оно есть и у проекта */
      if (STAGES_GET_CTRL_COEXEC(NRN => C.RN) = 1) then
        return 1;
      end if;
    end loop;
    /* Если мы здесь - отклонений нет */
    if (BFOUND) then
      return 0;
    else
      return null;
    end if;
  end GET_CTRL_COEXEC;

  /* Получение состояния сроков проекта */
  function GET_CTRL_PERIOD
  (
    NRN                     in number            -- Рег. номер проекта
  ) return                  number               -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  is
    NSTAGE_CTRL             PKG_STD.TNUMBER;     -- Состояние этапа
    NCNT_STAGES             PKG_STD.TNUMBER :=0; -- Количество этапов
    NCNT_NULL               PKG_STD.TNUMBER :=0; -- Количество "безконтрольных" этапов
  begin
    /* Обходим этапы */
    for C in (select PS.RN from PROJECTSTAGE PS where PS.PRN = NRN)
    loop
      /* Увеличим счётчик этапов */
      NCNT_STAGES := NCNT_STAGES + 1;
      /* Получим состояние этапа */
      NSTAGE_CTRL := STAGES_GET_CTRL_PERIOD(NRN => C.RN);
      /* Подсчитаем количество "безконтрольных" */
      if (NSTAGE_CTRL is null) then
        NCNT_NULL := NCNT_NULL + 1;
      end if;
      /* Если у этапа есть отклонение - оно есть и у проекта */
      if (NSTAGE_CTRL = 1) then
        return 1;
      end if;
    end loop;
    /* Если ни один этап не подлежит контролю - то и состояние проекта тоже */
    if (NCNT_NULL = NCNT_STAGES) then
      return null;
    end if;
    /* Если мы здесь - отклонений нет */
    if (NCNT_STAGES > 0) then
      return 0;
    else
      /* Нет этапов и нет контроля */
      return null;
    end if;
  end GET_CTRL_PERIOD;
  
  /* Получение состояния затрат проекта */
  function GET_CTRL_COST
  (
    NRN                     in number            -- Рег. номер проекта
  ) return                  number               -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  is
    NSTAGE_CTRL             PKG_STD.TNUMBER;     -- Состояние этапа
    NCNT_STAGES             PKG_STD.TNUMBER :=0; -- Количество этапов
    NCNT_NULL               PKG_STD.TNUMBER :=0; -- Количество "безконтрольных" этапов
  begin
    /* Обходим этапы */
    for C in (select PS.RN from PROJECTSTAGE PS where PS.PRN = NRN)
    loop
      /* Увеличим счётчик этапов */
      NCNT_STAGES := NCNT_STAGES + 1;
      /* Получим состояние этапа */
      NSTAGE_CTRL := STAGES_GET_CTRL_COST(NRN => C.RN);
      /* Подсчитаем количество "безконтрольных" */
      if (NSTAGE_CTRL is null) then
        NCNT_NULL := NCNT_NULL + 1;
      end if;
      /* Если у этапа есть отклонение - оно есть и у проекта */
      if (NSTAGE_CTRL = 1) then
        return 1;
      end if;
    end loop;
    /* Если ни один этап не подлежит контролю - то и состояние проекта тоже */
    if (NCNT_NULL = NCNT_STAGES) then
      return null;
    end if;
    /* Если мы здесь - отклонений нет */
    if (NCNT_STAGES > 0) then
      return 0;
    else
      /* Нет этапов и нет контроля */
      return null;
    end if;
  end GET_CTRL_COST;
  
  /* Получение состояния актирования проекта */
  function GET_CTRL_ACT
  (
    NRN                     in number         -- Рег. номер проекта
  ) return                  number            -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  is
    BFOUND                  boolean := false; -- Флаг наличия этапов  
  begin
    /* Обходим этапы */
    for C in (select PS.RN from PROJECTSTAGE PS where PS.PRN = NRN)
    loop
      /* Выставим флаг наличия этапов */
      BFOUND := true;
      /* Если у этапа есть отклонение - оно есть и у проекта */
      if (STAGES_GET_CTRL_ACT(NRN => C.RN) = 1) then
        return 1;
      end if;
    end loop;
    /* Если мы здесь - отклонений нет */
    if (BFOUND) then
      return 0;
    else
      return null;
    end if;
  end GET_CTRL_ACT;
  
  /* Список проектов */
  procedure LIST
  (
    NPAGE_NUMBER            in number,                             -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,                             -- Количество записей на странице (0 - все)
    CFILTERS                in clob,                               -- Фильтры
    CORDERS                 in clob,                               -- Сортировки
    NINCLUDE_DEF            in number,                             -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob                               -- Сериализованная таблица данных
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
    NIDENT                  PKG_STD.TREF := GEN_IDENT();           -- Идентификатор отбора
    RF                      PKG_P8PANELS_VISUAL.TFILTERS;          -- Фильтры
    RO                      PKG_P8PANELS_VISUAL.TORDERS;           -- Сортировки
    RDG                     PKG_P8PANELS_VISUAL.TDATA_GRID;        -- Описание таблицы
    RDG_ROW                 PKG_P8PANELS_VISUAL.TROW;              -- Строка таблицы
    RCOL_VALS               PKG_P8PANELS_VISUAL.TCOL_VALS;         -- Предопределённые значения столбцов
    NROW_FROM               PKG_STD.TREF;                          -- Номер строки с
    NROW_TO                 PKG_STD.TREF;                          -- Номер строки по
    CSQL                    clob;                                  -- Буфер для запроса
    ICURSOR                 integer;                               -- Курсор для исполнения запроса
    NECON_RESP_DP           PKG_STD.TREF;                          -- Рег. номер ДС "Ответственный экономист"
  begin
    /* Читаем фильтры */
    RF := PKG_P8PANELS_VISUAL.TFILTERS_FROM_XML(CFILTERS => CFILTERS);
    /* Читем сортировки */
    RO := PKG_P8PANELS_VISUAL.TORDERS_FROM_XML(CORDERS => CORDERS);
    /* Преобразуем номер и размер страницы в номер строк с и по */
    PKG_P8PANELS_VISUAL.UTL_ROWS_LIMITS_CALC(NPAGE_NUMBER => NPAGE_NUMBER,
                                             NPAGE_SIZE   => NPAGE_SIZE,
                                             NROW_FROM    => NROW_FROM,
                                             NROW_TO      => NROW_TO);
    /* Инициализируем таблицу данных */
    RDG := PKG_P8PANELS_VISUAL.TDATA_GRID_MAKE();
    /* Добавляем в таблицу описание колонок */
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NRN',
                                               SCAPTION   => 'Рег. номер',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SCODE',
                                               SCAPTION   => 'Код',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               SCOND_FROM => 'EDMNEMO',
                                               BORDER     => true,
                                               BFILTER    => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SNAME',
                                               SCAPTION   => 'Наименование',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               SCOND_FROM => 'EDNAME',
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SNAME_USL',
                                               SCAPTION   => 'Условное наименование',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               SCOND_FROM => 'EDNAME_USL',
                                               BORDER     => true,
                                               BFILTER    => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SEXPECTED_RES',
                                               SCAPTION   => 'Ожидаемые результаты',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SPRJTYPE',
                                               SCAPTION   => 'Тип',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               SCOND_FROM => 'EDPROJECTTYPE',
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SEXT_CUST',
                                               SCAPTION   => 'Заказчик',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               SCOND_FROM => 'EDEXT_CUST',
                                               BORDER     => true,
                                               BFILTER    => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SGOVCNTRID',
                                               SCAPTION   => 'ИГК',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SDOC_OSN',
                                               SCAPTION   => 'Документ-основание',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SLNK_UNIT_SDOC_OSN',
                                               SCAPTION   => 'Документ-основание (код раздела ссылки)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NLNK_DOCUMENT_SDOC_OSN',
                                               SCAPTION   => 'Документ-основание (документ ссылки)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SSUBDIV_RESP',
                                               SCAPTION   => 'Подразделение-исполнитель',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SRESPONSIBLE',
                                               SCAPTION   => 'Ответственный исполнитель',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SECON_RESP',
                                               SCAPTION   => 'Ответственный экономист',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 0, BCLEAR => true);
    PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 1);
    PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 2);
    PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 3);
    PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 4);
    PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 5);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NSTATE',
                                               SCAPTION   => 'Состояние',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'CGSTATE',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DBEGPLAN',
                                               SCAPTION   => 'Дата начала',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               SCOND_FROM => 'EDPLANBEGFrom',
                                               SCOND_TO   => 'EDPLANBEGTo',
                                               BORDER     => true,
                                               BFILTER    => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DENDPLAN',
                                               SCAPTION   => 'Дата окончания',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               SCOND_FROM => 'EDPLANENDFrom',
                                               SCOND_TO   => 'EDPLANENDTo',
                                               BORDER     => true,
                                               BFILTER    => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCOST_SUM',
                                               SCAPTION   => 'Стоимость',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SCURNAMES',
                                               SCAPTION   => 'Валюта',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NFIN_IN',
                                               SCAPTION   => 'Входящее финансирование',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SLNK_UNIT_NFIN_IN',
                                               SCAPTION   => 'Входящее финансирование (код раздела ссылки)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NLNK_DOCUMENT_NFIN_IN',
                                               SCAPTION   => 'Входящее финансирование (документ ссылки)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NFIN_OUT',
                                               SCAPTION   => 'Исходящее финансирование',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SLNK_UNIT_NFIN_OUT',
                                               SCAPTION   => 'Исходящее финансирование (код раздела ссылки)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NLNK_DOCUMENT_NFIN_OUT',
                                               SCAPTION   => 'Исходящее финансирование (документ ссылки)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 0, BCLEAR => true);
    PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 1);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_FIN',
                                               SCAPTION   => 'Финансирование',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_FIN',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_CONTR',
                                               SCAPTION   => 'Контрактация',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_CONTR',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_COEXEC',
                                               SCAPTION   => 'Соисполнители',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_COEXEC',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_PERIOD',
                                               SCAPTION   => 'Сроки',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_PERIOD',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_COST',
                                               SCAPTION   => 'Затраты',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_COST',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_ACT',
                                               SCAPTION   => 'Актирование',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_ACT',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS);
    /* Определим дополнительные свойства - ответственный экономист */
    FIND_DOCS_PROPS_CODE(NFLAG_SMART => 1, NCOMPANY => NCOMPANY, SCODE => 'ПУП.SECON_RESP', NRN => NECON_RESP_DP);
    /* Обходим данные */
    begin
      /* Собираем запрос */
      CSQL := 'select *
            from (select D.*,
                         ROWNUM NROW
                    from (select P.RN NRN,
                                 P.CODE SCODE,
                                 P.NAME SNAME,
                                 P.NAME_USL SNAME_USL,
                                 P.EXPECTED_RES SEXPECTED_RES,
                                 PT.CODE SPRJTYPE,
                                 EC.AGNABBR SEXT_CUST,
                                 ''"'' || GC.CODE || ''"'' SGOVCNTRID,
                                 P.DOC_OSN SDOC_OSN,
                                 ''Contracts'' SLNK_UNIT_SDOC_OSN,
                                 PKG_P8PANELS_PROJECTS.GET_DOC_OSN_LNK_DOCUMENT(P.RN) NLNK_DOCUMENT_SDOC_OSN,
                                 SR.CODE SSUBDIV_RESP,
                                 R.AGNABBR SRESPONSIBLE,
                                 F_DOCS_PROPS_GET_STR_VALUE(:NECON_RESP_DP, ''Projects'', P.RN) SECON_RESP,
                                 P.STATE NSTATE,
                                 P.BEGPLAN DBEGPLAN,
                                 P.ENDPLAN DENDPLAN,
                                 P.COST_SUM_BASECURR NCOST_SUM,
                                 CN.INTCODE SCURNAMES,
                                 PKG_P8PANELS_PROJECTS.GET_FIN_IN(P.RN) NFIN_IN,
                                 ''Paynotes'' SLNK_UNIT_NFIN_IN,
                                 0 NLNK_DOCUMENT_NFIN_IN,                                 
                                 PKG_P8PANELS_PROJECTS.GET_FIN_OUT(P.RN) NFIN_OUT,
                                 ''Paynotes'' SLNK_UNIT_NFIN_OUT,
                                 1 NLNK_DOCUMENT_NFIN_OUT,                                 
                                 PKG_P8PANELS_PROJECTS.GET_CTRL_FIN(P.RN) NCTRL_FIN,
                                 PKG_P8PANELS_PROJECTS.GET_CTRL_CONTR(P.RN) NCTRL_CONTR,
                                 PKG_P8PANELS_PROJECTS.GET_CTRL_COEXEC(P.RN) NCTRL_COEXEC,
                                 PKG_P8PANELS_PROJECTS.GET_CTRL_PERIOD(P.RN) NCTRL_PERIOD,
                                 PKG_P8PANELS_PROJECTS.GET_CTRL_COST(P.RN) NCTRL_COST,
                                 PKG_P8PANELS_PROJECTS.GET_CTRL_ACT(P.RN) NCTRL_ACT
                            from PROJECT        P,
                                 PRJTYPE        PT,
                                 AGNLIST        EC,
                                 GOVCNTRID      GC,
                                 INS_DEPARTMENT SR,
                                 AGNLIST        R,
                                 CURNAMES       CN
                           where P.PRJTYPE = PT.RN
                             and P.EXT_CUST = EC.RN(+)
                             and P.GOVCNTRID = GC.RN(+)
                             and P.SUBDIV_RESP = SR.RN(+)
                             and P.RESPONSIBLE = R.RN(+)
                             and P.CURNAMES = CN.RN 
                             and P.RN in (select ID from COND_BROKER_IDSMART where IDENT = :NIDENT) %ORDER_BY%) D) F
           where F.NROW between :NROW_FROM and :NROW_TO';
      /* Учтём сортировки */
      PKG_P8PANELS_VISUAL.TORDERS_SET_QUERY(RDATA_GRID => RDG, RORDERS => RO, SPATTERN => '%ORDER_BY%', CSQL => CSQL);
      /* Учтём фильтры */
      PKG_P8PANELS_VISUAL.TFILTERS_SET_QUERY(NIDENT     => NIDENT,
                                             NCOMPANY   => NCOMPANY,
                                             SUNIT      => 'Projects',
                                             SPROCEDURE => 'PKG_P8PANELS_PROJECTS.COND',
                                             RDATA_GRID => RDG,
                                             RFILTERS   => RF);
      /* Разбираем его */
      ICURSOR := PKG_SQL_DML.OPEN_CURSOR(SWHAT => 'SELECT');
      PKG_SQL_DML.PARSE(ICURSOR => ICURSOR, SQUERY => CSQL);
      /* Делаем подстановку параметров */
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NECON_RESP_DP', NVALUE => NECON_RESP_DP);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NIDENT', NVALUE => NIDENT);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_FROM', NVALUE => NROW_FROM);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_TO', NVALUE => NROW_TO);
      /* Описываем структуру записи курсора */
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 1);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 2);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 3);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 4);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 5);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 6);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 7);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 8);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 9);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 10);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 11);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 12);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 13);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 14);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 15);
      PKG_SQL_DML.DEFINE_COLUMN_DATE(ICURSOR => ICURSOR, IPOSITION => 16);
      PKG_SQL_DML.DEFINE_COLUMN_DATE(ICURSOR => ICURSOR, IPOSITION => 17);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 18);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 19);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 20);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 21);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 22);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 23);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 24);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 25);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 26);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 27);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 28);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 29);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 30);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 31);
      /* Делаем выборку */
      if (PKG_SQL_DML.EXECUTE(ICURSOR => ICURSOR) = 0) then
        null;
      end if;
      /* Обходим выбранные записи */
      while (PKG_SQL_DML.FETCH_ROWS(ICURSOR => ICURSOR) > 0)
      loop
        /* Добавляем колонки с данными */
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW => RDG_ROW, SNAME => 'NRN', ICURSOR => ICURSOR, NPOSITION => 1, BCLEAR => true);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SCODE', ICURSOR => ICURSOR, NPOSITION => 2);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SNAME', ICURSOR => ICURSOR, NPOSITION => 3);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SNAME_USL',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 4);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SEXPECTED_RES',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 5);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SPRJTYPE', ICURSOR => ICURSOR, NPOSITION => 6);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SEXT_CUST',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 7);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SGOVCNTRID',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 8);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SDOC_OSN', ICURSOR => ICURSOR, NPOSITION => 9);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SLNK_UNIT_SDOC_OSN',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 10);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NLNK_DOCUMENT_SDOC_OSN',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 11);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SSUBDIV_RESP',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 12);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SRESPONSIBLE',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 13);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SECON_RESP',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 14);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW => RDG_ROW, SNAME => 'NSTATE', ICURSOR => ICURSOR, NPOSITION => 15);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLD(RROW      => RDG_ROW,
                                              SNAME     => 'DBEGPLAN',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 16);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLD(RROW      => RDG_ROW,
                                              SNAME     => 'DENDPLAN',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 17);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NCOST_SUM',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 18);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SCURNAMES',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 19);      
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW => RDG_ROW, SNAME => 'NFIN_IN', ICURSOR => ICURSOR, NPOSITION => 20);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SLNK_UNIT_NFIN_IN',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 21);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NLNK_DOCUMENT_NFIN_IN',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 22);      
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NFIN_OUT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 23);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SLNK_UNIT_NFIN_OUT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 24);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NLNK_DOCUMENT_NFIN_OUT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 25);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NCTRL_FIN',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 26);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NCTRL_CONTR',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 27);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NCTRL_COEXEC',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 28);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NCTRL_PERIOD',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 29);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NCTRL_COST',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 30);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NCTRL_ACT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 31);
        /* Добавляем строку в таблицу */
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW);
      end loop;
      /* Освобождаем курсор */
      PKG_SQL_DML.CLOSE_CURSOR(ICURSOR => ICURSOR);
    exception
      when others then
        PKG_SQL_DML.CLOSE_CURSOR(ICURSOR => ICURSOR);
        raise;
    end;
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TDATA_GRID_TO_XML(RDATA_GRID => RDG, NINCLUDE_DEF => NINCLUDE_DEF);
  end LIST;
  
  /* Считывание записи этапа проекта */
  function STAGES_GET
  (
    NRN                     in number             -- Рег. номер этапа проекта
  ) return                  PROJECTSTAGE%rowtype  -- Запись этапа проекта
  is
    RRES                    PROJECTSTAGE%rowtype; -- Буфер для результата
  begin
    select PS.* into RRES from PROJECTSTAGE PS where PS.RN = NRN;
    return RRES;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0, NDOCUMENT => NRN, SUNIT_TABLE => 'PROJECTSTAGE');
  end STAGES_GET;
  
  /* Отбор этапов проектов */
  procedure STAGES_COND
  as
  begin
    /* Установка главной таблицы */
    PKG_COND_BROKER.SET_TABLE(STABLE_NAME => 'PROJECTSTAGE');
    /* Проект */
    PKG_COND_BROKER.SET_COLUMN_PRN(SCOLUMN_NAME => 'PRN');
    /* Номер */
    PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME => 'NUMB', SCONDITION_NAME => 'EDNUMB');
    /* Наименование */
    PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME => 'NAME', SCONDITION_NAME => 'EDNAME');
    /* Дата начала план */
    PKG_COND_BROKER.ADD_CONDITION_BETWEEN(SCOLUMN_NAME         => 'BEGPLAN',
                                          SCONDITION_NAME_FROM => 'EDPLANBEGFrom',
                                          SCONDITION_NAME_TO   => 'EDPLANBEGTo');
    /* Дата окончания план */
    PKG_COND_BROKER.ADD_CONDITION_BETWEEN(SCOLUMN_NAME         => 'ENDPLAN',
                                          SCONDITION_NAME_FROM => 'EDPLANENDFrom',
                                          SCONDITION_NAME_TO   => 'EDPLANENDTo');
    /* Состояние */
    PKG_COND_BROKER.ADD_CONDITION_ENUM(SCOLUMN_NAME => 'STATE', SCONDITION_NAME => 'CGSTATE');
    /* Контроль финансирования */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_FIN') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => 'PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_FIN(RN) = :EDCTRL_FIN');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_FIN',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_FIN'));
    end if;  
    /* Контроль контрактации */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_CONTR') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => 'PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_CONTR(RN) = :EDCTRL_CONTR');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_CONTR',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_CONTR'));
    end if;
    /* Контроль соисполнения */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_COEXEC') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => 'PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_COEXEC(RN) = :EDCTRL_COEXEC');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_COEXEC',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_COEXEC'));
    end if;
    /* Контроль сроков */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_PERIOD') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => 'PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_PERIOD(RN) = :EDCTRL_PERIOD');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_PERIOD',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_PERIOD'));
    end if;
    /* Контроль затрат */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_COST') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => 'PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_COST(RN) = :EDCTRL_COST');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_COST',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_COST'));
    end if;
  end STAGES_COND;
  
  /* Подбор платежей финансирования этапа проекта */
  procedure STAGES_SELECT_FIN
  (
    NPRN                    in number := null, -- Рег. номер проекта (null - не отбирать по проекту)
    NRN                     in number := null, -- Рег. номер этапа проекта (null - не отбирать по этапу)
    NDIRECTION              in number,         -- Направление (0 - приход, 1 - расход)
    NIDENT                  out number         -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  )
  is
    NSELECTLIST             PKG_STD.TREF;      -- Рег. номер добавленной записи буфера подобранных
  begin
    /* Подберём платежи */
    for C in (select PN.COMPANY,
                     PN.RN
                from PAYNOTES PN,
                     DICTOPER O
               where PN.COMPANY in (select PS.COMPANY
                                      from PROJECTSTAGE PS
                                     where ((NRN is null) or ((NRN is not null) and (PS.RN = NRN)))
                                       and ((NPRN is null) or ((NPRN is not null) and (PS.PRN = NPRN))))
                 and PN.SIGNPLAN = 0
                 and PN.FINOPER = O.RN
                 and O.TYPOPER_DIRECT = NDIRECTION
                 and exists (select PNC.RN
                        from PAYNOTESCLC  PNC,
                             PROJECTSTAGE PS
                       where PNC.PRN = PN.RN
                         and PNC.FACEACCOUNT = PS.FACEACC
                         and ((NRN is null) or ((NRN is not null) and (PS.RN = NRN)))
                         and ((NPRN is null) or ((NPRN is not null) and (PS.PRN = NPRN)))))
    loop
      /* Сформируем идентификатор буфера */
      if (NIDENT is null) then
        NIDENT := GEN_IDENT();
      end if;
      /* Добавим подобранное в список отмеченных записей */
      P_SELECTLIST_BASE_INSERT(NIDENT       => NIDENT,
                               NCOMPANY     => C.COMPANY,
                               NDOCUMENT    => C.RN,
                               SUNITCODE    => 'PayNotes',
                               SACTIONCODE  => null,
                               NCRN         => null,
                               NDOCUMENT1   => null,
                               SUNITCODE1   => null,
                               SACTIONCODE1 => null,
                               NRN          => NSELECTLIST);
    end loop;
  end STAGES_SELECT_FIN;
  
  /* Получение суммы финансирования этапа проекта */
  function STAGES_GET_FIN
  (
    NRN                     in number,       -- Рег. номер этапа проекта
    NDIRECTION              in number        -- Направление (0 - приход, 1 - расход)
  ) return                  number           -- Сумма финансирования проекта
  is
    NRES                    PKG_STD.TNUMBER; -- Буфер для рузультата
  begin
    /* Суммируем фактические платежи нужного направления по лицевому счёту затрат этапа */
    select COALESCE(sum(PN.PAY_SUM * (PN.CURR_RATE_BASE/PN.CURR_RATE)), 0)
      into NRES
      from PAYNOTES PN,
           DICTOPER O
     where PN.COMPANY in (select PS.COMPANY from PROJECTSTAGE PS where PS.RN = NRN)
       and PN.SIGNPLAN = 0
       and PN.FINOPER = O.RN
       and O.TYPOPER_DIRECT = NDIRECTION
       and exists (select PNC.RN
              from PAYNOTESCLC  PNC,
                   PROJECTSTAGE PS
             where PNC.PRN = PN.RN
               and PNC.FACEACCOUNT = PS.FACEACC
               and PS.RN = NRN);
    /* Возвращаем результат */
    return NRES;
  end STAGES_GET_FIN;
  
  /* Получение суммы входящего финансирования этапа проекта */
  function STAGES_GET_FIN_IN
  (
    NRN                     in number   -- Рег. номер этапа проекта
  ) return                  number      -- Сумма входящего финансирования проекта
  is
  begin
    return STAGES_GET_FIN(NRN => NRN, NDIRECTION => 0);
  end STAGES_GET_FIN_IN;

  /* Получение суммы исходящего финансирования этапа проекта */
  function STAGES_GET_FIN_OUT
  (
    NRN                     in number   -- Рег. номер этапа проекта
  ) return                  number      -- Сумма исходяшего финансирования проекта
  is
  begin
    return STAGES_GET_FIN(NRN => NRN, NDIRECTION => 1);
  end STAGES_GET_FIN_OUT;

  /* Получение состояния финансирования этапа проекта */
  function STAGES_GET_CTRL_FIN
  (
    NRN                     in number   -- Рег. номер этапа проекта
  ) return                  number      -- Состояние (0 - без отклонений, 1 - есть отклонения)
  is
  begin
    return 0;
  end STAGES_GET_CTRL_FIN;

  /* Получение состояния контрактации этапа проекта */
  function STAGES_GET_CTRL_CONTR
  (
    NRN                     in number             -- Рег. номер этапа проекта
  ) return                  number                -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  is
    RSTAGE_ARTS             TSTAGE_ARTS;          -- Сведения о контрактации по статьям этапа
    NCNT_NULL               PKG_STD.TNUMBER := 0; -- Количество статей с неопределённым состоянием
  begin
    /* Получим сведения о контрактации по статьям */
    STAGE_ARTS_GET(NSTAGE => NRN, NINC_CONTR => 1, RSTAGE_ARTS => RSTAGE_ARTS);
    /* Если сведения есть - будем разбираться */
    if ((RSTAGE_ARTS is not null) and (RSTAGE_ARTS.COUNT > 0)) then
      for I in RSTAGE_ARTS.FIRST .. RSTAGE_ARTS.LAST
      loop
        if (RSTAGE_ARTS(I).NCTRL_CONTR is null) then
          NCNT_NULL := NCNT_NULL + 1;
        end if;
        /* Если хоть одна статья имеет отклонения */
        if (RSTAGE_ARTS(I).NCTRL_CONTR = 1) then
          /* То и этап имеет отклонение */
          return 1;
        end if;
      end loop;
      /* Если ни одна статья не подлежит контролю - то и состояние этапа тоже */
      if (NCNT_NULL = RSTAGE_ARTS.COUNT) then
        return null;
      end if;
      /* Если мы здесь - отклонений нет */
      return 0;
    else
      /* Нет данных по статьям */
      return null;
    end if;
  end STAGES_GET_CTRL_CONTR;

  /* Получение состояния соисполнения этапа проекта */
  function STAGES_GET_CTRL_COEXEC
  (
    NRN                     in number   -- Рег. номер этапа проекта
  ) return                  number      -- Состояние (0 - без отклонений, 1 - есть отклонения)
  is
  begin
    return 0;
  end STAGES_GET_CTRL_COEXEC;
  
  /* Получение состояния сроков этапа проекта */
  function STAGES_GET_CTRL_PERIOD
  (
    NRN                     in number        -- Рег. номер этапа проекта
  ) return                  number           -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  is
    NDAYS_LEFT              PKG_STD.TNUMBER; -- Остаток дней до завершения этапа
  begin
    /* Получим количество дней до завершения */
    NDAYS_LEFT := STAGES_GET_DAYS_LEFT(NRN => NRN);
    /* Если мы не знаем количества дней - то не можем и контролировать */
    if (NDAYS_LEFT is null) then
      return null;
    end if;
    /* Если осталось меньше определённого лимита */
    if (NDAYS_LEFT < NDAYS_LEFT_LIMIT) then
      /* На это необходимо обратить внимание */
      return 1;
    else
      /* Отклонений нет */
      return 0;
    end if;
  end STAGES_GET_CTRL_PERIOD;
  
  /* Получение состояния затрат этапа проекта */
  function STAGES_GET_CTRL_COST
  (
    NRN                     in number             -- Рег. номер этапа проекта
  ) return                  number                -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  is
    RSTAGE_ARTS             TSTAGE_ARTS;          -- Сведения о затратах по статьям этапа
    NCNT_NULL               PKG_STD.TNUMBER := 0; -- Количество статей с неопределённым состоянием
  begin
    /* Получим сведения о затратах по статьям */
    STAGE_ARTS_GET(NSTAGE => NRN, NINC_COST => 1, RSTAGE_ARTS => RSTAGE_ARTS);
    /* Если сведения есть - будем разбираться */
    if ((RSTAGE_ARTS is not null) and (RSTAGE_ARTS.COUNT > 0)) then
      for I in RSTAGE_ARTS.FIRST .. RSTAGE_ARTS.LAST
      loop
        if (RSTAGE_ARTS(I).NCTRL_COST is null) then
          NCNT_NULL := NCNT_NULL + 1;
        end if;
        /* Если хоть одна статья имеет отклонения */
        if (RSTAGE_ARTS(I).NCTRL_COST = 1) then
          /* То и этап имеет отклонение */
          return 1;
        end if;
      end loop;
      /* Если ни одна статья не подлежит контролю - то и состояние этапа тоже */
      if (NCNT_NULL = RSTAGE_ARTS.COUNT) then
        return null;
      end if;
      /* Если мы здесь - отклонений нет */
      return 0;
    else
      /* Нет данных по статьям */
      return null;
    end if;
  end STAGES_GET_CTRL_COST;
  
  /* Получение состояния актирования этапа проекта */
  function STAGES_GET_CTRL_ACT
  (
    NRN                     in number   -- Рег. номер этапа проекта
  ) return                  number      -- Состояние (0 - без отклонений, 1 - есть отклонения)
  is
  begin
    return 1;
  end STAGES_GET_CTRL_ACT;  
  
  /* Получение остатка срока исполнения этапа проекта */
  function STAGES_GET_DAYS_LEFT
  (
    NRN                     in number             -- Рег. номер этапа проекта
  ) return                  number                -- Количество дней (null - не определено)
  is
    RSTG                    PROJECTSTAGE%rowtype; -- Запись этапа
  begin
    /* Считаем этап */
    RSTG := STAGES_GET(NRN => NRN);
    /* Вернём остаток дней */
    if (RSTG.ENDPLAN is not null) then
      return RSTG.ENDPLAN - sysdate;
    else
      return null;
    end if;
  end STAGES_GET_DAYS_LEFT;
  
  /* Подбор записей журнала затрат этапа проекта */
  procedure STAGES_SELECT_COST_FACT
  (
    NRN                     in number,  -- Рег. номер этапа проекта (null - не отбирать по этапу)
    NIDENT                  out number  -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  )
  is
  begin
    STAGE_ARTS_SELECT_COST_FACT(NSTAGE => NRN, NFINFLOW_TYPE => 2, NIDENT => NIDENT);
  end STAGES_SELECT_COST_FACT;
  
  /* Получение суммы фактических затрат этапа проекта */
  function STAGES_GET_COST_FACT
  (
    NRN                     in number   -- Рег. номер этапа проекта
  ) return                  number      -- Сумма фактических затрат
  is
  begin
    return STAGE_ARTS_GET_COST_FACT(NSTAGE => NRN, NFINFLOW_TYPE => 2);
  end STAGES_GET_COST_FACT;
    
  /* Получение суммы реализации этапа проекта */
  function STAGES_GET_SUMM_REALIZ
  (
    NRN                     in number,  -- Рег. номер этапа проекта
    NFPDARTCL_REALIZ        in number   -- Рег. номер статьи калькуляции для реализации
  ) return                  number      -- Сумма реализации
  is
  begin
    if (NFPDARTCL_REALIZ is not null) then
      return STAGE_ARTS_GET_COST_FACT(NSTAGE => NRN, NFPDARTCL => NFPDARTCL_REALIZ);
    else
      return 0;
    end if;
  end STAGES_GET_SUMM_REALIZ;
    
  /* Список этапов */
  procedure STAGES_LIST
  (
    NPRN                    in number,                             -- Рег. номер проекта
    NPAGE_NUMBER            in number,                             -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,                             -- Количество записей на странице (0 - все)
    CFILTERS                in clob,                               -- Фильтры
    CORDERS                 in clob,                               -- Сортировки
    NINCLUDE_DEF            in number,                             -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob                               -- Сериализованная таблица данных
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
    NIDENT                  PKG_STD.TREF := GEN_IDENT();           -- Идентификатор отбора
    RF                      PKG_P8PANELS_VISUAL.TFILTERS;          -- Фильтры
    RO                      PKG_P8PANELS_VISUAL.TORDERS;           -- Сортировки
    RDG                     PKG_P8PANELS_VISUAL.TDATA_GRID;        -- Описание таблицы
    RDG_ROW                 PKG_P8PANELS_VISUAL.TROW;              -- Строка таблицы
    RCOL_VALS               PKG_P8PANELS_VISUAL.TCOL_VALS;         -- Предопределённые значения столбцов
    NROW_FROM               PKG_STD.TREF;                          -- Номер строки с
    NROW_TO                 PKG_STD.TREF;                          -- Номер строки по
    NFPDARTCL_REALIZ        PKG_STD.TREF;                          -- Рег. номер статьи калькуляции для реализации
    CSQL                    clob;                                  -- Буфер для запроса
    ICURSOR                 integer;                               -- Курсор для исполнения запроса
    NCOST_FACT              PKG_STD.TNUMBER;                       -- Сумма фактических затрат по этапу проекта
    NSUMM_REALIZ            PKG_STD.TNUMBER;                       -- Сумма реализации по этапу проекта
    NSUMM_INCOME            PKG_STD.TNUMBER;                       -- Сумма прибыли по этапу проекта
    NINCOME_PRC             PKG_STD.TNUMBER;                       -- Процент прибыли по этапу проекта
  begin
    /* Определим рег. номер статьи калькуляции для учёта реализации */    
    FIND_FPDARTCL_CODE(NFLAG_SMART => 1, NCOMPANY => NCOMPANY, SCODE => SFPDARTCL_REALIZ, NRN => NFPDARTCL_REALIZ);
    /* Читаем фильтры */
    RF := PKG_P8PANELS_VISUAL.TFILTERS_FROM_XML(CFILTERS => CFILTERS);
    /* Читем сортировки */
    RO := PKG_P8PANELS_VISUAL.TORDERS_FROM_XML(CORDERS => CORDERS);
    /* Преобразуем номер и размер страницы в номер строк с и по */
    PKG_P8PANELS_VISUAL.UTL_ROWS_LIMITS_CALC(NPAGE_NUMBER => NPAGE_NUMBER,
                                             NPAGE_SIZE   => NPAGE_SIZE,
                                             NROW_FROM    => NROW_FROM,
                                             NROW_TO      => NROW_TO);
    /* Инициализируем таблицу данных */
    RDG := PKG_P8PANELS_VISUAL.TDATA_GRID_MAKE();
    /* Добавляем в таблицу описание колонок */
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NRN',
                                               SCAPTION   => 'Рег. номер',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SNUMB',
                                               SCAPTION   => 'Номер',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               SCOND_FROM => 'EDNUMB',
                                               BORDER     => true,
                                               BFILTER    => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SNAME',
                                               SCAPTION   => 'Наименование',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               SCOND_FROM => 'EDNAME',
                                               BORDER     => true,
                                               BFILTER    => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SEXPECTED_RES',
                                               SCAPTION   => 'Ожидаемые результаты',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SFACEACC',
                                               SCAPTION   => 'Шифр затрат',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 0, BCLEAR => true);
    PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 1);
    PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 2);
    PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 3);
    PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 4);
    PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 5);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NSTATE',
                                               SCAPTION   => 'Состояние',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'CGSTATE',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DBEGPLAN',
                                               SCAPTION   => 'Дата начала',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               SCOND_FROM => 'EDPLANBEGFrom',
                                               SCOND_TO   => 'EDPLANBEGTo',
                                               BORDER     => true,
                                               BFILTER    => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DENDPLAN',
                                               SCAPTION   => 'Дата окончания',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               SCOND_FROM => 'EDPLANENDFrom',
                                               SCOND_TO   => 'EDPLANENDTo',
                                               BORDER     => true,
                                               BFILTER    => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCOST_SUM',
                                               SCAPTION   => 'Стоимость',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SCURNAMES',
                                               SCAPTION   => 'Валюта',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NFIN_IN',
                                               SCAPTION   => 'Входящее финансирование',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SLNK_UNIT_NFIN_IN',
                                               SCAPTION   => 'Входящее финансирование (код раздела ссылки)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NLNK_DOCUMENT_NFIN_IN',
                                               SCAPTION   => 'Входящее финансирование (документ ссылки)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NFIN_OUT',
                                               SCAPTION   => 'Исходящее финансирование',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SLNK_UNIT_NFIN_OUT',
                                               SCAPTION   => 'Исходящее финансирование (код раздела ссылки)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NLNK_DOCUMENT_NFIN_OUT',
                                               SCAPTION   => 'Исходящее финансирование (документ ссылки)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 0, BCLEAR => true);
    PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 1);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_FIN',
                                               SCAPTION   => 'Финансирование',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_FIN',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_CONTR',
                                               SCAPTION   => 'Контрактация',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_CONTR',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_COEXEC',
                                               SCAPTION   => 'Соисполнители',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_COEXEC',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NDAYS_LEFT',
                                               SCAPTION   => 'Дней до окончания',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_PERIOD',
                                               SCAPTION   => 'Сроки',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_PERIOD',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCOST_FACT',
                                               SCAPTION   => 'Сумма фактических затрат',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SLNK_UNIT_NCOST_FACT',
                                               SCAPTION   => 'Сумма фактических затрат (код раздела ссылки)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NLNK_DOCUMENT_NCOST_FACT',
                                               SCAPTION   => 'Сумма фактических затрат (документ ссылки)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NSUMM_REALIZ',
                                               SCAPTION   => 'Сумма реализации',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NSUMM_INCOME',
                                               SCAPTION   => 'Сумма прибыли',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NINCOME_PRC',
                                               SCAPTION   => 'Процент прибыли',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_COST',
                                               SCAPTION   => 'Затраты',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_COST',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS);                                               
    /* Обходим данные */
    begin
      /* Собираем запрос */
      CSQL := 'select *
            from (select D.*,
                         ROWNUM NROW
                    from (select PS.RN NRN,
                                 PS.NUMB SNUMB,
                                 PS.NAME SNAME,                                 
                                 PS.EXPECTED_RES SEXPECTED_RES,
                                 FAC.NUMB SFACEACC,
                                 PS.STATE NSTATE,
                                 PS.BEGPLAN DBEGPLAN,
                                 PS.ENDPLAN DENDPLAN,
                                 PS.COST_SUM_BASECURR NCOST_SUM,
                                 CN.INTCODE SCURNAMES,
                                 PKG_P8PANELS_PROJECTS.STAGES_GET_FIN_IN(PS.RN) NFIN_IN,
                                 ''Paynotes'' SLNK_UNIT_NFIN_IN,
                                 0 NLNK_DOCUMENT_NFIN_IN,
                                 PKG_P8PANELS_PROJECTS.STAGES_GET_FIN_OUT(PS.RN) NFIN_OUT,
                                 ''Paynotes'' SLNK_UNIT_NFIN_OUT,
                                 1 NLNK_DOCUMENT_NFIN_OUT,
                                 PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_FIN(PS.RN) NCTRL_FIN,
                                 PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_CONTR(PS.RN) NCTRL_CONTR,
                                 PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_COEXEC(PS.RN) NCTRL_COEXEC,
                                 PKG_P8PANELS_PROJECTS.STAGES_GET_DAYS_LEFT(PS.RN) NDAYS_LEFT,
                                 PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_PERIOD(PS.RN) NCTRL_PERIOD,
                                 PKG_P8PANELS_PROJECTS.STAGES_GET_COST_FACT(PS.RN) NCOST_FACT,
                                 ''CostNotes'' SLNK_UNIT_NCOST_FACT,
                                 1 NLNK_DOCUMENT_NCOST_FACT,
                                 PKG_P8PANELS_PROJECTS.STAGES_GET_SUMM_REALIZ(PS.RN, :NFPDARTCL_REALIZ) NSUMM_REALIZ,
                                 PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_COST(PS.RN) NCTRL_COST
                            from PROJECTSTAGE   PS,
                                 PROJECT        P,
                                 FACEACC        FAC,
                                 CURNAMES       CN
                           where PS.PRN = P.RN
                             and PS.FACEACC = FAC.RN(+)
                             and P.CURNAMES = CN.RN                             
                             and PS.RN in (select ID from COND_BROKER_IDSMART where IDENT = :NIDENT) %ORDER_BY%) D) F
           where F.NROW between :NROW_FROM and :NROW_TO';
      /* Учтём сортировки */
      PKG_P8PANELS_VISUAL.TORDERS_SET_QUERY(RDATA_GRID => RDG, RORDERS => RO, SPATTERN => '%ORDER_BY%', CSQL => CSQL);
      /* Учтём фильтры */
      PKG_P8PANELS_VISUAL.TFILTERS_SET_QUERY(NIDENT     => NIDENT,
                                             NCOMPANY   => NCOMPANY,
                                             NPARENT    => NPRN,
                                             SUNIT      => 'ProjectsStages',
                                             SPROCEDURE => 'PKG_P8PANELS_PROJECTS.STAGES_COND',
                                             RDATA_GRID => RDG,
                                             RFILTERS   => RF);
      /* Разбираем его */
      ICURSOR := PKG_SQL_DML.OPEN_CURSOR(SWHAT => 'SELECT');
      PKG_SQL_DML.PARSE(ICURSOR => ICURSOR, SQUERY => CSQL);
      /* Делаем подстановку параметров */
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NIDENT', NVALUE => NIDENT);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_FROM', NVALUE => NROW_FROM);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_TO', NVALUE => NROW_TO);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NFPDARTCL_REALIZ', NVALUE => NFPDARTCL_REALIZ);
      /* Описываем структуру записи курсора */
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 1);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 2);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 3);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 4);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 5);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 6);
      PKG_SQL_DML.DEFINE_COLUMN_DATE(ICURSOR => ICURSOR, IPOSITION => 7);
      PKG_SQL_DML.DEFINE_COLUMN_DATE(ICURSOR => ICURSOR, IPOSITION => 8);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 9);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 10);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 11);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 12);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 13);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 14);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 15);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 16);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 17);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 18);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 19);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 20);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 21);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 22);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 23);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 24);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 25);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 26);      
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
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SNUMB', ICURSOR => ICURSOR, NPOSITION => 2);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SNAME', ICURSOR => ICURSOR, NPOSITION => 3);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SEXPECTED_RES',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 4);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SFACEACC', ICURSOR => ICURSOR, NPOSITION => 5);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW => RDG_ROW, SNAME => 'NSTATE', ICURSOR => ICURSOR, NPOSITION => 6);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLD(RROW => RDG_ROW, SNAME => 'DBEGPLAN', ICURSOR => ICURSOR, NPOSITION => 7);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLD(RROW => RDG_ROW, SNAME => 'DENDPLAN', ICURSOR => ICURSOR, NPOSITION => 8);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NCOST_SUM',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 9);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SCURNAMES',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 10);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW => RDG_ROW, SNAME => 'NFIN_IN', ICURSOR => ICURSOR, NPOSITION => 11);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SLNK_UNIT_NFIN_IN',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 12);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NLNK_DOCUMENT_NFIN_IN',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 13);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NFIN_OUT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 14);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SLNK_UNIT_NFIN_OUT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 15);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NLNK_DOCUMENT_NFIN_OUT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 16);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NCTRL_FIN',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 17);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NCTRL_CONTR',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 18);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NCTRL_COEXEC',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 19);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NDAYS_LEFT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 20);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NCTRL_PERIOD',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 21);
        PKG_SQL_DML.COLUMN_VALUE_NUM(ICURSOR => ICURSOR, IPOSITION => 22, NVALUE => NCOST_FACT);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NCOST_FACT', NVALUE => NCOST_FACT);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SLNK_UNIT_NCOST_FACT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 23);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NLNK_DOCUMENT_NCOST_FACT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 24);
        PKG_SQL_DML.COLUMN_VALUE_NUM(ICURSOR => ICURSOR, IPOSITION => 25, NVALUE => NSUMM_REALIZ);
        if (NSUMM_REALIZ = 0) then
          NSUMM_INCOME := 0;
          NINCOME_PRC  := 0;
        else
          NSUMM_INCOME := NSUMM_REALIZ - NCOST_FACT;
          NINCOME_PRC  := NSUMM_INCOME / NCOST_FACT * 100;
        end if;
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NSUMM_REALIZ', NVALUE => NSUMM_REALIZ);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NSUMM_INCOME', NVALUE => NSUMM_INCOME);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NINCOME_PRC', NVALUE => NINCOME_PRC);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NCTRL_COST',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 26);
        /* Добавляем строку в таблицу */
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW);
      end loop;
      /* Освобождаем курсор */
      PKG_SQL_DML.CLOSE_CURSOR(ICURSOR => ICURSOR);
    exception
      when others then
        PKG_SQL_DML.CLOSE_CURSOR(ICURSOR => ICURSOR);
        raise;
    end;
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TDATA_GRID_TO_XML(RDATA_GRID => RDG, NINCLUDE_DEF => NINCLUDE_DEF);
  end STAGES_LIST;
  
  /* Подбор записей журнала затрат по статье калькуляции этапа проекта */
  procedure STAGE_ARTS_SELECT_COST_FACT
  (
    NSTAGE                  in number,         -- Рег. номер этапа проекта
    NFPDARTCL               in number := null, -- Рег. номер статьи калькуляции (null - по всем)
    NFINFLOW_TYPE           in number := null, -- Вид движения по статье (null - по всем, 0 - остаток, 1 - приход, 2 - расход)
    NIDENT                  out number         -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  )
  is
    NSELECTLIST             PKG_STD.TREF;      -- Рег. номер добавленной записи буфера подобранных
  begin
    /* Подберём записи журнала затрат */
    for C in (select CN.COMPANY,
                     CN.RN
                from PROJECTSTAGE PS,
                     FCCOSTNOTES  CN,
                     FINSTATE     FS,
                     FPDARTCL     FA,
                     FINFLOWTYPE  FT
               where PS.RN = NSTAGE
                 and PS.FACEACC = CN.PROD_ORDER
                 and ((NFPDARTCL is null) or ((NFPDARTCL is not null) and (CN.COST_ARTICLE = NFPDARTCL)))
                 and CN.COST_TYPE = FS.RN
                 and FS.TYPE = 1
                 and CN.COST_ARTICLE = FA.RN
                 and FA.DEF_FLOW = FT.RN(+)
                 and ((NFINFLOW_TYPE is null) or ((NFINFLOW_TYPE is not null) and (FT.TYPE = NFINFLOW_TYPE))))
    loop
      /* Сформируем идентификатор буфера */
      if (NIDENT is null) then
        NIDENT := GEN_IDENT();
      end if;
      /* Добавим подобранное в список отмеченных записей */
      P_SELECTLIST_BASE_INSERT(NIDENT       => NIDENT,
                               NCOMPANY     => C.COMPANY,
                               NDOCUMENT    => C.RN,
                               SUNITCODE    => 'CostNotes',
                               SACTIONCODE  => null,
                               NCRN         => null,
                               NDOCUMENT1   => null,
                               SUNITCODE1   => null,
                               SACTIONCODE1 => null,
                               NRN          => NSELECTLIST);
    end loop;
  end STAGE_ARTS_SELECT_COST_FACT;
  
  /* Получение суммы-факт по статье калькуляции этапа проекта */
  function STAGE_ARTS_GET_COST_FACT
  (
    NSTAGE                  in number,         -- Рег. номер этапа проекта
    NFPDARTCL               in number := null, -- Рег. номер статьи калькуляции (null - по всем)
    NFINFLOW_TYPE           in number := null  -- Вид движения по статье (null - по всем, 0 - остаток, 1 - приход, 2 - расход)
  ) return                  number             -- Сумма-факт по статье
  is
    NRES                    PKG_STD.TNUMBER;   -- Буфер для рузультата
  begin
    /* Суммируем факт по лицевому счёту затрат этапа и указанной статье */
    select COALESCE(sum(CN.COST_BSUM), 0)
      into NRES
      from PROJECTSTAGE PS,
           FCCOSTNOTES  CN,
           FINSTATE     FS,
           FPDARTCL     FA,
           FINFLOWTYPE  FT
     where PS.RN = NSTAGE
       and PS.FACEACC = CN.PROD_ORDER
       and ((NFPDARTCL is null) or ((NFPDARTCL is not null) and (CN.COST_ARTICLE = NFPDARTCL)))
       and CN.COST_TYPE = FS.RN
       and FS.TYPE = 1
       and CN.COST_ARTICLE = FA.RN
       and FA.DEF_FLOW = FT.RN(+)
       and ((NFINFLOW_TYPE is null) or ((NFINFLOW_TYPE is not null) and (FT.TYPE = NFINFLOW_TYPE)));
    /* Возвращаем результат */
    return NRES;
  end STAGE_ARTS_GET_COST_FACT;

  /* Подбор записей договоров с соисполнителями по статье калькуляции этапа проекта */
  procedure STAGE_ARTS_SELECT_CONTR
  (
    NSTAGE                  in number,         -- Рег. номер этапа проекта
    NFPDARTCL               in number := null, -- Рег. номер статьи затрат (null - по всем)
    NIDENT                  out number         -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  )
  is
    NSELECTLIST             PKG_STD.TREF;      -- Рег. номер добавленной записи буфера подобранных
  begin
    /* Подберём записи договоров */
    for C in (select distinct S.COMPANY NCOMPANY,
                              S.PRN     NRN
                from PROJECTSTAGEPF EPF,
                     STAGES         S
               where EPF.PRN = NSTAGE
                 and EPF.FACEACC = S.FACEACC
                 and ((NFPDARTCL is null) or ((NFPDARTCL is not null) and (EPF.COST_ARTICLE = NFPDARTCL))))
    loop
      /* Сформируем идентификатор буфера */
      if (NIDENT is null) then
        NIDENT := GEN_IDENT();
      end if;
      /* Добавим подобранное в список отмеченных записей */
      P_SELECTLIST_BASE_INSERT(NIDENT       => NIDENT,
                               NCOMPANY     => C.NCOMPANY,
                               NDOCUMENT    => C.NRN,
                               SUNITCODE    => 'Contracts',
                               SACTIONCODE  => null,
                               NCRN         => null,
                               NDOCUMENT1   => null,
                               SUNITCODE1   => null,
                               SACTIONCODE1 => null,
                               NRN          => NSELECTLIST);
    end loop;
  end STAGE_ARTS_SELECT_CONTR;

  /* Получение законтрактованной суммы по статье калькуляции этапа проекта */
  function STAGE_ARTS_GET_CONTR
  (
    NSTAGE                  in number,            -- Рег. номер этапа проекта
    NFPDARTCL               in number :=null      -- Рег. номер статьи затрат (null - по всем)
  ) return                  number                -- Сумма контрактов по статье
  is
    RSTG                    PROJECTSTAGE%rowtype; -- Запись этапа
    NTAX_GROUP_DP           PKG_STD.TREF;         -- Рег. номер доп. свойства для налоговой группы проекта
    SPRJ_TAX_GROUP          PKG_STD.TSTRING;      -- Налоговая группа проекта
    NSUM                    PKG_STD.TNUMBER;      -- Сумма контрактов (без налогов)
    NSUM_TAX                PKG_STD.TNUMBER;      -- Сумма контрактов (с налогами)
  begin
    /* Считаем запись этапа */
    begin
      select PS.* into RSTG from PROJECTSTAGE PS where PS.RN = NSTAGE;
    exception
      when NO_DATA_FOUND then
        null;
    end;
    /* Если считано успешно - будем искать данные */
    if (RSTG.RN is not null) then
      /* Определим рег. номер доп. свойства для налоговой группы проекта */
      FIND_DOCS_PROPS_CODE(NFLAG_SMART => 1,
                           NCOMPANY    => RSTG.COMPANY,
                           SCODE       => 'ПУП.TAX_GROUP',
                           NRN         => NTAX_GROUP_DP);
      /* Считаем налоговую группу проекта */
      SPRJ_TAX_GROUP := F_DOCS_PROPS_GET_STR_VALUE(NPROPERTY => NTAX_GROUP_DP,
                                                   SUNITCODE => 'Projects',
                                                   NDOCUMENT => RSTG.PRN);
      /* Считаем сумму этапов договоров с соисполнителями */
      select COALESCE(sum(S.STAGE_SUM), 0),
             COALESCE(sum(S.STAGE_SUMTAX), 0)
        into NSUM,
             NSUM_TAX
        from PROJECTSTAGEPF EPF,
             STAGES         S
       where EPF.PRN = RSTG.RN
         and EPF.FACEACC = S.FACEACC
         and ((NFPDARTCL is null) or ((NFPDARTCL is not null) and (EPF.COST_ARTICLE = NFPDARTCL)));
      /* Вернём сумму в зависимости от налоговой группы проекта */
      if (SPRJ_TAX_GROUP is not null) then
        return NSUM;
      else
        return NSUM_TAX;
      end if;
    else
      return 0;
    end if;
  end STAGE_ARTS_GET_CONTR;
  
  /* Получение списка статей этапа проекта */
  procedure STAGE_ARTS_GET
  (
    NSTAGE                  in number,            -- Рег. номер этапа проекта  
    NINC_COST               in number := 0,       -- Включить сведения о затратах (0 - нет, 1 - да)
    NINC_CONTR              in number := 0,       -- Включить сведения о контрактации (0 - нет, 1 - да)
    RSTAGE_ARTS             out TSTAGE_ARTS       -- Список статей этапа проекта
  )
  is
    RSTG                    PROJECTSTAGE%rowtype; -- Запись этапа проекта
    NCTL_COST_DP            PKG_STD.TREF;         -- Рег. номер доп. свойства, определяющего необходимость контроля затрат по статье
    NCTL_CONTR_DP           PKG_STD.TREF;         -- Рег. номер доп. свойства, определяющего необходимость контроля контрактации по статье
    I                       PKG_STD.TNUMBER;      -- Счётчик статей в результирующей коллекции
  begin
    /* Читаем этап */
    RSTG := STAGES_GET(NRN => NSTAGE);
    /* Определим дополнительные свойства - контроль затрат */
    if (NINC_COST = 1) then
      FIND_DOCS_PROPS_CODE(NFLAG_SMART => 1, NCOMPANY => RSTG.COMPANY, SCODE => 'ПУП.CTL_COST', NRN => NCTL_COST_DP);
    end if;
    /* Определим дополнительные свойства - контроль контрактации */
    if (NINC_CONTR = 1) then
      FIND_DOCS_PROPS_CODE(NFLAG_SMART => 1,
                           NCOMPANY    => RSTG.COMPANY,
                           SCODE       => 'ПУП.CTL_CONTR',
                           NRN         => NCTL_CONTR_DP);
    end if;
    /* Инициализируем коллекцию */
    RSTAGE_ARTS := TSTAGE_ARTS();
    /* Подбираем активную структуру цены этапа проекта и её обходим статьи */
    for C in (select CSPA.NUMB     SNUMB,
                     A.RN          NARTICLE,
                     A.NAME        SARTICLE,
                     CSPA.COST_SUM NCOST_SUM
                from PROJECTSTAGE  PS,
                     STAGES        CS,
                     CONTRPRSTRUCT CSP,
                     CONTRPRCLC    CSPA,
                     FPDARTCL      A
               where PS.RN = RSTG.RN
                 and PS.FACEACCCUST = CS.FACEACC
                 and CSP.PRN = CS.RN
                 and CSP.SIGN_ACT = 1
                 and CSPA.PRN = CSP.RN
                 and CSPA.COST_ARTICLE = A.RN
               order by CSPA.NUMB)
    loop
      /* Добавим строку в коллекцию */
      RSTAGE_ARTS.EXTEND();
      I := RSTAGE_ARTS.LAST;
      /* Наполним её значениями из хранилища */
      RSTAGE_ARTS(I).NRN := C.NARTICLE;
      RSTAGE_ARTS(I).SCODE := C.SNUMB;
      RSTAGE_ARTS(I).SNAME := C.SARTICLE;
      RSTAGE_ARTS(I).NPLAN := C.NCOST_SUM;
      /* Если просили включить сведения о затратах и статья поддерживает это  */
      if ((NINC_COST = 1) and
         (UPPER(F_DOCS_PROPS_GET_STR_VALUE(NPROPERTY => NCTL_COST_DP,
                                            SUNITCODE => 'FinPlanArticles',
                                            NDOCUMENT => RSTAGE_ARTS(I).NRN)) = UPPER(SYES)) and
         (RSTAGE_ARTS(I).NPLAN is not null)) then
        /* Фактические затраты по статье */
        RSTAGE_ARTS(I).NCOST_FACT := STAGE_ARTS_GET_COST_FACT(NSTAGE => NSTAGE, NFPDARTCL => RSTAGE_ARTS(I).NRN);
        /* Отклонение затрат (план-факт) */
        RSTAGE_ARTS(I).NCOST_DIFF := RSTAGE_ARTS(I).NPLAN - RSTAGE_ARTS(I).NCOST_FACT;
        /* Контроль затрат */
        if (RSTAGE_ARTS(I).NCOST_DIFF >= 0) then
          RSTAGE_ARTS(I).NCTRL_COST := 0;
        else
          RSTAGE_ARTS(I).NCTRL_COST := 1;
        end if;
      end if;
      /* Если просили включить сведения о контрактах и статья поддерживает это */
      if ((NINC_CONTR = 1) and
         (UPPER(F_DOCS_PROPS_GET_STR_VALUE(NPROPERTY => NCTL_CONTR_DP,
                                            SUNITCODE => 'FinPlanArticles',
                                            NDOCUMENT => RSTAGE_ARTS(I).NRN)) = UPPER(SYES)) and
         (RSTAGE_ARTS(I).NPLAN is not null)) then
        /* Законтрактовано */
        RSTAGE_ARTS(I).NCONTR := STAGE_ARTS_GET_CONTR(NSTAGE => NSTAGE, NFPDARTCL => RSTAGE_ARTS(I).NRN);
        /* Осталось законтрактовать */
        RSTAGE_ARTS(I).NCONTR_LEFT := RSTAGE_ARTS(I).NPLAN - RSTAGE_ARTS(I).NCONTR;
        /* Контроль контрактации */
        if (RSTAGE_ARTS(I).NCONTR_LEFT >= 0) then
          RSTAGE_ARTS(I).NCTRL_CONTR := 0;
        else
          RSTAGE_ARTS(I).NCTRL_CONTR := 1;
        end if;
      end if;
    end loop;
  end STAGE_ARTS_GET;
  
  /* Список статей калькуляции этапа проекта */
  procedure STAGE_ARTS_LIST
  (
    NSTAGE                  in number,                      -- Рег. номер этапа проекта
    CFILTERS                in clob,                        -- Фильтры
    NINCLUDE_DEF            in number,                      -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob                        -- Сериализованная таблица данных
  )
  is
    RF                      PKG_P8PANELS_VISUAL.TFILTERS;   -- Фильтры
    RF_CTRL_COST            PKG_P8PANELS_VISUAL.TFILTER;    -- Фильтр по колонке "Контроль (затраты)"
    NCTRL_COST_FROM         PKG_STD.TNUMBER;                -- Нижняя граница диапазона фильтра по колонке "Контроль (затраты)"
    NCTRL_COST_TO           PKG_STD.TNUMBER;                -- Верхняя граница диапазона фильтра по колонке "Контроль (затраты)"
    RF_CTRL_CONTR           PKG_P8PANELS_VISUAL.TFILTER;    -- Фильтр по колонке "Контроль (контрактация)"
    NCTRL_CONTR_FROM        PKG_STD.TNUMBER;                -- Нижняя граница диапазона фильтра по колонке "Контроль (контрактация)"
    NCTRL_CONTR_TO          PKG_STD.TNUMBER;                -- Верхняя граница диапазона фильтра по колонке "Контроль (контрактация)"
    RDG                     PKG_P8PANELS_VISUAL.TDATA_GRID; -- Описание таблицы
    RDG_ROW                 PKG_P8PANELS_VISUAL.TROW;       -- Строка таблицы
    RCOL_VALS               PKG_P8PANELS_VISUAL.TCOL_VALS;  -- Предопределённые значения столбцов
    RSTAGE_ARTS             TSTAGE_ARTS;                    -- Список статей этапа проекта
  begin
    /* Читаем фильтры */
    RF := PKG_P8PANELS_VISUAL.TFILTERS_FROM_XML(CFILTERS => CFILTERS);
    /* Найдем фильтр по контролю затрат */
    RF_CTRL_COST := PKG_P8PANELS_VISUAL.TFILTERS_FIND(RFILTERS => RF, SNAME => 'NCTRL_COST');
    PKG_P8PANELS_VISUAL.TFILTER_TO_NUMBER(RFILTER => RF_CTRL_COST, NFROM => NCTRL_COST_FROM, NTO => NCTRL_COST_TO);
    /* Найдем фильтр по контролю контрактации */
    RF_CTRL_CONTR := PKG_P8PANELS_VISUAL.TFILTERS_FIND(RFILTERS => RF, SNAME => 'NCTRL_CONTR');
    PKG_P8PANELS_VISUAL.TFILTER_TO_NUMBER(RFILTER => RF_CTRL_CONTR, NFROM => NCTRL_CONTR_FROM, NTO => NCTRL_CONTR_TO);
    /* Инициализируем таблицу данных */
    RDG := PKG_P8PANELS_VISUAL.TDATA_GRID_MAKE();
    /* Добавляем в таблицу описание колонок */
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NRN',
                                               SCAPTION   => 'Рег. номер',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SNUMB',
                                               SCAPTION   => 'Номер',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SNAME',
                                               SCAPTION   => 'Наименование статьи',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NPLAN',
                                               SCAPTION   => 'План',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCOST_FACT',
                                               SCAPTION   => 'Фактические затраты',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCOST_DIFF',
                                               SCAPTION   => 'Отклонение по затратам',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 0, BCLEAR => true);
    PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 1);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_COST',
                                               SCAPTION   => 'Контроль (затраты)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCONTR',
                                               SCAPTION   => 'Законтрактовано',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCONTR_LEFT',
                                               SCAPTION   => 'Осталось законтрактовать',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_CONTR',
                                               SCAPTION   => 'Контроль (контрактация)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS);
    /* Сформируем сведения по статям этапа проекта  */
    STAGE_ARTS_GET(NSTAGE => NSTAGE, NINC_COST => 1, NINC_CONTR => 1, RSTAGE_ARTS => RSTAGE_ARTS);
    /* Обходим собранные статьи */
    if ((RSTAGE_ARTS is not null) and (RSTAGE_ARTS.COUNT > 0)) then
      for I in RSTAGE_ARTS.FIRST .. RSTAGE_ARTS.LAST
      loop
        /* Если прошли фильтр */
        if (((NCTRL_COST_FROM is null) or
           ((NCTRL_COST_FROM is not null) and (NCTRL_COST_FROM = RSTAGE_ARTS(I).NCTRL_COST))) and
           ((NCTRL_CONTR_FROM is null) or
           ((NCTRL_CONTR_FROM is not null) and (NCTRL_CONTR_FROM = RSTAGE_ARTS(I).NCTRL_CONTR)))) then
          /* Добавляем колонки с данными */
          PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW   => RDG_ROW,
                                           SNAME  => 'NRN',
                                           NVALUE => RSTAGE_ARTS(I).NRN,
                                           BCLEAR => true);
          PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'SNUMB', SVALUE => RSTAGE_ARTS(I).SCODE);
          PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'SNAME', SVALUE => RSTAGE_ARTS(I).SNAME);
          PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NPLAN', NVALUE => RSTAGE_ARTS(I).NPLAN);
          PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NCOST_FACT', NVALUE => RSTAGE_ARTS(I).NCOST_FACT);
          PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NCOST_DIFF', NVALUE => RSTAGE_ARTS(I).NCOST_DIFF);
          PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NCTRL_COST', NVALUE => RSTAGE_ARTS(I).NCTRL_COST);
          PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NCONTR', NVALUE => RSTAGE_ARTS(I).NCONTR);
          PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW   => RDG_ROW,
                                           SNAME  => 'NCONTR_LEFT',
                                           NVALUE => RSTAGE_ARTS(I).NCONTR_LEFT);
          PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW   => RDG_ROW,
                                           SNAME  => 'NCTRL_CONTR',
                                           NVALUE => RSTAGE_ARTS(I).NCTRL_CONTR);
          /* Добавляем строку в таблицу */
          PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW);
        end if;
      end loop;
    end if;
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TDATA_GRID_TO_XML(RDATA_GRID => RDG, NINCLUDE_DEF => NINCLUDE_DEF);
  end STAGE_ARTS_LIST;

  /* Список договоров этапа проекта */
  procedure STAGE_CONTRACTS_COND
  is
  begin
    /* Установка главной таблицы */
    PKG_COND_BROKER.SET_TABLE(STABLE_NAME => 'PROJECTSTAGEPF');
    /* Этап проекта */
    PKG_COND_BROKER.SET_COLUMN_PRN(SCOLUMN_NAME => 'PRN');
    /* Соисполнитель */
    PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'AGNNAME',
                                       SCONDITION_NAME => 'EDAGENT',
                                       SJOINS          => 'PERFORMER <- RN;AGNLIST');
    /* Статья затрат */
    PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'CODE',
                                       SCONDITION_NAME => 'EDSCOST_ART',
                                       SJOINS          => 'COST_ARTICLE <- RN;FPDARTCL');
    /* Группа - этап договора */
    PKG_COND_BROKER.SET_GROUP(SGROUP_NAME         => 'STAGES',
                              STABLE_NAME         => 'STAGES',
                              SCOLUMN_NAME        => 'FACEACC',
                              SPARENT_COLUMN_NAME => 'FACEACC');
    /* Этап договора - номер этапа */
    PKG_COND_BROKER.ADD_GROUP_CONDITION_CODE(SGROUP_NAME     => 'STAGES',
                                             SCOLUMN_NAME    => 'NUMB',
                                             SCONDITION_NAME => 'EDSTAGE',
                                             IALIGN          => 20);
    /* Этап договора - дата начала этапа */
    PKG_COND_BROKER.ADD_GROUP_CONDITION_BETWEEN(SGROUP_NAME          => 'STAGES',
                                                SCOLUMN_NAME         => 'BEGIN_DATE',
                                                SCONDITION_NAME_FROM => 'EDCSTAGE_BEGIN_DATEFrom',
                                                SCONDITION_NAME_TO   => 'EDCSTAGE_BEGIN_DATETo');
    /* Этап договора - дата окончания этапа */
    PKG_COND_BROKER.ADD_GROUP_CONDITION_BETWEEN(SGROUP_NAME          => 'STAGES',
                                                SCOLUMN_NAME         => 'END_DATE',
                                                SCONDITION_NAME_FROM => 'EDCSTAGE_END_DATEFrom',
                                                SCONDITION_NAME_TO   => 'EDCSTAGE_END_DATETo');
    /* Этап договора - префикс договора */
    PKG_COND_BROKER.ADD_GROUP_CONDITION_CODE(SGROUP_NAME     => 'STAGES',
                                             SCOLUMN_NAME    => 'DOC_PREF',
                                             SCONDITION_NAME => 'EDDOC_PREF',
                                             SJOINS          => 'PRN <- RN;CONTRACTS',
                                             IALIGN          => 80);
    /* Этап договора - номер договора */
    PKG_COND_BROKER.ADD_GROUP_CONDITION_CODE(SGROUP_NAME     => 'STAGES',
                                             SCOLUMN_NAME    => 'DOC_NUMB',
                                             SCONDITION_NAME => 'EDDOC_NUMB',
                                             SJOINS          => 'PRN <- RN;CONTRACTS',
                                             IALIGN          => 80);
    /* Этап договора - дата договора */
    PKG_COND_BROKER.ADD_GROUP_CONDITION_BETWEEN(SGROUP_NAME          => 'STAGES',
                                                SCOLUMN_NAME         => 'DOC_DATE',
                                                SCONDITION_NAME_FROM => 'EDDOC_DATEFrom',
                                                SCONDITION_NAME_TO   => 'EDDOC_DATETo',
                                                SJOINS               => 'PRN <- RN;CONTRACTS');
  end STAGE_CONTRACTS_COND;

  /* Список договоров этапа проекта */
  procedure STAGE_CONTRACTS_LIST
  (
    NSTAGE                  in number,                             -- Рег. номер этапа проекта
    NPAGE_NUMBER            in number,                             -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,                             -- Количество записей на странице (0 - все)
    CFILTERS                in clob,                               -- Фильтры
    CORDERS                 in clob,                               -- Сортировки
    NINCLUDE_DEF            in number,                             -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob                               -- Сериализованная таблица данных
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
    NIDENT                  PKG_STD.TREF := GEN_IDENT();           -- Идентификатор отбора
    RF                      PKG_P8PANELS_VISUAL.TFILTERS;          -- Фильтры
    RO                      PKG_P8PANELS_VISUAL.TORDERS;           -- Сортировки
    RDG                     PKG_P8PANELS_VISUAL.TDATA_GRID;        -- Описание таблицы
    RDG_ROW                 PKG_P8PANELS_VISUAL.TROW;              -- Строка таблицы
    NROW_FROM               PKG_STD.TREF;                          -- Номер строки с
    NROW_TO                 PKG_STD.TREF;                          -- Номер строки по
    CSQL                    clob;                                  -- Буфер для запроса
    ICURSOR                 integer;                               -- Курсор для исполнения запроса
  begin
    /* Читаем фильтры */
    RF := PKG_P8PANELS_VISUAL.TFILTERS_FROM_XML(CFILTERS => CFILTERS);
    /* Читем сортировки */
    RO := PKG_P8PANELS_VISUAL.TORDERS_FROM_XML(CORDERS => CORDERS);
    /* Преобразуем номер и размер страницы в номер строк с и по */
    PKG_P8PANELS_VISUAL.UTL_ROWS_LIMITS_CALC(NPAGE_NUMBER => NPAGE_NUMBER,
                                             NPAGE_SIZE   => NPAGE_SIZE,
                                             NROW_FROM    => NROW_FROM,
                                             NROW_TO      => NROW_TO);
    /* Инициализируем таблицу данных */
    RDG := PKG_P8PANELS_VISUAL.TDATA_GRID_MAKE();
    /* Добавляем в таблицу описание колонок */
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NRN',
                                               SCAPTION   => 'Рег. номер',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SDOC_PREF',
                                               SCAPTION   => 'Префикс',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               SCOND_FROM => 'EDDOC_PREF',
                                               BORDER     => true,
                                               BFILTER    => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SLNK_UNIT_SDOC_PREF',
                                               SCAPTION   => 'Префикс (код раздела ссылки)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NLNK_DOCUMENT_SDOC_PREF',
                                               SCAPTION   => 'Префикс (документ ссылки)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SDOC_NUMB',
                                               SCAPTION   => 'Номер',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               SCOND_FROM => 'EDDOC_NUMB',
                                               BORDER     => true,
                                               BFILTER    => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SLNK_UNIT_SDOC_NUMB',
                                               SCAPTION   => 'Номер (код раздела ссылки)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NLNK_DOCUMENT_SDOC_NUMB',
                                               SCAPTION   => 'Номер (документ ссылки)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DDOC_DATE',
                                               SCAPTION   => 'Дата',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               SCOND_FROM => 'EDDOC_DATEFrom',
                                               SCOND_TO   => 'EDDOC_DATETo',
                                               BORDER     => true,
                                               BFILTER    => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SEXT_NUMBER',
                                               SCAPTION   => 'Внешний номер',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SAGENT',
                                               SCAPTION   => 'Соисполнитель',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               SCOND_FROM => 'EDAGENT',
                                               BORDER     => true,
                                               BFILTER    => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SAGENT_INN',
                                               SCAPTION   => 'ИНН соисполнителя',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SAGENT_KPP',
                                               SCAPTION   => 'КПП соисполнителя',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SGOVCNTRID',
                                               SCAPTION   => 'ИГК',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SCSTAGE',
                                               SCAPTION   => 'Этап',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               SCOND_FROM => 'EDSTAGE',
                                               BORDER     => true,
                                               BFILTER    => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SCSTAGE_DESCRIPTION',
                                               SCAPTION   => 'Описание этапа',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DCSTAGE_BEGIN_DATE',
                                               SCAPTION   => 'Дата начала',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               SCOND_FROM => 'EDCSTAGE_BEGIN_DATEFrom',
                                               SCOND_TO   => 'EDCSTAGE_BEGIN_DATETo',
                                               BORDER     => true,
                                               BFILTER    => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DCSTAGE_END_DATE',
                                               SCAPTION   => 'Дата окончания',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               SCOND_FROM => 'EDCSTAGE_END_DATEFrom',
                                               SCOND_TO   => 'EDCSTAGE_END_DATETo',
                                               BORDER     => true,
                                               BFILTER    => true);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NSUMM',
                                               SCAPTION   => 'Сумма',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SCURR',
                                               SCAPTION   => 'Валюта',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SCOST_ART',
                                               SCAPTION   => 'Статья затрат',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               SCOND_FROM => 'EDSCOST_ART',
                                               BORDER     => true,
                                               BFILTER    => true);
    /* Обходим данные */
    begin
      /* Собираем запрос */
      CSQL := 'select *
            from (select D.*,
                         ROWNUM NROW
                    from (select PSPF.RN NRN,
                                 trim(CN.DOC_PREF) SDOC_PREF,
                                 ''Contracts'' SLNK_UNIT_SDOC_PREF,
                                 CN.RN NLNK_DOCUMENT_SDOC_PREF,
                                 trim(CN.DOC_NUMB) SDOC_NUMB,
                                 ''Contracts'' SLNK_UNIT_SDOC_NUMB,
                                 CN.RN NLNK_DOCUMENT_SDOC_NUMB,
                                 CN.DOC_DATE DDOC_DATE,
                                 CN.EXT_NUMBER SEXT_NUMBER,
                                 AG.AGNNAME SAGENT,
                                 AG.AGNIDNUMB SAGENT_INN,
                                 AG.REASON_CODE SAGENT_KPP,
                                 ''"'' || GC.CODE || ''"'' SGOVCNTRID,
                                 trim(ST.NUMB) SCSTAGE,
                                 ST.DESCRIPTION SCSTAGE_DESCRIPTION,
                                 ST.BEGIN_DATE DCSTAGE_BEGIN_DATE,
                                 ST.END_DATE DCSTAGE_END_DATE,
                                 PSPF.COST_PLAN NSUMM,
                                 CUR.INTCODE SCURR,
                                 ART.CODE SCOST_ART
                            from PROJECTSTAGEPF PSPF,
                                 STAGES         ST,
                                 CONTRACTS      CN,
                                 AGNLIST        AG,
                                 CURNAMES       CUR,
                                 FPDARTCL       ART,
                                 GOVCNTRID      GC
                           where PSPF.FACEACC = ST.FACEACC
                             and ST.PRN = CN.RN
                             and PSPF.PERFORMER = AG.RN
                             and CN.CURRENCY = CUR.RN
                             and PSPF.COST_ARTICLE = ART.RN(+)
                             and CN.GOVCNTRID = GC.RN(+)                             
                             and PSPF.RN in (select ID from COND_BROKER_IDSMART where IDENT = :NIDENT) %ORDER_BY%) D) F
           where F.NROW between :NROW_FROM and :NROW_TO';
      /* Учтём сортировки */
      PKG_P8PANELS_VISUAL.TORDERS_SET_QUERY(RDATA_GRID => RDG, RORDERS => RO, SPATTERN => '%ORDER_BY%', CSQL => CSQL);
      /* Учтём фильтры */
      PKG_P8PANELS_VISUAL.TFILTERS_SET_QUERY(NIDENT     => NIDENT,
                                             NCOMPANY   => NCOMPANY,
                                             NPARENT    => NSTAGE,
                                             SUNIT      => 'ProjectsStagesPerformers',
                                             SPROCEDURE => 'PKG_P8PANELS_PROJECTS.STAGE_CONTRACTS_COND',
                                             RDATA_GRID => RDG,
                                             RFILTERS   => RF);
      /* Разбираем его */
      ICURSOR := PKG_SQL_DML.OPEN_CURSOR(SWHAT => 'SELECT');
      PKG_SQL_DML.PARSE(ICURSOR => ICURSOR, SQUERY => CSQL);
      /* Делаем подстановку параметров */
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NIDENT', NVALUE => NIDENT);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_FROM', NVALUE => NROW_FROM);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_TO', NVALUE => NROW_TO);
      /* Описываем структуру записи курсора */
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 1);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 2);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 3);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 4);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 5);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 6);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 7);
      PKG_SQL_DML.DEFINE_COLUMN_DATE(ICURSOR => ICURSOR, IPOSITION => 8);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 9);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 10);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 11);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 12);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 13);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 14);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 15);
      PKG_SQL_DML.DEFINE_COLUMN_DATE(ICURSOR => ICURSOR, IPOSITION => 16);
      PKG_SQL_DML.DEFINE_COLUMN_DATE(ICURSOR => ICURSOR, IPOSITION => 17);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 18);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 19);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 20);
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
                                              SNAME     => 'SDOC_PREF',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 2);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SLNK_UNIT_SDOC_PREF',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 3);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NLNK_DOCUMENT_SDOC_PREF',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 4);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SDOC_NUMB',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 5);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SLNK_UNIT_SDOC_NUMB',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 6);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NLNK_DOCUMENT_SDOC_NUMB',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 7);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLD(RROW      => RDG_ROW,
                                              SNAME     => 'DDOC_DATE',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 8);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SEXT_NUMBER',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 9);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SAGENT', ICURSOR => ICURSOR, NPOSITION => 10);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SAGENT_INN',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 11);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SAGENT_KPP',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 12);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SGOVCNTRID',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 13);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SCSTAGE', ICURSOR => ICURSOR, NPOSITION => 14);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SCSTAGE_DESCRIPTION',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 15);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLD(RROW      => RDG_ROW,
                                              SNAME     => 'DCSTAGE_BEGIN_DATE',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 16);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLD(RROW      => RDG_ROW,
                                              SNAME     => 'DCSTAGE_END_DATE',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 17);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW => RDG_ROW, SNAME => 'NSUMM', ICURSOR => ICURSOR, NPOSITION => 18);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SCURR', ICURSOR => ICURSOR, NPOSITION => 19);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SCOST_ART',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 20);
        /* Добавляем строку в таблицу */
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW);
      end loop;
      /* Освобождаем курсор */
      PKG_SQL_DML.CLOSE_CURSOR(ICURSOR => ICURSOR);
    exception
      when others then
        PKG_SQL_DML.CLOSE_CURSOR(ICURSOR => ICURSOR);
        raise;
    end;
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TDATA_GRID_TO_XML(RDATA_GRID => RDG, NINCLUDE_DEF => NINCLUDE_DEF);
  end STAGE_CONTRACTS_LIST;

end PKG_P8PANELS_PROJECTS;
/

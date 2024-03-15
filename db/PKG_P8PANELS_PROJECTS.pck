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

  /* Получение % готовности проекта (по затратам) */
  function GET_COST_READY
  (
    NRN                     in number   -- Рег. номер проекта
  ) return                  number;     -- % готовности
  
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
  
  /* Сфодный график проектов */
  procedure GRAPH
  (
    COUT                    out clob    -- График проектов
  );
  
  /* График по данным проектов - "Топ проблем" */
  procedure CHART_PROBLEMS
  (
    COUT                    out clob    -- Сериализованный график
  );

  /* График по данным проектов - "Топ заказчиков" */
  procedure CHART_CUSTOMERS
  (
    COUT                    out clob    -- Сериализованный график
  );
  
  /* График по данным проектов - "Затраты на проекты" */
  procedure CHART_FCCOSTNOTES
  (
    COUT                    out clob    -- Сериализованный график
  );
  
  /* График по данным проектов - "Затраты на проекты" (подбор записей журнала затрат по точке графика) */
  procedure CHART_FCCOSTNOTES_SELECT_COST
  (
    NYEAR                   in number,  -- Год
    NMONTH                  in number,  -- Месяц
    NIDENT                  out number  -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
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
  ) return                  number;     -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)

  /* Получение состояния контрактации этапа проекта */
  function STAGES_GET_CTRL_CONTR
  (
    NRN                     in number   -- Рег. номер этапа проекта
  ) return                  number;     -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)

  /* Получение состояния соисполнения этапа проекта */
  function STAGES_GET_CTRL_COEXEC
  (
    NRN                     in number   -- Рег. номер этапа проекта
  ) return                  number;     -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  
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
  ) return                  number;     -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  
  /* Получение остатка срока исполнения этапа проекта */
  function STAGES_GET_DAYS_LEFT
  (
    NRN                     in number   -- Рег. номер этапа проекта
  ) return                  number;     -- Количество дней (null - не определено)
  
  /* Подбор записей журнала затрат этапа проекта */
  procedure STAGES_SELECT_COST_FACT
  (
    NRN                     in number,  -- Рег. номер этапа проекта
    NIDENT                  out number  -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  );
  
  /* Получение суммы фактических затрат этапа проекта */
  function STAGES_GET_COST_FACT
  (
    NRN                     in number   -- Рег. номер этапа проекта
  ) return                  number;     -- Сумма фактических затрат

  /* Подбор записей расходных накладных на отпуск потребителям этапа проекта */
  procedure STAGES_SELECT_SUMM_REALIZ
  (
    NRN                     in number,  -- Рег. номер этапа проекта
    NIDENT                  out number  -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  );
  
  /* Получение суммы реализации этапа проекта */
  function STAGES_GET_SUMM_REALIZ
  (
    NRN                     in number,  -- Рег. номер этапа проекта
    NFPDARTCL_REALIZ        in number   -- Рег. номер статьи калькуляции для реализации
  ) return                  number;     -- Сумма реализации
  
  /* Получение % готовности этапа проекта (по затратам) */
  function STAGES_GET_COST_READY
  (
    NRN                     in number   -- Рег. номер этапа проекта
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
    NSTAGE                  in number,         -- Рег. номер этапа проекта
    NFPDARTCL               in number := null, -- Рег. номер статьи затрат (null - брать все)
    NINC_COST               in number := 0,    -- Включить сведения о затратах (0 - нет, 1 - да)
    NINC_CONTR              in number := 0,    -- Включить сведения о контрактации (0 - нет, 1 - да)
    RSTAGE_ARTS             out TSTAGE_ARTS    -- Список статей этапа проекта
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

  /* Подбор входящих счетов на оплату соисполнителя этапа проекта */
  procedure STAGE_CONTRACTS_SELECT_PAY_IN
  (
    NPROJECTSTAGEPF         in number,  -- Рег. номер соисполнителя этапа проекта
    NIDENT                  out number  -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  );

  /* Подбор приходных накладных соисполнителя этапа проекта */
  procedure STAGE_CONTRACTS_SELECT_ININV
  (
    NPROJECTSTAGEPF         in number,  -- Рег. номер соисполнителя этапа проекта
    NIDENT                  out number  -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  );
  
  /* Подбор платежей финансирования соисполнителя этапа проекта */
  procedure STAGE_CONTRACTS_SELECT_FIN_OUT
  (
    NPROJECTSTAGEPF         in number,  -- Рег. номер соисполнителя этапа проекта
    NIDENT                  out number  -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  );
  
  /* Получение состояния финансирования по договору соисполнителя этапа проекта */
  function STAGE_CONTRACTS_GET_CTRL_FIN
  (
    NPROJECTSTAGEPF         in number   -- Рег. номер соисполнителя этапа проекта
  ) return                  number;     -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)

  /* Получение состояния соисполнения по договору соисполнителя этапа проекта */
  function STAGE_CONTRACTS_GET_CTRL_COEXE
  (
    NPROJECTSTAGEPF         in number   -- Рег. номер соисполнителя этапа проекта
  ) return                  number;     -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)

  /* Получение сведений по договору соисполнителя этапа проекта */
  procedure STAGE_CONTRACTS_GET
  (
    NPROJECTSTAGEPF         in number,      -- Рег. номер соисполнителя этапа проекта
    NINC_FIN                in number := 0, -- Включить сведения о финансировании (0 - нет, 1 - да)
    NINC_COEXEC             in number := 0, -- Включить сведения о соисполнении (0 - нет, 1 - да)
    NPAY_IN                 out number,     -- Сведения о финансировании - сумма акцептованных счетов на оплату
    NFIN_OUT                out number,     -- Сведения о финансировании - сумма оплаченных счетов на оплату
    NPAY_IN_REST            out number,     -- Сведения о финансировании - сумма оставшихся к оплате счетов на оплату
    NFIN_REST               out number,     -- Сведения о финансировании - общий остаток к оплате по договору
    NCTRL_FIN               out number,     -- Сведения о финансировании - состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
    NCOEXEC_IN              out number,     -- Сведения о соисполнении - получено актов/накладных
    NCOEXEC_REST            out number,     -- Сведения о соисполнении - остаток к актированию/поставке
    NCTRL_COEXEC            out number      -- Сведения о соисполнении - состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  );
  
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

    /* Получение списка проектов */
  procedure JB_PRJCTS_LIST
  (
    NIDENT                  in number,  -- Идентификатор процесса
    COUT                    out clob    -- Список проектов
  );
  
  /* Изменение сроков работы в буфере балансировки */
  procedure JB_JOBS_MODIFY_PERIOD
  (
    NJB_JOBS                in number,  -- Рег. номер записи балансируемой работы/этапа
    DDATE_FROM              in date,    -- Новая дата начала
    DDATE_TO                in date,    -- Новая дата окончания
    DBEGIN                  in date,    -- Дата начала периода мониторинга загрузки ресурсов
    DFACT                   in date,    -- Факт по состоянию на
    NDURATION_MEAS          in number,  -- Единица измерения длительности (0 - день, 1 - неделя, 2 - декада, 3 - месяц, 4 - квартал, 5 - год)    
    NRESOURCE_STATUS        out number  -- Состояние ресурсов (0 - без отклонений, 1 - есть отклонения, -1 - ничего не изменяли)
  );
  
  /* Получение списка работ проектов для диаграммы Ганта */
  procedure JB_JOBS_LIST
  (
    NIDENT                  in number,  -- Идентификатор процесса
    NPRN                    in number,  -- Рег. номер родителя
    NINCLUDE_DEF            in number,  -- Признак включения описания диаграммы в ответ
    COUT                    out clob    -- Список проектов
  );
  
    /* Получение списка для детализации трудоёмкости по ФОТ периода балансировки */
  procedure JB_PERIODS_LIST_PLAN_FOT
  (
    NJB_PERIODS             in number,  -- Рег. номер записи периода в буфере балансировки
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    CORDERS                 in clob,    -- Сортировки    
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
  );
  
  /* Получение списка для детализации трудоёмкости периода балансировки по текущему состоянию графика */
  procedure JB_PERIODS_LIST_PLAN_JOBS
  (
    NJB_PERIODS             in number,  -- Рег. номер записи периода в буфере балансировки
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    CORDERS                 in clob,    -- Сортировки    
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
  );
  
  /* Пересчёт периодов балансировки */
  procedure JB_PERIODS_RECALC
  (
    NIDENT                  in number,  -- Идентификатор процесса
    DBEGIN                  in date,    -- Дата начала периода мониторинга загрузки ресурсов
    NINITIAL                in number,  -- Признак первоначального рассчёта (0 - пересчёт, 1 - первоначальный рассчёт)
    NRESOURCE_STATUS        out number  -- Состояние ресурсов (0 - без отклонений, 1 - есть отклонения)
  );
  
  /* Список периодов балансировки */
  procedure JB_PERIODS_LIST
  (
    NIDENT                  in number,  -- Идентификатор процесса
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    CORDERS                 in clob,    -- Сортировки    
    NINCLUDE_DEF            in number,  -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob    -- Сериализованная таблица данных
  );
  
  /* Очистка данных балансировки */
  procedure JB_CLEAN
  (
    NIDENT                  in number   -- Идентификатор процесса
  );
  
  /* Перенос данных буфера балансировки в проекты */
  procedure JB_SAVE
  (
    NIDENT                  in number,  -- Идентификатор процесса
    COUT                    out clob    -- Список проектов
  );
  
  /* Формирование исходных данных для балансировки планов-графиков работ */
  procedure JB_INIT
  (
    DBEGIN                  in out date,     -- Дата начала периода мониторинга загрузки ресурсов
    DFACT                   in out date,     -- Факт по состоянию на
    NDURATION_MEAS          in out number,   -- Единица измерения длительности (0 - день, 1 - неделя, 2 - декада, 3 - месяц, 4 - квартал, 5 - год)
    SLAB_MEAS               in out varchar2, -- Единица измерения трудоёмкости
    NIDENT                  in out number,   -- Идентификатор процесса (null - сгенерировать новый, !null - удалить старые данные и пересоздать с указанным идентификатором)
    NRESOURCE_STATUS        out number       -- Состояние ресурсов (0 - без отклонений, 1 - есть отклонения)    
  );

end PKG_P8PANELS_PROJECTS;
/
create or replace package body PKG_P8PANELS_PROJECTS as

/*
TODO: owner="root" created="25.10.2023"
text="Пересчёт единиц измерения в мониторе плана-графика"
*/

/*
TODO: owner="root" created="25.10.2023"
text="Буфер для хранения параметров балансировки и читать их оттуда для вызовов JB_JOBS_MODIFY_PERIOD, JB_JOBS_PERIODS_RECALC"
*/

/*
TODO: owner="root" created="25.10.2023"
text="Права доступа в мониторе ресурвов при балансировке планов-графиков"
*/

/*
TODO: owner="root" created="25.10.2023"
text="Вынести расчте плановой трудоёмкости по графику (и всех её причендалов) в отдельную функцию (и), чтобы можно было включить её в динамический запрос и вернуть сортировку по полям трудоёмкости в JB_PERIODS_LIST_PLAN_JOBS"
*/

/*
TODO: owner="root" created="25.10.2023"
text="Проверить, что для расчётных полей дата-гридов отключена сортировка - иначе получается ошибка, т.к. поля нет в SQL-запросе"
*/


  /* Константы - предопределённые значения */
  SYES                        constant PKG_STD.TSTRING := 'Да';               -- Да
  NDAYS_LEFT_LIMIT            constant PKG_STD.TNUMBER := 30;                 -- Лимит отстатка дней для контроля сроков
  SFPDARTCL_REALIZ            constant PKG_STD.TSTRING := '14 Цена без НДС';  -- Мнемокод статьи калькуляции для учёта реализации
  SFPDARTCL_SELF_COST         constant PKG_STD.TSTRING := '10 Себестоимость'; -- Мнемокод статьи калькуляции для учёта себестоимости
  NGANTT_TASK_CAPTION_LEN     constant PKG_STD.TNUMBER := 50;                 -- Предельная длина (знаков) метки задачи при отображении диаграммы Ганта
  NJB_DURATION_MEAS           constant PKG_STD.TNUMBER := 0;                  -- Единица измерения длительности по умолчанию для интерфейса балансировки работ (0 - день, 1 - неделя, 2 - декада, 3 - месяц, 4 - квартал, 5 - год)
  SJB_LAB_MEAS                constant PKG_STD.TSTRING := 'Ч/Ч';              -- Единица измерения трудоёмкости по умолчанию для интерфейса балансировки работ

  /* Константы - дополнительные свойства */
  SDP_SECON_RESP              constant PKG_STD.TSTRING := 'ПУП.SECON_RESP'; -- Ответственный экономист проекта
  SDP_STAX_GROUP              constant PKG_STD.TSTRING := 'ПУП.TAX_GROUP';  -- Налоговая группа проекта
  SDP_SCTL_COST               constant PKG_STD.TSTRING := 'ПУП.CTL_COST';   -- Принзнак необходимости контроля факт. затрат по статье калькуляции
  SDP_SCTL_CONTR              constant PKG_STD.TSTRING := 'ПУП.CTL_CONTR';  -- Принзнак необходимости контроля контрактации по статье калькуляции

  /* Считывание наименование подразделения по рег. номеру */
  function UTL_INS_DEPARTMENT_GET_NAME
  (
    NRN                     in number        -- Рег. номер подразделения
  ) return                  varchar2         -- Наименование подразеления (null - если не нашли)
  is
    SRES                    PKG_STD.TSTRING; -- Буфер для результата
  begin
    select T.NAME into SRES from INS_DEPARTMENT T where T.RN = NRN;
    return SRES;
  exception
    when NO_DATA_FOUND then
      return null;
  end UTL_INS_DEPARTMENT_GET_NAME;   
     
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
  
  /* Проверка пользователя на ответственность за проект */
  function CHECK_RESPONSIBLE
  (
    NRN                     in number,            -- Рег. номер проекта
    SAUTHID                 in varchar2           -- Имя пользователя    
  ) return                  number                -- Признак ответственности за проект (0 - не ответственный, 1 - ответственный)
  is
    RP                      PROJECT%rowtype;      -- Запись проекта
    NRES                    PKG_STD.TNUMBER := 0; -- Буфер для результата
    NAUTHID_AGENT           PKG_STD.TREF;         -- Рег. номер контрагента пользователя  
  begin
    /* Считаем проект */
    RP := GET(NRN => NRN);
    /* Найдем контрагента, соответствующего текущему пользователю */
    FIND_AGNLIST_AUTHID(NFLAG_OPTION => 1, NCOMPANY => RP.COMPANY, SPERS_AUTHID => SAUTHID, NAGENT => NAUTHID_AGENT);
    /* Проверим ответственность */
    if (RP.RESPONSIBLE = NAUTHID_AGENT) then
      NRES := 1;
    end if;
    /* Вернём результат */
    return NRES;
  exception
    when others then
      return NRES;
  end CHECK_RESPONSIBLE;

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
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.GET_CTRL_FIN') ||
                                            '(RN) = :EDCTRL_FIN');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_FIN',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_FIN'));
    end if;
    /* Контроль контрактации */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_CONTR') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.GET_CTRL_CONTR') ||
                                            '(RN) = :EDCTRL_CONTR');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_CONTR',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_CONTR'));
    end if;
    /* Контроль соисполнения */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_COEXEC') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.GET_CTRL_COEXEC') ||
                                            '(RN) = :EDCTRL_COEXEC');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_COEXEC',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_COEXEC'));
    end if;
    /* Контроль сроков */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_PERIOD') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.GET_CTRL_PERIOD') ||
                                            '(RN) = :EDCTRL_PERIOD');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_PERIOD',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_PERIOD'));
    end if;
    /* Контроль затрат */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_COST') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.GET_CTRL_COST') ||
                                            '(RN) = :EDCTRL_COST');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_COST',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_COST'));
    end if;
    /* Контроль актирования */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_ACT') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.GET_CTRL_ACT') ||
                                            '(RN) = :EDCTRL_ACT');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_ACT',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_ACT'));
    end if;
    /* Готовность (%, по затратам) */
    if ((PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCOST_READYFrom') = 1) and
       (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCOST_READYTo') = 0)) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.GET_COST_READY') ||
                                            '(RN) >= :EDCOST_READYFrom');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCOST_READYFrom',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCOST_READYFrom'));
    end if;
    if ((PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCOST_READYTo') = 1) and
       (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCOST_READYFrom') = 0)) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.GET_COST_READY') ||
                                            '(RN) <= :EDCOST_READYTo');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCOST_READYTo',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCOST_READYTo'));
    end if;
    if ((PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCOST_READYFrom') = 1) and
       (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCOST_READYTo') = 1)) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.GET_COST_READY') ||
                                            '(RN) between :EDCOST_READYFrom and :EDCOST_READYTo');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCOST_READYFrom',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCOST_READYFrom'));
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCOST_READYTo',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCOST_READYTo'));
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
                 and exists (select null from V_USERPRIV UP where UP.CATALOG = PS.CRN)
                 and exists (select null
                        from V_USERPRIV UP
                       where UP.JUR_PERS = PS.JUR_PERS
                         and UP.UNITCODE = 'Projects')
                 and exists (select /*+ INDEX(UP I_USERPRIV_CATALOG_ROLEID) */
                       null
                        from USERPRIV UP
                       where UP.CATALOG = CN.CRN
                         and UP.ROLEID in (select /*+ INDEX(UR I_USERROLES_AUTHID_FK) */
                                            UR.ROLEID
                                             from USERROLES UR
                                            where UR.AUTHID = UTILIZER)
                      union all
                      select /*+ INDEX(UP I_USERPRIV_CATALOG_AUTHID) */
                       null
                        from USERPRIV UP
                       where UP.CATALOG = CN.CRN
                         and UP.AUTHID = UTILIZER)
                 and exists (select /*+ INDEX(UP I_USERPRIV_JUR_PERS_ROLEID) */
                       null
                        from USERPRIV UP
                       where UP.JUR_PERS = CN.JUR_PERS
                         and UP.UNITCODE = 'Contracts'
                         and UP.ROLEID in (select /*+ INDEX(UR I_USERROLES_AUTHID_FK) */
                                            UR.ROLEID
                                             from USERROLES UR
                                            where UR.AUTHID = UTILIZER)
                      union all
                      select /*+ INDEX(UP I_USERPRIV_JUR_PERS_AUTHID) */
                       null
                        from USERPRIV UP
                       where UP.JUR_PERS = CN.JUR_PERS
                         and UP.UNITCODE = 'Contracts'
                         and UP.AUTHID = UTILIZER)
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
    NRN                     in number,  -- Рег. номер проекта
    NDIRECTION              in number,  -- Направление (0 - приход, 1 - расход)
    NIDENT                  out number  -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
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
    NRN                     in number             -- Рег. номер проекта
  ) return                  number                -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  is
    NSTAGE_CTRL             PKG_STD.TNUMBER;      -- Состояние этапа
    NCNT_STAGES             PKG_STD.TNUMBER := 0; -- Количество этапов
    NCNT_NULL               PKG_STD.TNUMBER := 0; -- Количество "безконтрольных" этапов
  begin
    /* Обходим этапы */
    for C in (select PS.RN from PROJECTSTAGE PS where PS.PRN = NRN)
    loop
      /* Увеличим счётчик этапов */
      NCNT_STAGES := NCNT_STAGES + 1;
      /* Получим состояние этапа */
      NSTAGE_CTRL := STAGES_GET_CTRL_FIN(NRN => C.RN);
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
  end GET_CTRL_FIN;

  /* Получение состояния контрактации проекта */
  function GET_CTRL_CONTR
  (
    NRN                     in number             -- Рег. номер проекта
  ) return                  number                -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  is
    NSTAGE_CTRL             PKG_STD.TNUMBER;      -- Состояние этапа
    NCNT_STAGES             PKG_STD.TNUMBER := 0; -- Количество этапов
    NCNT_NULL               PKG_STD.TNUMBER := 0; -- Количество "безконтрольных" этапов
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
    NRN                     in number             -- Рег. номер проекта
  ) return                  number                -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  is
    NSTAGE_CTRL             PKG_STD.TNUMBER;      -- Состояние этапа
    NCNT_STAGES             PKG_STD.TNUMBER := 0; -- Количество этапов
    NCNT_NULL               PKG_STD.TNUMBER := 0; -- Количество "безконтрольных" этапов
  begin
    /* Обходим этапы */
    for C in (select PS.RN from PROJECTSTAGE PS where PS.PRN = NRN)
    loop
      /* Увеличим счётчик этапов */
      NCNT_STAGES := NCNT_STAGES + 1;
      /* Получим состояние этапа */
      NSTAGE_CTRL := STAGES_GET_CTRL_COEXEC(NRN => C.RN);
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
  end GET_CTRL_COEXEC;

  /* Получение состояния сроков проекта */
  function GET_CTRL_PERIOD
  (
    NRN                     in number             -- Рег. номер проекта
  ) return                  number                -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  is
    NSTAGE_CTRL             PKG_STD.TNUMBER;      -- Состояние этапа
    NCNT_STAGES             PKG_STD.TNUMBER := 0; -- Количество этапов
    NCNT_NULL               PKG_STD.TNUMBER := 0; -- Количество "безконтрольных" этапов
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
    NRN                     in number             -- Рег. номер проекта
  ) return                  number                -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  is
    NSTAGE_CTRL             PKG_STD.TNUMBER;      -- Состояние этапа
    NCNT_STAGES             PKG_STD.TNUMBER := 0; -- Количество этапов
    NCNT_NULL               PKG_STD.TNUMBER := 0; -- Количество "безконтрольных" этапов
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
    NRN                     in number             -- Рег. номер проекта
  ) return                  number                -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  is
    NSTAGE_CTRL             PKG_STD.TNUMBER;      -- Состояние этапа
    NCNT_STAGES             PKG_STD.TNUMBER := 0; -- Количество этапов
    NCNT_NULL               PKG_STD.TNUMBER := 0; -- Количество "безконтрольных" этапов
  begin
    /* Обходим этапы */
    for C in (select PS.RN from PROJECTSTAGE PS where PS.PRN = NRN)
    loop
      /* Увеличим счётчик этапов */
      NCNT_STAGES := NCNT_STAGES + 1;
      /* Получим состояние этапа */
      NSTAGE_CTRL := STAGES_GET_CTRL_ACT(NRN => C.RN);
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
  end GET_CTRL_ACT;
  
  /* Получение % готовности проекта (по затратам) */
  function GET_COST_READY
  (
    NRN                     in number             -- Рег. номер проекта
  ) return                  number                -- % готовности
  is
    RP                      PROJECT%rowtype;      -- Запись проекта
    NFPDARTCL_SELF_COST     PKG_STD.TREF;         -- Рег. номер статьи себестоимости
    NCOST_FACT              PKG_STD.TNUMBER := 0; -- Сумма фактических затрат по проекту
    NSELF_COST_PLAN         PKG_STD.TNUMBER := 0; -- Плановая себестоимость проекта
    RSTG_SELF_COST_PLAN     TSTAGE_ARTS;          -- Плановая себестоимость этапа
    NRES                    PKG_STD.TNUMBER := 0; -- Буфер для результата
  begin
    /* Читаем проект */
    RP := GET(NRN => NRN);
    /* Определим рег. номер статьи калькуляции для учёта себестоимости */
    FIND_FPDARTCL_CODE(NFLAG_SMART => 1,
                       NCOMPANY    => RP.COMPANY,
                       SCODE       => SFPDARTCL_SELF_COST,
                       NRN         => NFPDARTCL_SELF_COST);
    /* Обходим этапы */
    for C in (select PS.RN from PROJECTSTAGE PS where PS.PRN = RP.RN)
    loop
      /* Накапливаем сумму фактических затрат */
      NCOST_FACT := NCOST_FACT + STAGES_GET_COST_FACT(NRN => C.RN);
      /* Накапливаем плановую себестоимость */
      STAGE_ARTS_GET(NSTAGE => C.RN, NFPDARTCL => NFPDARTCL_SELF_COST, RSTAGE_ARTS => RSTG_SELF_COST_PLAN);
      if ((RSTG_SELF_COST_PLAN.COUNT = 1) and (RSTG_SELF_COST_PLAN(RSTG_SELF_COST_PLAN.LAST).NPLAN <> 0)) then
        NSELF_COST_PLAN := NSELF_COST_PLAN + RSTG_SELF_COST_PLAN(RSTG_SELF_COST_PLAN.LAST).NPLAN;
      end if;
    end loop;
    /* Если есть и фактические затраты и плановая себестоимость */
    if ((NCOST_FACT > 0) and (NSELF_COST_PLAN > 0)) then
      /* Отношение фактических затрат к плановой себестоимость - искомый % готовности */
      NRES := ROUND(NCOST_FACT / NSELF_COST_PLAN * 100, 0);
      /* Если затраты превысили себестоимость, то % может быть > 100, но это бессмысленно, откорректируем ситуацию */
      if (NRES > 100) then
        NRES := 100;
      end if;
    end if;
    /* Вернём рассчитанное */
    return NRES;
  end GET_COST_READY;
  
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
                                               SCAPTION   => 'Фин-е (исх.)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_FIN',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS,
                                               SHINT      => '<b>Финансирование (исходящее)</b> - контроль оплаты счетов, выставленных соисполнителями в рамках проекта.<br>' ||
                                                             '<b style="color:red">Требует внимания</b> - в проекте есть этапы, для которых не все выставленные соисполнителями счета оплачены.<br>' ||
                                                             '<b style="color:green">В норме</b> - нет этапов с отклонениями, описанными выше.<br>' ||
                                                             '<b style="color:gray">Пусто</b> - в Системе не хватает данных для рассчёта. Убедитесь, что для этапов задана привязка к договорам с соисполнителями.');
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_CONTR',
                                               SCAPTION   => 'Контр-я',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_CONTR',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS,
                                               SHINT      => '<b>Контрактация</b> - контроль суммы договоров, заключеных с соисполнителями в рамках проекта.<br>' ||
                                                             '<b style="color:red">Требует внимания</b> - в проекте есть этапы, для которых сумма договоров с соисполнителями превышает заложенные в калькуляцию плановые показатели.<br>' ||
                                                             '<b style="color:green">В норме</b> - нет этапов с отклонениями, описанными выше.<br>' ||
                                                             '<b style="color:gray">Пусто</b> - в Системе не хватает данных для рассчёта. Убедитесь, что для всех этапов заданы плановые калькуляции.');
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_COEXEC',
                                               SCAPTION   => 'Соисп-е',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_COEXEC',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS,
                                               SHINT      => '<b>Соисполнение</b> - контроль исполнения обязательств по договорам, заключеным с соисполнителями в рамках проекта.<br>' ||
                                                             '<b style="color:red">Требует внимания</b> - в проекте есть этапы, до окончания которых осталось менее ' ||
                                                             TO_CHAR(NDAYS_LEFT_LIMIT) ||
                                                             ' дней, при этом зафиксирован положительный остаток к поставке/актированию по договорам соисполнителей данного этапа.<br>' ||
                                                             '<b style="color:green">В норме</b> - нет этапов с отклонениями, описанными выше.<br>' ||
                                                             '<b style="color:gray">Пусто</b> - в Системе не хватает данных для рассчёта. Убедитесь, что для этапов задана привязка к договорам с соисполнителями и плановые сроки окончания.');
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_PERIOD',
                                               SCAPTION   => 'Сроки',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_PERIOD',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS,
                                               SHINT      => '<b>Сроки</b> - контроль сроков исполнения работ по проекту.<br>' ||
                                                             '<b style="color:red">Требует внимания</b> - в проекте есть этапы, до окончания которых осталось менее ' ||
                                                             TO_CHAR(NDAYS_LEFT_LIMIT) || ' дней.<br>' ||
                                                             '<b style="color:green">В норме</b> - нет этапов с отклонениями, описанными выше.<br>' ||
                                                             '<b style="color:gray">Пусто</b> - в Системе не хватает данных для рассчёта. Убедитесь, что для этапов заданы плановые сроки окончания.');
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_COST',
                                               SCAPTION   => 'Затраты',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_COST',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS,
                                               SHINT      => '<b>Затраты</b> - контроль затрат, понесённых в ходе выполнения работ по проекту.<br>' ||
                                                             '<b style="color:red">Требует внимания</b> - в проекте есть этапы, для которых сумма фактических затрат по статьям калькуляции превысила плановую.<br>' ||
                                                             '<b style="color:green">В норме</b> - нет этапов с отклонениями, описанными выше.<br>' ||
                                                             '<b style="color:gray">Пусто</b> - в Системе не хватает данных для рассчёта. Убедитесь, что для этапов задана действующая калькуляция с указанием плановых значений по статьям, подлежащим контролю.');
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_ACT',
                                               SCAPTION   => 'Актир-е',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_ACT',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS,
                                               SHINT      => '<b>Актирование</b> - контроль актирования работ, выполненных по проекту, со стороны заказчика.<br>' ||
                                                             '<b style="color:red">Требует внимания</b> - в проекте есть этапы, в состоянии "Закрыт", но при этом в Системе отсутствует утверждённая "Расходная накладная на отпуск потребителю" для данного этапа.<br>' ||
                                                             '<b style="color:green">В норме</b> - нет этапов с отклонениями, описанными выше.<br>' ||
                                                             '<b style="color:gray">Пусто</b> - в Системе не хватает данных для рассчёта. Убедитесь, что этапы, по которым завершены работы, переведены в состояние "Закрыт".');
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCOST_READY',
                                               SCAPTION   => 'Готов (%, затраты)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCOST_READYFrom',
                                               SCOND_TO   => 'EDCOST_READYTo',
                                               BORDER     => true,
                                               BFILTER    => true);
    /* Определим дополнительные свойства - ответственный экономист */
    FIND_DOCS_PROPS_CODE(NFLAG_SMART => 1, NCOMPANY => NCOMPANY, SCODE => SDP_SECON_RESP, NRN => NECON_RESP_DP);
    /* Обходим данные */
    begin
      /* Добавляем подсказку совместимости */
      CSQL := PKG_SQL_BUILD.COMPATIBLE(SSQL => CSQL);
      /* Формируем запрос */
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => 'select *');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '  from (select D.*,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.SQLROWNUM() || ' NROW');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '          from (select P.RN NRN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.CODE SCODE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P."NAME" SNAME,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.NAME_USL SNAME_USL,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.EXPECTED_RES SEXPECTED_RES,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       PT.CODE SPRJTYPE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       EC.AGNABBR SEXT_CUST,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       GC.CODE SGOVCNTRID,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.DOC_OSN SDOC_OSN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.WRAP_STR(SVALUE => 'Contracts') || ' SLNK_UNIT_SDOC_OSN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.GET_DOC_OSN_LNK_DOCUMENT') || '(P.RN) NLNK_DOCUMENT_SDOC_OSN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       SR.CODE SSUBDIV_RESP,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       R.AGNABBR SRESPONSIBLE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       F_DOCS_PROPS_GET_STR_VALUE(:NECON_RESP_DP, ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'Projects') || ', P.RN) SECON_RESP,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P."STATE" NSTATE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.BEGPLAN DBEGPLAN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.ENDPLAN DENDPLAN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.COST_SUM_BASECURR NCOST_SUM,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       CN.INTCODE SCURNAMES,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.GET_FIN_IN') || '(P.RN) NFIN_IN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.WRAP_STR(SVALUE => 'Paynotes') || ' SLNK_UNIT_NFIN_IN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.WRAP_NUM(NVALUE => 0) || ' NLNK_DOCUMENT_NFIN_IN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.GET_FIN_OUT') || '(P.RN) NFIN_OUT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.WRAP_STR(SVALUE => 'Paynotes') || ' SLNK_UNIT_NFIN_OUT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.WRAP_NUM(NVALUE => 1) || ' NLNK_DOCUMENT_NFIN_OUT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.GET_CTRL_FIN') || '(P.RN) NCTRL_FIN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.GET_CTRL_CONTR') || '(P.RN) NCTRL_CONTR,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.GET_CTRL_COEXEC') || '(P.RN) NCTRL_COEXEC,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.GET_CTRL_PERIOD') || '(P.RN) NCTRL_PERIOD,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.GET_CTRL_COST') || '(P.RN) NCTRL_COST,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.GET_CTRL_ACT') || '(P.RN) NCTRL_ACT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.GET_COST_READY') || '(P.RN) NCOST_READY');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  from PROJECT P');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       left outer join AGNLIST EC on P.EXT_CUST = EC.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       left outer join GOVCNTRID GC on P.GOVCNTRID = GC.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       left outer join INS_DEPARTMENT SR on P.SUBDIV_RESP = SR.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       left outer join AGNLIST R on P.RESPONSIBLE = R.RN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       PRJTYPE PT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       CURNAMES CN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                 where P.PRJTYPE = PT.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and P.CURNAMES = CN.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and exists (select null from V_USERPRIV UP where UP."CATALOG" = P.CRN)');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and exists (select null from V_USERPRIV UP where UP.JUR_PERS = P.JUR_PERS and UP.UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'Projects') || ')');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                    and P.RN in (select ID from COND_BROKER_IDSMART where IDENT = :NIDENT) %ORDER_BY%) D) F');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '     where F.NROW between :NROW_FROM and :NROW_TO');
      /* Учтём сортировки */
      PKG_P8PANELS_VISUAL.TORDERS_SET_QUERY(RDATA_GRID => RDG, RORDERS => RO, SPATTERN => '%ORDER_BY%', CSQL => CSQL);
      /* Учтём фильтры */
      PKG_P8PANELS_VISUAL.TFILTERS_SET_QUERY(NIDENT     => NIDENT,
                                             NCOMPANY   => NCOMPANY,
                                             SUNIT      => 'Projects',
                                             SPROCEDURE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.COND'),
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
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 32);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 33);
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
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NCOST_READY',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 32);
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
  
  /* Сфодный график проектов */
  procedure GRAPH
  (
    COUT                    out clob                               -- График проектов
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Рег. номер организации
    DFROM                   PKG_STD.TLDATE;                        -- Дата начала всех работ
    DTO                     PKG_STD.TLDATE;                        -- Дата окончания всех работ
    DFROM_CUR               PKG_STD.TLDATE;                        -- Дата начала текущая
    DTO_CUR                 PKG_STD.TLDATE;                        -- Дата окончания текущая
    SYEAR_COL_NAME          PKG_STD.TSTRING;                       -- Наименование колонки для года
    SPRJ_GROUP_NAME         PKG_STD.TSTRING;                       -- Наименование группы для проекта
    BEXPANDED               boolean;                               -- Флаг раскрытости уровня
    RDG                     PKG_P8PANELS_VISUAL.TDATA_GRID;        -- Описание таблицы
    RDG_ROW                 PKG_P8PANELS_VISUAL.TROW;              -- Строка таблицы
  begin
    /* Определим даты начала и окончания проектов */
    select TRUNC(min(DBEGPLAN), 'mm'),
           LAST_DAY(max(DENDPLAN))
      into DFROM,
           DTO
      from (select min(P.BEGPLAN) DBEGPLAN,
                   max(P.ENDPLAN) DENDPLAN
              from PROJECT P
             where P.COMPANY = NCOMPANY
               and P.STATE in (0, 1, 4)
            union all
            select min(PS.BEGPLAN) DBEGPLAN,
                   max(PS.ENDPLAN) DENDPLAN
              from PROJECT      P,
                   PROJECTSTAGE PS
             where P.COMPANY = NCOMPANY
               and P.STATE in (0, 1, 4)
               and P.RN = PS.PRN
               and PS.STATE in (0, 1, 3)
               and PS.HRN is null);
    /* Инициализируем таблицу данных */
    RDG := PKG_P8PANELS_VISUAL.TDATA_GRID_MAKE();
    /* Формируем структуру заголовка */
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NRN',
                                               SCAPTION   => 'Рег. номер',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SJOB',
                                               SCAPTION   => 'Работы',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SRESP',
                                               SCAPTION   => 'Ответственный',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NSTATE',
                                               SCAPTION   => 'Состояние',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DFROM',
                                               SCAPTION   => 'Начало работы',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DTO',
                                               SCAPTION   => 'Окончание работы',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               BVISIBLE   => false);
    for Y in EXTRACT(year from DFROM) .. EXTRACT(year from DTO)
    loop
      SYEAR_COL_NAME := TO_CHAR(Y);
      if (Y = EXTRACT(year from sysdate)) then
        BEXPANDED := true;
      else
        BEXPANDED := false;
      end if;
      PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID  => RDG,
                                                 SNAME       => SYEAR_COL_NAME,
                                                 SCAPTION    => TO_CHAR(Y),
                                                 SDATA_TYPE  => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                                 BEXPANDABLE => true,
                                                 BEXPANDED   => BEXPANDED);
      for M in 1 .. 12
      loop
        DFROM_CUR := TO_DATE('01.' || LPAD(TO_CHAR(M), 2, '0') || '.' || TO_CHAR(Y), 'dd.mm.yyyy');
        DTO_CUR   := LAST_DAY(DFROM_CUR);
        if ((DFROM_CUR >= DFROM) and (DTO_CUR <= DTO)) then
          PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                                     SNAME      => SYEAR_COL_NAME || '_' || TO_CHAR(M),
                                                     SCAPTION   => LPAD(TO_CHAR(M), 2, '0'),
                                                     SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                                     SPARENT    => SYEAR_COL_NAME);
        end if;
      end loop;
    end loop;
    /* Обходим открытые проекты */
    for PR in (select P.*
                 from PROJECT P
                where P.COMPANY = NCOMPANY
                  and P.STATE in (0, 1, 4)
                order by P.BEGPLAN)
    loop
      /* Добвим группу для проекта */
      SPRJ_GROUP_NAME := PR.RN;
      PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_GROUP(RDATA_GRID  => RDG,
                                               SNAME       => SPRJ_GROUP_NAME,
                                               SCAPTION    => PR.CODE || ' - ' || PR.NAME,
                                               BEXPANDABLE => true,
                                               BEXPANDED   => true);
      /* Обходим этапы проекта */
      for ST in (select PS.RN NRN,
                        trim(PS.NUMB) || ' - ' || PS.NAME SJOB,
                        COALESCE(AG.AGNABBR, IND.NAME) SRESP,
                        PS.STATE NSTATE,
                        PS.BEGPLAN DFROM,
                        PS.ENDPLAN DTO
                   from PROJECTSTAGE   PS,
                        AGNLIST        AG,
                        INS_DEPARTMENT IND
                  where PS.PRN = PR.RN
                    and PS.STATE in (0, 1, 3)
                    and PS.HRN is null
                    and PS.RESPONSIBLE = AG.RN(+)
                    and PS.SUBDIV_RESP = IND.RN(+)
                  order by PS.NUMB)
      loop
        /* Инициализируем строку */
        RDG_ROW := PKG_P8PANELS_VISUAL.TROW_MAKE(SGROUP => SPRJ_GROUP_NAME);
        /* Добавляем колонки с данными */
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NRN', NVALUE => ST.NRN);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'SJOB', SVALUE => ST.SJOB);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'SRESP', SVALUE => ST.SRESP);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NSTATE', NVALUE => ST.NSTATE);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'DFROM', DVALUE => ST.DFROM);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'DTO', DVALUE => ST.DTO);
        /* Добавим строку для этапа */
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW);
      end loop;
    end loop;
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TDATA_GRID_TO_XML(RDATA_GRID => RDG, NINCLUDE_DEF => 1);
  end GRAPH;
  
  /* График по данным проектов - "Топ проблем" */
  procedure CHART_PROBLEMS
  (
    COUT                    out clob                                           -- Сериализованный график
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY();             -- Организация сеанса
    RCH                     PKG_P8PANELS_VISUAL.TCHART;                        -- График
    RCH_DS                  PKG_P8PANELS_VISUAL.TCHART_DATASET;                -- Набор данных
    RATTR_VALS              PKG_P8PANELS_VISUAL.TCHART_DATASET_ITEM_ATTR_VALS; -- Атрибуты элемента набора данных
  begin
    /* Сформируем заголовок графика */
    RCH := PKG_P8PANELS_VISUAL.TCHART_MAKE(STYPE     => PKG_P8PANELS_VISUAL.SCHART_TYPE_BAR,
                                           STITLE    => 'Топ проблем',
                                           SLGND_POS => PKG_P8PANELS_VISUAL.SCHART_LGND_POS_TOP);
    /* Сформируем набор данных */
    RCH_DS := PKG_P8PANELS_VISUAL.TCHART_DATASET_MAKE(SCAPTION => 'Кол-во проектов с проблемой');
    /* Строим список проблем по убыванию количества */
    for C in (select D.SFILTER,
                     D.SNAME,
                     D.NCOUNT
                from (select 'NCTRL_FIN' SFILTER,
                             'Финансирование' SNAME,
                             count(P.RN) NCOUNT
                        from PROJECT P
                       where P.COMPANY = NCOMPANY 
                         and PKG_P8PANELS_PROJECTS.GET_CTRL_FIN(P.RN) = 1
                         and exists (select null from V_USERPRIV UP where UP.CATALOG = P.CRN)
                         and exists (select null
                                from V_USERPRIV UP
                               where UP.JUR_PERS = P.JUR_PERS
                                 and UP.UNITCODE = 'Projects')
                      union all
                      select 'NCTRL_CONTR' SFILTER,
                             'Контрактация' SNAME,
                             count(P.RN) NCOUNT
                        from PROJECT P
                       where P.COMPANY = NCOMPANY 
                         and PKG_P8PANELS_PROJECTS.GET_CTRL_CONTR(P.RN) = 1
                         and exists (select null from V_USERPRIV UP where UP.CATALOG = P.CRN)
                         and exists (select null
                                from V_USERPRIV UP
                               where UP.JUR_PERS = P.JUR_PERS
                                 and UP.UNITCODE = 'Projects')
                      union all
                      select 'NCTRL_COEXEC' SFILTER,
                             'Соисполнение' SNAME,
                             count(P.RN) NCOUNT
                        from PROJECT P
                       where P.COMPANY = NCOMPANY 
                         and PKG_P8PANELS_PROJECTS.GET_CTRL_COEXEC(P.RN) = 1
                         and exists (select null from V_USERPRIV UP where UP.CATALOG = P.CRN)
                         and exists (select null
                                from V_USERPRIV UP
                               where UP.JUR_PERS = P.JUR_PERS
                                 and UP.UNITCODE = 'Projects')
                      union all
                      select 'NCTRL_PERIOD' SFILTER,
                             'Сроки' SNAME,
                             count(P.RN) NCOUNT
                        from PROJECT P
                       where P.COMPANY = NCOMPANY 
                         and PKG_P8PANELS_PROJECTS.GET_CTRL_PERIOD(P.RN) = 1
                         and exists (select null from V_USERPRIV UP where UP.CATALOG = P.CRN)
                         and exists (select null
                                from V_USERPRIV UP
                               where UP.JUR_PERS = P.JUR_PERS
                                 and UP.UNITCODE = 'Projects')
                      union all
                      select 'NCTRL_COST' SFILTER,
                             'Затраты' SNAME,
                             count(P.RN) NCOUNT
                        from PROJECT P
                       where P.COMPANY = NCOMPANY 
                         and PKG_P8PANELS_PROJECTS.GET_CTRL_COST(P.RN) = 1
                         and exists (select null from V_USERPRIV UP where UP.CATALOG = P.CRN)
                         and exists (select null
                                from V_USERPRIV UP
                               where UP.JUR_PERS = P.JUR_PERS
                                 and UP.UNITCODE = 'Projects')
                      union all
                      select 'NCTRL_ACT' SFILTER,
                             'Актирование' SNAME,
                             count(P.RN) NCOUNT
                        from PROJECT P
                       where P.COMPANY = NCOMPANY 
                         and PKG_P8PANELS_PROJECTS.GET_CTRL_ACT(P.RN) = 1
                         and exists (select null from V_USERPRIV UP where UP.CATALOG = P.CRN)
                         and exists (select null
                                from V_USERPRIV UP
                               where UP.JUR_PERS = P.JUR_PERS
                                 and UP.UNITCODE = 'Projects')) D
               order by D.NCOUNT desc)
    loop
      /* Если проблема выявлена */
      if (C.NCOUNT > 0) then
        /* Добавим метку для проблемы */
        PKG_P8PANELS_VISUAL.TCHART_ADD_LABEL(RCHART => RCH, SLABEL => C.SNAME);
        /* Добавим проблему в набор данных */
        PKG_P8PANELS_VISUAL.TCHART_DATASET_ITM_ATTR_VL_ADD(RATTR_VALS => RATTR_VALS,
                                                           SNAME      => 'SFILTER',
                                                           SVALUE     => C.SFILTER,
                                                           BCLEAR     => true);
        PKG_P8PANELS_VISUAL.TCHART_DATASET_ITM_ATTR_VL_ADD(RATTR_VALS => RATTR_VALS,
                                                           SNAME      => 'SFILTER_VALUE',
                                                           SVALUE     => '1');
        PKG_P8PANELS_VISUAL.TCHART_DATASET_ADD_ITEM(RDATASET => RCH_DS, NVALUE => C.NCOUNT, RATTR_VALS => RATTR_VALS);
      end if;
    end loop;
    /* Добавим набор данных в график */
    PKG_P8PANELS_VISUAL.TCHART_ADD_DATASET(RCHART => RCH, RDATASET => RCH_DS);
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TCHART_TO_XML(RCHART => RCH, NINCLUDE_DEF => 1);
  end CHART_PROBLEMS;
  
  /* График по данным проектов - "Топ заказчиков" */
  procedure CHART_CUSTOMERS
  (
    COUT                    out clob                                           -- Сериализованный график
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY();             -- Организация сеанса
    RCH                     PKG_P8PANELS_VISUAL.TCHART;                        -- График
    RCH_DS                  PKG_P8PANELS_VISUAL.TCHART_DATASET;                -- Набор данных
    RATTR_VALS              PKG_P8PANELS_VISUAL.TCHART_DATASET_ITEM_ATTR_VALS; -- Атрибуты элемента набора данных
  begin
    /* Сформируем заголовок графика */
    RCH := PKG_P8PANELS_VISUAL.TCHART_MAKE(STYPE     => PKG_P8PANELS_VISUAL.SCHART_TYPE_PIE,
                                           STITLE    => 'Топ заказчиков',
                                           SLGND_POS => PKG_P8PANELS_VISUAL.SCHART_LGND_POS_RIGHT);
    /* Сформируем набор данных */
    RCH_DS := PKG_P8PANELS_VISUAL.TCHART_DATASET_MAKE(SCAPTION => 'Стоимость проектов');
    /* Обходим проекты, сгруппированные по внешним заказчикам */
    for C in (select D.SEXT_CUST,
                     D.NSUM
                from (select EC.AGNABBR SEXT_CUST,
                             sum(P.COST_SUM_BASECURR) NSUM
                        from PROJECT P,
                             AGNLIST EC
                       where P.COMPANY = NCOMPANY
                         and P.EXT_CUST = EC.RN
                       group by EC.AGNABBR
                       order by 2 desc) D
               where ROWNUM <= 5)
    loop
      /* Добавим метку для контрагента */
      PKG_P8PANELS_VISUAL.TCHART_ADD_LABEL(RCHART => RCH, SLABEL => C.SEXT_CUST);
      /* Добавим контрагента в набор данных */
      PKG_P8PANELS_VISUAL.TCHART_DATASET_ITM_ATTR_VL_ADD(RATTR_VALS => RATTR_VALS,
                                                         SNAME      => 'SFILTER',
                                                         SVALUE     => 'SEXT_CUST',
                                                         BCLEAR     => true);
      PKG_P8PANELS_VISUAL.TCHART_DATASET_ITM_ATTR_VL_ADD(RATTR_VALS => RATTR_VALS,
                                                         SNAME      => 'SFILTER_VALUE',
                                                         SVALUE     => C.SEXT_CUST);
      PKG_P8PANELS_VISUAL.TCHART_DATASET_ADD_ITEM(RDATASET => RCH_DS, NVALUE => C.NSUM, RATTR_VALS => RATTR_VALS);
    end loop;
    /* Добавим набор данных в график */
    PKG_P8PANELS_VISUAL.TCHART_ADD_DATASET(RCHART => RCH, RDATASET => RCH_DS);
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TCHART_TO_XML(RCHART => RCH, NINCLUDE_DEF => 1);
  end CHART_CUSTOMERS;
  
  /* График по данным проектов - "Затраты на проекты" */
  procedure CHART_FCCOSTNOTES
  (
    COUT                    out clob                                           -- Сериализованный график
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY();             -- Организация сеанса
    RCH                     PKG_P8PANELS_VISUAL.TCHART;                        -- График
    RCH_DS                  PKG_P8PANELS_VISUAL.TCHART_DATASET;                -- Набор данных
    RATTR_VALS              PKG_P8PANELS_VISUAL.TCHART_DATASET_ITEM_ATTR_VALS; -- Атрибуты элемента набора данных
    NYEAR                   PKG_STD.TNUMBER;                                   -- Текущий год
    NSUM                    PKG_STD.TNUMBER;                                   -- Сумма затрат в текущем месяце
  begin
    NYEAR := TO_NUMBER(TO_CHAR(sysdate, 'yyyy'));
    /* Сформируем заголовок графика */
    RCH := PKG_P8PANELS_VISUAL.TCHART_MAKE(STYPE     => PKG_P8PANELS_VISUAL.SCHART_TYPE_LINE,
                                           STITLE    => 'Затраты на проекты в ' || TO_CHAR(NYEAR) || ' году',
                                           SLGND_POS => PKG_P8PANELS_VISUAL.SCHART_LGND_POS_TOP);
    /* Сформируем набор данных */
    RCH_DS := PKG_P8PANELS_VISUAL.TCHART_DATASET_MAKE(SCAPTION => 'Сумма затрат (тыс. руб.)');
    /* Обходим месяцы года */
    for I in 1 .. 12
    loop
      /* Суммируем затраты этого месяца, отнесённые на проекты */
      select COALESCE(sum(CN.COST_BSUM) / 1000, 0)
        into NSUM
        from FCCOSTNOTES CN
       where CN.COMPANY = NCOMPANY
         and TO_NUMBER(TO_CHAR(CN.COST_DATE, 'mm')) = I
         and TO_NUMBER(TO_CHAR(CN.COST_DATE, 'yyyy')) = NYEAR
         and exists (select null from V_USERPRIV UP where UP.CATALOG = CN.CRN)
         and CN.PROD_ORDER in (select PS.FACEACC
                                 from PROJECTSTAGE PS
                                where PS.COMPANY = CN.COMPANY
                                  and exists (select null from V_USERPRIV UP where UP.CATALOG = PS.CRN)
                                  and exists (select null
                                         from V_USERPRIV UP
                                        where UP.JUR_PERS = PS.JUR_PERS
                                          and UP.UNITCODE = 'Projects'));
      /* Добавим метку для месяца */
      PKG_P8PANELS_VISUAL.TCHART_ADD_LABEL(RCHART => RCH, SLABEL => F_GET_MONTH(NVALUE => I));
      /* Добавим месяц в набор данных */
      PKG_P8PANELS_VISUAL.TCHART_DATASET_ITM_ATTR_VL_ADD(RATTR_VALS => RATTR_VALS,
                                                         SNAME      => 'SUNITCODE',
                                                         SVALUE     => 'CostNotes',
                                                         BCLEAR     => true);
      PKG_P8PANELS_VISUAL.TCHART_DATASET_ITM_ATTR_VL_ADD(RATTR_VALS => RATTR_VALS, SNAME => 'NYEAR', SVALUE => TO_CHAR(NYEAR));
      PKG_P8PANELS_VISUAL.TCHART_DATASET_ITM_ATTR_VL_ADD(RATTR_VALS => RATTR_VALS, SNAME => 'NMONTH', SVALUE => TO_CHAR(I));
      PKG_P8PANELS_VISUAL.TCHART_DATASET_ADD_ITEM(RDATASET => RCH_DS, NVALUE => NSUM, RATTR_VALS => RATTR_VALS);
    end loop;
    /* Добавим набор данных в график */
    PKG_P8PANELS_VISUAL.TCHART_ADD_DATASET(RCHART => RCH, RDATASET => RCH_DS);
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TCHART_TO_XML(RCHART => RCH, NINCLUDE_DEF => 1);
  end CHART_FCCOSTNOTES;
  
  /* График по данным проектов - "Затраты на проекты" (подбор записей журнала затрат по точке графика) */
  procedure CHART_FCCOSTNOTES_SELECT_COST
  (
    NYEAR                   in number,                             -- Год
    NMONTH                  in number,                             -- Месяц
    NIDENT                  out number                             -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
    NSELECTLIST             PKG_STD.TREF;                          -- Рег. номер добавленной записи буфера подобранных
  begin
    /* Подберём записи журнала затрат */
    for C in (select CN.COMPANY,
                     CN.RN
                from FCCOSTNOTES CN
               where CN.COMPANY = NCOMPANY
                 and TO_NUMBER(TO_CHAR(CN.COST_DATE, 'mm')) = NMONTH
                 and TO_NUMBER(TO_CHAR(CN.COST_DATE, 'yyyy')) = NYEAR
                 and exists
               (select null from V_USERPRIV UP where UP.CATALOG = CN.CRN)
                 and CN.PROD_ORDER in (select PS.FACEACC
                                         from PROJECTSTAGE PS
                                        where PS.COMPANY = CN.COMPANY
                                          and exists (select null from V_USERPRIV UP where UP.CATALOG = PS.CRN)
                                          and exists (select null
                                                 from V_USERPRIV UP
                                                where UP.JUR_PERS = PS.JUR_PERS
                                                  and UP.UNITCODE = 'Projects')))
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
  end CHART_FCCOSTNOTES_SELECT_COST;
  
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
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_FIN') || '(RN) = :EDCTRL_FIN');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_FIN',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_FIN'));
    end if;
    /* Контроль контрактации */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_CONTR') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_CONTR') || '(RN) = :EDCTRL_CONTR');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_CONTR',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_CONTR'));
    end if;
    /* Контроль соисполнения */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_COEXEC') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_COEXEC') || '(RN) = :EDCTRL_COEXEC');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_COEXEC',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_COEXEC'));
    end if;
    /* Контроль сроков */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_PERIOD') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_PERIOD') || '(RN) = :EDCTRL_PERIOD');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_PERIOD',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_PERIOD'));
    end if;
    /* Контроль затрат */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_COST') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_COST') || '(RN) = :EDCTRL_COST');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_COST',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_COST'));
    end if;
    /* Контроль актирования */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_ACT') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_ACT') || '(RN) = :EDCTRL_ACT');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_ACT',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_ACT'));
    end if;
    /* Готовность (%, по затратам) */
    if ((PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCOST_READYFrom') = 1) and
       (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCOST_READYTo') = 0)) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_GET_COST_READY') || '(RN) >= :EDCOST_READYFrom');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCOST_READYFrom',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCOST_READYFrom'));
    end if;
    if ((PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCOST_READYTo') = 1) and
       (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCOST_READYFrom') = 0)) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_GET_COST_READY') || '(RN) <= :EDCOST_READYTo');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCOST_READYTo',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCOST_READYTo'));
    end if;
    if ((PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCOST_READYFrom') = 1) and
       (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCOST_READYTo') = 1)) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_GET_COST_READY') || '(RN) between :EDCOST_READYFrom and :EDCOST_READYTo');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCOST_READYFrom',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCOST_READYFrom'));
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCOST_READYTo',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCOST_READYTo'));
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
                         and exists (select null from V_USERPRIV UP where UP.CATALOG = PS.CRN)
                         and exists (select null
                                from V_USERPRIV UP
                               where UP.JUR_PERS = PS.JUR_PERS
                                 and UP.UNITCODE = 'Projects')
                         and ((NRN is null) or ((NRN is not null) and (PS.RN = NRN)))
                         and ((NPRN is null) or ((NPRN is not null) and (PS.PRN = NPRN))))
                 and exists (select /*+ INDEX(UP I_USERPRIV_CATALOG_ROLEID) */
                       null
                        from USERPRIV UP
                       where UP.CATALOG = PN.CRN
                         and UP.ROLEID in (select /*+ INDEX(UR I_USERROLES_AUTHID_FK) */
                                            UR.ROLEID
                                             from USERROLES UR
                                            where UR.AUTHID = UTILIZER)
                      union all
                      select /*+ INDEX(UP I_USERPRIV_CATALOG_AUTHID) */
                       null
                        from USERPRIV UP
                       where UP.CATALOG = PN.CRN
                         and UP.AUTHID = UTILIZER)
                 and exists (select /*+ INDEX(UP I_USERPRIV_JUR_PERS_ROLEID) */
                       null
                        from USERPRIV UP
                       where UP.JUR_PERS = PN.JUR_PERS
                         and UP.UNITCODE = 'PayNotes'
                         and UP.ROLEID in (select /*+ INDEX(UR I_USERROLES_AUTHID_FK) */
                                            UR.ROLEID
                                             from USERROLES UR
                                            where UR.AUTHID = UTILIZER)
                      union all
                      select /*+ INDEX(UP I_USERPRIV_JUR_PERS_AUTHID) */
                       null
                        from USERPRIV UP
                       where UP.JUR_PERS = PN.JUR_PERS
                         and UP.UNITCODE = 'PayNotes'
                         and UP.AUTHID = UTILIZER))
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
    select COALESCE(sum(PN.PAY_SUM * (PN.CURR_RATE_BASE / PN.CURR_RATE)), 0)
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
    NRN                     in number             -- Рег. номер этапа проекта
  ) return                  number                -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  is
    NCONTR_CTRL             PKG_STD.TNUMBER;      -- Состояние соисполнителя этапа
    NCNT_CONTR              PKG_STD.TNUMBER := 0; -- Количество соисполнителей этапа
    NCNT_NULL               PKG_STD.TNUMBER := 0; -- Количество "безконтрольных" соисполнителей этапа
  begin
    /* Обходим соисполнителей этапа */
    for C in (select PSPF.RN from PROJECTSTAGEPF PSPF where PSPF.PRN = NRN)
    loop
      /* Увеличим счётчик соисполнителей */
      NCNT_CONTR := NCNT_CONTR + 1;
      /* Получим состояние соисполнителя */
      NCONTR_CTRL := STAGE_CONTRACTS_GET_CTRL_FIN(NPROJECTSTAGEPF => C.RN);
      /* Подсчитаем количество "безконтрольных" */
      if (NCONTR_CTRL is null) then
        NCNT_NULL := NCNT_NULL + 1;
      end if;
      /* Если у соисполнителя есть отклонение - оно есть и у этапа */
      if (NCONTR_CTRL = 1) then
        return 1;
      end if;
    end loop;
    /* Если ни один соисполнитель не подлежит контролю - то и состояние жтапа тоже */
    if (NCNT_NULL = NCNT_CONTR) then
      return null;
    end if;
    /* Если мы здесь - отклонений нет */
    if (NCNT_CONTR > 0) then
      return 0;
    else
      /* Нет соисполнителей и нет контроля */
      return null;
    end if;
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
    NRN                     in number             -- Рег. номер этапа проекта
  ) return                  number                -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  is
    NCONTR_CTRL             PKG_STD.TNUMBER;      -- Состояние соисполнителя этапа
    NCNT_CONTR              PKG_STD.TNUMBER := 0; -- Количество соисполнителей этапа
    NCNT_NULL               PKG_STD.TNUMBER := 0; -- Количество "безконтрольных" соисполнителей этапа
  begin
    /* Обходим соисполнителей этапа */
    for C in (select PSPF.RN from PROJECTSTAGEPF PSPF where PSPF.PRN = NRN)
    loop
      /* Увеличим счётчик соисполнителей */
      NCNT_CONTR := NCNT_CONTR + 1;
      /* Получим состояние соисполнителя */
      NCONTR_CTRL := STAGE_CONTRACTS_GET_CTRL_COEXE(NPROJECTSTAGEPF => C.RN);
      /* Подсчитаем количество "безконтрольных" */
      if (NCONTR_CTRL is null) then
        NCNT_NULL := NCNT_NULL + 1;
      end if;
      /* Если у соисполнителя есть отклонение - оно есть и у этапа */
      if (NCONTR_CTRL = 1) then
        return 1;
      end if;
    end loop;
    /* Если ни один соисполнитель не подлежит контролю - то и состояние жтапа тоже */
    if (NCNT_NULL = NCNT_CONTR) then
      return null;
    end if;
    /* Если мы здесь - отклонений нет */
    if (NCNT_CONTR > 0) then
      return 0;
    else
      /* Нет соисполнителей и нет контроля */
      return null;
    end if;
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
    NRN                     in number             -- Рег. номер этапа проекта
  ) return                  number                -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  is
    RPS                     PROJECTSTAGE%rowtype; -- Запись этапа проекта
    NTRANSINVCUST           PKG_STD.TREF;         -- Рег. номер РНОПотр, закрывающей этап
  begin
    /* Читаем запись этапа */
    RPS := STAGES_GET(NRN => NRN);
    /* Если этап не в состоянии "Закрыт", то нечего контролировать */
    if (RPS.STATE <> 2) then
      return null;
    end if;
    /* Проверяем наличие подписанного аката */
    begin
      select T.RN
        into NTRANSINVCUST
        from TRANSINVCUST T
       where T.FACEACC = RPS.FACEACCCUST
         and T.STATUS = 1
         and exists (select null
                from TRINVCUSTCLC TC
               where TC.PRN in (select TS.RN from TRANSINVCUSTSPECS TS where TS.PRN = T.RN)
                 and TC.FACEACCOUNT = RPS.FACEACC);
    exception
      when NO_DATA_FOUND then
        null;
    end;
    /* Если мы здесь, значит этап "Закрыт", если нет закрывающего акта с заказчиком - это отклонение */
    if (NTRANSINVCUST is null) then
      return 1;
    end if;
    /* Все проверки пройдены - отклонений нет */
    return 0;
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
    NRN                     in number,  -- Рег. номер этапа проекта
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
    
  /* Подбор записей расходных накладных на отпуск потребителям этапа проекта */
  procedure STAGES_SELECT_SUMM_REALIZ
  (
    NRN                     in number,            -- Рег. номер этапа проекта
    NIDENT                  out number            -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  )
  is
    RSTG                    PROJECTSTAGE%rowtype; -- Запись этапа
    NSELECTLIST             PKG_STD.TREF;         -- Рег. номер добавленной записи буфера подобранных
  begin
    /* Читаем этап */
    RSTG := STAGES_GET(NRN => NRN);
    /* Подберём расходные накладные на отпуск потребителям */
    for C in (select T.COMPANY,
                     T.RN
                from TRANSINVCUST T
               where T.STATUS = 1
                 and T.COMPANY = RSTG.COMPANY
                 and T.FACEACC = RSTG.FACEACCCUST
                 and exists (select TC.RN
                        from TRANSINVCUSTSPECS TS,
                             TRINVCUSTCLC      TC
                       where TS.PRN = T.RN
                         and TC.PRN = TS.RN
                         and TC.FACEACCOUNT = RSTG.FACEACC
                         and exists (select null from V_USERPRIV UP where UP.CATALOG = RSTG.CRN)
                         and exists (select null
                                from V_USERPRIV UP
                               where UP.JUR_PERS = RSTG.JUR_PERS
                                 and UP.UNITCODE = 'Projects'))
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
                         and UP.AUTHID = UTILIZER))
    loop
      /* Сформируем идентификатор буфера */
      if (NIDENT is null) then
        NIDENT := GEN_IDENT();
      end if;
      /* Добавим подобранное в список отмеченных записей */
      P_SELECTLIST_BASE_INSERT(NIDENT       => NIDENT,
                               NCOMPANY     => C.COMPANY,
                               NDOCUMENT    => C.RN,
                               SUNITCODE    => 'GoodsTransInvoicesToConsumers',
                               SACTIONCODE  => null,
                               NCRN         => null,
                               NDOCUMENT1   => null,
                               SUNITCODE1   => null,
                               SACTIONCODE1 => null,
                               NRN          => NSELECTLIST);
    end loop;
  end STAGES_SELECT_SUMM_REALIZ;
  
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
    
  /* Получение % готовности этапа проекта (по затратам) */
  function STAGES_GET_COST_READY
  (
    NRN                     in number             -- Рег. номер этапа проекта
  ) return                  number                -- % готовности
  is
    RSTG                    PROJECTSTAGE%rowtype; -- Запись этапа
    NFPDARTCL_SELF_COST     PKG_STD.TREF;         -- Рег. номер статьи себестоимости
    NCOST_FACT              PKG_STD.TNUMBER;      -- Сумма фактических затрат
    RSELF_COST_PLAN         TSTAGE_ARTS;          -- Плановая себестоимость
    NRES                    PKG_STD.TNUMBER := 0; -- Буфер для результата
  begin
    /* Читаем этап */
    RSTG := STAGES_GET(NRN => NRN);
    /* Определим рег. номер статьи калькуляции для учёта себестоимости */
    FIND_FPDARTCL_CODE(NFLAG_SMART => 1,
                       NCOMPANY    => RSTG.COMPANY,
                       SCODE       => SFPDARTCL_SELF_COST,
                       NRN         => NFPDARTCL_SELF_COST);
    /* Опеределим сумму фактических затрат */
    NCOST_FACT := STAGES_GET_COST_FACT(NRN => RSTG.RN);
    /* Определим плановую себестоимость */
    STAGE_ARTS_GET(NSTAGE => RSTG.RN, NFPDARTCL => NFPDARTCL_SELF_COST, RSTAGE_ARTS => RSELF_COST_PLAN);
    /* Если есть и фактические затраты и найдена плановая себестоимость */
    if ((NCOST_FACT > 0) and (RSELF_COST_PLAN.COUNT = 1) and (RSELF_COST_PLAN(RSELF_COST_PLAN.LAST).NPLAN <> 0)) then
      /* Отношение фактических затрат к плановой себестоимость - искомый % готовности */
      NRES := ROUND(NCOST_FACT / RSELF_COST_PLAN(RSELF_COST_PLAN.LAST).NPLAN * 100, 0);
      /* Если затраты превысили себестоимость, то % может быть > 100, но это бессмысленно, откорректируем ситуацию */
      if (NRES > 100) then
        NRES := 100;
      end if;
    end if;
    /* Вернём рассчитанное */
    return NRES;
  end STAGES_GET_COST_READY;
  
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
                                               SCAPTION   => 'Фин-е (исх.)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_FIN',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS,
                                               SHINT      => '<b>Финансирование (исходящее)</b> - контроль оплаты счетов, выставленных соисполнителями по этапу.<br>' ||
                                                             '<b style="color:red">Требует внимания</b> - к этапу привязаны договоры соисполнителей, для которых не все выставленные соисполнителями счета оплачены.<br>' ||
                                                             '<b style="color:green">В норме</b> - нет договоров соисполнения с отклонениями, описанными выше.<br>' ||
                                                             '<b style="color:gray">Пусто</b> - в Системе не хватает данных для рассчёта. Убедитесь, что для этапов задана привязка к договорам с соисполнителями.');
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_CONTR',
                                               SCAPTION   => 'Контр-я',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_CONTR',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS,
                                               SHINT      => '<b>Контрактация</b> - контроль суммы договоров, заключеных с соисполнителями в рамках этапа.<br>' ||
                                                             '<b style="color:red">Требует внимания</b> - сумма договоров с соисполнителями, привязанных к этапу, превышает заложенные в калькуляцию плановые показатели по сответствующим статьям.<br>' ||
                                                             '<b style="color:green">В норме</b> - нет описанных выше отклонений.<br>' ||
                                                             '<b style="color:gray">Пусто</b> - в Системе не хватает данных для рассчёта. Убедитесь, что для этапа задана калькуляция и для контрагентских статей указаны плановые показатели.');
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_COEXEC',
                                               SCAPTION   => 'Соисп-е',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_COEXEC',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS,
                                               SHINT      => '<b>Соисполнение</b> - контроль исполнения обязательств по договорам, заключеным с соисполнителями в рамках этапа.<br>' ||
                                                             '<b style="color:red">Требует внимания</b> - до окончания этапа осталось менее ' ||
                                                             TO_CHAR(NDAYS_LEFT_LIMIT) ||
                                                             ' дней, при этом зафиксирован положительный остаток к поставке/актированию по привязанным к нему договорам соисполнителей.<br>' ||
                                                             '<b style="color:green">В норме</b> - нет описанных выше отклонений.<br>' ||
                                                             '<b style="color:gray">Пусто</b> - в Системе не хватает данных для рассчёта. Убедитесь, что для этапа задана привязка к договорам с соисполнителями и плановый срок окончания.');
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
                                               RCOL_VALS  => RCOL_VALS,
                                               SHINT      => '<b>Сроки</b> - контроль сроков исполнения работ по этапу.<br>' ||
                                                             '<b style="color:red">Требует внимания</b> - до окончания этапа осталось менее ' ||
                                                             TO_CHAR(NDAYS_LEFT_LIMIT) || ' дней.<br>' ||
                                                             '<b style="color:green">В норме</b> - нет описанных выше отклонений.<br>' ||
                                                             '<b style="color:gray">Пусто</b> - в Системе не хватает данных для рассчёта. Убедитесь, что для этапа задан плановый срок окончания.');
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
                                               SNAME      => 'SLNK_UNIT_NSUMM_REALIZ',
                                               SCAPTION   => 'Сумма реализации (код раздела ссылки)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NLNK_DOCUMENT_NSUMM_REALIZ',
                                               SCAPTION   => 'Сумма реализации (документ ссылки)',
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
                                               RCOL_VALS  => RCOL_VALS,
                                               SHINT      => '<b>Затраты</b> - контроль затрат, понесённых в ходе выполнения работ по этапу.<br>' ||
                                                             '<b style="color:red">Требует внимания</b> - сумма фактических затрат этапа по некоторым статьям калькуляции превысила плановую.<br>' ||
                                                             '<b style="color:green">В норме</b> - нет описанных выше отклонений.<br>' ||
                                                             '<b style="color:gray">Пусто</b> - в Системе не хватает данных для рассчёта. Убедитесь, что для этапа задана действующая калькуляция с указанием плановых значений по статьям, подлежащим контролю.');
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_ACT',
                                               SCAPTION   => 'Актир-е',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_ACT',
                                               BORDER     => true,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS,
                                               SHINT      => '<b>Актирование</b> - контроль актирования работ, выполненных по этапу, со стороны заказчика.<br>' ||
                                                             '<b style="color:red">Требует внимания</b> - этап в состоянии "Закрыт", но при этом в Системе отсутствует утверждённая "Расходная накладная на отпуск потребителю" для данного этапа.<br>' ||
                                                             '<b style="color:green">В норме</b> - нет описанных выше отклонений.<br>' ||
                                                             '<b style="color:gray">Пусто</b> - в Системе не хватает данных для рассчёта. Убедитесь, что этап, если работы по нему завершены, переведен в состояние "Закрыт".');
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCOST_READY',
                                               SCAPTION   => 'Готов (%, затраты)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCOST_READYFrom',
                                               SCOND_TO   => 'EDCOST_READYTo',
                                               BORDER     => true,
                                               BFILTER    => true);
    /* Обходим данные */
    begin
      /* Добавляем подсказку совместимости */
      CSQL := PKG_SQL_BUILD.COMPATIBLE(SSQL => CSQL);
      /* Формируем запрос */
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => 'select *');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '  from (select D.*,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.SQLROWNUM() || ' NROW');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '          from (select PS.RN NRN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       PS.NUMB SNUMB,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       PS."NAME" SNAME,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       PS.EXPECTED_RES SEXPECTED_RES,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       FAC.NUMB SFACEACC,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       PS."STATE" NSTATE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       PS.BEGPLAN DBEGPLAN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       PS.ENDPLAN DENDPLAN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       PS.COST_SUM_BASECURR NCOST_SUM,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       CN.INTCODE SCURNAMES,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_GET_FIN_IN') || '(PS.RN) NFIN_IN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.WRAP_STR(SVALUE => 'Paynotes') || ' SLNK_UNIT_NFIN_IN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.WRAP_NUM(NVALUE => 0) || ' NLNK_DOCUMENT_NFIN_IN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_GET_FIN_OUT') || '(PS.RN) NFIN_OUT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.WRAP_STR(SVALUE => 'Paynotes') || ' SLNK_UNIT_NFIN_OUT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.WRAP_NUM(NVALUE => 1) || ' NLNK_DOCUMENT_NFIN_OUT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_FIN') || '(PS.RN) NCTRL_FIN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_CONTR') || '(PS.RN) NCTRL_CONTR,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_COEXEC') || '(PS.RN) NCTRL_COEXEC,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_GET_DAYS_LEFT') || '(PS.RN) NDAYS_LEFT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_PERIOD') || '(PS.RN) NCTRL_PERIOD,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_GET_COST_FACT') || '(PS.RN) NCOST_FACT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.WRAP_STR(SVALUE => 'CostNotes') || ' SLNK_UNIT_NCOST_FACT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.WRAP_NUM(NVALUE => 1) || ' NLNK_DOCUMENT_NCOST_FACT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_GET_SUMM_REALIZ') || '(PS.RN, :NFPDARTCL_REALIZ) NSUMM_REALIZ,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.WRAP_STR(SVALUE => 'GoodsTransInvoicesToConsumers') || ' SLNK_UNIT_NSUMM_REALIZ,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.WRAP_NUM(NVALUE => 1) || ' NLNK_DOCUMENT_NSUMM_REALIZ,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_COST') || '(PS.RN) NCTRL_COST,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_GET_CTRL_ACT') || '(PS.RN) NCTRL_ACT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_GET_COST_READY') || '(PS.RN) NCOST_READY');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  from PROJECTSTAGE PS');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       left outer join FACEACC FAC on PS.FACEACC = FAC.RN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       PROJECT P,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       CURNAMES CN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                 where PS.PRN = P.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and P.CURNAMES = CN.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and exists (select null from V_USERPRIV UP where UP."CATALOG" = PS.CRN)');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and exists (select null from V_USERPRIV UP where UP.JUR_PERS = PS.JUR_PERS and UP.UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'Projects') || ')');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and PS.RN in (select ID from COND_BROKER_IDSMART where IDENT = :NIDENT) %ORDER_BY%) D) F');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => ' where F.NROW between :NROW_FROM and :NROW_TO');
      /* Учтём сортировки */
      PKG_P8PANELS_VISUAL.TORDERS_SET_QUERY(RDATA_GRID => RDG, RORDERS => RO, SPATTERN => '%ORDER_BY%', CSQL => CSQL);
      /* Учтём фильтры */
      PKG_P8PANELS_VISUAL.TFILTERS_SET_QUERY(NIDENT     => NIDENT,
                                             NCOMPANY   => NCOMPANY,
                                             NPARENT    => NPRN,
                                             SUNIT      => 'ProjectsStages',
                                             SPROCEDURE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGES_COND'),
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
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 26);
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
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SLNK_UNIT_NSUMM_REALIZ',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 26);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NLNK_DOCUMENT_NSUMM_REALIZ',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 27);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NSUMM_INCOME', NVALUE => NSUMM_INCOME);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NINCOME_PRC', NVALUE => NINCOME_PRC);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NCTRL_COST',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 28);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NCTRL_ACT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 29);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NCOST_READY',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 30);
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
                 and ((NFINFLOW_TYPE is null) or ((NFINFLOW_TYPE is not null) and (FT.TYPE = NFINFLOW_TYPE)))
                 and exists (select null from V_USERPRIV UP where UP.CATALOG = PS.CRN)
                 and exists (select null from V_USERPRIV UP where UP.JUR_PERS = PS.JUR_PERS and UP.UNITCODE = 'Projects')
                 and exists (select null from V_USERPRIV UP where UP.CATALOG = CN.CRN))
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
                 and ((NFPDARTCL is null) or ((NFPDARTCL is not null) and (EPF.COST_ARTICLE = NFPDARTCL)))
                 and exists (select null from V_USERPRIV UP where UP.CATALOG = EPF.CRN)
                 and exists (select null from V_USERPRIV UP where UP.JUR_PERS = EPF.JUR_PERS and UP.UNITCODE = 'Projects')
                 and exists (select null from V_USERPRIV UP where UP.CATALOG = S.CRN)
                 and exists (select null from V_USERPRIV UP where UP.JUR_PERS = S.JUR_PERS and UP.UNITCODE = 'Contracts'))
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
      RSTG := STAGES_GET(NRN => NSTAGE);
    exception
      when others then
        null;
    end;
    /* Если считано успешно - будем искать данные */
    if (RSTG.RN is not null) then
      /* Определим рег. номер доп. свойства для налоговой группы проекта */
      FIND_DOCS_PROPS_CODE(NFLAG_SMART => 1,
                           NCOMPANY    => RSTG.COMPANY,
                           SCODE       => SDP_STAX_GROUP,
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
    NFPDARTCL               in number := null,    -- Рег. номер статьи затрат (null - брать все)
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
      FIND_DOCS_PROPS_CODE(NFLAG_SMART => 1, NCOMPANY => RSTG.COMPANY, SCODE => SDP_SCTL_COST, NRN => NCTL_COST_DP);
    end if;
    /* Определим дополнительные свойства - контроль контрактации */
    if (NINC_CONTR = 1) then
      FIND_DOCS_PROPS_CODE(NFLAG_SMART => 1, NCOMPANY => RSTG.COMPANY, SCODE => SDP_SCTL_CONTR, NRN => NCTL_CONTR_DP);
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
                 and ((NFPDARTCL is null) or ((NFPDARTCL is not null) and (A.RN = NFPDARTCL)))
                 and exists (select null from V_USERPRIV UP where UP.CATALOG = PS.CRN)
                 and exists (select null from V_USERPRIV UP where UP.JUR_PERS = PS.JUR_PERS and UP.UNITCODE = 'Projects')
                 and exists (select null from V_USERPRIV UP where UP.CATALOG = CS.CRN)
                 and exists (select null from V_USERPRIV UP where UP.JUR_PERS = CS.JUR_PERS and UP.UNITCODE = 'Contracts')
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

  /* Считывание записи соисполнителя этапа проекта */
  function STAGE_CONTRACTS_GET_PSPF
  (
    NPROJECTSTAGEPF         in number               -- Рег. номер соисполнителя этапа проекта
  ) return                  PROJECTSTAGEPF%rowtype  -- Запись соисполнителя этапа проекта
  is
    RRES                    PROJECTSTAGEPF%rowtype; -- Буфер для результата
  begin
    select PS.* into RRES from PROJECTSTAGEPF PS where PS.RN = NPROJECTSTAGEPF;
    return RRES;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0, NDOCUMENT => NPROJECTSTAGEPF, SUNIT_TABLE => 'PROJECTSTAGEPF');
  end STAGE_CONTRACTS_GET_PSPF;
  
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
    /* Контроль финансирования */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_FIN') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGE_CONTRACTS_GET_CTRL_FIN') || '(RN) = :EDCTRL_FIN');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_FIN',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_FIN'));
    end if;
    /* Контроль соисполнения */
    if (PKG_COND_BROKER.CONDITION_EXISTS(SCONDITION_NAME => 'EDCTRL_COEXEC') = 1) then
      PKG_COND_BROKER.ADD_CLAUSE(SCLAUSE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGE_CONTRACTS_GET_CTRL_COEXE') || '(RN) = :EDCTRL_COEXEC');
      PKG_COND_BROKER.BIND_VARIABLE(SVARIABLE_NAME => 'EDCTRL_COEXEC',
                                    NVALUE         => PKG_COND_BROKER.GET_CONDITION_NUM(SCONDITION_NAME => 'EDCTRL_COEXEC'));
    end if;
  end STAGE_CONTRACTS_COND;

  /* Подбор входящих счетов на оплату соисполнителя этапа проекта */
  procedure STAGE_CONTRACTS_SELECT_PAY_IN
  (
    NPROJECTSTAGEPF         in number,    -- Рег. номер соисполнителя этапа проекта
    NIDENT                  out number    -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  )
  is
    NSELECTLIST             PKG_STD.TREF; -- Рег. номер добавленной записи буфера подобранных
  begin
    /* Подберём счета */
    for C in (select PAI.COMPANY,
                     PAI.RN
                from PROJECTSTAGEPF PSPF,
                     PROJECTSTAGE   PS,
                     PAYACCIN       PAI
               where PSPF.RN = NPROJECTSTAGEPF
                 and PSPF.PRN = PS.RN
                 and PSPF.FACEACC = PAI.FACEACC
                 and PAI.DOC_STATE = 1
                 and exists (select null
                        from PAYACCINSPCLC PCLC
                       where PCLC.PRN in (select PAIS.RN from PAYACCINSPEC PAIS where PAIS.PRN = PAI.RN)
                         and PCLC.FACEACCOUNT = PS.FACEACC)
                 and exists (select null from V_USERPRIV UP where UP.CATALOG = PSPF.CRN)
                 and exists (select null
                        from V_USERPRIV UP
                       where UP.JUR_PERS = PSPF.JUR_PERS
                         and UP.UNITCODE = 'Projects')
                 and exists (select null from V_USERPRIV UP where UP.CATALOG = PAI.CRN))
    loop
      /* Сформируем идентификатор буфера */
      if (NIDENT is null) then
        NIDENT := GEN_IDENT();
      end if;
      /* Добавим подобранное в список отмеченных записей */
      P_SELECTLIST_BASE_INSERT(NIDENT       => NIDENT,
                               NCOMPANY     => C.COMPANY,
                               NDOCUMENT    => C.RN,
                               SUNITCODE    => 'PaymentAccountsIn',
                               SACTIONCODE  => null,
                               NCRN         => null,
                               NDOCUMENT1   => null,
                               SUNITCODE1   => null,
                               SACTIONCODE1 => null,
                               NRN          => NSELECTLIST);
    end loop;
  end STAGE_CONTRACTS_SELECT_PAY_IN;
  
  /* Подбор приходных накладных соисполнителя этапа проекта */
  procedure STAGE_CONTRACTS_SELECT_ININV
  (
    NPROJECTSTAGEPF         in number,    -- Рег. номер соисполнителя этапа проекта
    NIDENT                  out number    -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  )
  is
    NSELECTLIST             PKG_STD.TREF; -- Рег. номер добавленной записи буфера подобранных
  begin
    /* Подберём счета */
    for C in (select I.COMPANY,
                     I.RN
                from PROJECTSTAGEPF PSPF,
                     PROJECTSTAGE   PS,
                     ININVOICES     I
               where PSPF.RN = NPROJECTSTAGEPF
                 and PSPF.PRN = PS.RN
                 and PSPF.FACEACC = I.FACEACC
                 and I.STATUS = 2
                 and exists (select null
                        from ININVOICESSPC ICLC
                       where ICLC.PRN in (select ISP.RN from ININVOICESSPECS ISP where ISP.PRN = I.RN)
                         and ICLC.FACEACCOUNT = PS.FACEACC)
                 and exists (select null from V_USERPRIV UP where UP.CATALOG = PSPF.CRN)
                 and exists (select null
                        from V_USERPRIV UP
                       where UP.JUR_PERS = PSPF.JUR_PERS
                         and UP.UNITCODE = 'Projects')
                 and exists (select /*+ INDEX(UP I_USERPRIV_CATALOG_ROLEID) */
                       null
                        from USERPRIV UP
                       where UP.CATALOG = I.CRN
                         and UP.ROLEID in (select /*+ INDEX(UR I_USERROLES_AUTHID_FK) */
                                            UR.ROLEID
                                             from USERROLES UR
                                            where UR.AUTHID = UTILIZER)
                      union all
                      select /*+ INDEX(UP I_USERPRIV_CATALOG_AUTHID) */
                       null
                        from USERPRIV UP
                       where UP.CATALOG = I.CRN
                         and UP.AUTHID = UTILIZER))
    loop
      /* Сформируем идентификатор буфера */
      if (NIDENT is null) then
        NIDENT := GEN_IDENT();
      end if;
      /* Добавим подобранное в список отмеченных записей */
      P_SELECTLIST_BASE_INSERT(NIDENT       => NIDENT,
                               NCOMPANY     => C.COMPANY,
                               NDOCUMENT    => C.RN,
                               SUNITCODE    => 'IncomingInvoices',
                               SACTIONCODE  => null,
                               NCRN         => null,
                               NDOCUMENT1   => null,
                               SUNITCODE1   => null,
                               SACTIONCODE1 => null,
                               NRN          => NSELECTLIST);
    end loop;
  end STAGE_CONTRACTS_SELECT_ININV;

  /* Подбор платежей финансирования соисполнителя этапа проекта */
  procedure STAGE_CONTRACTS_SELECT_FIN_OUT
  (
    NPROJECTSTAGEPF         in number,    -- Рег. номер соисполнителя этапа проекта
    NIDENT                  out number    -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  )
  is
    NSELECTLIST             PKG_STD.TREF; -- Рег. номер добавленной записи буфера подобранных
  begin
    /* Подберём платежи */
    for C in (select PN.COMPANY,
                     PN.RN
                from PROJECTSTAGEPF PSPF,
                     PROJECTSTAGE   PS,
                     PAYNOTES       PN
               where PSPF.RN = NPROJECTSTAGEPF
                 and PSPF.PRN = PS.RN
                 and PSPF.FACEACC = PN.FACEACC
                 and PN.SIGNPLAN = 0
                 and exists (select null
                        from PAYNOTESCLC PNCLC
                       where PNCLC.PRN = PN.RN
                         and PNCLC.FACEACCOUNT = PS.FACEACC)
                 and exists (select null from V_USERPRIV UP where UP.CATALOG = PSPF.CRN)
                 and exists (select null
                        from V_USERPRIV UP
                       where UP.JUR_PERS = PSPF.JUR_PERS
                         and UP.UNITCODE = 'Projects')
                 and exists (select /*+ INDEX(UP I_USERPRIV_CATALOG_ROLEID) */
                       null
                        from USERPRIV UP
                       where UP.CATALOG = PN.CRN
                         and UP.ROLEID in (select /*+ INDEX(UR I_USERROLES_AUTHID_FK) */
                                            UR.ROLEID
                                             from USERROLES UR
                                            where UR.AUTHID = UTILIZER)
                      union all
                      select /*+ INDEX(UP I_USERPRIV_CATALOG_AUTHID) */
                       null
                        from USERPRIV UP
                       where UP.CATALOG = PN.CRN
                         and UP.AUTHID = UTILIZER)
                 and exists (select /*+ INDEX(UP I_USERPRIV_JUR_PERS_ROLEID) */
                       null
                        from USERPRIV UP
                       where UP.JUR_PERS = PN.JUR_PERS
                         and UP.UNITCODE = 'PayNotes'
                         and UP.ROLEID in (select /*+ INDEX(UR I_USERROLES_AUTHID_FK) */
                                            UR.ROLEID
                                             from USERROLES UR
                                            where UR.AUTHID = UTILIZER)
                      union all
                      select /*+ INDEX(UP I_USERPRIV_JUR_PERS_AUTHID) */
                       null
                        from USERPRIV UP
                       where UP.JUR_PERS = PN.JUR_PERS
                         and UP.UNITCODE = 'PayNotes'
                         and UP.AUTHID = UTILIZER))
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
  end STAGE_CONTRACTS_SELECT_FIN_OUT;

  /* Получение состояния финансирования по договору соисполнителя этапа проекта */
  function STAGE_CONTRACTS_GET_CTRL_FIN
  (
    NPROJECTSTAGEPF         in number        -- Рег. номер соисполнителя этапа проекта
  ) return                  number           -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  is
    NTMP                    PKG_STD.TNUMBER; -- Буфер для вызова процедуры расчёта
    NCTRL_FIN               PKG_STD.TNUMBER; -- Буфер для результата
  begin
    /* Получим сведения по договору соисполнителя этапа */
    STAGE_CONTRACTS_GET(NPROJECTSTAGEPF => NPROJECTSTAGEPF,
                        NINC_FIN        => 1,
                        NINC_COEXEC     => 0,
                        NPAY_IN         => NTMP,
                        NFIN_OUT        => NTMP,
                        NPAY_IN_REST    => NTMP,
                        NFIN_REST       => NTMP,
                        NCTRL_FIN       => NCTRL_FIN,
                        NCOEXEC_IN      => NTMP,
                        NCOEXEC_REST    => NTMP,
                        NCTRL_COEXEC    => NTMP);
    /* Вернём результат */
    return NCTRL_FIN;
  end STAGE_CONTRACTS_GET_CTRL_FIN;
  
  /* Получение состояния соисполнения по договору соисполнителя этапа проекта */
  function STAGE_CONTRACTS_GET_CTRL_COEXE
  (
    NPROJECTSTAGEPF         in number        -- Рег. номер соисполнителя этапа проекта
  ) return                  number           -- Состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  is
    NTMP                    PKG_STD.TNUMBER; -- Буфер для вызова процедуры расчёта
    NCTRL_COEXEC            PKG_STD.TNUMBER; -- Буфер для результата
  begin
    /* Получим сведения по договору соисполнителя этапа */
    STAGE_CONTRACTS_GET(NPROJECTSTAGEPF => NPROJECTSTAGEPF,
                        NINC_FIN        => 0,
                        NINC_COEXEC     => 1,
                        NPAY_IN         => NTMP,
                        NFIN_OUT        => NTMP,
                        NPAY_IN_REST    => NTMP,
                        NFIN_REST       => NTMP,
                        NCTRL_FIN       => NTMP,
                        NCOEXEC_IN      => NTMP,
                        NCOEXEC_REST    => NTMP,
                        NCTRL_COEXEC    => NCTRL_COEXEC);
    /* Вернём результат */
    return NCTRL_COEXEC;
  end STAGE_CONTRACTS_GET_CTRL_COEXE;

  /* Получение сведений по договору соисполнителя этапа проекта */
  procedure STAGE_CONTRACTS_GET
  (
    NPROJECTSTAGEPF         in number,              -- Рег. номер соисполнителя этапа проекта
    NINC_FIN                in number := 0,         -- Включить сведения о финансировании (0 - нет, 1 - да)
    NINC_COEXEC             in number := 0,         -- Включить сведения о соисполнении (0 - нет, 1 - да)    
    NPAY_IN                 out number,             -- Сведения о финансировании - сумма акцептованных счетов на оплату
    NFIN_OUT                out number,             -- Сведения о финансировании - сумма оплаченных счетов на оплату
    NPAY_IN_REST            out number,             -- Сведения о финансировании - сумма оставшихся к оплате счетов на оплату
    NFIN_REST               out number,             -- Сведения о финансировании - общий остаток к оплате по договору
    NCTRL_FIN               out number,             -- Сведения о финансировании - состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
    NCOEXEC_IN              out number,             -- Сведения о соисполнении - получено актов/накладных
    NCOEXEC_REST            out number,             -- Сведения о соисполнении - остаток к актированию/поставке
    NCTRL_COEXEC            out number              -- Сведения о соисполнении - состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
  )
  is
    RPSPF                   PROJECTSTAGEPF%rowtype; -- Запись соисполнителя этапа проекта
    RPS                     PROJECTSTAGE%rowtype;   -- Запись родительского этапа проекта
    NDAYS_LEFT              PKG_STD.TNUMBER;        -- Остаток дней до завершения родительского этапа проекта
  begin
    /* Читаем запись соисполнителя этапа проекта */
    RPSPF := STAGE_CONTRACTS_GET_PSPF(NPROJECTSTAGEPF => NPROJECTSTAGEPF);
    /* Читаем записб родительского этапа проекта */
    RPS := STAGES_GET(NRN => RPSPF.PRN);
    /* Инициализируем выходные значения */
    NPAY_IN      := 0;
    NFIN_OUT     := 0;
    NPAY_IN_REST := 0;
    NFIN_REST    := RPSPF.COST_PLAN;
    NCTRL_FIN    := null;
    NCOEXEC_IN   := 0;
    NCOEXEC_REST := RPSPF.COST_PLAN;
    NCTRL_COEXEC := null;
    /* Если ЛС этапа проекта задан */
    if (RPS.FACEACC is not null) then
      /* Если нужны сведения о финансировании */
      if (NINC_FIN = 1) then
        /* Сумма акцептованных счетов на оплату - по ВСО с ЛС соисполнителя этапа проекта, в калькуляции которых присутствует ЛС затрат этапа проекта */
        select sum(PAI.SUMMWITHNDS * PAI.FA_BASECOURS)
          into NPAY_IN
          from PAYACCIN PAI
         where PAI.FACEACC = RPSPF.FACEACC
           and PAI.DOC_STATE = 1
           and exists (select null
                  from PAYACCINSPCLC PCLC
                 where PCLC.PRN in (select PAIS.RN from PAYACCINSPEC PAIS where PAIS.PRN = PAI.RN)
                   and PCLC.FACEACCOUNT = RPS.FACEACC);
        /* Сумма оплаченных счетов на оплату - по расходным факт. ЖП с ЛС соисполнителя этапа проекта, в калькуляции которых присутствует ЛС затрат этапа проекта */
        select sum(PN.PAY_SUM * (PN.CURR_RATE_BASE / PN.CURR_RATE))
          into NFIN_OUT
          from PAYNOTES PN
         where PN.FACEACC = RPSPF.FACEACC
           and PN.SIGNPLAN = 0
           and exists (select null
                  from PAYNOTESCLC PNCLC
                 where PNCLC.PRN = PN.RN
                   and PNCLC.FACEACCOUNT = RPS.FACEACC);
        /* Сумма оставшихся к оплате счетов на оплату */
        NPAY_IN_REST := COALESCE(NPAY_IN, 0) - COALESCE(NFIN_OUT, 0);
        /* Общий остаток к оплате по договору */
        NFIN_REST := RPSPF.COST_PLAN - COALESCE(NFIN_OUT, 0);
        /* Контроль отклонений по финансированию (состояние) */
        if (NPAY_IN is null) then
          NCTRL_FIN := null;
        else
          if (NPAY_IN_REST > 0) then
            NCTRL_FIN := 1;
          else
            NCTRL_FIN := 0;
          end if;
        end if;
        /* Приведение значений */
        NPAY_IN  := COALESCE(NPAY_IN, 0);
        NFIN_OUT := COALESCE(NFIN_OUT, 0);
      end if;
      /* Если нужны сведения о соисполнении */
      if (NINC_COEXEC = 1) then
        /* Получено актов/накладных - по отработанным как факт ПН с ЛС соисполнителя этапа проекта, в калькуляции которых присутствует ЛС затрат этапа проекта */
        select sum(I.SUMMTAX * (I.CURBASECOURS / I.CURCOURS))
          into NCOEXEC_IN
          from ININVOICES I
         where I.FACEACC = RPSPF.FACEACC
           and I.STATUS = 2
           and exists (select null
                  from ININVOICESSPC ICLC
                 where ICLC.PRN in (select ISP.RN from ININVOICESSPECS ISP where ISP.PRN = I.RN)
                   and ICLC.FACEACCOUNT = RPS.FACEACC);
        /* Общий остаток к актированию/поставке */
        NCOEXEC_REST := RPSPF.COST_PLAN - COALESCE(NCOEXEC_IN, 0);
        /* Контроль отклонений по соисполнению (состояние) */
        NDAYS_LEFT := STAGES_GET_DAYS_LEFT(NRN => RPS.RN);
        if (NDAYS_LEFT is null) then
          NCTRL_COEXEC := null;
        else
          if ((NCOEXEC_REST > 0) and (NDAYS_LEFT < NDAYS_LEFT_LIMIT)) then
            NCTRL_COEXEC := 1;
          else
            NCTRL_COEXEC := 0;
          end if;
        end if;
        /* Приведение значений */
        NCOEXEC_IN := COALESCE(NCOEXEC_IN, 0);
      end if;
    end if;
  end STAGE_CONTRACTS_GET;
  
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
    RCOL_VALS               PKG_P8PANELS_VISUAL.TCOL_VALS;         -- Предопределённые значения столбцов
    NROW_FROM               PKG_STD.TREF;                          -- Номер строки с
    NROW_TO                 PKG_STD.TREF;                          -- Номер строки по
    CSQL                    clob;                                  -- Буфер для запроса
    ICURSOR                 integer;                               -- Курсор для исполнения запроса
    NPROJECTSTAGEPF         PKG_STD.TREF;                          -- Рег. номер соисполнителя этапа проекта    
    NPAY_IN                 PKG_STD.TNUMBER;                       -- Сведения о финансировании - сумма акцептованных счетов на оплату
    NFIN_OUT                PKG_STD.TNUMBER;                       -- Сведения о финансировании - сумма оплаченных счетов на оплату
    NPAY_IN_REST            PKG_STD.TNUMBER;                       -- Сведения о финансировании - сумма оставшихся к оплате счетов на оплату
    NFIN_REST               PKG_STD.TNUMBER;                       -- Сведения о финансировании - общий остаток к оплате по договору
    NCTRL_FIN               PKG_STD.TNUMBER;                       -- Сведения о финансировании - состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
    NCOEXEC_IN              PKG_STD.TNUMBER;                       -- Сведения о соисполнении - получено актов/накладных
    NCOEXEC_REST            PKG_STD.TNUMBER;                       -- Сведения о соисполнении - остаток к актированию/поставке
    NCTRL_COEXEC            PKG_STD.TNUMBER;                       -- Сведения о соисполнении - состояние (null - не определено, 0 - без отклонений, 1 - есть отклонения)
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
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NPAY_IN',
                                               SCAPTION   => 'Акцептовано счетов на оплату',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NFIN_OUT',
                                               SCAPTION   => 'Оплачено счетов',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NPAY_IN_REST',
                                               SCAPTION   => 'Осталось оплатить счетов',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 0, BCLEAR => true);
    PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 1);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_FIN',
                                               SCAPTION   => 'Фин-е (исх.)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_FIN',
                                               BORDER     => false,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS,
                                               SHINT      => '<b>Финансирование (исходящее)</b> - контроль оплаты счетов, выставленных соисполнителем в рамках договора.<br>' ||
                                                             '<b style="color:red">Требует внимания</b> - не все выставленные соисполнителем акцептованные счета оплачены.<br>' ||
                                                             '<b style="color:green">В норме</b> - нет описанных выше отклонений.<br>' ||
                                                             '<b style="color:gray">Пусто</b> - в Системе не хватает данных для рассчёта. Убедитесь, что для договора с соисполнителем аккуратно ведётся учёт первичных документов оперативного учёта (входящих счетов на оплату).');
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NFIN_REST',
                                               SCAPTION   => 'Общий остаток к оплате по договору',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCOEXEC_IN',
                                               SCAPTION   => 'Получено актов/накладных',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCOEXEC_REST',
                                               SCAPTION   => 'Остаток к актированию/поставке',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NCTRL_COEXEC',
                                               SCAPTION   => 'Соисполнение',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               SCOND_FROM => 'EDCTRL_COEXEC',
                                               BORDER     => false,
                                               BFILTER    => true,
                                               RCOL_VALS  => RCOL_VALS,
                                               SHINT      => '<b>Соисполнение</b> - контроль исполнения обязательств по договору с соисполнителем.<br>' ||
                                                             '<b style="color:red">Требует внимания</b> - до окончания этапа проекта, в рамках которого действует соисполнение, осталось менее ' ||
                                                             TO_CHAR(NDAYS_LEFT_LIMIT) ||
                                                             ' дней, при этом зафиксирован положительный остаток к поставке/актированию по договору.<br>' ||
                                                             '<b style="color:green">В норме</b> - нет описанных выше отклонений.<br>' ||
                                                             '<b style="color:gray">Пусто</b> - в Системе не хватает данных для рассчёта. Убедитесь, что для связанного этапа проекта задана плановая дата окончания, ' ||
                                                             'а по договору с соисполнителем аккуратно ведётся учёт первичных документов оперативного учёта (приходных накладных).');
    /* Обходим данные */
    begin
      /* Добавляем подсказку совместимости */
      CSQL := PKG_SQL_BUILD.COMPATIBLE(SSQL => CSQL);
      /* Формируем запрос */
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => 'select *');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '  from (select D.*,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.SQLROWNUM() || ' NROW');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '          from (select PSPF.RN NRN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       trim(CN.DOC_PREF) SDOC_PREF,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.WRAP_STR(SVALUE => 'Contracts') || ' SLNK_UNIT_SDOC_PREF,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       CN.RN NLNK_DOCUMENT_SDOC_PREF,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       trim(CN.DOC_NUMB) SDOC_NUMB,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.WRAP_STR(SVALUE => 'Contracts') || ' SLNK_UNIT_SDOC_NUMB,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       CN.RN NLNK_DOCUMENT_SDOC_NUMB,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       CN.DOC_DATE DDOC_DATE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       CN.EXT_NUMBER SEXT_NUMBER,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       AG.AGNNAME SAGENT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       AG.AGNIDNUMB SAGENT_INN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       AG.REASON_CODE SAGENT_KPP,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       GC.CODE SGOVCNTRID,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       trim(ST.NUMB) SCSTAGE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       ST.DESCRIPTION SCSTAGE_DESCRIPTION,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       ST.BEGIN_DATE DCSTAGE_BEGIN_DATE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       ST.END_DATE DCSTAGE_END_DATE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       PSPF.COST_PLAN NSUMM,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       CUR.INTCODE SCURR,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       ART.CODE SCOST_ART');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  from PROJECTSTAGEPF PSPF');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       left outer join FPDARTCL ART on PSPF.COST_ARTICLE = ART.RN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       STAGES ST,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       CONTRACTS CN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       left outer join GOVCNTRID GC on CN.GOVCNTRID = GC.RN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       AGNLIST AG,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       CURNAMES CUR');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                 where PSPF.FACEACC = ST.FACEACC');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and ST.PRN = CN.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and PSPF.PERFORMER = AG.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and CN.CURRENCY = CUR.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and exists (select null from V_USERPRIV UP where UP."CATALOG" = PSPF.CRN)');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and exists (select null from V_USERPRIV UP where UP.JUR_PERS = PSPF.JUR_PERS and UP.UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'Projects') || ')');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and exists (select null from V_USERPRIV UP where UP."CATALOG" = ST.CRN)');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and exists (select null from V_USERPRIV UP where UP.JUR_PERS = ST.JUR_PERS and UP.UNITCODE = ' || PKG_SQL_BUILD.WRAP_STR(SVALUE => 'Contracts') || ')');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and PSPF.RN in (select ID from COND_BROKER_IDSMART where IDENT = :NIDENT) %ORDER_BY%) D) F');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => ' where F.NROW between :NROW_FROM and :NROW_TO');
      /* Учтём сортировки */
      PKG_P8PANELS_VISUAL.TORDERS_SET_QUERY(RDATA_GRID => RDG, RORDERS => RO, SPATTERN => '%ORDER_BY%', CSQL => CSQL);
      /* Учтём фильтры */
      PKG_P8PANELS_VISUAL.TFILTERS_SET_QUERY(NIDENT     => NIDENT,
                                             NCOMPANY   => NCOMPANY,
                                             NPARENT    => NSTAGE,
                                             SUNIT      => 'ProjectsStagesPerformers',
                                             SPROCEDURE => PKG_SQL_BUILD.PKG_NAME(SNAME => 'PKG_P8PANELS_PROJECTS.STAGE_CONTRACTS_COND'),
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
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 21);
      /* Делаем выборку */
      if (PKG_SQL_DML.EXECUTE(ICURSOR => ICURSOR) = 0) then
        null;
      end if;
      /* Обходим выбранные записи */
      while (PKG_SQL_DML.FETCH_ROWS(ICURSOR => ICURSOR) > 0)
      loop
        /* Добавляем колонки с данными */
        PKG_SQL_DML.COLUMN_VALUE_NUM(ICURSOR => ICURSOR, IPOSITION => 1, NVALUE => NPROJECTSTAGEPF);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NRN', NVALUE => NPROJECTSTAGEPF, BCLEAR => true);
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
        STAGE_CONTRACTS_GET(NPROJECTSTAGEPF => NPROJECTSTAGEPF,
                            NINC_FIN        => 1,
                            NINC_COEXEC     => 1,
                            NPAY_IN         => NPAY_IN,
                            NFIN_OUT        => NFIN_OUT,
                            NPAY_IN_REST    => NPAY_IN_REST,
                            NFIN_REST       => NFIN_REST,
                            NCTRL_FIN       => NCTRL_FIN,
                            NCOEXEC_IN      => NCOEXEC_IN,
                            NCOEXEC_REST    => NCOEXEC_REST,
                            NCTRL_COEXEC    => NCTRL_COEXEC);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NPAY_IN', NVALUE => NPAY_IN);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NFIN_OUT', NVALUE => NFIN_OUT);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NPAY_IN_REST', NVALUE => NPAY_IN_REST);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NCTRL_FIN', NVALUE => NCTRL_FIN);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NFIN_REST', NVALUE => NFIN_REST);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NCOEXEC_IN', NVALUE => NCOEXEC_IN);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NCOEXEC_REST', NVALUE => NCOEXEC_REST);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NCTRL_COEXEC', NVALUE => NCTRL_COEXEC);
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
  
  /* Считывание записи работы проекта */
  function JOBS_GET
  (
    NRN                     in number           -- Рег. номер работы проекта
  ) return                  PROJECTJOB%rowtype  -- Запись работы проекта
  is
    RRES                    PROJECTJOB%rowtype; -- Буфер для результата
  begin
    select PS.* into RRES from PROJECTJOB PS where PS.RN = NRN;
    return RRES;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0, NDOCUMENT => NRN, SUNIT_TABLE => 'PROJECTJOB');
  end JOBS_GET;
  
  /* Получение даты начала периода балансировки */
  function JB_GET_BEG
  (
    NIDENT                  in number       -- Идентификатор процесса
  ) return                  date            -- Дата начала периода балансировки
  is
    DRES                    PKG_STD.TLDATE; -- Буфер для результата
  begin
    select min(D.DMIN_BEG_PLAN)
      into DRES
      from (select min(P.BEGPLAN) DMIN_BEG_PLAN
              from PROJECT P
             where P.RN in (select T.PROJECT from P8PNL_JB_PRJCTS T where T.IDENT = NIDENT)
            union all
            select min(PS.BEGPLAN) DMIN_BEG_PLAN
              from PROJECTSTAGE PS
             where PS.PRN in (select T.PROJECT from P8PNL_JB_PRJCTS T where T.IDENT = NIDENT)
            union all
            select min(PJ.BEGPLAN) DMIN_BEG_PLAN
              from PROJECTJOB PJ
             where PJ.PRN in (select T.PROJECT from P8PNL_JB_PRJCTS T where T.IDENT = NIDENT)) D;
    /* Проверим, что хоть что-то нашли */
    if (DRES is null) then
      P_EXCEPTION(0,
                  'Не удалось определить дату начала периода балансировки. Убедитесь, что для проектов, этапов и работ заданы плановые сроки начала.');
    end if;
    /* Вернём результат - первый день минимального месяца */
    return TRUNC(DRES, 'mm');
  end JB_GET_BEG;
  
  /* Получение даты окончания периода балансировки */
  function JB_GET_END
  (
    NIDENT                  in number       -- Идентификатор процесса
  ) return                  date            -- Дата окончания периода балансировки
  is
    DRES                    PKG_STD.TLDATE; -- Буфер для результата
  begin
    select max(D.DMAX_END_PLAN)
      into DRES
      from (select max(P.ENDPLAN) DMAX_END_PLAN
              from PROJECT P
             where P.RN in (select T.PROJECT from P8PNL_JB_PRJCTS T where T.IDENT = NIDENT)
            union all
            select max(PS.ENDPLAN) DMAX_END_PLAN
              from PROJECTSTAGE PS
             where PS.PRN in (select T.PROJECT from P8PNL_JB_PRJCTS T where T.IDENT = NIDENT)
            union all
            select max(PJ.ENDPLAN) DMAX_END_PLAN
              from PROJECTJOB PJ
             where PJ.PRN in (select T.PROJECT from P8PNL_JB_PRJCTS T where T.IDENT = NIDENT)) D;
    /* Проверим, что хоть что-то нашли */
    if (DRES is null) then
      P_EXCEPTION(0,
                  'Не удалось определить дату окончания периода балансировки. Убедитесь, что для проектов, этапов и работ заданы плановые сроки окончания.');
    end if;
    /* Вернём результат - последний день максимального месяца */
    return LAST_DAY(DRES);
  end JB_GET_END;  
  
  /* Считывание записи проекта из буфера балансировки работ */
  function JB_PRJCTS_GET
  (
    NJB_PRJCTS              in number                -- Рег. номер записи списка балансируемых проектов
  ) return                  P8PNL_JB_PRJCTS%rowtype  -- Запись проекта
  is
    RRES                    P8PNL_JB_PRJCTS%rowtype; -- Буфер для результата
  begin
    select P.* into RRES from P8PNL_JB_PRJCTS P where P.RN = NJB_PRJCTS;
    return RRES;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0, NDOCUMENT => NJB_PRJCTS, SUNIT_TABLE => 'P8PNL_JB_PRJCTS');
  end JB_PRJCTS_GET;

  /* Установка признака наличия изменений проекта, требующих сохранения */
  procedure JB_PRJCTS_SET_CHANGED
  (
    NJB_PRJCTS              in number,  -- Рег. номер записи списка балансируемых проектов
    NCHANGED                in number   -- Признак наличия изменений, требующих сохранения (0 - нет, 1 - да)  
  )
  is
  begin
    /* Установим признак */
    update P8PNL_JB_PRJCTS T set T.CHANGED = NCHANGED where T.RN = NJB_PRJCTS;
  end JB_PRJCTS_SET_CHANGED;

  /* Базовое добавление проекта для балансировки работ */
  procedure JB_PRJCTS_BASE_INSERT
  (
    NIDENT                  in number,  -- Идентификатор процесса
    NPROJECT                in number,  -- Рег. номер проекта
    NJOBS                   in number,  -- Признак наличия плана-графика (0 - нет, 1 - да)
    NEDITABLE               in number,  -- Признак возможности редактирования (0 - нет, 1 - да)
    NCHANGED                in number,  -- Признак наличия изменений, требующих сохранения (0 - нет, 1 - да)  
    NJB_PRJCTS              out number  -- Рег. номер записи списка балансируемых проектов
  )
  is
  begin
    /* Сформируем рег. номер записи */
    NJB_PRJCTS := GEN_ID();
    /* Добавим запись */
    insert into P8PNL_JB_PRJCTS
      (RN, IDENT, PROJECT, JOBS, EDITABLE, CHANGED)
    values
      (NJB_PRJCTS, NIDENT, NPROJECT, NJOBS, NEDITABLE, NCHANGED);
  end JB_PRJCTS_BASE_INSERT;
  
  /* Получение списка проектов */
  procedure JB_PRJCTS_LIST
  (
    NIDENT                  in number,  -- Идентификатор процесса
    COUT                    out clob    -- Список проектов
  )
  is
  begin
    /* Начинаем формирование XML */
    PKG_XFAST.PROLOGUE(ITYPE => PKG_XFAST.CONTENT_);
    /* Открываем корень */
    PKG_XFAST.DOWN_NODE(SNAME => 'XDATA');
    /* Обходим буфер балансировки */
    for C in (select T.RN       NRN,
                     T.PROJECT  NPROJECT,
                     P.NAME_USL SNAME,
                     T.JOBS     NJOBS,
                     T.EDITABLE NEDITABLE,
                     T.CHANGED  NCHANGED
                from P8PNL_JB_PRJCTS T,
                     PROJECT         P
               where T.IDENT = NIDENT
                 and T.PROJECT = P.RN
                 and exists (select null from V_USERPRIV UP where UP.CATALOG = P.CRN)
                 and exists (select null
                        from V_USERPRIV UP
                       where UP.JUR_PERS = P.JUR_PERS
                         and UP.UNITCODE = 'Projects')
               order by T.RN)
    loop
      /* Открываем проект */
      PKG_XFAST.DOWN_NODE(SNAME => 'XPROJECTS');
      /* Описываем проект */
      PKG_XFAST.ATTR(SNAME => 'NRN', NVALUE => C.NRN);
      PKG_XFAST.ATTR(SNAME => 'NPROJECT', NVALUE => C.NPROJECT);
      PKG_XFAST.ATTR(SNAME => 'SNAME', SVALUE => C.SNAME);
      PKG_XFAST.ATTR(SNAME => 'NJOBS', NVALUE => C.NJOBS);
      PKG_XFAST.ATTR(SNAME => 'NEDITABLE', NVALUE => C.NEDITABLE);
      PKG_XFAST.ATTR(SNAME => 'NCHANGED', NVALUE => C.NCHANGED);
      /* Закрываем проект */
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
  end JB_PRJCTS_LIST;
  
  /* Считывание записи работы/этапа из буфера балансировки работ */
  function JB_JOBS_GET
  (
    NJB_JOBS                in number              -- Рег. номер записи работы/этапа в буфере балансировки работ
  ) return                  P8PNL_JB_JOBS%rowtype  -- Найденная запись
  is
    RRES                    P8PNL_JB_JOBS%rowtype; -- Буфер для результата
  begin
    select P.* into RRES from P8PNL_JB_JOBS P where P.RN = NJB_JOBS;
    return RRES;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0, NDOCUMENT => NJB_JOBS, SUNIT_TABLE => 'P8PNL_JB_JOBS');
  end JB_JOBS_GET;
  
  /* Поиск записи работы/этапа в списке балансировки по этапу/работе проекта */
  function JB_JOBS_GET_BY_SOURCE
  (
    NIDENT                  in number,             -- Идентификатор процесса
    NPRN                    in number,             -- Рег. номер родителя
    NSOURCE                 in number              -- Рег. номер источника (работы/этапа проекта)
  ) return                  P8PNL_JB_JOBS%rowtype  -- Найденная запись
  is
    RRES                    P8PNL_JB_JOBS%rowtype; -- Буфер для результата
  begin
    select T.*
      into RRES
      from P8PNL_JB_JOBS T
     where T.IDENT = NIDENT
       and T.PRN = NPRN
       and T.SOURCE = NSOURCE;
    return RRES;
  exception
    when NO_DATA_FOUND then
      P_EXCEPTION(0,
                  'Запись работы/этапа (RN-источника: %s) не определена в буфере балансировки.',
                  COALESCE(TO_CHAR(NSOURCE), '<НЕ УКАЗАН>'));
  end JB_JOBS_GET_BY_SOURCE;
  
  /* Установка признака наличия изменений балансируемой работы/этапа, требующих сохранения */
  procedure JB_JOBS_SET_CHANGED
  (
    NJB_JOBS                in number,  -- Рег. номер записи балансируемой работы/этапа
    NCHANGED                in number   -- Признак наличия изменений, требующих сохранения (0 - нет, 1 - да)  
  )
  is
  begin
    /* Установим признак */
    update P8PNL_JB_JOBS T set T.CHANGED = NCHANGED where T.RN = NJB_JOBS;
  end JB_JOBS_SET_CHANGED;
  
  /* Базовое добавление работы/этапа для балансировки работ */
  procedure JB_JOBS_BASE_INSERT
  (
    NIDENT                  in number,   -- Идентификатор процесса
    NPRN                    in number,   -- Рег. номер родителя
    NHRN                    in number,   -- Рег. номер родительской записи в иерархии работ/этапов
    NSOURCE                 in number,   -- Рег. номер источника (работы/этапа проекта)
    SNUMB                   in varchar2, -- Номер
    SNAME                   in varchar2, -- Наименование
    DDATE_FROM              in date,     -- Начало
    DDATE_TO                in date,     -- Окончание
    NDURATION               in number,   -- Длительность
    SEXECUTOR               in varchar2, -- Исполнитель
    NSTAGE                  in number,   -- Признак этапа (0 - нет, 1 - да)
    NEDITABLE               in number,   -- Признак возможности редактирования (0 - нет, 1 - да)
    NJB_JOBS                out number   -- Рег. номер записи балансируемой работы/этапа
  )
  is
  begin
    /* Сформируем рег. номер записи */
    NJB_JOBS := GEN_ID();
    /* Добавим запись */
    insert into P8PNL_JB_JOBS
      (RN, IDENT, PRN, HRN, source, NUMB, name, DATE_FROM, DATE_TO, DURATION, EXECUTOR, STAGE, EDITABLE)
    values
      (NJB_JOBS, NIDENT, NPRN, NHRN, NSOURCE, SNUMB, SNAME, DDATE_FROM, DDATE_TO, NDURATION, SEXECUTOR, NSTAGE, NEDITABLE);
  end JB_JOBS_BASE_INSERT;
  
  /* Базовое изменением сроков работы в буфере балансировки */
  procedure JB_JOBS_BASE_MODIFY_PERIOD
  (
    NJB_JOBS                in number,               -- Рег. номер записи балансируемой работы/этапа
    NDELTA                  in number,               -- Изменение срока работы
    NCHANGE_FLAG            in number,               -- Флаг изменения данных (1 - изменять дату начала, 2 - изменять дату окончания)
    DFACT                   in date,                 -- Факт по состоянию на
    NDURATION_MEAS          in number                -- Единица измерения длительности (0 - день, 1 - неделя, 2 - декада, 3 - месяц, 4 - квартал, 5 - год)    
  )
  is
    RJ                      PROJECTJOB%rowtype;      -- Запись работы в проекте
    RS                      PROJECTSTAGE%rowtype;    -- Запись этапа в проекте
    RJB_J                   P8PNL_JB_JOBS%rowtype;   -- Запись работы в буфере балансировки
    DDATE_FROM_NEW          PKG_STD.TLDATE;          -- Новая дата начала работы
    DDATE_TO_NEW            PKG_STD.TLDATE;          -- Новая дата окончания работы
  begin
    /* Считаем работу из буфера */
    RJB_J := JB_JOBS_GET(NJB_JOBS => NJB_JOBS);
    /* Считаем работу проекта */
    RJ := JOBS_GET(NRN => RJB_J.SOURCE);
    /* Проверки - работа должна быть привязана к этапу */
    if (RJ.PROJECTSTAGE is null) then
      P_EXCEPTION(0,
                  'Работа "%s" должа быть привязана к этапу проекта.',
                  trim(RJ.NUMB));
    end if;
    /* Считаем этап проекта */
    RS := STAGES_GET(NRN => RJ.PROJECTSTAGE);
    /* Проверки - работа должна иметь фиксированную длительность */
    if (RJ.DURATION_CHG <> 2) then
      P_EXCEPTION(0,
                  'Работа "%s" должна иметь фиксированную длительность.',
                  trim(RJ.NUMB));
    end if;
    /* Проверки - работа должна быть в состоянии отличном от "Неначата" */
    if (RJ.STATE <> 0) then
      P_EXCEPTION(0,
                  'Работа "%s" должна быть в состоянии "Не начата".',
                  trim(RJ.NUMB));
    end if;
    /* Вычислим новую дату начала и окончания для работы */
    if (NCHANGE_FLAG = 1) then
      DDATE_FROM_NEW := RJB_J.DATE_FROM + NDELTA;
      P_PROJECTJOB_GET_OFFSET_DATE(NCOMPANY     => RJ.COMPANY,
                                   DSRC_DATE    => DDATE_FROM_NEW,
                                   NOFFSET      => RJ.DURATION_P,
                                   NOFFSET_MEAS => NDURATION_MEAS,
                                   DDEST_DATE   => DDATE_TO_NEW);
    else
      DDATE_TO_NEW := RJB_J.DATE_TO + NDELTA;
      P_PROJECTJOB_GET_OFFSET_DATE(NCOMPANY     => RJ.COMPANY,
                                   DSRC_DATE    => DDATE_TO_NEW,
                                   NOFFSET      => -RJ.DURATION_P,
                                   NOFFSET_MEAS => NDURATION_MEAS,
                                   DDEST_DATE   => DDATE_FROM_NEW);
    end if;
    /* Проверки - дата начала работы не должна быть меньше даты факта */
    if ((NCHANGE_FLAG = 1) and (DDATE_FROM_NEW <= DFACT)) then
      P_EXCEPTION(0,
                  'Работа не может начинаться раньше даты "Факт по состоянию на" (%s).',
                  TO_CHAR(DFACT, 'DD.MM.YYYY'));
    end if;
    /* Проверки - дата окончания работы не должна быть меньше даты факта */
    if ((NCHANGE_FLAG = 2) and (DDATE_TO_NEW <= DFACT)) then
      P_EXCEPTION(0,
                  'Работа не может заканчиваться раньше даты "Факт по состоянию на" (%s).',
                  TO_CHAR(DFACT, 'DD.MM.YYYY'));
    end if;
    /* Проверки - дата окончания работы не должна быть больше даты окончания этапа */
    if ((NCHANGE_FLAG = 2) and (DDATE_TO_NEW >= RS.ENDPLAN)) then
      P_EXCEPTION(0,
                  'Работа не может заканчиваться после даты завершения этапа (%s).',
                  TO_CHAR(RS.ENDPLAN, 'DD.MM.YYYY'));
    end if;
    /* Изменяем работу */
    update P8PNL_JB_JOBS T
       set T.DATE_FROM = DDATE_FROM_NEW,
           T.DATE_TO   = DDATE_TO_NEW
     where T.RN = RJB_J.RN;
    /* Установим признак наличия изменений */
    JB_JOBS_SET_CHANGED(NJB_JOBS => RJB_J.RN, NCHANGED => 1);
    /* Обходим зависимые работы с фиксированной длительностью и меняем их */
    for C in (select J.RN
                from P8PNL_JB_JOBS J
               where J.RN in (select PRV.PRN
                                from P8PNL_JB_JOBSPREV PRV
                               where PRV.IDENT = RJB_J.IDENT
                                 and PRV.JB_JOBS = RJB_J.RN))
    loop
      JB_JOBS_BASE_MODIFY_PERIOD(NJB_JOBS       => C.RN,
                                 NDELTA         => NDELTA,
                                 NCHANGE_FLAG   => NCHANGE_FLAG,
                                 DFACT          => DFACT,
                                 NDURATION_MEAS => NDURATION_MEAS);
    end loop;
  end JB_JOBS_BASE_MODIFY_PERIOD;
  
  /* Изменение сроков работы в буфере балансировки */
  procedure JB_JOBS_MODIFY_PERIOD
  (
    NJB_JOBS                in number,                     -- Рег. номер записи балансируемой работы/этапа
    DDATE_FROM              in date,                       -- Новая дата начала
    DDATE_TO                in date,                       -- Новая дата окончания
    DBEGIN                  in date,                       -- Дата начала периода мониторинга загрузки ресурсов
    DFACT                   in date,                       -- Факт по состоянию на
    NDURATION_MEAS          in number,                     -- Единица измерения длительности (0 - день, 1 - неделя, 2 - декада, 3 - месяц, 4 - квартал, 5 - год)
    NRESOURCE_STATUS        out number                     -- Состояние ресурсов (0 - без отклонений, 1 - есть отклонения, -1 - ничего не изменяли)
  )
  is
    RJB_J                   P8PNL_JB_JOBS%rowtype;         -- Запись работы в буфере балансировки
    RJB_P                   P8PNL_JB_PRJCTS%rowtype;       -- Запись родительского проекта в буфере балансировки
    RJ                      PROJECTJOB%rowtype;            -- Запись работы в проекте
    NCHANGE_FLAG            PKG_STD.TNUMBER := 0;          -- Флаг изменения данных (0 - нечего менять, 1 - дата начала изменилась, 2 - дата окончания изменилась)
    NDELTA                  PKG_STD.TNUMBER;               -- Изменение даты
    SUTILIZER               PKG_STD.TSTRING := UTILIZER(); -- Пользователь сеанса
  begin
    /* Считаем работу из буфера */
    RJB_J := JB_JOBS_GET(NJB_JOBS => NJB_JOBS);
    /* Считаем проект из буфера */
    RJB_P := JB_PRJCTS_GET(NJB_PRJCTS => RJB_J.PRN);
    /* Считаем работу проекта */
    RJ := JOBS_GET(NRN => RJB_J.SOURCE);
    /* Проверки - это должна быть работа */
    if (RJB_J.STAGE = 1) then
      P_EXCEPTION(0, 'Изменение сроков допустимо только для работ.');
    end if;
    /* Проверки - пользователь должен быть ответственным за проект */
    if (CHECK_RESPONSIBLE(NRN => RJB_P.PROJECT, SAUTHID => SUTILIZER) <> 1) then
      P_EXCEPTION(0, 'Вы не являетесь ответственным за данный проект.');
    end if;
    /* Проверки - работа должна иметь фиксированную длительность */
    if (RJ.DURATION_CHG <> 2) then
      P_EXCEPTION(0, 'Работа должна иметь фиксированную длительность.');
    end if;
    /* Определимся с тем, что будем менять и на сколько */
    if ((DDATE_FROM is not null) and (TRUNC(RJB_J.DATE_FROM) <> TRUNC(DDATE_FROM))) then
      NCHANGE_FLAG := 1;
      NDELTA       := TRUNC(DDATE_FROM) - TRUNC(RJB_J.DATE_FROM);
    end if;
    if ((DDATE_TO is not null) and (TRUNC(RJB_J.DATE_TO) <> TRUNC(DDATE_TO)) and (NCHANGE_FLAG = 0)) then
      NCHANGE_FLAG := 2;
      NDELTA       := TRUNC(DDATE_TO) - TRUNC(RJB_J.DATE_TO);
    end if;
    /* Если есть что менять */
    if (NCHANGE_FLAG <> 0) then
      /* Изменяем работы */
      JB_JOBS_BASE_MODIFY_PERIOD(NJB_JOBS       => RJB_J.RN,
                                 NDELTA         => NDELTA,
                                 NCHANGE_FLAG   => NCHANGE_FLAG,
                                 DFACT          => DFACT,
                                 NDURATION_MEAS => NDURATION_MEAS);
      /* Выставим признак изменений в проекте */
      JB_PRJCTS_SET_CHANGED(NJB_PRJCTS => RJB_P.RN, NCHANGED => 1);
      /* Выполним пересчёт монитора */
      JB_PERIODS_RECALC(NIDENT => RJB_P.IDENT, DBEGIN => DBEGIN, NINITIAL => 0, NRESOURCE_STATUS => NRESOURCE_STATUS);
    else
      /* Ничего не изменили */
      NRESOURCE_STATUS := -1;
    end if;
  end JB_JOBS_MODIFY_PERIOD;
  
  /* Получение списка работ проектов для диаграммы Ганта */
  procedure JB_JOBS_LIST
  (
    NIDENT                  in number,                                -- Идентификатор процесса
    NPRN                    in number,                                -- Рег. номер родителя
    NINCLUDE_DEF            in number,                                -- Признак включения описания диаграммы в ответ
    COUT                    out clob                                  -- Список проектов
  )
  is
    /* Константы */
    SBG_COLOR_DANGER        constant PKG_STD.TSTRING := '#ff4d4d';    -- Цвет заливки проблемных задач
    SBG_COLOR_WARN          constant PKG_STD.TSTRING := 'orange';     -- Цвет заливки задач с предупреждениями
    SBG_COLOR_OK            constant PKG_STD.TSTRING := 'lightgreen'; -- Цвет заливки беспроблемных задач
    SBG_COLOR_DISABLED      constant PKG_STD.TSTRING := 'darkgrey';   -- Цвет заливки невыполняемых задач
    SBG_COLOR_STAGE         constant PKG_STD.TSTRING := 'cadetblue';  -- Цвет заливки этапов
    STEXT_COLOR_DANGER      constant PKG_STD.TSTRING := 'blue';       -- Цвет текста задач с предупреждениями

    /* Переменные */
    RJB_PRJ                 P8PNL_JB_PRJCTS%rowtype;                  -- Родительская запись буфера балансировки
    RPRJ                    PROJECT%rowtype;                          -- Запись проекта
    RSTG                    PROJECTSTAGE%rowtype;                     -- Запись этапа
    RJOB                    PROJECTJOB%rowtype;                       -- Запись работы
    RG                      PKG_P8PANELS_VISUAL.TGANTT;               -- Описание диаграммы Ганта
    RGT                     PKG_P8PANELS_VISUAL.TGANTT_TASK;          -- Описание задачи для диаграммы    
    STITLE                  PKG_STD.TSTRING;                          -- Общий заголовок
    BREAD_ONLY_DATES        boolean := false;                         -- Флаг доступности дат проекта только для чтения
    BTASK_READ_ONLY         boolean;                                  -- Флаг доступности задачи только для чтения
    STASK_BG_COLOR          PKG_STD.TSTRING;                          -- Цвет фона задачи
    STASK_TEXT_COLOR        PKG_STD.TSTRING;                          -- Цвет текста задачи
    STASK_CAPTION           PKG_STD.TSTRING;                          -- Заголовок задачи    
    NTASK_STATE             PKG_STD.TNUMBER;                          -- Состояние задачи
    NTASK_PROGRESS          PKG_STD.TNUMBER;                          -- Прогресс выполнения задачи    
    STASK_RESP              PKG_STD.TSTRING;                          -- Ответственный за исполнение задачи
  begin
    /* Читаем родительскую запись буфера балансировки */
    RJB_PRJ := JB_PRJCTS_GET(NJB_PRJCTS => NPRN);
    /* Читаем запись проекта */
    RPRJ := GET(NRN => RJB_PRJ.PROJECT);
    /* Определимся с возможностью изменения данных проекта */
    if (RJB_PRJ.EDITABLE = 0) then
      BREAD_ONLY_DATES := true;
    end if;
    /* Сформируем общий заголовок */
    STITLE := RPRJ.NAME_USL || ' - ' || RPRJ.NAME;
    if ((RPRJ.EXT_CUST is not null) or ((RPRJ.BEGPLAN is not null) and (RPRJ.ENDPLAN is not null))) then
      STITLE := STITLE || ' (';
      if (RPRJ.EXT_CUST is not null) then
        STITLE := STITLE || 'заказчик: "' ||
                  COALESCE(GET_AGNLIST_AGNABBR_ID(NFLAG_SMART => 1, NRN => RPRJ.EXT_CUST), '<НЕ ОПРЕДЕЛЁН>') || '", ';
      end if;
      if ((RPRJ.BEGPLAN is not null) and (RPRJ.ENDPLAN is not null)) then
        STITLE := STITLE || 'с ' || TO_CHAR(RPRJ.BEGPLAN, 'dd.mm.yyyy') || ' по ' ||
                  TO_CHAR(RPRJ.ENDPLAN, 'dd.mm.yyyy');
      end if;
      STITLE := STITLE || ')';
    end if;
    /* Инициализируем диаграмму Ганта */
    RG := PKG_P8PANELS_VISUAL.TGANTT_MAKE(STITLE              => STITLE,
                                          NZOOM               => PKG_P8PANELS_VISUAL.NGANTT_ZOOM_MONTH,
                                          BREAD_ONLY_DATES    => BREAD_ONLY_DATES,
                                          BREAD_ONLY_PROGRESS => true);
    /* Добавим динамические атрибуты к задачам */
    PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_ATTR(RGANTT => RG, SNAME => 'type', SCAPTION => 'Тип');
    PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_ATTR(RGANTT => RG, SNAME => 'state', SCAPTION => 'Состояние');
    PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_ATTR(RGANTT => RG, SNAME => 'resp', SCAPTION => 'Ответственный');
    /* Добавим описание цветов задач */
    PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_COLOR(RGANTT      => RG,
                                              SBG_COLOR   => SBG_COLOR_DANGER,
                                              STEXT_COLOR => STEXT_COLOR_DANGER,
                                              SDESC       => 'Для задач в состоянии "Не начата" - срыв срока начала, есть угроза срыва сроков окончания задачи. ' ||
                                                             'Для задач в состоянии "Выполняется", "Остановлена" - срыв срока окончания, есть угроза срыва срока окончания этапа/проекта.');
    PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_COLOR(RGANTT    => RG,
                                              SBG_COLOR => SBG_COLOR_WARN,
                                              SDESC     => 'Для задач в состоянии "Не начата" - приближается срок начала, важно обеспечить своевременное выполнение работ. ' ||
                                                           'Для задач в состоянии "Выполняется", "Остановлена" - приближается срок окончания, важно обеспечить своевременное завершение работ.');
    PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_COLOR(RGANTT    => RG,
                                              SBG_COLOR => SBG_COLOR_OK,
                                              SDESC     => 'Сроки исполнения задачи не вызывают опасений.');
    PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_COLOR(RGANTT    => RG,
                                              SBG_COLOR => SBG_COLOR_DISABLED,
                                              SDESC     => 'Задача не выполняется (она в состоянии "Выполнена" или "Отменена").');
    PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK_COLOR(RGANTT    => RG,
                                              SBG_COLOR => SBG_COLOR_STAGE,
                                              SDESC     => 'Этим цветом выделены этапы.');
    /* Обходим работы */
    for C in (select JB.*
                from P8PNL_JB_JOBS   JB,
                     P8PNL_JB_PRJCTS PB,
                     PROJECT         P
               where JB.IDENT = NIDENT
                 and JB.PRN = NPRN
                 and JB.PRN = PB.RN
                 and PB.PROJECT = P.RN
                 and exists (select null from V_USERPRIV UP where UP.CATALOG = P.CRN)
                 and exists (select null
                        from V_USERPRIV UP
                       where UP.JUR_PERS = P.JUR_PERS
                         and UP.UNITCODE = 'Projects')
               order by JB.RN)
    loop
      /* Считаем источник - этап или работу проекта, здесь же найдём ответственного */
      STASK_RESP := null;
      if (C.STAGE = 1) then
        RSTG := STAGES_GET(NRN => C.SOURCE);
        if (RSTG.RESPONSIBLE is not null) then
          STASK_RESP := GET_AGNLIST_AGNABBR_ID(NFLAG_SMART => 1, NRN => RSTG.RESPONSIBLE);
        elsif (RSTG.SUBDIV_RESP is not null) then
          STASK_RESP := UTL_INS_DEPARTMENT_GET_NAME(NRN => RSTG.SUBDIV_RESP);
        end if;
      else
        RJOB := JOBS_GET(NRN => C.SOURCE);
        if (RJOB.PERFORM is not null) then
          STASK_RESP := GET_AGNLIST_AGNABBR_ID(NFLAG_SMART => 1, NRN => RJOB.PERFORM);
        elsif (RJOB.SUBDIV is not null) then
          STASK_RESP := UTL_INS_DEPARTMENT_GET_NAME(NRN => RJOB.SUBDIV);
        end if;
      end if;
      /* Определимся с состоянием */
      if (C.STAGE = 1) then
        NTASK_STATE := RSTG.STATE;
      else
        NTASK_STATE := RJOB.STATE;
      end if;
      /* Определимся с форматированием */
      if (C.STAGE = 1) then
        /* Этапы всегда одинаково красим */
        STASK_BG_COLOR := SBG_COLOR_STAGE;
      else
        /* Сбросим цвета от предыдущей работы (на всякий случай) */
        STASK_BG_COLOR   := null;
        STASK_TEXT_COLOR := null;
        /* Работы - от статуса ("Не начата") */
        if (RJOB.STATE = 0) then
          if (C.DATE_FROM <= sysdate) then
            STASK_BG_COLOR   := SBG_COLOR_DANGER;
            STASK_TEXT_COLOR := STEXT_COLOR_DANGER;
          elsif (C.DATE_FROM <= sysdate + NDAYS_LEFT_LIMIT) then
            STASK_BG_COLOR := SBG_COLOR_WARN;
          else
            STASK_BG_COLOR := SBG_COLOR_OK;
          end if;
        end if;
        /* Работы - от статуса ("Выполняется", "Остановлена") */
        if (RJOB.STATE in (1, 3)) then
          if (C.DATE_TO <= sysdate) then
            STASK_BG_COLOR   := SBG_COLOR_DANGER;
            STASK_TEXT_COLOR := STEXT_COLOR_DANGER;
          elsif (C.DATE_TO <= sysdate + NDAYS_LEFT_LIMIT) then
            STASK_BG_COLOR := SBG_COLOR_WARN;
          else
            STASK_BG_COLOR := SBG_COLOR_OK;
          end if;
        end if;
        /* Работы - от статуса ("Выполнена", "Отменена") */
        if (RJOB.STATE in (2, 4)) then
          /* Всегда тёмные */
          STASK_BG_COLOR := SBG_COLOR_DISABLED;
        end if;
      end if;
      /* Определимся с возможностью редактирования */
      BTASK_READ_ONLY := false;
      if (C.EDITABLE = 0) then
        BTASK_READ_ONLY := true;
      end if;
      /* Сформируем заголовок для выдачи в диаграмме */
      STASK_CAPTION := trim(C.NUMB) || ' - ' || C.NAME;
      if (LENGTH(STASK_CAPTION) > NGANTT_TASK_CAPTION_LEN) then
        STASK_CAPTION := SUBSTR(STASK_CAPTION, 1, NGANTT_TASK_CAPTION_LEN) || '...';
      end if;
      /* Определим прогресс (только для работ в статусах "Выполняется" и "Остановлена") */
      if ((C.STAGE = 0) and (RJOB.STATE in (1, 3)) and (RJOB.LAB_PLAN > 0)) then
        NTASK_PROGRESS := RJOB.LAB_FACT / RJOB.LAB_PLAN * 100;
      else
        NTASK_PROGRESS := null;
      end if;
      /* Сформируем работу */
      RGT := PKG_P8PANELS_VISUAL.TGANTT_TASK_MAKE(NRN                 => C.RN,
                                                  SNUMB               => C.NUMB,
                                                  SCAPTION            => STASK_CAPTION,
                                                  SNAME               => C.NAME,
                                                  DSTART              => C.DATE_FROM,
                                                  DEND                => C.DATE_TO,
                                                  NPROGRESS           => NTASK_PROGRESS,
                                                  SBG_COLOR           => STASK_BG_COLOR,
                                                  STEXT_COLOR         => STASK_TEXT_COLOR,
                                                  BREAD_ONLY          => BTASK_READ_ONLY,
                                                  BREAD_ONLY_PROGRESS => true);
      PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_ATTR_VAL(RGANTT => RG,
                                                   RTASK  => RGT,
                                                   SNAME  => 'type',
                                                   SVALUE => C.STAGE,
                                                   BCLEAR => true);
      PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_ATTR_VAL(RGANTT => RG, RTASK => RGT, SNAME => 'state', SVALUE => NTASK_STATE);
      PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_ATTR_VAL(RGANTT => RG, RTASK => RGT, SNAME => 'resp', SVALUE => STASK_RESP);
      /* Определимся с предшествующими работами */
      for CP in (select JP.JB_JOBS
                   from P8PNL_JB_JOBSPREV JP
                  where JP.IDENT = NIDENT
                    and JP.PRN = C.RN)
      loop
        PKG_P8PANELS_VISUAL.TGANTT_TASK_ADD_DEPENDENCY(RTASK => RGT, NDEPENDENCY => CP.JB_JOBS);
      end loop;
      /* Добавляем работу в диаграмму */
      PKG_P8PANELS_VISUAL.TGANTT_ADD_TASK(RGANTT => RG, RTASK => RGT);
    end loop;
    /* Проверим, что есть хоть что-то для отображения */
    if (RG.RTASKS.COUNT = 0) then
      P_EXCEPTION(0,
                  'Для проекта не определены этапы/работы, отображение которых допустимо в диаграмме (убедитесь, что для них в учётных данных заданы плановые даты начала/окончания).');
    end if;
    /* Формируем список */
    COUT := PKG_P8PANELS_VISUAL.TGANTT_TO_XML(RGANTT => RG, NINCLUDE_DEF => NINCLUDE_DEF);
  end JB_JOBS_LIST;
  
  /* Базовое добавление предшествующей работы/этапа для балансировки работ */
  procedure JB_JOBSPREV_BASE_INSERT
  (    
    NIDENT                  in number, -- Идентификатор процесса
    NPRN                    in number, -- Рег. номер родителя
    NJB_JOBS                in number, -- Рег. номер предшествующей работы/этапа
    NJB_JOBSPREV            out number -- Рег. номер записи предшествующей балансируемой работы/этапа
  )
  is
  begin
    /* Сформируем рег. номер записи */
    NJB_JOBSPREV := GEN_ID();
    /* Добавим запись */
    insert into P8PNL_JB_JOBSPREV (RN, IDENT, PRN, JB_JOBS) values (NJB_JOBSPREV, NIDENT, NPRN, NJB_JOBS);
  end JB_JOBSPREV_BASE_INSERT;
  
  /* Считывание записи периода из буфера балансировки работ */
  function JB_PERIODS_GET
  (
    NJB_PERIODS             in number                 -- Рег. номер записи периода в буфере балансировки
  ) return                  P8PNL_JB_PERIODS%rowtype  -- Запись периода
  is
    RRES                    P8PNL_JB_PERIODS%rowtype; -- Буфер для результата
  begin
    select P.* into RRES from P8PNL_JB_PERIODS P where P.RN = NJB_PERIODS;
    return RRES;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0, NDOCUMENT => NJB_PERIODS, SUNIT_TABLE => 'P8PNL_JB_PERIODS');
  end JB_PERIODS_GET;
  
  /* Получение списка для детализации трудоёмкости по ФОТ периода балансировки */
  procedure JB_PERIODS_LIST_PLAN_FOT
  (
    NJB_PERIODS             in number,                             -- Рег. номер записи периода в буфере балансировки
    NPAGE_NUMBER            in number,                             -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,                             -- Количество записей на странице (0 - все)
    CORDERS                 in clob,                               -- Сортировки    
    NINCLUDE_DEF            in number,                             -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob                               -- Сериализованная таблица данных
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
    RPRD                    P8PNL_JB_PERIODS%rowtype;              -- Запись детализируемого периода
    RO                      PKG_P8PANELS_VISUAL.TORDERS;           -- Сортировки
    RDG                     PKG_P8PANELS_VISUAL.TDATA_GRID;        -- Описание таблицы
    RDG_ROW                 PKG_P8PANELS_VISUAL.TROW;              -- Строка таблицы
    CSQL                    clob;                                  -- Буфер для запроса
    ICURSOR                 integer;                               -- Курсор для исполнения запроса
    NROW_FROM               PKG_STD.TREF;                          -- Номер строки с
    NROW_TO                 PKG_STD.TREF;                          -- Номер строки по    
  begin
    /* Считаем детализируемую запись периода */
    RPRD := JB_PERIODS_GET(NJB_PERIODS => NJB_PERIODS);
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
                                               SNAME      => 'SPERSON',
                                               SCAPTION   => 'Сотрудник',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BORDER     => true,
                                               BFILTER    => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NLAB_PLAN_FOT',
                                               SCAPTION   => 'Трудоёмкость',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BORDER     => false,
                                               BFILTER    => false);
    /* Обходим данные */
    begin
      /* Добавляем подсказку совместимости */
      CSQL := PKG_SQL_BUILD.COMPATIBLE(SSQL => CSQL);
      /* Формируем запрос */
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => 'select *');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '  from (select D.*,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.SQLROWNUM() || ' NROW');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '          from (select FM.RN NRN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       PERS.CODE SPERSON,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       SH.AVG_HOURS NLAB_PLAN_FOT');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  from CLNPSPFM   FM,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       CLNPERSONS PERS,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       CLNPSDEP   PSD,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       PRPROF     PROF,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       CLNPSPFMHS FMH,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       SLSCHEDULE SH');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                 where FM.COMPANY = :NCOMPANY');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and FM.PERSRN = PERS.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and FM.DEPTRN = :NINS_DEPARTMENT');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and FM.PSDEPRN = PSD.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and PSD.PRPROF = PROF.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and PROF.RN in (select MP.PRPROF from FCMANPOWER MP where MP.RN = :NFCMANPOWER)');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and ((FM.BEGENG between :DDATE_FROM and :DDATE_TO) or (FM.ENDENG between :DDATE_FROM and :DDATE_TO) or');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       ((FM.BEGENG < :DDATE_FROM) and (COALESCE(FM.ENDENG, :DDATE_TO + 1) > :DDATE_TO)))');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and FM.RN = FMH.PRN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and ((FMH.DO_ACT_FROM between :DDATE_FROM and :DDATE_TO) or (FMH.DO_ACT_TO between :DDATE_FROM and :DDATE_TO) or');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       ((FMH.DO_ACT_FROM < :DDATE_FROM) and (COALESCE(FMH.DO_ACT_TO, :DDATE_TO + 1) > :DDATE_TO)))');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and FMH.SCHEDULE = SH.RN %ORDER_BY%) D) F');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => ' where F.NROW between :NROW_FROM and :NROW_TO');
      /* Учтём сортировки */
      PKG_P8PANELS_VISUAL.TORDERS_SET_QUERY(RDATA_GRID => RDG, RORDERS => RO, SPATTERN => '%ORDER_BY%', CSQL => CSQL);
      /* Разбираем его */
      ICURSOR := PKG_SQL_DML.OPEN_CURSOR(SWHAT => 'SELECT');
      PKG_SQL_DML.PARSE(ICURSOR => ICURSOR, SQUERY => CSQL);
      /* Делаем подстановку параметров */
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NCOMPANY', NVALUE => NCOMPANY);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NINS_DEPARTMENT', NVALUE => RPRD.INS_DEPARTMENT);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NFCMANPOWER', NVALUE => RPRD.FCMANPOWER);
      PKG_SQL_DML.BIND_VARIABLE_DATE(ICURSOR => ICURSOR, SNAME => 'DDATE_FROM', DVALUE => RPRD.DATE_FROM);
      PKG_SQL_DML.BIND_VARIABLE_DATE(ICURSOR => ICURSOR, SNAME => 'DDATE_TO', DVALUE => RPRD.DATE_TO);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_FROM', NVALUE => NROW_FROM);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_TO', NVALUE => NROW_TO);
      /* Описываем структуру записи курсора */
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 1);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 2);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 3);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 4);
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
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SPERSON', ICURSOR => ICURSOR, NPOSITION => 2);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NLAB_PLAN_FOT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 3);
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
  end JB_PERIODS_LIST_PLAN_FOT;
  
  /* Получение плановой трудоёмкости по ФОТ для периода балансировки (в часах) */
  function JB_PERIODS_GET_PLAN_FOT
  (
    NCOMPANY                in number,       -- Рег. номер организации
    DDATE_FROM              in date,         -- Начало
    DDATE_TO                in date,         -- Окончание
    NINS_DEPARTMENT         in number,       -- Рег. номер штатного подразделения
    NFCMANPOWER             in number        -- Рег. номер трудового ресурса
  ) return                  number           -- Плановая трудоёмкость по ФОТ (в часах)
  is
    NRES                    PKG_STD.TNUMBER; -- Плановая трудоёмкость по ФОТ
  begin
    /* Обойдем подходящие исполнения и просуммируем среднемесячную численность часов */
    select sum(SH.AVG_HOURS)
      into NRES
      from CLNPSPFM   FM,
           CLNPSDEP   PSD,
           PRPROF     PROF,
           CLNPSPFMHS FMH,
           SLSCHEDULE SH
     where FM.COMPANY = NCOMPANY
       and FM.DEPTRN = NINS_DEPARTMENT
       and FM.PSDEPRN = PSD.RN
       and PSD.PRPROF = PROF.RN
       and PROF.RN in (select MP.PRPROF from FCMANPOWER MP where MP.RN = NFCMANPOWER)
       and ((FM.BEGENG between DDATE_FROM and DDATE_TO) or (FM.ENDENG between DDATE_FROM and DDATE_TO) or
           ((FM.BEGENG < DDATE_FROM) and (COALESCE(FM.ENDENG, DDATE_TO + 1) > DDATE_TO)))
       and FM.RN = FMH.PRN
       and ((FMH.DO_ACT_FROM between DDATE_FROM and DDATE_TO) or (FMH.DO_ACT_TO between DDATE_FROM and DDATE_TO) or
           ((FMH.DO_ACT_FROM < DDATE_FROM) and (COALESCE(FMH.DO_ACT_TO, DDATE_TO + 1) > DDATE_TO)))
       and FMH.SCHEDULE = SH.RN;
    /* Вернём собранный результат */
    return COALESCE(NRES, 0);
  end JB_PERIODS_GET_PLAN_FOT;
  
  /* Получение списка для детализации трудоёмкости периода балансировки по текущему состоянию графика */
  procedure JB_PERIODS_LIST_PLAN_JOBS
  (
    NJB_PERIODS             in number,                             -- Рег. номер записи периода в буфере балансировки
    NPAGE_NUMBER            in number,                             -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,                             -- Количество записей на странице (0 - все)
    CORDERS                 in clob,                               -- Сортировки    
    NINCLUDE_DEF            in number,                             -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob                               -- Сериализованная таблица данных
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
    RPRD                    P8PNL_JB_PERIODS%rowtype;              -- Запись детализируемого периода
    RO                      PKG_P8PANELS_VISUAL.TORDERS;           -- Сортировки
    RDG                     PKG_P8PANELS_VISUAL.TDATA_GRID;        -- Описание таблицы
    RDG_ROW                 PKG_P8PANELS_VISUAL.TROW;              -- Строка таблицы
    CSQL                    clob;                                  -- Буфер для запроса
    ICURSOR                 integer;                               -- Курсор для исполнения запроса
    NROW_FROM               PKG_STD.TREF;                          -- Номер строки с
    NROW_TO                 PKG_STD.TREF;                          -- Номер строки по
    DBEG                    PKG_STD.TLDATE;                        -- Дата начала для расчёта трудоёмкости текущей работы
    DEND                    PKG_STD.TLDATE;                        -- Дата окончания для расчёта трудоёмкости текущей работы
    DJOB_BEG                PKG_STD.TLDATE;                        -- Дата начала текущей работы согласно плану-груфику
    DJOB_END                PKG_STD.TLDATE;                        -- Дата окончания текущей работы согласно плану-груфику
    NJOB_DUR                PKG_STD.TNUMBER;                       -- Длительнось текущей работы согласно плану-груфику
    NMP_LAB                 PKG_STD.TNUMBER;                       -- Трудоёмкость трудового ресурса в текущей работе согласно проекта
    NMP_LAB_ONE             PKG_STD.TNUMBER;                       -- Трудоёмкость (за единицу длительности) трудового ресурса в текущей работе согласно проекта
    NMP_LAB_PLAN            PKG_STD.TNUMBER;                       -- Трудоёмкость трудового ресурса в текущей работе согласно плана-графика
  begin
    /* Считаем детализируемую запись периода */
    RPRD := JB_PERIODS_GET(NJB_PERIODS => NJB_PERIODS);
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
                                               SNAME      => 'NPROJECT',
                                               SCAPTION   => 'Рег. номер проекта',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NJB_PRJCTS',
                                               SCAPTION   => 'Рег. номер буфера балансировки проекта',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SPRJ',
                                               SCAPTION   => 'Проект',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BORDER     => true,
                                               BFILTER    => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SSTG_JOB',
                                               SCAPTION   => 'Этап-работа',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BORDER     => true,
                                               BFILTER    => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SJOB_NAME',
                                               SCAPTION   => 'Наим. работы',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BORDER     => true,
                                               BFILTER    => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NJOB_STATE',
                                               SCAPTION   => 'Сост. работы',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BORDER     => true,
                                               BFILTER    => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DJOB_BEG',
                                               SCAPTION   => 'Начало работы',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               BORDER     => true,
                                               BFILTER    => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DJOB_END',
                                               SCAPTION   => 'Окончание работы',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               BORDER     => true,
                                               BFILTER    => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NJOB_DUR',
                                               SCAPTION   => 'Длительн. работы',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BORDER     => false,
                                               BFILTER    => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NMP_LAB',
                                               SCAPTION   => 'Труд.',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BORDER     => false,
                                               BFILTER    => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NMP_LAB_ONE',
                                               SCAPTION   => 'Труд. (в ед. длит.)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BORDER     => false,
                                               BFILTER    => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NMP_LAB_PLAN',
                                               SCAPTION   => 'Труд. (план, график)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BORDER     => false,
                                               BFILTER    => false);
    /* Обходим данные */
    begin
      /* Добавляем подсказку совместимости */
      CSQL := PKG_SQL_BUILD.COMPATIBLE(SSQL => CSQL);
      /* Формируем запрос */
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => 'select *');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '  from (select D.*,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.SQLROWNUM() || ' NROW');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '         from (select JB.RN NRN,');                                     
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                      P.RN NPROJECT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                      JBP.RN NJB_PRJCTS,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                      P.CODE || ''-'' || P.NAME_USL SPRJ,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                      trim(PS.NUMB) || ''-'' || trim(PJ.NUMB) SSTG_JOB,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                      PJ.NAME SJOB_NAME,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                      PJ.STATE NJOB_STATE,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                      JB.DATE_FROM DJOB_BEG,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                      JB.DATE_TO DJOB_END,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                      PJMP.LABOUR_P NLABOUR_P');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                 from P8PNL_JB_JOBS JB,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                      P8PNL_JB_PRJCTS JBP,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                      PROJECTJOB PJ');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                      left outer join PROJECTSTAGE PS on PJ.PROJECTSTAGE = PS.RN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                      PROJECTJOBMANPOW PJMP,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                      PROJECT P');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                where JB.IDENT = :NIDENT');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  and JB.STAGE = ' || PKG_SQL_BUILD.WRAP_NUM(NVALUE => 0));
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  and JB.PRN = JBP.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  and JB.SOURCE = PJ.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  and PJ.COMPANY = :NCOMPANY');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  and PJ.PRN = P.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  and PJ.RN = PJMP.PRN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  and PJMP.FCMANPOWER = :NFCMANPOWER');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  and PJMP.SUBDIV = :NINS_DEPARTMENT');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  and ((JB.DATE_FROM between :DDATE_FROM and :DDATE_TO) or (JB.DATE_TO between :DDATE_FROM and :DDATE_TO) or');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                      ((JB.DATE_FROM < :DDATE_FROM) and (JB.DATE_TO > :DDATE_TO))) %ORDER_BY%) D) F');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => ' where F.NROW between :NROW_FROM and :NROW_TO');
      /* Учтём сортировки */
      PKG_P8PANELS_VISUAL.TORDERS_SET_QUERY(RDATA_GRID => RDG, RORDERS => RO, SPATTERN => '%ORDER_BY%', CSQL => CSQL);
      /* Разбираем его */
      ICURSOR := PKG_SQL_DML.OPEN_CURSOR(SWHAT => 'SELECT');
      PKG_SQL_DML.PARSE(ICURSOR => ICURSOR, SQUERY => CSQL);
      /* Делаем подстановку параметров */
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NCOMPANY', NVALUE => NCOMPANY);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NIDENT', NVALUE => RPRD.IDENT);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NINS_DEPARTMENT', NVALUE => RPRD.INS_DEPARTMENT);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NFCMANPOWER', NVALUE => RPRD.FCMANPOWER);
      PKG_SQL_DML.BIND_VARIABLE_DATE(ICURSOR => ICURSOR, SNAME => 'DDATE_FROM', DVALUE => RPRD.DATE_FROM);
      PKG_SQL_DML.BIND_VARIABLE_DATE(ICURSOR => ICURSOR, SNAME => 'DDATE_TO', DVALUE => RPRD.DATE_TO);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_FROM', NVALUE => NROW_FROM);
      PKG_SQL_DML.BIND_VARIABLE_NUM(ICURSOR => ICURSOR, SNAME => 'NROW_TO', NVALUE => NROW_TO);
      /* Описываем структуру записи курсора */
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 1);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 2);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 3);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 4);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 5);
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 6);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 7);
      PKG_SQL_DML.DEFINE_COLUMN_DATE(ICURSOR => ICURSOR, IPOSITION => 8);
      PKG_SQL_DML.DEFINE_COLUMN_DATE(ICURSOR => ICURSOR, IPOSITION => 9);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 10);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 11);
      /* Делаем выборку */
      if (PKG_SQL_DML.EXECUTE(ICURSOR => ICURSOR) = 0) then
        null;
      end if;
      /* Обходим выбранные записи */
      while (PKG_SQL_DML.FETCH_ROWS(ICURSOR => ICURSOR) > 0)
      loop
        /* Вычислим трудоёмкость в датлизируемом периоде по буферу балансировки */
        PKG_SQL_DML.COLUMN_VALUE_DATE(ICURSOR => ICURSOR, IPOSITION => 8, DVALUE => DJOB_BEG);
        PKG_SQL_DML.COLUMN_VALUE_DATE(ICURSOR => ICURSOR, IPOSITION => 9, DVALUE => DJOB_END);
        PKG_SQL_DML.COLUMN_VALUE_NUM(ICURSOR => ICURSOR, IPOSITION => 10, NVALUE => NMP_LAB);
        P_PROJECTJOB_GET_DURATION(NCOMPANY       => NCOMPANY,
                                  DBEG_DATE      => DJOB_BEG,
                                  DEND_DATE      => DJOB_END,
                                  NDURATION_MEAS => NJB_DURATION_MEAS,
                                  NDURATION      => NJOB_DUR);
        DBEG := RPRD.DATE_FROM;
        if (DJOB_BEG > RPRD.DATE_FROM) then
          DBEG := DJOB_BEG;
        end if;
        DEND := RPRD.DATE_TO;
        if (DJOB_END < RPRD.DATE_TO) then
          DEND := DJOB_END;
        end if;
        if (DJOB_END - DJOB_BEG <> 0) then
          NMP_LAB_ONE := NMP_LAB / (DJOB_END - DJOB_BEG);
        else
          NMP_LAB_ONE := NMP_LAB;
        end if;
      
        NMP_LAB_PLAN := (DEND - DBEG) * NMP_LAB_ONE;
        /* Добавляем колонки с данными */
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NRN',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 1,
                                              BCLEAR    => true);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW => RDG_ROW, SNAME => 'NPROJECT', ICURSOR => ICURSOR, NPOSITION => 2);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NJB_PRJCTS',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 3);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SPRJ', ICURSOR => ICURSOR, NPOSITION => 4);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SSTG_JOB', ICURSOR => ICURSOR, NPOSITION => 5);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SJOB_NAME',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 6);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NJOB_STATE',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 7);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'DJOB_BEG', DVALUE => DJOB_BEG);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'DJOB_END', DVALUE => DJOB_END);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NJOB_DUR', NVALUE => NJOB_DUR);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NMP_LAB', NVALUE => NMP_LAB);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NMP_LAB_ONE', NVALUE => NMP_LAB_ONE);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'NMP_LAB_PLAN', NVALUE => NMP_LAB_PLAN);
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
  end JB_PERIODS_LIST_PLAN_JOBS;
  
  /* Получение плановой трудоёскости по текущему состоянию графиков в буфере балансировки для периода балансировки */
  function JB_PERIODS_GET_PLAN_JOBS
  (
    NIDENT                  in number,       -- Идентификатор процесса
    DDATE_FROM              in date,         -- Начало
    DDATE_TO                in date,         -- Окончание
    NINS_DEPARTMENT         in number,       -- Рег. номер штатного подразделения
    NFCMANPOWER             in number        -- Рег. номер трудового ресурса
  ) return                  number           -- Плановая трудоёмкость по текущему состоянию графиков в буфере балансировки
  is
    NRES                    PKG_STD.TNUMBER; -- Буфер для результата
    NPLAN_JOB               PKG_STD.TNUMBER; -- Плановая трудоёмкость текущей работы согласно графика
    DBEG                    PKG_STD.TLDATE;  -- Дата начала для расчёта трудоёмкости текущей работы
    DEND                    PKG_STD.TLDATE;  -- Дата окончания для расчёта трудоёмкости текущей работы
  begin
    /* Обходим все работы в буфере подходящие по условиям */
    for C in (select JB.*,
                     PJMP.LABOUR_P
                from P8PNL_JB_JOBS    JB,
                     PROJECTJOB       PJ,
                     PROJECTJOBMANPOW PJMP
               where JB.IDENT = NIDENT
                 and JB.STAGE = 0
                 and JB.SOURCE = PJ.RN
                 and PJ.RN = PJMP.PRN
                 and PJMP.FCMANPOWER = NFCMANPOWER
                 and PJMP.SUBDIV = NINS_DEPARTMENT
                 and ((JB.DATE_FROM between DDATE_FROM and DDATE_TO) or (JB.DATE_TO between DDATE_FROM and DDATE_TO) or
                     ((JB.DATE_FROM < DDATE_FROM) and (JB.DATE_TO > DDATE_TO))))
    loop
      /* Вычислим трудоёмкость по графику для попавшейся работы */
      DBEG := DDATE_FROM;
      if (C.DATE_FROM > DDATE_FROM) then
        DBEG := C.DATE_FROM;
      end if;
      DEND := DDATE_TO;
      if (C.DATE_TO < DDATE_TO) then
        DEND := C.DATE_TO;
      end if;
      if (C.LABOUR_P <> 0) then
        if (C.DATE_TO - C.DATE_FROM <> 0) then
          NPLAN_JOB := (DEND - DBEG) * (C.LABOUR_P / (C.DATE_TO - C.DATE_FROM));
        else
          NPLAN_JOB := (DEND - DBEG) * C.LABOUR_P;
        end if;
      else
        NPLAN_JOB := 0;
      end if;
      /* Накопим сумму в буфере результата */
      NRES := COALESCE(NRES, 0) + NPLAN_JOB;
    end loop;
    /* Вернём собранный результат */
    return COALESCE(NRES, 0);
  end JB_PERIODS_GET_PLAN_JOBS;
  
  /* Базовое добавление периода балансировки работ */
  procedure JB_PERIODS_BASE_INSERT
  (
    NIDENT                  in number,      -- Идентификатор процесса
    DDATE_FROM              in date,        -- Начало
    DDATE_TO                in date,        -- Окончание
    NINS_DEPARTMENT         in number,      -- Рег. номер штатного подразделения
    NFCMANPOWER             in number,      -- Рег. номер трудового ресурса
    NLAB_PLAN_FOT           in number := 0, -- Трудоёмкость (план, по ФОТ)
    NLAB_FACT_RPT           in number := 0, -- Трудоёмкость (факт, по отчёту)
    NLAB_PLAN_JOBS          in number := 0, -- Трудоёмкость (план, по графику)
    NJB_PERIODS             out number      -- Рег. номер записи периода балансировки
  )
  is
  begin
    /* Сформируем рег. номер записи */
    NJB_PERIODS := GEN_ID();
    /* Добавим запись */
    insert into P8PNL_JB_PERIODS
      (RN,
       IDENT,
       DATE_FROM,
       DATE_TO,
       INS_DEPARTMENT,
       FCMANPOWER,
       LAB_PLAN_FOT,
       LAB_FACT_RPT,
       LAB_PLAN_JOBS)
    values
      (NJB_PERIODS,
       NIDENT,
       DDATE_FROM,
       DDATE_TO,
       NINS_DEPARTMENT,
       NFCMANPOWER,
       NLAB_PLAN_FOT,
       NLAB_FACT_RPT,
       NLAB_PLAN_JOBS);
  end JB_PERIODS_BASE_INSERT;
  
  /* Очистка периодов балансировки */
  procedure JB_PERIODS_CLEAN
  (
    NIDENT                  in number   -- Идентификатор процесса
  )
  is
  begin
    /* Удаляем периоды балансировки */
    delete from P8PNL_JB_PERIODS T where T.IDENT = NIDENT;
  end JB_PERIODS_CLEAN;
  
  /* Пересчёт периодов балансировки */
  procedure JB_PERIODS_RECALC
  (
    NIDENT                  in number,                             -- Идентификатор процесса
    DBEGIN                  in date,                               -- Дата начала периода мониторинга загрузки ресурсов
    NINITIAL                in number,                             -- Признак первоначального рассчёта (0 - пересчёт, 1 - первоначальный рассчёт)
    NRESOURCE_STATUS        out number                             -- Состояние ресурсов (0 - без отклонений, 1 - есть отклонения)
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
    DJB_BEG                 PKG_STD.TLDATE;                        -- Дата начала периода балансировки
    DJB_END                 PKG_STD.TLDATE;                        -- Дата окончания периода балансировки
    DBEG                    PKG_STD.TLDATE;                        -- Дата начала текущего месяца периода балансировки
    DEND                    PKG_STD.TLDATE;                        -- Дата окончания текущего месяца периода балансировки
    NJB_PERIODS             PKG_STD.TREF;                          -- Рег. номер добавленного периода балансировки
    NLAB_PLAN_FOT           PKG_STD.TNUMBER;                       -- Плановая трудоёмкость по ФОТ для текущего месяца периода балансировки
    NLAB_PLAN_JOBS          PKG_STD.TNUMBER;                       -- Плановая трудоёмкость по плану-графику в буфере для текущего месяца периода балансировки
  begin    
    /* Подчистка при перерасчёте */
    if (NINITIAL = 0) then
      JB_PERIODS_CLEAN(NIDENT => NIDENT);
    end if;
    /* Скажем, что нет отклонений */
    NRESOURCE_STATUS := 0;
    /* Определим период балансировки */
    DJB_BEG := DBEGIN;
    DJB_END := JB_GET_END(NIDENT => NIDENT);
    /* Сформируем записи периодов балансировки */
    for I in 0 .. FLOOR(MONTHS_BETWEEN(DJB_END, DJB_BEG))
    loop
      DBEG := TRUNC(ADD_MONTHS(DJB_BEG, I), 'mm');
      DEND := LAST_DAY(DBEG);
      /* Определим подразделения, занятые в работах в этом месяце */
      for D in (select JMP.FCMANPOWER,
                       JMP.SUBDIV
                  from P8PNL_JB_JOBS    JB,
                       PROJECTJOB       J,
                       PROJECTJOBMANPOW JMP
                 where JB.IDENT = NIDENT
                   and JB.STAGE = 0
                   and ((JB.DATE_FROM between DBEG and DEND) or (JB.DATE_TO between DBEG and DEND) or
                       ((JB.DATE_FROM < DBEG) and (JB.DATE_TO > DEND)))
                   and JB.SOURCE = J.RN
                   and J.RN = JMP.PRN
                   and JMP.SUBDIV is not null
                 group by JMP.FCMANPOWER,
                          JMP.SUBDIV)
      loop
        /* Рассчитаем трудоёмкость по ФОТ (в часах) */
        NLAB_PLAN_FOT := JB_PERIODS_GET_PLAN_FOT(NCOMPANY        => NCOMPANY,
                                                 DDATE_FROM      => DBEG,
                                                 DDATE_TO        => DEND,
                                                 NINS_DEPARTMENT => D.SUBDIV,
                                                 NFCMANPOWER     => D.FCMANPOWER);
        /* Рассчитаем трудоёмкость по работам графика */
        NLAB_PLAN_JOBS := JB_PERIODS_GET_PLAN_JOBS(NIDENT          => NIDENT,
                                                   DDATE_FROM      => DBEG,
                                                   DDATE_TO        => DEND,
                                                   NINS_DEPARTMENT => D.SUBDIV,
                                                   NFCMANPOWER     => D.FCMANPOWER);
        /* Добавим запись периода балансировки */
        JB_PERIODS_BASE_INSERT(NIDENT          => NIDENT,
                               DDATE_FROM      => DBEG,
                               DDATE_TO        => DEND,
                               NINS_DEPARTMENT => D.SUBDIV,
                               NFCMANPOWER     => D.FCMANPOWER,
                               NLAB_PLAN_FOT   => NLAB_PLAN_FOT,
                               NLAB_FACT_RPT   => 0,
                               NLAB_PLAN_JOBS  => NLAB_PLAN_JOBS,
                               NJB_PERIODS     => NJB_PERIODS);
        /* Если плановая трудоёмкость по работам графика превысила ФОТ - значит с ресурсами всё плохо */
        if (NLAB_PLAN_JOBS > NLAB_PLAN_FOT) then
          NRESOURCE_STATUS := 1;
        end if;
      end loop;
    end loop;
  end JB_PERIODS_RECALC;
  
  /* Список периодов балансировки */
  procedure JB_PERIODS_LIST
  (
    NIDENT                  in number,                      -- Идентификатор процесса
    NPAGE_NUMBER            in number,                      -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,                      -- Количество записей на странице (0 - все)
    CORDERS                 in clob,                        -- Сортировки    
    NINCLUDE_DEF            in number,                      -- Признак включения описания колонок таблицы в ответ
    COUT                    out clob                        -- Сериализованная таблица данных
  )
  is
    RO                      PKG_P8PANELS_VISUAL.TORDERS;    -- Сортировки
    RDG                     PKG_P8PANELS_VISUAL.TDATA_GRID; -- Описание таблицы
    RDG_ROW                 PKG_P8PANELS_VISUAL.TROW;       -- Строка таблицы
    CSQL                    clob;                           -- Буфер для запроса
    ICURSOR                 integer;                        -- Курсор для исполнения запроса
    NROW_FROM               PKG_STD.TREF;                   -- Номер строки с
    NROW_TO                 PKG_STD.TREF;                   -- Номер строки по
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
    /* Добавляем в таблицу описание колонок */
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NRN',
                                               SCAPTION   => 'Рег. номер',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SPERIOD',
                                               SCAPTION   => 'Период',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BORDER     => true,
                                               BFILTER    => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SINS_DEPARTMENT',
                                               SCAPTION   => 'Подразделение',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BORDER     => true,
                                               BFILTER    => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SFCMANPOWER',
                                               SCAPTION   => 'Ресурс',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BORDER     => true,
                                               BFILTER    => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NLAB_PLAN_FOT',
                                               SCAPTION   => 'Труд. (план, ФОТ)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BORDER     => true,
                                               BFILTER    => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NLAB_FACT_RPT',
                                               SCAPTION   => 'Труд. (факт, отчёт)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false,
                                               BORDER     => true,
                                               BFILTER    => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NLAB_DIFF_RPT_FOT',
                                               SCAPTION   => 'Отклон. (факт-план)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false,
                                               BORDER     => true,
                                               BFILTER    => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NLAB_PLAN_JOBS',
                                               SCAPTION   => 'Труд. (план, график)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BORDER     => true,
                                               BFILTER    => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NLAB_DIFF_JOBS_FOT',
                                               SCAPTION   => 'Отклон. (график-план)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BORDER     => true,
                                               BFILTER    => false);
    /* Обходим данные */
    begin
      /* Добавляем подсказку совместимости */
      CSQL := PKG_SQL_BUILD.COMPATIBLE(SSQL => CSQL);
      /* Формируем запрос */
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => 'select *');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '  from (select D.*,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => PKG_SQL_BUILD.SQLROWNUM() || ' NROW');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '          from (select P.RN NRN,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       TO_CHAR(P.DATE_FROM, ''YYYY.MM'') SPERIOD,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       INSD.CODE SINS_DEPARTMENT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       MP.CODE SFCMANPOWER,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.LAB_PLAN_FOT NLAB_PLAN_FOT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.LAB_FACT_RPT NLAB_FACT_RPT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.LAB_FACT_RPT - P.LAB_PLAN_FOT NLAB_DIFF_RPT_FOT,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.LAB_PLAN_JOBS NLAB_PLAN_JOBS,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       P.LAB_PLAN_JOBS - P.LAB_PLAN_FOT NLAB_DIFF_JOBS_FOT');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                  from P8PNL_JB_PERIODS P,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       INS_DEPARTMENT   INSD,');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                       FCMANPOWER       MP');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                 where P.IDENT = :NIDENT');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and P.INS_DEPARTMENT = INSD.RN');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => '                   and P.FCMANPOWER = MP.RN %ORDER_BY%) D) F');
      PKG_SQL_BUILD.APPEND(SSQL => CSQL, SELEMENT1 => ' where F.NROW between :NROW_FROM and :NROW_TO');
      /* Учтём сортировки */
      PKG_P8PANELS_VISUAL.TORDERS_SET_QUERY(RDATA_GRID => RDG, RORDERS => RO, SPATTERN => '%ORDER_BY%', CSQL => CSQL);
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
      PKG_SQL_DML.DEFINE_COLUMN_STR(ICURSOR => ICURSOR, IPOSITION => 4);
      PKG_SQL_DML.DEFINE_COLUMN_NUM(ICURSOR => ICURSOR, IPOSITION => 5);
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
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW => RDG_ROW, SNAME => 'SPERIOD', ICURSOR => ICURSOR, NPOSITION => 2);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SINS_DEPARTMENT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 3);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLS(RROW      => RDG_ROW,
                                              SNAME     => 'SFCMANPOWER',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 4);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NLAB_PLAN_FOT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 5);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NLAB_FACT_RPT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 6);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NLAB_DIFF_RPT_FOT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 7);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NLAB_PLAN_JOBS',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 8);
        PKG_P8PANELS_VISUAL.TROW_ADD_CUR_COLN(RROW      => RDG_ROW,
                                              SNAME     => 'NLAB_DIFF_JOBS_FOT',
                                              ICURSOR   => ICURSOR,
                                              NPOSITION => 9);
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
  end JB_PERIODS_LIST;
  
  /* Очистка данных балансировки */
  procedure JB_CLEAN
  (
    NIDENT                  in number   -- Идентификатор процесса
  )
  is
  begin
    /* Удаляем список предшествующих работ */
    delete from P8PNL_JB_JOBSPREV T where T.IDENT = NIDENT;
    /* Удаляем список работ */
    for C in (select T.RN
                from P8PNL_JB_JOBS T
               where T.IDENT = NIDENT
              connect by prior T.RN = T.HRN
               start with T.HRN is null
               order by level desc)
    loop
      delete from P8PNL_JB_JOBS T where T.RN = C.RN;
    end loop;
    /* Удаляем список проектов */
    delete from P8PNL_JB_PRJCTS T where T.IDENT = NIDENT;
    /* Удаляем периоды балансировки */
    JB_PERIODS_CLEAN(NIDENT => NIDENT);
  end JB_CLEAN;
  
  /* Перенос данных буфера балансировки в проекты */
  procedure JB_SAVE
  (
    NIDENT                  in number,    -- Идентификатор процесса
    COUT                    out clob      -- Список проектов
  )
  is
    NJH                     PKG_STD.TREF; -- Рег. номер записи истории изменения работы
  begin
    /* Обходим изменённые проекты буфера */
    for P in (select T.*
                from P8PNL_JB_PRJCTS T
               where T.IDENT = NIDENT
                 and T.CHANGED = 1)
    loop
      /* Обходим изменённые работы проекта */
      for J in (select T.*
                  from P8PNL_JB_JOBS T
                 where T.IDENT = NIDENT
                   and T.PRN = P.RN
                   and T.STAGE = 0
                   and T.CHANGED = 1)
      loop
        /* Меняем работу в проекте */
        for PJ in (select T.* from PROJECTJOB T where T.RN = J.SOURCE)
        loop
          P_PROJECTJOB_BASE_UPDATE(NRN                => PJ.RN,
                                   NCOMPANY           => PJ.COMPANY,
                                   NJUR_PERS          => PJ.JUR_PERS,
                                   NPROJECTSTAGE      => PJ.PROJECTSTAGE,
                                   NFACEACC           => PJ.FACEACC,
                                   SNUMB              => PJ.NUMB,
                                   SBUDG_NUMB         => PJ.BUDG_NUMB,
                                   SNAME              => PJ.NAME,
                                   NPRJOB             => PJ.PRJOB,
                                   NPRIORITY          => PJ.PRIORITY,
                                   NRESTRICTION       => PJ.RESTRICTION,
                                   DRESTRICT_DATE     => PJ.RESTRICT_DATE,
                                   NDURATION_CHG      => PJ.DURATION_CHG,
                                   NDURATION_NRM      => PJ.DURATION_NRM,
                                   NDURATION_MEAS     => PJ.DURATION_MEAS,
                                   NDURATION_P        => PJ.DURATION_P,
                                   NDURATION_F        => PJ.DURATION_F,
                                   NSUBDIV            => PJ.SUBDIV,
                                   NPERFORM           => PJ.PERFORM,
                                   NRELEASE           => PJ.RELEASE,
                                   NVOLUME_P          => PJ.VOLUME_P,
                                   NVOLUME_F          => PJ.VOLUME_F,
                                   NPRICE_P           => PJ.PRICE_P,
                                   NPRICE_F           => PJ.PRICE_F,
                                   NCURNAMES          => PJ.CURNAMES,
                                   NFPDARTCL          => PJ.FPDARTCL,
                                   NCOST_PLAN         => PJ.COST_PLAN,
                                   NCOST_FACT         => PJ.COST_FACT,
                                   NCOST_BPRICE       => PJ.COST_BPRICE,
                                   NCOST_CALC         => PJ.COST_CALC,
                                   NSTATE             => PJ.STATE,
                                   NPERFORM_PRC       => PJ.PERFORM_PRC,
                                   NFINDEFLINIT       => PJ.FINDEFLINIT,
                                   DBEGPLAN           => J.DATE_FROM,
                                   DBEGFACT           => PJ.BEGFACT,
                                   DENDPLAN           => J.DATE_TO,
                                   DENDFACT           => PJ.ENDFACT,
                                   SNOTE              => PJ.NOTE,
                                   DDO_ACT_FROM       => sysdate,
                                   NRFLCT_HS          => PJ.RFLCT_HS,
                                   NLAB_NORM          => PJ.LAB_NORM,
                                   NCALC_LAB          => PJ.CALC_LAB,
                                   NLAB_PLAN_I        => PJ.LAB_PLAN,
                                   NLAB_FACT_I        => PJ.LAB_FACT,
                                   NLAB_PART          => PJ.LAB_PART,
                                   NLAB_MEAS          => PJ.LAB_MEAS,
                                   SCHNG_BASE         => PJ.CHNG_BASE,
                                   NFACEACCPERF       => PJ.FACEACCPERF,
                                   NCHECK_DO_ACT_FROM => 0,
                                   NLAB_UNITCOST      => PJ.LAB_UNITCOST,
                                   NLAB_CURRENCY      => PJ.LAB_CURRENCY);
          P_PROJECTJOBHS_MAKE_HIST(NCOMPANY => PJ.COMPANY, NPRN => PJ.RN, NCHECK_HS => 0, NRN => NJH);
        end loop;
        /* Снимаем флаг внесения изменений в буферную работу */
        JB_JOBS_SET_CHANGED(NJB_JOBS => J.RN, NCHANGED => 0);
      end loop;
      /* Снимаем флаг внесения изменений в буферный проект */
      JB_PRJCTS_SET_CHANGED(NJB_PRJCTS => P.RN, NCHANGED => 0);
    end loop;
    /* Вернём пересобранный список проектов */
    JB_PRJCTS_LIST(NIDENT => NIDENT, COUT => COUT);
  end JB_SAVE;
  
  /* Формирование исходных данных для балансировки планов-графиков работ */
  procedure JB_INIT
  (
    DBEGIN                  in out date,                           -- Дата начала периода мониторинга загрузки ресурсов
    DFACT                   in out date,                           -- Факт по состоянию на
    NDURATION_MEAS          in out number,                         -- Единица измерения длительности (0 - день, 1 - неделя, 2 - декада, 3 - месяц, 4 - квартал, 5 - год)
    SLAB_MEAS               in out varchar2,                       -- Единица измерения трудоёмкости
    NIDENT                  in out number,                         -- Идентификатор процесса (null - сгенерировать новый, !null - удалить старые данные и пересоздать с указанным идентификатором)
    NRESOURCE_STATUS        out number                             -- Состояние ресурсов (0 - без отклонений, 1 - есть отклонения)
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
    SUTILIZER               PKG_STD.TSTRING := UTILIZER();         -- Пользователь сеанса
    NJB_PRJCTS              PKG_STD.TREF;                          -- Рег. номер проекта в списке для балансировки
    NJB_JOBS_STAGE          PKG_STD.TREF;                          -- Рег. номер этапа проекта в списке для балансировки
    NJB_JOBS_JOB            PKG_STD.TREF;                          -- Рег. номер работы проекта в списке для балансировки
    NJB_JOBS_JOBPREV        PKG_STD.TREF;                          -- Рег. номер предшествующей работы проекта в списке для балансировки
    RH_JB_JOBS              P8PNL_JB_JOBS%rowtype;                 -- Запись родительской работы/этапа в иехархии балансируемых
    RH_JB_JOBS_PREV         P8PNL_JB_JOBS%rowtype;                 -- Запись предшествующей работы в иехархии балансируемых    
    NDURATION               P8PNL_JB_JOBS.DURATION%type;           -- Длительност текущей работы/этапа
    NEDITABLE               PKG_STD.TREF;                          -- Признак возможности редактирования работы
    NLAB_MEAS               PKG_STD.TREF;                          -- Рег. номер выбранной для рассчётов единицы измерения трудоёмкости    
  begin
    /* Обработаем дату начала периода мониторинга загрузки ресурсов */
    if (DBEGIN is null) then
      DBEGIN := TRUNC(sysdate, 'yyyy');
    else
      DBEGIN := TRUNC(DBEGIN, 'yyyy');
    end if;
    /* Обработаем дату факта */
    DFACT := TO_DATE('01.01.2022', 'DD.MM.YYYY');
    /* Обработаем единицу измерения длительности (пока - она всегда должна быть "день", по умолчанию) */
    NDURATION_MEAS := NJB_DURATION_MEAS;
    /* Обработаем единицу измерения трудоёмкости (пока - она всегда должна быть "ч/ч", по умолчанию) */
    SLAB_MEAS := SJB_LAB_MEAS;
    FIND_DICMUNTS_BY_MNEMO(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SMEAS_MNEMO => SLAB_MEAS, NRN => NLAB_MEAS);
    /* Отработаем идентификатор процесса */
    if (NIDENT is null) then
      NIDENT := GEN_IDENT();
    else
      JB_CLEAN(NIDENT => NIDENT);
    end if;
    /* Обходим проекты */
    for PRJ in (select P.RN NRN,
                       COALESCE((select 1
                                  from PROJECTJOB   PJ,
                                       PROJECTSTAGE PS
                                 where PJ.PRN = P.RN
                                   and PJ.BEGPLAN is not null
                                   and PJ.ENDPLAN is not null
                                   and PJ.PROJECTSTAGE = PS.RN
                                   and PS.BEGPLAN is not null
                                   and PS.ENDPLAN is not null
                                   and ROWNUM <= 1),
                                0) NJOBS,
                       0 NEDITABLE,
                       P.BEGPLAN DBEGPLAN,
                       P.ENDPLAN DENDPLAN
                  from PROJECT P
                 where P.COMPANY = NCOMPANY
                   and P.STATE not in (3, 5)
                   and exists (select null from V_USERPRIV UP where UP.CATALOG = P.CRN)
                   and exists (select null
                          from V_USERPRIV UP
                         where UP.JUR_PERS = P.JUR_PERS
                           and UP.UNITCODE = 'Projects')
                 order by P.NAME_USL)
    loop
      /* Установим признак доступности редактирования */
      if (CHECK_RESPONSIBLE(NRN => PRJ.NRN, SAUTHID => SUTILIZER) = 1) then
        PRJ.NEDITABLE := 1;
      end if;
      /* Помещаем проект в список балансируемых */
      JB_PRJCTS_BASE_INSERT(NIDENT     => NIDENT,
                            NPROJECT   => PRJ.NRN,
                            NJOBS      => PRJ.NJOBS,
                            NEDITABLE  => PRJ.NEDITABLE,
                            NCHANGED   => 0,
                            NJB_PRJCTS => NJB_PRJCTS);
      /* Обходим этапы проекта в порядке иерархии */
      for STG in (select PS.COMPANY NCOMPANY,
                         PS.RN NRN,
                         PS.HRN NHRN,
                         trim(PS.NUMB) SNUMB,
                         PS.NAME SNAME,
                         PS.BEGPLAN DBEGPLAN,
                         PS.ENDPLAN DENDPLAN,
                         COALESCE(AG.AGNABBR, DP.CODE) SEXECUTOR
                    from PROJECTSTAGE   PS,
                         AGNLIST        AG,
                         INS_DEPARTMENT DP
                   where PS.PRN = PRJ.NRN
                     and PS.BEGPLAN is not null
                     and PS.ENDPLAN is not null
                     and PS.RESPONSIBLE = AG.RN(+)
                     and PS.SUBDIV_RESP = DP.RN(+)
                  connect by prior PS.RN = PS.HRN
                   start with PS.HRN is null
                   order by level,
                            PS.NUMB,
                            PS.BEGPLAN)
      loop
        /* Найдём родительский этап в списке балансировки */
        if (STG.NHRN is not null) then
          RH_JB_JOBS := JB_JOBS_GET_BY_SOURCE(NIDENT => NIDENT, NPRN => NJB_PRJCTS, NSOURCE => STG.NHRN);
        else
          RH_JB_JOBS := null;
        end if;
        /* Определим длительность этапа */
        P_PROJECTJOB_GET_DURATION(NCOMPANY       => STG.NCOMPANY,
                                  DBEG_DATE      => STG.DBEGPLAN,
                                  DEND_DATE      => STG.DENDPLAN,
                                  NDURATION_MEAS => NDURATION_MEAS,
                                  NDURATION      => NDURATION);
        /* Помещаем этап в список балансировки */
        JB_JOBS_BASE_INSERT(NIDENT     => NIDENT,
                            NPRN       => NJB_PRJCTS,
                            NHRN       => RH_JB_JOBS.RN,
                            NSOURCE    => STG.NRN,
                            SNUMB      => STG.SNUMB,
                            SNAME      => STG.SNAME,
                            DDATE_FROM => STG.DBEGPLAN,
                            DDATE_TO   => STG.DENDPLAN,
                            NDURATION  => COALESCE(NDURATION, 0),
                            SEXECUTOR  => STG.SEXECUTOR,
                            NSTAGE     => 1,
                            NEDITABLE  => 0,
                            NJB_JOBS   => NJB_JOBS_STAGE);
        /* Обходим работы этапа */
        for PJ in (select J.COMPANY NCOMPANY,
                          J.RN NRN,
                          trim(J.NUMB) SNUMB,
                          J.NAME SNAME,
                          J.BEGPLAN DBEGPLAN,
                          J.ENDPLAN DENDPLAN,
                          COALESCE(COALESCE(DP.CODE, AG.AGNABBR), STG.SEXECUTOR) SEXECUTOR,
                          J.STATE NSTATE,
                          J.DURATION_CHG NDURATION_CHG
                     from PROJECTJOB     J,
                          AGNLIST        AG,
                          INS_DEPARTMENT DP
                    where J.PRN = PRJ.NRN
                      and J.PROJECTSTAGE = STG.NRN
                      and J.BEGPLAN is not null
                      and J.ENDPLAN is not null
                      and J.SUBDIV = DP.RN(+)
                      and J.PERFORM = AG.RN(+)
                    order by J.NUMB,
                             J.BEGPLAN)
        loop
          /* Определим возможность редактирования работы */
          NEDITABLE := 1;
          if ((PRJ.NEDITABLE = 0) or (PJ.NSTATE <> 0) or (PJ.NDURATION_CHG <> 2)) then
            NEDITABLE := 0;
          end if;
          /* Определим длительность работы */
          P_PROJECTJOB_GET_DURATION(NCOMPANY       => PJ.NCOMPANY,
                                    DBEG_DATE      => PJ.DBEGPLAN,
                                    DEND_DATE      => PJ.DENDPLAN,
                                    NDURATION_MEAS => NDURATION_MEAS,
                                    NDURATION      => NDURATION);
          /* Помещаем работу в список балансировки */
          JB_JOBS_BASE_INSERT(NIDENT     => NIDENT,
                              NPRN       => NJB_PRJCTS,
                              NHRN       => NJB_JOBS_STAGE,
                              NSOURCE    => PJ.NRN,
                              SNUMB      => PJ.SNUMB,
                              SNAME      => PJ.SNAME,
                              DDATE_FROM => PJ.DBEGPLAN,
                              DDATE_TO   => PJ.DENDPLAN,
                              NDURATION  => COALESCE(NDURATION, 0),
                              SEXECUTOR  => PJ.SEXECUTOR,
                              NSTAGE     => 0,
                              NEDITABLE  => NEDITABLE,
                              NJB_JOBS   => NJB_JOBS_JOB);
        end loop;
      end loop;
      /* Обходим работы проекта ещё раз, для наполнения списка предшествующих в буфере балансировки */
      for PJ in (select J.RN NRN
                   from PROJECTJOB J
                  where J.PRN = PRJ.NRN
                    and exists (select null
                           from P8PNL_JB_JOBS JB
                          where JB.IDENT = NIDENT
                            and JB.STAGE = 0
                            and JB.SOURCE = J.RN))
      loop
        RH_JB_JOBS := JB_JOBS_GET_BY_SOURCE(NIDENT => NIDENT, NPRN => NJB_PRJCTS, NSOURCE => PJ.NRN);
        /* Помещаем предшествующие работы в буфер балансировки */
        for PJPREV in (select JP.PROJECTJOB NPROJECTJOB from PROJECTJOBPREV JP where JP.PRN = PJ.NRN)
        loop
          RH_JB_JOBS_PREV := JB_JOBS_GET_BY_SOURCE(NIDENT => NIDENT, NPRN => NJB_PRJCTS, NSOURCE => PJPREV.NPROJECTJOB);
          JB_JOBSPREV_BASE_INSERT(NIDENT       => NIDENT,
                                  NPRN         => RH_JB_JOBS.RN,
                                  NJB_JOBS     => RH_JB_JOBS_PREV.RN,
                                  NJB_JOBSPREV => NJB_JOBS_JOBPREV);
        end loop;
      end loop;
    end loop;
    /* Сформируем данные монитора загрузки ресурсов */
    JB_PERIODS_RECALC(NIDENT => NIDENT, DBEGIN => DBEGIN, NINITIAL => 1, NRESOURCE_STATUS => NRESOURCE_STATUS);
  end JB_INIT;

end PKG_P8PANELS_PROJECTS;
/

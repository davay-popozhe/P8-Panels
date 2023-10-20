create or replace package PKG_P8PANELS_VISUAL as

  /* Константы - типы данных */
  SDATA_TYPE_STR            constant PKG_STD.TSTRING := 'STR';  -- Тип данных "строка"
  SDATA_TYPE_NUMB           constant PKG_STD.TSTRING := 'NUMB'; -- Тип данных "число"
  SDATA_TYPE_DATE           constant PKG_STD.TSTRING := 'DATE'; -- Тип данных "дата"
  
  /* Константы - направление сортировки */
  SORDER_DIRECTION_ASC      constant PKG_STD.TSTRING := 'ASC';  -- По возрастанию
  SORDER_DIRECTION_DESC     constant PKG_STD.TSTRING := 'DESC'; -- По убыванию
  
  /* Константы - масштаб диаграммы Ганта */
  NGANTT_ZOOM_QUARTER_DAY   constant PKG_STD.TNUMBER := 0; -- Четверть дня
  NGANTT_ZOOM_HALF_DAY      constant PKG_STD.TNUMBER := 1; -- Пол дня
  NGANTT_ZOOM_DAY           constant PKG_STD.TNUMBER := 2; -- День
  NGANTT_ZOOM_WEEK          constant PKG_STD.TNUMBER := 3; -- Неделя
  NGANTT_ZOOM_MONTH         constant PKG_STD.TNUMBER := 4; -- Месяц
  
  /* Константы - тип графика */
  SCHART_TYPE_BAR           constant PKG_STD.TSTRING := 'bar';
  SCHART_TYPE_LINE          constant PKG_STD.TSTRING := 'line';
  SCHART_TYPE_PIE           constant PKG_STD.TSTRING := 'pie';
  SCHART_TYPE_DOUGHNUT      constant PKG_STD.TSTRING := 'doughnut';

  /* Константы - расположение легенды графика */  
  SCHART_LGND_POS_LEFT      constant PKG_STD.TSTRING := 'left';
  SCHART_LGND_POS_RIGHT     constant PKG_STD.TSTRING := 'right';
  SCHART_LGND_POS_TOP       constant PKG_STD.TSTRING := 'top';
  SCHART_LGND_POS_BOTTOM    constant PKG_STD.TSTRING := 'bottom';

  /* Типы данных - значение колонки таблицы данных */
  type TCOL_VAL is record
  (
    SVALUE                  PKG_STD.TLSTRING, -- Значение (строка)
    NVALUE                  PKG_STD.TNUMBER,  -- Значение (число)
    DVALUE                  PKG_STD.TLDATE    -- Значение (дата)
  );
  
  /* Типы данных - коллекция значений колонки таблицы данных */
  type TCOL_VALS is table of TCOL_VAL;
 
  /* Типы данных - описатель колонки таблицы данных */
  type TCOL_DEF is record
  (
    SNAME                   PKG_STD.TSTRING, -- Наименование
    SCAPTION                PKG_STD.TSTRING, -- Заголовок
    SDATA_TYPE              PKG_STD.TSTRING, -- Тип данных (см. константы SDATA_TYPE_*)
    SCOND_FROM              PKG_STD.TSTRING, -- Наименование нижней границы условия отбора
    SCOND_TO                PKG_STD.TSTRING, -- Наименование верхней границы условия отбора
    BVISIBLE                boolean,         -- Разрешить отображение
    BORDER                  boolean,         -- Разрешить сортировку
    BFILTER                 boolean,         -- Разрешить отбор
    RCOL_VALS               TCOL_VALS,       -- Предопределённые значения
    SHINT                   PKG_STD.TSTRING  -- Текст всплывающей подсказки
  );
  
  /* Типы данных - коллекция описателей колонок таблицы данных */
  type TCOL_DEFS is table of TCOL_DEF;
  
  /* Типы данных - колонка */
  type TCOL is record
  (
    SNAME                   PKG_STD.TSTRING, -- Наименование
    RCOL_VAL                TCOL_VAL         -- Значение
  );

  /* Типы данных - коллекция колонок */
  type TCOLS is table of TCOL;
  
  /* Типы данных - строка */
  type TROW is record
  (
    RCOLS                   TCOLS       -- Колонки
  );
  
  /* Типы данных - коллекция строк */
  type TROWS is table of TROW;
  
  /* Типы данных - таблица данных */
  type TDATA_GRID is record
  (
    RCOL_DEFS               TCOL_DEFS,  -- Описание колонок
    RROWS                   TROWS       -- Данные строк
  );
  
  /* Типы данных - фильтр */
  type TFILTER is record
  (
    SNAME                   PKG_STD.TSTRING, -- Наименование
    SFROM                   PKG_STD.TSTRING, -- Значение "с"
    STO                     PKG_STD.TSTRING  -- Значение "по"
  );
  
  /* Типы данных - коллекция фильтров */
  type TFILTERS is table of TFILTER;
  
  /* Типы данных - сортировка */
  type TORDER is record
  (
    SNAME                   PKG_STD.TSTRING, -- Наименование
    SDIRECTION              PKG_STD.TSTRING  -- Направление (см. константы SORDER_DIRECTION_*)
  );
  
  /* Типы данных - коллекция сортировок */
  type TORDERS is table of TORDER;
  
  /* Типы данных - описание атрибута задачи для диаграммы Ганта */
  type TGANTT_TASK_ATTR is record
  (
    SNAME                   PKG_STD.TSTRING, -- Наименование
    SCAPTION                PKG_STD.TSTRING  -- Заголовок
  );
  
  /* Типы данных - коллекция описаний атрибутов задачи для диаграммы Ганта */
  type TGANTT_TASK_ATTRS is table of TGANTT_TASK_ATTR;

  /* Типы данных - значение атрибута задачи для диаграммы Ганта */
  type TGANTT_TASK_ATTR_VAL is record
  (
    SNAME                   PKG_STD.TSTRING, -- Наименование
    SVALUE                  PKG_STD.TSTRING  -- Значение
  );
  
  /* Типы данных - коллекция значений атрибутов задачи для диаграммы Ганта */
  type TGANTT_TASK_ATTR_VALS is table of TGANTT_TASK_ATTR_VAL;
  
  /* Типы данных - коллекция ссылок на предшествующие задачи для диаграммы Ганта */
  type TGANTT_TASK_DEPENDENCIES is table of PKG_STD.TREF;
  
  /* Тип данных - задача для диаграммы Ганта */
  type TGANTT_TASK is record
  (
    NRN                     PKG_STD.TREF,                    -- Рег. номер
    SNUMB                   PKG_STD.TSTRING,                 -- Номер
    SCAPTION                PKG_STD.TSTRING,                 -- Заголовок
    SNAME                   PKG_STD.TSTRING,                 -- Наименование
    DSTART                  PKG_STD.TLDATE,                  -- Дата начала
    DEND                    PKG_STD.TLDATE,                  -- Дата окончания
    NPROGRESS               PKG_STD.TNUMBER := null,         -- Прогресс (% готовности) задачи (null - не определен)
    SBG_COLOR               PKG_STD.TSTRING := null,         -- Цвет заливки задачи (null - использовать цвет по умолчанию из стилей, формат - HTML-цвет, #RRGGBBAA)
    STEXT_COLOR             PKG_STD.TSTRING := null,         -- Цвет текста заголовка задачи (null - использовать цвет по умолчанию из стилей, формат - HTML-цвет, #RRGGBBAA)
    BREAD_ONLY              boolean := null,                 -- Сроки и прогресс задачи только для чтения (null - как указано в описании диаграммы)
    BREAD_ONLY_DATES        boolean := null,                 -- Сроки задачи только для чтения (null - как указано в описании диаграммы)
    BREAD_ONLY_PROGRESS     boolean := null,                 -- Прогресс задачи только для чтения (null - как указано в описании диаграммы)
    RATTR_VALS              TGANTT_TASK_ATTR_VALS := null,   -- Значения дополнительных атрбутов (null - дополнительные атрибуты не определены)
    RDEPENDENCIES           TGANTT_TASK_DEPENDENCIES := null -- Список предшествующих задач
  );
  
  /* Тип данных - коллекция задач диаграммы Ганта */
  type TGANTT_TASKS is table of TGANTT_TASK;
  
  /* Тип данных - описание цвета задач диаграммы Ганта */
  type TGANTT_TASK_COLOR is record
  (
    SBG_COLOR               PKG_STD.TSTRING := null, -- Цвет заливки задачи (формат - HTML-цвет, #RRGGBBAA)
    STEXT_COLOR             PKG_STD.TSTRING := null, -- Цвет текста заголовка задачи (формат - HTML-цвет, #RRGGBBAA)
    SDESC                   PKG_STD.TSTRING          -- Описание
  );
  
  /* Тип данных - коллекция описаний цветов задач диаграммы Ганта */
  type TGANTT_TASK_COLORS is table of TGANTT_TASK_COLOR;
  
  /* Типы данных - диаграмма Ганта */
  type TGANTT is record
  (
    STITLE                  PKG_STD.TSTRING := null,             -- Заголовок (null - не отображать)
    NZOOM                   PKG_STD.TNUMBER := NGANTT_ZOOM_WEEK, -- Текущий масштаб (см. константы NGANTT_ZOOM_*)
    BZOOM_BAR               boolean := true,                     -- Обображать панель масштабирования
    BREAD_ONLY              boolean := false,                    -- Сроки и прогресс задач только для чтения
    BREAD_ONLY_DATES        boolean := false,                    -- Сроки задач только для чтения
    BREAD_ONLY_PROGRESS     boolean := false,                    -- Прогресс задач только для чтения
    RTASK_ATTRS             TGANTT_TASK_ATTRS,                   -- Описание атрибутов карточки задачи
    RTASK_COLORS            TGANTT_TASK_COLORS,                  -- Описание цветов задач
    RTASKS                  TGANTT_TASKS                         -- Список задач
  );
  
  /* Типы данных - значение атрибута элемента данных графика */
  type TCHART_DATASET_ITEM_ATTR_VAL is record
  (
    SNAME                   PKG_STD.TSTRING, -- Наименование
    SVALUE                  PKG_STD.TSTRING  -- Значение
  );
  
  /* Типы данных - коллекция значений атрибутов элемента данных графика */
  type TCHART_DATASET_ITEM_ATTR_VALS is table of TCHART_DATASET_ITEM_ATTR_VAL;  
  
  /* Тип данных - элемент данных графика */
  type TCHART_DATASET_ITEM is record
  (
    NVALUE                  PKG_STD.TNUMBER,                      -- Значение элемента данных, отображаемое на графике
    RATTR_VALS              TCHART_DATASET_ITEM_ATTR_VALS := null -- Значения дополнительных атрбутов (null - дополнительные атрибуты не определены)
  );
  
  /* Тип данных - коллекция элементов данных */
  type TCHART_DATASET_ITEMS is table of TCHART_DATASET_ITEM;
  
  /* Тип данных - набор данных графика */
  type TCHART_DATASET is record
  (
    SCAPTION                PKG_STD.TSTRING,         -- Заголовок
    SBORDER_COLOR           PKG_STD.TSTRING := null, -- Цвет границы элемента данных на графике (null - использовать цвет по умолчанию из стилей, формат - HTML-цвет, #RRGGBBAA)
    SBG_COLOR               PKG_STD.TSTRING := null, -- Цвет заливки элемента данных на графике (null - использовать цвет по умолчанию из стилей, формат - HTML-цвет, #RRGGBBAA)
    RITEMS                  TCHART_DATASET_ITEMS     -- Элементы данных
  );
  
  /* Тип данных - коллекция наборов данных графика */
  type TCHART_DATASETS is table of TCHART_DATASET;
  
  /* Тип данных - коллекция меток данных графика */
  type TCHART_LABELS is table of PKG_STD.TSTRING;
  
  /* Типы данных - график */
  type TCHART is record
  (
    STYPE                   PKG_STD.TSTRING,         -- Тип (см. константы SCHART_TYPE_*)
    STITLE                  PKG_STD.TSTRING := null, -- Заголовок (null - не отображать)
    SLGND_POS               PKG_STD.TSTRING := null, -- Расположение легенды (null - не отображать, см. константы SCHART_LGND_POS_*)
    RLABELS                 TCHART_LABELS,           -- Метки значений
    RDATASETS               TCHART_DATASETS          -- Наборы данных
  );
  
  /* Расчет диапаона выдаваемых записей */
  procedure UTL_ROWS_LIMITS_CALC
  (
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    NROW_FROM               out number, -- Нижняя граница диапазона
    NROW_TO                 out number  -- Верхняя граница диапазона
  );
  
  /* Формирование наименования условия отбора для нижней границы */
  function UTL_COND_NAME_MAKE_FROM
  (
    SNAME                   in varchar2 -- Наименование колонки
  ) return                  varchar2;   -- Результат
  
  /* Формирование наименования условия отбора для верхней границы */
  function UTL_COND_NAME_MAKE_TO
  (
    SNAME                   in varchar2 -- Наименование колонки
  ) return                  varchar2;   -- Результат
  
  /* Добавление значения в коллекцию */
  procedure TCOL_VALS_ADD
  (
    RCOL_VALS               in out nocopy TCOL_VALS, -- Коллекция значений
    SVALUE                  in varchar2 := null,     -- Значение (строка)
    NVALUE                  in number := null,       -- Значение (число)
    DVALUE                  in date := null,         -- Значение (дата)
    BCLEAR                  in boolean := false      -- Флаг очистки коллекции (false - не очищать, true - очистить коллекцию перед добавлением)
  );
  
  /* Формирование строки */
  function TROW_MAKE
  return                    TROW;       -- Результат работы
  
  /* Добавление колонки к строке */
  procedure TROW_ADD_COL
  (
    RROW                    in out nocopy TROW,  -- Строка
    SNAME                   in varchar2,         -- Наименование колонки
    SVALUE                  in varchar2 := null, -- Значение (строка)
    NVALUE                  in number := null,   -- Значение (число)
    DVALUE                  in date := null,     -- Значение (дата)
    BCLEAR                  in boolean := false  -- Флаг очистки коллекции (false - не очищать, true - очистить коллекцию перед добавлением)
  );
  
  /* Добавление строковой колонки к строке из курсора динамического запроса */
  procedure TROW_ADD_CUR_COLS
  (
    RROW                    in out nocopy TROW, -- Строка
    SNAME                   in varchar2,        -- Наименование колонки
    ICURSOR                 in integer,         -- Курсор
    NPOSITION               in number,          -- Номер колонки в курсоре
    BCLEAR                  in boolean := false -- Флаг очистки коллекции (false - не очищать, true - очистить коллекцию перед добавлением)
  );
  
  /* Добавление числовой колонки к строке из курсора динамического запроса */
  procedure TROW_ADD_CUR_COLN
  (
    RROW                    in out nocopy TROW, -- Строка
    SNAME                   in varchar2,        -- Наименование колонки
    ICURSOR                 in integer,         -- Курсор
    NPOSITION               in number,          -- Номер колонки в курсоре
    BCLEAR                  in boolean := false -- Флаг очистки коллекции (false - не очищать, true - очистить коллекцию перед добавлением)
  );

  /* Добавление колонки типа "дата" к строке из курсора динамического запроса */
  procedure TROW_ADD_CUR_COLD
  (
    RROW                    in out nocopy TROW, -- Строка
    SNAME                   in varchar2,        -- Наименование колонки
    ICURSOR                 in integer,         -- Курсор
    NPOSITION               in number,          -- Номер колонки в курсоре
    BCLEAR                  in boolean := false -- Флаг очистки коллекции (false - не очищать, true - очистить коллекцию перед добавлением)
  );
  
  /* Формирование таблицы данных */
  function TDATA_GRID_MAKE
  return                    TDATA_GRID; -- Результат работы
  
  /* Поиск описания колонки в таблице данных по наименованию */
  function TDATA_GRID_FIND_COL_DEF
  (
    RDATA_GRID              in TDATA_GRID, -- Описание таблицы данных
    SNAME                   in varchar2    -- Наименование колонки
  ) return                  TCOL_DEF;      -- Найденное описание (null - если не нашли)
  
  /* Добавление описания колонки к таблице данных */
  procedure TDATA_GRID_ADD_COL_DEF
  (
    RDATA_GRID              in out nocopy TDATA_GRID,      -- Описание таблицы данных
    SNAME                   in varchar2,                   -- Наименование колонки
    SCAPTION                in varchar2,                   -- Заголовок колонки
    SDATA_TYPE              in varchar2 := SDATA_TYPE_STR, -- Тип данных колонки (см. константы SDATA_TYPE_*)
    SCOND_FROM              in varchar2 := null,           -- Наименование нижней границы условия отбора (null - используется UTL_COND_NAME_MAKE_FROM)
    SCOND_TO                in varchar2 := null,           -- Наименование верхней границы условия отбора (null - используется UTL_COND_NAME_MAKE_TO)
    BVISIBLE                in boolean := true,            -- Разрешить отображение
    BORDER                  in boolean := false,           -- Разрешить сортировку по колонке
    BFILTER                 in boolean := false,           -- Разрешить отбор по колонке
    RCOL_VALS               in TCOL_VALS := null,          -- Предопределённые значения колонки
    SHINT                   in varchar2 := null,           -- Текст всплывающей подсказки    
    BCLEAR                  in boolean := false            -- Флаг очистки коллекции описаний колонок таблицы данных (false - не очищать, true - очистить коллекцию перед добавлением)
  );
  
  /* Добавление описания колонки к таблице данных */
  procedure TDATA_GRID_ADD_ROW
  (
    RDATA_GRID              in out nocopy TDATA_GRID, -- Описание таблицы данных
    RROW                    in TROW,                  -- Строка
    BCLEAR                  in boolean := false       -- Флаг очистки коллекции строк таблицы данных (false - не очищать, true - очистить коллекцию перед добавлением)
  );

  /* Сериализация таблицы данных */
  function TDATA_GRID_TO_XML
  (
    RDATA_GRID              in TDATA_GRID, -- Описание таблицы данных
    NINCLUDE_DEF            in number := 1 -- Включить описание колонок (0 - нет, 1 - да)
  ) return                  clob;          -- XML-описание

  
  /* Конвертация значений фильтра в число */
  procedure TFILTER_TO_NUMBER
  (
    RFILTER                 in TFILTER, -- Фильтр
    NFROM                   out number, -- Значение нижней границы диапазона
    NTO                     out number  -- Значение верхней границы диапазона
  );

  /* Конвертация значений фильтра в дату */
  procedure TFILTER_TO_DATE
  (
    RFILTER                 in TFILTER, -- Фильтр
    DFROM                   out date,   -- Значение нижней границы диапазона
    DTO                     out date    -- Значение верхней границы диапазона
  );
  
  /* Поиск фильтра в коллекции */
  function TFILTERS_FIND
  (
    RFILTERS                in TFILTERS, -- Коллекция фильтров
    SNAME                   in varchar2  -- Наименование
  ) return                  TFILTER;     -- Найденный фильтр (null - если не нашли)
  
  /* Десериализация фильтров */
  function TFILTERS_FROM_XML
  (
    CFILTERS                in clob     -- Сериализованное представление фильтров (BASE64(<filters><name>ИМЯ</name><from>ЗНАЧЕНИЕ</from><to>ЗНАЧЕНИЕ</to></filters>...))
  ) return                  TFILTERS;   -- Результат работы

  /* Применение параметров фильтрации в запросе */
  procedure TFILTERS_SET_QUERY
  (
    NIDENT                  in number,         -- Идентификатор отбора
    NCOMPANY                in number,         -- Рег. номер организации
    NPARENT                 in number := null, -- Рег. номер родителя
    SUNIT                   in varchar2,       -- Код раздела
    SPROCEDURE              in varchar2,       -- Наименование серверной процедуры отбора
    RDATA_GRID              in TDATA_GRID,     -- Описание таблицы данных
    RFILTERS                in TFILTERS        -- Коллекция фильтров
  );
  
  /* Десериализация сортировок */
  function TORDERS_FROM_XML
  (
    CORDERS                 in clob     -- Сериализованное представление сотрировок (BASE64(<orders><name>ИМЯ</name><direction>ASC/DESC</direction></orders>...))
  ) return                  TORDERS;    -- Результат работы

  /* Применение параметров сортировки в запросе */
  procedure TORDERS_SET_QUERY
  (
    RDATA_GRID              in TDATA_GRID,     -- Описание таблицы
    RORDERS                 in TORDERS,        -- Коллекция сортировок
    SPATTERN                in varchar2,       -- Шаблон для подстановки условий отбора в запрос
    CSQL                    in out nocopy clob -- Буфер запроса
  );
  
  /* Формирование задачи для диаграммы Ганта */
  function TGANTT_TASK_MAKE
  (
    NRN                     in number,           -- Рег. номер
    SNUMB                   in varchar2,         -- Номер
    SCAPTION                in varchar2,         -- Заголовок
    SNAME                   in varchar2,         -- Наименование    
    DSTART                  in date,             -- Дата начала
    DEND                    in date,             -- Дата окончания
    NPROGRESS               in number := null,   -- Прогресс (% готовности) задачи (null - не определен)
    SBG_COLOR               in varchar2 := null, -- Цвет заливки задачи (null - использовать цвет по умолчанию из стилей, формат - HTML-цвет, #RRGGBBAA)
    STEXT_COLOR             in varchar2 := null, -- Цвет текста заголовка задачи (null - использовать цвет по умолчанию из стилей, формат - HTML-цвет, #RRGGBBAA)
    BREAD_ONLY              in boolean := null,  -- Сроки и прогресс задачи только для чтения (null - как указано в описании диаграммы)
    BREAD_ONLY_DATES        in boolean := null,  -- Сроки задачи только для чтения (null - как указано в описании диаграммы)
    BREAD_ONLY_PROGRESS     in boolean := null   -- Прогресс задачи только для чтения (null - как указано в описании диаграммы)
  ) return                  TGANTT_TASK;         -- Результат работы
  
  /* Добавление значения атрибута к задаче диаграммы Ганта */
  procedure TGANTT_TASK_ADD_ATTR_VAL
  (
    RGANTT                  in TGANTT,                 -- Описание диаграммы
    RTASK                   in out nocopy TGANTT_TASK, -- Описание задачи
    SNAME                   in varchar2,               -- Наименование
    SVALUE                  in varchar2,               -- Значение
    BCLEAR                  in boolean := false        -- Флаг очистки коллекции значений атрибутов (false - не очищать, true - очистить коллекцию перед добавлением)
  );
  
  /* Добавление предшествующей задачи к задаче диаграммы Ганта */
  procedure TGANTT_TASK_ADD_DEPENDENCY
  (
    RTASK                   in out nocopy TGANTT_TASK, -- Описание задачи
    NDEPENDENCY             in number,                 -- Рег. номер предшествующей задачи
    BCLEAR                  in boolean := false        -- Флаг очистки коллекции предшествущих задач (false - не очищать, true - очистить коллекцию перед добавлением)
  );
  
  /* Формирование диаграммы Ганта */
  function TGANTT_MAKE
  (
    STITLE                  in varchar2 := null,           -- Заголовок (null - не отображать)
    NZOOM                   in number := NGANTT_ZOOM_WEEK, -- Текущий масштаб (см. константы NGANTT_ZOOM_*)
    BZOOM_BAR               in boolean := true,            -- Обображать панель масштабирования
    BREAD_ONLY              in boolean := false,           -- Сроки и прогресс задач только для чтения
    BREAD_ONLY_DATES        in boolean := false,           -- Сроки задач только для чтения
    BREAD_ONLY_PROGRESS     in boolean := false            -- Прогресс задач только для чтения
  ) return                  TGANTT;                        -- Результат работы
  
  /* Добавление описания атрибута карточки задачи диаграммы Ганта */
  procedure TGANTT_ADD_TASK_ATTR
  (
    RGANTT                  in out nocopy TGANTT, -- Описание диаграммы Ганта
    SNAME                   in varchar2,          -- Наименование
    SCAPTION                in varchar2,          -- Заголовок
    BCLEAR                  in boolean := false   -- Флаг очистки коллекции атрибутов (false - не очищать, true - очистить коллекцию перед добавлением)
  );

  /* Добавление описания цвета задачи диаграммы Ганта */
  procedure TGANTT_ADD_TASK_COLOR
  (
    RGANTT                  in out nocopy TGANTT, -- Описание диаграммы Ганта
    SBG_COLOR               in varchar2 := null,  -- Цвет заливки задачи (формат - HTML-цвет, #RRGGBBAA)
    STEXT_COLOR             in varchar2 := null,  -- Цвет текста заголовка задачи (формат - HTML-цвет, #RRGGBBAA)
    SDESC                   in varchar2,          -- Описание
    BCLEAR                  in boolean := false   -- Флаг очистки коллекции цветов (false - не очищать, true - очистить коллекцию перед добавлением)
  );

  /* Добавление задачи к диаграмме Ганта */
  procedure TGANTT_ADD_TASK
  (
    RGANTT                  in out nocopy TGANTT, -- Описание диаграммы Ганта
    RTASK                   in TGANTT_TASK,       -- Задача
    BCLEAR                  in boolean := false   -- Флаг очистки коллекции задач диаграммы (false - не очищать, true - очистить коллекцию перед добавлением)
  );
  
  /* Сериализация диаграммы Ганта */
  function TGANTT_TO_XML
  (
    RGANTT                  in TGANTT,     -- Описание диаграммы Ганта
    NINCLUDE_DEF            in number := 1 -- Включить описание заголовка (0 - нет, 1 - да)
  ) return                  clob;          -- XML-описание

  /* Добавление дополнительного атрибута элемента данных графика */
  procedure TCHART_DATASET_ITM_ATTR_VL_ADD
  (
    RATTR_VALS              in out nocopy TCHART_DATASET_ITEM_ATTR_VALS, -- Коллекция дополнительных атрибутов элемента данных графика
    SNAME                   PKG_STD.TSTRING,                             -- Наименование
    SVALUE                  PKG_STD.TSTRING,                             -- Значение
    BCLEAR                  in boolean := false                          -- Флаг очистки коллекции дополнительных атрибутов элемента данных (false - не очищать, true - очистить коллекцию перед добавлением)
  );

  /* Формирование набора данных графика */
  function TCHART_DATASET_MAKE
  (
    SCAPTION                in varchar2,         -- Заголовок
    SBORDER_COLOR           in varchar2 := null, -- Цвет границы элемента данных на графике (null - использовать цвет по умолчанию из стилей, формат - HTML-цвет, #RRGGBBAA)
    SBG_COLOR               in varchar2 := null  -- Цвет заливки элемента данных на графике (null - использовать цвет по умолчанию из стилей, формат - HTML-цвет, #RRGGBBAA)
  ) return                  TCHART_DATASET;      -- Результат работы

  /* Добавление элемента в набор данных графика */
  procedure TCHART_DATASET_ADD_ITEM
  (
    RDATASET                in out nocopy TCHART_DATASET,             -- Описание набора данных графика
    NVALUE                  in number,                                -- Значение элемента данных, отображаемое на графике
    RATTR_VALS              in TCHART_DATASET_ITEM_ATTR_VALS := null, -- Значения дополнительных атрбутов (null - дополнительные атрибуты не определены)
    BCLEAR                  in boolean := false                       -- Флаг очистки коллекции элементов набора данных (false - не очищать, true - очистить коллекцию перед добавлением)
  );

  /* Формирование графика */
  function TCHART_MAKE
  (
    STYPE                   in varchar2,         -- Тип (см. константы SCHART_TYPE_*)
    STITLE                  in varchar2 := null, -- Заголовок (null - не отображать)
    SLGND_POS               in varchar2 := null  -- Расположение легенды (null - не отображать, см. константы SCHART_LGND_POS_*)
  ) return                  TCHART;              -- Результат работы

  /* Добавление метки значения графика */
  procedure TCHART_ADD_LABEL
  (
    RCHART                  in out nocopy TCHART, -- Описание графика
    SLABEL                  in varchar2,          -- Метка значения
    BCLEAR                  in boolean := false   -- Флаг очистки коллекции меток (false - не очищать, true - очистить коллекцию перед добавлением)
  );

  /* Добавление набора данных графика */
  procedure TCHART_ADD_DATASET
  (
    RCHART                  in out nocopy TCHART, -- Описание графика
    RDATASET                in TCHART_DATASET,    -- Набор данных
    BCLEAR                  in boolean := false   -- Флаг очистки коллекции наборов данных (false - не очищать, true - очистить коллекцию перед добавлением)
  );

  /* Сериализация графика */
  function TCHART_TO_XML
  (
    RCHART                  in TCHART,     -- Описание графика
    NINCLUDE_DEF            in number := 1 -- Включить описание заголовка (0 - нет, 1 - да)
  ) return                  clob;          -- XML-описание

end PKG_P8PANELS_VISUAL;
/
create or replace package body PKG_P8PANELS_VISUAL as
/*
TODO: owner="root" created="18.10.2023"
text="Формат data_grid и gant как в chart"
*/
  /* Константы - тэги запросов */
  SRQ_TAG_XROOT               constant PKG_STD.TSTRING := 'XROOT';     -- Тэг для корня данных запроса
  SRQ_TAG_XFILTERS            constant PKG_STD.TSTRING := 'filters';   -- Тэг для строк данных
  SRQ_TAG_XORDERS             constant PKG_STD.TSTRING := 'orders';    -- Тэг для описания колонок
  SRQ_TAG_SNAME               constant PKG_STD.TSTRING := 'name';      -- Тэг для наименования
  SRQ_TAG_SDIRECTION          constant PKG_STD.TSTRING := 'direction'; -- Тэг для направления
  SRQ_TAG_SFROM               constant PKG_STD.TSTRING := 'from';      -- Тэг для значения "с"
  SRQ_TAG_STO                 constant PKG_STD.TSTRING := 'to';        -- Тэг для значения "по"

  /* Константы - тэги ответов */
  SRESP_TAG_XDATA             constant PKG_STD.TSTRING := 'XDATA';           -- Тэг для корня описания данных
  SRESP_TAG_XROWS             constant PKG_STD.TSTRING := 'XROWS';           -- Тэг для строк данных
  SRESP_TAG_XCOLUMNS_DEF      constant PKG_STD.TSTRING := 'XCOLUMNS_DEF';    -- Тэг для описания колонок
  SRESP_TAG_XGANTT_DEF        constant PKG_STD.TSTRING := 'XGANTT_DEF';      -- Тэг для описания заголовка диаграммы Ганта
  SRESP_TAG_XGANTT_TASKS      constant PKG_STD.TSTRING := 'XGANTT_TASKS';    -- Тэг для описания коллекции задач диаграммы Ганта
  SRESP_TAG_XCHART            constant PKG_STD.TSTRING := 'XCHART';          -- Тэг для описания графика
  
  /* Константы - атрибуты ответов (универсальные) */
  SRESP_ATTR_NAME             constant PKG_STD.TSTRING := 'name';     -- Атрибут для наименования
  SRESP_ATTR_CAPTION          constant PKG_STD.TSTRING := 'caption';  -- Атрибут для подписи
  SRESP_ATTR_DATA_TYPE        constant PKG_STD.TSTRING := 'dataType'; -- Атрибут для типа данных
  SRESP_ATTR_VISIBLE          constant PKG_STD.TSTRING := 'visible';  -- Атрибут для флага видимости
  SRESP_ATTR_TITLE            constant PKG_STD.TSTRING := 'title';    -- Атрибут для заголовка
  SRESP_ATTR_ZOOM             constant PKG_STD.TSTRING := 'zoom';     -- Атрибут для масштаба
  SRESP_ATTR_ID               constant PKG_STD.TSTRING := 'id';       -- Атрибут для идентификатора
  SRESP_ATTR_START            constant PKG_STD.TSTRING := 'start';    -- Атрибут для даты начала
  SRESP_ATTR_END              constant PKG_STD.TSTRING := 'end';      -- Атрибут для даты окончания
  SRESP_ATTR_RN               constant PKG_STD.TSTRING := 'rn';       -- Атрибут для рег. номера
  SRESP_ATTR_NUMB             constant PKG_STD.TSTRING := 'numb';     -- Атрибут для номера
  SRESP_ATTR_FULL_NAME        constant PKG_STD.TSTRING := 'fullName'; -- Атрибут для полного наименования
  SRESP_ATTR_DESC             constant PKG_STD.TSTRING := 'desc';     -- Атрибут для описания
  SRESP_ATTR_TYPE             constant PKG_STD.TSTRING := 'type';     -- Атрибут для типа
  SRESP_ATTR_HINT             constant PKG_STD.TSTRING := 'hint';     -- Атрибут для подсказки

  /* Константы - атрибуты ответов (таблица данных) */
  SRESP_ATTR_DT_ORDER         constant PKG_STD.TSTRING := 'order';  -- Атрибут для флага сортировки
  SRESP_ATTR_DT_FILTER        constant PKG_STD.TSTRING := 'filter'; -- Атрибут для флага отбора
  SRESP_ATTR_DT_COLUMN_VALUES constant PKG_STD.TSTRING := 'values'; -- Атрибут для предопределённых значений

  /* Константы - атрибуты ответов (диаграмма Ганта) */  
  SRESP_ATTR_GANTT_ZOOM_BAR   constant PKG_STD.TSTRING := 'zoomBar';          -- Атрибут для флага отображения панели масштаба диаграммы Ганта
  SRESP_ATTR_TASK_PROGRESS    constant PKG_STD.TSTRING := 'progress';         -- Атрибут для прогресса задачи
  SRESP_ATTR_TASK_DEPS        constant PKG_STD.TSTRING := 'dependencies';     -- Атрибут для зависимостей задачи
  SRESP_ATTR_TASK_RO          constant PKG_STD.TSTRING := 'readOnly';         -- Атрибут для флага задачи "только для чтения"
  SRESP_ATTR_TASK_RO_PRGRS    constant PKG_STD.TSTRING := 'readOnlyProgress'; -- Атрибут для флага задачи "прогресс только для чтения"
  SRESP_ATTR_TASK_RO_DATES    constant PKG_STD.TSTRING := 'readOnlyDates';    -- Атрибут для флага задачи "даты только для чтения"
  SRESP_ATTR_TASK_BG_COLOR    constant PKG_STD.TSTRING := 'bgColor';          -- Атрибут для цвета заголовка задачи
  SRESP_ATTR_TASK_TEXT_COLOR  constant PKG_STD.TSTRING := 'textColor';        -- Атрибут для цвета текста задачи
  SRESP_ATTR_TASK_ATTRIBUTES  constant PKG_STD.TSTRING := 'taskAttributes';   -- Атрибут для коллекции атрибутов задачи
  SRESP_ATTR_TASK_COLORS      constant PKG_STD.TSTRING := 'taskColors';       -- Атрибут для коллекции цветов задачи

  /* Константы - атрибуты ответов (графики) */  
  SRESP_ATTR_CHART_LGND_POS   constant PKG_STD.TSTRING := 'legendPosition';  -- Атрибут для места размешения легенды графика
  SRESP_ATTR_CHART_LABELS     constant PKG_STD.TSTRING := 'labels';          -- Атрибут для меток графика
  SRESP_ATTR_CHART_DATASETS   constant PKG_STD.TSTRING := 'datasets';        -- Атрибут для наборов данных графика
  SRESP_ATTR_CHART_DS_LABEL   constant PKG_STD.TSTRING := 'label';           -- Атрибут для метки набора данных графика
  SRESP_ATTR_CHART_DS_BR_CLR  constant PKG_STD.TSTRING := 'borderColor';     -- Атрибут для цвета границы элемента набора данных графика
  SRESP_ATTR_CHART_DS_BG_CLR  constant PKG_STD.TSTRING := 'backgroundColor'; -- Атрибут для цвета заливки элемента набора данных графика
  SRESP_ATTR_CHART_DS_DATA    constant PKG_STD.TSTRING := 'data';            -- Атрибут для коллекции значений элементов набора данных
  SRESP_ATTR_CHART_DS_ITEMS   constant PKG_STD.TSTRING := 'items';           -- Атрибут для коллекции элементов набора данных
  SRESP_ATTR_CHART_DS_I_VAL   constant PKG_STD.TSTRING := 'value';           -- Атрибут для значения элемента набора данных
  
  /* Константы - параметры условий отбора */
  SCOND_FROM_POSTFIX          constant PKG_STD.TSTRING := 'From'; -- Постфикс наименования нижней границы условия отбора
  SCOND_TO_POSTFIX            constant PKG_STD.TSTRING := 'To';   -- Постфикс наименования верхней границы условия отбора

  /* Расчет диапаона выдаваемых записей */
  procedure UTL_ROWS_LIMITS_CALC
  (
    NPAGE_NUMBER            in number,  -- Номер страницы (игнорируется при NPAGE_SIZE=0)
    NPAGE_SIZE              in number,  -- Количество записей на странице (0 - все)
    NROW_FROM               out number, -- Нижняя граница диапазона
    NROW_TO                 out number  -- Верхняя граница диапазона
  )
  is
  begin
    if (COALESCE(NPAGE_SIZE, 0) <= 0)
    then
      NROW_FROM := 1;
      NROW_TO   := 1000000000;
    else
      NROW_FROM := COALESCE(NPAGE_NUMBER, 1) * NPAGE_SIZE - NPAGE_SIZE + 1;
      NROW_TO   := COALESCE(NPAGE_NUMBER, 1) * NPAGE_SIZE;
    end if;
  end UTL_ROWS_LIMITS_CALC;
  
  /* Формирование наименования условия отбора для нижней границы */
  function UTL_COND_NAME_MAKE_FROM
  (
    SNAME                   in varchar2 -- Наименование колонки
  ) return                  varchar2    -- Результат
  is
  begin
    return SNAME || SCOND_FROM_POSTFIX;
  end UTL_COND_NAME_MAKE_FROM;

  /* Формирование наименования условия отбора для верхней границы */
  function UTL_COND_NAME_MAKE_TO
  (
    SNAME                   in varchar2 -- Наименование колонки
  ) return                  varchar2    -- Результат
  is
  begin
    return SNAME || SCOND_TO_POSTFIX;
  end UTL_COND_NAME_MAKE_TO;
  
  /* Формирование значения */
  function TCOL_VAL_MAKE
  (
    SVALUE                  in varchar2, -- Значение (строка)
    NVALUE                  in number,   -- Значение (число)
    DVALUE                  in date      -- Значение (дата)
  ) return                  TCOL_VAL     -- Результат работы
  is
    RRES                    TCOL_VAL;    -- Буфер для результата
  begin
    /* Формируем объект */
    RRES.SVALUE := SVALUE;
    RRES.NVALUE := NVALUE;
    RRES.DVALUE := DVALUE;
    /* Возвращаем результат */
    return RRES;
  end TCOL_VAL_MAKE;

  /* Добавление значения в коллекцию */
  procedure TCOL_VALS_ADD
  (
    RCOL_VALS               in out nocopy TCOL_VALS, -- Коллекция значений
    SVALUE                  in varchar2 := null,     -- Значение (строка)
    NVALUE                  in number := null,       -- Значение (число)
    DVALUE                  in date := null,         -- Значение (дата)
    BCLEAR                  in boolean := false      -- Флаг очистки коллекции (false - не очищать, true - очистить коллекцию перед добавлением)
  )
  is
  begin
    /* Инициализируем коллекцию если необходимо */
    if ((RCOL_VALS is null) or (BCLEAR)) then
      RCOL_VALS := TCOL_VALS();
    end if;
    /* Добавляем элемент */
    RCOL_VALS.EXTEND();
    RCOL_VALS(RCOL_VALS.LAST) := TCOL_VAL_MAKE(SVALUE => SVALUE, NVALUE => NVALUE, DVALUE => DVALUE);
  end TCOL_VALS_ADD;
  
  /* Формирование описания колонки */
  function TCOL_DEF_MAKE
  (
    SNAME                   in varchar2,                   -- Наименование
    SCAPTION                in varchar2,                   -- Заголовок
    SDATA_TYPE              in varchar2 := SDATA_TYPE_STR, -- Тип данных (см. константы SDATA_TYPE_*)
    SCOND_FROM              in varchar2 := null,           -- Наименование нижней границы условия отбора (null - используется UTL_COND_NAME_MAKE_FROM)
    SCOND_TO                in varchar2 := null,           -- Наименование верхней границы условия отбора (null - используется UTL_COND_NAME_MAKE_TO)
    BVISIBLE                in boolean := true,            -- Разрешить отображение
    BORDER                  in boolean := false,           -- Разрешить сортировку
    BFILTER                 in boolean := false,           -- Разрешить отбор
    RCOL_VALS               in TCOL_VALS := null,          -- Предопределённые значения
    SHINT                   in varchar2 := null            -- Текст всплывающей подсказки
  ) return                  TCOL_DEF                       -- Результат работы
  is
    RRES                    TCOL_DEF;                      -- Буфер для результата
  begin
    /* Формируем объект */
    RRES.SNAME      := SNAME;
    RRES.SCAPTION   := SCAPTION;
    RRES.SDATA_TYPE := COALESCE(SDATA_TYPE, SDATA_TYPE_STR);
    RRES.SCOND_FROM := COALESCE(SCOND_FROM, UTL_COND_NAME_MAKE_FROM(SNAME => SNAME));
    RRES.SCOND_TO   := COALESCE(SCOND_TO, UTL_COND_NAME_MAKE_TO(SNAME => SNAME));
    RRES.BVISIBLE   := COALESCE(BVISIBLE, true);
    RRES.BORDER     := COALESCE(BORDER, false);
    RRES.BFILTER    := COALESCE(BFILTER, false);
    RRES.RCOL_VALS  := COALESCE(RCOL_VALS, TCOL_VALS());
    RRES.SHINT      := SHINT;
    /* Возвращаем результат */
    return RRES;
  end TCOL_DEF_MAKE;
  
  /* Добавление описания колонки в коллекцию */
  procedure TCOL_DEFS_ADD
  (
    RCOL_DEFS               in out nocopy TCOL_DEFS,       -- Коллекция описаний колонок
    SNAME                   in varchar2,                   -- Наименование
    SCAPTION                in varchar2,                   -- Заголовок
    SDATA_TYPE              in varchar2 := SDATA_TYPE_STR, -- Тип данных (см. константы SDATA_TYPE_*)
    SCOND_FROM              in varchar2 := null,           -- Наименование нижней границы условия отбора (null - используется UTL_COND_NAME_MAKE_FROM)
    SCOND_TO                in varchar2 := null,           -- Наименование верхней границы условия отбора (null - используется UTL_COND_NAME_MAKE_TO)
    BVISIBLE                in boolean := true,            -- Разрешить отображение
    BORDER                  in boolean := false,           -- Разрешить сортировку
    BFILTER                 in boolean := false,           -- Разрешить отбор
    RCOL_VALS               in TCOL_VALS := null,          -- Предопределённые значения
    SHINT                   in varchar2 := null,           -- Текст всплывающей подсказки
    BCLEAR                  in boolean := false            -- Флаг очистки коллекции (false - не очищать, true - очистить коллекцию перед добавлением)
  )
  is
  begin
    /* Инициализируем коллекцию если необходимо */
    if ((RCOL_DEFS is null) or (BCLEAR)) then
      RCOL_DEFS := TCOL_DEFS();
    end if;
    /* Добавляем элемент */
    RCOL_DEFS.EXTEND();
    RCOL_DEFS(RCOL_DEFS.LAST) := TCOL_DEF_MAKE(SNAME      => SNAME,
                                               SCAPTION   => SCAPTION,
                                               SDATA_TYPE => SDATA_TYPE,
                                               SCOND_FROM => SCOND_FROM,
                                               SCOND_TO   => SCOND_TO,
                                               BVISIBLE   => BVISIBLE,
                                               BORDER     => BORDER,
                                               BFILTER    => BFILTER,
                                               SHINT      => SHINT,
                                               RCOL_VALS  => RCOL_VALS);
  end TCOL_DEFS_ADD;
  
  /* Поиск описания колонки по наименованию */
  function TCOL_DEFS_FIND
  (
    RCOL_DEFS               in TCOL_DEFS, -- Описание колонок таблицы данных
    SNAME                   in varchar2   -- Наименование
  ) return                  TCOL_DEF      -- Найденное описание (null - если не нашли)
  is
  begin
    /* Обходим колонки из коллекции описаний */
    if ((RCOL_DEFS is not null) and (RCOL_DEFS.COUNT > 0)) then
      for I in RCOL_DEFS.FIRST .. RCOL_DEFS.LAST
      loop
        if (RCOL_DEFS(I).SNAME = SNAME) then
          return RCOL_DEFS(I);
        end if;
      end loop;
    end if;
    /* Ничего не нашли */
    return null;
  end TCOL_DEFS_FIND;
  
  /* Сериализация описания колонки таблицы данных */
  procedure TCOL_DEFS_TO_XML
  (
    RCOL_DEFS               in TCOL_DEFS -- Описание колонок таблицы данных
  )
  is    
  begin
    /* Обходим колонки из коллекции */
    if ((RCOL_DEFS is not null) and (RCOL_DEFS.COUNT > 0)) then
      for I in RCOL_DEFS.FIRST .. RCOL_DEFS.LAST
      loop
        /* Открываем описание колонки */
        PKG_XFAST.DOWN_NODE(SNAME => SRESP_TAG_XCOLUMNS_DEF);
        /* Атрибуты колонки */
        PKG_XFAST.ATTR(SNAME => SRESP_ATTR_NAME, SVALUE => RCOL_DEFS(I).SNAME);
        PKG_XFAST.ATTR(SNAME => SRESP_ATTR_CAPTION, SVALUE => RCOL_DEFS(I).SCAPTION);
        PKG_XFAST.ATTR(SNAME => SRESP_ATTR_DATA_TYPE, SVALUE => RCOL_DEFS(I).SDATA_TYPE);
        PKG_XFAST.ATTR(SNAME => SRESP_ATTR_VISIBLE, BVALUE => RCOL_DEFS(I).BVISIBLE);
        PKG_XFAST.ATTR(SNAME => SRESP_ATTR_DT_ORDER, BVALUE => RCOL_DEFS(I).BORDER);
        PKG_XFAST.ATTR(SNAME => SRESP_ATTR_DT_FILTER, BVALUE => RCOL_DEFS(I).BFILTER);
        PKG_XFAST.ATTR(SNAME => SRESP_ATTR_HINT, SVALUE => RCOL_DEFS(I).SHINT);
        /* Предопределённые значения */
        if (RCOL_DEFS(I).RCOL_VALS is not null) and (RCOL_DEFS(I).RCOL_VALS.COUNT > 0) then
          for V in RCOL_DEFS(I).RCOL_VALS.FIRST .. RCOL_DEFS(I).RCOL_VALS.LAST
          loop
            /* Открываем описание предопределённого значения */
            PKG_XFAST.DOWN_NODE(SNAME => SRESP_ATTR_DT_COLUMN_VALUES);
            /* Значение */
            case RCOL_DEFS(I).SDATA_TYPE
              when SDATA_TYPE_STR then
                PKG_XFAST.VALUE(SVALUE => RCOL_DEFS(I).RCOL_VALS(V).SVALUE);
              when SDATA_TYPE_NUMB then
                PKG_XFAST.VALUE(NVALUE => RCOL_DEFS(I).RCOL_VALS(V).NVALUE);
              when SDATA_TYPE_DATE then
                PKG_XFAST.VALUE(DVALUE => RCOL_DEFS(I).RCOL_VALS(V).DVALUE);
              else
                P_EXCEPTION(0,
                            'Описание колонки "%s" таблицы данных содержит неподдерживаемый тип данных ("%s").',
                            COALESCE(RCOL_DEFS(I).SNAME, '<НЕ ОПРЕДЕЛЕНА>'),
                            COALESCE(RCOL_DEFS(I).SDATA_TYPE, '<НЕ ОПРЕДЕЛЁН>'));
            end case;
            /* Закрываем описание предопределённого значения */
            PKG_XFAST.UP();          
          end loop;
        end if;
        /* Закрываем описание колонки */
        PKG_XFAST.UP();
      end loop;
    end if;
  end TCOL_DEFS_TO_XML;
  
  /* Формирование колонки */
  function TCOL_MAKE
  (
    SNAME                   in varchar2,         -- Наименование колонки
    SVALUE                  in varchar2 := null, -- Значение (строка)
    NVALUE                  in number := null,   -- Значение (число)
    DVALUE                  in date := null      -- Значение (дата)
  ) return                  TCOL                 -- Результат работы
  is
    RRES                    TCOL;                -- Буфер для результата
  begin
    /* Формируем объект */
    RRES.SNAME    := SNAME;
    RRES.RCOL_VAL := TCOL_VAL_MAKE(SVALUE => SVALUE, NVALUE => NVALUE, DVALUE => DVALUE);
    /* Возвращаем результат */
    return RRES;
  end TCOL_MAKE;
  
  /* Добавление колонки в коллекцию */
  procedure TCOLS_ADD
  (
    RCOLS                   in out nocopy TCOLS, -- Коллекция колонок
    SNAME                   in varchar2,         -- Наименование колонки
    SVALUE                  in varchar2 := null, -- Значение (строка)
    NVALUE                  in number := null,   -- Значение (число)
    DVALUE                  in date := null,     -- Значение (дата)
    BCLEAR                  in boolean := false  -- Флаг очистки коллекции (false - не очищать, true - очистить коллекцию перед добавлением)
  )
  is
  begin
    /* Инициализируем коллекцию если необходимо */
    if ((RCOLS is null) or (BCLEAR)) then
      RCOLS := TCOLS();
    end if;
    /* Добавляем элемент */
    RCOLS.EXTEND();
    RCOLS(RCOLS.LAST) := TCOL_MAKE(SNAME => SNAME, SVALUE => SVALUE, NVALUE => NVALUE, DVALUE => DVALUE);
  end TCOLS_ADD;
  
  /* Формирование строки */
  function TROW_MAKE
  return                    TROW        -- Результат работы
  is
    RRES                    TROW;       -- Буфер для результата
  begin
    /* Формируем объект */
    RRES.RCOLS := TCOLS();
    /* Возвращаем результат */
    return RRES;
  end TROW_MAKE;
  
  /* Добавление колонки к строке */
  procedure TROW_ADD_COL
  (
    RROW                    in out nocopy TROW,  -- Строка
    SNAME                   in varchar2,         -- Наименование колонки
    SVALUE                  in varchar2 := null, -- Значение (строка)
    NVALUE                  in number := null,   -- Значение (число)
    DVALUE                  in date := null,     -- Значение (дата)
    BCLEAR                  in boolean := false  -- Флаг очистки коллекции (false - не очищать, true - очистить коллекцию перед добавлением)
  )
  is
  begin
    /* Сформируем колонку и добавим её к коллекции колонок строки */
    TCOLS_ADD(RCOLS => RROW.RCOLS, SNAME => SNAME, SVALUE => SVALUE, NVALUE => NVALUE, DVALUE => DVALUE, BCLEAR => BCLEAR);
  end TROW_ADD_COL;
  
  /* Добавление строковой колонки к строке из курсора динамического запроса */
  procedure TROW_ADD_CUR_COLS
  (
    RROW                    in out nocopy TROW, -- Строка
    SNAME                   in varchar2,        -- Наименование колонки
    ICURSOR                 in integer,         -- Курсор
    NPOSITION               in number,          -- Номер колонки в курсоре
    BCLEAR                  in boolean := false -- Флаг очистки коллекции (false - не очищать, true - очистить коллекцию перед добавлением)
  )
  is
    SVALUE                  PKG_STD.TLSTRING;   -- Буфер для значения курсора
  begin
    /* Читаем данные из курсора */
    PKG_SQL_DML.COLUMN_VALUE_STR(ICURSOR => ICURSOR, IPOSITION => NPOSITION, SVALUE => SVALUE);
    /* Сформируем колонку и добавим её к коллекции колонок строки */
    TCOLS_ADD(RCOLS => RROW.RCOLS, SNAME => SNAME, SVALUE => SVALUE, NVALUE => null, DVALUE => null, BCLEAR => BCLEAR);
  end TROW_ADD_CUR_COLS;

  /* Добавление числовой колонки к строке из курсора динамического запроса */
  procedure TROW_ADD_CUR_COLN
  (
    RROW                    in out nocopy TROW, -- Строка
    SNAME                   in varchar2,        -- Наименование колонки
    ICURSOR                 in integer,         -- Курсор
    NPOSITION               in number,          -- Номер колонки в курсоре
    BCLEAR                  in boolean := false -- Флаг очистки коллекции (false - не очищать, true - очистить коллекцию перед добавлением)
  )
  is
    NVALUE                  PKG_STD.TNUMBER;    -- Буфер для значения курсора
  begin
    /* Читаем данные из курсора */
    PKG_SQL_DML.COLUMN_VALUE_NUM(ICURSOR => ICURSOR, IPOSITION => NPOSITION, NVALUE => NVALUE);
    /* Сформируем колонку и добавим её к коллекции колонок строки */
    TCOLS_ADD(RCOLS => RROW.RCOLS, SNAME => SNAME, SVALUE => null, NVALUE => NVALUE, DVALUE => null, BCLEAR => BCLEAR);
  end TROW_ADD_CUR_COLN;
  
  /* Добавление колонки типа "дата" к строке из курсора динамического запроса */
  procedure TROW_ADD_CUR_COLD
  (
    RROW                    in out nocopy TROW, -- Строка
    SNAME                   in varchar2,        -- Наименование колонки
    ICURSOR                 in integer,         -- Курсор
    NPOSITION               in number,          -- Номер колонки в курсоре
    BCLEAR                  in boolean := false -- Флаг очистки коллекции (false - не очищать, true - очистить коллекцию перед добавлением)
  )
  is
    DVALUE                  PKG_STD.TLDATE;     -- Буфер для значения курсора
  begin
    /* Читаем данные из курсора */
    PKG_SQL_DML.COLUMN_VALUE_DATE(ICURSOR => ICURSOR, IPOSITION => NPOSITION, DVALUE => DVALUE);
    /* Сформируем колонку и добавим её к коллекции колонок строки */
    TCOLS_ADD(RCOLS => RROW.RCOLS, SNAME => SNAME, SVALUE => null, NVALUE => null, DVALUE => DVALUE, BCLEAR => BCLEAR);
  end TROW_ADD_CUR_COLD;
  
  /* Сериализация строки данных таблицы данных */
  procedure TROWS_TO_XML
  (
    RCOL_DEFS               in TCOL_DEFS, -- Описание колонок таблицы данных
    RROWS                   in TROWS      -- Строки таблицы данных
  )
  is  
    RCOL_DEF                TCOL_DEF;     -- Описание текущей сериализуемой колонки
  begin
    /* Обходим строки из коллекции */
    if ((RROWS is not null) and (RROWS.COUNT > 0)) then
      for I in RROWS.FIRST .. RROWS.LAST
      loop
        /* Открываем строку */
        PKG_XFAST.DOWN_NODE(SNAME => SRESP_TAG_XROWS);
        /* Обходим колонки строки */
        if ((RROWS(I).RCOLS is not null) and (RROWS(I).RCOLS.COUNT > 0)) then
          for J in RROWS(I).RCOLS.FIRST .. RROWS(I).RCOLS.LAST
          loop
            /* Найдём описание колонки */
            RCOL_DEF := TCOL_DEFS_FIND(RCOL_DEFS => RCOL_DEFS, SNAME => RROWS(I).RCOLS(J).SNAME);
            if (RCOL_DEF.SNAME is null) then
              P_EXCEPTION(0,
                          'Описание колонки "%s" таблицы данных не определено.',
                          RROWS(I).RCOLS(J).SNAME);
            end if;
            /* Добавлением значение колонки как атрибут строки */
            case RCOL_DEF.SDATA_TYPE
              when SDATA_TYPE_STR then
                PKG_XFAST.ATTR(SNAME => RROWS(I).RCOLS(J).SNAME, SVALUE => RROWS(I).RCOLS(J).RCOL_VAL.SVALUE);
              when SDATA_TYPE_NUMB then
                PKG_XFAST.ATTR(SNAME => RROWS(I).RCOLS(J).SNAME, NVALUE => RROWS(I).RCOLS(J).RCOL_VAL.NVALUE);
              when SDATA_TYPE_DATE then
                PKG_XFAST.ATTR(SNAME => RROWS(I).RCOLS(J).SNAME, DVALUE => RROWS(I).RCOLS(J).RCOL_VAL.DVALUE);
              else
                P_EXCEPTION(0,
                            'Описание колонки "%s" таблицы данных содержит неподдерживаемый тип данных ("%s").',
                            RCOL_DEFS(I).SNAME,
                            COALESCE(RCOL_DEFS(I).SDATA_TYPE, '<НЕ ОПРЕДЕЛЁН>'));
            end case;
          end loop;
        end if;
        /* Закрываем строку */
        PKG_XFAST.UP();
      end loop;
    end if;
  end TROWS_TO_XML;
  
  /* Формирование таблицы данных */
  function TDATA_GRID_MAKE
  return                    TDATA_GRID  -- Результат работы
  is
    RRES                    TDATA_GRID; -- Буфер для результата
  begin
    /* Формируем объект */
    RRES.RCOL_DEFS := TCOL_DEFS();
    RRES.RROWS     := TROWS();
    /* Возвращаем результат */
    return RRES;
  end TDATA_GRID_MAKE;
  
  /* Поиск описания колонки в таблице данных по наименованию */
  function TDATA_GRID_FIND_COL_DEF
  (
    RDATA_GRID              in TDATA_GRID, -- Описание таблицы данных
    SNAME                   in varchar2    -- Наименование колонки
  ) return                  TCOL_DEF       -- Найденное описание (null - если не нашли)
  is
  begin
    return TCOL_DEFS_FIND(RCOL_DEFS => RDATA_GRID.RCOL_DEFS, SNAME => SNAME);
  end TDATA_GRID_FIND_COL_DEF;
  
  /* Добавление описания колонки к таблице данных */
  procedure TDATA_GRID_ADD_COL_DEF
  (
    RDATA_GRID              in out nocopy TDATA_GRID,      -- Описание таблицы данных
    SNAME                   in varchar2,                   -- Наименование колонки
    SCAPTION                in varchar2,                   -- Заголовок колонки
    SDATA_TYPE              in varchar2 := SDATA_TYPE_STR, -- Тип данных колонки (см. константы SDATA_TYPE_*)
    SCOND_FROM              in varchar2 := null,           -- Наименование нижней границы условия отбора (null - используется UTL_COND_NAME_MAKE_FROM)
    SCOND_TO                in varchar2 := null,           -- Наименование верхней границы условия отбора (null - используется UTL_COND_NAME_MAKE_TO)
    BVISIBLE                in boolean := true,            -- Разрешить отображение
    BORDER                  in boolean := false,           -- Разрешить сортировку по колонке
    BFILTER                 in boolean := false,           -- Разрешить отбор по колонке
    RCOL_VALS               in TCOL_VALS := null,          -- Предопределённые значения колонки
    SHINT                   in varchar2 := null,           -- Текст всплывающей подсказки
    BCLEAR                  in boolean := false            -- Флаг очистки коллекции описаний колонок таблицы данных (false - не очищать, true - очистить коллекцию перед добавлением)
  )
  is
  begin
    /* Формируем описание и добавляем в коллекцию таблицы данных */
    TCOL_DEFS_ADD(RCOL_DEFS  => RDATA_GRID.RCOL_DEFS,
                  SNAME      => SNAME,
                  SCAPTION   => SCAPTION,
                  SDATA_TYPE => SDATA_TYPE,
                  SCOND_FROM => SCOND_FROM,
                  SCOND_TO   => SCOND_TO,
                  BVISIBLE   => BVISIBLE,
                  BORDER     => BORDER,
                  BFILTER    => BFILTER,
                  RCOL_VALS  => RCOL_VALS,
                  SHINT      => SHINT,
                  BCLEAR     => BCLEAR);
  end TDATA_GRID_ADD_COL_DEF;
  
  /* Добавление описания колонки к таблице данных */
  procedure TDATA_GRID_ADD_ROW
  (
    RDATA_GRID              in out nocopy TDATA_GRID, -- Описание таблицы данных
    RROW                    in TROW,                  -- Строка
    BCLEAR                  in boolean := false       -- Флаг очистки коллекции строк таблицы данных (false - не очищать, true - очистить коллекцию перед добавлением)
  )
  is
  begin
    /* Инициализируем коллекцию если необходимо */
    if ((RDATA_GRID.RROWS is null) or (BCLEAR)) then
      RDATA_GRID.RROWS := TROWS();
    end if;
    /* Добавляем элемент */
    RDATA_GRID.RROWS.EXTEND();
    RDATA_GRID.RROWS(RDATA_GRID.RROWS.LAST) := RROW;
  end TDATA_GRID_ADD_ROW;
  
  /* Сериализация таблицы данных */
  function TDATA_GRID_TO_XML
  (
    RDATA_GRID              in TDATA_GRID, -- Описание таблицы данных
    NINCLUDE_DEF            in number := 1 -- Включить описание колонок (0 - нет, 1 - да)
  ) return                  clob           -- XML-описание
  is
    CRES                    clob;          -- Буфер для результата
  begin
    /* Начинаем формирование XML */
    PKG_XFAST.PROLOGUE(ITYPE => PKG_XFAST.CONTENT_);
    /* Открываем корень */
    PKG_XFAST.DOWN_NODE(SNAME => SRESP_TAG_XDATA);
    /* Если необходимо включить описание колонок */
    if (NINCLUDE_DEF = 1) then
      TCOL_DEFS_TO_XML(RCOL_DEFS => RDATA_GRID.RCOL_DEFS);
    end if;
    /* Формируем описание строк */
    TROWS_TO_XML(RCOL_DEFS => RDATA_GRID.RCOL_DEFS, RROWS => RDATA_GRID.RROWS);
    /* Закрываем корень */
    PKG_XFAST.UP();
    /* Сериализуем */
    CRES := PKG_XFAST.SERIALIZE_TO_CLOB();
    /* Завершаем формирование XML */
    PKG_XFAST.EPILOGUE();
    /* Возвращаем полученное */
    return CRES;
  exception
    when others then
      /* Завершаем формирование XML */
      PKG_XFAST.EPILOGUE();
      /* Вернем ошибку */
      PKG_STATE.DIAGNOSTICS_STACKED();
      P_EXCEPTION(0, PKG_STATE.SQL_ERRM());
  end TDATA_GRID_TO_XML;
  
  /* Конвертация значений фильтра в число */
  procedure TFILTER_TO_NUMBER
  (
    RFILTER                 in TFILTER, -- Фильтр
    NFROM                   out number, -- Значение нижней границы диапазона
    NTO                     out number  -- Значение верхней границы диапазона
  )
  is
  begin
    /* Нижняя граница диапазона */
    if (RFILTER.SFROM is not null) then
      begin
        NFROM := PKG_P8PANELS_BASE.UTL_S2N(SVALUE => RFILTER.SFROM);
      exception
        when others then
          P_EXCEPTION(0,
                      'Неверный формат числа (%s) в указанной нижней границе диапазона фильтра.',
                      RFILTER.SFROM);
      end;
    end if;
    /* Верхняя граница диапазона */    
    if (RFILTER.STO is not null) then
      begin
        NTO := PKG_P8PANELS_BASE.UTL_S2N(SVALUE => RFILTER.STO);
      exception
        when others then
          P_EXCEPTION(0,
                      'Неверный формат числа (%s) в указанной верхней границе диапазона фильтра.',
                      RFILTER.STO);
      end;
    end if;
  end TFILTER_TO_NUMBER;
  
  /* Конвертация значений фильтра в дату */
  procedure TFILTER_TO_DATE
  (
    RFILTER                 in TFILTER, -- Фильтр
    DFROM                   out date,   -- Значение нижней границы диапазона
    DTO                     out date    -- Значение верхней границы диапазона
  )
  is
  begin
    /* Нижняя граница диапазона */
    if (RFILTER.SFROM is not null) then
      begin
        DFROM := PKG_P8PANELS_BASE.UTL_S2D(SVALUE => RFILTER.SFROM);
      exception
        when others then
          P_EXCEPTION(0,
                      'Неверный формат даты (%s) в указанной нижней границе диапазона фильтра.',
                      RFILTER.SFROM);
      end;
    end if;
    /* Верхняя граница диапазона */
    if (RFILTER.STO is not null) then
      begin
        DTO := PKG_P8PANELS_BASE.UTL_S2D(SVALUE => RFILTER.STO);
      exception
        when others then
          P_EXCEPTION(0,
                      'Неверный формат даты (%s) в указанной верхней границе диапазона фильтра.',
                      RFILTER.STO);
      end;
    end if;
  end TFILTER_TO_DATE;

  /* Формирование фильтра */
  function TFILTER_MAKE
  (
    SNAME                   in varchar2, -- Наименование
    SFROM                   in varchar2, -- Значение "с"
    STO                     in varchar2  -- Значение "по"
  ) return                  TFILTER      -- Результат работы
  is
    RRES                    TFILTER;    -- Буфер для результата
  begin
    /* Формируем объект */
    RRES.SNAME := SNAME;
    RRES.SFROM := SFROM;
    RRES.STO   := STO;
    /* Возвращаем результат */
    return RRES;
  end TFILTER_MAKE;
  
  /* Поиск фильтра в коллекции */
  function TFILTERS_FIND
  (
    RFILTERS                in TFILTERS, -- Коллекция фильтров
    SNAME                   in varchar2  -- Наименование
  ) return                  TFILTER      -- Найденный фильтр (null - если не нашли)
  is
  begin
    /* Обходим фильтры из коллекции */
    if ((RFILTERS is not null) and (RFILTERS.COUNT > 0)) then
      for I in RFILTERS.FIRST .. RFILTERS.LAST
      loop
        if (RFILTERS(I).SNAME = SNAME) then
          return RFILTERS(I);
        end if;
      end loop;
    end if;
    /* Ничего не нашли */
    return null;
  end TFILTERS_FIND;
  
  /* Десериализация фильтров */
  function TFILTERS_FROM_XML
  (
    CFILTERS                in clob              -- Сериализованное представление фильтров (BASE64(<filters><name>ИМЯ</name><from>ЗНАЧЕНИЕ</from><to>ЗНАЧЕНИЕ</to></filters>...))
  ) return                  TFILTERS             -- Результат работы
  is
    RFILTERS                TFILTERS;            -- Буфер для результата работы
    XDOC                    PKG_XPATH.TDOCUMENT; -- Документ XML
    XROOT                   PKG_XPATH.TNODE;     -- Корень документа XML
    XNODE                   PKG_XPATH.TNODE;     -- Буфер узла документа
    XNODES                  PKG_XPATH.TNODES;    -- Буфер коллекции узлов документа
  begin
    /* Вернём выходную коллекцию */
    RFILTERS := TFILTERS();
    /* Разбираем XML */
    XDOC := PKG_XPATH.PARSE_FROM_CLOB(LCXML => '<' || SRQ_TAG_XROOT || '>' ||
                                               BLOB2CLOB(LBDATA   => BASE64_DECODE(LCSRCE => CFILTERS),
                                                         SCHARSET => PKG_CHARSET.CHARSET_UTF_()) || '</' ||
                                               SRQ_TAG_XROOT || '>');
    /* Считываем корневой узел */
    XROOT := PKG_XPATH.ROOT_NODE(RDOCUMENT => XDOC);
    /* Считывание списка записей */
    XNODES := PKG_XPATH.LIST_NODES(RPARENT_NODE => XROOT, SPATTERN => '/' || SRQ_TAG_XROOT || '/' || SRQ_TAG_XFILTERS);
    /* Цикл по списку записией */
    for I in 1 .. PKG_XPATH.COUNT_NODES(RNODES => XNODES)
    loop
      /* Считаем элемент по его номеру */
      XNODE := PKG_XPATH.ITEM_NODE(RNODES => XNODES, INUMBER => I);
      /* Добавим его в коллекцию */
      RFILTERS.EXTEND();
      RFILTERS(RFILTERS.LAST) := TFILTER_MAKE(SNAME => PKG_XPATH.VALUE(RNODE => XNODE, SPATTERN => SRQ_TAG_SNAME),
                                              SFROM => PKG_XPATH.VALUE(RNODE => XNODE, SPATTERN => SRQ_TAG_SFROM),
                                              STO   => PKG_XPATH.VALUE(RNODE => XNODE, SPATTERN => SRQ_TAG_STO));
    end loop;
    /* Освободим документ */
    PKG_XPATH.FREE(RDOCUMENT => XDOC);
    /* Вернём результат */
    return RFILTERS;
  exception
    when others then
      /* Освободим документ */
      PKG_XPATH.FREE(RDOCUMENT => XDOC);
      /* Вернем ошибку */
      PKG_STATE.DIAGNOSTICS_STACKED();
      P_EXCEPTION(0, PKG_STATE.SQL_ERRM());
  end TFILTERS_FROM_XML;
  
  /* Применение параметров фильтрации в запросе */
  procedure TFILTERS_SET_QUERY
  (
    NIDENT                  in number,         -- Идентификатор отбора
    NCOMPANY                in number,         -- Рег. номер организации
    NPARENT                 in number := null, -- Рег. номер родителя
    SUNIT                   in varchar2,       -- Код раздела
    SPROCEDURE              in varchar2,       -- Наименование серверной процедуры отбора
    RDATA_GRID              in TDATA_GRID,     -- Описание таблицы данных
    RFILTERS                in TFILTERS        -- Коллекция фильтров
  )
  is
    RCOL_DEF                TCOL_DEF;          -- Описание текущей фильтруемой колонки
    BENUM                   boolean;           -- Флаг начиличия перечисляемых значений
    NFROM                   PKG_STD.TNUMBER;   -- Буфер для верхней границы диапазона отбора чисел
    NTO                     PKG_STD.TNUMBER;   -- Буфер для нижней границы диапазона отбора чисел
    DFROM                   PKG_STD.TLDATE;    -- Буфер для верхней границы диапазона отбора дат
    DTO                     PKG_STD.TLDATE;    -- Буфер для нижней границы диапазона отбора дат
  begin
    /* Формирование условий отбора - Пролог */
    PKG_COND_BROKER.PROLOGUE(IMODE => PKG_COND_BROKER.MODE_SMART_, NIDENT => NIDENT);
    /* Формирование условий отбора - Установка процедуры серверного отбора */
    PKG_COND_BROKER.SET_PROCEDURE(SPROCEDURE_NAME => SPROCEDURE);
    /* Формирование условий отбора - Установка раздела */
    PKG_COND_BROKER.SET_UNIT(SUNITCODE => SUNIT);
    /* Формирование условий отбора - Установка организации */
    PKG_COND_BROKER.SET_COMPANY(NCOMPANY => NCOMPANY);
    /* Формирование условий отбора - Установка родителя */
    if (NPARENT is not null) then
      PKG_COND_BROKER.SET_PARENT(NPARENT => NPARENT);
    end if;
    /* Обходим фильтр, если задан */
    if ((RFILTERS is not null) and (RFILTERS.COUNT > 0)) then
      for I in RFILTERS.FIRST .. RFILTERS.LAST
      loop
        /* Найдем фильтруемую колонку в описании */
        RCOL_DEF := TCOL_DEFS_FIND(RCOL_DEFS => RDATA_GRID.RCOL_DEFS, SNAME => RFILTERS(I).SNAME);
        if (RCOL_DEF.SNAME is not null) then
          /* Определимся с наличием перечисляемых значений */
          if ((RCOL_DEF.RCOL_VALS is not null) and (RCOL_DEF.RCOL_VALS.COUNT > 0)) then
            BENUM := true;
          else
            BENUM := false;
          end if;
          /* Установим для неё условие отобра согласно типу данных */
          case RCOL_DEF.SDATA_TYPE
            when SDATA_TYPE_STR then
              begin
                if (BENUM) then
                  PKG_COND_BROKER.SET_CONDITION_ESTR(SCONDITION_NAME   => RCOL_DEF.SCOND_FROM,
                                                     SCONDITION_ESTR   => RFILTERS(I).SFROM,
                                                     ICASE_INSENSITIVE => 1);
                else
                  PKG_COND_BROKER.SET_CONDITION_STR(SCONDITION_NAME   => RCOL_DEF.SCOND_FROM,
                                                    SCONDITION_VALUE  => RFILTERS(I).SFROM,
                                                    ICASE_INSENSITIVE => 1);
                end if;
              end;
            when SDATA_TYPE_NUMB then
              begin
                if (BENUM) then
                  PKG_COND_BROKER.SET_CONDITION_ENUM(SCONDITION_NAME => RCOL_DEF.SCOND_FROM,
                                                     SCONDITION_ENUM => RFILTERS(I).SFROM);
                else
                  TFILTER_TO_NUMBER(RFILTER => RFILTERS(I), NFROM => NFROM, NTO => NTO);
                  if (NFROM is not null) then
                    PKG_COND_BROKER.SET_CONDITION_NUM(SCONDITION_NAME  => RCOL_DEF.SCOND_FROM,
                                                      NCONDITION_VALUE => NFROM);
                  end if;
                  if (NTO is not null) then
                    PKG_COND_BROKER.SET_CONDITION_NUM(SCONDITION_NAME => RCOL_DEF.SCOND_TO, NCONDITION_VALUE => NTO);
                  end if;
                end if;
              end;
            when SDATA_TYPE_DATE then
              begin
                if (BENUM) then                  
                  PKG_COND_BROKER.SET_CONDITION_EDATE(SCONDITION_NAME => RCOL_DEF.SCOND_FROM,
                                                      SCONDITION_EDATE => RFILTERS(I).SFROM);
                else
                  TFILTER_TO_DATE(RFILTER => RFILTERS(I), DFROM => DFROM, DTO => DTO);
                  if (DFROM is not null) then
                    PKG_COND_BROKER.SET_CONDITION_DATE(SCONDITION_NAME  => RCOL_DEF.SCOND_FROM,
                                                       DCONDITION_VALUE => DFROM);
                  end if;
                  if (DTO is not null) then
                    PKG_COND_BROKER.SET_CONDITION_DATE(SCONDITION_NAME => RCOL_DEF.SCOND_TO, DCONDITION_VALUE => DTO);
                  end if;
                end if;
              end;
            else
              P_EXCEPTION(0,
                          'Описание колонки "%s" таблицы данных содержит неподдерживаемый тип данных ("%s").',
                          RCOL_DEF.SNAME,
                          COALESCE(RCOL_DEF.SDATA_TYPE, '<НЕ ОПРЕДЕЛЁН>'));
          end case;
        end if;
      end loop;
    end if;
    /* Формирование условий отбора - Эпилог */
    PKG_COND_BROKER.EPILOGUE();
  end TFILTERS_SET_QUERY;
  
  /* Формирование сортировки */
  function TORDER_MAKE
  (
    SNAME                   in varchar2, -- Наименование
    SDIRECTION              in varchar2  -- Направление (см. константы SORDER_DIRECTION_*)
  ) return                  TORDER       -- Результат работы
  is
    RRES                    TORDER;      -- Буфер для результата
  begin
    /* Формируем объект */
    RRES.SNAME      := SNAME;
    RRES.SDIRECTION := SDIRECTION;
    /* Возвращаем результат */
    return RRES;
  end TORDER_MAKE;
  
  /* Десериализация сортировок */
  function TORDERS_FROM_XML
  (
    CORDERS                 in clob              -- Сериализованное представление сотрировок (BASE64(<orders><name>ИМЯ</name><direction>ASC/DESC</direction></orders>...))
  ) return                  TORDERS              -- Результат работы
  is
    RORDERS                 TORDERS;             -- Буфер для результата работы
    XDOC                    PKG_XPATH.TDOCUMENT; -- Документ XML
    XROOT                   PKG_XPATH.TNODE;     -- Корень документа XML
    XNODE                   PKG_XPATH.TNODE;     -- Буфер узла документа
    XNODES                  PKG_XPATH.TNODES;    -- Буфер коллекции узлов документа
  begin
    /* Инициализируем выходную коллекцию */
    RORDERS := TORDERS();
    /* Разбираем XML */
    XDOC := PKG_XPATH.PARSE_FROM_CLOB(LCXML => '<' || SRQ_TAG_XROOT || '>' ||
                                               BLOB2CLOB(LBDATA   => BASE64_DECODE(LCSRCE => CORDERS),
                                                         SCHARSET => PKG_CHARSET.CHARSET_UTF_()) || '</' ||
                                               SRQ_TAG_XROOT || '>');
    /* Считываем корневой узел */
    XROOT := PKG_XPATH.ROOT_NODE(RDOCUMENT => XDOC);
    /* Считывание списка записей */
    XNODES := PKG_XPATH.LIST_NODES(RPARENT_NODE => XROOT, SPATTERN => '/' || SRQ_TAG_XROOT || '/' || SRQ_TAG_XORDERS);
    /* Цикл по списку записией */
    for I in 1 .. PKG_XPATH.COUNT_NODES(RNODES => XNODES)
    loop
      /* Считаем элемент по его номеру */
      XNODE := PKG_XPATH.ITEM_NODE(RNODES => XNODES, INUMBER => I);
      /* Добавим его в коллекцию */
      RORDERS.EXTEND();
      RORDERS(RORDERS.LAST) := TORDER_MAKE(SNAME      => PKG_XPATH.VALUE(RNODE => XNODE, SPATTERN => SRQ_TAG_SNAME),
                                           SDIRECTION => PKG_XPATH.VALUE(RNODE => XNODE, SPATTERN => SRQ_TAG_SDIRECTION));
    end loop;
    /* Освободим документ */
    PKG_XPATH.FREE(RDOCUMENT => XDOC);
    /* Вернём результат */
    return RORDERS;
  exception
    when others then
      /* Освободим документ */
      PKG_XPATH.FREE(RDOCUMENT => XDOC);
      /* Вернем ошибку */
      PKG_STATE.DIAGNOSTICS_STACKED();
      P_EXCEPTION(0, PKG_STATE.SQL_ERRM());
  end TORDERS_FROM_XML;
  
  /* Применение параметров сортировки в запросе */
  procedure TORDERS_SET_QUERY
  (
    RDATA_GRID              in TDATA_GRID,      -- Описание таблицы
    RORDERS                 in TORDERS,         -- Коллекция сортировок
    SPATTERN                in varchar2,        -- Шаблон для подстановки условий отбора в запрос    
    CSQL                    in out nocopy clob  -- Буфер запроса
  )
  is
    CSQL_ORDERS             clob;               -- Буфер для условий сортировки в запросе
  begin
    /* Если сортировка задана */
    if ((RORDERS is not null) and (RORDERS.COUNT > 0)) then
      CSQL_ORDERS := ' order by ';
      for I in RORDERS.FIRST .. RORDERS.LAST
      loop
        /* Перед добавлением в запрос - обязательная проверка, чтобы избежать SQL-инъекций */
        if ((TCOL_DEFS_FIND(RCOL_DEFS => RDATA_GRID.RCOL_DEFS, SNAME => RORDERS(I).SNAME).SNAME is not null) and
           (RORDERS(I).SDIRECTION in (SORDER_DIRECTION_ASC, SORDER_DIRECTION_DESC))) then
          CSQL_ORDERS := CSQL_ORDERS || RORDERS(I).SNAME || ' ' || RORDERS(I).SDIRECTION;
          if (I < RORDERS.LAST) then
            CSQL_ORDERS := CSQL_ORDERS || ', ';
          end if;
        end if;
      end loop;
    end if;
    CSQL := replace(CSQL, SPATTERN, CSQL_ORDERS);
  end TORDERS_SET_QUERY;
  
  /* Проверка корректности наименования дополнительного атрибута задачи диаграммы Ганта */
  procedure TGANTT_TASK_ATTR_NAME_CHECK
  (
    SNAME                   in varchar2 -- Наименование
  )
  is
  begin
    if (SNAME in (SRESP_ATTR_ID,
                  SRESP_ATTR_RN,
                  SRESP_ATTR_NUMB,
                  SRESP_ATTR_CAPTION,
                  SRESP_ATTR_FULL_NAME,
                  SRESP_ATTR_START,
                  SRESP_ATTR_END,
                  SRESP_ATTR_TASK_PROGRESS,
                  SRESP_ATTR_TASK_BG_COLOR,
                  SRESP_ATTR_TASK_TEXT_COLOR,                  
                  SRESP_ATTR_TASK_RO,
                  SRESP_ATTR_TASK_RO_PRGRS,
                  SRESP_ATTR_TASK_RO_DATES,
                  SRESP_ATTR_TASK_DEPS)) then
      P_EXCEPTION(0,
                  'Наименование атрибута "%s" является зарезервированным.',
                  SNAME);
    end if;
  end TGANTT_TASK_ATTR_NAME_CHECK;
  
  /* Поиск атрибута задачи диаграммы Ганта по наименованию */
  function TGANTT_TASK_ATTR_FIND
  (
    RTASK_ATTRS             in TGANTT_TASK_ATTRS, -- Описание атрибутов задачи диаграммы Ганта
    SNAME                   in varchar2           -- Наименование
  ) return                  TGANTT_TASK_ATTR      -- Найденное описание (null - если не нашли)
  is
  begin
    /* Обходим атрибуты из описания */
    if ((RTASK_ATTRS is not null) and (RTASK_ATTRS.COUNT > 0)) then
      for I in RTASK_ATTRS.FIRST .. RTASK_ATTRS.LAST
      loop
        if (RTASK_ATTRS(I).SNAME = SNAME) then
          return RTASK_ATTRS(I);
        end if;
      end loop;
    end if;
    /* Ничего не нашли */
    return null;
  end TGANTT_TASK_ATTR_FIND;
  
  /* Поиск цвета задачи диаграммы Ганта по параметрам */
  function TGANTT_TASK_COLOR_FIND
  (
    RTASK_COLORS            in TGANTT_TASK_COLORS, -- Описание цветов задачи диаграммы Ганта
    SBG_COLOR               in varchar2 := null,   -- Цвет заливки задачи (формат - HTML-цвет, #RRGGBBAA)
    STEXT_COLOR             in varchar2 := null    -- Цвет текста заголовка задачи (формат - HTML-цвет, #RRGGBBAA)
  ) return                  TGANTT_TASK_COLOR      -- Найденное описание цвета (null - если не нашли)
  is
  begin
    /* Обходим цвета из описания */
    if ((RTASK_COLORS is not null) and (RTASK_COLORS.COUNT > 0)) then
      for I in RTASK_COLORS.FIRST .. RTASK_COLORS.LAST
      loop
        if ((CMP_VC2(V1 => RTASK_COLORS(I).SBG_COLOR, V2 => SBG_COLOR) = 1) and
           (CMP_VC2(V1 => RTASK_COLORS(I).STEXT_COLOR, V2 => STEXT_COLOR) = 1)) then
          return RTASK_COLORS(I);
        end if;
      end loop;
    end if;
    /* Ничего не нашли */
    return null;
  end TGANTT_TASK_COLOR_FIND;
  
  /* Формирование задачи для диаграммы Ганта */
  function TGANTT_TASK_MAKE
  (
    NRN                     in number,           -- Рег. номер
    SNUMB                   in varchar2,         -- Номер
    SCAPTION                in varchar2,         -- Заголовок
    SNAME                   in varchar2,         -- Наименование
    DSTART                  in date,             -- Дата начала
    DEND                    in date,             -- Дата окончания
    NPROGRESS               in number := null,   -- Прогресс (% готовности) задачи (null - не определен)
    SBG_COLOR               in varchar2 := null, -- Цвет заливки задачи (null - использовать цвет по умолчанию из стилей, формат - HTML-цвет, #RRGGBBAA)
    STEXT_COLOR             in varchar2 := null, -- Цвет текста заголовка задачи (null - использовать цвет по умолчанию из стилей, формат - HTML-цвет, #RRGGBBAA)
    BREAD_ONLY              in boolean := null,  -- Сроки и прогресс задачи только для чтения (null - как указано в описании диаграммы)
    BREAD_ONLY_DATES        in boolean := null,  -- Сроки задачи только для чтения (null - как указано в описании диаграммы)
    BREAD_ONLY_PROGRESS     in boolean := null   -- Прогресс задачи только для чтения (null - как указано в описании диаграммы)
  ) return                  TGANTT_TASK          -- Результат работы
  is
    RRES                    TGANTT_TASK;         -- Буфер для результата
  begin
    /* Проверим параметры */
    if ((NRN is null) or (SNUMB is null) or (SCAPTION is null) or (SNAME is null) or (DSTART is null) or (DEND is null)) then
      P_EXCEPTION(0,
                  'Регистрационный номер, номер, заголовок, наименование, даты начала и окончания являются обязательными при создании задачи для диаграммы Ганта.');
    end if;
    if ((NPROGRESS is not null) and (not (NPROGRESS between 0 and 100))) then
      P_EXCEPTION(0, 'Прогресс задачи должен быть значением от 0 до 100');
    end if;
    /* Формируем объект */
    RRES.NRN                 := NRN;
    RRES.SNUMB               := SNUMB;
    RRES.SCAPTION            := SCAPTION;
    RRES.SNAME               := SNAME;
    RRES.DSTART              := DSTART;
    RRES.DEND                := DEND;
    RRES.NPROGRESS           := NPROGRESS;
    RRES.SBG_COLOR           := SBG_COLOR;
    RRES.STEXT_COLOR         := STEXT_COLOR;
    RRES.BREAD_ONLY          := BREAD_ONLY;
    RRES.BREAD_ONLY_DATES    := BREAD_ONLY_DATES;
    RRES.BREAD_ONLY_PROGRESS := BREAD_ONLY_PROGRESS;
    RRES.RATTR_VALS          := TGANTT_TASK_ATTR_VALS();
    RRES.RDEPENDENCIES       := TGANTT_TASK_DEPENDENCIES();
    /* Возвращаем результат */
    return RRES;
  end TGANTT_TASK_MAKE;
  
  /* Добавление значения атрибута к задаче диаграммы Ганта */
  procedure TGANTT_TASK_ADD_ATTR_VAL
  (
    RGANTT                  in TGANTT,                 -- Описание диаграммы
    RTASK                   in out nocopy TGANTT_TASK, -- Описание задачи
    SNAME                   in varchar2,               -- Наименование
    SVALUE                  in varchar2,               -- Значение
    BCLEAR                  in boolean := false        -- Флаг очистки коллекции значений атрибутов (false - не очищать, true - очистить коллекцию перед добавлением)
  )
  is
  begin
    /* Проверим наименование */
    TGANTT_TASK_ATTR_NAME_CHECK(SNAME => SNAME);
    /* Проверим, что такой атрибут зарегистрирован */
    if (TGANTT_TASK_ATTR_FIND(RTASK_ATTRS => RGANTT.RTASK_ATTRS, SNAME => SNAME).SNAME is null) then
      P_EXCEPTION(0,
                  'Атрибут "%s" задачи диаграммы Ганта не зарегистрирован.',
                  SNAME);
    end if;
    /* Инициализируем коллекцию если необходимо */
    if ((RTASK.RATTR_VALS is null) or (BCLEAR)) then
      RTASK.RATTR_VALS := TGANTT_TASK_ATTR_VALS();
    end if;
    /* Добавляем элемент */
    RTASK.RATTR_VALS.EXTEND();
    RTASK.RATTR_VALS(RTASK.RATTR_VALS.LAST).SNAME := SNAME;
    RTASK.RATTR_VALS(RTASK.RATTR_VALS.LAST).SVALUE := SVALUE;
  end TGANTT_TASK_ADD_ATTR_VAL;
  
  /* Добавление предшествующей задачи к задаче диаграммы Ганта */
  procedure TGANTT_TASK_ADD_DEPENDENCY
  (
    RTASK                   in out nocopy TGANTT_TASK, -- Описание задачи
    NDEPENDENCY             in number,                 -- Рег. номер предшествующей задачи
    BCLEAR                  in boolean := false        -- Флаг очистки коллекции предшествущих задач (false - не очищать, true - очистить коллекцию перед добавлением)
  )
  is
  begin
    /* Инициализируем коллекцию если необходимо */
    if ((RTASK.RDEPENDENCIES is null) or (BCLEAR)) then
      RTASK.RDEPENDENCIES := TGANTT_TASK_DEPENDENCIES();
    end if;
    /* Добавляем элемент */
    RTASK.RDEPENDENCIES.EXTEND();
    RTASK.RDEPENDENCIES(RTASK.RDEPENDENCIES.LAST) := NDEPENDENCY;
  end TGANTT_TASK_ADD_DEPENDENCY;
  
  /* Сериализация описания задач диаграммы Ганта */
  procedure TGANTT_TASKS_TO_XML
  (
    RTASKS                  in TGANTT_TASKS   -- Коллекция задач диаграммы Ганта
  )
  is
    SDEPS                   PKG_STD.TLSTRING; -- Буфер для списка зависимых
  begin
    /* Обходим задачи из коллекции */
    if ((RTASKS is not null) and (RTASKS.COUNT > 0)) then
      for I in RTASKS.FIRST .. RTASKS.LAST
      loop
        /* Открываем строку */
        PKG_XFAST.DOWN_NODE(SNAME => SRESP_TAG_XGANTT_TASKS);
        /* Статические тарибуты */
        PKG_XFAST.ATTR(SNAME => SRESP_ATTR_ID, SVALUE => 'taskId' || RTASKS(I).NRN);
        PKG_XFAST.ATTR(SNAME => SRESP_ATTR_RN, NVALUE => RTASKS(I).NRN);
        PKG_XFAST.ATTR(SNAME => SRESP_ATTR_NUMB, SVALUE => RTASKS(I).SNUMB);
        PKG_XFAST.ATTR(SNAME => SRESP_ATTR_NAME, SVALUE => RTASKS(I).SCAPTION);
        PKG_XFAST.ATTR(SNAME => SRESP_ATTR_FULL_NAME, SVALUE => RTASKS(I).SNAME);
        PKG_XFAST.ATTR(SNAME => SRESP_ATTR_START, DVALUE => RTASKS(I).DSTART);
        PKG_XFAST.ATTR(SNAME => SRESP_ATTR_END, DVALUE => RTASKS(I).DEND);
        if (RTASKS(I).NPROGRESS is not null) then
          PKG_XFAST.ATTR(SNAME => SRESP_ATTR_TASK_PROGRESS, NVALUE => RTASKS(I).NPROGRESS);
        end if;
        if (RTASKS(I).SBG_COLOR is not null) then
          PKG_XFAST.ATTR(SNAME => SRESP_ATTR_TASK_BG_COLOR, SVALUE => RTASKS(I).SBG_COLOR);
        end if;
        if (RTASKS(I).STEXT_COLOR is not null) then
          PKG_XFAST.ATTR(SNAME => SRESP_ATTR_TASK_TEXT_COLOR, SVALUE => RTASKS(I).STEXT_COLOR);
        end if;
        if (RTASKS(I).BREAD_ONLY is not null) then
          PKG_XFAST.ATTR(SNAME => SRESP_ATTR_TASK_RO, BVALUE => RTASKS(I).BREAD_ONLY);
        end if;
        if (RTASKS(I).BREAD_ONLY_DATES is not null) then
          PKG_XFAST.ATTR(SNAME => SRESP_ATTR_TASK_RO_DATES, BVALUE => RTASKS(I).BREAD_ONLY_DATES);
        end if;
        if (RTASKS(I).BREAD_ONLY_PROGRESS is not null) then
          PKG_XFAST.ATTR(SNAME => SRESP_ATTR_TASK_RO_PRGRS, BVALUE => RTASKS(I).BREAD_ONLY_PROGRESS);
        end if;
        if ((RTASKS(I).RDEPENDENCIES is not null) and (RTASKS(I).RDEPENDENCIES.COUNT > 0)) then
          SDEPS := null;
          for J in RTASKS(I).RDEPENDENCIES.FIRST .. RTASKS(I).RDEPENDENCIES.LAST
          loop
            SDEPS := COALESCE(SDEPS, '') || 'taskId' || TO_CHAR(RTASKS(I).RDEPENDENCIES(J)) || ',';
          end loop;
          PKG_XFAST.ATTR(SNAME => SRESP_ATTR_TASK_DEPS, SVALUE => RTRIM(SDEPS, ','));
        end if;
        /* Динамические атрибуты */
        if ((RTASKS(I).RATTR_VALS is not null) and (RTASKS(I).RATTR_VALS.COUNT > 0)) then
          for J in RTASKS(I).RATTR_VALS.FIRST .. RTASKS(I).RATTR_VALS.LAST
          loop
            PKG_XFAST.ATTR(SNAME => RTASKS(I).RATTR_VALS(J).SNAME, SVALUE => RTASKS(I).RATTR_VALS(J).SVALUE);
          end loop;
        end if;
        /* Закрываем задачу */
        PKG_XFAST.UP();
      end loop;
    end if;
  end TGANTT_TASKS_TO_XML;

  /* Формирование диаграммы Ганта */
  function TGANTT_MAKE
  (
    STITLE                  in varchar2 := null,           -- Заголовок (null - не отображать)
    NZOOM                   in number := NGANTT_ZOOM_WEEK, -- Текущий масштаб (см. константы NGANTT_ZOOM_*)
    BZOOM_BAR               in boolean := true,            -- Обображать панель масштабирования
    BREAD_ONLY              in boolean := false,           -- Сроки и прогресс задач только для чтения
    BREAD_ONLY_DATES        in boolean := false,           -- Сроки задач только для чтения
    BREAD_ONLY_PROGRESS     in boolean := false            -- Прогресс задач только для чтения
  ) return                  TGANTT                         -- Результат работы
  is
    RRES                    TGANTT;                        -- Буфер для результата
  begin
    /* Формируем объект */
    RRES.STITLE              := STITLE;
    RRES.NZOOM               := COALESCE(NZOOM, NGANTT_ZOOM_WEEK);
    RRES.BZOOM_BAR           := COALESCE(BZOOM_BAR, true);
    RRES.BREAD_ONLY          := COALESCE(BREAD_ONLY, false);
    RRES.BREAD_ONLY_DATES    := COALESCE(BREAD_ONLY_DATES, false);
    RRES.BREAD_ONLY_PROGRESS := COALESCE(BREAD_ONLY_PROGRESS, false);
    RRES.RTASK_ATTRS         := TGANTT_TASK_ATTRS();
    RRES.RTASK_COLORS        := TGANTT_TASK_COLORS();
    RRES.RTASKS              := TGANTT_TASKS();
    /* Возвращаем результат */
    return RRES;
  end TGANTT_MAKE;
  
  /* Добавление описания атрибута карточки задачи диаграммы Ганта */
  procedure TGANTT_ADD_TASK_ATTR
  (
    RGANTT                  in out nocopy TGANTT, -- Описание диаграммы Ганта
    SNAME                   in varchar2,          -- Наименование
    SCAPTION                in varchar2,          -- Заголовок
    BCLEAR                  in boolean := false   -- Флаг очистки коллекции атрибутов (false - не очищать, true - очистить коллекцию перед добавлением)
  )
  is
  begin
    /* Проверим наименование */
    TGANTT_TASK_ATTR_NAME_CHECK(SNAME => SNAME);
    /* Проверим, что такого ещё нет */
    if (TGANTT_TASK_ATTR_FIND(RTASK_ATTRS => RGANTT.RTASK_ATTRS, SNAME => SNAME).SNAME is not null) then
      P_EXCEPTION(0,
                  'Атрибут "%s" задачи диаграммы Ганта уже зарегистрирован.',
                  SNAME);
    end if;
    /* Инициализируем коллекцию если необходимо */
    if ((RGANTT.RTASK_ATTRS is null) or (BCLEAR)) then
      RGANTT.RTASK_ATTRS := TGANTT_TASK_ATTRS();
    end if;
    /* Добавляем элемент */
    RGANTT.RTASK_ATTRS.EXTEND();
    RGANTT.RTASK_ATTRS(RGANTT.RTASK_ATTRS.LAST).SNAME := SNAME;
    RGANTT.RTASK_ATTRS(RGANTT.RTASK_ATTRS.LAST).SCAPTION := SCAPTION;
  end TGANTT_ADD_TASK_ATTR;

  /* Добавление описания цвета задачи диаграммы Ганта */
  procedure TGANTT_ADD_TASK_COLOR
  (
    RGANTT                  in out nocopy TGANTT, -- Описание диаграммы Ганта
    SBG_COLOR               in varchar2 := null,  -- Цвет заливки задачи (формат - HTML-цвет, #RRGGBBAA)
    STEXT_COLOR             in varchar2 := null,  -- Цвет текста заголовка задачи (формат - HTML-цвет, #RRGGBBAA)
    SDESC                   in varchar2,          -- Описание
    BCLEAR                  in boolean := false   -- Флаг очистки коллекции цветов (false - не очищать, true - очистить коллекцию перед добавлением)
  )
  is
  begin
    /* Проверим параметры */
    if ((SBG_COLOR is null) and (STEXT_COLOR is null)) then
      P_EXCEPTION(0,
                  'Должен быть указан цвет заливки или цвет текста задачи.');
    end if;
    if (SDESC is null) then
      P_EXCEPTION(0, 'Описание цвета должно быть задано.');
    end if;
    /* Проверим, что такого ещё нет */
    if (TGANTT_TASK_COLOR_FIND(RTASK_COLORS => RGANTT.RTASK_COLORS, SBG_COLOR => SBG_COLOR, STEXT_COLOR => STEXT_COLOR)
       .SDESC is not null) then
      P_EXCEPTION(0,
                  'Такое описание цвета для задачи диаграммы Ганта уже зарегистрировано.');
    end if;
    /* Инициализируем коллекцию если необходимо */
    if ((RGANTT.RTASK_COLORS is null) or (BCLEAR)) then
      RGANTT.RTASK_COLORS := TGANTT_TASK_COLORS();
    end if;
    /* Добавляем элемент */
    RGANTT.RTASK_COLORS.EXTEND();
    RGANTT.RTASK_COLORS(RGANTT.RTASK_COLORS.LAST).SBG_COLOR := SBG_COLOR;
    RGANTT.RTASK_COLORS(RGANTT.RTASK_COLORS.LAST).STEXT_COLOR := STEXT_COLOR;
    RGANTT.RTASK_COLORS(RGANTT.RTASK_COLORS.LAST).SDESC := SDESC;
  end TGANTT_ADD_TASK_COLOR;

  /* Добавление задачи к диаграмме Ганта */
  procedure TGANTT_ADD_TASK
  (
    RGANTT                  in out nocopy TGANTT, -- Описание диаграммы Ганта
    RTASK                   in TGANTT_TASK,       -- Задача
    BCLEAR                  in boolean := false   -- Флаг очистки коллекции задач диаграммы (false - не очищать, true - очистить коллекцию перед добавлением)
  )
  is
  begin
    /* Инициализируем коллекцию если необходимо */
    if ((RGANTT.RTASKS is null) or (BCLEAR)) then
      RGANTT.RTASKS := TGANTT_TASKS();
    end if;
    /* Добавляем элемент */
    RGANTT.RTASKS.EXTEND();
    RGANTT.RTASKS(RGANTT.RTASKS.LAST) := RTASK;
  end TGANTT_ADD_TASK;
  
  /* Сериализация описания заголовка диаграммы Ганта */
  procedure TGANTT_DEF_TO_XML
  (
    RGANTT                  in TGANTT   -- Описание диаграммы Ганта
  )
  is    
  begin
    /* Открываем описание заголовка */
    PKG_XFAST.DOWN_NODE(SNAME => SRESP_TAG_XGANTT_DEF);
    /* Cтатические атрибуты заголовка */
    PKG_XFAST.ATTR(SNAME => SRESP_ATTR_TITLE, SVALUE => RGANTT.STITLE);
    PKG_XFAST.ATTR(SNAME => SRESP_ATTR_ZOOM, NVALUE => RGANTT.NZOOM);
    PKG_XFAST.ATTR(SNAME => SRESP_ATTR_GANTT_ZOOM_BAR, BVALUE => RGANTT.BZOOM_BAR);
    PKG_XFAST.ATTR(SNAME => SRESP_ATTR_TASK_RO, BVALUE => RGANTT.BREAD_ONLY);
    PKG_XFAST.ATTR(SNAME => SRESP_ATTR_TASK_RO_DATES, BVALUE => RGANTT.BREAD_ONLY_DATES);
    PKG_XFAST.ATTR(SNAME => SRESP_ATTR_TASK_RO_PRGRS, BVALUE => RGANTT.BREAD_ONLY_PROGRESS);
    /* Если есть динамические атрибуты */
    if ((RGANTT.RTASK_ATTRS is not null) and (RGANTT.RTASK_ATTRS.COUNT > 0)) then
      /* Обходим динамические атрибуты задачи */
      for I in RGANTT.RTASK_ATTRS.FIRST .. RGANTT.RTASK_ATTRS.LAST
      loop
        /* Открываем динамический атрибут задачи */
        PKG_XFAST.DOWN_NODE(SNAME => SRESP_ATTR_TASK_ATTRIBUTES);
        /* Наполняем его атрибутами */
        PKG_XFAST.ATTR(SNAME => SRESP_ATTR_NAME, SVALUE => RGANTT.RTASK_ATTRS(I).SNAME);
        PKG_XFAST.ATTR(SNAME => SRESP_ATTR_CAPTION, SVALUE => RGANTT.RTASK_ATTRS(I).SCAPTION);
        /* Закрываем динамический атрибут задачи */
        PKG_XFAST.UP();
      end loop;
    end if;
    /* Если есть описание цветов */
    if ((RGANTT.RTASK_COLORS is not null) and (RGANTT.RTASK_COLORS.COUNT > 0)) then
      /* Обходим описание цветов задачи */
      for I in RGANTT.RTASK_COLORS.FIRST .. RGANTT.RTASK_COLORS.LAST
      loop
        /* Открываем описание цвета задачи */
        PKG_XFAST.DOWN_NODE(SNAME => SRESP_ATTR_TASK_COLORS);
        /* Наполняем его атрибутами */
        if (RGANTT.RTASK_COLORS(I).SBG_COLOR is not null) then
          PKG_XFAST.ATTR(SNAME => SRESP_ATTR_TASK_BG_COLOR, SVALUE => RGANTT.RTASK_COLORS(I).SBG_COLOR);
        end if;
        if (RGANTT.RTASK_COLORS(I).STEXT_COLOR is not null) then
          PKG_XFAST.ATTR(SNAME => SRESP_ATTR_TASK_TEXT_COLOR, SVALUE => RGANTT.RTASK_COLORS(I).STEXT_COLOR);
        end if;
        PKG_XFAST.ATTR(SNAME => SRESP_ATTR_DESC, SVALUE => RGANTT.RTASK_COLORS(I).SDESC);
        /* Закрываем описание цвета задачи */
        PKG_XFAST.UP();
      end loop;
    end if;
    /* Закрываем описание заголовка */
    PKG_XFAST.UP();
  end TGANTT_DEF_TO_XML;
  
  /* Сериализация диаграммы Ганта */
  function TGANTT_TO_XML
  (
    RGANTT                  in TGANTT,     -- Описание диаграммы Ганта
    NINCLUDE_DEF            in number := 1 -- Включить описание заголовка (0 - нет, 1 - да)
  ) return                  clob           -- XML-описание
  is
    CRES                    clob;          -- Буфер для результата
  begin
    /* Начинаем формирование XML */
    PKG_XFAST.PROLOGUE(ITYPE => PKG_XFAST.CONTENT_);
    /* Открываем корень */
    PKG_XFAST.DOWN_NODE(SNAME => SRESP_TAG_XDATA);
    /* Если необходимо включить описание колонок */
    if (NINCLUDE_DEF = 1) then
      TGANTT_DEF_TO_XML(RGANTT => RGANTT);
    end if;
    /* Формируем описание задач */
    TGANTT_TASKS_TO_XML(RTASKS => RGANTT.RTASKS);
    /* Закрываем корень */
    PKG_XFAST.UP();
    /* Сериализуем */
    CRES := PKG_XFAST.SERIALIZE_TO_CLOB();
    /* Завершаем формирование XML */
    PKG_XFAST.EPILOGUE();
    /* Возвращаем полученное */
    return CRES;
  exception
    when others then
      /* Завершаем формирование XML */
      PKG_XFAST.EPILOGUE();
      /* Вернем ошибку */
      PKG_STATE.DIAGNOSTICS_STACKED();
      P_EXCEPTION(0, PKG_STATE.SQL_ERRM());
  end TGANTT_TO_XML;
  
  /* Проверка корректности наименования дополнительного атрибута элемента данных графика */
  procedure TCHART_DATASET_ITEM_ATTR_NM_CH
  (
    SNAME                   in varchar2 -- Наименование
  )
  is
  begin
    if (SNAME in (SRESP_ATTR_CHART_DS_I_VAL)) then
      P_EXCEPTION(0,
                  'Наименование атрибута "%s" является зарезервированным.',
                  SNAME);
    end if;
  end TCHART_DATASET_ITEM_ATTR_NM_CH;
  
  /* Сериализация меток графика */
  procedure TCHART_LABELS_TO_XML
  (
    RLABELS                 in TCHART_LABELS -- Описание диаграммы Ганта
  )
  is    
  begin
    /* Если есть метки */
    if ((RLABELS is not null) and (RLABELS.COUNT > 0)) then
      /* Обходим метки */
      for I in RLABELS.FIRST .. RLABELS.LAST
      loop
        /* Открываем описание метки */
        PKG_XFAST.DOWN_NODE(SNAME => SRESP_ATTR_CHART_LABELS);
        /* Добавляем значение */
        PKG_XFAST.VALUE(SVALUE => RLABELS(I));
        /* Закрываем описание метки */
        PKG_XFAST.UP();
      end loop;
    end if;
  end TCHART_LABELS_TO_XML;
  
  /* Добавление дополнительного атрибута элемента данных графика */
  procedure TCHART_DATASET_ITM_ATTR_VL_ADD
  (
    RATTR_VALS              in out nocopy TCHART_DATASET_ITEM_ATTR_VALS, -- Коллекция дополнительных атрибутов элемента данных графика
    SNAME                   PKG_STD.TSTRING,                             -- Наименование
    SVALUE                  PKG_STD.TSTRING,                             -- Значение
    BCLEAR                  in boolean := false                          -- Флаг очистки коллекции дополнительных атрибутов элемента данных (false - не очищать, true - очистить коллекцию перед добавлением)
  )
  is
  begin
    /* Проверим корректность наименования */
    TCHART_DATASET_ITEM_ATTR_NM_CH(SNAME => SNAME);
    /* Инициализируем коллекцию если необходимо */
    if ((RATTR_VALS is null) or (BCLEAR)) then
      RATTR_VALS := TCHART_DATASET_ITEM_ATTR_VALS();
    end if;
    /* Добавляем элемент */
    RATTR_VALS.EXTEND();
    RATTR_VALS(RATTR_VALS.LAST).SNAME := SNAME;
    RATTR_VALS(RATTR_VALS.LAST).SVALUE := SVALUE;
  end TCHART_DATASET_ITM_ATTR_VL_ADD;
  
  /* Формирование набора данных графика */
  function TCHART_DATASET_MAKE
  (
    SCAPTION                in varchar2,         -- Заголовок
    SBORDER_COLOR           in varchar2 := null, -- Цвет границы элемента данных на графике (null - использовать цвет по умолчанию из стилей, формат - HTML-цвет, #RRGGBBAA)
    SBG_COLOR               in varchar2 := null  -- Цвет заливки элемента данных на графике (null - использовать цвет по умолчанию из стилей, формат - HTML-цвет, #RRGGBBAA)
  ) return                  TCHART_DATASET       -- Результат работы
  is
    RRES                    TCHART_DATASET;      -- Буфер для результата
  begin
    /* Формируем объект */
    RRES.SCAPTION      := SCAPTION;
    RRES.SBORDER_COLOR := SBORDER_COLOR;
    RRES.SBG_COLOR     := SBG_COLOR;
    RRES.RITEMS        := TCHART_DATASET_ITEMS();
    /* Возвращаем результат */
    return RRES;
  end TCHART_DATASET_MAKE;
  
  /* Добавление элемента в набор данных графика */
  procedure TCHART_DATASET_ADD_ITEM
  (
    RDATASET                in out nocopy TCHART_DATASET,             -- Описание набора данных графика
    NVALUE                  in number,                                -- Значение элемента данных, отображаемое на графике
    RATTR_VALS              in TCHART_DATASET_ITEM_ATTR_VALS := null, -- Значения дополнительных атрбутов (null - дополнительные атрибуты не определены)
    BCLEAR                  in boolean := false                       -- Флаг очистки коллекции элементов набора данных (false - не очищать, true - очистить коллекцию перед добавлением)
  )
  is
  begin
    /* Инициализируем коллекцию если необходимо */
    if ((RDATASET.RITEMS is null) or (BCLEAR)) then
      RDATASET.RITEMS := TCHART_DATASET_ITEMS();
    end if;
    /* Добавляем элемент */
    RDATASET.RITEMS.EXTEND();
    RDATASET.RITEMS(RDATASET.RITEMS.LAST).NVALUE := NVALUE;
    RDATASET.RITEMS(RDATASET.RITEMS.LAST).RATTR_VALS := RATTR_VALS;
  end TCHART_DATASET_ADD_ITEM;
  
  /* Сериализация коллекции наборов данных графика */
  procedure TCHART_DATASETS_TO_XML
  (
    RDATASETS               in TCHART_DATASETS -- Наборы данных графика
  )
  is
  begin
    /* Если есть наборы данных */
    if ((RDATASETS is not null) and (RDATASETS.COUNT > 0)) then
      /* Обходим наборы данных */
      for I in RDATASETS.FIRST .. RDATASETS.LAST
      loop
        /* Открываем набор данных */
        PKG_XFAST.DOWN_NODE(SNAME => SRESP_ATTR_CHART_DATASETS);
        /* Добавляем статические атрибуты */
        PKG_XFAST.ATTR(SNAME => SRESP_ATTR_CHART_DS_LABEL, SVALUE => RDATASETS(I).SCAPTION);
        if (RDATASETS(I).SBORDER_COLOR is not null) then
          PKG_XFAST.ATTR(SNAME => SRESP_ATTR_CHART_DS_BR_CLR, SVALUE => RDATASETS(I).SBORDER_COLOR);
        end if;
        if (RDATASETS(I).SBG_COLOR is not null) then
          PKG_XFAST.ATTR(SNAME => SRESP_ATTR_CHART_DS_BG_CLR, SVALUE => RDATASETS(I).SBG_COLOR);
        end if;
        /* Если в наборе данных есть элементы */
        if ((RDATASETS(I).RITEMS is not null) and (RDATASETS(I).RITEMS.COUNT > 0)) then
          /* Обходим элементы набора данных для формирования отображаемых значений */
          for J in RDATASETS(I).RITEMS.FIRST .. RDATASETS(I).RITEMS.LAST
          loop
            /* Открываем значение элемента набора данных */
            PKG_XFAST.DOWN_NODE(SNAME => SRESP_ATTR_CHART_DS_DATA);
            /* Формируем значение элемента */
            PKG_XFAST.VALUE(NVALUE => RDATASETS(I).RITEMS(J).NVALUE);
            /* Закрываем значение элемента набора данных */
            PKG_XFAST.UP();
          end loop;
          /* Обходим элементы набора данных для формирования из самих */
          for J in RDATASETS(I).RITEMS.FIRST .. RDATASETS(I).RITEMS.LAST
          loop
            /* Открываем элемент набора данных */
            PKG_XFAST.DOWN_NODE(SNAME => SRESP_ATTR_CHART_DS_ITEMS);
            /* Добавляем статические атрибуты */
            PKG_XFAST.ATTR(SNAME => SRESP_ATTR_CHART_DS_I_VAL, NVALUE => RDATASETS(I).RITEMS(J).NVALUE);
            /* Добавляем дополнительные атрибуты */
            if ((RDATASETS(I).RITEMS(J).RATTR_VALS is not null) and (RDATASETS(I).RITEMS(J).RATTR_VALS.COUNT > 0)) then
              for K in RDATASETS(I).RITEMS(J).RATTR_VALS.FIRST .. RDATASETS(I).RITEMS(J).RATTR_VALS.LAST
              loop
                PKG_XFAST.ATTR(SNAME  => RDATASETS(I).RITEMS(J).RATTR_VALS(K).SNAME,
                               SVALUE => RDATASETS(I).RITEMS(J).RATTR_VALS(K).SVALUE);
              end loop;
            end if;
            /* Закрываем элемент набора данных */
            PKG_XFAST.UP();
          end loop;
        end if;
        /* Закрываем набор данных */
        PKG_XFAST.UP();
      end loop;
    end if;
  end TCHART_DATASETS_TO_XML;
  
  /* Формирование графика */
  function TCHART_MAKE
  (
    STYPE                   in varchar2,         -- Тип (см. константы SCHART_TYPE_*)
    STITLE                  in varchar2 := null, -- Заголовок (null - не отображать)
    SLGND_POS               in varchar2 := null  -- Расположение легенды (null - не отображать, см. константы SCHART_LGND_POS_*)
  ) return                  TCHART               -- Результат работы
  is
    RRES                    TCHART;              -- Буфер для результата
  begin
    /* Формируем объект */
    RRES.STYPE     := STYPE;
    RRES.STITLE    := STITLE;
    RRES.SLGND_POS := SLGND_POS;
    RRES.RLABELS   := TCHART_LABELS();
    RRES.RDATASETS := TCHART_DATASETS();
    /* Возвращаем результат */
    return RRES;
  end TCHART_MAKE;
  
  /* Добавление метки значения графика */
  procedure TCHART_ADD_LABEL
  (
    RCHART                  in out nocopy TCHART, -- Описание графика
    SLABEL                  in varchar2,          -- Метка значения
    BCLEAR                  in boolean := false   -- Флаг очистки коллекции меток (false - не очищать, true - очистить коллекцию перед добавлением)
  )
  is
  begin
    /* Инициализируем коллекцию если необходимо */
    if ((RCHART.RLABELS is null) or (BCLEAR)) then
      RCHART.RLABELS := TCHART_LABELS();
    end if;
    /* Добавляем элемент */
    RCHART.RLABELS.EXTEND();
    RCHART.RLABELS(RCHART.RLABELS.LAST) := SLABEL;
  end TCHART_ADD_LABEL;
  
  /* Добавление набора данных графика */
  procedure TCHART_ADD_DATASET
  (
    RCHART                  in out nocopy TCHART, -- Описание графика
    RDATASET                in TCHART_DATASET,    -- Набор данных
    BCLEAR                  in boolean := false   -- Флаг очистки коллекции наборов данных (false - не очищать, true - очистить коллекцию перед добавлением)
  )
  is
  begin
    /* Инициализируем коллекцию если необходимо */
    if ((RCHART.RDATASETS is null) or (BCLEAR)) then
      RCHART.RDATASETS := TCHART_DATASETS();
    end if;
    /* Добавляем элемент */
    RCHART.RDATASETS.EXTEND();
    RCHART.RDATASETS(RCHART.RDATASETS.LAST) := RDATASET;
  end TCHART_ADD_DATASET;
  
  /* Сериализация описания заголовка графика */
  procedure TCHART_DEF_TO_XML
  (
    RCHART                  in TCHART   -- Описание графика
  )
  is    
  begin
    /* Cтатические атрибуты заголовка */
    PKG_XFAST.ATTR(SNAME => SRESP_ATTR_TYPE, SVALUE => RCHART.STYPE);
    PKG_XFAST.ATTR(SNAME => SRESP_ATTR_TITLE, SVALUE => RCHART.STITLE);
    PKG_XFAST.ATTR(SNAME => SRESP_ATTR_CHART_LGND_POS, SVALUE => RCHART.SLGND_POS);
  end TCHART_DEF_TO_XML;
  
  /* Сериализация графика */
  function TCHART_TO_XML
  (
    RCHART                  in TCHART,     -- Описание графика
    NINCLUDE_DEF            in number := 1 -- Включить описание заголовка (0 - нет, 1 - да)
  ) return                  clob           -- XML-описание
  is
    CRES                    clob;          -- Буфер для результата
  begin
    /* Начинаем формирование XML */
    PKG_XFAST.PROLOGUE(ITYPE => PKG_XFAST.CONTENT_);
    /* Открываем корень */
    PKG_XFAST.DOWN_NODE(SNAME => SRESP_TAG_XDATA);
    /* Открываем график */
    PKG_XFAST.DOWN_NODE(SNAME => SRESP_TAG_XCHART);
    /* Если необходимо включить описание колонок */
    if (NINCLUDE_DEF = 1) then
      TCHART_DEF_TO_XML(RCHART => RCHART);
    end if;
    /* Формируем описание меток */
    TCHART_LABELS_TO_XML(RLABELS => RCHART.RLABELS);
    /* Формируем описание наборов данных */
    TCHART_DATASETS_TO_XML(RDATASETS => RCHART.RDATASETS);
    /* Закрываем график */
    PKG_XFAST.UP();
    /* Закрываем корень */
    PKG_XFAST.UP();
    /* Сериализуем */
    CRES := PKG_XFAST.SERIALIZE_TO_CLOB();
    /* Завершаем формирование XML */
    PKG_XFAST.EPILOGUE();
    /* Возвращаем полученное */
    return CRES;
  exception
    when others then
      /* Завершаем формирование XML */
      PKG_XFAST.EPILOGUE();
      /* Вернем ошибку */
      PKG_STATE.DIAGNOSTICS_STACKED();
      P_EXCEPTION(0, PKG_STATE.SQL_ERRM());
  end TCHART_TO_XML;
  
end PKG_P8PANELS_VISUAL;
/

create or replace package PKG_P8PANELS_VISUAL as

  /* Константы - типы данных */
  SDATA_TYPE_STR            constant PKG_STD.TSTRING := 'STR';  -- Тип данных "строка"
  SDATA_TYPE_NUMB           constant PKG_STD.TSTRING := 'NUMB'; -- Тип данных "число"
  SDATA_TYPE_DATE           constant PKG_STD.TSTRING := 'DATE'; -- Тип данных "дата"
  
  /* Константы - направление сортировки */
  SORDER_DIRECTION_ASC      constant PKG_STD.TSTRING := 'ASC';  -- По возрастанию
  SORDER_DIRECTION_DESC     constant PKG_STD.TSTRING := 'DESC'; -- По убыванию

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
    RCOL_VALS               TCOL_VALS        -- Предопределённые значения
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
  
  /* Формирование таблицы данныз */
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

end PKG_P8PANELS_VISUAL;
/
create or replace package body PKG_P8PANELS_VISUAL as

  /* Константы - тэги запросов */
  SRQ_TAG_XROOT           constant PKG_STD.TSTRING := 'XROOT';     -- Тэг для корня данных запроса
  SRQ_TAG_XFILTERS        constant PKG_STD.TSTRING := 'filters';   -- Тэг для строк данных
  SRQ_TAG_XORDERS         constant PKG_STD.TSTRING := 'orders';    -- Тэг для описания колонок
  SRQ_TAG_SNAME           constant PKG_STD.TSTRING := 'name';      -- Тэг для наименования
  SRQ_TAG_SDIRECTION      constant PKG_STD.TSTRING := 'direction'; -- Тэг для направления
  SRQ_TAG_SFROM           constant PKG_STD.TSTRING := 'from';      -- Тэг для значения "с"
  SRQ_TAG_STO             constant PKG_STD.TSTRING := 'to';        -- Тэг для значения "по"

  /* Константы - тэги ответов */
  SRESP_TAG_XDATA           constant PKG_STD.TSTRING := 'XDATA';        -- Тэг для корня описания данных
  SRESP_TAG_XROWS           constant PKG_STD.TSTRING := 'XROWS';        -- Тэг для строк данных
  SRESP_TAG_XCOLUMNS_DEF    constant PKG_STD.TSTRING := 'XCOLUMNS_DEF'; -- Тэг для описания колонок

  /* Константы - атрибуты ответов */
  SRESP_ATTR_NAME           constant PKG_STD.TSTRING := 'name';     -- Атрибут для наименования
  SRESP_ATTR_CAPTION        constant PKG_STD.TSTRING := 'caption';  -- Атрибут для подписи
  SRESP_ATTR_DATA_TYPE      constant PKG_STD.TSTRING := 'dataType'; -- Атрибут для типа данных
  SRESP_ATTR_VISIBLE        constant PKG_STD.TSTRING := 'visible';  -- Атрибут для флага видимости
  SRESP_ATTR_ORDER          constant PKG_STD.TSTRING := 'order';    -- Атрибут для флага сортировки
  SRESP_ATTR_FILTER         constant PKG_STD.TSTRING := 'filter';   -- Атрибут для флага отбора
  SRESP_ATTR_VALUES         constant PKG_STD.TSTRING := 'values';   -- Атрибут для значений
  
  /* Константы - параметры условий отбора */
  SCOND_FROM_POSTFIX        constant PKG_STD.TSTRING := 'From'; -- Постфикс наименования нижней границы условия отбора
  SCOND_TO_POSTFIX          constant PKG_STD.TSTRING := 'To';   -- Постфикс наименования верхней границы условия отбора

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
    RCOL_VALS               in TCOL_VALS := null           -- Предопределённые значения
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
        PKG_XFAST.ATTR(SNAME => SRESP_ATTR_ORDER, BVALUE => RCOL_DEFS(I).BORDER);
        PKG_XFAST.ATTR(SNAME => SRESP_ATTR_FILTER, BVALUE => RCOL_DEFS(I).BFILTER);
        /* Предопределённые значения */
        if (RCOL_DEFS(I).RCOL_VALS is not null) and (RCOL_DEFS(I).RCOL_VALS.COUNT > 0) then
          for V in RCOL_DEFS(I).RCOL_VALS.FIRST .. RCOL_DEFS(I).RCOL_VALS.LAST
          loop
            /* Открываем описание предопределённого значения */
            PKG_XFAST.DOWN_NODE(SNAME => SRESP_ATTR_VALUES);
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
  
  /* Формирование таблицы данныз */
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
    TROWS_TO_XML(RCOL_DEFS => RDATA_GRID.RCOL_DEFS,RROWS => RDATA_GRID.RROWS);
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
  
end PKG_P8PANELS_VISUAL;
/

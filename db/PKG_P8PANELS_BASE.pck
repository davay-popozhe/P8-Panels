create or replace package PKG_P8PANELS_BASE as

  /*Константы - Типовой постфикс тега для массива (при переводе XML -> JSON) */
  SXML_ALWAYS_ARRAY_POSTFIX  constant PKG_STD.TSTRING := '__SYSTEM__ARRAY__';

  /* Конвертация строки в число */
  function UTL_S2N
  (
    SVALUE                  in varchar2 -- Конвертируемое строковое значение
  ) return                  number;     -- Конвертированное число

  /* Конвертация даты в число */
  function UTL_S2D
  (
    SVALUE                  in varchar2 -- Конвертируемое строковое значение
  ) return                  date;       -- Конвертированная дата
  
  /* Базовое исполнение действий */
  procedure PROCESS
  (
    CIN                     in clob,    -- Входные параметры
    COUT                    out clob    -- Результат
  );

end PKG_P8PANELS_BASE;
/
create or replace package body PKG_P8PANELS_BASE as

  /* Константы - коды дествий запросов */
  SRQ_ACTION_EXEC_STORED    constant PKG_STD.TSTRING := 'EXEC_STORED'; -- Запрос на исполнение хранимой процедуры

  /* Константы - тэги запросов */
  SRQ_TAG_XREQUEST          constant PKG_STD.TSTRING := 'XREQUEST';   -- Корневой тэг запроса
  SRQ_TAG_XPAYLOAD          constant PKG_STD.TSTRING := 'XPAYLOAD';   -- Тэг для данных запроса
  SRQ_TAG_SACTION           constant PKG_STD.TSTRING := 'SACTION';    -- Тэг для действия запроса
  SRQ_TAG_SSTORED           constant PKG_STD.TSTRING := 'SSTORED';    -- Тэг для имени хранимого объекта в запросе
  SRQ_TAG_SRESP_ARG         constant PKG_STD.TSTRING := 'SRESP_ARG';  -- Тэг для имени аргумента, формирующего данные ответа
  SRQ_TAG_XARGUMENTS        constant PKG_STD.TSTRING := 'XARGUMENTS'; -- Тэг для списка аргументов хранимого объекта/выборки в запросе
  SRQ_TAG_XARGUMENT         constant PKG_STD.TSTRING := 'XARGUMENT';  -- Тэг для аргумента хранимого объекта/выборки в запросе
  SRQ_TAG_SNAME             constant PKG_STD.TSTRING := 'SNAME';      -- Тэг для наименования в запросе
  SRQ_TAG_SDATA_TYPE        constant PKG_STD.TSTRING := 'SDATA_TYPE'; -- Тэг для типа данных в запросе
  SRQ_TAG_VALUE             constant PKG_STD.TSTRING := 'VALUE';      -- Тэг для значения в запросе

  /* Константы - тэги ответов */
  SRESP_TAG_XPAYLOAD        constant PKG_STD.TSTRING := 'XPAYLOAD';       -- Тэг для данных ответа
  SRESP_TAG_XOUT_ARGUMENTS  constant PKG_STD.TSTRING := 'XOUT_ARGUMENTS'; -- Тэг для выходных аргументов хранимого объекта в ответе
  SRESP_TAG_SDATA_TYPE      constant PKG_STD.TSTRING := 'SDATA_TYPE';     -- Тэг для типа данных в ответе
  SRESP_TAG_VALUE           constant PKG_STD.TSTRING := 'VALUE';          -- Тэг для значения в ответе
  SRESP_TAG_SNAME           constant PKG_STD.TSTRING := 'SNAME';          -- Тэг для наименования в ответе

  /* Константы - типы данных */
  SDATA_TYPE_STR            constant PKG_STD.TSTRING := 'STR';  -- Тип данных "строка"
  SDATA_TYPE_NUMB           constant PKG_STD.TSTRING := 'NUMB'; -- Тип данных "число"
  SDATA_TYPE_DATE           constant PKG_STD.TSTRING := 'DATE'; -- Тип данных "дата"
  SDATA_TYPE_CLOB           constant PKG_STD.TSTRING := 'CLOB'; -- Тип данных "текст"
  
  /* Константы - состояния объектов БД */
  SDB_OBJECT_STATE_VALID    constant PKG_STD.TSTRING := 'VALID'; -- Объект валиден

  /* Типы данных - аргументы */
  type TARGUMENT is record
  (
    SNAME                   PKG_STD.TSTRING,  -- Наименование
    SDATA_TYPE              PKG_STD.TSTRING,  -- Тип данных (см. константы SPWS_DATA_TYPE_*)
    SVALUE                  PKG_STD.TSTRING,  -- Значение (строка)
    NVALUE                  PKG_STD.TLNUMBER, -- Значение (число)
    DVALUE                  PKG_STD.TLDATE,   -- Значение (дата)
    CVALUE                  clob              -- Значение (текст)
  );

  /* Типы данных - коллекция аргументов запроса */
  type TARGUMENTS is table of TARGUMENT;

  /* Конвертация строки в число */
  function UTL_S2N
  (
    SVALUE                  in varchar2      -- Конвертируемое строковое значение
  ) return                  number           -- Конвертированное число
  is
    NVALUE                  PKG_STD.TNUMBER; -- Результат работы
  begin
    /* Пробуем конвертировать */
    NVALUE := TO_NUMBER(replace(SVALUE, ',', '.'));
    /* Отдаём результат */
    return NVALUE;
  exception
    when others then
      P_EXCEPTION(0, 'Неверный формат числа (%s).', SVALUE);
  end UTL_S2N;
  
  /* Конвертация даты в число */
  function UTL_S2D
  (
    SVALUE                  in varchar2      -- Конвертируемое строковое значение
  ) return                  date             -- Конвертированная дата
  is
    DVALUE                  PKG_STD.TLDATE; -- Результат работы
  begin
    /* Пробуем конвертировать */
    begin
      DVALUE := TO_DATE(SVALUE, 'YYYY-MM-DD');
    exception
      when others then
        begin
          DVALUE := TO_DATE(SVALUE, 'YYYY/MM/DD');
        exception
          when others then
            begin
              DVALUE := TO_DATE(SVALUE, 'DD.MM.YYYY');
            exception
              when others then
                DVALUE := TO_DATE(SVALUE, 'DD/MM/YYYY');
            end;
        end;
    end;
    /* Отдаём результат */
    return DVALUE;
  exception
    when others then
      P_EXCEPTION(0, 'Неверный формат даты (%s).', SVALUE);
  end UTL_S2D;

  /* Формирование сообщения об отсутствии значения */
  function MSG_NO_DATA_MAKE
  (
    SPATH                   in varchar2 := null, -- Путь по которому ожидалось значение
    SMESSAGE_OBJECT         in varchar2 := null  -- Наимемнование объекта для формулирования сообщения об ошибке
  ) return                  varchar2             -- Сформированное сообщение об ошибке
  is
    SPATH_                  PKG_STD.TSTRING;     -- Буфер для пути
    SMESSAGE_OBJECT_        PKG_STD.TSTRING;     -- Буфер для наименования объекта
  begin
    /* Подготовим путь к выдаче */
    if (SPATH is not null) then
      SPATH_ := ' (' || SPATH || ')';
    end if;
    /* Подготовим наименование объекта к выдаче */
    if (SMESSAGE_OBJECT is not null) then
      SMESSAGE_OBJECT_ := ' элемента "' || SMESSAGE_OBJECT || '"';
    else
      SMESSAGE_OBJECT_ := ' элемента';
    end if;
    /* Вернём сформированное сообщение */
    return 'Не указано значение' || SMESSAGE_OBJECT_ || SPATH_ || '.';
  end MSG_NO_DATA_MAKE;

  /* Конвертация стандартного типа данных (PKG_STD) в тип данных сервиса (PWS) */
  function STD_DATA_TYPE_TO_STR
  (
    NSTD_DATA_TYPE          in number        -- Станартный тип данных
  ) return                  varchar2         -- Соответствующий тип данных сервиса
  is
    SRES                    PKG_STD.TSTRING; -- Буфер для результата
  begin
    /* Работаем от типа данных */
    case NSTD_DATA_TYPE
      /* Строка */
      when PKG_STD.DATA_TYPE_STR then
        SRES := SDATA_TYPE_STR;
      /* Число */
      when PKG_STD.DATA_TYPE_NUM then
        SRES := SDATA_TYPE_NUMB;
      /* Дата */
      when PKG_STD.DATA_TYPE_DATE then
        SRES := SDATA_TYPE_DATE;
      /* Текст */
      when PKG_STD.DATA_TYPE_CLOB then
        SRES := SDATA_TYPE_CLOB;
      /* Неизвестный тип данных */
      else
        P_EXCEPTION(0,
                    'Тип данных "%s" не поддерживается.',
                    COALESCE(TO_CHAR(NSTD_DATA_TYPE), '<НЕ ОПРЕДЕЛЁН>'));
    end case;
    /* Возвращаем результат */
    return SRES;
  end STD_DATA_TYPE_TO_STR;

  /* Считывание значения ветки XML (строка) */
  function NODE_SVAL_GET
  (
    XROOT                   in PKG_XPATH.TNODE, -- Корневая ветка для считывания значения
    SPATH                   in varchar2,        -- Путь для считывания данных
    NREQUIRED               in number := 0,     -- Флаг выдачи сообщения об ошибке в случае отсутствия значения (0 - не выдавать, 1 - выдавать)
    SMESSAGE_OBJECT         in varchar2 := null -- Наимемнование объекта для формулирования сообщения об ошибке
  ) return                  varchar2            -- Считанное значение
  is
    XNODE                   PKG_XPATH.TNODE;    -- Искомая ветка со значением (подходящая под шаблон)
    SVAL                    PKG_STD.TSTRING;    -- Результат работы
  begin
    /* Найдем нужную ветку по шаблону */
    XNODE := PKG_XPATH.SINGLE_NODE(RPARENT_NODE => XROOT, SPATTERN => SPATH);
    /* Если там нет ничего */
    if (PKG_XPATH.IS_NULL(RNODE => XNODE)) then
      /* Его и вернём */
      SVAL := null;
    else
      /* Что-то есть - читаем данные */
      begin
        SVAL := PKG_XPATH.VALUE(RNODE => XNODE);
      exception
        when others then
          P_EXCEPTION(0, 'Неверный формат строки (%s).', SPATH);
      end;
    end if;
    /* Если значения нет, а оно должно быть - скажем об этом */
    if ((SVAL is null) and (NREQUIRED = 1)) then
      P_EXCEPTION(0, MSG_NO_DATA_MAKE(SPATH => SPATH, SMESSAGE_OBJECT => SMESSAGE_OBJECT));
    end if;
    /* Отдаём результат */
    return SVAL;
  end NODE_SVAL_GET;

  /* Считывание значения ветки XML (число) */
  function NODE_NVAL_GET
  (
    XROOT                   in PKG_XPATH.TNODE, -- Корневая ветка для считывания значения
    SPATH                   in varchar2,        -- Путь для считывания данных
    NREQUIRED               in number := 0,     -- Флаг выдачи сообщения об ошибке в случае отсутствия значения (0 - не выдавать, 1 - выдавать)
    SMESSAGE_OBJECT         in varchar2 := null -- Наимемнование объекта для формулирования сообщения об ошибке
  ) return                  number              -- Считанное значение
  is
    XNODE                   PKG_XPATH.TNODE;    -- Искомая ветка со значением (подходящая под шаблон)
    NVAL                    PKG_STD.TLNUMBER;   -- Результат работы
  begin
    /* Найдем нужную ветку по шаблону */
    XNODE := PKG_XPATH.SINGLE_NODE(RPARENT_NODE => XROOT, SPATTERN => SPATH);
    /* Если там нет ничего */
    if (PKG_XPATH.IS_NULL(RNODE => XNODE)) then
      /* Его и вернём */
      NVAL := null;
    else
      /* Что-то есть - читаем данные */
      begin
        NVAL := PKG_XPATH.VALUE_NUM(RNODE => XNODE);
      exception
        when others then
          P_EXCEPTION(0, 'Неверный формат числа (%s).', SPATH);
      end;
    end if;
    /* Если значения нет, а оно должно быть - скажем об этом */
    if ((NVAL is null) and (NREQUIRED = 1)) then
      P_EXCEPTION(0, MSG_NO_DATA_MAKE(SPATH => SPATH, SMESSAGE_OBJECT => SMESSAGE_OBJECT));
    end if;
    /* Отдаём результат */
    return NVAL;
  end NODE_NVAL_GET;

  /* Считывание значения ветки XML (дата) */
  function NODE_DVAL_GET
  (
    XROOT                   in PKG_XPATH.TNODE, -- Корневая ветка для считывания значения
    SPATH                   in varchar2,        -- Путь для считывания данных
    NREQUIRED               in number := 0,     -- Флаг выдачи сообщения об ошибке в случае отсутствия значения (0 - не выдавать, 1 - выдавать)
    SMESSAGE_OBJECT         in varchar2 := null -- Наимемнование объекта для формулирования сообщения об ошибке
  ) return                  date                -- Считанное значение
  is
    XNODE                   PKG_XPATH.TNODE;    -- Искомая ветка со значением (подходящая под шаблон)
    DVAL                    PKG_STD.TLDATE;     -- Результат работы
  begin
    /* Найдем нужную ветку по шаблону */
    XNODE := PKG_XPATH.SINGLE_NODE(RPARENT_NODE => XROOT, SPATTERN => SPATH);
    /* Если там нет ничего */
    if (PKG_XPATH.IS_NULL(RNODE => XNODE)) then
      /* Его и вернём */
      DVAL := null;
    else
      /* Что-то есть - читаем данные */
      begin
        DVAL := PKG_XPATH.VALUE_DATE(RNODE => XNODE);
      exception
        when others then
          begin
            DVAL := PKG_XPATH.VALUE_TS(RNODE => XNODE);
          exception
            when others then
              begin
                DVAL := PKG_XPATH.VALUE_TZ(RNODE => XNODE);
              exception
                when others then
                  P_EXCEPTION(0,
                              'Неверный формат даты (%s). Ожидалось: YYYY-MM-DD"T"HH24:MI:SS.FF3tzh:tzm, YYYY-MM-DD"T"HH24:MI:SS.FF3, YYYY-MM-DD"T"HH24:MI:SS, YYYY-MM-DD.',
                              SPATH);
              end;
          end;
      end;
    end if;
    /* Если значения нет, а оно должно быть - скажем об этом */
    if ((DVAL is null) and (NREQUIRED = 1)) then
      P_EXCEPTION(0, MSG_NO_DATA_MAKE(SPATH => SPATH, SMESSAGE_OBJECT => SMESSAGE_OBJECT));
    end if;
    /* Отдаём результат */
    return DVAL;
  end NODE_DVAL_GET;
  
  /* Считывание значения ветки XML (текст) */
  function NODE_CVAL_GET
  (
    XROOT                   in PKG_XPATH.TNODE, -- Корневая ветка для считывания значения
    SPATH                   in varchar2,        -- Путь для считывания данных
    NREQUIRED               in number := 0,     -- Флаг выдачи сообщения об ошибке в случае отсутствия значения (0 - не выдавать, 1 - выдавать)
    SMESSAGE_OBJECT         in varchar2 := null -- Наимемнование объекта для формулирования сообщения об ошибке
  ) return                  clob                -- Считанное значение
  is
    XNODE                   PKG_XPATH.TNODE;    -- Искомая ветка со значением (подходящая под шаблон)
    CVAL                    clob;               -- Результат работы
  begin
    /* Найдем нужную ветку по шаблону */
    XNODE := PKG_XPATH.SINGLE_NODE(RPARENT_NODE => XROOT, SPATTERN => SPATH);
    /* Если там нет ничего */
    if (PKG_XPATH.IS_NULL(RNODE => XNODE)) then
      /* Его и вернём */
      CVAL := null;
    else
      /* Что-то есть - читаем данные */
      begin
        CVAL := PKG_XPATH.VALUE_CLOB(RNODE => XNODE);
      exception
        when others then
          P_EXCEPTION(0, 'Неверный формат текстовых данных (%s).', SPATH);
      end;
    end if;
    /* Если значения нет, а оно должно быть - скажем об этом */
    if ((CVAL is null) and (NREQUIRED = 1)) then
      P_EXCEPTION(0, MSG_NO_DATA_MAKE(SPATH => SPATH, SMESSAGE_OBJECT => SMESSAGE_OBJECT));
    end if;
    /* Отдаём результат */
    return CVAL;
  end NODE_CVAL_GET;
  
  /* Считывание аргумента из коллекции */
  function TARGUMENTS_GET
  (
    ARGUMENTS               in TARGUMENTS, -- Коллекция аргументов
    SARGUMENT               in varchar2,   -- Код аргумента
    NREQUIRED               in number := 0 -- Флаг выдачи сообщения об ошибке в случае отсутствия значения (0 - не выдавать, 1 - выдавать)
  ) return                  TARGUMENT      -- Найденный аргумент
  is
  begin
    /* Если данные в коллекции есть */
    if ((ARGUMENTS is not null) and (ARGUMENTS.COUNT > 0)) then
      /* Обходим её */
      for I in ARGUMENTS.FIRST .. ARGUMENTS.LAST
      loop
        /* Если встретился нужный аргумент */
        if (ARGUMENTS(I).SNAME = SARGUMENT) then
          /* Вернём его */
          return ARGUMENTS(I);
        end if;
      end loop;
    end if;
    /* Если мы здесь - аргумент не нашелся, будем выдавать сообщение об ошибке если он был обязательным */
    if (NREQUIRED = 1) then
      P_EXCEPTION(0, 'Не задан обязательный аргумент "%s".', SARGUMENT);
    else
      /* Он не обязательный - вернём отсутствие данных */
      return null;
    end if;
  end TARGUMENTS_GET;

  /* Считывание значения аргумента из коллекции (строка) */
  function TARGUMENTS_SVAL_GET
  (
    ARGUMENTS               in TARGUMENTS, -- Коллекция аргументов
    SARGUMENT               in varchar2,   -- Код аргумента
    NREQUIRED               in number := 0 -- Флаг выдачи сообщения об ошибке в случае отсутствия значения (0 - не выдавать, 1 - выдавать)
  ) return                  varchar2       -- Значение аргумента
  is
  begin
    /* Считаем и вернём значение */
    return TARGUMENTS_GET(ARGUMENTS => ARGUMENTS, SARGUMENT => SARGUMENT, NREQUIRED => NREQUIRED).SVALUE;
  end TARGUMENTS_SVAL_GET;

  /* Считывание значения параметра из запроса (число) */
  function TARGUMENTS_NVAL_GET
  (
    ARGUMENTS               in TARGUMENTS, -- Коллекция аргументов
    SARGUMENT               in varchar2,   -- Код аргумента
    NREQUIRED               in number := 0 -- Флаг выдачи сообщения об ошибке в случае отсутствия значения (0 - не выдавать, 1 - выдавать)
  ) return                  number         -- Значение аргумента
  is
  begin
    /* Считаем и вернём значение */
    return TARGUMENTS_GET(ARGUMENTS => ARGUMENTS, SARGUMENT => SARGUMENT, NREQUIRED => NREQUIRED).NVALUE;
  end TARGUMENTS_NVAL_GET;

  /* Считывание значения параметра из запроса (дата) */
  function TARGUMENTS_DVAL_GET
  (
    ARGUMENTS               in TARGUMENTS, -- Коллекция аргументов
    SARGUMENT               in varchar2,   -- Код аргумента
    NREQUIRED               in number := 0 -- Флаг выдачи сообщения об ошибке в случае отсутствия значения (0 - не выдавать, 1 - выдавать)
  ) return                  date           -- Значение аргумента
  is
  begin
    /* Считаем и вернём значение */
    return TARGUMENTS_GET(ARGUMENTS => ARGUMENTS, SARGUMENT => SARGUMENT, NREQUIRED => NREQUIRED).DVALUE;
  end TARGUMENTS_DVAL_GET;

  /* Считывание значения параметра из запроса (текст) */
  function TARGUMENTS_CVAL_GET
  (
    ARGUMENTS               in TARGUMENTS, -- Коллекция аргументов
    SARGUMENT               in varchar2,   -- Код аргумента
    NREQUIRED               in number := 0 -- Флаг выдачи сообщения об ошибке в случае отсутствия значения (0 - не выдавать, 1 - выдавать)
  ) return                  clob           -- Значение аргумента
  is
  begin
    /* Считаем и вернём значение */
    return TARGUMENTS_GET(ARGUMENTS => ARGUMENTS, SARGUMENT => SARGUMENT, NREQUIRED => NREQUIRED).CVALUE;
  end TARGUMENTS_CVAL_GET;

  /* Получение корневого элемента тела запроса */
  function RQ_ROOT_GET
  (
    CRQ                     in clob         -- Запрос
  ) return                  PKG_XPATH.TNODE -- Корневой элемент первой ветки тела документа
  is
  begin
    /* Возвращаем корневой элемент документа */
    return PKG_XPATH.ROOT_NODE(RDOCUMENT => PKG_XPATH.PARSE_FROM_CLOB(LCXML => CRQ));
  end RQ_ROOT_GET;

  /* Получение пути к запросу */
  function RQ_PATH_GET
  return                    varchar2    -- Путь к запросу
  is
  begin
    return '/' || SRQ_TAG_XREQUEST;
  end RQ_PATH_GET;

  /* Получение пути к элементу действия запроса */
  function RQ_ACTION_PATH_GET
  return                    varchar2    -- Путь к элементу действия запроса
  is
  begin
    return RQ_PATH_GET() || '/' || SRQ_TAG_SACTION;
  end RQ_ACTION_PATH_GET;
  
  /* Получение кода действия запроса */
  function RQ_ACTION_GET
  (
    XRQ_ROOT                in PKG_XPATH.TNODE := null, -- Корневая ветка запроса
    NREQUIRED               in number := 0              -- Флаг выдачи сообщения об ошибке в случае отсутствия значения (0 - не выдавать, 1 - выдавать)
  ) return                  varchar2                    -- Код действия запроса
  is
  begin
    /* Вернем значение элемента тела с кодом действия */
    return NODE_SVAL_GET(XROOT           => XRQ_ROOT,
                         SPATH           => RQ_ACTION_PATH_GET(),
                         NREQUIRED       => NREQUIRED,
                         SMESSAGE_OBJECT => 'Код действия');
  end RQ_ACTION_GET;

  /* Получение пути к параметрам запроса */
  function RQ_PAYLOAD_PATH_GET
  return                    varchar2    -- Путь к параметрам запроса
  is
  begin
    /* Вернем значение */
    return RQ_PATH_GET() || '/' || SRQ_TAG_XPAYLOAD;
  end RQ_PAYLOAD_PATH_GET;

  /* Получение пути к элкменту параметров запроса */
  function RQ_PAYLOAD_ITEM_PATH_GET
  (
    SITEM_TAG               in varchar2 -- Тэг элемента
  )
  return                    varchar2    -- Путь к элементу параметров запроса
  is
  begin
    /* Вернем значение */
    return RQ_PAYLOAD_PATH_GET() || '/' || SITEM_TAG;
  end RQ_PAYLOAD_ITEM_PATH_GET;

  /* Считывание наименования исполняемого хранимого объекта из запроса */
  function RQ_PAYLOAD_STORED_GET
  (
    XRQ_ROOT                in PKG_XPATH.TNODE := null, -- Корневая ветка запроса
    NREQUIRED               in number := 0              -- Флаг выдачи сообщения об ошибке в случае отсутствия значения (0 - не выдавать, 1 - выдавать)
  ) return                  varchar2                    -- Наименование исполняемого хранимого объекта из запроса
  is
  begin
    /* Вернем значение элемента тела с наименованием хранимого объекта */
    return NODE_SVAL_GET(XROOT           => XRQ_ROOT,
                         SPATH           => RQ_PAYLOAD_ITEM_PATH_GET(SITEM_TAG => SRQ_TAG_SSTORED),
                         NREQUIRED       => NREQUIRED,
                         SMESSAGE_OBJECT => 'Наименование процедуры/функции');
  end RQ_PAYLOAD_STORED_GET;
  
  /* Проверка исполняемого хранимого объекта из запроса */
  procedure RQ_PAYLOAD_STORED_CHECK
  (
    XRQ_ROOT                in PKG_XPATH.TNODE,       -- Корневая ветка запроса
    SSTORED                 in varchar2 := null       -- Наименование проверяемого хранимого объекта (null - автоматическое считывание из запроса)
  )
  is
    SSTORED_                PKG_STD.TSTRING;          -- Буфер для наименования проверяемого хранимого объекта
    RSTORED                 PKG_OBJECT_DESC.TSTORED;  -- Описание хранимого объекта из БД
    SPROCEDURE              PKG_STD.TSTRING;          -- Буфер для наименования хранимой процедуры
    SPACKAGE                PKG_STD.TSTRING;          -- Буфер для наименования пакета, содержащего хранимый объект
    RPACKAGE                PKG_OBJECT_DESC.TPACKAGE; -- Описание пакета, содержащего хранимый объект
  begin
    /* Считаем наименование объекта из запроса или используем переданное в параметрах */
    if (SSTORED is not null) then
      SSTORED_ := SSTORED;
    else
      SSTORED_ := RQ_PAYLOAD_STORED_GET(XRQ_ROOT => XRQ_ROOT, NREQUIRED => 1);
    end if;
    /* Проверим, что это процедура или функция и она вообще существует */
    if (PKG_OBJECT_DESC.EXISTS_STORED(SSTORED_NAME => SSTORED_) = 0) then
      P_EXCEPTION(0,
                  'Хранимая процедура/функция "' || SSTORED_ || '" не определена.');
    else
      /* Проверим, что в имени нет ссылки на пакет */
      PKG_EXS.UTL_STORED_PARSE_LINK(SSTORED => SSTORED_, SPROCEDURE => SPROCEDURE, SPACKAGE => SPACKAGE);
      /* Если в имени есть ссылка на пакет - сначала проверим его состояние */
      if (SPACKAGE is not null) then
        RPACKAGE := PKG_OBJECT_DESC.DESC_PACKAGE(SPACKAGE_NAME => SPACKAGE, BRAISE_ERROR => false);
      end if;
      /* Если есть ссылка на пакет, или он не валиден - это ошибка */
      if ((SPACKAGE is not null) and (RPACKAGE.STATUS <> SDB_OBJECT_STATE_VALID)) then
        P_EXCEPTION(0,
                    'Пакет "' || SPACKAGE ||
                    '", содержащий хранимую процедуру/функцию, невалиден. Обращение к объекту невозможно.');
      else
        /* Нет ссылки на пакет или он валиден - проверяем глубже, получим описание объекта из БД */
        RSTORED := PKG_OBJECT_DESC.DESC_STORED(SSTORED_NAME => SSTORED_, BRAISE_ERROR => false);
        /* Проверим, что валидна */
        if (RSTORED.STATUS <> SDB_OBJECT_STATE_VALID) then
          P_EXCEPTION(0,
                      'Хранимая процедура/функция "' || SSTORED_ || '" невалидна. Обращение к объекту невозможно.');
        else
          /* Проверим, что это клиентский объект */
          if (PKG_OBJECT_DESC.EXISTS_PRIV_EXECUTE(SSTORED_NAME => COALESCE(RSTORED.PACKAGE_NAME, SSTORED_)) = 0) then
            P_EXCEPTION(0,
                        'Хранимая процедура/функция "' || SSTORED_ ||
                        '" не является клиентской. Обращение к объекту невозможно.');
          end if;
        end if;
      end if;
    end if;
  end RQ_PAYLOAD_STORED_CHECK;

  /* Считывание списка аргументов из запроса */
  function RQ_PAYLOAD_ARGUMENTS_GET
  (
    XRQ_ROOT                in PKG_XPATH.TNODE, -- Корневая ветка запроса
    NREQUIRED               in number := 0      -- Флаг выдачи сообщения об ошибке в случае отсутствия значения (0 - не выдавать, 1 - выдавать)
  ) return                  TARGUMENTS          -- Коллекция аргументов из запроса
  is
    RES                     TARGUMENTS;         -- Результат работы
    SRQ_ARGUMENTS_PATH      PKG_STD.TSTRING;    -- Полный путь до аргументов выборки в запросе
    XRQ_ARGUMENTS           PKG_XPATH.TNODES;   -- Коллекция элементов документа запроса с аргументами
    XRQ_ARGUMENT            PKG_XPATH.TNODE;    -- Элемент документа запроса с аргументов
  begin
    /* Инициализируем результат */
    RES := TARGUMENTS();
    /* Сформируем полный путь до аргументов в выборке */
    SRQ_ARGUMENTS_PATH := RQ_PAYLOAD_ITEM_PATH_GET(SITEM_TAG => SRQ_TAG_XARGUMENTS) || '/' || SRQ_TAG_XARGUMENT;
    /* Считаем коллекцию аргументов из документа */
    XRQ_ARGUMENTS := PKG_XPATH.LIST_NODES(RPARENT_NODE => XRQ_ROOT, SPATTERN => SRQ_ARGUMENTS_PATH);
    /* Обходим коллекцию аргументов из документа */
    for I in 1 .. PKG_XPATH.COUNT_NODES(RNODES => XRQ_ARGUMENTS)
    loop
      /* Берем очередной аргумент */
      XRQ_ARGUMENT := PKG_XPATH.ITEM_NODE(RNODES => XRQ_ARGUMENTS, INUMBER => I);
      /* Добавляем его в выходную коллекцию */
      RES.EXTEND();
      RES(RES.LAST).SNAME := NODE_SVAL_GET(XROOT => XRQ_ARGUMENT, SPATH => SRQ_TAG_SNAME);
      RES(RES.LAST).SDATA_TYPE := NODE_SVAL_GET(XROOT => XRQ_ARGUMENT, SPATH => SRQ_TAG_SDATA_TYPE);
      /* Проверим корректность данных - наименование */
      if (RES(RES.LAST).SNAME is null) then
        P_EXCEPTION(0,
                    'Для аргумента не задано наименование (%s).',
                    SRQ_ARGUMENTS_PATH || '/' || SRQ_TAG_SNAME);
      end if;
      /* Проверим корректность данных - тип данных */
      if (RES(RES.LAST).SDATA_TYPE is null) then
        P_EXCEPTION(0,
                    'Для аргумента "%s" не задан тип данных (%s).',
                    RES(RES.LAST).SNAME,
                    SRQ_ARGUMENTS_PATH || '/' || SRQ_TAG_SDATA_TYPE);
      end if;
      /* Считаем значение в зависимости от типа данных */
      case
        /* Строка */
        when (RES(RES.LAST).SDATA_TYPE = SDATA_TYPE_STR) then
          RES(RES.LAST).SVALUE := NODE_SVAL_GET(XROOT => XRQ_ARGUMENT, SPATH => SRQ_TAG_VALUE);
        /* Число */
        when (RES(RES.LAST).SDATA_TYPE = SDATA_TYPE_NUMB) then
          RES(RES.LAST).NVALUE := NODE_NVAL_GET(XROOT => XRQ_ARGUMENT, SPATH => SRQ_TAG_VALUE);
        /* Дата */
        when (RES(RES.LAST).SDATA_TYPE = SDATA_TYPE_DATE) then
          RES(RES.LAST).DVALUE := NODE_DVAL_GET(XROOT => XRQ_ARGUMENT, SPATH => SRQ_TAG_VALUE);
        /* Текст */
        when (RES(RES.LAST).SDATA_TYPE = SDATA_TYPE_CLOB) then
          RES(RES.LAST).CVALUE := NODE_CVAL_GET(XROOT => XRQ_ARGUMENT, SPATH => SRQ_TAG_VALUE);
        /* Неподдерживаемый тип данных */
        else
          P_EXCEPTION(0,
                      'Указанный для аргумента "%s" тип данных "%s" не поддерживается (%s).',
                      RES(RES.LAST).SNAME,
                      RES(RES.LAST).SDATA_TYPE,
                      SRQ_ARGUMENTS_PATH || '/' || SRQ_TAG_SDATA_TYPE);
      end case;
    end loop;
    /* Проверка обязательности */
    if ((RES.COUNT = 0) and (NREQUIRED = 1)) then
      P_EXCEPTION(0, 'Не указаны аргументы (' || SRQ_ARGUMENTS_PATH || ').');
    end if;
    /* Возвращаем результат */
    return RES;
  end RQ_PAYLOAD_ARGUMENTS_GET;

  /* Исполнение хранимой процедуры */
  procedure EXEC_STORED
  (
    XRQ_ROOT                in PKG_XPATH.TNODE,         -- Корневой элемент тела документа запроса
    COUT                    out clob                    -- Ответ на запрос
  )
  is
    SRQ_STORED              PKG_STD.TSTRING;            -- Наименование исполняемого хранимого объекта из запроса
    SRQ_RESP_ARG            PKG_STD.TSTRING;            -- Наименование выходного аргумента хранимого объекта из запроса для формирования тела ответа
    RQ_ARGUMENTS            TARGUMENTS;                 -- Коллекция аргументов хранимого объекта из запроса
    ARGS                    PKG_OBJECT_DESC.TARGUMENTS; -- Коллекция формальных параметров хранимого объекта
    RARG                    PKG_OBJECT_DESC.TARGUMENT;  -- Формальный параметр хранимого объекта
    ARGS_VALS               PKG_CONTPRMLOC.TCONTAINER;  -- Контейнер для фактических параметров хранимого объекта
    RARG_VAL                PKG_CONTAINER.TPARAM;       -- Фактический параметр хранимого объекта
    SARG_NAME               PKG_STD.TSTRING;            -- Наименование текущего обрабатываемого фактического параметра хранимого объекта
    XRESP                   integer;                    -- Документ для ответа
    XRESP_OUT_ARGUMENTS     PKG_XMAKE.TNODE;            -- Элемент для коллекции выходных параметров хранимого объекта
    RRESP_ARGUMENT_VALUE    PKG_XMAKE.TVALUE;           -- Значение выходного параметра хранимого объекта
    BRESP_ARG_FOUND         boolean := false;           -- Флаг присутствия в составе выходных аргументов аргумента с типом CLOB и именем, указанным в параметре запроса SRESP_ARG
  begin
    /* Создаём документ для ответа */
    XRESP := PKG_XMAKE.OPEN_CURSOR();
    /* Проверим хранимый объект в запросе */
    RQ_PAYLOAD_STORED_CHECK(XRQ_ROOT => XRQ_ROOT);
    /* Считываем наименование хранимого объекта из запроса */
    SRQ_STORED := RQ_PAYLOAD_STORED_GET(XRQ_ROOT => XRQ_ROOT, NREQUIRED => 1);
    /* Считываем наименование выходного аргумента хранимого объекта из запроса для формирования тела ответа */
    SRQ_RESP_ARG := NODE_SVAL_GET(XROOT           => XRQ_ROOT,
                                  SPATH           => RQ_PAYLOAD_ITEM_PATH_GET(SITEM_TAG => SRQ_TAG_SRESP_ARG),
                                  NREQUIRED       => 0,
                                  SMESSAGE_OBJECT => 'Наименование выходного аргумента для формирования тела ответа');
    /* Считаем список аргументов из запроса */
    RQ_ARGUMENTS := RQ_PAYLOAD_ARGUMENTS_GET(XRQ_ROOT => XRQ_ROOT);
    /* Считываем описание параметров хранимого объекта */
    ARGS := PKG_OBJECT_DESC.DESC_ARGUMENTS(SSTORED_NAME => SRQ_STORED, BRAISE_ERROR => true);
    /* Обходим входные параметры и формируем коллекцию значений */
    for I in 1 .. PKG_OBJECT_DESC.COUNT_ARGUMENTS(RARGUMENTS => ARGS)
    loop
      /* Считываем очередной параметр */
      RARG := PKG_OBJECT_DESC.FETCH_ARGUMENT(RARGUMENTS => ARGS, IINDEX => I);
      /* Если это входной параметр */
      if (RARG.IN_OUT in (PKG_STD.PARAM_TYPE_IN, PKG_STD.PARAM_TYPE_IN_OUT)) then
        /* Добавим его значение в коллекцию фактических параметров */
        case RARG.DATA_TYPE
          /* Строка */
          when PKG_STD.DATA_TYPE_STR then
            PKG_CONTPRMLOC.APPENDS(RCONTAINER => ARGS_VALS,
                                   SNAME      => RARG.ARGUMENT_NAME,
                                   SVALUE     => TARGUMENTS_SVAL_GET(ARGUMENTS => RQ_ARGUMENTS,
                                                                     SARGUMENT => RARG.ARGUMENT_NAME),
                                   NIN_OUT    => RARG.IN_OUT);
          /* Число */
          when PKG_STD.DATA_TYPE_NUM then
            PKG_CONTPRMLOC.APPENDN(RCONTAINER => ARGS_VALS,
                                   SNAME      => RARG.ARGUMENT_NAME,
                                   NVALUE     => TARGUMENTS_NVAL_GET(ARGUMENTS => RQ_ARGUMENTS,
                                                                     SARGUMENT => RARG.ARGUMENT_NAME),
                                   NIN_OUT    => RARG.IN_OUT);
          /* Дата */
          when PKG_STD.DATA_TYPE_DATE then
            PKG_CONTPRMLOC.APPENDD(RCONTAINER => ARGS_VALS,
                                   SNAME      => RARG.ARGUMENT_NAME,
                                   DVALUE     => TARGUMENTS_DVAL_GET(ARGUMENTS => RQ_ARGUMENTS,
                                                                     SARGUMENT => RARG.ARGUMENT_NAME),
                                   NIN_OUT    => RARG.IN_OUT);
          /* Текст */
          when PKG_STD.DATA_TYPE_CLOB then
            PKG_CONTPRMLOC.APPENDLC(RCONTAINER => ARGS_VALS,
                                    SNAME      => RARG.ARGUMENT_NAME,
                                    LCVALUE    => TARGUMENTS_CVAL_GET(ARGUMENTS => RQ_ARGUMENTS,
                                                                      SARGUMENT => RARG.ARGUMENT_NAME),
                                    NIN_OUT    => RARG.IN_OUT);
          /* Неизвестный тип данных */
          else
            P_EXCEPTION(0,
                        'Тип данных (%s) входного параметра "%s" не поддерживается.',
                        RARG.DB_DATA_TYPE,
                        RARG.ARGUMENT_NAME);
        end case;
      end if;
    end loop;
    /* Исполняем процедуру */
    PKG_SQL_CALL.EXECUTE_STORED(SSTORED_NAME => SRQ_STORED, RPARAM_CONTAINER => ARGS_VALS);
    /* Обходим выходные параметры и собираем их в ответ */
    SARG_NAME := PKG_CONTPRMLOC.FIRST_(RCONTAINER => ARGS_VALS);
    while (SARG_NAME is not null)
    loop
      /* Считываем значение параметра */
      RARG_VAL := PKG_CONTPRMLOC.GET(RCONTAINER => ARGS_VALS, SNAME => SARG_NAME);
      /* Считываем описание параметра */
      RARG := PKG_OBJECT_DESC.FETCH_ARGUMENT(RARGUMENTS => ARGS, SARGUMENT_NAME => SARG_NAME);
      /* Если это выходной параметр */
      if (RARG.IN_OUT in (PKG_STD.PARAM_TYPE_IN_OUT, PKG_STD.PARAM_TYPE_OUT)) then
        /* Сформируем для него значение в зависимости от его типа */
        case RARG.DATA_TYPE
          /* Строка */
          when PKG_STD.DATA_TYPE_STR then
            RRESP_ARGUMENT_VALUE := PKG_XMAKE.VALUE(ICURSOR => XRESP,
                                                    SVALUE  => PKG_CONTPRMLOC.GETS(RCONTAINER => ARGS_VALS,
                                                                                   SNAME      => RARG_VAL.NAME));
          /* Число */
          when PKG_STD.DATA_TYPE_NUM then
            RRESP_ARGUMENT_VALUE := PKG_XMAKE.VALUE(ICURSOR => XRESP,
                                                    NVALUE  => PKG_CONTPRMLOC.GETN(RCONTAINER => ARGS_VALS,
                                                                                   SNAME      => RARG_VAL.NAME));
          /* Дата */
          when PKG_STD.DATA_TYPE_DATE then
            RRESP_ARGUMENT_VALUE := PKG_XMAKE.VALUE(ICURSOR => XRESP,
                                                    DVALUE  => PKG_CONTPRMLOC.GETD(RCONTAINER => ARGS_VALS,
                                                                                   SNAME      => RARG_VAL.NAME));
          /* Текст */
          when PKG_STD.DATA_TYPE_CLOB then
            RRESP_ARGUMENT_VALUE := PKG_XMAKE.VALUE(ICURSOR => XRESP,
                                                    LCVALUE => PKG_CONTPRMLOC.GETLC(RCONTAINER => ARGS_VALS,
                                                                                    SNAME      => RARG_VAL.NAME));
            if ((SRQ_RESP_ARG is not null) and (RARG_VAL.NAME = SRQ_RESP_ARG)) then
              COUT            := PKG_CONTPRMLOC.GETLC(RCONTAINER => ARGS_VALS, SNAME => RARG_VAL.NAME);
              BRESP_ARG_FOUND := true;
              exit;
            end if;
          /* Неизвестный тип данных */
          else
            P_EXCEPTION(0,
                        'Тип данных (%s) выходного параметра "%s" не поддерживается.',
                        RARG.DB_DATA_TYPE,
                        RARG.ARGUMENT_NAME);
        end case;
        /* Добавим ветку выходного параметра в выходную коллекцию */
        XRESP_OUT_ARGUMENTS := PKG_XMAKE.CONCAT(ICURSOR => XRESP,
                                                RNODE00 => XRESP_OUT_ARGUMENTS,
                                                RNODE01 => PKG_XMAKE.ELEMENT(ICURSOR => XRESP,
                                                                             SNAME   => SRESP_TAG_XOUT_ARGUMENTS,
                                                                             RNODE00 => PKG_XMAKE.ELEMENT(ICURSOR  => XRESP,
                                                                                                          SNAME    => SRESP_TAG_SNAME,
                                                                                                          RVALUE00 => PKG_XMAKE.VALUE(ICURSOR => XRESP,
                                                                                                                                      SVALUE  => RARG_VAL.NAME)),
                                                                             RNODE01 => PKG_XMAKE.ELEMENT(ICURSOR  => XRESP,
                                                                                                          SNAME    => SRESP_TAG_VALUE,
                                                                                                          RVALUE00 => RRESP_ARGUMENT_VALUE),
                                                                             RNODE02 => PKG_XMAKE.ELEMENT(ICURSOR  => XRESP,
                                                                                                          SNAME    => SRESP_TAG_SDATA_TYPE,
                                                                                                          RVALUE00 => PKG_XMAKE.VALUE(ICURSOR => XRESP,
                                                                                                                                      SVALUE  => STD_DATA_TYPE_TO_STR(NSTD_DATA_TYPE => RARG.DATA_TYPE)))));
      end if;
      /* Считываем наименование следующего параметра */
      SARG_NAME := PKG_CONTPRMLOC.NEXT_(RCONTAINER => ARGS_VALS, SNAME => SARG_NAME);
    end loop;
    /* Проверим, что был найден опциональный аргумент для формирования полного ответа */
    if ((SRQ_RESP_ARG is not null) and (not BRESP_ARG_FOUND)) then
      P_EXCEPTION(0,
                  'В составе выходных параметров "%s" отсуствует аргумент "%s" типа "CLOB".',
                  SRQ_STORED,
                  SRQ_RESP_ARG);
    end if;
    /* Собираем ответ (только если не формировали полный ответ через аргумент для формирования полного ответа) */
    if (not BRESP_ARG_FOUND) then
      COUT := PKG_XMAKE.SERIALIZE_TO_CLOB(ICURSOR => XRESP,
                                          ITYPE   => PKG_XMAKE.CONTENT_,
                                          RNODE   => PKG_XMAKE.ELEMENT(ICURSOR => XRESP,
                                                                       SNAME   => SRESP_TAG_XPAYLOAD,
                                                                       RNODE00 => XRESP_OUT_ARGUMENTS));
    end if;
    /* Очистим контейнер параметров */
    PKG_CONTPRMLOC.PURGE(RCONTAINER => ARGS_VALS);
    /* Освобождаем документ результата */
    PKG_XMAKE.CLOSE_CURSOR(ICURSOR => XRESP);
  exception
    when others then
      /* Закроем курсор и вернем ошибку */
      PKG_XMAKE.CLOSE_CURSOR(ICURSOR => XRESP);
      /* Покажем ошибку */
      PKG_STATE.DIAGNOSTICS_STACKED();
      P_EXCEPTION(0, PKG_STATE.SQL_ERRM());
  end EXEC_STORED;
  
  /* Базовое исполнение действий */
  procedure PROCESS
  (
    CIN                     in clob,         -- Входные параметры
    COUT                    out clob         -- Результат
  )
  is
    XRQ_ROOT                PKG_XPATH.TNODE; -- Корневой элемент тела документа запроса
    SRQ_ACTION              PKG_STD.TSTRING; -- Код действия из запроса
  begin
    /* Разбираем запрос */
    XRQ_ROOT := RQ_ROOT_GET(CRQ => CIN);
    /* Считываем код действия из запроса */
    SRQ_ACTION := RQ_ACTION_GET(XRQ_ROOT => XRQ_ROOT, NREQUIRED => 1);
    /* Вызываем обработчик в зависимости от кода действия */
    case SRQ_ACTION
    /* Исполнение хранимой процедуры */
      when SRQ_ACTION_EXEC_STORED then
        EXEC_STORED(XRQ_ROOT => XRQ_ROOT, COUT => COUT);
        /* Неизвестное действие */
      else
        P_EXCEPTION(0, 'Действие "%s" не поддерживается.', SRQ_ACTION);
    end case;
  end PROCESS;

end PKG_P8PANELS_BASE;
/

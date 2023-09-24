create or replace procedure UDO_P_P8PANELS_AGNLIST
(
  NPAGE_NUMBER              in number,                             -- Номер страницы (игнорируется при NPAGE_SIZE=0)
  NPAGE_SIZE                in number,                             -- Количество записей на странице (0 - все)
  CFILTERS                  in clob,                               -- Фильтры
  CORDERS                   in clob,                               -- Сортировки
  NINCLUDE_DEF              in number,                             -- Признак включения описания колонок таблицы в ответ
  COUT                      out clob                               -- Сериализованная таблица данных
)
is
  NCOMPANY                  PKG_STD.TREF := GET_SESSION_COMPANY(); -- Организация сеанса
  NIDENT                    PKG_STD.TREF := GEN_IDENT();           -- Идентификатор отбора
  RF                        PKG_P8PANELS_VISUAL.TFILTERS;          -- Фильтры
  RO                        PKG_P8PANELS_VISUAL.TORDERS;           -- Сортировки
  RDG                       PKG_P8PANELS_VISUAL.TDATA_GRID;        -- Описание таблицы
  RDG_ROW                   PKG_P8PANELS_VISUAL.TROW;              -- Строка таблицы
  RCOL_VALS                 PKG_P8PANELS_VISUAL.TCOL_VALS;         -- Предопределённые значения столбцов
  NROW_FROM                 PKG_STD.TREF;                          -- Номер строки с
  NROW_TO                   PKG_STD.TREF;                          -- Номер строки по
  CSQL                      clob;                                  -- Буфер для запроса
  ICURSOR                   integer;                               -- Курсор для исполнения запроса
  RAGENT                    AGNLIST%rowtype;                       -- Буфер для записи курсора
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
                                             SNAME      => 'RN',
                                             SCAPTION   => 'Рег. номер',
                                             SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                             BVISIBLE   => false);
  PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                             SNAME      => 'AGNABBR',
                                             SCAPTION   => 'Мнемокод',
                                             SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                             SCOND_FROM => 'AgentAbbr',
                                             BORDER     => true,
                                             BFILTER    => true);
  PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                             SNAME      => 'AGNNAME',
                                             SCAPTION   => 'Наименование',
                                             SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                             SCOND_FROM => 'AgentName',
                                             BORDER     => true,
                                             BFILTER    => true);
  PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 0, BCLEAR => true);
  PKG_P8PANELS_VISUAL.TCOL_VALS_ADD(RCOL_VALS => RCOL_VALS, NVALUE => 1);
  PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                             SNAME      => 'AGNTYPE',
                                             SCAPTION   => 'Тип',
                                             SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                             SCOND_FROM => 'AgentType',
                                             BORDER     => true,
                                             BFILTER    => true,
                                             RCOL_VALS  => RCOL_VALS);
  PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                             SNAME      => 'AGNBURN',
                                             SCAPTION   => 'Дата рождения',
                                             SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                             SCOND_FROM => 'AgentBornFrom',
                                             SCOND_TO   => 'AgentBornTo',
                                             BORDER     => true,
                                             BFILTER    => true);
  /* Обходим данные */
  begin
    /* Собираем запрос */
    CSQL := 'select *
          from (select D.*,
                       ROWNUM NROW
                  from (select AG.RN,
                               AG.AGNABBR,
                               AG.AGNNAME,
                               AG.AGNTYPE,
                               AG.AGNBURN
                          from AGNLIST AG
                         where AG.RN in (select ID from COND_BROKER_IDSMART where IDENT = :NIDENT) %ORDER_BY%) D) F
         where F.NROW between :NROW_FROM and :NROW_TO';
    /* Учтём сортировки */
    PKG_P8PANELS_VISUAL.TORDERS_SET_QUERY(RDATA_GRID => RDG, RORDERS => RO, SPATTERN => '%ORDER_BY%', CSQL => CSQL);
    /* Учтём фильтры */
    PKG_P8PANELS_VISUAL.TFILTERS_SET_QUERY(NIDENT     => NIDENT,
                                           NCOMPANY   => NCOMPANY,
                                           SUNIT      => 'AGNLIST',
                                           SPROCEDURE => 'P_AGNLIST_BASE_COND',
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
    PKG_SQL_DML.DEFINE_COLUMN_DATE(ICURSOR => ICURSOR, IPOSITION => 5);
    /* Делаем выборку */
    if (PKG_SQL_DML.EXECUTE(ICURSOR => ICURSOR) = 0) then
      null;
    end if;
    /* Обходим выбранные записи */
    while (PKG_SQL_DML.FETCH_ROWS(ICURSOR => ICURSOR) > 0)
    loop
      /* Извлекаем очередную запись */
      PKG_SQL_DML.COLUMN_VALUE_NUM(ICURSOR => ICURSOR, IPOSITION => 1, NVALUE => RAGENT.RN);
      PKG_SQL_DML.COLUMN_VALUE_STR(ICURSOR => ICURSOR, IPOSITION => 2, SVALUE => RAGENT.AGNABBR);
      PKG_SQL_DML.COLUMN_VALUE_STR(ICURSOR => ICURSOR, IPOSITION => 3, SVALUE => RAGENT.AGNNAME);
      PKG_SQL_DML.COLUMN_VALUE_NUM(ICURSOR => ICURSOR, IPOSITION => 4, NVALUE => RAGENT.AGNTYPE);
      PKG_SQL_DML.COLUMN_VALUE_DATE(ICURSOR => ICURSOR, IPOSITION => 5, DVALUE => RAGENT.AGNBURN);
      /* Инициализируем строку таблицы данных */
      RDG_ROW := PKG_P8PANELS_VISUAL.TROW_MAKE();
      /* Добавляем колонки с данными */
      PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'RN', NVALUE => RAGENT.RN);
      PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'AGNABBR', SVALUE => RAGENT.AGNABBR);
      PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'AGNNAME', SVALUE => RAGENT.AGNNAME);
      PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'AGNTYPE', NVALUE => RAGENT.AGNTYPE);
      PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'AGNBURN', DVALUE => RAGENT.AGNBURN);
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
end;
/

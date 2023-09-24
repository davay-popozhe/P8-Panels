create or replace package PKG_P8PANELS as

  /* Исполнение действий клиентских приложений */
  procedure PROCESS
  (
    CIN                     in clob,    -- Входные параметры
    COUT                    out clob    -- Результат
  );

end PKG_P8PANELS;
/
create or replace package body PKG_P8PANELS as

  /* Исполнение действий клиентских приложений */
  procedure PROCESS
  (
    CIN                     in clob,    -- Входные параметры
    COUT                    out clob    -- Результат
  )
  is
  begin
    /* Базовое исполнение действия */
    PKG_P8PANELS_BASE.PROCESS(CIN => CIN, COUT => COUT);
  end PROCESS;

end PKG_P8PANELS;
/

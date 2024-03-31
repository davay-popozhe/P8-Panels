create or replace package PKG_P8PANELS as

  /* Исполнение действий клиентских приложений */
  procedure PROCESS
  (
    CIN                     in clob,    -- Входные параметры
    COUT                    out clob    -- Результат
  );
  
  /* Инициализация буфера отмеченных записей для панели */
  procedure SELECTLIST_INIT
  (
    NIDENT                  in number   -- Идентификатор буфера отмеченных записей  
  );
  
  /* Очистка буфера отмеченных записей для панели */
  procedure SELECTLIST_CLEAR
  (
    NIDENT                  in number   -- Идентификатор буфера отмеченных записей
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
  
  /* Инициализация буфера отмеченных записей для панели */
  procedure SELECTLIST_INIT
  (
    NIDENT                  in number   -- Идентификатор буфера отмеченных записей  
  )
  is
  begin
    /* Базовое исполнение действия */
    PKG_P8PANELS_BASE.SELECTLIST_INIT(NIDENT => NIDENT);
  end SELECTLIST_INIT;
  
  /* Очистка буфера отмеченных записей для панели */
  procedure SELECTLIST_CLEAR
  (
    NIDENT                  in number   -- Идентификатор буфера отмеченных записей
  )
  is
  begin
    /* Базовое исполнение действия */
    PKG_P8PANELS_BASE.SELECTLIST_CLEAR(NIDENT => NIDENT);
  end SELECTLIST_CLEAR;

end PKG_P8PANELS;
/

/* 
  Парус 8 - Панели мониторинга
  Список отмеченных записей
*/
create table P8PNL_SELECTLIST
(
  RN                        number(17) not null,       -- Рег. номер записи
  IDENT                     number(17) not null,       -- Идентификатор процесса
  AUTHID                    varchar2(30) not null,     -- Пользователь
  SESSION_ID                varchar2(24) not null,     -- Идентификатор сеанса
  CONNECT_EXT               varchar2(255) not null,    -- Внешний идентификатор сеанса
  COMPANY                   number(17) default null,   -- Организация
  DOCUMENT                  number(17) not null,       -- Документ
  UNITCODE                  varchar2(40) default null, -- Код раздела документа
  ACTIONCODE                varchar2(40) default null, -- Код действия документа
  CRN                       number(17) default null,   -- Каталог документа
  DOCUMENT1                 number(17) default null,   -- Документ 1
  UNITCODE1                 varchar2(40) default null, -- Код раздела документа 1
  ACTIONCODE1               varchar2(40) default null, -- Код действия документа 1
  constraint C_P8PNL_SELECTLIST_PK primary key(RN),
  constraint C_P8PNL_SELECTLIST_UK unique(IDENT, DOCUMENT, UNITCODE, DOCUMENT1, UNITCODE1)
);

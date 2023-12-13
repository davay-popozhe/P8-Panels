/* 
  Парус 8 - Панели мониторинга - Примеры
  Буфер для диаграммы Ганта
*/
create table P8PNL_SMPL_GANTT
(
  RN                        number(17) not null,    -- Рег. номер записи
  IDENT                     number(17) not null,    -- Идентификатор процесса
  TYPE                      number(1) not null,     -- Тип задачи (0 - этап/веха, 1 - работа)
  NUMB                      varchar2(20) not null,  -- Номер задачи
  NAME                      varchar2(200) not null, -- Наименование задачи
  DATE_FROM                 date not null,          -- Дата начала задачи
  DATE_TO                   date not null,          -- Дата окончания задачи
  constraint C_P8PNL_SMPL_GANTT_RN_PK primary key (RN),
  constraint C_P8PNL_SMPL_GANTT_VAL check (TYPE in (0, 1)),
  constraint C_P8PNL_SMPL_GANTT_UN unique (IDENT, NUMB)
);

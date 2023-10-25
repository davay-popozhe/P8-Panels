/* 
  Парус 8 - Панели мониторинга - ПУП - Балансировка планов-графиков проектов
  Список балансируемых работ проектов
*/
create table P8PNL_JB_JOBS
(
  RN                        number(17) not null,             -- Рег. номер записи
  IDENT                     number(17) not null,             -- Идентификатор процесса
  PRN                       number(17) not null,             -- Рег. номер родителя
  HRN                       number(17) default null,         -- Рег. номер родительской записи в иерархии работ/этапов
  SOURCE                    number(17) not null,             -- Рег. номер источника (работы/этапа проекта)
  NUMB                      varchar2(40) not null,           -- Номер
  NAME                      varchar2(2000) not null,         -- Наименование
  DATE_FROM                 date,                            -- Начало
  DATE_TO                   date,                            -- Окончание
  DURATION                  number(17,5) default 0 not null, -- Длительность
  EXECUTOR                  varchar2(2000) default null,     -- Исполнитель
  STAGE                     number(1) default 0 not null,    -- Признак этапа (0 - нет, 1 - да)  
  EDITABLE                  number(1) default 0 not null,    -- Признак возможности редактирования (0 - нет, 1 - да)
  constraint C_P8PNL_JB_JOBS_RN_PK primary key (RN),
  constraint C_P8PNL_JB_JOBS_PRN_FK foreign key (PRN) references P8PNL_JB_PRJCTS (RN),
  constraint C_P8PNL_JB_JOBS_HRN_FK foreign key (HRN) references P8PNL_JB_JOBS (RN),
  constraint C_P8PNL_JB_JOBS_STAGE_VAL check (STAGE in (0, 1)),
  constraint C_P8PNL_JB_JOBS_EDTBL_VAL check (EDITABLE in (0, 1)),
  constraint C_P8PNL_JB_JOBS_UN unique (IDENT, PRN, SOURCE)
);

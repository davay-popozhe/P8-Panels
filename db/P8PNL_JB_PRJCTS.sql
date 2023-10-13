/* 
  Парус 8 - Панели мониторинга - ПУП - Балансировка планов-графиков проектов
  Список балансируемых проектов
*/
create table P8PNL_JB_PRJCTS
(
  RN                        number(17) not null,          -- Рег. номер записи
  IDENT                     number(17) not null,          -- Идентификатор процесса
  PROJECT                   number(17) not null,          -- Рег. номер проекта
  JOBS                      number(1) default 0 not null, -- Признак наличия плана-графика (0 - нет, 1 - да)
  EDITABLE                  number(1) default 0 not null, -- Признак возможности редактирования (0 - нет, 1 - да)
  CHANGED                   number(1) default 0 not null, -- Признак наличия изменений, требующих сохранения (0 - нет, 1 - да)
  constraint C_P8PNL_JB_PRJCTS_RN_PK primary key (RN),
  constraint C_P8PNL_JB_PRJCTS_PROJECT_FK foreign key (PROJECT) references PROJECT (RN),
  constraint C_P8PNL_JB_PRJCTS_JOBS_VAL check (JOBS in (0, 1)),
  constraint C_P8PNL_JB_PRJCTS_EDTBL_VAL check (EDITABLE in (0, 1)),
  constraint C_P8PNL_JB_PRJCTS_CHNGD_VAL check (CHANGED in (0, 1)),
  constraint C_P8PNL_JB_PRJCTS_UN unique (IDENT, PROJECT)
);

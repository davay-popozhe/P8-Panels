/* 
  Парус 8 - Панели мониторинга - ПУП - Балансировка планов-графиков проектов
  Список балансируемых периодов и ресурсов
*/
create table P8PNL_JB_PERIODS
(
  RN                        number(17) not null,             -- Рег. номер записи
  IDENT                     number(17) not null,             -- Идентификатор процесса
  DATE_FROM                 date not null,                   -- Начало периода
  DATE_TO                   date not null,                   -- Окончание периода
  INS_DEPARTMENT            number(17) not null,             -- Рег. номер штатного подразделения
  FCMANPOWER                number(17) not null,             -- Рег. номер трудового ресурса
  LAB_PLAN_FOT              number(17,3) default 0 not null, -- Трудоёмкость (план, по ФОТ)
  LAB_FACT_RPT              number(17,3) default 0 not null, -- Трудоёмкость (факт, по отчёту)
  LAB_PLAN_JOBS             number(17,3) default 0 not null, -- Трудоёмкость (план, по графику)
  constraint C_P8PNL_JB_PERIODS_RN_PK primary key (RN),
  constraint C_P8PNL_JB_PERIODS_DATE_VAL check (DATE_FROM <= DATE_TO),
  constraint C_P8PNL_JB_PERIODS_INS_DEP_FK foreign key (INS_DEPARTMENT) references INS_DEPARTMENT (RN),
  constraint C_P8PNL_JB_PERIODS_FCMNPWR_FK foreign key (FCMANPOWER) references FCMANPOWER (RN),
  constraint C_P8PNL_JB_PERIODS_UN unique (IDENT, DATE_FROM, INS_DEPARTMENT, FCMANPOWER)
);

/* 
  Парус 8 - Панели мониторинга - ПУП - Балансировка планов-графиков проектов
  Параметры балансировки
*/
create table P8PNL_JB_PRMS
(
  RN                        number(17) not null,   -- Рег. номер записи
  IDENT                     number(17) not null,   -- Идентификатор процесса
  DATE_BEGIN                date not null,         -- Дата начала периода балансировки
  DATE_FACT                 date not null,         -- Факт по состоянию на
  DURATION_MEAS             number(1) not null,    -- Единица измерения длительности (0 - день, 1 - неделя, 2 - декада, 3 - месяц, 4 - квартал, 5 - год)
  DURATION_MEAS_CODE        varchar2(40) not null, -- Единица измерения длительности (мнемокод)
  LAB_MEAS                  number(17) not null,   -- Единица измерения трудоёмкости
  LAB_MEAS_CODE             varchar2(40) not null, -- Единица измерения трудоёмкости (мнемокод)
  constraint C_P8PNL_JB_PRMS_RN_PK primary key (RN),
  constraint C_P8PNL_JB_PRMS_LAB_MEAS_FK foreign key (LAB_MEAS) references DICMUNTS (RN) on delete cascade,
  constraint C_P8PNL_JB_PRMS_DUR_MEAS_VAL check (DURATION_MEAS in (0, 1, 2, 3, 4, 5)),
  constraint C_P8PNL_JB_PRMS_UN unique (IDENT)  
);

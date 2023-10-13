/* 
  Парус 8 - Панели мониторинга - ПУП - Балансировка планов-графиков проектов
  Список балансируемых работ проектов (предшествующие работы)
*/
create table P8PNL_JB_JOBSPREV
(
  RN                        number(17) not null, -- Рег. номер записи
  IDENT                     number(17) not null, -- Идентификатор процесса
  PRN                       number(17) not null, -- Рег. номер родителя
  JB_JOBS                   number(17) not null, -- Рег. номер предшествующей работы/этапа
  constraint C_P8PNL_JB_JOBSPREV_RN_PK primary key (RN),
  constraint C_P8PNL_JB_JOBSPREV_PRN_FK foreign key (PRN) references P8PNL_JB_JOBS (RN),
  constraint C_P8PNL_JB_JOBSPREV_JB_JOBS_FK foreign key (JB_JOBS) references P8PNL_JB_JOBS (RN),
  constraint C_P8PNL_JB_JOBSPREV_UN unique (IDENT, PRN, JB_JOBS)
);

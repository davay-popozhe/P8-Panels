create or replace package PKG_P8PANELS_EQUIPSRV as

  /* Получение параметров фильтра по умолчанию */
  procedure GET_DEFAULT_FP
  (
    COUT                    out clob    -- XML с параметрами фильтра по умолчанию
  );

  /* Формирование строки с кол-вом часов */
  function HOURS_STR
  (
    NHOURS                  in number   -- Кол-во часов
  ) return                  varchar2;   -- Результат работы

  /* Отбор документов (ТОиР или Графики ремонтов) по дате */
  procedure SELECT_EQUIPSRV
  (
    SBELONG                 in varchar2,         -- Принадлежность к Юр. лицу
    SPRODOBJ                in varchar2,         -- Производственный объект
    STECHSERV               in varchar2 := null, -- Техническая служба
    SRESPDEP                in varchar2 := null, -- Ответственное подразделение
    STECHNAME               in varchar2,         -- Наименование объекта ремонта
    SSRVKIND                in varchar2,         -- Код вида ремонта
    NYEAR                   in number,           -- Год
    NMONTH                  in number,           -- Месяц
    NDAY                    in number := null,   -- День
    NWORKTYPE               in number,           -- Тип работы (0 - план, 1 - факт)
    NIDENT                  out number           -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  );

  /* Выполнение работ по ТОиР */
  procedure EQUIPSRV_GRID
  (
    SBELONG                 in varchar2,         -- Принадлежность к Юр. лицу
    SPRODOBJ                in varchar2,         -- Производственный объект
    STECHSERV               in varchar2 := null, -- Техническая служба
    SRESPDEP                in varchar2 := null, -- Ответственное подразделение
    NFROMMONTH              in number,           -- Месяц начала периода
    NFROMYEAR               in number,           -- Год начала периода
    NTOMONTH                in number,           -- Месяц окончания периода
    NTOYEAR                 in number,           -- Год окончания периода
    COUT                    out clob             -- График проектов
  );
  
end PKG_P8PANELS_EQUIPSRV;
/
create or replace package body PKG_P8PANELS_EQUIPSRV as
  
  /* Получение параметров фильтра по умолчанию */
  procedure GET_DEFAULT_FP
  (
    COUT                    out clob                               -- XML с параметрами фильтра по умолчанию
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Рег. номер организации
    SJUR_PERS               PKG_STD.TSTRING := null;               -- Юр. лицо (наименование)
  begin
    /* Находим юр. лицо */
    SJUR_PERS := GET_OPTIONS_STR(SCODE => 'JuridicalPerson', NCOMP_VERS => NCOMPANY);
    /* Формируем XML */
    PKG_XFAST.PROLOGUE(ITYPE => PKG_XFAST.CONTENT_);
    PKG_XFAST.DOWN_NODE(SNAME => 'DATA');
    PKG_XFAST.DOWN_NODE(SNAME => 'JURPERS');
    PKG_XFAST.VALUE(SVALUE => SJUR_PERS);
    PKG_XFAST.UP();
    PKG_XFAST.DOWN_NODE(SNAME => 'MONTH');
    PKG_XFAST.VALUE(NVALUE => EXTRACT(month from sysdate));
    PKG_XFAST.UP();
    PKG_XFAST.DOWN_NODE(SNAME => 'YEAR');
    PKG_XFAST.VALUE(NVALUE => EXTRACT(year from sysdate));
    PKG_XFAST.UP();
    PKG_XFAST.UP();
    /* Сериализуем в clob */
    COUT := PKG_XFAST.SERIALIZE_TO_CLOB();
    PKG_XFAST.EPILOGUE();
  end GET_DEFAULT_FP;

  /* Формирование строки с кол-вом часов */
  function HOURS_STR
  (
    NHOURS                  in number        -- Кол-во часов
  ) return                  varchar2         -- Строка с кол-вом часов
  is
    SRESULT                 PKG_STD.TSTRING; -- Строка результат
  begin
    if ((mod(TRUNC(NHOURS), 10) = 1) and (mod(TRUNC(NHOURS), 100) != 11)) then
      SRESULT := NHOURS || ' час';
    elsif (((mod(TRUNC(NHOURS), 10) = 2) and (mod(TRUNC(NHOURS), 100) != 12)) or
          ((mod(TRUNC(NHOURS), 10) = 3) and (mod(TRUNC(NHOURS), 100) != 13)) or
          ((mod(TRUNC(NHOURS), 10) = 4) and (mod(TRUNC(NHOURS), 100) != 14))) then
      SRESULT := NHOURS || ' часа';
    else
      SRESULT := NHOURS || ' часов';
    end if;
    return SRESULT;
  end HOURS_STR;

  /* Отбор документов (ТОиР или Графики ремонтов) по дате */
  procedure SELECT_EQUIPSRV
  (
    SBELONG                 in varchar2,                           -- Принадлежность к Юр. лицу
    SPRODOBJ                in varchar2,                           -- Производственный объект
    STECHSERV               in varchar2 := null,                   -- Техническая служба
    SRESPDEP                in varchar2 := null,                   -- Ответственное подразделение
    STECHNAME               in varchar2,                           -- Наименование объекта ремонта
    SSRVKIND                in varchar2,                           -- Код вида ремонта
    NYEAR                   in number,                             -- Год
    NMONTH                  in number,                             -- Месяц
    NDAY                    in number := null,                     -- День
    NWORKTYPE               in number,                             -- Тип работы (0 - план, 1 - факт)
    NIDENT                  out number                             -- Идентификатор буфера подобранных (списка отмеченных записей, null - не найдено)
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Рег. номер организации
    NSELECTLIST             PKG_STD.TREF;                          -- Рег. номер добавленной записи буфера подобранных
    SDATE                   PKG_STD.TSTRING;                       -- Строка даты
  begin
    /* Проверка на дату с днём */
    if (NDAY is not null) then
      SDATE := LPAD(TO_CHAR(NDAY), 2, '0') || '.' || LPAD(TO_CHAR(NMONTH), 2, '0') || '.' || NYEAR;
    else
      SDATE := LPAD(TO_CHAR(NMONTH), 2, '0') || '.' || NYEAR;
    end if;
    /* Если графики ТОиР */
    if (NWORKTYPE = 0) then
      for C in (select T.RN,
                       T.COMPANY
                  from EQTCHSRV       T,
                       JURPERSONS     J,
                       EQTECSRVKIND   SK,
                       EQCONFIG       C1,
                       EQCONFIG       C2,
                       INS_DEPARTMENT DS,
                       INS_DEPARTMENT DR
                 where T.STATE in (1, 2)
                   and T.COMPANY = NCOMPANY
                   and T.JUR_PERS = J.RN
                   and J.CODE = SBELONG
                   and T.EQCONFIG = C1.RN
                   and C1.CODE = SPRODOBJ
                   and T.DEPTTCSRV = DS.RN(+)
                   and (DS.CODE = STECHSERV or STECHSERV is null)
                   and T.DEPTRESP = DR.RN(+)
                   and (DR.CODE = SRESPDEP or SRESPDEP is null)
                   and T.EQCONFIG_TECH = C2.RN
                   and C2.NAME = STECHNAME
                   and T.EQTECSRVKIND = SK.RN
                   and SK.CODE = SSRVKIND
                   and ((NDAY is not null and TO_DATE(SDATE, 'dd.mm.yyyy') between TRUNC(T.DATEPRD_BEG) and
                       TRUNC(T.DATEPRD_END)) or
                       (NDAY is null and TRUNC(T.DATEPRD_BEG, 'MONTH') <= TRUNC(TO_DATE(SDATE, 'mm.yyyy'), 'MONTH') and
                       TRUNC(TO_DATE(SDATE, 'mm.yyyy'), 'MONTH') <= TRUNC(LAST_DAY(T.DATEPRD_END)))))
      
      loop
        /* Сформируем идентификатор буфера */
        if (NIDENT is null) then
          NIDENT := GEN_IDENT();
        end if;
        /* Добавим подобранное в список отмеченных записей */
        P_SELECTLIST_BASE_INSERT(NIDENT       => NIDENT,
                                 NCOMPANY     => C.COMPANY,
                                 NDOCUMENT    => C.RN,
                                 SUNITCODE    => 'EquipTechServices',
                                 SACTIONCODE  => null,
                                 NCRN         => null,
                                 NDOCUMENT1   => null,
                                 SUNITCODE1   => null,
                                 SACTIONCODE1 => null,
                                 NRN          => NSELECTLIST);
      end loop;
      /* Иначе ремонтные ведомости */
    else
      for C in (select T.RN,
                       T.COMPANY
                  from EQRPSHEETS   T,
                       JURPERSONS   J,
                       EQTECSRVKIND SK,
                       EQCONFIG     C
                 where T.STATE in (0, 2, 3)
                   and T.COMPANY = NCOMPANY
                   and T.JURPERSONS = J.RN
                   and J.CODE = SBELONG
                   and T.EQCONFIG = C.RN
                   and C.NAME = STECHNAME
                   and T.TECSRVKIND = SK.RN
                   and SK.CODE = SSRVKIND
                   and ((NDAY is not null and TO_DATE(SDATE, 'dd.mm.yyyy') between TRUNC(T.DATEFACT_BEG) and
                       TRUNC(T.DATEFACT_END)) or
                       (NDAY is null and TRUNC(T.DATEFACT_BEG, 'MONTH') <= TRUNC(TO_DATE(SDATE, 'mm.yyyy'), 'MONTH') and
                       TRUNC(TO_DATE(SDATE, 'mm.yyyy'), 'MONTH') <= TRUNC(LAST_DAY(T.DATEFACT_END)))))
      loop
        /* Сформируем идентификатор буфера */
        if (NIDENT is null) then
          NIDENT := GEN_IDENT();
        end if;
        /* Добавим подобранное в список отмеченных записей */
        P_SELECTLIST_BASE_INSERT(NIDENT       => NIDENT,
                                 NCOMPANY     => C.COMPANY,
                                 NDOCUMENT    => C.RN,
                                 SUNITCODE    => 'EquipRepairSheets',
                                 SACTIONCODE  => null,
                                 NCRN         => null,
                                 NDOCUMENT1   => null,
                                 SUNITCODE1   => null,
                                 SACTIONCODE1 => null,
                                 NRN          => NSELECTLIST);
      end loop;
    end if;
  end SELECT_EQUIPSRV;

  /* Выполнение работ по ТОиР */
  procedure EQUIPSRV_GRID
  (
    SBELONG                 in varchar2,                           -- Принадлежность к Юр. лицу
    SPRODOBJ                in varchar2,                           -- Производственный объект
    STECHSERV               in varchar2 := null,                   -- Техническая служба
    SRESPDEP                in varchar2 := null,                   -- Ответственное подразделение
    NFROMMONTH              in number,                             -- Месяц начала периода
    NFROMYEAR               in number,                             -- Год начала периода
    NTOMONTH                in number,                             -- Месяц окончания периода
    NTOYEAR                 in number,                             -- Год окончания периода
    COUT                    out clob                               -- График проектов
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Рег. номер организации
    SPRJ_GROUP_NAME         PKG_STD.TSTRING;                       -- Наименование группы для проекта
    BEXPANDED               boolean;                               -- Флаг раскрытости уровня
    RDG                     PKG_P8PANELS_VISUAL.TDATA_GRID;        -- Описание таблицы
    RDG_ROW0                PKG_P8PANELS_VISUAL.TROW;              -- Строка таблицы0
    RDG_ROW                 PKG_P8PANELS_VISUAL.TROW;              -- Строка таблицы
    RDG_ROW2                PKG_P8PANELS_VISUAL.TROW;              -- Строка таблицы2
    NCURYEAR                PKG_STD.TNUMBER;                       -- Текущий год
    NCURMONTH               PKG_STD.TNUMBER;                       -- Текущий месяц
    NTOTALDAYS              PKG_STD.TNUMBER;                       -- Дней в текущем месяце
    SCURTECHOBJ             PKG_STD.TSTRING := null;               -- Текущий технический объект
    SCURTSKCODE             PKG_STD.TSTRING := null;               -- Текущий вид ремонта
    NFROMDATE               PKG_STD.TLDATE;                        -- Дата начала периода
    NTODATE                 PKG_STD.TLDATE;                        -- Дата конца периода
    NMS                     PKG_STD.TNUMBER;                       -- Месяц начала в цикле года
    NME                     PKG_STD.TNUMBER;                       -- Месяц окончания в цикле года
    NYEAR_PLAN              PKG_STD.TNUMBER;                       -- Год план
    NMONTH_PLAN             PKG_STD.TNUMBER;                       -- Месяц план
    NDAY_PLAN               PKG_STD.TNUMBER;                       -- День план
    NYEAR_FACT              PKG_STD.TNUMBER;                       -- Год факт
    NMONTH_FACT             PKG_STD.TNUMBER;                       -- Месяц факт
    NDAY_FACT               PKG_STD.TNUMBER;                       -- День факт
    SPERIODNAME             PKG_STD.TSTRING;                       -- Имя периода
    SFACT_CLR               PKG_STD.TSTRING;                       -- Цвет закрашивания фактических дат
    NROWS                   PKG_STD.TNUMBER := 0;                  -- Кол-во строк в курсоре
    NWORKPERDAY             PKG_STD.TNUMBER(17,2) := null;         -- Работы в день
    YM                      PKG_CONTVALLOC1S.TCONTAINER;           -- Коллекция для подсчёта работ за месяц
    MCLR                    PKG_CONTVALLOC1S.TCONTAINER;           -- Коллекция для закрашивания месяцев
    CR                      PKG_STD.TSTRING;                       -- Текущий ключ коллекции MCLR
    GF                      PKG_CONTVALLOC1S.TCONTAINER;           -- Коллекция заполнения групп по объекту ремонта
    COLS                    PKG_CONTVALLOC1S.TCONTAINER;           -- Коллекция закрашивания колонок

    /* Курсор с работами ТОиР */
    cursor C1 is
           select TT.NEQV_RN NEQV_RN,
                  TT.NEQS_RN NEQS_RN,
                  TT.NWRK_RN NRN,
                  TT.NCOMPANY NCOMPANY,
                  TT.SNAME_WORK SWORKNAME,
                  EC2.CODE STECHOBJCODE,
                  EC2.NAME STECHOBJNAME,
                  JP.CODE SBELONG,
                  EC1.CODE SPRODOBJ,
                  DS.CODE STECHSERV,
                  DR.CODE SRESPDEP,
                  TT.DDATEPRD_BEG DDATEPLANBEG,
                  TT.DDATEPRD_END DDATEPLANEND,
                  EQJ.DATEFACT_BEG DDATEFACTBEG,
                  COALESCE(EQJ.DATEFACT_END, EQJ.DATEFACT_BEG) DDATEFACTEND, --
                  EK.CODE STECSRVKINDCODE,
                  EK.NAME STECSRVKINDNAME,
                  COALESCE(EW.NSUM, (TT.DDATEPRD_END - TT.DDATEPRD_BEG) * 24) NSUMWORKPLAN,
                  COALESCE(EWJ.NSUMF, (EQJ.DATEFACT_END - EQJ.DATEFACT_BEG) * 24) NSUMWORKFACT
             from (select B.NEQV_RN NEQV_RN,
                          B.NCOMPANY NCOMPANY,
                          B.NJUR_PERS NJUR_PERS,
                          B.NSTATE NSTATE,
                          B.DDATEPRD_BEG DDATEPRD_BEG,
                          B.DDATEPRD_END DDATEPRD_END,
                          B.NEQS_RN NEQS_RN,
                          C.RN NWRK_RN,
                          C.PRN NWRK_PRN,
                          C.NAME_WORK SNAME_WORK,
                          C.DATEPLAN_BEG DDATEPLAN_BEG,
                          C.DATEPLAN_END DDATEPLAN_END,
                          COALESCE(C.TECSRVKIND, B.NEQTECSRVKIND) NTECSRVKIND,
                          COALESCE(C.EQCONFIG, B.NEQCONFIG_TECH) NEQCONFIG,
                          C.DEPTPERF NDEPTPERF,
                          C.DEPTTCSRV NDEPTTCSRV,
                          C.RESP_AGN NRESP_AGN
                     from (select EQV.RN            NEQV_RN,
                                  EQV.COMPANY       NCOMPANY,
                                  EQV.JUR_PERS      NJUR_PERS,
                                  EQV.STATE         NSTATE,
                                  EQV.DATEPRD_BEG   DDATEPRD_BEG,
                                  EQV.DATEPRD_END   DDATEPRD_END,
                                  EQV.EQTECSRVKIND  NEQTECSRVKIND,
                                  EQV.EQCONFIG_TECH NEQCONFIG_TECH,
                                  EQS.RN            NEQS_RN
                             from EQTCHSRV   EQV,
                                  JURPERSONS J,
                                  DOCLINKS   DL,
                                  EQRPSHEETS EQS
                            where EQV.JUR_PERS = J.RN
                              and J.CODE = SBELONG
                              and EQV.RN = DL.IN_DOCUMENT(+)
                              and DL.OUT_UNITCODE(+) = 'EquipRepairSheets'
                              and DL.OUT_DOCUMENT = EQS.RN(+)) B,
                          EQTCHSRWRK C
                    where B.NEQV_RN = C.PRN(+)
                   union all
                   select B.NEQV_RN NEQV_RN,
                          B.NCOMPANY NCOMPANY,
                          B.NJUR_PERS NJUR_PERS,
                          B.NSTATE NSTATE,
                          B.DDATEPLAN_BEG DDATEPLAN_BEG,
                          B.DDATEPLAN_END DDATEPLAN_END,
                          B.NEQS_RN NEQS_RN,
                          C.RN NWRK_RN,
                          C.PRN NWRK_PRN,
                          C.NAME_WORK SNAME_WORK,
                          C.DATEPLAN_BEG DDATEPLAN_BEG,
                          C.DATEPLAN_END DDATEPLAN_END,
                          COALESCE(C.TECSRVKIND, B.NTECSRVKIND) NTECSRVKIND,
                          COALESCE(C.EQCONFIG, B.NEQCONFIG) NEQCONFIG,
                          C.DEPTPERF NDEPTPERF,
                          null NDEPTTCSRV,
                          C.RESP_AGN NRESP_AGN
                     from (select null             NEQV_RN,
                                  EQS.COMPANY      NCOMPANY,
                                  EQS.JURPERSONS   NJUR_PERS,
                                  EQS.STATE        NSTATE,
                                  EQS.DATEPLAN_BEG DDATEPLAN_BEG,
                                  EQS.DATEPLAN_END DDATEPLAN_END,
                                  EQS.RN           NEQS_RN,
                                  EQS.EQCONFIG     NEQCONFIG,
                                  EQS.TECSRVKIND   NTECSRVKIND
                             from EQRPSHEETS EQS,
                                  JURPERSONS J
                            where not exists (select 1
                                     from DOCLINKS DL
                                    where DL.OUT_DOCUMENT = EQS.RN
                                      and DL.IN_UNITCODE = 'EquipTechServices')
                              and EQS.JURPERSONS = J.RN
                              and J.CODE = SBELONG) B,
                          EQRPSHWRK C
                    where B.NEQS_RN = C.PRN(+)) TT,
                  EQTECSRVKIND EK,
                  JURPERSONS JP,
                  EQCONFIG EC1,
                  EQCONFIG EC2,
                  INS_DEPARTMENT DS,
                  INS_DEPARTMENT DR,
                  DOCLINKS DL,
                  EQTECSRVJRNL EQJ,
                  (select T.PRN NPRN,
                          sum(T.WORKTIMEPLAN * T.PERFORM_QUANT) NSUM
                     from EQTCHSRWRC T
                    group by T.PRN) EW,
                  (select T.PRN NPRN,
                          sum(T.WORKTIMEFACT * T.QUANTFACT) NSUMF
                     from EQTCHSRJRNLWRC T
                    group by T.PRN) EWJ
            where TT.NCOMPANY = NCOMPANY
              and ((TT.NSTATE in (1, 2) and TT.NEQV_RN is not null) or (TT.NSTATE in (0, 2, 3) and TT.NEQV_RN is null))
              and TT.DDATEPRD_BEG >= NFROMDATE
              and TT.DDATEPRD_END <= NTODATE
              and JP.CODE = SBELONG
              and EC1.CODE = SPRODOBJ
              and (DS.CODE = STECHSERV or STECHSERV is null)
              and (DR.CODE = SRESPDEP or SRESPDEP is null)
              and TT.NEQCONFIG = EC2.RN(+)
              and TT.NDEPTPERF = DR.RN(+)
              and TT.NDEPTTCSRV = DS.RN(+)
              and TT.NWRK_RN = EW.NPRN(+)
              and EQJ.RN = EWJ.NPRN(+)
              and TT.NTECSRVKIND = EK.RN(+)
              and TT.NWRK_RN = DL.IN_DOCUMENT(+)
              and ((DL.OUT_UNITCODE = 'EquipTechServiceJournal' and DL.RN is not null) or
                  (DL.OUT_UNITCODE is null and DL.RN is null))
              and DL.OUT_DOCUMENT = EQJ.RN(+)
            order by EC2.NAME,
                     EK.CODE;
  begin
    /* Определим дату начала периода */
    NFROMDATE := TO_DATE('01.' || LPAD(TO_CHAR(NFROMMONTH), 2, '0') || '.' || TO_CHAR(NFROMYEAR), 'dd.mm.yyyy');
    /* Определим дату конца периода */
    NTODATE := LAST_DAY(TO_DATE('01.' || LPAD(TO_CHAR(NTOMONTH), 2, '0') || '.' || TO_CHAR(NTOYEAR), 'dd.mm.yyyy'));
    /* Инициализируем таблицу данных */
    RDG := PKG_P8PANELS_VISUAL.TDATA_GRID_MAKE();
    /* Формируем структуру заголовка */
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SOBJINFO',
                                               SCAPTION   => 'Информация по объекту ремонта',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SINFO',
                                               SCAPTION   => 'Объект ремонта',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SWRKTYPE',
                                               SCAPTION   => 'Тип работ',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               SPARENT    => 'SINFO');
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'NRN',
                                               SCAPTION   => 'Рег. номер',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_NUMB,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SWORKNAME',
                                               SCAPTION   => 'Наименование работы',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'STECHOBJCODE',
                                               SCAPTION   => 'Код тех. объекта',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'STECHOBJNAME',
                                               SCAPTION   => 'Наименование тех. объекта',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SBELONG',
                                               SCAPTION   => 'Принадлежность',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SPRODOBJ',
                                               SCAPTION   => 'Производственный объект',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'STECHSERV',
                                               SCAPTION   => 'Тех. служба',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'SRESPDEP',
                                               SCAPTION   => 'Отвественное подразделение',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'STECSERVCODE',
                                               SCAPTION   => 'Вид ремонта',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DDATEPLANBEG',
                                               SCAPTION   => 'Начало работы (план)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DDATEPLANEND',
                                               SCAPTION   => 'Окончание работы (план)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DDATEFACTBEG',
                                               SCAPTION   => 'Начало работы (факт)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'DDATEFACTEND',
                                               SCAPTION   => 'Окончание работы (факт)',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_DATE,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'STECSRVKINDCODE',
                                               SCAPTION   => 'Код типа работы',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                               SNAME      => 'STECSRVKINDNAME',
                                               SCAPTION   => 'Наименование типа работы',
                                               SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                               BVISIBLE   => false);
    /* Очистка коллекций */
    PKG_CONTVALLOC1S.PURGE(RCONTAINER => YM);
    PKG_CONTVALLOC1S.PURGE(RCONTAINER => MCLR);
    PKG_CONTVALLOC1S.PURGE(RCONTAINER => GF);
    PKG_CONTVALLOC1S.PURGE(RCONTAINER => COLS);
    /* Текущий год */
    NCURYEAR := EXTRACT(year from sysdate);
    /* Текущий месяц */
    NCURMONTH := EXTRACT(month from sysdate);
    /* Цикл по годам периода */
    for Y in NFROMYEAR .. NTOYEAR
    loop
      if (NFROMYEAR = NTOYEAR) then
        NMS := NFROMMONTH;
        NME := NTOMONTH;
      else
        if (Y = NFROMYEAR) then
          NMS := NFROMMONTH;
          NME := 12;
        elsif ((NFROMYEAR < Y) and (Y < NTOYEAR)) then
          NMS := 1;
          NME := 12;
        elsif (Y = NTOYEAR) then
          NMS := 1;
          NME := NTOMONTH;
        end if;
      end if;
      /* Цикл по месяцам года */
      for M in NMS .. NME
      loop
        PKG_CONTVALLOC1S.PUTN(RCONTAINER => YM, SROWID => '_' || TO_CHAR(Y) || '_' || TO_CHAR(M) || '_P', NVALUE => 0);
        PKG_CONTVALLOC1S.PUTN(RCONTAINER => YM, SROWID => '_' || TO_CHAR(Y) || '_' || TO_CHAR(M) || '_F', NVALUE => 0);
        /* Находим текущий месяц и делаем его развёрнутым по дням */
        if ((Y = NCURYEAR) and (M = NCURMONTH)) then
          BEXPANDED := true;
        else
          BEXPANDED := false;
        end if;
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID  => RDG,
                                                   SNAME       => '_' || TO_CHAR(Y) || '_' || TO_CHAR(M),
                                                   SCAPTION    => LPAD(TO_CHAR(M), 2, '0') || ' ' || TO_CHAR(Y),
                                                   SDATA_TYPE  => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                                   BEXPANDABLE => true,
                                                   BEXPANDED   => BEXPANDED);
        /* Подсчёт кол-ва дней в месяце */
        NTOTALDAYS := TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE('01.' || LPAD(TO_CHAR(M), 2, '0') || '.' || TO_CHAR(Y),
                                                         'dd.mm.yyyy')),
                                        'dd'),
                                '99');
        /* Цикл по дням месяца */
        for D in 1 .. NTOTALDAYS
        loop
          PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_COL_DEF(RDATA_GRID => RDG,
                                                     SNAME      => '_' || TO_CHAR(Y) || '_' || TO_CHAR(M) || '_' ||
                                                                   TO_CHAR(D),
                                                     SCAPTION   => TO_CHAR(D, '99'),
                                                     SDATA_TYPE => PKG_P8PANELS_VISUAL.SDATA_TYPE_STR,
                                                     SPARENT    => '_' || TO_CHAR(Y) || '_' || TO_CHAR(M));
        end loop;
      end loop;
    end loop;
    /* Подсчёт кол-ва записей в курсоре */
    for Q1 in C1
    loop
      NROWS := NROWS + 1;
    end loop;
    /* Цикл по курсору */
    for QQ in C1
    loop
      NROWS := NROWS - 1;
      /* Если новый объект ремонта */
      if ((SCURTECHOBJ != QQ.STECHOBJNAME) or (SCURTECHOBJ is null)) then
        /* Если строка с трудоёмкостью по объекту ремонта сформирована */
        if (RDG_ROW0.RCOLS is not null) then
          /* Цикл по годам периода */
          for Y in NFROMYEAR .. NTOYEAR
          loop
            /* Если отчёт в пределах года */
            if (NFROMYEAR = NTOYEAR) then
              NMS := NFROMMONTH;
              NME := NTOMONTH;
              /* Иначе вычисляем кол-во месяцев в каждом году периода отчёта*/
            else
              if (Y = NFROMYEAR) then
                NMS := NFROMMONTH;
                NME := 12;
              elsif ((NFROMYEAR < Y) and (Y < NTOYEAR)) then
                NMS := 1;
                NME := 12;
              elsif (Y = NTOYEAR) then
                NMS := 1;
                NME := NTOMONTH;
              end if;
            end if;
            /* Цикл по месяцам года, заполнение трудоёмкости с привязкой к месяцу */
            for M in NMS .. NME
            loop
              SPERIODNAME := '_' || TO_CHAR(Y) || '_' || TO_CHAR(M);
              PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW   => RDG_ROW0,
                                               SNAME  => SPERIODNAME,
                                               SVALUE => 'план: ' || HOURS_STR(NHOURS => TRUNC(PKG_CONTVALLOC1S.GETN(RCONTAINER => YM,
                                                                                                                     SROWID     => SPERIODNAME || '_P'),
                                                                                               1)) || ' факт: ' ||
                                                         HOURS_STR(NHOURS => TRUNC(PKG_CONTVALLOC1S.GETN(RCONTAINER => YM,
                                                                                                         SROWID     => SPERIODNAME || '_F'),
                                                                                   1)));
              /* Добавление в коллекцию трудоёмкость план */
              PKG_CONTVALLOC1S.PUTN(RCONTAINER => YM, SROWID => SPERIODNAME || '_P', NVALUE => 0);
              /* Добавление в коллекцию трудоёмкость факт */
              PKG_CONTVALLOC1S.PUTN(RCONTAINER => YM, SROWID => SPERIODNAME || '_F', NVALUE => 0);
            end loop;
          end loop;
          /* Добавление строки с трудоёмкостью */
          PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW0);
        end if;
        /* Добавление группы с объектом ремонта */
        SCURTECHOBJ     := QQ.STECHOBJNAME;
        SPRJ_GROUP_NAME := SCURTECHOBJ;
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_GROUP(RDATA_GRID  => RDG,
                                                 SNAME       => SPRJ_GROUP_NAME,
                                                 SCAPTION    => QQ.STECHOBJNAME,
                                                 BEXPANDABLE => false);
        RDG_ROW0 := PKG_P8PANELS_VISUAL.TROW_MAKE(SGROUP => SPRJ_GROUP_NAME);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW0, SNAME => 'SOBJINFO', SVALUE => SCURTECHOBJ);
      end if;
      /* Формируем имя группы для вида ремонта */
      SCURTSKCODE := SCURTECHOBJ || '_' || QQ.STECSRVKINDCODE;
      /* Если по данной группе еще нет строк плана и факта */
      if (PKG_CONTVALLOC1S.EXISTS_(RCONTAINER => GF, SROWID => SCURTSKCODE) = false) then
        /* Добавляем строку плана */
        if (RDG_ROW.RCOLS is not null) then
          PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW);
        end if;
        /* Добавляем строку факта */
        if (RDG_ROW2.RCOLS is not null) then
          CR := PKG_CONTVALLOC1S.FIRST_(RCONTAINER => MCLR);
          /* Цикл по коллекции для закрашивания месяцев */
          for Z in 1 .. PKG_CONTVALLOC1S.COUNT_(RCONTAINER => MCLR)
          loop
            PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW   => RDG_ROW2,
                                             SNAME  => CR,
                                             SVALUE => PKG_CONTVALLOC1S.GETS(RCONTAINER => MCLR, SROWID => CR));
            CR := PKG_CONTVALLOC1S.NEXT_(RCONTAINER => MCLR, SROWID => CR);
          end loop;
          PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW2);
        end if;
        PKG_CONTVALLOC1S.PURGE(RCONTAINER => MCLR);
        /* Добвим группу для вида ремонта */
        SPRJ_GROUP_NAME := SCURTSKCODE;
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_GROUP(RDATA_GRID  => RDG,
                                                 SNAME       => SPRJ_GROUP_NAME,
                                                 SCAPTION    => QQ.STECSRVKINDCODE,
                                                 BEXPANDABLE => false);
        /* Строка плана */
        RDG_ROW := PKG_P8PANELS_VISUAL.TROW_MAKE(SGROUP => SPRJ_GROUP_NAME);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'SOBJINFO', SVALUE => QQ.STECSRVKINDCODE);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => 'SWRKTYPE', SVALUE => 'План');
        /* Строка факта */
        RDG_ROW2 := PKG_P8PANELS_VISUAL.TROW_MAKE(SGROUP => SPRJ_GROUP_NAME);
        PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW2, SNAME => 'SWRKTYPE', SVALUE => 'Факт');
        /* Добавляем в заполненные группы */
        PKG_CONTVALLOC1S.PUTS(RCONTAINER => GF, SROWID => SPRJ_GROUP_NAME, SVALUE => '');
      end if;
      /* Плановые работы */
      if (QQ.NEQV_RN is not null) then
        /* Цикл по периоду */
        for X in 0 .. TRUNC(QQ.DDATEPLANEND) - TRUNC(QQ.DDATEPLANBEG)
        loop
          NYEAR_PLAN  := EXTRACT(year from QQ.DDATEPLANBEG + X);
          NMONTH_PLAN := EXTRACT(month from QQ.DDATEPLANBEG + X);
          NDAY_PLAN   := EXTRACT(day from QQ.DDATEPLANBEG + X);
          /* Если первый день периода */
          if (X = 0) then
            SPERIODNAME := '_' || TO_CHAR(NYEAR_PLAN) || '_' || NMONTH_PLAN;
            /* Подсчёт трудоёмкости за месяц */
            if (QQ.NSUMWORKPLAN is not null) then
              PKG_CONTVALLOC1S.PUTN(RCONTAINER => YM,
                                    SROWID     => SPERIODNAME || '_P',
                                    NVALUE     => PKG_CONTVALLOC1S.GETN(RCONTAINER => YM, SROWID => SPERIODNAME || '_P') +
                                                  QQ.NSUMWORKPLAN);
            end if;
            /* Закрашивание месяца плана синим */
            if (PKG_CONTVALLOC1S.EXISTS_(RCONTAINER => COLS, SROWID => SPRJ_GROUP_NAME || ' ' || SPERIODNAME || ' PLAN') =
               false) then
              PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => SPERIODNAME, SVALUE => 'blue');
              PKG_CONTVALLOC1S.PUTS(RCONTAINER => COLS,
                                    SROWID     => SPRJ_GROUP_NAME || ' ' || SPERIODNAME || ' PLAN',
                                    SVALUE     => '');
            end if;
          end if;
          SPERIODNAME := '_' || TO_CHAR(NYEAR_PLAN) || '_' || TO_CHAR(NMONTH_PLAN) || '_' || TO_CHAR(NDAY_PLAN);
          /* Закрашивание дня плана синим */
          if (PKG_CONTVALLOC1S.EXISTS_(RCONTAINER => COLS, SROWID => SPRJ_GROUP_NAME || ' ' || SPERIODNAME || ' PLAN') =
             false) then
            PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW => RDG_ROW, SNAME => SPERIODNAME, SVALUE => 'blue');
            PKG_CONTVALLOC1S.PUTS(RCONTAINER => COLS,
                                  SROWID     => SPRJ_GROUP_NAME || ' ' || SPERIODNAME || ' PLAN',
                                  SVALUE     => '');
          end if;
        end loop;
      end if;
      /* Фактические и внеплановые работы */
      if ((QQ.DDATEFACTEND is not null) and (QQ.DDATEFACTBEG is not null)) then
        /* Фактические - зелёный, внеплановые - красный */
        if (QQ.NEQV_RN is not null) then
          SFACT_CLR := 'green';
        else
          SFACT_CLR := 'red';
        end if;
        NWORKPERDAY := null;
        /* Если период не в одном месяце, то считаем трудоёмкость в день */
        if (EXTRACT(month from QQ.DDATEFACTBEG) != EXTRACT(month from QQ.DDATEFACTEND)) then
          NWORKPERDAY := QQ.NSUMWORKFACT / (ROUND(QQ.DDATEFACTEND - QQ.DDATEFACTBEG) + 1);
          NCURMONTH   := EXTRACT(month from QQ.DDATEFACTBEG);
        end if;
        /* Цикл по периоду */
        for X in 0 .. TRUNC(QQ.DDATEFACTEND) - TRUNC(QQ.DDATEFACTBEG)
        loop
          NYEAR_FACT  := EXTRACT(year from QQ.DDATEFACTBEG + X);
          NMONTH_FACT := EXTRACT(month from QQ.DDATEFACTBEG + X);
          NDAY_FACT   := EXTRACT(day from QQ.DDATEFACTBEG + X);
          /* Если первый день периода или следующий месяц периода */
          if ((X = 0) or (NCURMONTH != NMONTH_FACT)) then
            /* Обновляется текущий месяц */
            if (NCURMONTH != NMONTH_FACT) then
              NCURMONTH := NMONTH_FACT;
            end if;
            SPERIODNAME := '_' || TO_CHAR(NYEAR_FACT) || '_' || NMONTH_FACT;
            /* Подсчёт трудоёмкости за месяц если период в одном месяце */
            if ((QQ.NSUMWORKFACT is not null) and (NWORKPERDAY is null)) then
              PKG_CONTVALLOC1S.PUTN(RCONTAINER => YM,
                                    SROWID     => SPERIODNAME || '_F',
                                    NVALUE     => PKG_CONTVALLOC1S.GETN(RCONTAINER => YM, SROWID => SPERIODNAME || '_F') +
                                                  QQ.NSUMWORKFACT);
            end if;
            /* Добавление в коллекцию окрашивания месяца */
            if (PKG_CONTVALLOC1S.EXISTS_(RCONTAINER => MCLR, SROWID => SPERIODNAME) = false) then
              PKG_CONTVALLOC1S.PUTS(RCONTAINER => MCLR, SROWID => SPERIODNAME, SVALUE => SFACT_CLR);
            else
              /* Если второй цвет для месяца */
              if (STRIN(trim(SFACT_CLR), trim(PKG_CONTVALLOC1S.GETS(MCLR, SPERIODNAME))) = 0) then
                PKG_CONTVALLOC1S.PUTS(RCONTAINER => MCLR,
                                      SROWID     => SPERIODNAME,
                                      SVALUE     => PKG_CONTVALLOC1S.GETS(RCONTAINER => MCLR, SROWID => SPERIODNAME) || ' ' ||
                                                    SFACT_CLR);
              end if;
            end if;
          end if;
          /* Подсчёт трудоёмкости за месяц если период не в одном месяце */
          if (NWORKPERDAY is not null) then
            PKG_CONTVALLOC1S.PUTN(RCONTAINER => YM,
                                  SROWID     => SPERIODNAME || '_F',
                                  NVALUE     => PKG_CONTVALLOC1S.GETN(RCONTAINER => YM, SROWID => SPERIODNAME || '_F') +
                                                NWORKPERDAY);
          end if;
          SPERIODNAME := '_' || TO_CHAR(NYEAR_FACT) || '_' || TO_CHAR(NMONTH_FACT) || '_' || TO_CHAR(NDAY_FACT);
          /* Добавление в коллекцию окрашивания дней факта */
          if (PKG_CONTVALLOC1S.EXISTS_(RCONTAINER => MCLR, SROWID => SPERIODNAME) = false) then
            PKG_CONTVALLOC1S.PUTS(RCONTAINER => MCLR, SROWID => SPERIODNAME, SVALUE => SFACT_CLR);
          else
            /* Если второй цвет для месяца */
            if ((trim(PKG_CONTVALLOC1S.GETS(RCONTAINER => MCLR, SROWID => SPERIODNAME)) = 'green') and
               (trim(SFACT_CLR) = 'red')) then
              PKG_CONTVALLOC1S.PUTS(RCONTAINER => MCLR, SROWID => SPERIODNAME, SVALUE => SFACT_CLR);
            end if;
          end if;
        end loop;
      end if;
      if ((RDG_ROW0.RCOLS is not null) and (NROWS = 0)) then
        /* Цикл по годам периода */
        for Y in NFROMYEAR .. NTOYEAR
        loop
          if (NFROMYEAR = NTOYEAR) then
            NMS := NFROMMONTH;
            NME := NTOMONTH;
          else
            if (Y = NFROMYEAR) then
              NMS := NFROMMONTH;
              NME := 12;
            elsif ((NFROMYEAR < Y) and (Y < NTOYEAR)) then
              NMS := 1;
              NME := 12;
            elsif (Y = NTOYEAR) then
              NMS := 1;
              NME := NTOMONTH;
            end if;
          end if;
          /* Цикл по месяцам года */
          for M in NMS .. NME
          loop
            SPERIODNAME := '_' || TO_CHAR(Y) || '_' || TO_CHAR(M);
            PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW   => RDG_ROW0,
                                             SNAME  => SPERIODNAME,
                                             SVALUE => 'план: ' || HOURS_STR(NHOURS => TRUNC(PKG_CONTVALLOC1S.GETN(RCONTAINER => YM,
                                                                                                                   SROWID     => SPERIODNAME || '_P'),
                                                                                             1)) || ' факт: ' ||
                                                       HOURS_STR(NHOURS => TRUNC(PKG_CONTVALLOC1S.GETN(RCONTAINER => YM,
                                                                                                       SROWID     => SPERIODNAME || '_F'),
                                                                                 1)));
          end loop;
        end loop;
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW0);
      end if;
      /* План для последней записи */
      if ((RDG_ROW.RCOLS is not null) and (NROWS = 0)) then
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW);
      end if;
      /* Факт для последней записи */
      if ((RDG_ROW2.RCOLS is not null) and (NROWS = 0)) then
        CR := PKG_CONTVALLOC1S.FIRST_(RCONTAINER => MCLR);
        for Z in 1 .. PKG_CONTVALLOC1S.COUNT_(RCONTAINER => MCLR)
        loop
          PKG_P8PANELS_VISUAL.TROW_ADD_COL(RROW   => RDG_ROW2,
                                           SNAME  => CR,
                                           SVALUE => PKG_CONTVALLOC1S.GETS(RCONTAINER => MCLR, SROWID => CR));
          CR := PKG_CONTVALLOC1S.NEXT_(RCONTAINER => MCLR, SROWID => CR);
        end loop;
        PKG_P8PANELS_VISUAL.TDATA_GRID_ADD_ROW(RDATA_GRID => RDG, RROW => RDG_ROW2);
      end if;
    end loop;
    /* Сериализуем описание */
    COUT := PKG_P8PANELS_VISUAL.TDATA_GRID_TO_XML(RDATA_GRID => RDG, NINCLUDE_DEF => 1);
    /* Очищаем контейнеры */
    PKG_CONTVALLOC1S.PURGE(RCONTAINER => YM);
    PKG_CONTVALLOC1S.PURGE(RCONTAINER => MCLR);
    PKG_CONTVALLOC1S.PURGE(RCONTAINER => GF);
    PKG_CONTVALLOC1S.PURGE(RCONTAINER => COLS);
  end EQUIPSRV_GRID;
 
end PKG_P8PANELS_EQUIPSRV;
/

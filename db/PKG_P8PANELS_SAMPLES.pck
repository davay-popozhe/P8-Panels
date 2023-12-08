create or replace package PKG_P8PANELS_SAMPLES as

  /* Получение списка контрагентов */
  procedure AGNLIST_GET
  (
    COUT                    out clob    -- Список контрагентов
  );

  /* Добавление контрагента */
  procedure AGNLIST_INSERT
  (
    SAGNABBR                in varchar2, -- Мнемокод
    SAGNNAME                in varchar2, -- Наименование
    NRN                     out number   -- Рег. номер добавленного
  );

  /* Удаление контрагента */
  procedure AGNLIST_DELETE
  (
    NRN                     in number   -- Рег. номер удаляемого
  );

end PKG_P8PANELS_SAMPLES;
/
create or replace package body PKG_P8PANELS_SAMPLES as

  /* Получение списка контрагентов */
  procedure AGNLIST_GET
  (
    COUT                    out clob      -- Список контрагентов
  )
  is
    NVERSION                PKG_STD.TREF; -- Рег. номер версии словаря контрагентов
  begin
    NVERSION := GET_SESSION_VERSION(SUNITCODE => 'AGNLIST');
    PKG_XFAST.PROLOGUE(ITYPE => PKG_XFAST.CONTENT_);
    PKG_XFAST.DOWN_NODE(SNAME => 'DATA');
    for C in (select D.*
                from (select T.RN      NRN,
                             T.AGNABBR SAGNABBR,
                             T.AGNNAME SAGNNAME
                        from AGNLIST T
                       where T.VERSION = NVERSION
                         and exists (select /*+ INDEX(UP I_USERPRIV_CATALOG_ROLEID) */
                               null
                                from USERPRIV UP
                               where UP.CATALOG = T.CRN
                                 and UP.ROLEID in (select /*+ INDEX(UR I_USERROLES_AUTHID_FK) */
                                                    UR.ROLEID
                                                     from USERROLES UR
                                                    where UR.AUTHID = UTILIZER)
                              union all
                              select /*+ INDEX(UP I_USERPRIV_CATALOG_AUTHID) */
                               null
                                from USERPRIV UP
                               where UP.CATALOG = T.CRN
                                 and UP.AUTHID = UTILIZER)
                       order by T.RN desc) D
               where ROWNUM <= 10)
    loop
      PKG_XFAST.DOWN_NODE(SNAME => 'AGENTS');
      PKG_XFAST.ATTR(SNAME => 'NRN', NVALUE => C.NRN);
      PKG_XFAST.ATTR(SNAME => 'SAGNABBR', SVALUE => C.SAGNABBR);
      PKG_XFAST.ATTR(SNAME => 'SAGNNAME', SVALUE => C.SAGNNAME);
      PKG_XFAST.UP();
    end loop;
    PKG_XFAST.UP();
    COUT := PKG_XFAST.SERIALIZE_TO_CLOB();
    PKG_XFAST.EPILOGUE();
  end AGNLIST_GET;

  /* Добавление контрагента */
  procedure AGNLIST_INSERT
  (
    SAGNABBR                in varchar2,                           -- Мнемокод
    SAGNNAME                in varchar2,                           -- Наименование
    NRN                     out number                             -- Рег. номер добавленного
  )
  is
    NCOMPANY                PKG_STD.TREF := GET_SESSION_COMPANY(); -- Текущая организация
    NCRN                    PKG_STD.TREF;                          -- Каталог размещения контрагента
  begin
    if (SAGNABBR is null) then
      P_EXCEPTION(0, 'Не указан мнемокод.');
    end if;
    if (SAGNABBR is null) then
      P_EXCEPTION(0, 'Не указано наименование.');
    end if;
    FIND_ROOT_CATALOG(NCOMPANY => NCOMPANY, SCODE => 'AGNLIST', NCRN => NCRN);
    P_AGNLIST_INSERT(NCOMPANY          => NCOMPANY,
                     CRN               => NCRN,
                     AGNABBR           => SAGNABBR,
                     AGNTYPE           => 0,
                     AGNNAME           => SAGNNAME,
                     AGNIDNUMB         => null,
                     ECONCODE          => null,
                     ORGCODE           => null,
                     AGNFAMILYNAME     => null,
                     AGNFIRSTNAME      => null,
                     AGNLASTNAME       => null,
                     AGNFAMILYNAME_TO  => null,
                     AGNFIRSTNAME_TO   => null,
                     AGNLASTNAME_TO    => null,
                     AGNFAMILYNAME_FR  => null,
                     AGNFIRSTNAME_FR   => null,
                     AGNLASTNAME_FR    => null,
                     AGNFAMILYNAME_AC  => null,
                     AGNFIRSTNAME_AC   => null,
                     AGNLASTNAME_AC    => null,
                     AGNFAMILYNAME_ABL => null,
                     AGNFIRSTNAME_ABL  => null,
                     AGNLASTNAME_ABL   => null,
                     EMP               => 0,
                     EMPPOST           => null,
                     EMPPOST_FROM      => null,
                     EMPPOST_TO        => null,
                     EMPPOST_AC        => null,
                     EMPPOST_ABL       => null,
                     AGNBURN           => null,
                     PHONE             => null,
                     PHONE2            => null,
                     FAX               => null,
                     TELEX             => null,
                     MAIL              => null,
                     IMAGE             => null,
                     DDISCDATE         => null,
                     AGN_COMMENT       => null,
                     NSEX              => 0,
                     SPENSION_NBR      => null,
                     SMEDPOLICY_SER    => null,
                     SMEDPOLICY_NUMB   => null,
                     SPROPFORM         => null,
                     SREASON_CODE      => null,
                     NRESIDENT_SIGN    => 0,
                     STAXPSTATUS       => null,
                     SOGRN             => null,
                     SPRFMLSTS         => null,
                     SPRNATION         => null,
                     SCITIZENSHIP      => null,
                     ADDR_BURN         => null,
                     SPRMLREL          => null,
                     SOKATO            => null,
                     SPFR_NAME         => null,
                     DPFR_FILL_DATE    => null,
                     DPFR_REG_DATE     => null,
                     SPFR_REG_NUMB     => null,
                     SFULLNAME         => null,
                     SOKFS             => null,
                     SOKOPF            => null,
                     STFOMS            => null,
                     SFSS_REG_NUMB     => null,
                     SFSS_SUBCODE      => null,
                     NCOEFFIC          => 0,
                     DAGNDEATH         => null,
                     NOLD_RN           => null,
                     SOKTMO            => null,
                     SINN_CITIZENSHIP  => null,
                     DTAX_REG_DATE     => null,
                     SORIGINAL_NAME    => null,
                     NIND_BUSINESSMAN  => 0,
                     SFNS_CODE         => null,
                     SCTZNSHP_TYPE     => null,
                     NCONTACT_METHOD   => null,
                     SMF_ID            => null,
                     SOKOGU            => null,
                     NRN               => NRN);
  end AGNLIST_INSERT;

  /* Удаление контрагента */
  procedure AGNLIST_DELETE
  (
    NRN                     in number   -- Рег. номер удаляемого
  )
  is
  begin
    P_AGNLIST_DELETE(NCOMPANY => GET_SESSION_COMPANY(), RN => NRN);
  end AGNLIST_DELETE;

end PKG_P8PANELS_SAMPLES;
/

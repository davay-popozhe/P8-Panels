create or replace procedure UDO_P_P8PANELS_TEST
(
  NRN in number,
  DDATE in date,
  CFILTERS in clob,
  CORDERS in clob,
  NRES out number,
  SRES out varchar2,
  COUT out clob,
  DD out date
)
is
begin
  NRES:=NRN*2;
  --DBMS_LOCK.SLEEP(3);
  if (DDATE is not null) then p_exception(0, to_char(ddate, 'dd.mm.yyyy hh24:mi:ss')); end if;
  SRES:='Очень хорошая погода';
  COUT:='Просто текст';
  --COUT:='<DATA><XROWS><COL1>333</COL1><COL2>444</COL2></XROWS><EXTRA>123</EXTRA><MORE>dfgsfg</MORE></DATA>';
  --COUT:='<DATA><XOUT_ARGUMENTS><SNAME>333</SNAME><VALUE>444</VALUE></XOUT_ARGUMENTS><XOUT_ARGUMENTS><SNAME>qqq</SNAME><VALUE>555</VALUE></XOUT_ARGUMENTS><XOUT_ARGUMENTS><SNAME>qsvfvr</SNAME><VALUE>432</VALUE></XOUT_ARGUMENTS><EXTRA>123</EXTRA><MORE>dfgsfg</MORE></DATA>';
  DD := DDATE;
end;
/

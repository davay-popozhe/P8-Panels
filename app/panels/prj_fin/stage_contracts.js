/*
    Парус 8 - Панели мониторинга - ПУП - Экономика проектов
    Панель мониторинга: Договоры с соисполнителями этапа проекта
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useCallback, useEffect, useContext } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Box, Stack, Grid, Paper, Table, TableBody, TableRow, TableCell, Typography, Button, Link, Icon } from "@mui/material"; //Интерфейсные компоненты
import { hasValue, formatDateRF, formatNumberRFCurrency, object2Base64XML } from "../../core/utils"; //Вспомогательные процедуры и функции
import { TEXTS } from "../../../app.text"; //Тектовые ресурсы и константы
import { P8PDataGrid, P8P_DATA_GRID_SIZE, P8P_DATA_GRID_FILTER_SHAPE } from "../../components/p8p_data_grid"; //Таблица данных
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { ApplicationСtx } from "../../context/application"; //Контекст приложения
import { MessagingСtx } from "../../context/messaging"; //Контекст сообщений
import { P8P_DATA_GRID_CONFIG_PROPS } from "../../config_wrapper"; //Подключение компонентов к настройкам приложения

//-----------------------
//Вспомогательные функции
//-----------------------

//Формирование значения для контрольных колонок
const formatCtrlValue = (value, addText = false) => {
    if (hasValue(value)) {
        const [text, icon, color] = value == 0 ? ["В норме", "done", "green"] : ["Требует внимания", "error", "red"];
        return (
            <Stack direction="row" gap={0.5} alignItems="center" justifyContent="center">
                <Icon title={text} sx={{ color }}>
                    {icon}
                </Icon>
                {addText == true ? text : null}
            </Stack>
        );
    } else return value;
};

//Форматирование значений колонок
const valueFormatter = ({ value, columnDef }) => {
    switch (columnDef.name) {
        case "DDOC_DATE":
        case "DCSTAGE_BEGIN_DATE":
        case "DCSTAGE_END_DATE":
            return formatDateRF(value);
        case "NCTRL_FIN":
            return formatCtrlValue(value, true);
    }
    return value;
};

//Генерация представления ячейки c данными
const dataCellRender = ({ row, columnDef }, pOnlineShowDocument) => {
    switch (columnDef.name) {
        case "SDOC_PREF":
        case "SDOC_NUMB":
            return {
                data: (
                    <Link
                        component="button"
                        variant="body2"
                        align="left"
                        underline="hover"
                        onClick={() =>
                            pOnlineShowDocument({
                                unitCode: row[`SLNK_UNIT_${columnDef.name}`],
                                document: row[`NLNK_DOCUMENT_${columnDef.name}`]
                            })
                        }
                    >
                        {row[columnDef.name]}
                    </Link>
                )
            };
        case "NCTRL_FIN":
            return {
                data: (
                    <Stack sx={{ justifyContent: "right" }} direction="row" spacing={1}>
                        {row[columnDef.name] === 1 ? (
                            <div style={{ color: "red", display: "flex", alignItems: "center" }} title="Счетов к оплате">
                                {formatNumberRFCurrency(row["NPAY_IN_REST"])}
                            </div>
                        ) : null}
                        {formatCtrlValue(row[columnDef.name], false)}
                    </Stack>
                )
            };
    }
};

//Генерация представления расширения строки
const rowExpandRender = ({ columnsDef, row }, pOnlineShowDocument, showStageContractPaymentAccountsIn, showStageContractPayNotes) => {
    const cardColumns = columnsDef.filter(
        columnDef =>
            columnDef.visible == false &&
            columnDef.name != "NRN" &&
            !columnDef.name.startsWith("SLNK_UNIT_") &&
            !columnDef.name.startsWith("NLNK_DOCUMENT_") &&
            hasValue(row[columnDef.name])
    );
    const formatColumnValue = (name, value) =>
        name.startsWith("N") ? formatNumberRFCurrency(value) : name.startsWith("D") ? formatDateRF(value) : value;
    return (
        <Box p={2}>
            <Grid container spacing={2}>
                <Grid item xs={12} md={1}>
                    <Stack spacing={2}>
                        <Button
                            fullWidth
                            variant="contained"
                            onClick={() => pOnlineShowDocument({ unitCode: row.SLNK_UNIT_SDOC_PREF, document: row.NLNK_DOCUMENT_SDOC_PREF })}
                        >
                            <nobr>В раздел</nobr>
                        </Button>
                    </Stack>
                </Grid>
                <Grid item xs={12} md={11}>
                    <Paper elevation={5}>
                        <Table sx={{ width: "100%" }} size="small">
                            <TableBody>
                                {cardColumns.map((cardColumn, i) => (
                                    <TableRow key={i}>
                                        <TableCell sx={{ width: "1px", whiteSpace: "nowrap" }}>
                                            <Typography variant="h6" color="primary" noWrap>
                                                {cardColumn.caption}:
                                            </Typography>
                                        </TableCell>
                                        <TableCell sx={{ paddingLeft: 0 }}>
                                            {(hasValue(row[`SLNK_UNIT_${cardColumn.name}`]) && hasValue(row[`NLNK_DOCUMENT_${cardColumn.name}`])) ||
                                            ["NPAY_IN", "NFIN_OUT"].includes(cardColumn.name) ? (
                                                <Link
                                                    component="button"
                                                    variant="body2"
                                                    align="left"
                                                    underline="always"
                                                    onClick={() =>
                                                        cardColumn.name === "NPAY_IN"
                                                            ? showStageContractPaymentAccountsIn(row.NRN)
                                                            : cardColumn.name === "NFIN_OUT"
                                                            ? showStageContractPayNotes(row.NRN)
                                                            : pOnlineShowDocument({
                                                                  unitCode: row[`SLNK_UNIT_${cardColumn.name}`],
                                                                  document: row[`NLNK_DOCUMENT_${cardColumn.name}`]
                                                              })
                                                    }
                                                >
                                                    <Typography variant="h6" color="text.secondary">
                                                        {formatColumnValue(cardColumn.name, row[cardColumn.name])}
                                                    </Typography>
                                                </Link>
                                            ) : (
                                                <Typography variant="h6" color="text.secondary">
                                                    {formatColumnValue(cardColumn.name, row[cardColumn.name])}
                                                </Typography>
                                            )}
                                        </TableCell>
                                    </TableRow>
                                ))}
                            </TableBody>
                        </Table>
                    </Paper>
                </Grid>
            </Grid>
        </Box>
    );
};

//-----------
//Тело модуля
//-----------

//Договоры с соисполнителями этапа проекта
const StageContracts = ({ stage, filters }) => {
    //Собственное состояние
    const [stageContractsDataGrid, setStageContractsDataGrid] = useState({
        dataLoaded: false,
        columnsDef: [],
        filters: [...filters],
        orders: null,
        rows: [],
        reload: true,
        pageNumber: 1,
        morePages: true
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored, SERV_DATA_TYPE_CLOB } = useContext(BackEndСtx);

    //Подключение к контексту приложения
    const { pOnlineShowDocument, pOnlineShowUnit, configSystemPageSize } = useContext(ApplicationСtx);

    //Подключение к контексту сообщений
    const { showMsgErr } = useContext(MessagingСtx);

    //Загрузка данных этапов с сервера
    const loadStageContracts = useCallback(async () => {
        if (stageContractsDataGrid.reload) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_PROJECTS.STAGE_CONTRACTS_LIST",
                args: {
                    NSTAGE: stage,
                    CFILTERS: {
                        VALUE: object2Base64XML(stageContractsDataGrid.filters, { arrayNodeName: "filters" }),
                        SDATA_TYPE: SERV_DATA_TYPE_CLOB
                    },
                    CORDERS: { VALUE: object2Base64XML(stageContractsDataGrid.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    NPAGE_NUMBER: stageContractsDataGrid.pageNumber,
                    NPAGE_SIZE: configSystemPageSize,
                    NINCLUDE_DEF: stageContractsDataGrid.dataLoaded ? 0 : 1
                },
                respArg: "COUT"
            });
            setStageContractsDataGrid(pv => ({
                ...pv,
                columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                rows: pv.pageNumber == 1 ? [...(data.XROWS || [])] : [...pv.rows, ...(data.XROWS || [])],
                dataLoaded: true,
                reload: false,
                morePages: (data.XROWS || []).length >= configSystemPageSize
            }));
        }
    }, [
        stage,
        stageContractsDataGrid.reload,
        stageContractsDataGrid.filters,
        stageContractsDataGrid.orders,
        stageContractsDataGrid.dataLoaded,
        stageContractsDataGrid.pageNumber,
        executeStored,
        configSystemPageSize,
        SERV_DATA_TYPE_CLOB
    ]);

    //Отображение выходящих счетов на оплату от соисполнителя этапа
    const showStageContractPaymentAccountsIn = async contract => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_PROJECTS.STAGE_CONTRACTS_SELECT_PAY_IN",
            args: { NPROJECTSTAGEPF: contract }
        });
        if (data.NIDENT) pOnlineShowUnit({ unitCode: "PaymentAccountsIn", inputParameters: [{ name: "in_SelectList_Ident", value: data.NIDENT }] });
        else showMsgErr(TEXTS.NO_DATA_FOUND);
    };

    //Отображение фактических платежей соисполнителю этапа
    const showStageContractPayNotes = async contract => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_PROJECTS.STAGE_CONTRACTS_SELECT_FIN_OUT",
            args: { NPROJECTSTAGEPF: contract }
        });
        if (data.NIDENT) pOnlineShowUnit({ unitCode: "PayNotes", inputParameters: [{ name: "in_SelectList_Ident", value: data.NIDENT }] });
        else showMsgErr(TEXTS.NO_DATA_FOUND);
    };

    //При изменении состояния фильтра
    const handleFilterChanged = ({ filters }) => setStageContractsDataGrid(pv => ({ ...pv, filters, pageNumber: 1, reload: true }));

    //При изменении состояния сортировки
    const handleOrderChanged = ({ orders }) => setStageContractsDataGrid(pv => ({ ...pv, orders, pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц
    const handlePagesCountChanged = () => setStageContractsDataGrid(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //При необходимости обновить данные
    useEffect(() => {
        loadStageContracts();
    }, [stageContractsDataGrid.reload, loadStageContracts]);

    //Генерация содержимого
    return (
        <Box pt={2}>
            {stageContractsDataGrid.dataLoaded ? (
                <P8PDataGrid
                    {...P8P_DATA_GRID_CONFIG_PROPS}
                    columnsDef={stageContractsDataGrid.columnsDef}
                    filtersInitial={filters}
                    rows={stageContractsDataGrid.rows}
                    size={P8P_DATA_GRID_SIZE.SMALL}
                    morePages={stageContractsDataGrid.morePages}
                    reloading={stageContractsDataGrid.reload}
                    expandable={true}
                    dataCellRender={prms => dataCellRender(prms, pOnlineShowDocument)}
                    rowExpandRender={prms =>
                        rowExpandRender(prms, pOnlineShowDocument, showStageContractPaymentAccountsIn, showStageContractPayNotes)
                    }
                    valueFormatter={valueFormatter}
                    onOrderChanged={handleOrderChanged}
                    onFilterChanged={handleFilterChanged}
                    onPagesCountChanged={handlePagesCountChanged}
                />
            ) : null}
        </Box>
    );
};

//Контроль свойств - Договоры с соисполнителями этапа проекта
StageContracts.propTypes = {
    stage: PropTypes.number.isRequired,
    filters: PropTypes.arrayOf(P8P_DATA_GRID_FILTER_SHAPE)
};

//----------------
//Интерфейс модуля
//----------------

export { StageContracts };

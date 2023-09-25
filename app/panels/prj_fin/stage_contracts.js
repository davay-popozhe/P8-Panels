/*
    Парус 8 - Панели мониторинга - ПУП - Экономика проектов
    Панель мониторинга: Договоры с соисполнителями этапа проекта
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useCallback, useEffect, useContext } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Box, Stack, Grid, Paper, Table, TableBody, TableRow, TableCell, Typography, Button, Link } from "@mui/material"; //Интерфейсные компоненты
import { deepCopyObject, hasValue, formatDateRF, formatNumberRFCurrency, object2Base64XML } from "../../core/utils"; //Вспомогательные процедуры и функции
import { BUTTONS, TEXTS, INPUTS } from "../../../app.text"; //Тектовые ресурсы и константы
import { P8PDataGrid, P8P_DATA_GRID_SIZE, P8P_DATA_GRID_FILTER_SHAPE } from "../../components/p8p_data_grid"; //Таблица данных
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { ApplicationСtx } from "../../context/application"; //Контекст приложения

//-----------------------
//Вспомогательные функции
//-----------------------

//Количество записей на странице
const PAGE_SIZE = 50;

//Форматирование значений колонок
const valueFormatter = ({ value, columnDef }) => {
    switch (columnDef.name) {
        case "DDOC_DATE":
        case "DCSTAGE_BEGIN_DATE":
        case "DCSTAGE_END_DATE":
            return formatDateRF(value);
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
    }
};

//Генерация представления расширения строки
const rowExpandRender = ({ columnsDef, row }, pOnlineShowDocument) => {
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
                                            {hasValue(row[`SLNK_UNIT_${cardColumn.name}`]) && hasValue(row[`NLNK_DOCUMENT_${cardColumn.name}`]) ? (
                                                <Link
                                                    component="button"
                                                    variant="body2"
                                                    align="left"
                                                    underline="always"
                                                    onClick={() =>
                                                        pOnlineShowDocument({
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
    const { pOnlineShowDocument } = useContext(ApplicationСtx);

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
                    NPAGE_SIZE: PAGE_SIZE,
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
                morePages: (data.XROWS || []).length >= PAGE_SIZE
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
        SERV_DATA_TYPE_CLOB
    ]);

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
                    columnsDef={stageContractsDataGrid.columnsDef}
                    filtersInitial={filters}
                    rows={stageContractsDataGrid.rows}
                    size={P8P_DATA_GRID_SIZE.SMALL}
                    morePages={stageContractsDataGrid.morePages}
                    reloading={stageContractsDataGrid.reload}
                    expandable={true}
                    orderAscMenuItemCaption={BUTTONS.ORDER_ASC}
                    orderDescMenuItemCaption={BUTTONS.ORDER_DESC}
                    filterMenuItemCaption={BUTTONS.FILTER}
                    valueFilterCaption={INPUTS.VALUE}
                    valueFromFilterCaption={INPUTS.VALUE_FROM}
                    valueToFilterCaption={INPUTS.VALUE_TO}
                    okFilterBtnCaption={BUTTONS.OK}
                    clearFilterBtnCaption={BUTTONS.CLEAR}
                    cancelFilterBtnCaption={BUTTONS.CANCEL}
                    morePagesBtnCaption={BUTTONS.MORE}
                    noDataFoundText={TEXTS.NO_DATA_FOUND}
                    dataCellRender={prms => dataCellRender(prms, pOnlineShowDocument)}
                    rowExpandRender={prms => rowExpandRender(prms, pOnlineShowDocument)}
                    valueFormatter={valueFormatter}
                    onOrderChanged={handleOrderChanged}
                    onFilterChanged={handleFilterChanged}
                    onPagesCountChanged={handlePagesCountChanged}
                    objectsCopier={deepCopyObject}
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

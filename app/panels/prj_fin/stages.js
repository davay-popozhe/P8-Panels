/*
    Парус 8 - Панели мониторинга - ПУП - Экономика проектов
    Панель мониторинга: Список этапов проекта
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useCallback, useEffect, useContext } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Box, Icon, Stack, Grid, Paper, Table, TableBody, TableRow, TableCell, Typography, Button, IconButton, Link } from "@mui/material"; //Интерфейсные компоненты
import { hasValue, formatDateRF, formatNumberRFCurrency, object2Base64XML } from "../../core/utils"; //Вспомогательные процедуры и функции
import { BUTTONS, TEXTS, INPUTS } from "../../../app.text"; //Тектовые ресурсы и константы
import { P8PDataGrid, P8P_DATA_GRID_SIZE, P8P_DATA_GRID_FILTER_SHAPE } from "../../components/p8p_data_grid"; //Таблица данных
import { P8PFullScreenDialog } from "../../components/p8p_fullscreen_dialog"; //Полноэкранный диалог
import { StageArts } from "./stage_arts"; //Калькуляция этапа проекта
import { StageContracts } from "./stage_contracts"; //Договоры с соисполнителями этапа проекта
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { ApplicationСtx } from "../../context/application"; //Контекст приложения
import { MessagingСtx } from "../../context/messaging"; //Контекст сообщений

//-----------------------
//Вспомогательные функции
//-----------------------

//Количество записей на странице
const PAGE_SIZE = 50;

//Формирование значения для колонки "Состояние"
const formatStageStatusValue = (value, addText = false) => {
    const [text, icon] =
        value == 0
            ? ["Зарегистрирован", "app_registration"]
            : value == 1
            ? ["Открыт", "lock_open"]
            : value == 2
            ? ["Закрыт", "lock_outline"]
            : value == 3
            ? ["Согласован", "thumb_up_alt"]
            : value == 4
            ? ["Исполнение прекращено", "block"]
            : ["Остановлен", "do_not_disturb_on"];
    return (
        <Stack direction="row" gap={0.5} alignItems="center" justifyContent="center">
            <Icon title={text}>{icon}</Icon>
            {addText == true ? text : null}
        </Stack>
    );
};

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
        case "NSTATE":
            return formatStageStatusValue(value, true);
        case "DBEGPLAN":
        case "DENDPLAN":
            return formatDateRF(value);
        case "NCTRL_FIN":
        case "NCTRL_CONTR":
        case "NCTRL_COEXEC":
        case "NCTRL_PERIOD":
        case "NCTRL_COST":
        case "NCTRL_ACT":
            return formatCtrlValue(value, true);
    }
    return value;
};

//Генерация представления ячейки заголовка
const headCellRender = ({ columnDef }) => {
    switch (columnDef.name) {
        case "NSTATE":
        case "NCTRL_FIN":
        case "NCTRL_CONTR":
        case "NCTRL_COEXEC":
        case "NCTRL_COST":
        case "NCTRL_ACT":
            return {
                stackProps: { justifyContent: "center" },
                cellProps: { align: "center" }
            };
    }
};

//Генерация представления ячейки c данными
const dataCellRender = ({ row, columnDef }, showStageArts) => {
    switch (columnDef.name) {
        case "NSTATE":
            return {
                cellProps: { align: "center" },
                data: formatStageStatusValue(row[columnDef.name], false)
            };
        case "NCTRL_FIN":
        case "NCTRL_COEXEC":
        case "NCTRL_ACT":
            return {
                cellProps: { align: "center" },
                data: formatCtrlValue(row[columnDef.name], false)
            };
        case "NCTRL_CONTR":
        case "NCTRL_COST":
            return {
                cellProps: { align: "center" },
                data: hasValue(row[columnDef.name]) ? (
                    <IconButton
                        onClick={() =>
                            showStageArts({ stage: row.NRN, stageNumb: row.SNUMB, filters: [{ name: columnDef.name, from: row[columnDef.name] }] })
                        }
                    >
                        {formatCtrlValue(row[columnDef.name], false)}
                    </IconButton>
                ) : null
            };
        case "NCTRL_PERIOD":
            return {
                cellProps: { align: "right" },
                data: hasValue(row[columnDef.name]) ? (
                    <Stack sx={{ justifyContent: "right" }} direction="row" spacing={1}>
                        <div style={{ color: row[columnDef.name] === 1 ? "red" : "green", display: "flex", alignItems: "center" }}>
                            {row.NDAYS_LEFT} дн.
                        </div>
                        {formatCtrlValue(row[columnDef.name], false)}
                    </Stack>
                ) : null
            };
    }
};

//Генерация представления расширения строки
const rowExpandRender = ({ columnsDef, row }, pOnlineShowDocument, showStageArts, showStageContracts, showStagePayNotes, showStageCostNotes) => {
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
                        <Button fullWidth variant="contained" onClick={() => showStageArts({ stage: row.NRN, stageNumb: row.SNUMB })}>
                            <nobr>Статьи</nobr>
                        </Button>
                        <Button fullWidth variant="contained" onClick={() => showStageContracts({ stage: row.NRN, stageNumb: row.SNUMB })}>
                            <nobr>Сисполнители</nobr>
                        </Button>
                        <Button fullWidth variant="contained" onClick={() => pOnlineShowDocument({ unitCode: "ProjectsStages", document: row.NRN })}>
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
                                            <Typography variant="h6" color="primary">
                                                {cardColumn.caption}:&nbsp;
                                            </Typography>
                                        </TableCell>
                                        <TableCell sx={{ paddingLeft: 0 }}>
                                            {hasValue(row[`SLNK_UNIT_${cardColumn.name}`]) && hasValue(row[`NLNK_DOCUMENT_${cardColumn.name}`]) ? (
                                                <Link
                                                    component="button"
                                                    variant="body2"
                                                    align="left"
                                                    underline="always"
                                                    onClick={() => {
                                                        if (["NFIN_IN", "NFIN_OUT"].includes(cardColumn.name))
                                                            showStagePayNotes(row.NRN, row[`NLNK_DOCUMENT_${cardColumn.name}`]);
                                                        else if (cardColumn.name == "NCOST_FACT") showStageCostNotes(row.NRN);
                                                        else
                                                            pOnlineShowDocument({
                                                                unitCode: row[`SLNK_UNIT_${cardColumn.name}`],
                                                                document: row[`NLNK_DOCUMENT_${cardColumn.name}`]
                                                            });
                                                    }}
                                                >
                                                    <Typography variant="h6" color="text.secondary">
                                                        {formatColumnValue(cardColumn.name, row[cardColumn.name])}
                                                    </Typography>
                                                </Link>
                                            ) : (
                                                <Typography variant="h6" color="text.secondary">
                                                    {["NDAYS_LEFT", "NINCOME_PRC"].includes(cardColumn.name)
                                                        ? row[cardColumn.name]
                                                        : formatColumnValue(cardColumn.name, row[cardColumn.name])}
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

//Список этапов проекта
const Stages = ({ project, projectName, filters }) => {
    //Собственное состояние
    const [stagesDataGrid, setStagesDataGrid] = useState({
        dataLoaded: false,
        columnsDef: [],
        filters: [...filters],
        orders: null,
        rows: [],
        reload: true,
        pageNumber: 1,
        morePages: true,
        selectedStageNumb: null,
        showStageArts: null,
        stageArtsFilters: [],
        showStageContracts: null,
        stageContractsFilters: []
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored, SERV_DATA_TYPE_CLOB } = useContext(BackEndСtx);

    //Подключение к контексту приложения
    const { pOnlineShowDocument, pOnlineShowUnit } = useContext(ApplicationСtx);

    //Подключение к контексту сообщений
    const { showMsgErr } = useContext(MessagingСtx);

    //Загрузка данных этапов с сервера
    const loadStages = useCallback(async () => {
        if (stagesDataGrid.reload) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_PROJECTS.STAGES_LIST",
                args: {
                    NPRN: project,
                    CFILTERS: { VALUE: object2Base64XML(stagesDataGrid.filters, { arrayNodeName: "filters" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    CORDERS: { VALUE: object2Base64XML(stagesDataGrid.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    NPAGE_NUMBER: stagesDataGrid.pageNumber,
                    NPAGE_SIZE: PAGE_SIZE,
                    NINCLUDE_DEF: stagesDataGrid.dataLoaded ? 0 : 1
                },
                respArg: "COUT"
            });
            setStagesDataGrid(pv => ({
                ...pv,
                columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                rows: pv.pageNumber == 1 ? [...(data.XROWS || [])] : [...pv.rows, ...(data.XROWS || [])],
                dataLoaded: true,
                reload: false,
                morePages: (data.XROWS || []).length >= PAGE_SIZE
            }));
        }
    }, [
        project,
        stagesDataGrid.reload,
        stagesDataGrid.filters,
        stagesDataGrid.orders,
        stagesDataGrid.dataLoaded,
        stagesDataGrid.pageNumber,
        executeStored,
        SERV_DATA_TYPE_CLOB
    ]);

    //Отображение журнала платежей по этапу проекта
    const showStagePayNotes = async (stage, direction) => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_PROJECTS.STAGES_SELECT_FIN",
            args: { NRN: stage, NDIRECTION: direction }
        });
        if (data.NIDENT) pOnlineShowUnit({ unitCode: "PayNotes", inputParameters: [{ name: "in_SelectList_Ident", value: data.NIDENT }] });
        else showMsgErr(TEXTS.NO_DATA_FOUND);
    };

    //Отображение журнала затрат по этапу проекта
    const showStageCostNotes = async stage => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_PROJECTS.STAGES_SELECT_COST_FACT",
            args: { NRN: stage }
        });
        if (data.NIDENT) pOnlineShowUnit({ unitCode: "CostNotes", inputParameters: [{ name: "in_SelectList_Ident", value: data.NIDENT }] });
        else showMsgErr(TEXTS.NO_DATA_FOUND);
    };

    //Отображение статей калькуляции по этапу проекта
    const showStageArts = ({ stage, stageNumb, filters = [] } = {}) => {
        setStagesDataGrid(pv => ({ ...pv, showStageArts: stage, selectedStageNumb: stageNumb, stageArtsFilters: [...filters] }));
    };

    //Отображение договоров с соисполнителями по этапу проекта
    const showStageContracts = ({ stage, stageNumb, filters = [] } = {}) => {
        setStagesDataGrid(pv => ({ ...pv, showStageContracts: stage, selectedStageNumb: stageNumb, stageContractsFilters: [...filters] }));
    };

    //При изменении состояния фильтра
    const handleFilterChanged = ({ filters }) => setStagesDataGrid(pv => ({ ...pv, filters, pageNumber: 1, reload: true }));

    //При изменении состояния сортировки
    const handleOrderChanged = ({ orders }) => setStagesDataGrid(pv => ({ ...pv, orders, pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц
    const handlePagesCountChanged = () => setStagesDataGrid(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //При закрытии списка договоров этапа
    const handleStageContractsClose = () => setStagesDataGrid(pv => ({ ...pv, showStageContracts: null, stageContractsFilters: [] }));

    //При закрытии калькуляции этапа
    const handleStageArtsClose = () => setStagesDataGrid(pv => ({ ...pv, showStageArts: null, stageArtsFilters: [] }));

    //При необходимости обновить данные
    useEffect(() => {
        loadStages();
    }, [stagesDataGrid.reload, loadStages]);

    //Генерация содержимого
    return (
        <Box pt={2}>
            {stagesDataGrid.dataLoaded ? (
                <P8PDataGrid
                    columnsDef={stagesDataGrid.columnsDef}
                    filtersInitial={filters}
                    rows={stagesDataGrid.rows}
                    size={P8P_DATA_GRID_SIZE.SMALL}
                    morePages={stagesDataGrid.morePages}
                    reloading={stagesDataGrid.reload}
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
                    headCellRender={headCellRender}
                    dataCellRender={prms => dataCellRender(prms, showStageArts)}
                    rowExpandRender={prms =>
                        rowExpandRender(prms, pOnlineShowDocument, showStageArts, showStageContracts, showStagePayNotes, showStageCostNotes)
                    }
                    valueFormatter={valueFormatter}
                    onOrderChanged={handleOrderChanged}
                    onFilterChanged={handleFilterChanged}
                    onPagesCountChanged={handlePagesCountChanged}
                />
            ) : null}
            {stagesDataGrid.showStageContracts ? (
                <P8PFullScreenDialog
                    title={`Договоры этапа "${stagesDataGrid.selectedStageNumb}" проекта "${projectName}"`}
                    onClose={handleStageContractsClose}
                >
                    <StageContracts stage={stagesDataGrid.showStageContracts} filters={stagesDataGrid.stageContractsFilters} />
                </P8PFullScreenDialog>
            ) : null}
            {stagesDataGrid.showStageArts ? (
                <P8PFullScreenDialog
                    title={`Калькуляция этапа "${stagesDataGrid.selectedStageNumb}" проекта "${projectName}"`}
                    onClose={handleStageArtsClose}
                >
                    <StageArts stage={stagesDataGrid.showStageArts} filters={stagesDataGrid.stageArtsFilters} />
                </P8PFullScreenDialog>
            ) : null}
        </Box>
    );
};

//Контроль свойств - Список этапов проекта
Stages.propTypes = {
    project: PropTypes.number.isRequired,
    projectName: PropTypes.string.isRequired,
    filters: PropTypes.arrayOf(P8P_DATA_GRID_FILTER_SHAPE)
};

//----------------
//Интерфейс модуля
//----------------

export { Stages };

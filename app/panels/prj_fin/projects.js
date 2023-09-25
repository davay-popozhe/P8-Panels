/*
    Парус 8 - Панели мониторинга - ПУП - Экономика проектов
    Панель мониторинга: Список проктов
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useCallback, useEffect, useContext } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Grid, Icon, Stack, Link, Button, Table, TableBody, TableRow, TableCell, Typography, Box, Paper, IconButton } from "@mui/material"; //Интерфейсные компоненты
import { deepCopyObject, hasValue, formatDateRF, formatNumberRFCurrency, object2Base64XML } from "../../core/utils"; //Вспомогательные процедуры и функции
import { BUTTONS, TEXTS, INPUTS } from "../../../app.text"; //Тектовые ресурсы и константы
import { P8PDataGrid, P8P_DATA_GRID_SIZE } from "../../components/p8p_data_grid"; //Таблица данных
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { ApplicationСtx } from "../../context/application"; //Контекст приложения
import { MessagingСtx } from "../../context/messaging"; //Контекст сообщений

//-----------------------
//Вспомогательные функции
//-----------------------

//Количество записей на странице
const PAGE_SIZE = 50;

//Формирование значения для колонки "Состояние проекта"
const formatPrjStateValue = (value, addText = false) => {
    const [text, icon] =
        value == 0
            ? ["Зарегистрирован", "app_registration"]
            : value == 1
            ? ["Открыт", "lock_open"]
            : value == 2
            ? ["Остановлен", "do_not_disturb_on"]
            : value == 3
            ? ["Закрыт", "lock_outline"]
            : value == 4
            ? ["Согласован", "thumb_up_alt"]
            : ["Исполнение прекращено", "block"];
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
            return formatPrjStateValue(value, true);
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
        case "NCTRL_PERIOD":
        case "NCTRL_COST":
        case "NCTRL_ACT":
            return {
                stackProps: { justifyContent: "center" },
                cellProps: { align: "center" }
            };
    }
};

//Генерация представления ячейки c данными
const dataCellRender = ({ row, columnDef }, handleStagesOpen) => {
    switch (columnDef.name) {
        case "SCODE":
        case "SNAME_USL":
            return {
                data: (
                    <Link component="button" variant="body2" align="left" underline="hover" onClick={() => handleStagesOpen({ project: row })}>
                        {row[columnDef.name]}
                    </Link>
                )
            };
        case "NSTATE":
            return {
                cellProps: { align: "center" },
                data: formatPrjStateValue(row[columnDef.name], false)
            };
        case "NCTRL_FIN":
        case "NCTRL_CONTR":
        case "NCTRL_COEXEC":
        case "NCTRL_PERIOD":
        case "NCTRL_COST":
        case "NCTRL_ACT":
            return {
                cellProps: { align: "center" },
                data: hasValue(row[columnDef.name]) ? (
                    <IconButton onClick={() => handleStagesOpen({ project: row, filters: [{ name: columnDef.name, from: row[columnDef.name] }] })}>
                        {formatCtrlValue(row[columnDef.name], false)}
                    </IconButton>
                ) : null
            };
    }
};

//Генерация представления расширения строки
const rowExpandRender = ({ columnsDef, row }, pOnlineShowDocument, showProjectPayNotes, handleStagesOpen) => {
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
                        <Button fullWidth variant="contained" onClick={() => handleStagesOpen({ project: row })}>
                            Этапы
                        </Button>
                        <Button fullWidth variant="contained" onClick={() => pOnlineShowDocument({ unitCode: "Projects", document: row.NRN })}>
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
                                                    onClick={() => {
                                                        if (["NFIN_IN", "NFIN_OUT"].includes(cardColumn.name))
                                                            showProjectPayNotes(row.NRN, row[`NLNK_DOCUMENT_${cardColumn.name}`]);
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

//Список проектов
const Projects = ({ onStagesOpen }) => {
    //Собственное состояние
    const [projectsDataGrid, setProjectsDataGrid] = useState({
        dataLoaded: false,
        columnsDef: [],
        filters: null,
        orders: null,
        rows: [],
        reload: true,
        pageNumber: 1,
        morePages: true
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored, SERV_DATA_TYPE_CLOB } = useContext(BackEndСtx);

    //Подключение к контексту приложения
    const { pOnlineShowDocument, pOnlineShowUnit } = useContext(ApplicationСtx);

    //Подключение к контексту сообщений
    const { showMsgErr } = useContext(MessagingСtx);

    //Загрузка данных проектов с сервера
    const loadProjects = useCallback(async () => {
        if (projectsDataGrid.reload) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_PROJECTS.LIST",
                args: {
                    CFILTERS: { VALUE: object2Base64XML(projectsDataGrid.filters, { arrayNodeName: "filters" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    CORDERS: { VALUE: object2Base64XML(projectsDataGrid.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    NPAGE_NUMBER: projectsDataGrid.pageNumber,
                    NPAGE_SIZE: PAGE_SIZE,
                    NINCLUDE_DEF: projectsDataGrid.dataLoaded ? 0 : 1
                },
                respArg: "COUT"
            });
            setProjectsDataGrid(pv => ({
                ...pv,
                columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                rows: pv.pageNumber == 1 ? [...(data.XROWS || [])] : [...pv.rows, ...(data.XROWS || [])],
                dataLoaded: true,
                reload: false,
                morePages: (data.XROWS || []).length >= PAGE_SIZE
            }));
        }
    }, [
        projectsDataGrid.reload,
        projectsDataGrid.filters,
        projectsDataGrid.orders,
        projectsDataGrid.dataLoaded,
        projectsDataGrid.pageNumber,
        executeStored,
        SERV_DATA_TYPE_CLOB
    ]);

    //Отображение журнала платежей по этапу проекта
    const showProjectPayNotes = async (project, direction) => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_PROJECTS.SELECT_FIN",
            args: { NRN: project, NDIRECTION: direction }
        });
        if (data.NIDENT) pOnlineShowUnit({ unitCode: "PayNotes", inputParameters: [{ name: "in_SelectList_Ident", value: data.NIDENT }] });
        else showMsgErr(TEXTS.NO_DATA_FOUND);
    };

    //При изменении состояния фильтра
    const handleFilterChanged = ({ filters }) => setProjectsDataGrid(pv => ({ ...pv, filters: [...filters], pageNumber: 1, reload: true }));

    //При изменении состояния сортировки
    const handleOrderChanged = ({ orders }) => setProjectsDataGrid(pv => ({ ...pv, orders: [...orders], pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц
    const handlePagesCountChanged = () => setProjectsDataGrid(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //При открытии списка этапов
    const handleStagesOpen = ({ project, filters }) => (onStagesOpen ? onStagesOpen({ project, filters }) : null);

    //При необходимости обновить данные
    useEffect(() => {
        loadProjects();
    }, [projectsDataGrid.reload, loadProjects]);

    //Генерация содержимого
    return (
        <>
            {projectsDataGrid.dataLoaded ? (
                <P8PDataGrid
                    columnsDef={projectsDataGrid.columnsDef}
                    rows={projectsDataGrid.rows}
                    size={P8P_DATA_GRID_SIZE.SMALL}
                    morePages={projectsDataGrid.morePages}
                    reloading={projectsDataGrid.reload}
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
                    dataCellRender={prms => dataCellRender(prms, handleStagesOpen)}
                    rowExpandRender={prms => rowExpandRender(prms, pOnlineShowDocument, showProjectPayNotes, handleStagesOpen)}
                    valueFormatter={valueFormatter}
                    onOrderChanged={handleOrderChanged}
                    onFilterChanged={handleFilterChanged}
                    onPagesCountChanged={handlePagesCountChanged}
                    objectsCopier={deepCopyObject}
                />
            ) : null}
        </>
    );
};

//Контроль свойств - Список проектов
Projects.propTypes = {
    onStagesOpen: PropTypes.func
};

//----------------
//Интерфейс модуля
//----------------

export { Projects };

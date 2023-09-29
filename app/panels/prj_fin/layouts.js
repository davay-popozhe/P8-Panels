/*
    Парус 8 - Панели мониторинга - ПУП - Экономика проектов
    Дополнительная разметка и вёрстка клиентских элементов
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import { Grid, Icon, Stack, Link, Button, Table, TableBody, TableRow, TableCell, Typography, Box, Paper, IconButton } from "@mui/material"; //Интерфейсные компоненты
import { hasValue, formatDateRF, formatNumberRFCurrency } from "../../core/utils"; //Вспомогательные процедуры и функции

//---------
//Константы
//---------

//Разделы панелей экономики проектов
export const PANEL_UNITS = {
    PROJECTS: "PROJECTS",
    PROJECT_STAGES: "PROJECT_STAGES",
    PROJECT_STAGE_CONTRACTS: "PROJECT_STAGE_CONTRACTS",
    PROJECT_STAGE_ARTS: "PROJECT_STAGE_ARTS"
};

//-----------
//Тело модуля
//-----------

//Формирование значения для колонки "Состояние" проекта
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

//Формирование значения для колонки "Состояние" этапа
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

//Подбор функции форматирования колонки "Состояние" по разделу панели
const getStatusFormatter = panelUnit => (panelUnit === PANEL_UNITS.PROJECTS ? formatPrjStateValue : formatStageStatusValue);

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
export const valueFormatter = ({ panelUnit, value, columnDef }) => {
    switch (columnDef.name) {
        case "NSTATE":
            return getStatusFormatter(panelUnit)(value, true);
        case "DBEGPLAN":
        case "DENDPLAN":
        case "DDOC_DATE":
        case "DCSTAGE_BEGIN_DATE":
        case "DCSTAGE_END_DATE":
            return formatDateRF(value);
        case "NPLAN":
        case "NCOST_FACT":
        case "NCONTR":
            return formatNumberRFCurrency(value);

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
export const headCellRender = ({ columnDef }) => {
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
export const dataCellRender = ({ panelUnit, row, columnDef, pOnlineShowDocument, showStages, showStageArts, showCostNotes, showContracts }) => {
    //Подбор функции на нажатие в ячейки контрольной колонки в зависимости от контекста
    const getCrlOnClick = () =>
        panelUnit == PANEL_UNITS.PROJECT_STAGES
            ? ["NCTRL_FIN", "NCTRL_COEXEC"].includes(columnDef.name)
                ? showContracts
                : showStageArts
            : showStages;
    //Подбор представления ячейки контрольной колонки в зависимости от контекста
    const renderCtl = () => ({
        cellProps: {
            align:
                (panelUnit == PANEL_UNITS.PROJECT_STAGES && columnDef.name == "NCTRL_PERIOD") ||
                (panelUnit == PANEL_UNITS.PROJECT_STAGE_CONTRACTS && columnDef.name == "NCTRL_FIN") ||
                (panelUnit == PANEL_UNITS.PROJECT_STAGE_ARTS && ["NCTRL_COST", "NCTRL_CONTR"].includes(columnDef.name))
                    ? "right"
                    : "center"
        },
        data: hasValue(row[columnDef.name]) ? (
            panelUnit == PANEL_UNITS.PROJECT_STAGES && columnDef.name == "NCTRL_PERIOD" ? (
                <Stack sx={{ justifyContent: "right" }} direction="row" spacing={1}>
                    <div style={{ color: row[columnDef.name] === 1 ? "red" : "green", display: "flex", alignItems: "center" }}>
                        {row.NDAYS_LEFT} дн.
                    </div>
                    {formatCtrlValue(row[columnDef.name], false)}
                </Stack>
            ) : panelUnit == PANEL_UNITS.PROJECT_STAGE_CONTRACTS && columnDef.name == "NCTRL_FIN" ? (
                <Stack sx={{ justifyContent: "right" }} direction="row" spacing={1}>
                    {row[columnDef.name] === 1 ? (
                        <div style={{ color: "red", display: "flex", alignItems: "center" }} title="Счетов к оплате">
                            {formatNumberRFCurrency(row["NPAY_IN_REST"])}
                        </div>
                    ) : null}
                    {formatCtrlValue(row[columnDef.name], false)}
                </Stack>
            ) : (panelUnit == PANEL_UNITS.PROJECT_STAGES && columnDef.name == "NCTRL_ACT") ||
              (panelUnit == PANEL_UNITS.PROJECT_STAGE_CONTRACTS && columnDef.name == "NCTRL_COEXEC") ? (
                formatCtrlValue(row[columnDef.name], false)
            ) : panelUnit == PANEL_UNITS.PROJECT_STAGE_ARTS && ["NCTRL_COST", "NCTRL_CONTR"].includes(columnDef.name) ? (
                <Stack sx={{ justifyContent: "right" }} direction="row" spacing={1}>
                    <div style={{ color: row[columnDef.name] === 1 ? "red" : "green", display: "flex", alignItems: "center" }}>
                        {formatNumberRFCurrency(row[columnDef.name === "NCTRL_COST" ? "NCOST_DIFF" : "NCONTR_LEFT"])}
                    </div>
                    {formatCtrlValue(row[columnDef.name], false)}
                </Stack>
            ) : (
                <IconButton onClick={() => getCrlOnClick()({ sender: row, filters: [{ name: columnDef.name, from: row[columnDef.name] }] })}>
                    {formatCtrlValue(row[columnDef.name], false)}
                </IconButton>
            )
        ) : null
    });
    //Формирование представлений
    switch (columnDef.name) {
        case "SCODE":
        case "SNAME_USL":
            return {
                data: (
                    <Link component="button" variant="body2" align="left" underline="hover" onClick={() => showStages({ sender: row })}>
                        {row[columnDef.name]}
                    </Link>
                )
            };
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
                            pOnlineShowDocument({ unitCode: row[`SLNK_UNIT_${columnDef.name}`], document: row[`NLNK_DOCUMENT_${columnDef.name}`] })
                        }
                    >
                        {row[columnDef.name]}
                    </Link>
                )
            };
        case "NCOST_FACT":
        case "NCONTR":
            return {
                data: row[columnDef.name] ? (
                    <Link
                        component="button"
                        variant="body2"
                        align="left"
                        underline="hover"
                        onClick={() => (columnDef.name === "NCOST_FACT" ? showCostNotes({ sender: row }) : showContracts({ sender: row }))}
                    >
                        {formatNumberRFCurrency(row[columnDef.name])}
                    </Link>
                ) : null
            };
        case "NSTATE":
            return {
                cellProps: { align: "center" },
                data: getStatusFormatter(panelUnit)(row[columnDef.name], false)
            };
        case "NCTRL_FIN":
        case "NCTRL_CONTR":
        case "NCTRL_COEXEC":
        case "NCTRL_PERIOD":
        case "NCTRL_COST":
        case "NCTRL_ACT":
            return renderCtl();
    }
};

//Генерация представления расширения строки
export const rowExpandRender = ({
    panelUnit,
    columnsDef,
    row,
    pOnlineShowDocument,
    showStages,
    showPayNotes,
    showCostNotes,
    showPaymentAccountsIn,
    showIncomingInvoices,
    showStageArts,
    showContracts
}) => {
    //Фильтруем системные атрибуты и атрибуты без значений
    const cardColumns = columnsDef.filter(
        columnDef =>
            columnDef.visible == false &&
            columnDef.name != "NRN" &&
            !columnDef.name.startsWith("SLNK_UNIT_") &&
            !columnDef.name.startsWith("NLNK_DOCUMENT_") &&
            hasValue(row[columnDef.name])
    );
    //Автоформатирование значения (N* - число, D* - дата, всё остальное - строка)
    const formatColumnValue = (name, value) =>
        name.startsWith("N") ? formatNumberRFCurrency(value) : name.startsWith("D") ? formatDateRF(value) : value;
    //Формирование кнопок переходов
    const linkButtons = () =>
        panelUnit === PANEL_UNITS.PROJECTS ? (
            <>
                <Button fullWidth variant="contained" onClick={() => showStages({ sender: row })}>
                    Этапы
                </Button>
                <Button fullWidth variant="contained" onClick={() => pOnlineShowDocument({ unitCode: "Projects", document: row.NRN })}>
                    В раздел
                </Button>
            </>
        ) : panelUnit === PANEL_UNITS.PROJECT_STAGES ? (
            <>
                <Button fullWidth variant="contained" onClick={() => showStageArts({ sender: row })}>
                    Статьи
                </Button>
                <Button fullWidth variant="contained" onClick={() => showContracts({ sender: row })}>
                    Сисполнители
                </Button>
                <Button fullWidth variant="contained" onClick={() => pOnlineShowDocument({ unitCode: "ProjectsStages", document: row.NRN })}>
                    В раздел
                </Button>
            </>
        ) : panelUnit === PANEL_UNITS.PROJECT_STAGE_CONTRACTS ? (
            <Button
                fullWidth
                variant="contained"
                onClick={() => pOnlineShowDocument({ unitCode: row.SLNK_UNIT_SDOC_PREF, document: row.NLNK_DOCUMENT_SDOC_PREF })}
            >
                В раздел
            </Button>
        ) : null;
    //Сборка содержимого
    return (
        <Box p={2}>
            <Grid container spacing={2}>
                <Grid item xs={12} md={1}>
                    <Stack spacing={2}>{linkButtons()}</Stack>
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
                                            ["NPAY_IN", "NFIN_OUT", "NCOEXEC_IN"].includes(cardColumn.name) ? (
                                                <Link
                                                    component="button"
                                                    variant="body2"
                                                    align="left"
                                                    underline="always"
                                                    onClick={() =>
                                                        ["NFIN_IN", "NFIN_OUT"].includes(cardColumn.name)
                                                            ? showPayNotes({ sender: row, direction: row[`NLNK_DOCUMENT_${cardColumn.name}`] })
                                                            : cardColumn.name == "NCOST_FACT"
                                                            ? showCostNotes({ sender: row })
                                                            : cardColumn.name == "NPAY_IN"
                                                            ? showPaymentAccountsIn({ sender: row })
                                                            : cardColumn.name == "NCOEXEC_IN"
                                                            ? showIncomingInvoices({ sender: row })
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

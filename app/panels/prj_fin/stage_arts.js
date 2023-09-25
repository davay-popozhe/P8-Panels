/*
    Парус 8 - Панели мониторинга - ПУП - Экономика проектов
    Панель мониторинга: Калькуляция этапа проекта
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useCallback, useEffect, useContext } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Box, Icon, Stack, Link } from "@mui/material"; //Интерфейсные компоненты
import { deepCopyObject, hasValue, formatNumberRFCurrency, object2Base64XML } from "../../core/utils"; //Вспомогательные процедуры и функции
import { BUTTONS, TEXTS, INPUTS } from "../../../app.text"; //Тектовые ресурсы и константы
import { P8PDataGrid, P8P_DATA_GRID_SIZE, P8P_DATA_GRID_FILTER_SHAPE } from "../../components/p8p_data_grid"; //Таблица данных
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { ApplicationСtx } from "../../context/application"; //Контекст приложения
import { MessagingСtx } from "../../context/messaging"; //Контекст сообщений

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
        case "NPLAN":
        case "NCOST_FACT":
        case "NCONTR":
            return formatNumberRFCurrency(value);
        case "NCTRL_COST":
        case "NCTRL_CONTR":
            return formatCtrlValue(value, true);
    }
    return value;
};

//Генерация представления ячейки c данными
const dataCellRender = ({ row, columnDef }, showStageArtCostNotes, showStageArtContracts) => {
    switch (columnDef.name) {
        case "NCOST_FACT":
        case "NCONTR":
            return {
                data: row[columnDef.name] ? (
                    <Link
                        component="button"
                        variant="body2"
                        align="left"
                        underline="hover"
                        onClick={() => (columnDef.name === "NCOST_FACT" ? showStageArtCostNotes(row.NRN) : showStageArtContracts(row.NRN))}
                    >
                        {formatNumberRFCurrency(row[columnDef.name])}
                    </Link>
                ) : null
            };
        case "NCTRL_COST":
        case "NCTRL_CONTR":
            return {
                data: (
                    <Stack sx={{ justifyContent: "right" }} direction="row" spacing={1}>
                        <div style={{ color: row[columnDef.name] === 1 ? "red" : "green", display: "flex", alignItems: "center" }}>
                            {formatNumberRFCurrency(row[columnDef.name === "NCTRL_COST" ? "NCOST_DIFF" : "NCONTR_LEFT"])}
                        </div>
                        {formatCtrlValue(row[columnDef.name], false)}
                    </Stack>
                )
            };
    }
};

//-----------
//Тело модуля
//-----------

//Калькуляция этапа проекта
const StageArts = ({ stage, filters }) => {
    //Собственное состояние
    const [stageArtsDataGrid, setStageArtsDataGrid] = useState({
        dataLoaded: false,
        columnsDef: [],
        filters: [...filters],
        rows: [],
        reload: true
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored, SERV_DATA_TYPE_CLOB } = useContext(BackEndСtx);

    //Подключение к контексту приложения
    const { pOnlineShowUnit } = useContext(ApplicationСtx);

    //Подключение к контексту сообщений
    const { showMsgErr } = useContext(MessagingСtx);

    //Загрузка данных калькуляции этапа с сервера
    const loadStageArts = useCallback(async () => {
        if (stageArtsDataGrid.reload) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_PROJECTS.STAGE_ARTS_LIST",
                args: {
                    NSTAGE: stage,
                    CFILTERS: { VALUE: object2Base64XML(stageArtsDataGrid.filters, { arrayNodeName: "filters" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    NINCLUDE_DEF: stageArtsDataGrid.dataLoaded ? 0 : 1
                },
                respArg: "COUT"
            });
            setStageArtsDataGrid(pv => ({
                ...pv,
                columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                rows: [...(data.XROWS || [])],
                dataLoaded: true,
                reload: false
            }));
        }
    }, [stage, stageArtsDataGrid.reload, stageArtsDataGrid.filters, stageArtsDataGrid.dataLoaded, executeStored, SERV_DATA_TYPE_CLOB]);

    //Отображение журнала затрат по статье калькуляции
    const showStageArtCostNotes = async article => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_PROJECTS.STAGE_ARTS_SELECT_COST_FACT",
            args: { NSTAGE: stage, NFPDARTCL: article }
        });
        if (data.NIDENT) pOnlineShowUnit({ unitCode: "CostNotes", inputParameters: [{ name: "in_SelectList_Ident", value: data.NIDENT }] });
        else showMsgErr(TEXTS.NO_DATA_FOUND);
    };

    //Отображение договоров по статье калькуляции
    const showStageArtContracts = async article => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_PROJECTS.STAGE_ARTS_SELECT_CONTR",
            args: { NSTAGE: stage, NFPDARTCL: article }
        });
        if (data.NIDENT) pOnlineShowUnit({ unitCode: "Contracts", inputParameters: [{ name: "in_Ident", value: data.NIDENT }] });
        else showMsgErr(TEXTS.NO_DATA_FOUND);
    };

    //При изменении состояния фильтра
    const handleFilterChanged = ({ filters }) => setStageArtsDataGrid(pv => ({ ...pv, filters, reload: true }));

    //При необходимости обновить данные
    useEffect(() => {
        loadStageArts();
    }, [stageArtsDataGrid.reload, loadStageArts]);

    //Генерация содержимого
    return (
        <Box pt={2}>
            {stageArtsDataGrid.dataLoaded ? (
                <P8PDataGrid
                    columnsDef={stageArtsDataGrid.columnsDef}
                    filtersInitial={filters}
                    rows={stageArtsDataGrid.rows}
                    size={P8P_DATA_GRID_SIZE.SMALL}
                    morePages={false}
                    reloading={stageArtsDataGrid.reload}
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
                    dataCellRender={prms => dataCellRender(prms, showStageArtCostNotes, showStageArtContracts)}
                    valueFormatter={valueFormatter}
                    onFilterChanged={handleFilterChanged}
                    objectsCopier={deepCopyObject}
                />
            ) : null}
        </Box>
    );
};

//Контроль свойств - Калькуляция этапа проекта
StageArts.propTypes = {
    stage: PropTypes.number.isRequired,
    filters: PropTypes.arrayOf(P8P_DATA_GRID_FILTER_SHAPE)
};

//----------------
//Интерфейс модуля
//----------------

export { StageArts };

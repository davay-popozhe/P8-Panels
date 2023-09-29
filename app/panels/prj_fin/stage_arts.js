/*
    Парус 8 - Панели мониторинга - ПУП - Экономика проектов
    Панель мониторинга: Калькуляция этапа проекта
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useCallback, useEffect, useContext } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Box } from "@mui/material"; //Интерфейсные компоненты
import { object2Base64XML } from "../../core/utils"; //Вспомогательные процедуры и функции
import { TEXTS } from "../../../app.text"; //Тектовые ресурсы и константы
import { P8PDataGrid, P8P_DATA_GRID_SIZE, P8P_DATA_GRID_FILTER_SHAPE } from "../../components/p8p_data_grid"; //Таблица данных
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { ApplicationСtx } from "../../context/application"; //Контекст приложения
import { MessagingСtx } from "../../context/messaging"; //Контекст сообщений
import { P8P_DATA_GRID_CONFIG_PROPS } from "../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { PANEL_UNITS, dataCellRender, valueFormatter } from "./layouts"; //Дополнительная разметка и вёрстка клиентских элементов

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
    const showCostNotes = async ({ sender }) => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_PROJECTS.STAGE_ARTS_SELECT_COST_FACT",
            args: { NSTAGE: stage, NFPDARTCL: sender.NRN }
        });
        if (data.NIDENT) pOnlineShowUnit({ unitCode: "CostNotes", inputParameters: [{ name: "in_SelectList_Ident", value: data.NIDENT }] });
        else showMsgErr(TEXTS.NO_DATA_FOUND);
    };

    //Отображение договоров по статье калькуляции
    const showContracts = async ({ sender }) => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_PROJECTS.STAGE_ARTS_SELECT_CONTR",
            args: { NSTAGE: stage, NFPDARTCL: sender.NRN }
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
                    {...P8P_DATA_GRID_CONFIG_PROPS}
                    columnsDef={stageArtsDataGrid.columnsDef}
                    filtersInitial={filters}
                    rows={stageArtsDataGrid.rows}
                    size={P8P_DATA_GRID_SIZE.SMALL}
                    morePages={false}
                    reloading={stageArtsDataGrid.reload}
                    dataCellRender={prms => dataCellRender({ ...prms, panelUnit: PANEL_UNITS.PROJECT_STAGE_ARTS, showCostNotes, showContracts })}
                    valueFormatter={valueFormatter}
                    onFilterChanged={handleFilterChanged}
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

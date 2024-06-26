/*
    Парус 8 - Панели мониторинга - ПУП - Экономика проектов
    Панель мониторинга: Список этапов проекта
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
import { P8PFullScreenDialog } from "../../components/p8p_fullscreen_dialog"; //Полноэкранный диалог
import { StageArts } from "./stage_arts"; //Калькуляция этапа проекта
import { StageContracts } from "./stage_contracts"; //Договоры с соисполнителями этапа проекта
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { ApplicationСtx } from "../../context/application"; //Контекст приложения
import { MessagingСtx } from "../../context/messaging"; //Контекст сообщений
import { P8P_DATA_GRID_CONFIG_PROPS } from "../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { PANEL_UNITS, headCellRender, dataCellRender, valueFormatter, rowExpandRender } from "./layouts"; //Дополнительная разметка и вёрстка клиентских элементов

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
    const { pOnlineShowDocument, pOnlineShowUnit, configSystemPageSize } = useContext(ApplicationСtx);

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
                    NPAGE_SIZE: configSystemPageSize,
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
                morePages: (data.XROWS || []).length >= configSystemPageSize
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
        configSystemPageSize,
        SERV_DATA_TYPE_CLOB
    ]);

    //Отображение журнала платежей по этапу проекта
    const showPayNotes = async ({ sender, direction }) => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_PROJECTS.STAGES_SELECT_FIN",
            args: { NRN: sender.NRN, NDIRECTION: direction }
        });
        if (data.NIDENT) pOnlineShowUnit({ unitCode: "PayNotes", inputParameters: [{ name: "in_SelectList_Ident", value: data.NIDENT }] });
        else showMsgErr(TEXTS.NO_DATA_FOUND);
    };

    //Отображение журнала затрат по этапу проекта
    const showCostNotes = async ({ sender }) => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_PROJECTS.STAGES_SELECT_COST_FACT",
            args: { NRN: sender.NRN }
        });
        if (data.NIDENT) pOnlineShowUnit({ unitCode: "CostNotes", inputParameters: [{ name: "in_IDENT", value: data.NIDENT }] });
        else showMsgErr(TEXTS.NO_DATA_FOUND);
    };

    //Отображение расходных накладных на отпуск потребителям по этапу проекта
    const showGoodsTransInvoicesToConsumers = async ({ sender }) => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_PROJECTS.STAGES_SELECT_SUMM_REALIZ",
            args: { NRN: sender.NRN }
        });
        if (data.NIDENT) pOnlineShowUnit({ unitCode: "GoodsTransInvoicesToConsumers", inputParameters: [{ name: "in_IDENT", value: data.NIDENT }] });
        else showMsgErr(TEXTS.NO_DATA_FOUND);
    };

    //Отображение статей калькуляции по этапу проекта
    const showStageArts = ({ sender, filters = [] } = {}) =>
        setStagesDataGrid(pv => ({ ...pv, showStageArts: sender.NRN, selectedStageNumb: sender.SNUMB, stageArtsFilters: [...filters] }));

    //Отображение договоров с соисполнителями по этапу проекта
    const showContracts = ({ sender, filters = [] } = {}) =>
        setStagesDataGrid(pv => ({ ...pv, showStageContracts: sender.NRN, selectedStageNumb: sender.SNUMB, stageContractsFilters: [...filters] }));

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
                    {...P8P_DATA_GRID_CONFIG_PROPS}
                    columnsDef={stagesDataGrid.columnsDef}
                    filtersInitial={filters}
                    rows={stagesDataGrid.rows}
                    size={P8P_DATA_GRID_SIZE.SMALL}
                    morePages={stagesDataGrid.morePages}
                    reloading={stagesDataGrid.reload}
                    expandable={true}
                    headCellRender={headCellRender}
                    dataCellRender={prms => dataCellRender({ ...prms, panelUnit: PANEL_UNITS.PROJECT_STAGES, showStageArts, showContracts })}
                    rowExpandRender={prms =>
                        rowExpandRender({
                            ...prms,
                            panelUnit: PANEL_UNITS.PROJECT_STAGES,
                            pOnlineShowDocument,
                            showStageArts,
                            showContracts,
                            showPayNotes,
                            showCostNotes,
                            showGoodsTransInvoicesToConsumers
                        })
                    }
                    valueFormatter={prms => valueFormatter({ ...prms, panelUnit: PANEL_UNITS.PROJECT_STAGES })}
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

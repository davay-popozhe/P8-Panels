/*
    Парус 8 - Панели мониторинга - ПУП - Экономика проектов
    Панель мониторинга: Список проктов
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useCallback, useEffect, useContext } from "react"; //Классы React
import { Box } from "@mui/material"; //Интерфейсные компоненты
import { object2Base64XML } from "../../core/utils"; //Вспомогательные процедуры и функции
import { TEXTS } from "../../../app.text"; //Тектовые ресурсы и константы
import { P8PDataGrid, P8P_DATA_GRID_SIZE } from "../../components/p8p_data_grid"; //Таблица данных
import { P8PFullScreenDialog } from "../../components/p8p_fullscreen_dialog"; //Полноэкранный диалог
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { ApplicationСtx } from "../../context/application"; //Контекст приложения
import { MessagingСtx } from "../../context/messaging"; //Контекст сообщений
import { P8P_DATA_GRID_CONFIG_PROPS } from "../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { PANEL_UNITS, headCellRender, dataCellRender, valueFormatter, rowExpandRender } from "./layouts"; //Дополнительная разметка и вёрстка клиентских элементов
import { Stages } from "./stages"; //Список этапов проекта

//-----------
//Тело модуля
//-----------

//Список проектов
const Projects = () => {
    //Собственное состояние
    const [projectsDataGrid, setProjectsDataGrid] = useState({
        dataLoaded: false,
        columnsDef: [],
        filters: null,
        orders: null,
        rows: [],
        reload: true,
        pageNumber: 1,
        morePages: true,
        selectedProject: null,
        stagesFilters: []
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored, SERV_DATA_TYPE_CLOB } = useContext(BackEndСtx);

    //Подключение к контексту приложения
    const { pOnlineShowDocument, pOnlineShowUnit, configSystemPageSize } = useContext(ApplicationСtx);

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
                    NPAGE_SIZE: configSystemPageSize,
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
                morePages: (data.XROWS || []).length >= configSystemPageSize
            }));
        }
    }, [
        projectsDataGrid.reload,
        projectsDataGrid.filters,
        projectsDataGrid.orders,
        projectsDataGrid.dataLoaded,
        projectsDataGrid.pageNumber,
        executeStored,
        configSystemPageSize,
        SERV_DATA_TYPE_CLOB
    ]);

    //Отображение журнала платежей по этапу проекта
    const showPayNotes = async ({ sender, direction }) => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_PROJECTS.SELECT_FIN",
            args: { NRN: sender.NRN, NDIRECTION: direction }
        });
        if (data.NIDENT) pOnlineShowUnit({ unitCode: "PayNotes", inputParameters: [{ name: "in_SelectList_Ident", value: data.NIDENT }] });
        else showMsgErr(TEXTS.NO_DATA_FOUND);
    };

    //Отображение этапов проекта
    const showStages = ({ sender, filters = [] } = {}) =>
        setProjectsDataGrid(pv => ({ ...pv, selectedProject: { ...sender }, stagesFilters: [...filters] }));

    //При изменении состояния фильтра
    const handleFilterChanged = ({ filters }) => setProjectsDataGrid(pv => ({ ...pv, filters: [...filters], pageNumber: 1, reload: true }));

    //При изменении состояния сортировки
    const handleOrderChanged = ({ orders }) => setProjectsDataGrid(pv => ({ ...pv, orders: [...orders], pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц
    const handlePagesCountChanged = () => setProjectsDataGrid(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //При закрытии списка этапов проекта
    const handleStagesClose = () => setProjectsDataGrid(pv => ({ ...pv, selectedProject: null, stagesFilters: [] }));

    //При необходимости обновить данные
    useEffect(() => {
        loadProjects();
    }, [projectsDataGrid.reload, loadProjects]);

    //Генерация содержимого
    return (
        <Box p={2}>
            {projectsDataGrid.dataLoaded ? (
                <P8PDataGrid
                    {...P8P_DATA_GRID_CONFIG_PROPS}
                    columnsDef={projectsDataGrid.columnsDef}
                    rows={projectsDataGrid.rows}
                    size={P8P_DATA_GRID_SIZE.SMALL}
                    morePages={projectsDataGrid.morePages}
                    reloading={projectsDataGrid.reload}
                    expandable={true}
                    headCellRender={headCellRender}
                    dataCellRender={prms => dataCellRender({ ...prms, panelUnit: PANEL_UNITS.PROJECTS, showStages })}
                    rowExpandRender={prms =>
                        rowExpandRender({
                            ...prms,
                            panelUnit: PANEL_UNITS.PROJECTS,
                            pOnlineShowDocument,
                            showPayNotes,
                            showStages
                        })
                    }
                    valueFormatter={prms => valueFormatter({ ...prms, panelUnit: PANEL_UNITS.PROJECTS })}
                    onOrderChanged={handleOrderChanged}
                    onFilterChanged={handleFilterChanged}
                    onPagesCountChanged={handlePagesCountChanged}
                />
            ) : null}
            {projectsDataGrid.selectedProject ? (
                <P8PFullScreenDialog title={`Этапы проекта "${projectsDataGrid.selectedProject.SNAME_USL}"`} onClose={handleStagesClose}>
                    <Stages
                        project={projectsDataGrid.selectedProject.NRN}
                        projectName={projectsDataGrid.selectedProject.SNAME_USL}
                        filters={projectsDataGrid.stagesFilters}
                    />
                </P8PFullScreenDialog>
            ) : null}
        </Box>
    );
};

//----------------
//Интерфейс модуля
//----------------

export { Projects };

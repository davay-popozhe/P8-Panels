/*
    Парус 8 - Панели мониторинга - ПУП - Экономика проектов
    Панель мониторинга: Договоры с соисполнителями этапа проекта
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
import { PANEL_UNITS, dataCellRender, valueFormatter, rowExpandRender } from "./layouts"; //Дополнительная разметка и вёрстка клиентских элементов

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
    const showPaymentAccountsIn = async ({ sender }) => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_PROJECTS.STAGE_CONTRACTS_SELECT_PAY_IN",
            args: { NPROJECTSTAGEPF: sender.NRN }
        });
        if (data.NIDENT) pOnlineShowUnit({ unitCode: "PaymentAccountsIn", inputParameters: [{ name: "in_SelectList_Ident", value: data.NIDENT }] });
        else showMsgErr(TEXTS.NO_DATA_FOUND);
    };

    //Отображение фактических платежей соисполнителю этапа
    const showPayNotes = async ({ sender }) => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_PROJECTS.STAGE_CONTRACTS_SELECT_FIN_OUT",
            args: { NPROJECTSTAGEPF: sender.NRN }
        });
        if (data.NIDENT) pOnlineShowUnit({ unitCode: "PayNotes", inputParameters: [{ name: "in_SelectList_Ident", value: data.NIDENT }] });
        else showMsgErr(TEXTS.NO_DATA_FOUND);
    };

    //Отображение приходных накладных от соисполнителя этапа
    const showIncomingInvoices = async ({ sender }) => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_PROJECTS.STAGE_CONTRACTS_SELECT_ININV",
            args: { NPROJECTSTAGEPF: sender.NRN }
        });
        if (data.NIDENT) pOnlineShowUnit({ unitCode: "IncomingInvoices", inputParameters: [{ name: "in_SelectList_Ident", value: data.NIDENT }] });
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
                    dataCellRender={prms => dataCellRender({ ...prms, panelUnit: PANEL_UNITS.PROJECT_STAGE_CONTRACTS, pOnlineShowDocument })}
                    rowExpandRender={prms =>
                        rowExpandRender({
                            ...prms,
                            panelUnit: PANEL_UNITS.PROJECT_STAGE_CONTRACTS,
                            pOnlineShowDocument,
                            showPaymentAccountsIn,
                            showPayNotes,
                            showIncomingInvoices
                        })
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

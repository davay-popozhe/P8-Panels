/*
    Парус 8 - Панели мониторинга - ПУП - Работы проектов
    Компонент панели: Монитор ресурсов
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useContext, useState, useCallback, useEffect } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { ApplicationСtx } from "../../context/application"; //Контекст приложения
import { object2Base64XML } from "../../core/utils"; //Вспомогательные функции
import { P8P_DATA_GRID_CONFIG_PROPS } from "../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { P8PDataGrid, P8P_DATA_GRID_SIZE } from "../../components/p8p_data_grid"; //Таблица данных
import { LabPlanFOTDtl } from "./lab_plan_fot_dtl"; //Детализация плановой трудоёмкости по ФОТ
import { LabFactRptDtl } from "./lab_fact_rpt_dtl"; //Детализация фактической трудоёмкости по "Планам и отчетам подразделений"
import { LabPlanJobsDtl } from "./lab_plan_jobs_dtl"; //Детализация плановой трудоёмкости по графику
import { periodsDataCellRender } from "./layouts"; //Дополнительная разметка и вёрстка клиентских элементов

//-----------
//Тело модуля
//-----------

//Монитор ресурсов
const ResMon = ({ ident, onPlanJobsDtlProjectClick }) => {
    //Собственное состояние
    const [state, setState] = useState({
        displayPlanFOTDtl: null,
        titlePlanFOTDtl: null,
        displayFactRptDtl: null,
        titleFactRptDtl: null,
        displayPlanJobsDtl: null,
        titlePlanJobsDtl: null
    });

    //Состояние таблицы периодов монитора ресурсов
    const [peridos, setPeriods] = useState({
        dataLoaded: false,
        columnsDef: [],
        orders: [],
        rows: [],
        reload: true,
        pageNumber: 1,
        morePages: true
    });

    //Подключение к контексту приложения
    const { configSystemPageSize } = useContext(ApplicationСtx);

    //Подключение к контексту взаимодействия с сервером
    const { executeStored, SERV_DATA_TYPE_CLOB } = useContext(BackEndСtx);

    //Загрузка данных монитора балансировки периодов с сервера
    const loadPeriods = useCallback(async () => {
        if (peridos.reload) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_PROJECTS.JB_PERIODS_LIST",
                args: {
                    NIDENT: ident,
                    CORDERS: { VALUE: object2Base64XML(peridos.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    NPAGE_NUMBER: peridos.pageNumber,
                    NPAGE_SIZE: configSystemPageSize,
                    NINCLUDE_DEF: peridos.dataLoaded ? 0 : 1
                },
                attributeValueProcessor: (name, val) => (name == "SPERIOD" ? undefined : val),
                respArg: "COUT"
            });
            setPeriods(pv => ({
                ...pv,
                columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                rows: pv.pageNumber == 1 ? [...(data.XROWS || [])] : [...pv.rows, ...(data.XROWS || [])],
                dataLoaded: true,
                reload: false,
                morePages: (data.XROWS || []).length >= configSystemPageSize
            }));
        }
    }, [ident, peridos.reload, peridos.orders, peridos.dataLoaded, peridos.pageNumber, executeStored, configSystemPageSize, SERV_DATA_TYPE_CLOB]);

    //При сокрытии детализации
    const handleHideDtl = () =>
        setState(pv => ({
            ...pv,
            displayPlanFOTDtl: null,
            titlePlanFOTDtl: null,
            displayFactRptDtl: null,
            titleFactRptDtl: null,
            displayPlanJobsDtl: null,
            titlePlanJobsDtl: null
        }));

    //При нажатии на плановую трудоёмкость по ФОТ
    const handleLabPlanFOTClick = ({ sender }) =>
        setState(pv => ({
            ...pv,
            displayPlanFOTDtl: sender.NRN,
            titlePlanFOTDtl: `${sender.SPERIOD} - ${sender.SINS_DEPARTMENT} - ${sender.SFCMANPOWER} - ${sender.NLAB_PLAN_FOT}`
        }));

    //При нажатии на фактическую трудоёмкость по отчетам
    const handleLabFactRptClick = ({ sender }) =>
        setState(pv => ({
            ...pv,
            displayFactRptDtl: sender.NRN,
            titleFactRptDtl: `${sender.SPERIOD} - ${sender.SINS_DEPARTMENT} - ${sender.SFCMANPOWER} - ${sender.NLAB_FACT_RPT}`
        }));

    //При нажатии на проект в списке детализации плановой трудоёмкости по графику
    const handleLabPlanJobsClick = ({ sender }) =>
        setState(pv => ({
            ...pv,
            displayPlanJobsDtl: sender.NRN,
            titlePlanJobsDtl: `${sender.SPERIOD} - ${sender.SINS_DEPARTMENT} - ${sender.SFCMANPOWER} - ${sender.NLAB_PLAN_JOBS}`
        }));

    //При изменении состояния сортировки в таблице периодов балансировки
    const handlePeriodsOrderChanged = ({ orders }) => setPeriods(pv => ({ ...pv, orders, pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц в таблице периодов балансировки
    const handlePeriodsPagesCountChanged = () => setPeriods(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //При нажатии на проект в таблице детализации трудоёмкости по плану-графику
    const handlePlanJobsDtlProjectClick = ({ sender }) => (onPlanJobsDtlProjectClick ? onPlanJobsDtlProjectClick({ sender }) : null);

    //При необходимости обновить данные
    useEffect(() => {
        loadPeriods();
    }, [peridos.reload, loadPeriods]);

    //Генерация содержимого
    return (
        <>
            {peridos.dataLoaded ? (
                <P8PDataGrid
                    {...P8P_DATA_GRID_CONFIG_PROPS}
                    columnsDef={peridos.columnsDef}
                    rows={peridos.rows}
                    size={P8P_DATA_GRID_SIZE.SMALL}
                    morePages={peridos.morePages}
                    reloading={peridos.reload}
                    onOrderChanged={handlePeriodsOrderChanged}
                    onPagesCountChanged={handlePeriodsPagesCountChanged}
                    dataCellRender={prms =>
                        periodsDataCellRender({
                            ...prms,
                            onLabPlanFOTClick: handleLabPlanFOTClick,
                            onLabFactRptClick: handleLabFactRptClick,
                            onLabPlanJobsClick: handleLabPlanJobsClick
                        })
                    }
                />
            ) : null}
            {state.displayPlanFOTDtl ? (
                <LabPlanFOTDtl periodId={state.displayPlanFOTDtl} title={state.titlePlanFOTDtl} onHide={handleHideDtl} />
            ) : null}
            {state.displayFactRptDtl ? (
                <LabFactRptDtl periodId={state.displayFactRptDtl} title={state.titleFactRptDtl} onHide={handleHideDtl} />
            ) : null}
            {state.displayPlanJobsDtl ? (
                <LabPlanJobsDtl
                    periodId={state.displayPlanJobsDtl}
                    title={state.titlePlanJobsDtl}
                    onHide={handleHideDtl}
                    onProjectClick={handlePlanJobsDtlProjectClick}
                />
            ) : null}
        </>
    );
};

//Контроль свойств - Монитор ресурсов
ResMon.propTypes = {
    ident: PropTypes.number.isRequired,
    onPlanJobsDtlProjectClick: PropTypes.func
};

//----------------
//Интерфейс модуля
//----------------

export { ResMon };

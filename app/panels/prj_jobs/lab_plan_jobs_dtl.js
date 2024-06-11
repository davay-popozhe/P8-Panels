/*
    Парус 8 - Панели мониторинга - ПУП - Работы проектов
    Компонент панели: Детализация плановой трудоёмкости по графику
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useContext, useState, useCallback, useEffect } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Dialog, DialogContent, DialogActions, Button, DialogTitle } from "@mui/material"; //Интерфейсные элементы
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { ApplicationСtx } from "../../context/application"; //Контекст приложения
import { object2Base64XML } from "../../core/utils"; //Вспомогательные функции
import { BUTTONS } from "../../../app.text"; //Текстовые ресурсы
import { P8P_DATA_GRID_CONFIG_PROPS } from "../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { P8PDataGrid, P8P_DATA_GRID_SIZE } from "../../components/p8p_data_grid"; //Таблица данных
import { planJobsDtlValueFormatter, planJobsDtlHeadCellRender, planJobsDtlDataCellRender } from "./layouts"; //Дополнительная разметка и вёрстка клиентских элементов

//------------------------------------
//Вспомогательные функции и компоненты
//------------------------------------

//-----------
//Тело модуля
//-----------

//Детализация плановой трудоёмкости по графику
const LabPlanJobsDtl = ({ periodId, title, onHide, onProjectClick }) => {
    //Состояние таблицы детализации плановой трудоёмкости по графику
    const [planJobsDtl, setPlanJobsDtl] = useState({
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

    //Загрузка детализации плановой трудоёмкости по графику для ресурса
    const loadPlanJobsDtl = useCallback(async () => {
        if (planJobsDtl.reload) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_PROJECTS.JB_PERIODS_PLAN_JOBS_LIST",
                args: {
                    NJB_PERIODS: periodId,
                    CORDERS: { VALUE: object2Base64XML(planJobsDtl.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    NPAGE_NUMBER: planJobsDtl.pageNumber,
                    NPAGE_SIZE: configSystemPageSize,
                    NINCLUDE_DEF: planJobsDtl.dataLoaded ? 0 : 1
                },
                respArg: "COUT"
            });
            setPlanJobsDtl(pv => ({
                ...pv,
                columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                rows: pv.pageNumber == 1 ? [...(data.XROWS || [])] : [...pv.rows, ...(data.XROWS || [])],
                dataLoaded: true,
                reload: false,
                morePages: (data.XROWS || []).length >= configSystemPageSize
            }));
        }
    }, [
        periodId,
        planJobsDtl.reload,
        planJobsDtl.orders,
        planJobsDtl.dataLoaded,
        planJobsDtl.pageNumber,
        executeStored,
        configSystemPageSize,
        SERV_DATA_TYPE_CLOB
    ]);

    //При изменении состояния сортировки в детализации плановой трудоёмкости по графику
    const handlePlanJobsDtlDGOrderChanged = ({ orders }) => setPlanJobsDtl(pv => ({ ...pv, orders, pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц в детализации плановой трудоёмкости по графику
    const handlePlanJobsDtlDGPagesCountChanged = () => setPlanJobsDtl(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //При нажатии на проект в таблице детализаци
    const handleProjectClick = ({ sender }) => (onProjectClick ? onProjectClick({ sender }) : null);

    //При необходимости обновить данные
    useEffect(() => {
        loadPlanJobsDtl();
    }, [planJobsDtl.reload, loadPlanJobsDtl]);

    //Генерация содержимого
    return planJobsDtl.dataLoaded ? (
        <Dialog open onClose={onHide} fullWidth maxWidth="xl">
            <DialogTitle>{title}</DialogTitle>
            <DialogContent>
                <P8PDataGrid
                    {...P8P_DATA_GRID_CONFIG_PROPS}
                    columnsDef={planJobsDtl.columnsDef}
                    rows={planJobsDtl.rows}
                    size={P8P_DATA_GRID_SIZE.SMALL}
                    morePages={planJobsDtl.morePages}
                    reloading={planJobsDtl.reload}
                    valueFormatter={planJobsDtlValueFormatter}
                    headCellRender={planJobsDtlHeadCellRender}
                    dataCellRender={prms => planJobsDtlDataCellRender({ ...prms, onProjectClick: handleProjectClick })}
                    onOrderChanged={handlePlanJobsDtlDGOrderChanged}
                    onPagesCountChanged={handlePlanJobsDtlDGPagesCountChanged}
                />
            </DialogContent>
            <DialogActions>
                <Button onClick={onHide}>{BUTTONS.CLOSE}</Button>
            </DialogActions>
        </Dialog>
    ) : null;
};

//Контроль свойств - Детализация плановой трудоёмкости по графику
LabPlanJobsDtl.propTypes = {
    periodId: PropTypes.number.isRequired,
    title: PropTypes.string.isRequired,
    onHide: PropTypes.func.isRequired,
    onProjectClick: PropTypes.func
};

//----------------
//Интерфейс модуля
//----------------

export { LabPlanJobsDtl };

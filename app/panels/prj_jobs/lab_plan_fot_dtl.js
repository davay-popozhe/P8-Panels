/*
    Парус 8 - Панели мониторинга - ПУП - Работы проектов
    Компонент панели: Детализация плановой трудоёмкости по ФОТ
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

//-----------
//Тело модуля
//-----------

//Детализация плановой трудоёмкости по ФОТ
const LabPlanFOTDtl = ({ periodId, title, onHide }) => {
    //Состояние таблицы детализации плановой трудоёмкости по ФОТ ресурса
    const [planFOTDtl, setPlanFOTDtl] = useState({
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

    //Загрузка детализации плановой трудоёмкости по ФОТ для ресурса
    const loadPlanFOTDtl = useCallback(async () => {
        if (planFOTDtl.reload) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_PROJECTS.JB_PERIODS_PLAN_FOT_LIST",
                args: {
                    NJB_PERIODS: periodId,
                    CORDERS: { VALUE: object2Base64XML(planFOTDtl.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    NPAGE_NUMBER: planFOTDtl.pageNumber,
                    NPAGE_SIZE: configSystemPageSize,
                    NINCLUDE_DEF: planFOTDtl.dataLoaded ? 0 : 1
                },
                respArg: "COUT"
            });
            setPlanFOTDtl(pv => ({
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
        planFOTDtl.reload,
        planFOTDtl.orders,
        planFOTDtl.dataLoaded,
        planFOTDtl.pageNumber,
        executeStored,
        configSystemPageSize,
        SERV_DATA_TYPE_CLOB
    ]);

    //При изменении состояния сортировки в детализации плана ФОТ по строке ресурса
    const handlePlanFOTDtlDGOrderChanged = ({ orders }) => setPlanFOTDtl(pv => ({ ...pv, orders, pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц в в детализации плана ФОТ по строке ресурса
    const handlePlanFOTDtlDGPagesCountChanged = () => setPlanFOTDtl(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //При необходимости обновить данные
    useEffect(() => {
        loadPlanFOTDtl();
    }, [planFOTDtl.reload, loadPlanFOTDtl]);

    //Генерация содержимого
    return planFOTDtl.dataLoaded ? (
        <Dialog open onClose={onHide}>
            <DialogTitle>{title}</DialogTitle>
            <DialogContent>
                <P8PDataGrid
                    {...P8P_DATA_GRID_CONFIG_PROPS}
                    columnsDef={planFOTDtl.columnsDef}
                    rows={planFOTDtl.rows}
                    size={P8P_DATA_GRID_SIZE.SMALL}
                    morePages={planFOTDtl.morePages}
                    reloading={planFOTDtl.reload}
                    onOrderChanged={handlePlanFOTDtlDGOrderChanged}
                    onPagesCountChanged={handlePlanFOTDtlDGPagesCountChanged}
                />
            </DialogContent>
            <DialogActions>
                <Button onClick={onHide}>{BUTTONS.CLOSE}</Button>
            </DialogActions>
        </Dialog>
    ) : null;
};

//Контроль свойств - Детализация плановой трудоёмкости по ФОТ
LabPlanFOTDtl.propTypes = {
    periodId: PropTypes.number.isRequired,
    title: PropTypes.string.isRequired,
    onHide: PropTypes.func.isRequired
};

//----------------
//Интерфейс модуля
//----------------

export { LabPlanFOTDtl };

/*
    Парус 8 - Панели мониторинга - ПУП - Работы проектов
    Компонент панели: Детализация фактической трудоёмкости по "Планам и отчетам подразделений"
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
import { factRptDtlValueFormatter, factRptDtlHeadCellRender } from "./layouts"; //Дополнительная разметка и вёрстка клиентских элементов

//-----------
//Тело модуля
//-----------

//Детализация фактической трудоёмкости по "Планам и отчетам подразделений"
const LabFactRptDtl = ({ periodId, title, onHide }) => {
    //Состояние таблицы детализации плановой трудоёмкости по графику
    const [factRptDtl, setFactRptDtl] = useState({
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

    //Загрузка детализации фактической трудоёмкости по отчетам для ресурса
    const loadFactRptDtl = useCallback(async () => {
        if (factRptDtl.reload) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_PROJECTS.JB_PERIODS_LIST_FACT_RPT",
                args: {
                    NJB_PERIODS: periodId,
                    CORDERS: { VALUE: object2Base64XML(factRptDtl.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    NPAGE_NUMBER: factRptDtl.pageNumber,
                    NPAGE_SIZE: configSystemPageSize,
                    NINCLUDE_DEF: factRptDtl.dataLoaded ? 0 : 1
                },
                respArg: "COUT"
            });
            setFactRptDtl(pv => ({
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
        factRptDtl.reload,
        factRptDtl.orders,
        factRptDtl.dataLoaded,
        factRptDtl.pageNumber,
        executeStored,
        configSystemPageSize,
        SERV_DATA_TYPE_CLOB
    ]);

    //При изменении состояния сортировки в детализации факта по "Планам и отчетам в подразделении"
    const handlePlanJobsDtlDGOrderChanged = ({ orders }) => setFactRptDtl(pv => ({ ...pv, orders, pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц в факта по "Планам и отчетам в подразделении"
    const handlePlanJobsDtlDGPagesCountChanged = () => setFactRptDtl(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //При необходимости обновить данные
    useEffect(() => {
        loadFactRptDtl();
    }, [factRptDtl.reload, loadFactRptDtl]);

    //Генерация содержимого
    return factRptDtl.dataLoaded ? (
        <Dialog open onClose={onHide} fullWidth maxWidth="xl">
            <DialogTitle>{title}</DialogTitle>
            <DialogContent>
                <P8PDataGrid
                    {...P8P_DATA_GRID_CONFIG_PROPS}
                    columnsDef={factRptDtl.columnsDef}
                    rows={factRptDtl.rows}
                    size={P8P_DATA_GRID_SIZE.SMALL}
                    morePages={factRptDtl.morePages}
                    reloading={factRptDtl.reload}
                    valueFormatter={factRptDtlValueFormatter}
                    headCellRender={factRptDtlHeadCellRender}
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

//Контроль свойств - Детализация фактической трудоёмкости по "Планам и отчетам подразделений"
LabFactRptDtl.propTypes = {
    periodId: PropTypes.number.isRequired,
    title: PropTypes.string.isRequired,
    onHide: PropTypes.func.isRequired
};

//----------------
//Интерфейс модуля
//----------------

export { LabFactRptDtl };

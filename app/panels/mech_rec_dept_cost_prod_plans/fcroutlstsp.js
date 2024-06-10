/*
    Парус 8 - Панели мониторинга - ПУП - Производственный план цеха
    Компонент панели: Таблица строк маршрутного листа
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useCallback, useEffect, useContext } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Typography } from "@mui/material"; //Интерфейсные элементы
import { P8PDataGrid, P8P_DATA_GRID_SIZE } from "../../components/p8p_data_grid"; //Таблица данных
import { P8P_DATA_GRID_CONFIG_PROPS } from "../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { object2Base64XML } from "../../core/utils"; //Вспомогательные функции

//---------
//Константы
//---------

//Стили
const STYLES = {
    CONTAINER: { margin: "5px 0px", textAlign: "center" }
};

//-----------
//Тело модуля
//-----------

//Таблица строк маршрутного листа
const CostRouteListsSpecsDataGrid = ({ mainRowRN }) => {
    //Собственное состояние - таблица данных
    const [costRouteListsSpecs, setCostRouteListsSpecs] = useState({
        dataLoaded: false,
        columnsDef: [],
        orders: null,
        rows: [],
        reload: true,
        pageNumber: 1,
        morePages: true
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored, SERV_DATA_TYPE_CLOB } = useContext(BackEndСtx);

    //Размер страницы данных
    const DATA_GRID_PAGE_SIZE = 10;

    //Загрузка данных таблицы с сервера
    const loadData = useCallback(async () => {
        if (costRouteListsSpecs.reload) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.FCROUTLSTSP_DEPT_DG_GET",
                args: {
                    NFCROUTLST: mainRowRN,
                    CORDERS: { VALUE: object2Base64XML(costRouteListsSpecs.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    NPAGE_NUMBER: costRouteListsSpecs.pageNumber,
                    NPAGE_SIZE: DATA_GRID_PAGE_SIZE,
                    NINCLUDE_DEF: costRouteListsSpecs.dataLoaded ? 0 : 1
                },
                respArg: "COUT"
            });
            setCostRouteListsSpecs(pv => ({
                ...pv,
                columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                rows: pv.pageNumber == 1 ? [...(data.XROWS || [])] : [...pv.rows, ...(data.XROWS || [])],
                dataLoaded: true,
                reload: false,
                morePages: (data.XROWS || []).length >= DATA_GRID_PAGE_SIZE
            }));
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [
        costRouteListsSpecs.reload,
        costRouteListsSpecs.filters,
        costRouteListsSpecs.orders,
        costRouteListsSpecs.dataLoaded,
        costRouteListsSpecs.pageNumber,
        executeStored,
        SERV_DATA_TYPE_CLOB
    ]);

    //При необходимости обновить данные таблицы
    useEffect(() => {
        loadData();
    }, [costRouteListsSpecs.reload, loadData]);

    //При изменении состояния сортировки
    const handleOrderChanged = ({ orders }) => setCostRouteListsSpecs(pv => ({ ...pv, orders: [...orders], pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц
    const handlePagesCountChanged = () => setCostRouteListsSpecs(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //Генерация содержимого
    return (
        <div style={STYLES.CONTAINER}>
            <Typography variant={"subtitle2"}>Операции</Typography>
            {costRouteListsSpecs.dataLoaded ? (
                <P8PDataGrid
                    {...P8P_DATA_GRID_CONFIG_PROPS}
                    columnsDef={costRouteListsSpecs.columnsDef}
                    rows={costRouteListsSpecs.rows}
                    size={P8P_DATA_GRID_SIZE.SMALL}
                    morePages={costRouteListsSpecs.morePages}
                    reloading={costRouteListsSpecs.reload}
                    onOrderChanged={handleOrderChanged}
                    onPagesCountChanged={handlePagesCountChanged}
                />
            ) : null}
        </div>
    );
};

//Контроль свойств - Таблица строк маршрутного листа
CostRouteListsSpecsDataGrid.propTypes = {
    mainRowRN: PropTypes.number.isRequired
};

//----------------
//Интерфейс модуля
//----------------

export { CostRouteListsSpecsDataGrid };

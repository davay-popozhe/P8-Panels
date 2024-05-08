/*
    Парус 8 - Панели мониторинга - ПУП - Производственный план цеха
    Компонент панели: Таблица заказов маршрутного листа
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

//Таблица заказов маршрутного листа
const CostRouteListsOrdDataGrid = ({ mainRowRN }) => {
    //Собственное состояние - таблица данных
    const [costRouteListsOrd, setCostRouteListsOrd] = useState({
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
        if (costRouteListsOrd.reload) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.FCROUTLSTORD_DEPT_DG_GET",
                args: {
                    NFCROUTLST: mainRowRN,
                    CORDERS: { VALUE: object2Base64XML(costRouteListsOrd.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    NPAGE_NUMBER: costRouteListsOrd.pageNumber,
                    NPAGE_SIZE: DATA_GRID_PAGE_SIZE,
                    NINCLUDE_DEF: costRouteListsOrd.dataLoaded ? 0 : 1
                },
                respArg: "COUT"
            });
            setCostRouteListsOrd(pv => ({
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
        costRouteListsOrd.reload,
        costRouteListsOrd.filters,
        costRouteListsOrd.orders,
        costRouteListsOrd.dataLoaded,
        costRouteListsOrd.pageNumber,
        executeStored,
        SERV_DATA_TYPE_CLOB
    ]);

    //При необходимости обновить данные таблицы
    useEffect(() => {
        loadData();
    }, [costRouteListsOrd.reload, loadData]);

    //При изменении состояния сортировки
    const handleOrderChanged = ({ orders }) => setCostRouteListsOrd(pv => ({ ...pv, orders: [...orders], pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц
    const handlePagesCountChanged = () => setCostRouteListsOrd(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //Генерация содержимого
    return (
        <div style={STYLES.CONTAINER}>
            <Typography variant={"subtitle2"}>Заказы</Typography>
            {costRouteListsOrd.dataLoaded ? (
                <P8PDataGrid
                    {...P8P_DATA_GRID_CONFIG_PROPS}
                    columnsDef={costRouteListsOrd.columnsDef}
                    rows={costRouteListsOrd.rows}
                    size={P8P_DATA_GRID_SIZE.SMALL}
                    morePages={costRouteListsOrd.morePages}
                    reloading={costRouteListsOrd.reload}
                    onOrderChanged={handleOrderChanged}
                    onPagesCountChanged={handlePagesCountChanged}
                />
            ) : null}
        </div>
    );
};

//Контроль свойств - Таблица заказов маршрутного листа
CostRouteListsOrdDataGrid.propTypes = {
    mainRowRN: PropTypes.number.isRequired
};

//----------------
//Интерфейс модуля
//----------------

export { CostRouteListsOrdDataGrid };

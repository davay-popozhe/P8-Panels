/*
    Парус 8 - Панели мониторинга - ПУП - Производственная программа
    Компонент панели: Таблица строк комплектации
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Typography } from "@mui/material"; //Интерфейсные элементы
import { P8PDataGrid, P8P_DATA_GRID_SIZE } from "../../../components/p8p_data_grid"; //Таблица данных
import { P8P_DATA_GRID_CONFIG_PROPS } from "../../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { useCostDeliveryLists } from "./backend_dg"; //Собственные хуки таблиц

//---------
//Константы
//---------

//Стили
const STYLES = {
    CONTAINER: { margin: "5px 0px", textAlign: "center" }
};

//------------------------------------
//Вспомогательные функции и компоненты
//------------------------------------

//Генерация заливки строки исходя от значений
const dataCellRender = ({ row, columnDef }) => {
    //Если "Количество план" равно или меньше "Остаток"
    if (row["NQUANT_PLAN"] <= row["NREST"]) {
        return {
            cellStyle: { backgroundColor: "lightblue" },
            data: row[columnDef]
        };
    } else {
        return {
            data: row[columnDef]
        };
    }
};

//-----------
//Тело модуля
//-----------

//Таблица строк комплектации
const CostDeliveryListsDataGrid = ({ mainRowRN }) => {
    //Собственное состояние - таблица данных
    const [costDeliveryLists, setCostDeliveryLists] = useCostDeliveryLists(mainRowRN);

    //При изменении состояния сортировки
    const handleOrderChanged = ({ orders }) => setCostDeliveryLists(pv => ({ ...pv, orders: [...orders], pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц
    const handlePagesCountChanged = () => setCostDeliveryLists(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //Генерация содержимого
    return (
        <div style={STYLES.CONTAINER}>
            <Typography variant={"subtitle2"}>Строки комплектации</Typography>
            {costDeliveryLists.dataLoaded ? (
                <P8PDataGrid
                    {...P8P_DATA_GRID_CONFIG_PROPS}
                    columnsDef={costDeliveryLists.columnsDef}
                    rows={costDeliveryLists.rows}
                    size={P8P_DATA_GRID_SIZE.SMALL}
                    morePages={costDeliveryLists.morePages}
                    reloading={costDeliveryLists.reload}
                    onOrderChanged={handleOrderChanged}
                    onPagesCountChanged={handlePagesCountChanged}
                    dataCellRender={prms => dataCellRender({ ...prms })}
                />
            ) : null}
        </div>
    );
};

//Контроль свойств - Таблица строк комплектации
CostDeliveryListsDataGrid.propTypes = {
    mainRowRN: PropTypes.number.isRequired
};

//----------------
//Интерфейс модуля
//----------------

export { CostDeliveryListsDataGrid };

/*
    Парус 8 - Панели мониторинга - ПУП - Производственная программа
    Компонент панели: Таблица товарных запасов
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Typography } from "@mui/material"; //Интерфейсные элементы
import { P8PDataGrid, P8P_DATA_GRID_SIZE } from "../../../components/p8p_data_grid"; //Таблица данных
import { P8P_DATA_GRID_CONFIG_PROPS } from "../../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { useGoodsParties } from "./backend_dg"; //Собственные хуки таблиц

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

//Генерация представления строки на основании заглавной
const dataCellRender = ({ row, columnDef, quantPlanSum }) => {
    //Если остаток больше суммы "Выдать по норме" - закрашиваем голубым
    if (row["NRESTFACT"] >= quantPlanSum) {
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

//Таблица товарных запасов
const GoodsPartiesDataGrid = ({ mainRowRN, quantPlanSum, nomenclature }) => {
    //Собственное состояние - таблица данных
    const [goodsParties, setGoodsParties] = useGoodsParties(mainRowRN);

    //При изменении состояния сортировки
    const handleOrderChanged = ({ orders }) => setGoodsParties(pv => ({ ...pv, orders: [...orders], pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц
    const handlePagesCountChanged = () => setGoodsParties(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //Генерация содержимого
    return (
        <div style={STYLES.CONTAINER}>
            <Typography variant={"h6"}>{`Товарные запасы по номенклатуре "${nomenclature}"`}</Typography>
            {goodsParties.dataLoaded ? (
                <P8PDataGrid
                    {...P8P_DATA_GRID_CONFIG_PROPS}
                    columnsDef={goodsParties.columnsDef}
                    rows={goodsParties.rows}
                    size={P8P_DATA_GRID_SIZE.LARGE}
                    morePages={goodsParties.morePages}
                    reloading={goodsParties.reload}
                    onOrderChanged={handleOrderChanged}
                    onPagesCountChanged={handlePagesCountChanged}
                    dataCellRender={prms => dataCellRender({ ...prms, quantPlanSum })}
                />
            ) : null}
        </div>
    );
};

//Контроль свойств - Таблица товарных запасов
GoodsPartiesDataGrid.propTypes = {
    mainRowRN: PropTypes.number.isRequired,
    quantPlanSum: PropTypes.number,
    nomenclature: PropTypes.string
};

//----------------
//Интерфейс модуля
//----------------

export { GoodsPartiesDataGrid };

/*
    Парус 8 - Панели мониторинга
    Обёртки для компонент, обеспечивающие подключение их к настройкам приложения
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import { deepCopyObject } from "./core/utils"; //Вспомогательные процедуры и функции
import { BUTTONS, TEXTS, INPUTS } from "../app.text"; //Текстовые ресурсы и константы
import { P8PDataGrid, P8P_DATA_GRID_SIZE } from "./components/p8p_data_grid"; //Таблица данных

//---------
//Константы
//---------

//Конфигурируемые свойства "Таблицы данных" (P8PDataGrid)
const P8P_DATA_GRID_CONFIG_PROPS = {
    orderAscMenuItemCaption: BUTTONS.ORDER_ASC,
    orderDescMenuItemCaption: BUTTONS.ORDER_DESC,
    filterMenuItemCaption: BUTTONS.FILTER,
    valueFilterCaption: INPUTS.VALUE,
    valueFromFilterCaption: INPUTS.VALUE_FROM,
    valueToFilterCaption: INPUTS.VALUE_TO,
    okFilterBtnCaption: BUTTONS.OK,
    clearFilterBtnCaption: BUTTONS.CLEAR,
    cancelFilterBtnCaption: BUTTONS.CANCEL,
    morePagesBtnCaption: BUTTONS.MORE,
    noDataFoundText: TEXTS.NO_DATA_FOUND,
    objectsCopier: deepCopyObject
};

//-----------------------
//Вспомогательные функции
//-----------------------

//Рекурсивное добавление свойств элемента, получаемых из конфигурационных файлов
const addConfigChildProps = children =>
    React.Children.map(children, child => {
        if (!React.isValidElement(child)) return child;
        const { children, ...restProps } = child.props;
        let configProps = {};
        if (child.type.name === "P8PDataGrid") configProps = P8P_DATA_GRID_CONFIG_PROPS;
        return React.createElement(child.type, { ...configProps, ...restProps }, addConfigChildProps(children));
    });

//-----------
//Тело модуля
//-----------

//Обёртка для компонента "Таблица данных" (P8PDataGrid)
const P8PDataGridConfigWrapped = (props = {}) => {
    return <P8PDataGrid {...P8P_DATA_GRID_CONFIG_PROPS} {...props} />;
};

//Универсальный элемент-обёртка в параметры конфигурации
const ConfigWrapper = ({ children }) => addConfigChildProps(children);

//----------------
//Интерфейс модуля
//----------------

export { P8P_DATA_GRID_CONFIG_PROPS, P8P_DATA_GRID_SIZE, P8PDataGridConfigWrapped, ConfigWrapper };

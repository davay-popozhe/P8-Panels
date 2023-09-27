/*
    Парус 8 - Панели мониторинга
    Обёртки для компонент, обеспечивающие подключение их к настройкам приложения
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import { deepCopyObject } from "./core/utils"; //Вспомогательные процедуры и функции
import { TITLES, BUTTONS, TEXTS, INPUTS } from "../app.text"; //Текстовые ресурсы и константы
import { P8PPanelsMenuGrid, P8P_PANELS_MENU_PANEL_SHAPE } from "./components/p8p_data_grid"; //Меню панелей
import { P8PAppWorkspace } from "./components/p8p_app_workspace"; //Рабочее пространство
import { P8PTable, P8P_TABLE_DATA_TYPE, P8P_TABLE_SIZE, P8P_TABLE_FILTER_SHAPE } from "./components/p8p_data_grid"; //Таблица данных
import { P8PDataGrid, P8P_DATA_GRID_DATA_TYPE, P8P_DATA_GRID_SIZE, P8P_DATA_GRID_FILTER_SHAPE } from "./components/p8p_data_grid"; //Таблица данных

//---------
//Константы
//---------

//Конфигурируемые свойства "Меню панелей (табличное)" (P8PPanelsMenuGrid)
const P8P_PANELS_MENU_GRID_CONFIG_PROPS = {
    navigateCaption: BUTTONS.NAVIGATE,
    defaultGroupTytle: TITLES.DEFAULT_PANELS_GROUP
};

//Конфигурируемые свойства "Рабочего пространства" (P8PAppWorkspace)
const P8P_APP_WORKSPACE_CONFIG_PROPS = {
    closeCaption: BUTTONS.CLOSE,
    homeCaption: BUTTONS.NAVIGATE_HOME
};

//Конфигурируемые свойства "Таблицы" (P8PTable)
const P8P_TABLE_CONFIG_PROPS = {
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
    noDataFoundText: TEXTS.NO_DATA_FOUND
};

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
        if (child.type.name === "P8PPanelsMenuGrid") configProps = P8P_PANELS_MENU_GRID_CONFIG_PROPS;
        if (child.type.name === "P8PTable") configProps = P8P_TABLE_CONFIG_PROPS;
        if (child.type.name === "P8PDataGrid") configProps = P8P_DATA_GRID_CONFIG_PROPS;
        return React.createElement(child.type, { ...configProps, ...restProps }, addConfigChildProps(children));
    });

//-----------
//Тело модуля
//-----------

//Обёртка для компонента "Меню панелей (табличное)" (P8PPanelsMenuGrid)
const P8PPanelsMenuGridConfigWrapped = (props = {}) => <P8PPanelsMenuGrid {...P8P_PANELS_MENU_GRID_CONFIG_PROPS} {...props} />;

//Обёртка для компонента "Рабочее пространство" (P8PAppWorkspace)
const P8PAppWorkspaceConfigWrapped = (props = {}) => <P8PAppWorkspace {...P8P_APP_WORKSPACE_CONFIG_PROPS} {...props} />;

//Обёртка для компонента "Таблица" (P8PTable)
const P8PTableConfigWrapped = (props = {}) => <P8PTable {...P8P_DATA_GRID_CONFIG_PROPS} {...props} />;

//Обёртка для компонента "Таблица данных" (P8PDataGrid)
const P8PDataGridConfigWrapped = (props = {}) => <P8PDataGrid {...P8P_DATA_GRID_CONFIG_PROPS} {...props} />;

//Универсальный элемент-обёртка в параметры конфигурации
const ConfigWrapper = ({ children }) => addConfigChildProps(children);

//----------------
//Интерфейс модуля
//----------------

export {
    P8P_PANELS_MENU_GRID_CONFIG_PROPS,
    P8P_PANELS_MENU_PANEL_SHAPE,
    P8P_APP_WORKSPACE_CONFIG_PROPS,
    P8P_TABLE_CONFIG_PROPS,
    P8P_TABLE_DATA_TYPE,
    P8P_TABLE_SIZE,
    P8P_TABLE_FILTER_SHAPE,
    P8P_DATA_GRID_CONFIG_PROPS,
    P8P_DATA_GRID_DATA_TYPE,
    P8P_DATA_GRID_SIZE,
    P8P_DATA_GRID_FILTER_SHAPE,
    P8PPanelsMenuGridConfigWrapped,
    P8PAppWorkspaceConfigWrapped,
    P8PTableConfigWrapped,
    P8PDataGridConfigWrapped,
    ConfigWrapper
};

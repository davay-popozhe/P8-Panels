/*
    Парус 8 - Панели мониторинга
    Обёртки для компонент, обеспечивающие подключение их к настройкам приложения
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import { deepCopyObject } from "./core/utils"; //Вспомогательные процедуры и функции
import { TITLES, BUTTONS, TEXTS, CAPTIONS } from "../app.text"; //Текстовые ресурсы и константы
import { P8PPanelsMenuGrid, P8P_PANELS_MENU_PANEL_SHAPE } from "./components/p8p_data_grid"; //Меню панелей
import { P8PAppWorkspace } from "./components/p8p_app_workspace"; //Рабочее пространство
import { P8PTable, P8P_TABLE_DATA_TYPE, P8P_TABLE_SIZE, P8P_TABLE_FILTER_SHAPE } from "./components/p8p_data_grid"; //Таблица данных
import { P8PDataGrid, P8P_DATA_GRID_DATA_TYPE, P8P_DATA_GRID_SIZE, P8P_DATA_GRID_FILTER_SHAPE } from "./components/p8p_data_grid"; //Таблица данных
import { P8PGantt, P8P_GANTT_TASK_SHAPE, P8P_GANTT_TASK_ATTRIBUTE_SHAPE, P8P_GANTT_TASK_COLOR_SHAPE } from "./components/p8p_gantt"; //Диаграмма Ганта

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
    valueFilterCaption: CAPTIONS.VALUE,
    valueFromFilterCaption: CAPTIONS.VALUE_FROM,
    valueToFilterCaption: CAPTIONS.VALUE_TO,
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
    valueFilterCaption: CAPTIONS.VALUE,
    valueFromFilterCaption: CAPTIONS.VALUE_FROM,
    valueToFilterCaption: CAPTIONS.VALUE_TO,
    okFilterBtnCaption: BUTTONS.OK,
    clearFilterBtnCaption: BUTTONS.CLEAR,
    cancelFilterBtnCaption: BUTTONS.CANCEL,
    morePagesBtnCaption: BUTTONS.MORE,
    noDataFoundText: TEXTS.NO_DATA_FOUND,
    objectsCopier: deepCopyObject
};

//Конфигурируемые свойства "Диаграммы Ганта" (P8PGantt)
const P8P_GANTT_CONFIG_PROPS = {
    noDataFoundText: TEXTS.NO_DATA_FOUND,
    numbTaskEditorCaption: CAPTIONS.NUMB,
    nameTaskEditorCaption: CAPTIONS.NAME,
    startTaskEditorCaption: CAPTIONS.START,
    endTaskEditorCaption: CAPTIONS.END,
    progressTaskEditorCaption: CAPTIONS.PROGRESS,
    legendTaskEditorCaption: CAPTIONS.LEGEND,
    okTaskEditorBtnCaption: BUTTONS.OK,
    cancelTaskEditorBtnCaption: BUTTONS.CANCEL
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
        if (child.type.name === "P8PGantt") configProps = P8P_GANTT_CONFIG_PROPS;
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
const P8PTableConfigWrapped = (props = {}) => <P8PTable {...P8P_TABLE_CONFIG_PROPS} {...props} />;

//Обёртка для компонента "Таблица данных" (P8PDataGrid)
const P8PDataGridConfigWrapped = (props = {}) => <P8PDataGrid {...P8P_DATA_GRID_CONFIG_PROPS} {...props} />;

//Обёртка для компонента "Диаграмма Ганта" (P8PGantt)
const P8PGanttConfigWrapped = (props = {}) => <P8PGantt {...P8P_GANTT_CONFIG_PROPS} {...props} />;

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
    P8P_GANTT_CONFIG_PROPS,
    P8P_GANTT_TASK_SHAPE,
    P8P_GANTT_TASK_ATTRIBUTE_SHAPE,
    P8P_GANTT_TASK_COLOR_SHAPE,
    P8PPanelsMenuGridConfigWrapped,
    P8PAppWorkspaceConfigWrapped,
    P8PTableConfigWrapped,
    P8PDataGridConfigWrapped,
    P8PGanttConfigWrapped,
    ConfigWrapper
};

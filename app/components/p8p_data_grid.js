/*
    Парус 8 - Панели мониторинга
    Компонент: Таблица данных
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useEffect } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { P8PTable, P8P_TABLE_SIZE, P8P_TABLE_DATA_TYPE, P8P_TABLE_FILTER_SHAPE } from "./p8p_table"; //Таблица

//---------
//Константы
//---------

//Размеры отступов
const P8P_DATA_GRID_SIZE = P8P_TABLE_SIZE;

//Типы данных
const P8P_DATA_GRID_DATA_TYPE = P8P_TABLE_DATA_TYPE;

//Формат фильтра
const P8P_DATA_GRID_FILTER_SHAPE = P8P_TABLE_FILTER_SHAPE;

//-----------
//Тело модуля
//-----------

//Таблица данных
const P8PDataGrid = ({
    columnsDef,
    filtersInitial,
    groups,
    rows,
    size,
    morePages = false,
    reloading,
    expandable,
    orderAscMenuItemCaption,
    orderDescMenuItemCaption,
    filterMenuItemCaption,
    valueFilterCaption,
    valueFromFilterCaption,
    valueToFilterCaption,
    okFilterBtnCaption,
    clearFilterBtnCaption,
    cancelFilterBtnCaption,
    morePagesBtnCaption,
    noDataFoundText,
    headCellRender,
    dataCellRender,
    groupCellRender,
    rowExpandRender,
    valueFormatter,
    containerComponent,
    containerComponentProps,
    onOrderChanged,
    onFilterChanged,
    onPagesCountChanged,
    objectsCopier
}) => {
    //Собственное состояние - сортировки
    const [orders, setOrders] = useState([]);

    //Собственное состояние - фильтры
    const [filters, setFilters] = useState(filtersInitial || []);

    //При изменении состояния сортировки
    const handleOrderChanged = ({ columnName, direction }) => {
        let newOrders = objectsCopier(orders);
        const curOrder = newOrders.find(o => o.name == columnName);
        if (direction == null && curOrder) newOrders.splice(newOrders.indexOf(curOrder), 1);
        if (direction != null && !curOrder) newOrders.push({ name: columnName, direction });
        if (direction != null && curOrder) curOrder.direction = direction;
        setOrders(newOrders);
        if (onOrderChanged) onOrderChanged({ orders: newOrders });
    };

    //При изменении состояния фильтра
    const handleFilterChanged = ({ columnName, from, to }) => {
        let newFilters = objectsCopier(filters);
        let curFilter = newFilters.find(f => f.name == columnName);
        if (from == null && to == null && curFilter) newFilters.splice(newFilters.indexOf(curFilter), 1);
        if ((from != null || to != null) && !curFilter) newFilters.push({ name: columnName, from, to });
        if ((from != null || to != null) && curFilter) {
            curFilter.from = from;
            curFilter.to = to;
        }
        setFilters(newFilters);
        if (onFilterChanged) onFilterChanged({ filters: newFilters });
    };

    //При изменении количества отображаемых страниц
    const handlePagesCountChanged = () => {
        if (onPagesCountChanged) onPagesCountChanged();
    };

    //При изменении списка установленных извне фильтров
    useEffect(() => {
        setFilters(filtersInitial || []);
    }, [filtersInitial]);

    //Генерация содержимого
    return (
        <P8PTable
            columnsDef={columnsDef}
            groups={groups}
            rows={rows}
            orders={orders}
            filters={filters}
            size={size || P8P_DATA_GRID_SIZE.MEDIUM}
            morePages={morePages}
            reloading={reloading}
            expandable={expandable}
            orderAscMenuItemCaption={orderAscMenuItemCaption}
            orderDescMenuItemCaption={orderDescMenuItemCaption}
            filterMenuItemCaption={filterMenuItemCaption}
            valueFilterCaption={valueFilterCaption}
            valueFromFilterCaption={valueFromFilterCaption}
            valueToFilterCaption={valueToFilterCaption}
            okFilterBtnCaption={okFilterBtnCaption}
            clearFilterBtnCaption={clearFilterBtnCaption}
            cancelFilterBtnCaption={cancelFilterBtnCaption}
            morePagesBtnCaption={morePagesBtnCaption}
            noDataFoundText={noDataFoundText}
            headCellRender={headCellRender}
            dataCellRender={dataCellRender}
            groupCellRender={groupCellRender}
            rowExpandRender={rowExpandRender}
            valueFormatter={valueFormatter}
            objectsCopier={objectsCopier}
            containerComponent={containerComponent}
            containerComponentProps={containerComponentProps}
            onOrderChanged={handleOrderChanged}
            onFilterChanged={handleFilterChanged}
            onPagesCountChanged={handlePagesCountChanged}
        />
    );
};

//Контроль свойств - Таблица данных
P8PDataGrid.propTypes = {
    columnsDef: PropTypes.array.isRequired,
    filtersInitial: PropTypes.arrayOf(P8P_DATA_GRID_FILTER_SHAPE),
    groups: PropTypes.array,
    rows: PropTypes.array.isRequired,
    size: PropTypes.string,
    morePages: PropTypes.bool,
    reloading: PropTypes.bool.isRequired,
    expandable: PropTypes.bool,
    orderAscMenuItemCaption: PropTypes.string.isRequired,
    orderDescMenuItemCaption: PropTypes.string.isRequired,
    filterMenuItemCaption: PropTypes.string.isRequired,
    valueFilterCaption: PropTypes.string.isRequired,
    valueFromFilterCaption: PropTypes.string.isRequired,
    valueToFilterCaption: PropTypes.string.isRequired,
    okFilterBtnCaption: PropTypes.string.isRequired,
    clearFilterBtnCaption: PropTypes.string.isRequired,
    cancelFilterBtnCaption: PropTypes.string.isRequired,
    morePagesBtnCaption: PropTypes.string.isRequired,
    noDataFoundText: PropTypes.string,
    headCellRender: PropTypes.func,
    dataCellRender: PropTypes.func,
    groupCellRender: PropTypes.func,
    rowExpandRender: PropTypes.func,
    valueFormatter: PropTypes.func,
    containerComponent: PropTypes.oneOfType([PropTypes.elementType, PropTypes.string]),
    containerComponentProps: PropTypes.object,
    onOrderChanged: PropTypes.func,
    onFilterChanged: PropTypes.func,
    onPagesCountChanged: PropTypes.func,
    objectsCopier: PropTypes.func.isRequired
};

//----------------
//Интерфейс модуля
//----------------

export { P8P_DATA_GRID_DATA_TYPE, P8P_DATA_GRID_SIZE, P8P_DATA_GRID_FILTER_SHAPE, P8PDataGrid };

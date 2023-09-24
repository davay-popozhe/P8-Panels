/*
    Парус 8 - Панели мониторинга
    Компонент: Таблица
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useEffect, useState, useMemo } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import {
    Table,
    TableBody,
    TableCell,
    TableContainer,
    TableHead,
    TableRow,
    Paper,
    IconButton,
    Icon,
    Menu,
    MenuItem,
    Divider,
    Stack,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    Button,
    TextField,
    Chip,
    Container
} from "@mui/material"; //Интерфейсные компоненты
import { P8PAppInlineError } from "./p8p_app_message"; //Встраиваемое сообщение об ошибке

//---------
//Константы
//---------

//Размеры отступов
const P8P_TABLE_SIZE = {
    SMALL: "small",
    MEDIUM: "medium"
};

//Типы данных
const P8P_TABLE_DATA_TYPE = {
    STR: "STR",
    NUMB: "NUMB",
    DATE: "DATE"
};

//Направления сортировки
const P8P_TABLE_COLUMN_ORDER_DIRECTIONS = {
    ASC: "ASC",
    DESC: "DESC"
};

//Действия панели инструментов столбца
const P8P_TABLE_COLUMN_TOOL_BAR_ACTIONS = {
    ORDER_TOGGLE: "ORDER_TOGGLE",
    FILTER_TOGGLE: "FILTER_TOGGLE"
};

//Действия меню столбца
const P8P_TABLE_COLUMN_MENU_ACTIONS = {
    ORDER_ASC: "ORDER_ASC",
    ORDER_DESC: "ORDER_DESC",
    FILTER: "FILTER"
};

//Стили
const STYLES = {
    TABLE: {
        with: "100%"
    },
    TABLE_ROW: {
        "&:last-child td, &:last-child th": { border: 0 }
    },
    TABLE_CELL_EXPAND_CONTAINER: {
        paddingBottom: 0,
        paddingTop: 0
    },
    TABLE_COLUMN_STACK: {
        alignItems: "center"
    },
    TABLE_COLUMN_MENU_ITEM_ICON: {
        paddingRight: "10px"
    },
    FILTER_CHIP: {
        alignItems: "center"
    },
    MORE_BUTTON_CONTAINER: {
        with: "100%",
        textAlign: "center",
        padding: "5px"
    }
};

//Структура элемента описания фильтра
const P8P_FILTER_SHAPE = PropTypes.shape({
    name: PropTypes.string.isRequired,
    from: PropTypes.any,
    to: PropTypes.any
});

//--------------------------------
//Вспомогательные классы и функции
//--------------------------------

//Проверка существования значения
const hasValue = value => typeof value !== "undefined" && value !== null && value !== "";

//Панель инструментов столбца
const P8PTableColumnToolBar = ({ columnDef, orders, filters, onItemClick }) => {
    //Кнопка сортировки
    const order = orders.find(o => o.name == columnDef.name);
    let orderButton = null;
    if (order)
        orderButton = (
            <IconButton onClick={() => (onItemClick ? onItemClick(P8P_TABLE_COLUMN_TOOL_BAR_ACTIONS.ORDER_TOGGLE, columnDef.name) : null)}>
                <Icon>{order.direction === P8P_TABLE_COLUMN_ORDER_DIRECTIONS.ASC ? "arrow_upward" : "arrow_downward"}</Icon>
            </IconButton>
        );

    //Кнопка фильтрации
    const filter = filters.find(f => f.name == columnDef.name);
    let filterButton = null;
    if (hasValue(filter?.from) || hasValue(filter?.to))
        filterButton = (
            <IconButton onClick={() => (onItemClick ? onItemClick(P8P_TABLE_COLUMN_TOOL_BAR_ACTIONS.FILTER_TOGGLE, columnDef.name) : null)}>
                <Icon>filter_alt</Icon>
            </IconButton>
        );
    //Генерация содержимого
    return (
        <>
            {orderButton}
            {filterButton}
        </>
    );
};

//Контроль свойств - Панель инструментов столбца
P8PTableColumnToolBar.propTypes = {
    columnDef: PropTypes.object.isRequired,
    orders: PropTypes.array.isRequired,
    filters: PropTypes.array.isRequired,
    onItemClick: PropTypes.func
};

//Меню столбца
const P8PTableColumnMenu = ({ columnDef, orderAscItemCaption, orderDescItemCaption, filterItemCaption, onItemClick }) => {
    //Собственное состояние
    const [anchorEl, setAnchorEl] = useState(null);

    //Флаг отображения
    const open = Boolean(anchorEl);

    //По нажатию на открытие меню
    const handleMenuButtonClick = event => {
        setAnchorEl(event.currentTarget);
    };

    //По нажатию на пункт меню
    const handleMenuItemClick = (event, index, action, columnName) => {
        if (onItemClick) onItemClick(action, columnName);
        setAnchorEl(null);
    };

    //При закрытии меню
    const handleMenuClose = () => {
        setAnchorEl(null);
    };

    //Формирование списка элементов меню в зависимости от описания колонки таблицы
    const menuItems = [];
    if (columnDef.order === true) {
        menuItems.push(
            <MenuItem
                key={"orderAsc"}
                onClick={(event, index) => handleMenuItemClick(event, index, P8P_TABLE_COLUMN_MENU_ACTIONS.ORDER_ASC, columnDef.name)}
            >
                <Icon sx={STYLES.TABLE_COLUMN_MENU_ITEM_ICON}>arrow_upward</Icon>
                {orderAscItemCaption}
            </MenuItem>
        );
        menuItems.push(
            <MenuItem
                key={"orderDesc"}
                onClick={(event, index) => handleMenuItemClick(event, index, P8P_TABLE_COLUMN_MENU_ACTIONS.ORDER_DESC, columnDef.name)}
            >
                <Icon sx={STYLES.TABLE_COLUMN_MENU_ITEM_ICON}>arrow_downward</Icon>
                {orderDescItemCaption}
            </MenuItem>
        );
    }
    if (columnDef.filter === true) {
        if (menuItems.length > 0) menuItems.push(<Divider key={"divider"} sx={{ my: 0.5 }} />);
        menuItems.push(
            <MenuItem
                key={"filter"}
                onClick={(event, index) => handleMenuItemClick(event, index, P8P_TABLE_COLUMN_MENU_ACTIONS.FILTER, columnDef.name)}
            >
                <Icon sx={STYLES.TABLE_COLUMN_MENU_ITEM_ICON}>filter_alt</Icon>
                {filterItemCaption}
            </MenuItem>
        );
    }

    //Генерация содержимого
    return menuItems.length > 0 ? (
        <>
            <IconButton id={`${columnDef.name}_menu_button`} aria-haspopup="true" onClick={handleMenuButtonClick}>
                <Icon>more_vert</Icon>
            </IconButton>
            <Menu id={`${columnDef.name}_menu`} anchorEl={anchorEl} open={open} onClose={handleMenuClose}>
                {menuItems}
            </Menu>
        </>
    ) : null;
};

//Контроль свойств - Меню столбца
P8PTableColumnMenu.propTypes = {
    columnDef: PropTypes.object.isRequired,
    orderAscItemCaption: PropTypes.string.isRequired,
    orderDescItemCaption: PropTypes.string.isRequired,
    filterItemCaption: PropTypes.string.isRequired,
    onItemClick: PropTypes.func
};

//Диалог фильтра
const P8PTableColumnFilterDialog = ({
    columnDef,
    from,
    to,
    valueCaption,
    valueFromCaption,
    valueToCaption,
    okBtnCaption,
    clearBtnCaption,
    cancelBtnCaption,
    valueFormatter,
    onOk,
    onClear,
    onCancel
}) => {
    //Собственное состояние - значения с-по
    const [filterValues, setFilterValues] = useState({ from, to });

    //Отработка воода значения в фильтр
    const handleFilterTextFieldChanged = e => {
        setFilterValues(prev => ({ ...prev, [e.target.name]: e.target.value }));
    };

    //Элементы ввода значений фильтра
    let inputs = null;
    if (Array.isArray(columnDef.values) && columnDef.values.length > 0) {
        inputs = (
            <TextField
                name="from"
                fullWidth
                select
                label={valueCaption}
                variant="standard"
                value={filterValues.from}
                onChange={handleFilterTextFieldChanged}
            >
                {columnDef.values.map((v, i) => (
                    <MenuItem key={i} value={v}>
                        {valueFormatter ? valueFormatter({ value: v, columnDef }) : v}
                    </MenuItem>
                ))}
            </TextField>
        );
    } else {
        switch (columnDef.dataType) {
            case P8P_TABLE_DATA_TYPE.STR: {
                inputs = (
                    <TextField
                        name="from"
                        fullWidth
                        InputLabelProps={{ shrink: true }}
                        value={filterValues.from}
                        onChange={handleFilterTextFieldChanged}
                        label={valueCaption}
                        variant="standard"
                    />
                );
                break;
            }
            case P8P_TABLE_DATA_TYPE.NUMB:
            case P8P_TABLE_DATA_TYPE.DATE: {
                inputs = (
                    <>
                        <TextField
                            name="from"
                            InputLabelProps={{ shrink: true }}
                            type={columnDef.dataType == P8P_TABLE_DATA_TYPE.NUMB ? "number" : "date"}
                            value={filterValues.from}
                            onChange={handleFilterTextFieldChanged}
                            label={valueFromCaption}
                            variant="standard"
                        />
                        &nbsp;
                        <TextField
                            name="to"
                            InputLabelProps={{ shrink: true }}
                            type={columnDef.dataType == P8P_TABLE_DATA_TYPE.NUMB ? "number" : "date"}
                            value={filterValues.to}
                            onChange={handleFilterTextFieldChanged}
                            label={valueToCaption}
                            variant="standard"
                        />
                    </>
                );
                break;
            }
        }
    }

    return (
        <Dialog
            open={true}
            aria-labelledby="filter-dialog-title"
            aria-describedby="filter-dialog-description"
            onClose={() => (onCancel ? onCancel(columnDef.name) : null)}
        >
            <DialogTitle id="filter-dialog-title">{columnDef.caption}</DialogTitle>
            <DialogContent>{inputs}</DialogContent>
            <DialogActions>
                <Button onClick={() => (onOk ? onOk(columnDef.name, filterValues.from, filterValues.to) : null)}>{okBtnCaption}</Button>
                <Button onClick={() => (onClear ? onClear(columnDef.name) : null)} variant="secondary">
                    {clearBtnCaption}
                </Button>
                <Button onClick={() => (onCancel ? onCancel(columnDef.name) : null)}>{cancelBtnCaption}</Button>
            </DialogActions>
        </Dialog>
    );
};

//Контроль свойств - Диалог фильтра
P8PTableColumnFilterDialog.propTypes = {
    columnDef: PropTypes.object.isRequired,
    from: PropTypes.any,
    to: PropTypes.any,
    valueCaption: PropTypes.string.isRequired,
    valueFromCaption: PropTypes.string.isRequired,
    valueToCaption: PropTypes.string.isRequired,
    okBtnCaption: PropTypes.string.isRequired,
    clearBtnCaption: PropTypes.string.isRequired,
    cancelBtnCaption: PropTypes.string.isRequired,
    valueFormatter: PropTypes.func,
    onOk: PropTypes.func,
    onClear: PropTypes.func,
    onCancel: PropTypes.func
};

//Сводный фильтр
const P8PTableFiltersChips = ({ filters, columnsDef, valueFromCaption, valueToCaption, onFilterChipClick, onFilterChipDelete, valueFormatter }) => {
    return (
        <Stack direction="row" spacing={1} pb={2}>
            {filters.map((filter, i) => {
                const columnDef = columnsDef.find(columnDef => columnDef.name == filter.name);
                return (
                    <Chip
                        key={i}
                        label={
                            <Stack direction="row" sx={STYLES.FILTER_CHIP}>
                                <strong>{columnDef.caption}</strong>:&nbsp;
                                {hasValue(filter.from) && !columnDef.values && columnDef.dataType != P8P_TABLE_DATA_TYPE.STR
                                    ? `${valueFromCaption.toLowerCase()} `
                                    : null}
                                {hasValue(filter.from) ? (valueFormatter ? valueFormatter({ value: filter.from, columnDef }) : filter.from) : null}
                                {hasValue(filter.to) && !columnDef.values && columnDef.dataType != P8P_TABLE_DATA_TYPE.STR
                                    ? ` ${valueToCaption.toLowerCase()} `
                                    : null}
                                {hasValue(filter.to) ? (valueFormatter ? valueFormatter({ value: filter.to, columnDef }) : filter.to) : null}
                            </Stack>
                        }
                        variant="outlined"
                        onClick={() => (onFilterChipClick ? onFilterChipClick(columnDef.name) : null)}
                        onDelete={() => (onFilterChipDelete ? onFilterChipDelete(columnDef.name) : null)}
                    />
                );
            })}
        </Stack>
    );
};

//Контроль свойств - Сводный фильтр
P8PTableFiltersChips.propTypes = {
    filters: PropTypes.array.isRequired,
    columnsDef: PropTypes.array.isRequired,
    valueFromCaption: PropTypes.string.isRequired,
    valueToCaption: PropTypes.string.isRequired,
    onFilterChipClick: PropTypes.func,
    onFilterChipDelete: PropTypes.func,
    valueFormatter: PropTypes.func
};

//-----------
//Тело модуля
//-----------

//Таблица
const P8PTable = ({
    columnsDef,
    rows,
    orders,
    filters,
    size,
    morePages,
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
    rowExpandRender,
    valueFormatter,
    onOrderChanged,
    onFilterChanged,
    onPagesCountChanged
}) => {
    //Собственное состояние - фильтруемая колонка
    const [filterColumn, setFilterColumn] = useState(null);

    //Собственное состояние - развёрнутые строки
    const [expanded, setExpanded] = useState({});

    //Описание фильтруемой колонки
    const filterColumnDef = filterColumn ? columnsDef.find(columnDef => columnDef.name == filterColumn) || null : null;

    //Значения фильтра фильтруемой колонки
    const [filterColumnFrom, filterColumnTo] = filterColumn
        ? (() => {
              const filter = filters.find(filter => filter.name == filterColumn);
              return filter ? [filter.from == null ? "" : filter.from, filter.to == null ? "" : filter.to] : ["", ""];
          })()
        : ["", ""];

    //Определение списка видимых колонок
    const visibleColumns = useMemo(() => columnsDef.filter(columnDef => columnDef.visible === true), [columnsDef]);

    //Определение количества видимых колонок
    const visibleColumnsCount = useMemo(() => visibleColumns.length + (expandable === true ? 1 : 0), [visibleColumns, expandable]);

    //Выравнивание в зависимости от типа данных
    const getAlignByDataType = dataType =>
        dataType === P8P_TABLE_DATA_TYPE.DATE ? "center" : dataType === P8P_TABLE_DATA_TYPE.NUMB ? "right" : "left";

    //Упорядочение содержимого в зависимости от типа данных
    const getJustifyContentByDataType = dataType =>
        dataType === P8P_TABLE_DATA_TYPE.DATE ? "center" : dataType === P8P_TABLE_DATA_TYPE.NUMB ? "flex-end" : "flex-start";

    //Отработка нажатия на элемент пункта меню
    const handleToolBarItemClick = (action, columnName) => {
        switch (action) {
            case P8P_TABLE_COLUMN_TOOL_BAR_ACTIONS.ORDER_TOGGLE: {
                const colOrder = orders.find(o => o.name == columnName);
                const newDirection =
                    colOrder?.direction == P8P_TABLE_COLUMN_ORDER_DIRECTIONS.ASC
                        ? P8P_TABLE_COLUMN_ORDER_DIRECTIONS.DESC
                        : colOrder?.direction == P8P_TABLE_COLUMN_ORDER_DIRECTIONS.DESC
                        ? null
                        : P8P_TABLE_COLUMN_ORDER_DIRECTIONS.ASC;
                if (onOrderChanged) onOrderChanged({ columnName, direction: newDirection });
                break;
            }
            case P8P_TABLE_COLUMN_TOOL_BAR_ACTIONS.FILTER_TOGGLE:
                setFilterColumn(columnName);
                break;
        }
    };

    //Отработка нажатия на пункты меню
    const handleMenuItemClick = (action, columnName) => {
        switch (action) {
            case P8P_TABLE_COLUMN_MENU_ACTIONS.ORDER_ASC:
                onOrderChanged({ columnName, direction: P8P_TABLE_COLUMN_ORDER_DIRECTIONS.ASC });
                break;
            case P8P_TABLE_COLUMN_MENU_ACTIONS.ORDER_DESC:
                onOrderChanged({ columnName, direction: P8P_TABLE_COLUMN_ORDER_DIRECTIONS.DESC });
                break;
            case P8P_TABLE_COLUMN_MENU_ACTIONS.FILTER:
                setFilterColumn(columnName);
                break;
        }
    };

    //Отработка ввода значения фильтра колонки
    const handleFilterOk = (columnName, from, to) => {
        if (onFilterChanged) onFilterChanged({ columnName, from: from === "" ? null : from, to: to === "" ? null : to });
        setFilterColumn(null);
    };

    //Отработка очистки значения фильтра колонки
    const handleFilterClear = columnName => {
        if (onFilterChanged) onFilterChanged({ columnName, from: null, to: null });
        setFilterColumn(null);
    };

    //Отработка отмены ввода значения фильтра колонки
    const handleFilterCancel = () => {
        setFilterColumn(null);
    };

    //Отработка нажатия на элемент сводного фильтра
    const handleFilterChipClick = columnName => setFilterColumn(columnName);

    //Отработка удаления элемента сводного фильтра
    const handleFilterChipDelete = columnName => (onFilterChanged ? onFilterChanged({ columnName, from: null, to: null }) : null);

    //Отработка нажатия на кнопку догрузки страницы
    const handleMorePagesBtnClick = () => {
        if (onPagesCountChanged) onPagesCountChanged();
    };

    //Отработка нажатия на кнопку раскрытия элемента
    const handleExpandClick = rowIndex => {
        if (expanded[rowIndex] === true)
            setExpanded(pv => {
                let res = { ...pv };
                delete res[rowIndex];
                return res;
            });
        else setExpanded(pv => ({ ...pv, [rowIndex]: true }));
    };

    //При перезагрузке данных
    useEffect(() => {
        if (reloading) setExpanded({});
    }, [reloading]);

    //Генерация содержимого
    return (
        <>
            {filterColumn ? (
                <P8PTableColumnFilterDialog
                    columnDef={filterColumnDef}
                    from={filterColumnFrom}
                    to={filterColumnTo}
                    valueCaption={valueFilterCaption}
                    valueFromCaption={valueFromFilterCaption}
                    valueToCaption={valueToFilterCaption}
                    okBtnCaption={okFilterBtnCaption}
                    clearBtnCaption={clearFilterBtnCaption}
                    cancelBtnCaption={cancelFilterBtnCaption}
                    valueFormatter={valueFormatter}
                    onOk={handleFilterOk}
                    onClear={handleFilterClear}
                    onCancel={handleFilterCancel}
                />
            ) : null}
            {Array.isArray(filters) && filters.length > 0 ? (
                <P8PTableFiltersChips
                    filters={filters}
                    columnsDef={columnsDef}
                    valueFromCaption={valueFromFilterCaption}
                    valueToCaption={valueToFilterCaption}
                    onFilterChipClick={handleFilterChipClick}
                    onFilterChipDelete={handleFilterChipDelete}
                    valueFormatter={valueFormatter}
                />
            ) : null}
            <TableContainer component={Paper}>
                <Table sx={STYLES.TABLE} size={size || P8P_TABLE_SIZE.MEDIUM}>
                    <TableHead>
                        <TableRow>
                            {expandable && rowExpandRender ? <TableCell key="head-cell-expand-control" align="center"></TableCell> : null}
                            {visibleColumns.map((columnDef, j) => {
                                let customRender = {};
                                if (headCellRender) customRender = headCellRender({ columnDef }) || {};
                                return (
                                    <TableCell
                                        key={`head-cell-${j}`}
                                        align={getAlignByDataType(columnDef.dataType)}
                                        sx={{ ...customRender.cellStyle }}
                                        {...customRender.cellProps}
                                    >
                                        <Stack
                                            direction="row"
                                            justifyContent={getJustifyContentByDataType(columnDef.dataType)}
                                            sx={{ ...STYLES.TABLE_COLUMN_STACK, ...customRender.stackStyle }}
                                            {...customRender.stackProps}
                                        >
                                            {customRender.data ? customRender.data : columnDef.caption}
                                            <P8PTableColumnToolBar
                                                columnDef={columnDef}
                                                orders={orders}
                                                filters={filters}
                                                onItemClick={handleToolBarItemClick}
                                            />
                                            <P8PTableColumnMenu
                                                columnDef={columnDef}
                                                orderAscItemCaption={orderAscMenuItemCaption}
                                                orderDescItemCaption={orderDescMenuItemCaption}
                                                filterItemCaption={filterMenuItemCaption}
                                                onItemClick={handleMenuItemClick}
                                            />
                                        </Stack>
                                    </TableCell>
                                );
                            })}
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {rows.length > 0
                            ? rows.map((row, i) => (
                                  <React.Fragment key={`data-${i}`}>
                                      <TableRow key={`data-row-${i}`} sx={STYLES.TABLE_ROW}>
                                          {expandable && rowExpandRender ? (
                                              <TableCell key={`data-cell-expand-control-${i}`} align="center">
                                                  <IconButton onClick={() => handleExpandClick(i)}>
                                                      <Icon>{expanded[i] === true ? "keyboard_arrow_down" : "keyboard_arrow_right"}</Icon>
                                                  </IconButton>
                                              </TableCell>
                                          ) : null}
                                          {visibleColumns.map((columnDef, j) => {
                                              let customRender = {};
                                              if (dataCellRender) customRender = dataCellRender({ row, columnDef }) || {};
                                              return (
                                                  <TableCell
                                                      key={`data-cell-${j}`}
                                                      align={getAlignByDataType(columnDef.dataType)}
                                                      sx={{ ...customRender.cellStyle }}
                                                      {...customRender.cellProps}
                                                  >
                                                      {customRender.data
                                                          ? customRender.data
                                                          : valueFormatter
                                                          ? valueFormatter({ value: row[columnDef.name], columnDef })
                                                          : row[columnDef.name]}
                                                  </TableCell>
                                              );
                                          })}
                                      </TableRow>
                                      {expandable && rowExpandRender && expanded[i] === true ? (
                                          <TableRow key={`data-row-expand-${i}`}>
                                              <TableCell sx={STYLES.TABLE_CELL_EXPAND_CONTAINER} colSpan={visibleColumnsCount}>
                                                  {rowExpandRender({ columnsDef, row })}
                                              </TableCell>
                                          </TableRow>
                                      ) : null}
                                  </React.Fragment>
                              ))
                            : null}
                    </TableBody>
                </Table>
                {rows.length == 0 ? (
                    noDataFoundText && !reloading ? (
                        <P8PAppInlineError text={noDataFoundText} />
                    ) : null
                ) : morePages ? (
                    <Container style={STYLES.MORE_BUTTON_CONTAINER}>
                        <Button fullWidth onClick={handleMorePagesBtnClick}>
                            {morePagesBtnCaption}
                        </Button>
                    </Container>
                ) : null}
            </TableContainer>
        </>
    );
};

//Контроль свойств - Таблица
P8PTable.propTypes = {
    columnsDef: PropTypes.arrayOf(
        PropTypes.shape({
            name: PropTypes.string.isRequired,
            caption: PropTypes.string.isRequired,
            order: PropTypes.bool.isRequired,
            filter: PropTypes.bool.isRequired,
            dataType: PropTypes.string.isRequired,
            values: PropTypes.array
        })
    ).isRequired,
    rows: PropTypes.array.isRequired,
    orders: PropTypes.arrayOf(
        PropTypes.shape({
            name: PropTypes.string.isRequired,
            direction: PropTypes.string.isRequired
        })
    ).isRequired,
    filters: PropTypes.arrayOf(P8P_FILTER_SHAPE).isRequired,
    size: PropTypes.string,
    morePages: PropTypes.bool.isRequired,
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
    rowExpandRender: PropTypes.func,
    valueFormatter: PropTypes.func,
    onOrderChanged: PropTypes.func,
    onFilterChanged: PropTypes.func,
    onPagesCountChanged: PropTypes.func
};

//----------------
//Интерфейс модуля
//----------------

export { P8PTable, P8P_TABLE_DATA_TYPE, P8P_TABLE_SIZE, P8P_FILTER_SHAPE };

/*
    Парус 8 - Панели мониторинга - ПУП - Производственный план цеха
    Панель мониторинга: Корневая панель производственного плана цеха
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useContext, useState, useCallback, useEffect } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Drawer, Fab, Box, List, ListItemButton, ListItemText, Typography, TextField, Link, Grid } from "@mui/material"; //Интерфейсные элементы
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { useFilteredPlans } from "./hooks"; //Вспомогательные хуки
import { object2Base64XML } from "../../core/utils"; //Вспомогательные функции
import { P8PDataGrid, P8P_DATA_GRID_SIZE } from "../../components/p8p_data_grid"; //Таблица данных
import { P8P_DATA_GRID_CONFIG_PROPS } from "../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { MessagingСtx } from "../../context/messaging"; //Контекст сообщений
import { IncomFromDepsDataGridDialog } from "./incomefromdeps"; //Диалог сдачи продукции
import { CostRouteListsDataGridDialog } from "./fcroutlst"; //Диалог маршрутных листов

//---------
//Константы
//---------

//Стили
const STYLES = {
    PLANS_FINDER: { marginTop: "10px", marginLeft: "10px", width: "93%" },
    PLANS_LIST_ITEM_PRIMARY: { wordWrap: "break-word" },
    PLANS_BUTTON: { position: "absolute", marginTop: "10px", marginLeft: "10px" },
    PLANS_DRAWER: {
        width: "350px",
        display: "inline-block",
        flexShrink: 0,
        [`& .MuiDrawer-paper`]: { width: "350px", display: "inline-block", boxSizing: "border-box" }
    },
    CONTAINER: { paddingTop: "40px", margin: "5px 0px", textAlign: "center" },
    DATA_GRID_CONTAINER: { minWidth: "95vw", maxWidth: "95vw", minHeight: "80vh", maxHeight: "80vh" },
    DATA_GRID_GROUP_CELL: { padding: "2px" },
    DATA_GRID_CELL: { padding: "8px", maxWidth: "300px", textOverflow: "ellipsis", overflow: "hidden", whiteSpace: "pre" },
    DATA_GRID_CELL_STATUS: (currentStyle, row) => ({ backgroundColor: getRowBackgroudColor(row), ...currentStyle }),
    DATA_GRID_CELL_PLAN_FACT: currentStyle => ({ ...currentStyle, backgroundColor: "lightgrey" }),
    DATA_GRID_CELL_MATRES_CODE: (currentStyle, row) => ({ backgroundColor: getRowBackgroudColor(row), ...currentStyle }),
    PLAN_FACT_VALUE: { textAlign: "center", display: "flex", justifyContent: "center" },
    PLAN_FACT_DELIMITER: { padding: "0px 5px" },
    FACT_VALUE: { color: "blue" }
};

//------------------------------------
//Вспомогательные функции и компоненты
//------------------------------------

//Генерация представления ячейки заголовка группы
export const groupCellRender = ({ group }) => ({
    cellStyle: STYLES.DATA_GRID_GROUP_CELL,
    data: group.caption
});

//Вычисление цвета заливки для строки
const getRowBackgroudColor = row => {
    //Факт === План
    if (row["NMAIN_QUANT"] === row["NREL_FACT"]) return "lightgreen";
    //План <= (Факт + Запущено)
    if (row["NMAIN_QUANT"] <= row["NREL_FACT"] + row["NFCROUTLST_QUANT"]) return "lightblue";
    //Сумма "Количество план" = 0 или < "План"
    if (row["NSUM_PLAN"] === 0 || (row["NSUM_PLAN"] !== 0 && row["NSUM_PLAN"] < row["NMAIN_QUANT"])) {
        //"Факт" >= "План"
        if (row["NREL_FACT"] >= row["NMAIN_QUANT"]) return "#F0E68C";
    } else {
        //Сумма "Количество факт" >= сумма "Количество план"
        if (row["NSUM_FACT"] >= row["NSUM_PLAN"]) return "#F0E68C";
    }
    return "lightcoral";
};

//Генерация заливки строки исходя от значений
const dataCellRender = ({ row, columnDef, handleProdOrderClick, handleMatresCodeClick }) => {
    //Описываем общие свойства
    let cellProps = { title: row[columnDef.name] };
    //Описываем общий стиль
    let cellStyle = STYLES.DATA_GRID_CELL;
    //Для колонки "Статус"
    if (columnDef.name === "SSTATUS") return { cellProps, cellStyle: STYLES.DATA_GRID_CELL_STATUS(cellStyle, row), data: row[columnDef] };
    //Для колонки даты
    if (columnDef.name.indexOf("PLAN_FACT") >= 0) {
        //Получаем текущий день
        let curDay = new Date().getDate().toString().padStart(2, "0");
        //Формируем regex для проверки
        let regex = new RegExp(`N_${curDay}.*`, "g");
        //Если это значение текущего дня
        if (columnDef.name.match(regex)) cellStyle = STYLES.DATA_GRID_CELL_PLAN_FACT(cellStyle);
        //Если в колонке есть значение
        if (row[columnDef.name]) {
            //Разбиваем его на план/факт
            let values = row[columnDef.name].split("/");
            //Разбиваем значения на блоки
            return {
                cellProps,
                cellStyle,
                data: (
                    <Box sx={STYLES.PLAN_FACT_VALUE}>
                        <Box>{values[0]}</Box>
                        <Box sx={STYLES.PLAN_FACT_DELIMITER}>/</Box>
                        <Box sx={STYLES.FACT_VALUE}>{values[1]}</Box>
                    </Box>
                )
            };
        } else return { cellProps, cellStyle, data: row[columnDef] };
    }
    //Для колонки "Заказ"
    if (columnDef.name === "SPROD_ORDER") {
        return {
            cellProps,
            cellStyle,
            data: (
                <Link component="button" variant="body2" align="left" underline="hover" onClick={() => handleProdOrderClick(row["NRN"])}>
                    {row[columnDef.name]}
                </Link>
            )
        };
    }
    //Для колонки "Обозначение"
    if (columnDef.name === "SMATRES_CODE")
        return {
            cellProps,
            cellStyle: STYLES.DATA_GRID_CELL_MATRES_CODE(cellStyle, row),
            data: (
                <Link component="button" variant="body2" align="left" underline="hover" onClick={() => handleMatresCodeClick(row["NRN"])}>
                    {row[columnDef.name]}
                </Link>
            )
        };
    //Для всех остальных
    return { cellProps, cellStyle, data: row[columnDef] };
};

//Список каталогов планов
const PlanList = ({ plans = [], selectedPlan, filter, setFilter, onClick } = {}) => {
    //Генерация содержимого
    return (
        <div>
            <TextField
                sx={STYLES.PLANS_FINDER}
                name="planFilter"
                label="План"
                value={filter.planName}
                variant="standard"
                fullWidth
                onChange={event => {
                    setFilter(pv => ({ ...pv, planName: event.target.value }));
                }}
            ></TextField>
            <List>
                {plans.map(p => (
                    <ListItemButton key={p.NRN} selected={p.NRN === selectedPlan.NRN} onClick={() => (onClick ? onClick(p) : null)}>
                        <ListItemText primary={<Typography sx={STYLES.PLANS_LIST_ITEM_PRIMARY}>{p.SDOC_INFO}</Typography>} />
                    </ListItemButton>
                ))}
            </List>
        </div>
    );
};

//Контроль свойств - Список каталогов планов
PlanList.propTypes = {
    plans: PropTypes.array,
    selectedPlan: PropTypes.object,
    onClick: PropTypes.func,
    filter: PropTypes.object,
    setFilter: PropTypes.func
};

//-----------
//Тело модуля
//-----------

//Корневая панель производственного плана цеха
const MechRecDeptCostProdPlans = () => {
    //Собственное состояние - таблица данных
    const [state, setState] = useState({
        init: false,
        showPlanList: false,
        showIncomeFromDeps: null,
        showFcroutelst: null,
        planList: [],
        planListLoaded: false,
        selectedPlan: {},
        dataLoaded: false,
        columnsDef: [],
        orders: null,
        rows: [],
        reload: true,
        pageNumber: 1,
        morePages: true,
        fixedHeader: false,
        fixedColumns: 0
    });

    //Состояние для фильтра каталогов
    const [filter, setFilter] = useState({ planName: "" });

    //Массив отфильтрованных каталогов
    const filteredPlanCtgls = useFilteredPlans(state.planList, filter);

    //Размер страницы данных
    const DATA_GRID_PAGE_SIZE = 10;

    //Подключение к контексту взаимодействия с сервером
    const { executeStored, SERV_DATA_TYPE_CLOB } = useContext(BackEndСtx);

    //Подключение к контексту сообщений
    const { InlineMsgInfo } = useContext(MessagingСtx);

    // Инициализация каталогов планов
    const initPlans = useCallback(async () => {
        if (!state.init) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.FCPRODPLAN_DEPT_INIT",
                args: {},
                respArg: "COUT",
                isArray: name => name === "XFCPRODPLANS"
            });
            setState(pv => ({ ...pv, init: true, planList: [...(data?.XFCPRODPLANS || [])], planListLoaded: true }));
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [state.init, executeStored]);

    //Загрузка данных таблицы с сервера
    const loadData = useCallback(
        async NRN => {
            if (state.reload && NRN) {
                const data = await executeStored({
                    stored: "PKG_P8PANELS_MECHREC.FCPRODPLANSP_DEPT_DG_GET",
                    args: {
                        NFCPRODPLAN: NRN,
                        CORDERS: { VALUE: object2Base64XML(state.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                        NPAGE_NUMBER: state.pageNumber,
                        NPAGE_SIZE: DATA_GRID_PAGE_SIZE,
                        NINCLUDE_DEF: state.dataLoaded ? 0 : 1
                    },
                    respArg: "COUT",
                    attributeValueProcessor: (name, val) => (name === "caption" ? undefined : val)
                });
                setState(pv => ({
                    ...pv,
                    fixedHeader: data.XDATA_GRID.fixedHeader,
                    fixedColumns: data.XDATA_GRID.fixedColumns,
                    columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                    rows: pv.pageNumber == 1 ? [...(data.XROWS || [])] : [...pv.rows, ...(data.XROWS || [])],
                    dataLoaded: true,
                    reload: false,
                    morePages: (data.XROWS || []).length >= DATA_GRID_PAGE_SIZE
                }));
            }
        },
        // eslint-disable-next-line react-hooks/exhaustive-deps
        [state.reload, state.orders, state.dataLoaded, state.pageNumber, executeStored, SERV_DATA_TYPE_CLOB]
    );

    //При необходимости обновить данные таблицы
    useEffect(() => {
        if (state.selectedPlan.NRN) {
            loadData(state.selectedPlan.NRN);
        } else {
            setState(pv => ({ ...pv, dataLoaded: false, columnsDef: [], orders: null, rows: [], reload: true, pageNumber: 1, morePages: true }));
        }
    }, [state.selectedPlan, state.reload, loadData]);

    //При подключении компонента к странице
    useEffect(() => {
        initPlans();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    //Выбор плана
    const selectPlan = plan => {
        setState(pv => ({
            ...pv,
            showIncomeFromDeps: null,
            showFcroutelst: null,
            selectedPlan: plan,
            showPlanList: false,
            dataLoaded: false,
            columnsDef: [],
            orders: null,
            rows: [],
            reload: true,
            pageNumber: 1,
            morePages: true
        }));
    };

    //Сброс выбора плана
    const unselectPlan = () =>
        setState(pv => ({
            ...pv,
            showIncomeFromDeps: null,
            showFcroutelst: null,
            selectedPlan: {},
            showPlanList: false,
            dataLoaded: false,
            columnsDef: [],
            orders: null,
            rows: [],
            reload: true,
            pageNumber: 1,
            morePages: true
        }));

    //Обработка нажатия на элемент в списке планов
    const handlePlanClick = plan => {
        if (state.selectedPlan.NRN != plan.NRN) selectPlan(plan);
        else unselectPlan();
    };

    //При изменении состояния сортировки
    const handleOrderChanged = ({ orders }) => setState(pv => ({ ...pv, orders: [...orders], pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц
    const handlePagesCountChanged = () => setState(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //При нажатии на "Заказ"
    const handleProdOrderClick = planSp => {
        setState(pv => ({ ...pv, showIncomeFromDeps: planSp }));
    };

    //При нажатии на "Обозначение"
    const handleMatresCodeClick = planSp => {
        setState(pv => ({ ...pv, showFcroutelst: planSp }));
    };

    //Генерация содержимого
    return (
        <>
            <Fab variant="extended" sx={STYLES.PLANS_BUTTON} onClick={() => setState(pv => ({ ...pv, showPlanList: !pv.showPlanList }))}>
                Планы
            </Fab>
            <Drawer
                anchor={"left"}
                open={state.showPlanList}
                onClose={() => setState(pv => ({ ...pv, showPlanList: false }))}
                sx={STYLES.PLANS_DRAWER}
            >
                <PlanList
                    plans={filteredPlanCtgls}
                    selectedPlan={state.selectedPlan}
                    filter={filter}
                    setFilter={setFilter}
                    onClick={handlePlanClick}
                />
            </Drawer>
            <div style={STYLES.CONTAINER}>
                {state.dataLoaded ? (
                    <Typography variant={"h6"}>
                        {`Производственный план цеха "${state.selectedPlan.SSUBDIV}" на ${state.selectedPlan.SPERIOD}`}
                    </Typography>
                ) : null}
                <Grid container spacing={1}>
                    <Grid item xs={12}>
                        <Box pt={1} display="flex" justifyContent="center" alignItems="center">
                            {state.dataLoaded ? (
                                <P8PDataGrid
                                    {...P8P_DATA_GRID_CONFIG_PROPS}
                                    containerComponentProps={{ elevation: 6, style: STYLES.DATA_GRID_CONTAINER }}
                                    fixedHeader={state.fixedHeader}
                                    fixedColumns={state.fixedColumns}
                                    columnsDef={state.columnsDef}
                                    rows={state.rows}
                                    size={P8P_DATA_GRID_SIZE.MEDIUM}
                                    morePages={state.morePages}
                                    reloading={state.reload}
                                    onOrderChanged={handleOrderChanged}
                                    onPagesCountChanged={handlePagesCountChanged}
                                    dataCellRender={prms => dataCellRender({ ...prms, handleProdOrderClick, handleMatresCodeClick })}
                                    groupCellRender={groupCellRender}
                                />
                            ) : !state.selectedPlan.NRN ? (
                                <InlineMsgInfo okBtn={false} text={"Укажите план для отображения его спецификаций"} />
                            ) : null}
                        </Box>
                    </Grid>
                </Grid>
                {state.showIncomeFromDeps ? (
                    <IncomFromDepsDataGridDialog task={state.showIncomeFromDeps} onClose={() => handleProdOrderClick(null)} />
                ) : null}
                {state.showFcroutelst ? (
                    <CostRouteListsDataGridDialog task={state.showFcroutelst} onClose={() => handleMatresCodeClick(null)} />
                ) : null}
            </div>
        </>
    );
};

//----------------
//Интерфейс модуля
//----------------

export { MechRecDeptCostProdPlans };

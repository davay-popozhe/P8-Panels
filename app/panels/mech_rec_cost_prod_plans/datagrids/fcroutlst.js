/*
    Парус 8 - Панели мониторинга - ПУП - Производственная программа
    Компонент панели: Таблица маршрутных листов
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Typography, Box, Paper } from "@mui/material"; //Интерфейсные элементы
import { P8PDataGrid, P8P_DATA_GRID_SIZE } from "../../../components/p8p_data_grid"; //Таблица данных
import { P8P_DATA_GRID_CONFIG_PROPS } from "../../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { GoodsPartiesDataGrid } from "./goodparties";
import { CostDeliveryListsDataGrid } from "./fcdeliverylistsp";
import { useCostRouteLists } from "./backend_dg"; //Собственные хуки таблиц

//---------
//Константы
//---------

//Стили
const STYLES = {
    CONTAINER: { textAlign: "center" },
    TABLE: { paddingTop: "15px" },
    TABLE_SUM: { textAlign: "right", paddingTop: "5px", paddingRight: "15px" }
};

//---------------------------------------------
//Вспомогательные функции форматирования данных
//---------------------------------------------

//Генерация представления расширения строки
export const rowExpandRender = ({ row }) => {
    return (
        <Paper elevation={4}>
            <CostDeliveryListsDataGrid mainRowRN={row.NRN} />
        </Paper>
    );
};

//-----------
//Тело модуля
//-----------

//Таблица маршрутных листов
const CostRouteListsDataGrid = ({ task, taskType }) => {
    //Собственное состояние - таблица данных
    const [costRouteLists, setCostRouteLists] = useCostRouteLists(task, taskType);

    //Необходимость разворачивать строки только для типа задачи 1
    const needExpand = taskType === 1;

    //При изменении состояния сортировки
    const handleOrderChanged = ({ orders }) => setCostRouteLists(pv => ({ ...pv, orders: [...orders], pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц
    const handlePagesCountChanged = () => setCostRouteLists(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //Генерация содержимого
    return (
        <div style={STYLES.CONTAINER}>
            <Typography variant={"h6"}>Маршрутные листы</Typography>
            {costRouteLists.dataLoaded ? (
                <>
                    <Box sx={STYLES.TABLE}>
                        <P8PDataGrid
                            {...P8P_DATA_GRID_CONFIG_PROPS}
                            columnsDef={costRouteLists.columnsDef}
                            rows={costRouteLists.rows}
                            size={P8P_DATA_GRID_SIZE.LARGE}
                            morePages={costRouteLists.morePages}
                            reloading={costRouteLists.reload}
                            expandable={needExpand}
                            rowExpandRender={needExpand ? rowExpandRender : null}
                            onOrderChanged={handleOrderChanged}
                            onPagesCountChanged={handlePagesCountChanged}
                        />
                        {taskType === 0 ? (
                            <Typography style={STYLES.TABLE_SUM} variant="subtitle2">
                                Итого: {costRouteLists.quantPlanSum}
                            </Typography>
                        ) : null}
                    </Box>
                    {taskType === 0
                        ? costRouteLists.uniqueNomns.map(item => (
                              <GoodsPartiesDataGrid
                                  key={item.NRN}
                                  mainRowRN={item.NRN}
                                  quantPlanSum={costRouteLists.quantPlanSum}
                                  nomenclature={item.SMATRES_PLAN_NOMEN.toString()}
                              />
                          ))
                        : null}
                </>
            ) : null}
        </div>
    );
};

//Контроль свойств - Таблица маршрутных листов
CostRouteListsDataGrid.propTypes = {
    task: PropTypes.number.isRequired,
    taskType: PropTypes.number.isRequired
};

//----------------
//Интерфейс модуля
//----------------

export { CostRouteListsDataGrid };

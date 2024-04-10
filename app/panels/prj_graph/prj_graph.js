/*
    Парус 8 - Панели мониторинга - ПУП - Графики проектов
    Панель мониторинга: Корневая панель графиков проекта
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useContext, useCallback, useEffect } from "react"; //Классы React
import { Grid, Box } from "@mui/material"; //Интерфейсные элементы
import { P8PDataGrid, P8P_DATA_GRID_SIZE } from "../../components/p8p_data_grid"; //Таблица данных
import { P8P_DATA_GRID_CONFIG_PROPS } from "../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { ApplicationСtx } from "../../context/application"; //Контекст приложения
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { dataCellRender, groupCellRender } from "./layouts"; //Дополнительная разметка и вёрстка клиентских элементов

//-----------
//Тело модуля
//-----------

//Графики проектов
const PrjGraph = () => {
    //Собственное состояние - таблица данных
    const [dataGrid, setdataGrid] = useState({
        dataLoaded: false,
        columnsDef: [],
        groups: [],
        rows: [],
        reload: true
    });

    //Подключение к контексту приложения
    const { pOnlineShowDocument } = useContext(ApplicationСtx);

    //Подключение к контексту взаимодействия с сервером
    const { executeStored } = useContext(BackEndСtx);

    //Загрузка данных таблицы с сервера
    const loadData = useCallback(async () => {
        if (dataGrid.reload) {
            const data = await executeStored({ stored: "PKG_P8PANELS_PROJECTS.GRAPH", args: {}, respArg: "COUT" });
            setdataGrid(pv => ({
                ...pv,
                columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                rows: [...(data.XROWS || [])],
                groups: [...(data.XGROUPS || [])],
                dataLoaded: true,
                reload: false
            }));
        }
    }, [dataGrid.reload, executeStored]);

    //При необходимости обновить данные таблицы
    useEffect(() => {
        loadData();
    }, [dataGrid.reload, loadData]);

    //Генерация содержимого
    return (
        <div>
            <Grid container spacing={1}>
                <Grid item xs={12}>
                    <Box p={5}>
                        {dataGrid.dataLoaded ? (
                            <P8PDataGrid
                                {...P8P_DATA_GRID_CONFIG_PROPS}
                                columnsDef={dataGrid.columnsDef}
                                groups={dataGrid.groups}
                                rows={dataGrid.rows}
                                size={P8P_DATA_GRID_SIZE.LARGE}
                                reloading={dataGrid.reload}
                                dataCellRender={prms => dataCellRender({ ...prms, pOnlineShowDocument })}
                                groupCellRender={prms => groupCellRender({ ...prms, pOnlineShowDocument })}
                                containerComponentProps={{ elevation: 6, sx: { overflowX: "visible" } }}
                            />
                        ) : null}
                    </Box>
                </Grid>
            </Grid>
        </div>
    );
};

//----------------
//Интерфейс модуля
//----------------

export { PrjGraph };

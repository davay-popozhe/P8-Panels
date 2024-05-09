/*
    Парус 8 - Панели мониторинга - ПУП - Загрузка цеха
    Панель мониторинга: Корневая панель загрузки цеха
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useContext, useCallback, useEffect } from "react"; //Классы React
import { Typography, Box, Grid } from "@mui/material"; //Интерфейсные элементы
import { object2Base64XML } from "../../core/utils"; //Вспомогательные процедуры и функции
import { P8PDataGrid, P8P_DATA_GRID_SIZE } from "../../components/p8p_data_grid"; //Таблица данных
import { P8P_DATA_GRID_CONFIG_PROPS } from "../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером

//---------
//Константы
//---------

//Размер страницы данных
const DATA_GRID_PAGE_SIZE = 5;

//Стили
const STYLES = {
    CONTAINER: { textAlign: "center", paddingTop: "20px" },
    TITLE: { paddingBottom: "15px" },
    DATA_GRID_CONTAINER: { minWidth: "95vw", maxWidth: "95vw", minHeight: "80vh", maxHeight: "80vh" },
    DATA_GRID_CELL: (row, columnDef) => ({
        padding: "8px",
        textOverflow: "ellipsis",
        overflow: "hidden",
        whiteSpace: "pre",
        ...(columnDef.name.match(/N.*_VALUE/) && row[columnDef.name]
            ? { backgroundColor: row[`${columnDef.name.substring(0, 12)}_TYPE`] === 0 ? "lightgrey" : "lightgreen" }
            : {})
    })
};

//------------------------------------
//Вспомогательные функции и компоненты
//------------------------------------

//Генерация заливки строки исходя от значений
const dataCellRender = ({ row, columnDef }) => ({
    cellProps: { title: row[columnDef.name] },
    cellStyle: STYLES.DATA_GRID_CELL(row, columnDef),
    data: row[columnDef]
});

//-----------
//Тело модуля
//-----------

//Корневая панель загрузки цеха
const MechRecDeptCostJobs = () => {
    //Собственное состояние - таблица данных
    const [costJobs, setCostJobs] = useState({
        subdiv: null,
        dataLoaded: false,
        columnsDef: [],
        filters: [],
        orders: null,
        rows: [],
        reload: true,
        pageNumber: 1,
        morePages: true,
        fixedHeader: false,
        fixedColumns: 0
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored, SERV_DATA_TYPE_CLOB } = useContext(BackEndСtx);

    //Загрузка данных таблицы с сервера
    const loadData = useCallback(async () => {
        if (costJobs.reload) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.FCJOBS_DEP_LOAD_DG_GET",
                args: {
                    CFILTERS: { VALUE: object2Base64XML(costJobs.filters, { arrayNodeName: "filters" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    CORDERS: { VALUE: object2Base64XML(costJobs.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    NPAGE_NUMBER: costJobs.pageNumber,
                    NPAGE_SIZE: DATA_GRID_PAGE_SIZE,
                    NINCLUDE_DEF: costJobs.dataLoaded ? 0 : 1
                },
                respArg: "COUT"
            });
            setCostJobs(pv => ({
                ...pv,
                fixedHeader: data.XFCJOBS.XDATA.XDATA_GRID.fixedHeader,
                fixedColumns: data.XFCJOBS.XDATA.XDATA_GRID.fixedColumns,
                subdiv: data.XINFO.SSUBDIV,
                columnsDef: data.XFCJOBS.XDATA.XCOLUMNS_DEF ? [...data.XFCJOBS.XDATA.XCOLUMNS_DEF] : pv.columnsDef,
                rows: pv.pageNumber == 1 ? [...(data.XFCJOBS.XDATA.XROWS || [])] : [...pv.rows, ...(data.XFCJOBS.XDATA.XROWS || [])],
                dataLoaded: true,
                reload: false,
                morePages: (data.XFCJOBS.XDATA.XROWS || []).length >= DATA_GRID_PAGE_SIZE
            }));
        }
    }, [costJobs.reload, costJobs.filters, costJobs.orders, costJobs.dataLoaded, costJobs.pageNumber, executeStored, SERV_DATA_TYPE_CLOB]);

    //При изменении состояния фильтра
    const handleFilterChanged = ({ filters }) => setCostJobs(pv => ({ ...pv, filters: [...filters], pageNumber: 1, reload: true }));

    //При изменении состояния сортировки
    const handleOrderChanged = ({ orders }) => setCostJobs(pv => ({ ...pv, orders: [...orders], pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц
    const handlePagesCountChanged = () => setCostJobs(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //При необходимости обновить данные таблицы
    useEffect(() => {
        loadData();
    }, [costJobs.reload, loadData]);

    //Генерация содержимого
    return (
        <div style={STYLES.CONTAINER}>
            <Typography sx={STYLES.TITLE} variant={"h6"}>
                {costJobs.dataLoaded ? `Загрузка станков "${costJobs.subdiv}"` : null}
            </Typography>
            <Grid container spacing={1}>
                <Grid item xs={12}>
                    <Box pt={1} display="flex" justifyContent="center" alignItems="center">
                        {costJobs.dataLoaded ? (
                            <P8PDataGrid
                                {...P8P_DATA_GRID_CONFIG_PROPS}
                                containerComponentProps={{ elevation: 6, style: STYLES.DATA_GRID_CONTAINER }}
                                fixedHeader={costJobs.fixedHeader}
                                fixedColumns={costJobs.fixedColumns}
                                columnsDef={costJobs.columnsDef}
                                rows={costJobs.rows}
                                size={P8P_DATA_GRID_SIZE.LARGE}
                                morePages={costJobs.morePages}
                                reloading={costJobs.reload}
                                onOrderChanged={handleOrderChanged}
                                onFilterChanged={handleFilterChanged}
                                onPagesCountChanged={handlePagesCountChanged}
                                dataCellRender={prms => dataCellRender({ ...prms })}
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

export { MechRecDeptCostJobs };

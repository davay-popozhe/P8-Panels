/*
    Парус 8 - Панели мониторинга - ПУП - Производственный план цеха
    Компонент панели: Таблица маршрутных листов
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useCallback, useEffect, useContext } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Typography, Box, Paper, IconButton, Icon, Dialog, DialogContent, DialogActions, Button, TextField } from "@mui/material"; //Интерфейсные элементы
import { P8PDataGrid, P8P_DATA_GRID_SIZE } from "../../components/p8p_data_grid"; //Таблица данных
import { P8P_DATA_GRID_CONFIG_PROPS } from "../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { object2Base64XML } from "../../core/utils"; //Вспомогательные функции
import { CostRouteListsOrdDataGrid } from "./fcroutlstord"; //Состояние таблицы заказов маршрутных листов
import { ApplicationСtx } from "../../context/application"; //Контекст приложения

//---------
//Константы
//---------

//Стили
const STYLES = {
    CONTAINER: { textAlign: "center" },
    TABLE: { paddingTop: "15px" },
    TABLE_SUM: { textAlign: "right", paddingTop: "5px", paddingRight: "15px" },
    DIALOG_EDITOR: { maxWidth: "250px" },
    DIALOG_BUTTONS: { marginTop: "10px", width: "240px" }
};

//---------------------------------------------
//Вспомогательные функции форматирования данных
//---------------------------------------------

//Генерация представления расширения строки
export const rowExpandRender = ({ row }) => {
    return (
        <Paper elevation={4}>
            <CostRouteListsOrdDataGrid mainRowRN={row.NRN} />
        </Paper>
    );
};

//Форматирование значений колонок
const dataCellRender = ({ row, columnDef, handlePriorEditOpen, handleOrderEditOpen }) => {
    //!!! Пока отключено - не удалять
    // switch (columnDef.name) {
    //     case "NPRIOR_PARTY":
    //         return {
    //             data: (
    //                 <>
    //                     {row["NPRIOR_PARTY"]}
    //                     <IconButton edge="end" title="Изменить приоритет" onClick={() => handlePriorEditOpen(row["NRN"], row["NPRIOR_PARTY"])}>
    //                         <Icon>edit</Icon>
    //                     </IconButton>
    //                 </>
    //             )
    //         };
    //     case "NCHANGE_FACEACC":
    //         return {
    //             data: (
    //                 <Box sx={{ textAlign: "center" }}>
    //                     <IconButton title="Изменить заказ" onClick={() => handleOrderEditOpen(row["NRN"], row["SPROD_ORDER"])}>
    //                         <Icon>inventory</Icon>
    //                     </IconButton>
    //                 </Box>
    //             )
    //         };
    // }
    return {
        data: row[columnDef]
    };
};

//-----------
//Тело модуля
//-----------

//Таблица маршрутных листов
const CostRouteListsDataGrid = ({ task }) => {
    //Собственное состояние - таблица данных
    const [costRouteLists, setCostRouteLists] = useState({
        dataLoaded: false,
        columnsDef: [],
        orders: null,
        rows: [],
        reload: true,
        pageNumber: 1,
        morePages: true,
        editPriorNRN: null,
        editPriorValue: null,
        editOrderNRN: null,
        editOrderValue: null
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored, SERV_DATA_TYPE_CLOB } = useContext(BackEndСtx);

    //Подключение к контексту приложения
    const { pOnlineShowDictionary } = useContext(ApplicationСtx);

    //Размер страницы данных
    const DATA_GRID_PAGE_SIZE = 5;

    //Загрузка данных таблицы с сервера
    const loadData = useCallback(async () => {
        if (costRouteLists.reload) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.FCROUTLST_DEPT_DG_GET",
                args: {
                    NFCPRODPLANSP: task,
                    CORDERS: { VALUE: object2Base64XML(costRouteLists.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    NPAGE_NUMBER: costRouteLists.pageNumber,
                    NPAGE_SIZE: DATA_GRID_PAGE_SIZE,
                    NINCLUDE_DEF: costRouteLists.dataLoaded ? 0 : 1
                },
                respArg: "COUT"
            });
            setCostRouteLists(pv => ({
                ...pv,
                columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                rows: pv.pageNumber == 1 ? [...(data.XROWS || [])] : [...pv.rows, ...(data.XROWS || [])],
                dataLoaded: true,
                reload: false,
                morePages: (data.XROWS || []).length >= DATA_GRID_PAGE_SIZE
            }));
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [
        costRouteLists.reload,
        costRouteLists.filters,
        costRouteLists.orders,
        costRouteLists.dataLoaded,
        costRouteLists.pageNumber,
        executeStored,
        SERV_DATA_TYPE_CLOB
    ]);

    //При необходимости обновить данные таблицы
    useEffect(() => {
        loadData();
    }, [costRouteLists.reload, loadData]);

    //При изменении состояния сортировки
    const handleOrderChanged = ({ orders }) => setCostRouteLists(pv => ({ ...pv, orders: [...orders], pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц
    const handlePagesCountChanged = () => setCostRouteLists(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //При открытии изменения приоритета партии
    const handlePriorEditOpen = (NRN, nPriorValue) => {
        setCostRouteLists(pv => ({ ...pv, editPriorNRN: NRN, editPriorValue: nPriorValue }));
    };

    //При закрытии изменения приоритета партии
    const handlePriorEditClose = () => {
        setCostRouteLists(pv => ({ ...pv, editPriorNRN: null, editPriorValue: null }));
    };

    //При изменении значения приоритета партии
    const handlePriorFormChanged = e => {
        setCostRouteLists(pv => ({ ...pv, editPriorValue: e.target.value }));
    };

    //Изменение приоритета
    const priorChange = useCallback(
        async (NRN, PriorValue, rows) => {
            try {
                await executeStored({
                    stored: "PKG_P8PANELS_MECHREC.FCROUTLST_PRIOR_PARTY_UPDATE",
                    args: { NFCROUTLST: NRN, SPRIOR_PARTY: PriorValue }
                });
                //Изменяем значение приоритета у нужного
                rows[rows.findIndex(obj => obj.NRN == NRN)].NPRIOR_PARTY = PriorValue;
                //Актуализируем строки таблицы
                setCostRouteLists(pv => ({ ...pv, rows: rows }));
                //Закрываем окно
                handlePriorEditClose();
            } catch (e) {
                throw new Error(e.message);
            }
        },
        [executeStored]
    );

    //При нажатии на изменение приоритета партии
    const handlePriorChange = () => {
        //Изменяем значение
        priorChange(costRouteLists.editPriorNRN, costRouteLists.editPriorValue, costRouteLists.rows);
    };

    //При открытии изменения заказа
    const handleOrderEditOpen = (NRN, sProdOrderValue) => {
        setCostRouteLists(pv => ({ ...pv, editOrderNRN: NRN, editOrderValue: sProdOrderValue }));
    };

    //При закрытии изменения заказа
    const handleOrderEditClose = () => {
        setCostRouteLists(pv => ({ ...pv, editOrderNRN: null, editOrderValue: null }));
    };

    //Изменение заказа
    const setEditOrderValue = value => {
        console.log(value);
        setCostRouteLists(pv => ({ ...pv, editOrderValue: value }));
    };

    //При изменении значения заказа
    const handleOrderFormChanged = e => {
        setEditOrderValue(e.target.value);
    };

    //При нажатии на изменение заказа
    const handleOrderChange = () => {
        //Изменяем значение
        //priorChange(costRouteLists.editPriorNRN, costRouteLists.editPriorValue);
        //Закрываем окно
        handleOrderEditClose();
    };

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
                            expandable={true}
                            rowExpandRender={rowExpandRender}
                            onOrderChanged={handleOrderChanged}
                            onPagesCountChanged={handlePagesCountChanged}
                            dataCellRender={prms => dataCellRender({ ...prms, handlePriorEditOpen, handleOrderEditOpen })}
                        />
                    </Box>
                </>
            ) : null}
            {costRouteLists.editPriorNRN ? (
                <Dialog open onClose={() => handlePriorEditClose(null)} sx={STYLES.DIALOG_EDITOR}>
                    <DialogContent>
                        <Box>
                            <TextField
                                name="editPriorValue"
                                label="Новое значение приоритета"
                                variant="standard"
                                fullWidth
                                type="number"
                                value={costRouteLists.editPriorValue}
                                onChange={handlePriorFormChanged}
                            />
                            <Box>
                                <Button onClick={handlePriorChange} variant="contained" sx={STYLES.DIALOG_BUTTONS}>
                                    Изменить
                                </Button>
                            </Box>
                        </Box>
                    </DialogContent>
                    <DialogActions>
                        <Button onClick={() => handlePriorEditClose(null)}>Закрыть</Button>
                    </DialogActions>
                </Dialog>
            ) : null}
            {costRouteLists.editOrderNRN ? (
                <Dialog open onClose={() => handleOrderEditClose(null)} sx={STYLES.DIALOG_EDITOR}>
                    <DialogContent>
                        <Box>
                            <TextField
                                name="editOrderValue"
                                label="Заказ"
                                variant="standard"
                                fullWidth
                                value={costRouteLists.editOrderValue}
                                onChange={handleOrderFormChanged}
                            />
                            <Box>
                                <Button
                                    sx={STYLES.DIALOG_BUTTONS}
                                    variant="contained"
                                    onClick={() => {
                                        pOnlineShowDictionary({
                                            unitCode: "FaceAccounts",
                                            inputParameters: [
                                                {
                                                    name: "in_NUMB",
                                                    value: costRouteLists.editOrderValue
                                                }
                                            ],
                                            callBack: res => (res.success === true ? setEditOrderValue(res.outParameters.out_NUMB) : null)
                                        });
                                    }}
                                >
                                    Лицевые счета
                                </Button>
                                <Box>
                                    <Button sx={STYLES.DIALOG_BUTTONS} onClick={handleOrderChange} variant="contained">
                                        Изменить
                                    </Button>
                                </Box>
                            </Box>
                        </Box>
                    </DialogContent>
                    <DialogActions>
                        <Button onClick={() => handleOrderEditClose(null)}>Закрыть</Button>
                    </DialogActions>
                </Dialog>
            ) : null}
        </div>
    );
};

//Контроль свойств - Таблица маршрутных листов
CostRouteListsDataGrid.propTypes = {
    task: PropTypes.number.isRequired
};

//----------------
//Интерфейс модуля
//----------------

export { CostRouteListsDataGrid };

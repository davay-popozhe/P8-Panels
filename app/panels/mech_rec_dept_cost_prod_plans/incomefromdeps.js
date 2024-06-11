/*
    Парус 8 - Панели мониторинга - ПУП - Производственный план цеха
    Компонент панели: Таблица сдачи продукции
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useCallback, useEffect, useContext } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Typography, Box, Dialog, DialogContent, DialogActions, Button } from "@mui/material"; //Интерфейсные элементы
import { P8PDataGrid, P8P_DATA_GRID_SIZE } from "../../components/p8p_data_grid"; //Таблица данных
import { P8P_DATA_GRID_CONFIG_PROPS } from "../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { object2Base64XML, formatDateRF } from "../../core/utils"; //Вспомогательные функции

//---------
//Константы
//---------

//Стили
const STYLES = {
    CONTAINER: { textAlign: "center" },
    TABLE: { paddingTop: "15px" }
};

//-----------
//Тело модуля
//-----------

//Таблица сдачи продукции
const IncomFromDepsDataGrid = ({ task }) => {
    //Собственное состояние - таблица данных
    const [incomFromDeps, setIncomFromDeps] = useState({
        dataLoaded: false,
        columnsDef: [],
        orders: null,
        rows: [],
        reload: true,
        pageNumber: 1,
        morePages: true
    });

    //Размер страницы данных
    const DATA_GRID_PAGE_SIZE = 10;

    //Подключение к контексту взаимодействия с сервером
    const { executeStored, SERV_DATA_TYPE_CLOB } = useContext(BackEndСtx);

    //Загрузка данных таблицы с сервера
    const loadData = useCallback(async () => {
        if (incomFromDeps.reload) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.INCOMEFROMDEPS_DEPT_DG_GET",
                args: {
                    NFCPRODPLANSP: task,
                    CORDERS: { VALUE: object2Base64XML(incomFromDeps.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    NPAGE_NUMBER: incomFromDeps.pageNumber,
                    NPAGE_SIZE: DATA_GRID_PAGE_SIZE,
                    NINCLUDE_DEF: incomFromDeps.dataLoaded ? 0 : 1
                },
                attributeValueProcessor: (name, val) => (["DDUE_DATE"].includes(name) ? formatDateRF(val) : val),
                respArg: "COUT"
            });
            setIncomFromDeps(pv => ({
                ...pv,
                columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                rows: pv.pageNumber == 1 ? [...(data.XROWS || [])] : [...pv.rows, ...(data.XROWS || [])],
                dataLoaded: true,
                reload: false,
                morePages: (data.XROWS || []).length >= DATA_GRID_PAGE_SIZE
            }));
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [incomFromDeps.reload, incomFromDeps.orders, incomFromDeps.dataLoaded, incomFromDeps.pageNumber, executeStored, SERV_DATA_TYPE_CLOB]);

    //При необходимости обновить данные таблицы
    useEffect(() => {
        loadData();
    }, [incomFromDeps.reload, loadData]);

    //При изменении состояния сортировки
    const handleOrderChanged = ({ orders }) => setIncomFromDeps(pv => ({ ...pv, orders: [...orders], pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц
    const handlePagesCountChanged = () => setIncomFromDeps(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //Генерация содержимого
    return (
        <div style={STYLES.CONTAINER}>
            <Typography variant={"h6"}>Сдача продукции</Typography>
            <Box sx={STYLES.TABLE}>
                {incomFromDeps.dataLoaded ? (
                    <P8PDataGrid
                        {...P8P_DATA_GRID_CONFIG_PROPS}
                        columnsDef={incomFromDeps.columnsDef}
                        rows={incomFromDeps.rows}
                        size={P8P_DATA_GRID_SIZE.LARGE}
                        morePages={incomFromDeps.morePages}
                        reloading={incomFromDeps.reload}
                        onOrderChanged={handleOrderChanged}
                        onPagesCountChanged={handlePagesCountChanged}
                    />
                ) : null}
            </Box>
        </div>
    );
};

//Контроль свойств - Таблица сдачи продукции
IncomFromDepsDataGrid.propTypes = {
    task: PropTypes.number.isRequired
};

//Диалог с таблицей сдачи продукции
const IncomFromDepsDataGridDialog = ({ task, onClose }) => {
    return (
        <Dialog open onClose={onClose ? onClose : null} fullWidth maxWidth="xl">
            <DialogContent>
                <IncomFromDepsDataGrid task={task} />
            </DialogContent>
            {onClose ? (
                <DialogActions>
                    <Button onClick={onClose}>Закрыть</Button>
                </DialogActions>
            ) : null}
        </Dialog>
    );
};

//Контроль свойств - Диалог с таблицей сдачи продукции
IncomFromDepsDataGridDialog.propTypes = {
    task: PropTypes.number.isRequired,
    onClose: PropTypes.func
};

//----------------
//Интерфейс модуля
//----------------

export { IncomFromDepsDataGridDialog };

/*
    Парус 8 - Панели мониторинга - ПУП - Мониторинг сборки изделий
    Панель мониторинга: Детализация по объекту
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Box, Grid, Container, Button, Typography } from "@mui/material"; //Интерфейсные элементы
import { ProgressBox } from "../elements/progressBox"; //Блок информации по прогрессу объекта
import { P8PDataGrid, P8P_DATA_GRID_SIZE } from "../../../components/p8p_data_grid"; //Таблица данных
import { P8P_DATA_GRID_CONFIG_PROPS } from "../../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { useCostProductComposition, useCostRouteLists, useCostDeliverySheets } from "../backend"; //Компоненты панели

//---------
//Константы
//---------

//Стили
const STYLES = {
    TABLE_INFO_MAIN: {
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        flexDirection: "column",
        border: "1px solid",
        borderRadius: "25px",
        height: "35vh"
    },
    TABLE_INFO_SUB: {
        margin: "21.6px 0px",
        maxHeight: "100%",
        overflow: "auto",
        textAlign: "center",
        width: "100%"
    },
    DETAIL_INFO: {
        display: "flex",
        justifyContent: "space-around",
        alignItems: "center",
        border: "1px solid",
        borderRadius: "25px",
        height: "17vh"
    },
    PRODUCT_SELECTOR: {
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        flexDirection: "column",
        border: "1px solid",
        borderRadius: "25px",
        height: "53vh",
        marginTop: "16px"
    },
    PLAN_INFO_MAIN: {
        display: "flex",
        flexDirection: "column",
        gap: "16px"
    },
    PLAN_INFO_SUB: {
        display: "flex",
        justifyContent: "space-between",
        width: "280px",
        borderBottom: "1px solid"
    }
};

//------------------------------------
//Вспомогательные функции и компоненты
//------------------------------------

//Информация об объекте
const CardDetailInfo = ({ cardInfo }) => {
    return (
        <>
            <Box sx={STYLES.PLAN_INFO_MAIN}>
                <Box sx={STYLES.PLAN_INFO_SUB}>
                    <Typography variant="UDO_body1" mt={1}>
                        Номер борта:
                    </Typography>
                    <Typography variant="subtitle2">{cardInfo.SNUMB}</Typography>
                </Box>
                <Box sx={STYLES.PLAN_INFO_SUB}>
                    <Typography variant="UDO_body1" mt={1}>
                        Год выпуска:
                    </Typography>
                    <Typography variant="subtitle2">{cardInfo.NYEAR}</Typography>
                </Box>
            </Box>
            <ProgressBox
                prms={{
                    NPROGRESS: cardInfo.NPROGRESS,
                    SDETAIL: cardInfo.SDETAIL,
                    width: "110px",
                    height: "110px",
                    progressVariant: "subtitle2",
                    detailVariant: "body3"
                }}
            />
        </>
    );
};

//Контроль свойств - Информация об объекте
CardDetailInfo.propTypes = {
    cardInfo: PropTypes.object
};

//Детали объекта
const CardSelector = ({ products, setCostProductComposition }) => {
    //При выборе детали в SVG
    const handleProductClick = product => {
        setCostProductComposition(pv => ({ ...pv, selectedProduct: product }));
    };

    return (
        <>
            <Box sx={STYLES.PLAN_INFO_MAIN}>
                {products.map(el => (
                    <Button key={el.NRN} onClick={() => handleProductClick(el.NRN)}>{`${el.SNAME}`}</Button>
                ))}
            </Box>
        </>
    );
};

//Контроль свойств - Детали объекта
CardSelector.propTypes = {
    products: PropTypes.array,
    setCostProductComposition: PropTypes.func
};

//Генерация представления ячейки заголовка
const headCellRender = ({ columnDef }) => {
    //Описываем общий стиль
    let cellStyle = { padding: "2px 5px", fontSize: "12px", textAlign: "center", lineHeight: "1rem" };
    let stackProps = { justifyContent: "center" };
    //Дополнительные свойства
    switch (columnDef.name) {
        case "NREMN_LABOUR":
            //Добавляем максимальную ширину
            cellStyle = { ...cellStyle, maxWidth: "90px" };
            break;
        case "NDEFICIT":
            //Добавляем максимальную ширину
            cellStyle = { ...cellStyle, maxWidth: "55px" };
            break;
        case "NAPPLICABILITY":
            //Добавляем максимальную ширину
            cellStyle = { ...cellStyle, maxWidth: "90px" };
            break;
        default:
            break;
    }
    return {
        stackProps,
        cellStyle
    };
};

//Генерация заливки строки исходя от значений
const dataCellRender = ({ row, columnDef }) => {
    //Описываем общий стиль
    let cellStyle = { padding: "2px 5px", fontSize: "12px" };
    //Для всех кроме содержания и номенклатуры добавляем выравнивание
    switch (columnDef.name) {
        case "SOPERATION":
            break;
        case "SNOMEN":
            break;
        default:
            //Добавляем выравнивание
            cellStyle = { ...cellStyle, textAlign: "center" };
            break;
    }
    return {
        cellStyle,
        data: row[columnDef]
    };
};

//-----------
//Тело модуля
//-----------

//Детализация по объекту
const CardDetail = ({ card, handleBackClick }) => {
    //Собственное состояние - данные производственных составов SVG
    const [costProductComposition, setCostProductComposition] = useCostProductComposition(card.NRN);
    //Собственное состояние - таблица данных маршрутных листов
    const [costRouteLists, setCostRouteLists] = useCostRouteLists(card.NRN, costProductComposition.selectedProduct);
    //Собственное состояние - таблица данных комплектовочных ведомостей
    const [сostDeliverySheets, setСostDeliverySheets] = useCostDeliverySheets(card.NRN, costProductComposition.selectedProduct);

    //При изменении состояния сортировки маршрутных листов
    const costRouteListsOrderChanged = ({ orders }) => setCostRouteLists(pv => ({ ...pv, orders: [...orders], pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц маршрутных листов
    const costRouteListsPagesCountChanged = () => setCostRouteLists(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //При изменении состояния сортировки комплектовочных ведомостей
    const СostDeliverySheetsOrderChanged = ({ orders }) => setСostDeliverySheets(pv => ({ ...pv, orders: [...orders], pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц комплектовочных ведомостей
    const СostDeliverySheetsPagesCountChanged = () => setСostDeliverySheets(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    return (
        <Container>
            <Button onClick={() => handleBackClick()}>Назад</Button>
            <Grid container spacing={2}>
                <Grid item xs={5}>
                    <Box sx={STYLES.TABLE_INFO_MAIN}>
                        <Box sx={STYLES.TABLE_INFO_SUB}>
                            {!costRouteLists.dataLoaded ? (
                                <Typography variant="UDO_body2">Выберите агрегат самолёта, чтобы увидеть информацию</Typography>
                            ) : costRouteLists.rows.length === 0 ? (
                                <Typography variant="subtitle2">Нет данных по МК</Typography>
                            ) : (
                                <>
                                    <Typography variant="h4">Маршрутная карта</Typography>
                                    <P8PDataGrid
                                        {...P8P_DATA_GRID_CONFIG_PROPS}
                                        columnsDef={costRouteLists.columnsDef}
                                        rows={costRouteLists.rows}
                                        size={P8P_DATA_GRID_SIZE.SMALL}
                                        morePages={costRouteLists.morePages}
                                        reloading={costRouteLists.reload}
                                        dataCellRender={dataCellRender}
                                        headCellRender={headCellRender}
                                        onOrderChanged={costRouteListsOrderChanged}
                                        onPagesCountChanged={costRouteListsPagesCountChanged}
                                    />
                                </>
                            )}
                        </Box>
                    </Box>
                    <Box sx={STYLES.TABLE_INFO_MAIN} mt={2}>
                        <Box sx={STYLES.TABLE_INFO_SUB}>
                            {!сostDeliverySheets.dataLoaded ? (
                                <Typography variant="UDO_body2">Выберите агрегат самолёта, чтобы увидеть информацию</Typography>
                            ) : сostDeliverySheets.rows.length === 0 ? (
                                <Typography variant="subtitle2">Нет данных по КВ</Typography>
                            ) : (
                                <>
                                    <Typography variant="h4">Дефицит по КВ</Typography>
                                    <P8PDataGrid
                                        {...P8P_DATA_GRID_CONFIG_PROPS}
                                        columnsDef={сostDeliverySheets.columnsDef}
                                        rows={сostDeliverySheets.rows}
                                        size={P8P_DATA_GRID_SIZE.SMALL}
                                        morePages={сostDeliverySheets.morePages}
                                        reloading={сostDeliverySheets.reload}
                                        dataCellRender={dataCellRender}
                                        headCellRender={headCellRender}
                                        onOrderChanged={СostDeliverySheetsOrderChanged}
                                        onPagesCountChanged={СostDeliverySheetsPagesCountChanged}
                                    />
                                </>
                            )}
                        </Box>
                    </Box>
                </Grid>
                <Grid item xs={7}>
                    <Box sx={STYLES.DETAIL_INFO}>
                        <CardDetailInfo cardInfo={card} />
                    </Box>
                    <Box sx={STYLES.PRODUCT_SELECTOR}>
                        <CardSelector products={costProductComposition.products} setCostProductComposition={setCostProductComposition} />
                    </Box>
                </Grid>
            </Grid>
        </Container>
    );
};

//Контроль свойств - Детализация по объекту
CardDetail.propTypes = {
    card: PropTypes.object,
    handleBackClick: PropTypes.func
};

//----------------
//Интерфейс модуля
//----------------

export { CardDetail };

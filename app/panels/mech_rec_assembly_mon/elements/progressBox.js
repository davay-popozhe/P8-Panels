/*
    Парус 8 - Панели мониторинга - ПУП - Мониторинг сборки изделий
    Панель мониторинга: Блок информации по прогрессу объекта
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Typography, Box } from "@mui/material"; //Интерфейсные элементы

//---------
//Константы
//---------

//Стили
const STYLES = {
    PROGRESS_INFO: {
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        flexDirection: "column",
        margin: "0px 32px",
        borderRadius: "50%"
    }
};

//------------------------------------
//Вспомогательные функции и компоненты
//------------------------------------

//-----------
//Тело модуля
//-----------

//Детализация по объекту

//Блок информации по прогрессу объекта
const ProgressBox = ({ prms }) => {
    //Инициализируем цвет тени
    let boxShadow = null;
    //Определяем цвет тени
    switch (true) {
        case prms.NPROGRESS >= 70:
            boxShadow = "0 0 30px #21d21e66";
            break;
        case prms.NPROGRESS >= 40:
            boxShadow = "0 0 30px #fddd3566";
            break;
        case prms.NPROGRESS >= 10:
            boxShadow = "0 0 30px #ea5c4966";
            break;
        default:
            boxShadow = "0 0 30px #d3d3d3";
    }
    //Возвращаем блок
    return (
        <Box sx={{ ...STYLES.PROGRESS_INFO, width: prms.width, height: prms.height }} boxShadow={boxShadow}>
            <Typography variant={prms.progressVariant}>{`${prms.NPROGRESS}%`}</Typography>
            <Typography variant={prms.detailVariant}>{prms.SDETAIL}</Typography>
        </Box>
    );
};

//Контроль свойств - Блок информации по прогрессу объекта
ProgressBox.propTypes = {
    prms: PropTypes.object
};

//----------------
//Интерфейс модуля
//----------------

export { ProgressBox };

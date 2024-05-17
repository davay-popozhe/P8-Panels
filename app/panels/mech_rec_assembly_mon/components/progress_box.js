/*
    Парус 8 - Панели мониторинга - ПУП - Мониторинг сборки изделий
    Компонент: Информация по прогрессу объекта
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
    PROGRESS_BOX: (width, height) => ({
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        flexDirection: "column",
        margin: "0px 32px",
        borderRadius: "50%",
        ...(width ? { width } : {}),
        ...(height ? { height } : {})
    })
};

//-----------
//Тело модуля
//-----------

//Информация по прогрессу объекта
const ProgressBox = ({ progress, detail, width, height, progressVariant, detailVariant }) => {
    //Определяем цвет тени
    let boxShadow = "0 0 30px #d3d3d3";
    switch (true) {
        case progress >= 70:
            boxShadow = "0 0 30px #21d21e66";
            break;
        case progress >= 40:
            boxShadow = "0 0 30px #fddd3566";
            break;
        case progress >= 10:
            boxShadow = "0 0 30px #ea5c4966";
            break;
    }

    //Возвращаем содержимое
    return (
        <Box sx={STYLES.PROGRESS_BOX(width, height)} boxShadow={boxShadow}>
            <Typography variant={progressVariant}>{`${progress}%`}</Typography>
            <Typography variant={detailVariant}>{detail}</Typography>
        </Box>
    );
};

//Контроль свойств - Информация по прогрессу объекта
ProgressBox.propTypes = {
    progress: PropTypes.number,
    detail: PropTypes.string,
    width: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    height: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    progressVariant: PropTypes.string,
    detailVariant: PropTypes.string
};

//----------------
//Интерфейс модуля
//----------------

export { ProgressBox };

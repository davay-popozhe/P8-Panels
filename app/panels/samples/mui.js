/*
    Парус 8 - Панели мониторинга - Примеры для разработчиков
    Пример: Компоненты MUI
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import { Typography } from "@mui/material"; //Интерфейсные элементы
import PropTypes from "prop-types"; //Контроль свойств компонента

//---------
//Константы
//---------

//Стили
const STYLES = {
    CONTAINER: { textAlign: "center", paddingTop: "20px" },
    TITLE: { paddingBottom: "15px" }
};

//-----------
//Тело модуля
//-----------

//Пример: Компоненты MUI
const Mui = ({ title }) => {
    //Генерация содержимого
    return (
        <div style={STYLES.CONTAINER}>
            <Typography sx={STYLES.TITLE} variant={"h6"}>
                {title}
            </Typography>
            Mui
        </div>
    );
};

//Контроль свойств - Пример: Компоненты MUI
Mui.propTypes = {
    title: PropTypes.string.isRequired
};

//----------------
//Интерфейс модуля
//----------------

export { Mui };

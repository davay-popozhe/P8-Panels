/*
    Парус 8 - Панели мониторинга
    Компонент: Страница ошибки
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Box } from "@mui/material"; //Контейнер
import { P8PAppInlineError } from "./p8p_app_message"; //Сообщения

//-----------
//Тело модуля
//-----------

//Страница ошибки
const P8PAppErrorPage = ({ errorMessage, onNavigate, navigateCaption }) => {
    //Генерация содержимого
    return (
        <Box display="flex" justifyContent="center" alignItems="center" minHeight="100vh">
            <div>
                <P8PAppInlineError text={errorMessage} okBtn={onNavigate ? true : false} onOk={onNavigate} okBtnCaption={navigateCaption} />
            </div>
        </Box>
    );
};

//Контроль свойств - Страница ошибки
P8PAppErrorPage.propTypes = {
    errorMessage: PropTypes.string.isRequired,
    onNavigate: PropTypes.func,
    navigateCaption: PropTypes.string
};

//----------------
//Интерфейс модуля
//----------------

export { P8PAppErrorPage };

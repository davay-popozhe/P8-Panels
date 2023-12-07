/*
    Парус 8 - Панели мониторинга - Примеры для разработчиков
    Пример: Индикатор процесса
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useContext } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Typography, Button } from "@mui/material"; //Интерфейсные элементы
import { MessagingСtx } from "../../context/messaging"; //Контекст сообщений

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

//Пример: Индикатор процесса
const Loader = ({ title }) => {
    //Подключение к контексту сообщений
    const { showLoader, hideLoader } = useContext(MessagingСtx);

    //Генерация содержимого
    return (
        <div style={STYLES.CONTAINER}>
            <Typography sx={STYLES.TITLE} variant={"h6"}>
                {title}
            </Typography>
            <Button
                onClick={() => {
                    showLoader("Процесс идёт. Закончится автоматически через пару секунд...");
                    setTimeout(hideLoader, 2000);
                }}
            >
                Показать индикатор процесса
            </Button>
        </div>
    );
};

//Контроль свойств - Пример: Индикатор процесса
Loader.propTypes = {
    title: PropTypes.string.isRequired
};

//----------------
//Интерфейс модуля
//----------------

export { Loader };

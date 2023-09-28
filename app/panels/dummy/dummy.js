/*
    Парус 8 - Панели мониторинга - Загулшка
    Панель-заглушка
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useContext } from "react"; //Классы React
import { NavigationCtx } from "../../context/navigation"; //Контекст навигации
import { P8PAppErrorPage } from "../../components/p8p_app_error_page"; //Страница с ошибкой
import { BUTTONS, ERRORS } from "../../../app.text"; //Текстовые ресурсы и константы

//-----------
//Тело модуля
//-----------

//Заглушка
const Dummy = () => {
    //Подключение к контексту навигации
    const { navigateRoot } = useContext(NavigationCtx);

    //Генерация содержимого
    return <P8PAppErrorPage errorMessage={ERRORS.UNDER_CONSTRUCTION} onNavigate={() => navigateRoot()} navigateCaption={BUTTONS.NAVIGATE_HOME} />;
};

//----------------
//Интерфейс модуля
//----------------

export { Dummy };

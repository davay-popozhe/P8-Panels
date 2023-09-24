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
import { BUTTONS, ERROR } from "../../../app.text"; //Текстовые ресурсы и константы

//-----------
//Тело модуля
//-----------

//Заглушка
const Dummy = () => {
    //Подключение к контексту навигации
    const { navigateBack } = useContext(NavigationCtx);

    //Генерация содержимого
    return <P8PAppErrorPage errorMessage={ERROR.UNDER_CONSTRUCTION} onNavigate={() => navigateBack()} navigateCaption={BUTTONS.NAVIGATE_BACK} />;
};

//----------------
//Интерфейс модуля
//----------------

export { Dummy };

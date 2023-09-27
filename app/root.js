/*
    Парус 8 - Панели мониторинга
    Корневой класс приложения (обёртка для контекста)
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import { MessagingContext } from "./context/messaging"; //Контекст сообщений
import { BackEndContext } from "./context/backend"; //Контекст взаимодействия с сервером
import { ApplicationContext } from "./context/application"; //Контекст приложения
import { App } from "./app"; //Приложение
import { ERRORS, TITLES, TEXTS, BUTTONS } from "../app.text"; //Текстовые ресурсы и константы
import { getDisplaySize, genGUID } from "./core/utils"; //Вспомогательные функции
import config from "../app.config"; //Настройки приложения
import client from "./core/client"; //Клиент для взаимодействия с сервером

//-----------
//Тело модуля
//-----------

//Обёртка для контекста
const Root = () => {
    return (
        <MessagingContext titles={TITLES} texts={TEXTS} buttons={BUTTONS}>
            <BackEndContext client={client}>
                <ApplicationContext errors={ERRORS} displaySizeGetter={getDisplaySize} guidGenerator={genGUID} config={config}>
                    <App />
                </ApplicationContext>
            </BackEndContext>
        </MessagingContext>
    );
};

//----------------
//Интерфейс модуля
//----------------

export default Root;

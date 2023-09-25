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
import { genGUID } from "./core/utils"; //Вспомогательные функции
import client from "./core/client"; //Клиент для взаимодействия с сервером

//-----------
//Тело модуля
//-----------

//Обёртка для контекста
const Root = () => {
    return (
        <MessagingContext>
            <BackEndContext client={client}>
                <ApplicationContext guidGenerator={genGUID}>
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

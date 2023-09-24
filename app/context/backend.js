/*
    Парус 8 - Панели мониторинга
    Контекст: Взаимодействие с серверным API
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { createContext, useContext, useCallback } from "react"; //ReactJS
import PropTypes from "prop-types"; //Контроль свойств компонента
import client from "../core/client"; //Клиент для взаимодействия с сервером
import { MessagingСtx } from "./messaging"; //Контекст сообщений

//----------------
//Интерфейс модуля
//----------------

//Контекст взаимодействия с серверным API
export const BackEndСtx = createContext();

//Провайдер контекста взаимодействия с серверным API
export const BackEndContext = ({ children }) => {
    //Подключение к контексту сообщений
    const { showLoader, hideLoader, showMsgErr } = useContext(MessagingСtx);

    //Проверка ответа на наличие ошибки
    const isRespErr = useCallback(resp => client.isRespErr(resp), []);

    //Извлечение ошибки из ответа
    const getRespErrMessage = useCallback(resp => client.getRespErrMessage(resp), []);

    //Извлечение полезного содержимого из ответа
    const getRespPayload = useCallback(resp => client.getRespPayload(resp), []);

    //Запуск хранимой процедуры
    const executeStored = useCallback(
        async ({
            stored,
            args,
            respArg,
            loader = true,
            loaderMessage = "",
            throwError = true,
            showErrorMessage = true,
            fullResponse = false,
            spreadOutArguments = true
        } = {}) => {
            try {
                if (loader !== false) showLoader(loaderMessage);
                let result = await client.executeStored({ stored, args, respArg, throwError, spreadOutArguments });
                if (fullResponse === true || isRespErr(result)) return result;
                else return result.XPAYLOAD;
            } catch (e) {
                if (showErrorMessage) showMsgErr(e.message);
                throw e;
            } finally {
                if (loader !== false) hideLoader();
            }
        },
        [showLoader, hideLoader, isRespErr, showMsgErr]
    );

    //Загрузка настроек панелей
    const getConfig = useCallback(
        async ({ loader = true, loaderMessage = "", throwError = true, showErrorMessage = true } = {}) => {
            try {
                if (loader !== false) showLoader(loaderMessage);
                let result = await client.getConfig({ throwError });
                return result;
            } catch (e) {
                if (showErrorMessage) showMsgErr(e.message);
                throw e;
            } finally {
                if (loader !== false) hideLoader();
            }
        },
        [showLoader, hideLoader, showMsgErr]
    );

    //Вернём компонент провайдера
    return (
        <BackEndСtx.Provider
            value={{
                SERV_DATA_TYPE_STR: client.SERV_DATA_TYPE_STR,
                SERV_DATA_TYPE_NUMB: client.SERV_DATA_TYPE_NUMB,
                SERV_DATA_TYPE_DATE: client.SERV_DATA_TYPE_DATE,
                SERV_DATA_TYPE_CLOB: client.SERV_DATA_TYPE_CLOB,
                isRespErr,
                getRespErrMessage,
                getRespPayload,
                executeStored,
                getConfig
            }}
        >
            {children}
        </BackEndСtx.Provider>
    );
};

//Контроль свойств - Провайдер контекста взаимодействия с серверным API
BackEndContext.propTypes = {
    children: PropTypes.oneOfType([PropTypes.arrayOf(PropTypes.node), PropTypes.node])
};

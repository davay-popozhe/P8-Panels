/*
    Парус 8 - Панели мониторинга
    Контекст: Сообщения - редьюсер состояния
*/

//---------------------
//Подключение библиотек
//---------------------

import { P8P_APP_MESSAGE_VARIANT } from "../components/p8p_app_message"; //Диалог сообщения

//---------
//Константы
//---------

//Типы действий
const MSG_AT = {
    SHOW_LOADER: "SHOW_LOADER", //Отображение индикатора загрузки
    HIDE_LOADER: "HIDE_LOADER", //Сокрытие индикатора загрузки
    SHOW_MSG: "SHOW_MSG", //Отображение сообщения
    HIDE_MSG: "HIDE_MSG" //Сокрытие сообщения
};

//Типы диалогов сообщений
const MSG_DLGT = {
    INFO: P8P_APP_MESSAGE_VARIANT.INFO, //Тип диалога - информация
    WARN: P8P_APP_MESSAGE_VARIANT.WARN, //Тип диалога - предупреждение
    ERR: P8P_APP_MESSAGE_VARIANT.ERR //Тип диалога - ошибка
};

//Состояние сообщений по умолчанию
const INITIAL_STATE = {
    loading: false,
    loadingMessage: "",
    msg: false,
    msgType: MSG_DLGT.ERR,
    msgText: null,
    msgOnOk: null,
    msgOnCancel: null
};

//-----------
//Тело модуля
//-----------

//Обработчики действий
const handlers = {
    //Отображение индикатора обработки данных
    [MSG_AT.SHOW_LOADER]: (state, { payload }) => ({
        ...state,
        loading: true,
        loadingMessage: payload
    }),
    //Сокрытие индикатора обработки данных
    [MSG_AT.HIDE_LOADER]: state => ({ ...state, loading: false }),
    //Отображение сообщения
    [MSG_AT.SHOW_MSG]: (state, { payload }) => ({
        ...state,
        msg: true,
        msgType: payload.type || MSG_DLGT.APP_ERR,
        msgText: payload.text,
        msgOnOk: payload.msgOnOk,
        msgOnCancel: payload.msgOnCancel
    }),
    //Сокрытие сообщения
    [MSG_AT.HIDE_MSG]: state => ({ ...state, msg: false, msgOnOk: null, msgOnCancel: null }),
    //Обработчик по умолчанию
    DEFAULT: state => state
};

//----------------
//Интерфейс модуля
//----------------

//Константы
export { MSG_AT, MSG_DLGT, INITIAL_STATE };

//Редьюсер состояния
export const messagingReducer = (state, action) => {
    //Подберём обработчик
    const handle = handlers[action.type] || handlers.DEFAULT;
    //Исполним его
    return handle(state, action);
};

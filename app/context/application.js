/*
    Парус 8 - Панели мониторинга
    Контекст: Приложение
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useReducer, createContext, useEffect, useContext, useCallback } from "react"; //ReactJS
import PropTypes from "prop-types"; //Контроль свойств компонента
import { getDisplaySize } from "../core/utils"; //Вспомогательные функции
import { APP_AT, INITIAL_STATE, applicationReducer } from "./application_reducer"; //Редьюсер состояния
import { MessagingСtx } from "./messaging"; //Контекст отображения сообщений
import { BackEndСtx } from "./backend"; //Контекст взаимодействия с сервером
import { ERROR } from "../../app.text"; //Текстовые ресурсы и константы

//---------
//Константы
//---------

//Клиентский API "ПАРУС 8 Онлайн"
const P8O_API = window.parent?.parus?.clientApi;

//--------------------------------
//Вспомогательные классы и функции
//--------------------------------

//----------------
//Интерфейс модуля
//----------------

//Контекст приложения
export const ApplicationСtx = createContext();

//Провайдер контекста приложения
export const ApplicationContext = ({ children }) => {
    //Подключим редьюсер состояния
    const [state, dispatch] = useReducer(applicationReducer, INITIAL_STATE);

    //Подключение к контексту взаимодействия с сервером
    const { getConfig, getRespPayload } = useContext(BackEndСtx);

    //Подключение к контексту отображения сообщений
    const { showMsgErr } = useContext(MessagingСtx);

    //Установка флага инициализированности приложения
    const setInitialized = () => dispatch({ type: APP_AT.SET_INITIALIZED });

    //Установка текущего размера экрана
    const setDisplaySize = displaySize => dispatch({ type: APP_AT.SET_DISPLAY_SIZE, payload: displaySize });

    //Установка списка панелей
    const setPanels = panels => dispatch({ type: APP_AT.LOAD_PANELS, payload: panels });

    //Поиск раздела по имени
    const findPanelByName = name => state.panels.find(panel => panel.name == name);

    //Отображение раздела "ПАРУС 8 Онлайн"
    const pOnlineShowUnit = useCallback(
        ({ unitCode, showMethod = "main", inputParameters }) => {
            if (P8O_API) P8O_API.fn.openDocumentModal({ unitcode: unitCode, method: showMethod, inputParameters });
            else showMsgErr(ERROR.P8O_API_UNAVAILABLE);
        },
        [showMsgErr]
    );

    //Отображение документа "ПАРУС 8 Онлайн"
    const pOnlineShowDocument = useCallback(
        ({ unitCode, document, showMethod = "main", inRnParameter = "in_RN" }) => {
            if (P8O_API)
                P8O_API.fn.openDocumentModal({ unitcode: unitCode, method: showMethod, inputParameters: [{ name: inRnParameter, value: document }] });
            else showMsgErr(ERROR.P8O_API_UNAVAILABLE);
        },
        [showMsgErr]
    );

    //Отображение словаря "ПАРУС 8 Онлайн"
    const pOnlineShowDictionary = useCallback(
        ({ unitCode, showMethod = "main", inputParameters, callBack }) => {
            if (P8O_API)
                P8O_API.fn.openDictionary({ unitcode: unitCode, method: showMethod, inputParameters }, res => (callBack ? callBack(res) : null));
            else showMsgErr(ERROR.P8O_API_UNAVAILABLE);
        },
        [showMsgErr]
    );

    //Исполнение пользовательской процедуры "ПАРУС 8 Онлайн"
    const pOnlineUserProcedure = useCallback(
        ({ code, inputParameters, callBack }) => {
            if (P8O_API) P8O_API.fn.performUserProcedureSync({ code, inputParameters }, res => (callBack ? callBack(res) : null));
            else showMsgErr(ERROR.P8O_API_UNAVAILABLE);
        },
        [showMsgErr]
    );

    //Исполнение пользовательского отчёта "ПАРУС 8 Онлайн"
    const pOnlineUserReport = useCallback(
        ({ code, inputParameters }) => {
            if (P8O_API) P8O_API.fn.performUserReport({ code, inputParameters });
            else showMsgErr(ERROR.P8O_API_UNAVAILABLE);
        },
        [showMsgErr]
    );

    //Инициализация приложения
    const initApp = useCallback(async () => {
        //Читаем конфигурацию с сервера
        let res = await getConfig();
        //Сохраняем список панелей
        setPanels(getRespPayload(res)?.Panels?.Panel);
        //Установим флаг завершения инициализации
        setInitialized();
    }, [getConfig, getRespPayload]);

    //Обработка подключения контекста к странице
    useEffect(() => {
        if (!state.initialized) {
            //Слушаем изменение размеров окна
            window.addEventListener("resize", () => {
                setDisplaySize(getDisplaySize());
            });
            //Инициализируем приложение
            initApp();
        }
    }, [state.initialized, initApp]);

    //Вернём компонент провайдера
    return (
        <ApplicationСtx.Provider
            value={{
                findPanelByName,
                pOnlineShowUnit,
                pOnlineShowDocument,
                pOnlineShowDictionary,
                pOnlineUserProcedure,
                pOnlineUserReport,
                appState: state
            }}
        >
            {children}
        </ApplicationСtx.Provider>
    );
};

//Контроль свойств - Провайдер контекста приложения
ApplicationContext.propTypes = {
    children: PropTypes.oneOfType([PropTypes.arrayOf(PropTypes.node), PropTypes.node])
};

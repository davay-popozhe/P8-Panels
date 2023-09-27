/*
    Парус 8 - Панели мониторинга
    Контекст: Приложение
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useReducer, createContext, useEffect, useContext, useCallback, useMemo } from "react"; //ReactJS
import PropTypes from "prop-types"; //Контроль свойств компонента
import { APP_AT, INITIAL_STATE, applicationReducer } from "./application_reducer"; //Редьюсер состояния
import { MessagingСtx } from "./messaging"; //Контекст отображения сообщений
import { BackEndСtx } from "./backend"; //Контекст взаимодействия с сервером

//---------
//Константы
//---------

//Клиентский API "ПАРУС 8 Онлайн"
const P8O_API = window.parent?.parus?.clientApi;

//Структура объекта с описанием ошибок
const APPLICATION_CONTEXT_ERRORS_SHAPE = PropTypes.shape({
    P8O_API_UNAVAILABLE: PropTypes.string.isRequired
});

//----------------
//Интерфейс модуля
//----------------

//Контекст приложения
export const ApplicationСtx = createContext();

//Провайдер контекста приложения
export const ApplicationContext = ({ errors, displaySizeGetter, guidGenerator, config, children }) => {
    //Подключим редьюсер состояния
    const [state, dispatch] = useReducer(applicationReducer, INITIAL_STATE(displaySizeGetter));

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

    //Отображение закладки "ПАРУС 8 Онлайн" с указанным URL
    const pOnlineShowTab = useCallback(
        ({ id, url, caption, onClose }) => {
            if (P8O_API) {
                const _id = id || guidGenerator();
                P8O_API.ui.openTab({ id: _id, url, caption, onClose: () => (onClose ? onClose(_id) : null) });
                return _id;
            } else showMsgErr(errors.P8O_API_UNAVAILABLE);
        },
        [showMsgErr, guidGenerator, errors.P8O_API_UNAVAILABLE]
    );

    //Отображение раздела "ПАРУС 8 Онлайн"
    const pOnlineShowUnit = useCallback(
        ({ unitCode, showMethod = "main", inputParameters }) => {
            if (P8O_API) P8O_API.fn.openDocumentModal({ unitcode: unitCode, method: showMethod, inputParameters });
            else showMsgErr(errors.P8O_API_UNAVAILABLE);
        },
        [showMsgErr, errors.P8O_API_UNAVAILABLE]
    );

    //Отображение документа "ПАРУС 8 Онлайн"
    const pOnlineShowDocument = useCallback(
        ({ unitCode, document, showMethod = "main", inRnParameter = "in_RN" }) => {
            if (P8O_API)
                P8O_API.fn.openDocumentModal({ unitcode: unitCode, method: showMethod, inputParameters: [{ name: inRnParameter, value: document }] });
            else showMsgErr(errors.P8O_API_UNAVAILABLE);
        },
        [showMsgErr, errors.P8O_API_UNAVAILABLE]
    );

    //Отображение словаря "ПАРУС 8 Онлайн"
    const pOnlineShowDictionary = useCallback(
        ({ unitCode, showMethod = "main", inputParameters, callBack }) => {
            if (P8O_API)
                P8O_API.fn.openDictionary({ unitcode: unitCode, method: showMethod, inputParameters }, res => (callBack ? callBack(res) : null));
            else showMsgErr(errors.P8O_API_UNAVAILABLE);
        },
        [showMsgErr, errors.P8O_API_UNAVAILABLE]
    );

    //Исполнение пользовательской процедуры "ПАРУС 8 Онлайн"
    const pOnlineUserProcedure = useCallback(
        ({ code, inputParameters, callBack }) => {
            if (P8O_API) P8O_API.fn.performUserProcedureSync({ code, inputParameters }, res => (callBack ? callBack(res) : null));
            else showMsgErr(errors.P8O_API_UNAVAILABLE);
        },
        [showMsgErr, errors.P8O_API_UNAVAILABLE]
    );

    //Исполнение пользовательского отчёта "ПАРУС 8 Онлайн"
    const pOnlineUserReport = useCallback(
        ({ code, inputParameters }) => {
            if (P8O_API) P8O_API.fn.performUserReport({ code, inputParameters });
            else showMsgErr(errors.P8O_API_UNAVAILABLE);
        },
        [showMsgErr, errors.P8O_API_UNAVAILABLE]
    );

    //Получение количества записей на странице
    const configSystemPageSize = useMemo(() => config.SYSTEM.PAGE_SIZE, [config.SYSTEM.PAGE_SIZE]);

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
                if (displaySizeGetter) setDisplaySize(displaySizeGetter());
            });
            //Инициализируем приложение
            initApp();
        }
    }, [state.initialized, initApp, displaySizeGetter]);

    //Вернём компонент провайдера
    return (
        <ApplicationСtx.Provider
            value={{
                findPanelByName,
                pOnlineShowTab,
                pOnlineShowUnit,
                pOnlineShowDocument,
                pOnlineShowDictionary,
                pOnlineUserProcedure,
                pOnlineUserReport,
                configSystemPageSize,
                appState: state
            }}
        >
            {children}
        </ApplicationСtx.Provider>
    );
};

//Контроль свойств - Провайдер контекста приложения
ApplicationContext.propTypes = {
    errors: APPLICATION_CONTEXT_ERRORS_SHAPE.isRequired,
    displaySizeGetter: PropTypes.func,
    guidGenerator: PropTypes.func.isRequired,
    config: PropTypes.object.isRequired,
    children: PropTypes.oneOfType([PropTypes.arrayOf(PropTypes.node), PropTypes.node])
};

/*
    Парус 8 - Панели мониторинга
    Контекст: Приложение - редьюсер состояния
*/

//---------
//Константы
//---------

//Типы действий
const APP_AT = {
    SET_URL_BASE: "SET_URL_BASE", //Установка базового URL приложения
    LOAD_PANELS: "LOAD_PANELS", //Загрузка списка панелей
    SET_INITIALIZED: "SET_INITIALIZED", //Установка флага инициализированности приложения
    SET_DISPLAY_SIZE: "SET_DISPLAY_SIZE" //Установка текущего типового размера экрана
};

//Состояние приложения по умолчанию
const INITIAL_STATE = displaySizeGetter => ({
    displaySize: displaySizeGetter(),
    urlBase: "",
    panels: [],
    panelsLoaded: false,
    initialized: false
});

//-----------
//Тело модуля
//-----------

//Обработчики действий
const handlers = {
    //Установка базового URL приложения
    [APP_AT.SET_URL_BASE]: (state, { payload }) => ({ ...state, urlBase: payload }),
    //Загрузка списка панелей
    [APP_AT.LOAD_PANELS]: (state, { payload }) => {
        let panels = [];
        if (payload && Array.isArray(payload)) for (let p of payload) panels.push({ ...p });
        return {
            ...state,
            panels,
            panelsLoaded: true
        };
    },
    //Установка текущего типового размера экрана
    [APP_AT.SET_INITIALIZED]: state => ({ ...state, initialized: true }),
    //Установка текущего типового размера экрана
    [APP_AT.SET_DISPLAY_SIZE]: (state, { payload }) => ({ ...state, displaySize: payload }),
    //Обработчик по умолчанию
    DEFAULT: state => state
};

//----------------
//Интерфейс модуля
//----------------

//Константы
export { APP_AT, INITIAL_STATE };

//Редьюсер состояния
export const applicationReducer = (state, action) => {
    //Подберём обработчик
    const handle = handlers[action.type] || handlers.DEFAULT;
    //Исполним его
    return handle(state, action);
};

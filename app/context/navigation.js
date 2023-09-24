/*
    Парус 8 - Панели мониторинга
    Контекст: Навигация
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { createContext, useContext } from "react"; //ReactJS
import PropTypes from "prop-types"; //Контроль свойств компонента
import { useLocation, useNavigate } from "react-router-dom"; //Роутер приложения
import queryString from "query-string"; //Работа со строкой запроса
import { ApplicationСtx } from "./application"; //Контекст приложения

//---------
//Константы
//---------

//Типовые пути
const PATHS = {
    ROOT: "/" //Корень приложения
};

//----------------
//Интерфейс модуля
//----------------

//Получение корневого пути
export const getRootLocation = () => PATHS.ROOT;

//Контекст навигации
export const NavigationCtx = createContext();

//Провайдер контекста навигации
export const NavigationContext = ({ children }) => {
    //Подключение к объекту роутера для управления навигацией
    const location = useLocation();

    //Подключение к объекту роутера для управления навигацией
    const navigate = useNavigate();

    //Подключение к контексту приложения
    const { findPanelByName } = useContext(ApplicationСtx);

    //Проверка наличия параметров запроса
    const isNavigationSearch = () => (location.search ? true : false);

    //Считываение параметров запроса
    const getNavigationSearch = () => queryString.parse(location.search);

    //Проверка наличия параметров запроса (передаваемых через состояние)
    const isNavigationState = () => (location.state ? true : false);

    //Считываение параметров запроса (передаваемых через состояние)
    const getNavigationState = () => (isNavigationState() ? JSON.parse(location.state) : null);

    //Обновление текущей страницы
    const refresh = () => window.location.reload();

    //Возврат на предыдущую страницу
    const navigateBack = () => navigate(-1);

    //Переход к адресу внутри приложения
    const navigateTo = ({ path, search, state, replace = false }) => {
        //Если указано куда переходить
        if (path) {
            //Переходим к адресу
            if (state) navigate(path, { state: JSON.stringify(state), replace });
            else navigate({ pathname: path, search: queryString.stringify(search), replace });
            //Флаг успешного перехода
            return true;
        }
        //Переход не состоялся
        else return false;
    };

    //Переход к домашней страничке
    const navigateRoot = state => navigateTo({ path: getRootLocation(), state });

    //Переход к панели
    const navigatePanel = (panel, state) => {
        if (panel) {
            let path = getRootLocation();
            path = !path.endsWith("/") && !panel.url.startsWith("/") ? `${path}/${panel.url}` : `${path}${panel.url}`;
            navigateTo({ path, state });
        } else return false;
    };

    //Переход к панели по наименованию
    const navigatePanelByName = (name, state) => navigatePanel(findPanelByName(name), state);

    //Переход к произвольному адресу
    const navigateURL = url => {
        window.open(url, "_self");
    };

    //Вернём компонент провайдера
    return (
        <NavigationCtx.Provider
            value={{
                getNavigationSearch,
                isNavigationSearch,
                getNavigationState,
                isNavigationState,
                refresh,
                navigateTo,
                navigateBack,
                navigateRoot,
                navigatePanel,
                navigatePanelByName,
                navigateURL
            }}
        >
            {children}
        </NavigationCtx.Provider>
    );
};

//Контроль свойств - Провайдер контекста навигации
NavigationContext.propTypes = {
    children: PropTypes.oneOfType([PropTypes.arrayOf(PropTypes.node), PropTypes.node])
};

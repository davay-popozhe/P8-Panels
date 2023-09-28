/*
    Парус 8 - Панели мониторинга
    Приложение
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useContext, useEffect } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { createHashRouter, RouterProvider, useRouteError } from "react-router-dom"; //Роутер
import { ApplicationСtx } from "./context/application"; //Контекст приложения
import { NavigationContext, NavigationCtx, getRootLocation } from "./context/navigation"; //Контекст навигации
import { P8PAppErrorPage } from "./components/p8p_app_error_page"; //Страница с ошибкой
import { P8PAppWorkspace } from "./components/p8p_app_workspace"; //Рабочее пространство панели
import { P8PPanelsMenuDesktop, P8PPanelsMenuGrid, P8P_PANELS_MENU_PANEL_SHAPE } from "./components/p8p_panels_menu"; //Меню панелей
import { BUTTONS, ERRORS, ERRORS_HTTP } from "../app.text"; //Текстовые ресурсы и константы
import { P8P_PANELS_MENU_GRID_CONFIG_PROPS, P8P_APP_WORKSPACE_CONFIG_PROPS } from "./config_wrapper"; //Подключение компонентов к настройкам приложения

//--------------------------
//Вспомогательные компоненты
//--------------------------

//Обработка ошибок роутинга
const RouterError = ({ homePath }) => {
    //Подключение к контексту навигации
    const { navigateTo } = useContext(NavigationCtx);

    //Извлечем ошибку роутинга
    const routeError = useRouteError();

    //Отработка нажатия на кнопку навигации
    const handleNavigate = () => navigateTo({ path: `${homePath.startsWith("/") ? "" : "/"}${homePath}` });

    //Генерация содержимого
    return (
        <P8PAppErrorPage
            errorMessage={ERRORS_HTTP[routeError.status] ? ERRORS_HTTP[routeError.status] : ERRORS.DEFAULT}
            onNavigate={handleNavigate}
            navigateCaption={BUTTONS.NAVIGATE_HOME}
        />
    );
};

//Контроль свойств - обработка ошибок роутинга
RouterError.propTypes = {
    homePath: PropTypes.string.isRequired
};

//Главное меню приложения
const MainMenu = ({ panels = [] } = {}) => {
    //Подключение к контексту навигации
    const { navigatePanel, isNavigationSearch, getNavigationSearch } = useContext(NavigationCtx);

    //Подключение к контексту приложения
    const { configUrlBase, pOnlineShowTab } = useContext(ApplicationСtx);

    //Получим параметры запроса из адресной строки
    const qS = isNavigationSearch() ? getNavigationSearch() : null;

    //Отработка действия навигации элемента меню
    const handleItemNavigate = (panel, newTab) =>
        newTab ? pOnlineShowTab({ id: panel.name, url: `${configUrlBase}${panel.url}`, caption: panel.caption }) : navigatePanel(panel);

    //Генерация содержимого
    return qS?.mode === "DESKTOP" ? (
        <P8PPanelsMenuDesktop
            {...P8P_PANELS_MENU_GRID_CONFIG_PROPS}
            group={qS?.group}
            panels={panels}
            onItemNavigate={panel => handleItemNavigate(panel, true)}
        />
    ) : (
        <P8PPanelsMenuGrid {...P8P_PANELS_MENU_GRID_CONFIG_PROPS} panels={panels} onItemNavigate={panel => handleItemNavigate(panel, false)} />
    );
};

//Контроль свойств - главное меню приложения
MainMenu.propTypes = {
    panels: PropTypes.arrayOf(P8P_PANELS_MENU_PANEL_SHAPE).isRequired
};

//Рабочее пространство панели
const Workspace = ({ panels = [], selectedPanel, children } = {}) => {
    //Подключение к контексту навигации
    const { navigateRoot, navigatePanel } = useContext(NavigationCtx);

    //Отработка действия навигации домой
    const handleHomeNavigate = () => navigateRoot();

    //Отработка действия навигации элемента меню
    const handleItemNavigate = panel => navigatePanel(panel);

    //Генерация содержимого
    return (
        <P8PAppWorkspace
            {...P8P_APP_WORKSPACE_CONFIG_PROPS}
            panels={panels}
            selectedPanel={selectedPanel}
            onHomeNavigate={handleHomeNavigate}
            onItemNavigate={handleItemNavigate}
        >
            {children}
        </P8PAppWorkspace>
    );
};

//Контроль свойств - главное меню приложения
Workspace.propTypes = {
    panels: PropTypes.arrayOf(P8P_PANELS_MENU_PANEL_SHAPE).isRequired,
    selectedPanel: P8P_PANELS_MENU_PANEL_SHAPE,
    children: PropTypes.element
};

//Обёртывание элемента в контекст навигации
const wrapNavigationContext = children => <NavigationContext>{children}</NavigationContext>;

//-----------
//Тело модуля
//-----------

//Приложение
const App = () => {
    //Собственное состояние
    const [routes, setRoutes] = useState([]);

    //Подключение к контексту приложения
    const { appState } = useContext(ApplicationСtx);

    //Инициализация роутера
    const content = routes.length > 0 ? <RouterProvider router={createHashRouter(routes)}></RouterProvider> : null;

    //При изменении состояния загрузки панелей
    useEffect(() => {
        if (appState.panelsLoaded) {
            //Сборка "веток" для панелей
            let routes = [
                {
                    path: getRootLocation(),
                    element: wrapNavigationContext(<MainMenu panels={appState.panels} />),
                    errorElement: wrapNavigationContext(<RouterError homePath={getRootLocation()} />)
                }
            ];
            for (const panel of appState.panels) {
                // eslint-disable-next-line no-undef
                const p = require(`./panels/${panel.path}`);
                routes.push({
                    path: `${panel.url}/*`,
                    element: wrapNavigationContext(
                        <Workspace panels={appState.panels} selectedPanel={panel}>
                            <p.RootClass />
                        </Workspace>
                    ),
                    errorElement: wrapNavigationContext(<RouterError homePath={panel.url} />)
                });
            }
            setRoutes(routes);
        }
    }, [appState.panels, appState.panelsLoaded]);

    //Генерация содержимого
    return content;
};

//----------------
//Интерфейс модуля
//----------------

export { App };

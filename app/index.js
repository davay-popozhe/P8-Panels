/*
    Парус 8 - Панели мониторинга
    Точка входа в приложение
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //React
import { createRoot } from "react-dom/client"; //Работа с DOM в React
import Root from "./root"; //Корневой компонент приложения

//-----------
//Точка входа
//-----------

const root = createRoot(document.getElementById("app-content"));
root.render(<Root />);

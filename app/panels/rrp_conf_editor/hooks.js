/*
    Парус 8 - Панели мониторинга - Редактор настройки регламентированного отчёта
    Пользовательские хуки
*/

//---------------------
//Подключение библиотек
//---------------------

import { useState, useLayoutEffect } from "react"; //Классы React

//-----------
//Тело модуля
//-----------

//Хук для отработки изменений ширины и высоты рабочей области окна
const useWindowResize = () => {
    //Состояние размера рабочей области
    const [size, setSize] = useState([0, 0]);
    //При изменении размера
    useLayoutEffect(() => {
        function updateSize() {
            setSize([document.documentElement.clientWidth, document.documentElement.clientHeight]);
        }
        window.addEventListener("resize", updateSize);
        updateSize();
        return () => window.removeEventListener("resize", updateSize);
    }, []);
    return size;
};

//--------------
//Интерфейс хука
//--------------

export { useWindowResize };

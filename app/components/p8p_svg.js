/*
    Парус 8 - Панели мониторинга
    Компонент: Интерактивные изображения SVG
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useEffect, useRef } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента

//---------
//Константы
//---------

//Стили
const STYLES = {
    CANVAS: { width: "100%", height: "100%" }
};

//Структура элемента изображения
const P8P_SVG_ITEM_SHAPE = PropTypes.shape({
    id: PropTypes.string.isRequired,
    backgroundColor: PropTypes.oneOfType([PropTypes.string, PropTypes.arrayOf(PropTypes.string)])
});

//-----------
//Тело модуля
//-----------

//Интерактивные изображения SVG
const P8PSVG = ({ data, items, onClick, style }) => {
    //Ссылки на DOM
    const svgContainerRef = useRef(null);
    const svgRef = useRef(null);

    //Обработка нажатия на элемент изображения
    const handleClick = e => {
        if (e.target.id && items && onClick) {
            const item = items.find(item => item.id == e.target.id);
            if (item) onClick({ item });
        }
    };

    //Формирование интерактивных элементов изображения
    const makeSVGItems = () => {
        items.forEach(item => {
            const svgE = document.getElementById(item.id);
            if (svgE) {
                svgE.setAttribute("style", `${onClick ? "cursor: pointer" : ""}; ${item.backgroundColor ? `fill: ${item.backgroundColor}` : ""}`);
                if (item?.title) {
                    const titleE = document.createElementNS("http://www.w3.org/2000/svg", "title");
                    titleE.textContent = item.title;
                    svgE.replaceChildren(titleE);
                }
            }
        });
    };

    //Загрузка изображения
    const loadSVG = () => {
        const parser = new DOMParser();
        const doc = parser.parseFromString(data, "image/svg+xml");
        svgRef.current = doc.documentElement;
        svgRef.current.onclick = handleClick;
        svgContainerRef.current.replaceChildren(svgRef.current);
        if (items) makeSVGItems(items);
    };

    //При обновлении данных
    useEffect(() => {
        loadSVG();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [data, items]);

    //Генерация содержимого
    return <div ref={svgContainerRef} style={{ ...STYLES.CANVAS, ...(style ? style : {}) }}></div>;
};

//Контроль свойств - Интерактивные изображения SVG
P8PSVG.propTypes = {
    data: PropTypes.string.isRequired,
    items: PropTypes.arrayOf(P8P_SVG_ITEM_SHAPE),
    onClick: PropTypes.func,
    style: PropTypes.object
};

//----------------
//Интерфейс модуля
//----------------

export { P8PSVG };

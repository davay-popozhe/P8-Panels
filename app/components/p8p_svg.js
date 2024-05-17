/*
    Парус 8 - Панели мониторинга
    Компонент: Интерактивные изображения SVG
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useEffect, useRef, useState } from "react"; //Классы React
import { IconButton, Icon, Container, Grid } from "@mui/material"; //Интерфейсные элементы
import PropTypes from "prop-types"; //Контроль свойств компонента

//---------
//Константы
//---------

//Стили
const STYLES = {
    GRID_ITEM_CANVAS: { width: "100%", height: "100%" },
    CONTROLS: { justifyContent: "center", alignItems: "center", display: "flex" }
};

//Структура элемента изображения
const P8P_SVG_ITEM_SHAPE = PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
    backgroundColor: PropTypes.oneOfType([PropTypes.string, PropTypes.arrayOf(PropTypes.string)])
});

//-----------
//Тело модуля
//-----------

//Интерактивные изображения SVG
const P8PSVG = ({ data, items, onClick, onItemClick, canvasStyle, fillOpacity }) => {
    //Собственное состояние
    const [state, setState] = useState({
        images: [],
        currentImage: 0,
        imagesCount: 0
    });

    //Ссылки на DOM
    const svgContainerRef = useRef(null);
    const svgRef = useRef(null);

    //Обработка нажатия на элемент изображения
    const handleClick = e => {
        let itemClickFired = false;
        if (items && onItemClick) {
            const item = items.find(item => item.id == e.target?.id || item.id == e.target?.parentElement?.id);
            if (item) {
                onItemClick({ item });
                itemClickFired = true;
            }
        }
        if (!itemClickFired && onClick) onClick(e);
    };

    //Формирование интерактивных элементов изображения
    const makeSVGItems = () => {
        items.forEach(item => {
            const svgE = document.getElementById(item.id);
            if (svgE) {
                //Запомним старый стиль элемента
                let styleOld = svgE.getAttribute("style") || "";
                if (styleOld && !styleOld.endsWith(";")) styleOld = `${styleOld};`;
                //Сформируем стиль для заливки
                let fillStyle = "";
                if (item.backgroundColor) fillStyle = `fill: ${item.backgroundColor}; ${fillOpacity ? `opacity: ${fillOpacity};` : ""}`;
                //Сформируем стиль для курсора
                let cursorStyle = "";
                if (onItemClick) cursorStyle = "cursor: pointer;";
                //Добавим элемент для всплывающей подсказки
                let titleE = null;
                if (item?.title) {
                    titleE = document.createElementNS("http://www.w3.org/2000/svg", "title");
                    titleE.textContent = item.title;
                    svgE.appendChild(titleE);
                }
                //Если нем попалась группа
                if (svgE.tagName == "g") {
                    //Установим ей новые стили
                    svgE.setAttribute("style", `${styleOld}${cursorStyle}`);
                    //И заливку всем дочерним элементам
                    if (fillStyle)
                        for (const child of svgE.children) {
                            let childStyleOld = child.getAttribute("style") || "";
                            if (childStyleOld && !childStyleOld.endsWith(";")) childStyleOld = `${childStyleOld};`;
                            child.setAttribute("style", `${childStyleOld}${fillStyle}`);
                        }
                } else {
                    //Это простой элемент, не группа - просто выставляем стили
                    svgE.setAttribute("style", `${styleOld}${cursorStyle}${fillStyle}`);
                }
            }
        });
    };

    //Загрузка изображения
    const loadSVG = () => {
        const images = data
            .split("</svg>")
            .filter(i => i)
            .map(i => i + "</svg>");
        setState(pv => ({ ...pv, images, imagesCount: images.length, currentImage: 0 }));
    };

    //Отображение текущего изображения
    const showSVG = () => {
        if (state.imagesCount > 0) {
            const parser = new DOMParser();
            const doc = parser.parseFromString(state.images[state.currentImage], "image/svg+xml");
            svgRef.current = doc.documentElement;
            svgRef.current.onclick = handleClick;
            svgContainerRef.current.replaceChildren(svgRef.current);
            if (items) makeSVGItems(items);
        }
    };

    //Переключение текущего изображения
    const switchImage = direction => {
        setState(pv => ({
            ...pv,
            currentImage:
                direction > 0
                    ? pv.currentImage + 1 >= pv.imagesCount
                        ? 0
                        : pv.currentImage + 1
                    : pv.currentImage - 1 < 0
                    ? pv.imagesCount - 1
                    : pv.currentImage - 1
        }));
    };

    //При обновлении данных
    useEffect(() => {
        loadSVG();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [data]);

    //При загрузке изображения
    useEffect(() => {
        showSVG();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [state.images, state.currentImage, items]);

    //При прокрутке изображений назад
    const handlePrevClick = () => switchImage(1);

    //При прокрутке изображений вперёд
    const handleNextClick = () => switchImage(-1);

    //Генерация содержимого
    return (
        <Container>
            <Grid container direction="column" justifyContent="center" alignItems="center" spacing={0}>
                <Grid item xs={12} sx={STYLES.GRID_ITEM_CANVAS}>
                    <div ref={svgContainerRef} style={{ ...(canvasStyle ? canvasStyle : {}) }}></div>
                </Grid>
                {state.imagesCount > 1 ? (
                    <Grid item xs={12}>
                        <div style={STYLES.CONTROLS}>
                            <IconButton onClick={handlePrevClick}>
                                <Icon>arrow_left</Icon>
                            </IconButton>
                            <IconButton onClick={handleNextClick}>
                                <Icon>arrow_right</Icon>
                            </IconButton>
                        </div>
                    </Grid>
                ) : null}
            </Grid>
        </Container>
    );
};

//Контроль свойств - Интерактивные изображения SVG
P8PSVG.propTypes = {
    data: PropTypes.string.isRequired,
    items: PropTypes.arrayOf(P8P_SVG_ITEM_SHAPE),
    onClick: PropTypes.func,
    onItemClick: PropTypes.func,
    canvasStyle: PropTypes.object,
    fillOpacity: PropTypes.string
};

//----------------
//Интерфейс модуля
//----------------

export { P8PSVG };

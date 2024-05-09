/*
    Парус 8 - Панели мониторинга - Примеры для разработчиков
    Пример: Интерактивные изображения "P8PSVG"
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useEffect } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Typography, Grid, FormControl, FormLabel, RadioGroup, FormControlLabel, Radio } from "@mui/material"; //Интерфейсные элементы
import { P8PSVG } from "../../components/p8p_svg"; //Интерактивные изображения

//---------
//Константы
//---------

//Адрес тестового изображения
const SAMPLE_URL = "http://localhost:8080/P8WebClient/Modules/p8-panels/img/sample.svg";

//Стили
const STYLES = {
    CONTAINER: { textAlign: "center", paddingTop: "20px" },
    TITLE: { paddingBottom: "15px" },
    SVG: { width: "95vw", height: "60vw", display: "flex", justifyContent: "center" }
};

//-----------
//Тело модуля
//-----------

//Пример: Интерактивные изображения "P8PSVG"
const Svg = ({ title }) => {
    //Собственное состояние - SVG-изображение
    const [svg, setSVG] = useState({
        loaded: false,
        data: null,
        mode: "items1",
        items1: [
            { id: "1", backgroundColor: "red", desc: "Цифра на флюзеляже" },
            { id: "2", backgroundColor: "magenta", desc: "Ребро флюзеляжа" },
            { id: "3", backgroundColor: "yellow", desc: "Люк" }
        ],
        items2: [
            { id: "4", backgroundColor: "green", desc: "Хвост", title: "Хвост" },
            { id: "5", backgroundColor: "blue", desc: "Хвостовой руль", title: "Хвостовой руль" },
            { id: "6", backgroundColor: "aquamarine", desc: "Ребро жесткости хвоста", title: "Ребро жесткости хвоста" }
        ],
        selectedItemDesc: ""
    });

    //Загрузка изображения
    const loadSVG = async () => {
        const resp = await fetch(SAMPLE_URL);
        const data = await resp.text();
        setSVG(pv => ({ ...pv, loaded: true, data }));
    };

    //Отработка нажатия на элемент изображения
    const handleSVGItemClick = ({ item }) => {
        setSVG(pv => ({ ...pv, selectedItemDesc: item?.desc ? `Выбран элемент: ${item.desc}` : "Для выбранного элемента не задано описание" }));
    };

    //При подключении к странице
    useEffect(() => {
        loadSVG();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    //Генерация содержимого
    return (
        <div style={STYLES.CONTAINER}>
            <Typography sx={STYLES.TITLE} variant={"h6"}>
                {title}
            </Typography>
            <FormControl>
                <FormLabel>Группа элементов</FormLabel>
                <RadioGroup row value={svg.mode} onChange={e => setSVG(pv => ({ ...pv, mode: e.target.value, selectedItemDesc: "" }))}>
                    <FormControlLabel value="items1" control={<Radio />} label="Элементы первой группы" />
                    <FormControlLabel value="items2" control={<Radio />} label="Элементы второй группы" />
                </RadioGroup>
                <FormLabel>{svg.selectedItemDesc ? svg.selectedItemDesc : "Нажмите на элемент изображения для получения его описания"}</FormLabel>
            </FormControl>
            <Grid container spacing={0} pt={5} direction="column" alignItems="center">
                <Grid item xs={12}>
                    {svg.loaded ? <P8PSVG data={svg.data} items={svg[svg.mode]} onClick={handleSVGItemClick} style={STYLES.SVG} /> : null}
                </Grid>
            </Grid>
        </div>
    );
};

//Контроль свойств - Пример: Интерактивные изображения "P8PSVG"
Svg.propTypes = {
    title: PropTypes.string.isRequired
};

//----------------
//Интерфейс модуля
//----------------

export { Svg };

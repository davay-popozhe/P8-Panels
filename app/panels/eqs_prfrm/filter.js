/*
    Парус 8 - Панели мониторинга - ТОиР - Выполнение работ
    Компонент: Фильтр отбора
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Chip, Stack, Icon, IconButton } from "@mui/material"; //Интерфейсные компоненты

//--------------------------
//Вспомогательные компоненты
//--------------------------

//Элемент фильтра
const FilterItem = ({ caption, value, onClick }) => {
    //При нажатии на элемент
    const handleClick = () => (onClick ? onClick() : null);

    //Генерация содержимого
    return (
        <Chip
            label={
                <Stack direction={"row"} alignItems={"center"}>
                    <strong>{caption}</strong>:&nbsp;{value}
                </Stack>
            }
            variant="outlined"
            onClick={handleClick}
        />
    );
};

//Контроль свойств компонента - Элемент фильтра
FilterItem.propTypes = {
    caption: PropTypes.string.isRequired,
    value: PropTypes.any.isRequired,
    onClick: PropTypes.func
};

//---------------
//Тело компонента
//---------------

//Фильтр отбора
const Filter = ({ filter, onClick }) => {
    //При нажатии на фильтр
    const handleClick = () => (onClick ? onClick() : null);

    //Генерация содержимого
    return (
        <Stack direction="row" spacing={1} p={1} alignItems={"center"}>
            <IconButton onClick={handleClick}>
                <Icon>filter_alt</Icon>
            </IconButton>
            {filter.belong ? <FilterItem caption={"Принадлежность"} value={filter.belong} onClick={handleClick} /> : null}
            {filter.prodObj ? <FilterItem caption={"Производственный объект"} value={filter.prodObj} onClick={handleClick} /> : null}
            {filter.techServ ? <FilterItem caption={"Техническая служба"} value={filter.techServ} onClick={handleClick} /> : null}
            {filter.respDep ? <FilterItem caption={"Ответственное подразделение"} value={filter.respDep} onClick={handleClick} /> : null}
            {filter.fromMonth && filter.fromYear ? (
                <FilterItem
                    caption={"Начало периода"}
                    value={`${filter.fromMonth < 10 ? "0" + filter.fromMonth : filter.fromMonth}.${filter.fromYear}`}
                    onClick={handleClick}
                />
            ) : null}
            {filter.toMonth && filter.toYear ? (
                <FilterItem
                    caption={"Конец периода"}
                    value={`${filter.toMonth < 10 ? "0" + filter.toMonth : filter.toMonth}.${filter.toYear}`}
                    onClick={handleClick}
                />
            ) : null}
        </Stack>
    );
};

//Контроль свойств компонента - Фильтр отбора
Filter.propTypes = {
    filter: PropTypes.object.isRequired,
    onClick: PropTypes.func
};

//--------------------
//Интерфейс компонента
//--------------------

export { Filter };

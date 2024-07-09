/*
    Парус 8 - Панели мониторинга - РО - Редактор настройки регламентированного отчёта
    Панель мониторинга: Компонент поля ввода 
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useEffect } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Box, FormControl, InputLabel, Input, InputAdornment, IconButton, Icon } from "@mui/material"; //Интерфейсные компоненты

//---------
//Константы
//---------

//Стили
export const STYLES = {
    DIALOG_WINDOW_WIDTH: { width: 400 }
};

//---------------
//Тело компонента
//---------------

const IUDFormTextField = ({ elementCode, elementValue, labelText, onChange, dictionary, ...other }) => {
    //Значение элемента
    const [value, setValue] = useState(elementValue);

    //При получении нового значения из вне
    useEffect(() => {
        setValue(elementValue);
    }, [elementValue]);

    //Выбор значения из словаря
    const handleDictionaryClick = () =>
        dictionary ? dictionary(res => (res ? handleChange({ target: { name: elementCode, value: res } }) : null)) : null;

    //Изменение значения элемента
    const handleChange = e => {
        setValue(e.target.value);
        if (onChange) onChange(e.target.name, e.target.value);
    };

    //Генерация содержимого
    return (
        <Box sx={{ p: 1 }}>
            <FormControl variant="standard" sx={STYLES.DIALOG_WINDOW_WIDTH} {...other}>
                <InputLabel htmlFor={elementCode}>{labelText}</InputLabel>
                <Input
                    id={elementCode}
                    name={elementCode}
                    value={value ? value : ""}
                    endAdornment={
                        dictionary ? (
                            <InputAdornment position="end">
                                <IconButton aria-label={`${elementCode} select`} onClick={handleDictionaryClick} edge="end">
                                    <Icon>list</Icon>
                                </IconButton>
                            </InputAdornment>
                        ) : null
                    }
                    onChange={handleChange}
                    multiline
                    maxRows={4}
                />
            </FormControl>
        </Box>
    );
};

//Контроль свойств - Поле ввода
IUDFormTextField.propTypes = {
    elementCode: PropTypes.string.isRequired,
    elementValue: PropTypes.string,
    labelText: PropTypes.string.isRequired,
    onChange: PropTypes.func,
    dictionary: PropTypes.func
};

//--------------------
//Интерфейс компонента
//--------------------

export { IUDFormTextField };

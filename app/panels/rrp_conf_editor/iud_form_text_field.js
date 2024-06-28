/*
    Парус 8 - Панели мониторинга - РО - Редактор настройки регламентированного отчёта
    Панель мониторинга: Компонент поля ввода 
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useCallback, useEffect } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Box, FormControl, InputLabel, Input, InputAdornment, IconButton, Icon } from "@mui/material"; //Интерфейсные компоненты
import { STYLES } from "./layouts"; //Стили диалогового окна

//---------------
//Тело компонента
//---------------

const IUDFormTextField = ({ elementCode, elementValue, labelText, onChange, dictionary, ...other }) => {
    //Значение элемента
    const [value, setValue] = useState(elementValue);

    //Формирование идентификатора элемента
    // const generateId = useCallback(async () => {
    //     setElementId(`${elementCode}-input`);
    // }, [elementCode]);

    //При рендере поля ввода
    // useEffect(() => {
    //     generateId();
    // }, [generateId]);

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

    return (
        <Box sx={{ p: 1 }}>
            <FormControl sx={STYLES.DIALOG_WINDOW_WIDTH} {...other}>
                <InputLabel htmlFor={elementCode}>{labelText}</InputLabel>
                <Input
                    id={elementCode}
                    name={elementCode}
                    value={value}
                    endAdornment={
                        dictionary ? (
                            <InputAdornment position="end">
                                <IconButton aria-label={`${elementCode} select`} onClick={handleDictionaryClick} edge="end">
                                    <Icon>list</Icon>
                                </IconButton>
                            </InputAdornment>
                        ) : null
                    }
                    aria-describedby={`${elementCode}-helper-text`}
                    label={labelText}
                    onChange={handleChange}
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

/*
    Парус 8 - Панели мониторинга - ТОиР - Выполнение работ
    Компонент: Поле ввода диалога фильтра
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useEffect, useState } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { FormControl, InputLabel, Input, InputAdornment, IconButton, Icon, FormHelperText, Select, MenuItem } from "@mui/material"; //Интерфейсные компоненты

//---------
//Константы
//---------

//Стили
const STYLES = {
    HELPER_TEXT: { color: "red" }
};

//---------------
//Тело компонента
//---------------

//Поле ввода
const FilterInputField = ({ elementCode, elementValue, labelText, onChange, required = false, items = null, dictionary }) => {
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

    //Генерация поля с выбором из словаря Парус
    const renderInput = validationError => {
        return (
            <Input
                error={validationError}
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
        );
    };

    //Генерация поля с выпадающим списком
    const renderSelect = (items, validationError) => {
        return (
            <Select
                error={validationError}
                id={elementCode}
                name={elementCode}
                value={value}
                aria-describedby={`${elementCode}-helper-text`}
                label={labelText}
                onChange={handleChange}
            >
                {items
                    ? items.map((item, i) => (
                          <MenuItem key={i} value={item.value}>
                              {item.caption}
                          </MenuItem>
                      ))
                    : null}
            </Select>
        );
    };

    //Признак ошибки валидации
    const validationError = !value && required ? true : false;

    //Генерация содержимого
    return (
        <FormControl fullWidth variant="standard">
            <InputLabel htmlFor={elementCode}>{labelText}</InputLabel>
            {items ? renderSelect(items, validationError) : renderInput(validationError)}
            {validationError ? (
                <FormHelperText id={`${elementCode}-helper-text`} sx={STYLES.HELPER_TEXT}>
                    *Обязательное поле
                </FormHelperText>
            ) : null}
        </FormControl>
    );
};

//Контроль свойств - Поле ввода
FilterInputField.propTypes = {
    elementCode: PropTypes.string.isRequired,
    elementValue: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    labelText: PropTypes.string.isRequired,
    required: PropTypes.bool,
    items: PropTypes.arrayOf(PropTypes.object),
    dictionary: PropTypes.func,
    onChange: PropTypes.func
};

//--------------------
//Интерфейс компонента
//--------------------

export { FilterInputField };

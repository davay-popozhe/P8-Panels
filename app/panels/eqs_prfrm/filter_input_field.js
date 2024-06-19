/*
    Парус 8 - Панели мониторинга - ТОиР - Выполнение работ
    Панель мониторинга: Компонент поля ввода
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useEffect, useState, useCallback } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { FormControl, InputLabel, Input, InputAdornment, IconButton, Icon, FormHelperText, Select, MenuItem } from "@mui/material"; //Интерфейсные компоненты
import { MONTH_ARRAY } from "./filter_dialog"; //Название месяцев

//---------------
//Тело компонента
//---------------

//Поле ввода
const FilterInputField = props => {
    //Свойства
    const { elementCode, elementValue, labelText, changeFunc, required, isDateField, yearArray } = props;

    //Состояние идентификатора элемента
    const [elementId, setElementId] = useState("");

    //Формирование идентификатора элемента
    const generateId = useCallback(async () => {
        setElementId(!isDateField ? `${elementCode}-input` : `${elementCode}-select`);
    }, [elementCode, isDateField]);

    //При рендере поля ввода
    useEffect(() => {
        generateId();
    }, [generateId]);

    //Генерация поля с выбором из словаря Парус
    const renderInput = () => {
        return (
            <Input
                error={!elementValue && required ? true : false}
                id={elementId}
                value={elementValue}
                endAdornment={
                    <InputAdornment position="end">
                        <IconButton aria-label={`${elementCode} select`} onClick={changeFunc} edge="end">
                            <Icon>list</Icon>
                        </IconButton>
                    </InputAdornment>
                }
                aria-describedby={`${elementId}-helper-text`}
                label={labelText}
            />
        );
    };

    //Генерация поля с выпадающим списком
    const renderSelect = () => {
        return (
            <Select
                error={elementValue ? false : true}
                id={elementId}
                value={elementValue}
                aria-describedby={`${elementId}-helper-text`}
                label={labelText}
                onChange={changeFunc}
            >
                {labelText === "Месяц"
                    ? MONTH_ARRAY.map((item, i) => (
                          <MenuItem key={i + 1} value={i + 1}>
                              {item}
                          </MenuItem>
                      ))
                    : null}
                {labelText === "Год"
                    ? yearArray.map(item => (
                          <MenuItem key={item} value={item}>
                              {item}
                          </MenuItem>
                      ))
                    : null}
            </Select>
        );
    };

    //Генерация содержимого
    return (
        <FormControl readOnly={isDateField ? false : true} fullWidth variant="standard">
            <InputLabel htmlFor={elementId}>{labelText}</InputLabel>
            {isDateField ? renderSelect() : renderInput()}
            {required && !elementValue ? (
                <FormHelperText id={`${elementId}-helper-text`} sx={{ color: "red" }}>
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
    changeFunc: PropTypes.func.isRequired,
    required: PropTypes.bool,
    isDateField: PropTypes.bool,
    yearArray: PropTypes.arrayOf(PropTypes.number)
};

//Значения по умолчанию - Поле ввода
FilterInputField.defaultProps = {
    required: false,
    isDateField: false
};

//--------------------
//Интерфейс компонента
//--------------------

export { FilterInputField };

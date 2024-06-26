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

const IUDFormTextField = props => {
    //Свойства
    const { elementCode, elementValue, labelText, changeFunc, withDictionary, ...other } = props;

    //Состояние идентификатора элемента
    const [elementId, setElementId] = useState("");

    //Формирование идентификатора элемента
    const generateId = useCallback(async () => {
        setElementId(`${elementCode}-input`);
    }, [elementCode]);

    //При рендере поля ввода
    useEffect(() => {
        generateId();
    }, [generateId]);

    return (
        <Box sx={{ p: 1 }}>
            <FormControl sx={STYLES.DIALOG_WINDOW_WIDTH} {...other}>
                <InputLabel htmlFor={elementId}>{labelText}</InputLabel>
                <Input
                    id={elementId}
                    value={elementValue ? elementValue : ""}
                    onChange={!withDictionary ? e => changeFunc(e.target.value) : null}
                    aria-describedby={`${elementCode}-helper-text`}
                    label={labelText}
                    endAdornment={
                        withDictionary ? (
                            <InputAdornment position="end">
                                <IconButton aria-label={`${elementCode} select`} onClick={changeFunc} edge="end">
                                    <Icon>list</Icon>
                                </IconButton>
                            </InputAdornment>
                        ) : null
                    }
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
    changeFunc: PropTypes.func.isRequired,
    withDictionary: PropTypes.bool
};

//--------------------
//Интерфейс компонента
//--------------------

export { IUDFormTextField };

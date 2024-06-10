/*
    Кастомный FormControl
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Box, FormControl, InputLabel, OutlinedInput, InputAdornment, IconButton, Icon } from "@mui/material"; //Интерфейсные компоненты
import { STYLES } from "./layouts"; //Стили диалогового окна

//-----------
//Тело модуля
//-----------

const CustomFormControl = props => {
    const { elementCode, elementValue, labelText, changeFunc, withDictionary, ...other } = props;

    return (
        <Box sx={{ p: 1 }}>
            <FormControl sx={STYLES.DIALOG_WINDOW_WIDTH} {...other}>
                <InputLabel htmlFor={`${elementCode}-outlined`}>{labelText}</InputLabel>
                <OutlinedInput
                    id={`${elementCode}-outlined`}
                    value={elementValue ? elementValue : ""}
                    onChange={!withDictionary ? e => changeFunc(e.target.value) : null}
                    aria-describedby={`${elementCode}-outlined-helper-text`}
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

CustomFormControl.propTypes = {
    elementCode: PropTypes.string.isRequired,
    elementValue: PropTypes.string,
    labelText: PropTypes.string.isRequired,
    changeFunc: PropTypes.func.isRequired,
    withDictionary: PropTypes.bool
};

//----------------
//Интерфейс модуля
//----------------

export { CustomFormControl };

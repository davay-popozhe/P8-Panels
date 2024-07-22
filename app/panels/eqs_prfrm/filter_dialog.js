/*
    Парус 8 - Панели мониторинга - ТОиР - Выполнение работ
    Компонент: Диалоговое окно фильтра отбора
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useContext } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Dialog, DialogTitle, IconButton, Icon, DialogContent, DialogActions, Button, Box, Grid } from "@mui/material"; //Интерфейсные компоненты
import { FilterInputField } from "./filter_input_field"; //Компонент поля ввода
import { ApplicationСtx } from "../../context/application"; //Контекст приложения

//---------
//Константы
//---------

//Массив месяцев
const MONTH_ARRAY = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"];

//Стили
const STYLES = {
    DIALOG_ACTIONS: { justifyContent: "center" },
    CLOSE_BUTTON: {
        position: "absolute",
        right: 8,
        top: 8,
        color: theme => theme.palette.grey[500]
    }
};

//-----------------------
//Вспомогательные функции
//-----------------------

//Формирование списка лет
const buildYears = () => {
    const res = [1990];
    const today = new Date();
    for (let i = res[0] + 1; i <= today.getFullYear(); i++) res.push(i);
    return res;
};

//Выбор принадлежности
const selectJuridicalPersons = (showDictionary, callBack) => {
    showDictionary({
        unitCode: "JuridicalPersons",
        callBack: res => (res.success === true ? callBack(res.outParameters.out_CODE) : callBack(null))
    });
};

//Выбор производственного объекта
const selectEquipConfiguration = (showDictionary, callBack) => {
    showDictionary({
        unitCode: "EquipConfiguration",
        callBack: res => (res.success === true ? callBack(res.outParameters.out_CODE) : callBack(null))
    });
};

//Выбор подразделения
const selectInsDepartment = (showDictionary, callBack) => {
    showDictionary({
        unitCode: "INS_DEPARTMENT",
        callBack: res => (res.success === true ? callBack(res.outParameters.out_CODE) : callBack(null))
    });
};

//---------------
//Тело компонента
//---------------

//Диалоговое окно фильтра отбора
const FilterDialog = ({ initial, onCancel, onOk }) => {
    //Собственное состояние
    const [filter, setFilter] = useState({ ...initial });

    //Подключение к контексту приложения
    const { pOnlineShowDictionary } = useContext(ApplicationСtx);

    //При закрытии диалога без изменения фильтра
    const handleCancel = () => (onCancel ? onCancel() : null);

    //При очистке фильтра
    const handleClear = () => {
        setFilter({
            belong: "",
            prodObj: "",
            techServ: "",
            respDep: "",
            fromMonth: "",
            fromYear: "",
            toMonth: "",
            toYear: ""
        });
    };

    //При закрытии диалога с изменением фильтра
    const handleOK = () => (onOk ? onOk(filter) : null);

    //При изменении значения элемента
    const handleFilterItemChange = (item, value) => setFilter(pv => ({ ...pv, [item]: value }));

    //Генерация содержимого
    return (
        <div>
            <Dialog open onClose={handleCancel} fullWidth maxWidth="sm">
                <DialogTitle>Фильтр отбора</DialogTitle>
                <IconButton aria-label="close" onClick={handleCancel} sx={STYLES.CLOSE_BUTTON}>
                    <Icon>close</Icon>
                </IconButton>
                <DialogContent>
                    <Box component="section" p={1}>
                        <FilterInputField
                            elementCode="belong"
                            elementValue={filter.belong}
                            labelText="Принадлежность"
                            dictionary={callBack => selectJuridicalPersons(pOnlineShowDictionary, callBack)}
                            required={true}
                            onChange={handleFilterItemChange}
                        />
                    </Box>
                    <Box component="section" p={1}>
                        <FilterInputField
                            elementCode="prodObj"
                            elementValue={filter.prodObj}
                            labelText="Производственный объект"
                            dictionary={callBack => selectEquipConfiguration(pOnlineShowDictionary, callBack)}
                            required={true}
                            onChange={handleFilterItemChange}
                        />
                    </Box>
                    <Box component="section" p={1}>
                        <FilterInputField
                            elementCode="techServ"
                            elementValue={filter.techServ}
                            labelText="Техническая служба"
                            dictionary={callBack => selectInsDepartment(pOnlineShowDictionary, callBack)}
                            onChange={handleFilterItemChange}
                        />
                    </Box>
                    <Box component="section" p={1}>
                        <FilterInputField
                            elementCode="respDep"
                            elementValue={filter.respDep}
                            labelText="Ответственное подразделение"
                            dictionary={callBack => selectInsDepartment(pOnlineShowDictionary, callBack)}
                            onChange={handleFilterItemChange}
                        />
                    </Box>
                    <Box component="section" p={1}>
                        <Grid container spacing={2} alignItems={"center"}>
                            <Grid textAlign={"left"} item xs={4}>
                                Начало периода:
                            </Grid>
                            <Grid item xs={4}>
                                <FilterInputField
                                    elementCode="fromMonth"
                                    elementValue={filter.fromMonth}
                                    labelText="Месяц"
                                    required={true}
                                    items={MONTH_ARRAY.map((item, i) => ({ value: i + 1, caption: item }))}
                                    onChange={handleFilterItemChange}
                                />
                            </Grid>
                            <Grid item xs={4}>
                                <FilterInputField
                                    elementCode="fromYear"
                                    elementValue={filter.fromYear}
                                    labelText="Год"
                                    required={true}
                                    items={buildYears().map(item => ({ value: item, caption: item }))}
                                    onChange={handleFilterItemChange}
                                />
                            </Grid>
                        </Grid>
                    </Box>
                    <Box component="section" p={1}>
                        <Grid container spacing={2} alignItems={"center"}>
                            <Grid textAlign={"left"} item xs={4}>
                                Конец периода:
                            </Grid>
                            <Grid item xs={4}>
                                <FilterInputField
                                    elementCode="toMonth"
                                    elementValue={filter.toMonth}
                                    labelText="Месяц"
                                    required={true}
                                    items={MONTH_ARRAY.map((item, i) => ({ value: i + 1, caption: item }))}
                                    onChange={handleFilterItemChange}
                                />
                            </Grid>
                            <Grid item xs={4}>
                                <FilterInputField
                                    elementCode="toYear"
                                    elementValue={filter.toYear}
                                    labelText="Год"
                                    required={true}
                                    items={buildYears().map(item => ({ value: item, caption: item }))}
                                    onChange={handleFilterItemChange}
                                />
                            </Grid>
                        </Grid>
                    </Box>
                </DialogContent>
                <DialogActions sx={STYLES.DIALOG_ACTIONS}>
                    <Button
                        variant="text"
                        disabled={
                            filter.belong && filter.prodObj && filter.fromMonth && filter.fromYear && filter.toMonth && filter.toYear ? false : true
                        }
                        onClick={handleOK}
                    >
                        Сформировать
                    </Button>
                    <Button variant="text" onClick={handleClear}>
                        Очистить
                    </Button>
                    <Button variant="text" onClick={handleCancel}>
                        Отмена
                    </Button>
                </DialogActions>
            </Dialog>
        </div>
    );
};

//Контроль свойств компонента - Диалоговое окно фильтра отбора
FilterDialog.propTypes = {
    initial: PropTypes.object.isRequired,
    onOk: PropTypes.func,
    onCancel: PropTypes.func
};

//--------------------
//Интерфейс компонента
//--------------------

export { FilterDialog };

/*
    Парус 8 - Панели мониторинга - ТОиР - Выполнение работ
    Панель мониторинга: Диалоговое окно фильтра отбора
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useContext, useEffect, useCallback } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Dialog, DialogTitle, IconButton, Icon, DialogContent, DialogActions, Button, Paper, Box, Grid } from "@mui/material"; //Интерфейсные компоненты
import { FilterInputField } from "./filter_input_field"; //Компонент поля ввода
import { ApplicationСtx } from "../../context/application"; //Контекст приложения
import { STYLES } from "./layouts"; //Стили

//---------
//Константы
//---------

//Массив месяцев
export const MONTH_ARRAY = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"];

//---------------
//Тело компонента
//---------------

//Диалоговое окно фильтра отбора
const FilterDialog = props => {
    //Свойства
    const { filter, filterCopy, filterOpen, setFilter, setFilterOpen, setDataGrid } = props;

    //Состояние ограничения редактирования фильтра
    const [filterLock, setFilterLock] = useState(false);

    //Состояние массива лет
    const [years, setYears] = useState({ array: [1990], filled: false });

    //Подключение к контексту приложения
    const { pOnlineShowDictionary } = useContext(ApplicationСtx);

    //Закрыть фильтр
    const closeFilter = e => {
        if (filterLock && e != undefined) setFilter(filterCopy);
        setFilterOpen(false);
    };

    //Очистить фильтр
    const clearFilter = () => {
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

    //Заполнение состояния массива лет
    const getYearArray = useCallback(async () => {
        const today = new Date();
        for (let i = years.array[0] + 1; i <= today.getFullYear(); i++) {
            setYears(pv => ({ ...pv, array: [...pv.array, i] }));
        }
        setYears(pv => ({ ...pv, filled: true }));
        //eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    //Только при первичном рендере
    useEffect(() => {
        if (filterOpen && !years.filled) getYearArray();
    }, [filterOpen, getYearArray, years.filled]);

    //Генерация содержимого
    return (
        <div>
            <Dialog open={filterOpen} onClose={closeFilter}>
                <DialogTitle>Фильтр отбора</DialogTitle>
                <IconButton
                    aria-label="close"
                    onClick={closeFilter}
                    sx={{
                        position: "absolute",
                        right: 8,
                        top: 8,
                        color: theme => theme.palette.grey[500]
                    }}
                >
                    <Icon>close</Icon>
                </IconButton>
                <DialogContent>
                    <Paper>
                        <Box component="section" sx={{ p: 1 }}>
                            <FilterInputField
                                elementCode="belong"
                                elementValue={filter.belong}
                                labelText="Принадлежность"
                                changeFunc={() => {
                                    pOnlineShowDictionary({
                                        unitCode: "JuridicalPersons",
                                        callBack: res =>
                                            res.success === true ? setFilter(pv => ({ ...pv, belong: res.outParameters.out_CODE })) : null
                                    });
                                }}
                                required={true}
                            />
                        </Box>
                        <Box component="section" sx={{ p: 1 }}>
                            <FilterInputField
                                elementCode="prodObj"
                                elementValue={filter.prodObj}
                                labelText="Производственный объект"
                                changeFunc={() => {
                                    pOnlineShowDictionary({
                                        unitCode: "EquipConfiguration",
                                        callBack: res =>
                                            res.success === true ? setFilter(pv => ({ ...pv, prodObj: res.outParameters.out_CODE })) : null
                                    });
                                }}
                                required={true}
                            />
                        </Box>
                        <Box component="section" sx={{ p: 1 }}>
                            <FilterInputField
                                elementCode="techServ"
                                elementValue={filter.techServ}
                                labelText="Техническая служба"
                                changeFunc={() => {
                                    pOnlineShowDictionary({
                                        unitCode: "INS_DEPARTMENT",
                                        callBack: res =>
                                            res.success === true ? setFilter(pv => ({ ...pv, techServ: res.outParameters.out_CODE })) : null
                                    });
                                }}
                            />
                        </Box>
                        <Box component="section" sx={{ p: 1 }}>
                            <FilterInputField
                                elementCode="respDep"
                                elementValue={filter.respDep}
                                labelText="Ответственное подразделение"
                                changeFunc={() => {
                                    pOnlineShowDictionary({
                                        unitCode: "INS_DEPARTMENT",
                                        callBack: res =>
                                            res.success === true ? setFilter(pv => ({ ...pv, respDep: res.outParameters.out_CODE })) : null
                                    });
                                }}
                            />
                        </Box>
                        <Box component="section" sx={{ p: 1 }}>
                            <Grid container spacing={2}>
                                <Grid textAlign={"center"} item xs={4}>
                                    Начало периода:
                                </Grid>
                                <Grid item xs={4}>
                                    <FilterInputField
                                        elementCode="from-month"
                                        elementValue={filter.fromMonth}
                                        labelText="Месяц"
                                        changeFunc={e => setFilter(pv => ({ ...pv, fromMonth: e.target.value }))}
                                        required={true}
                                        isDateField={true}
                                    />
                                </Grid>
                                <Grid item xs={4}>
                                    <FilterInputField
                                        elementCode="from-year"
                                        elementValue={filter.fromYear}
                                        labelText="Год"
                                        changeFunc={e => setFilter(pv => ({ ...pv, fromYear: e.target.value }))}
                                        required={true}
                                        isDateField={true}
                                        yearArray={years.array}
                                    />
                                </Grid>
                            </Grid>
                        </Box>
                        <Box component="section" sx={{ p: 1 }}>
                            <Grid container spacing={2}>
                                <Grid textAlign={"center"} item xs={4}>
                                    Конец периода:
                                </Grid>
                                <Grid item xs={4}>
                                    <FilterInputField
                                        elementCode="to-month"
                                        elementValue={filter.toMonth}
                                        labelText="Месяц"
                                        changeFunc={e => setFilter(pv => ({ ...pv, toMonth: e.target.value }))}
                                        required={true}
                                        isDateField={true}
                                    />
                                </Grid>
                                <Grid item xs={4}>
                                    <FilterInputField
                                        elementCode="to-year"
                                        elementValue={filter.toYear}
                                        labelText="Год"
                                        changeFunc={e => setFilter(pv => ({ ...pv, toYear: e.target.value }))}
                                        required={true}
                                        isDateField={true}
                                        yearArray={years.array}
                                    />
                                </Grid>
                            </Grid>
                        </Box>
                    </Paper>
                </DialogContent>
                <DialogActions sx={{ ...STYLES.FILTER_DIALOG_ACTIONS }}>
                    <Button
                        variant="text"
                        disabled={
                            filter.belong && filter.prodObj && filter.fromMonth && filter.fromYear && filter.toMonth && filter.toYear ? false : true
                        }
                        onClick={() => {
                            setFilterLock(true);
                            setDataGrid({ reload: true });
                            closeFilter();
                        }}
                    >
                        Сформировать
                    </Button>
                    <Button variant="text" onClick={clearFilter}>
                        Очистить
                    </Button>
                    <Button
                        variant="text"
                        onClick={() => {
                            setFilter(filterCopy);
                        }}
                    >
                        Отмена
                    </Button>
                </DialogActions>
            </Dialog>
        </div>
    );
};

//Контроль свойств компонента - Диалоговое окно фильтра отбора
FilterDialog.propTypes = {
    filter: PropTypes.object.isRequired,
    filterCopy: PropTypes.object.isRequired,
    filterOpen: PropTypes.bool.isRequired,
    setFilter: PropTypes.func.isRequired,
    setFilterOpen: PropTypes.func.isRequired,
    setDataGrid: PropTypes.func.isRequired
};

//--------------------
//Интерфейс компонента
//--------------------

export { FilterDialog };

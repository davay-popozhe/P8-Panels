/*
    Парус 8 - Панели мониторинга - ПУП - Выдача сменного задания
    Компонент панели: Таблица информации об операциях сменного задания
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Typography, Box, Checkbox, Grid, Icon, Button } from "@mui/material"; //Интерфейсные элементы
import { P8PDataGrid, P8P_DATA_GRID_SIZE } from "../../components/p8p_data_grid"; //Таблица данных
import { P8P_DATA_GRID_CONFIG_PROPS } from "../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { useCostRouteLists, useCostJobsSpecs, useCostEquipment } from "./backend"; //Собственные хуки таблиц

//---------
//Константы
//---------

const sUnitCostRouteLists = "CostRouteLists"; //Мнемокод раздела маршрутных листов
const sUnitCostJobsSpecs = "CostJobsSpecs"; //Мнемокод раздела операций
const sUnitCostEquipment = "CostEquipment"; //Мнемокод раздела рабочих центров

//Стили
const STYLES = {
    CONTAINER: { textAlign: "center" },
    TABLE: { paddingTop: "15px" },
    TABLE_SUM: { textAlign: "right", paddingTop: "5px", paddingRight: "15px" },
    TABLE_BUTTONS: { display: "flex", justifyContent: "flex-end" },
    CHECK_BOX: { textAlign: "center" },
    OPERATIONS_SEPARATOR: { padding: "3px 0px", backgroundColor: "lightblue" },
    INFORMATION_HALF: { minWidth: "50%", maxWidth: "50%", textAlign: "center" }
};

//---------------------------------------------
//Вспомогательные функции форматирования данных
//---------------------------------------------

//Формирование списка отмеченных записей
function selectedReducer(accumulator, current) {
    if (current.NSELECT == 1) {
        accumulator.push(current.NRN);
    }
    return accumulator;
}

//Форматирование значения ячейки
const dataCellRender = ({ row, columnDef, handleSelectChange, sUnit, selectedEquip }) => {
    //Инициализируем доступность выбора
    let disabled = false;
    //Если это рабочие центры
    if (sUnit === sUnitCostEquipment) {
        //Для колонки выбора
        if (columnDef.name === "NSELECT") {
            return {
                data: (
                    <Box sx={STYLES.CHECK_BOX}>
                        <Checkbox
                            disabled={selectedEquip.length === 1 && selectedEquip[0] !== row["NRN"]}
                            checked={row[columnDef.name]}
                            //checked={row[columnDef.name] === 1}
                            onChange={() => handleSelectChange(row["NRN"], sUnit, row["NCOEFF"] <= row["NLOADING"])}
                        />
                    </Box>
                )
            };
        }
        //Если оборудование загружено
        if (row["NCOEFF"] <= row["NLOADING"]) {
            //Если поле не поле выбора
            if (columnDef.name !== "NSELECT") {
                return {
                    cellStyle: { color: "lightgrey" },
                    data: row[columnDef.name]
                };
            }
        }
    }
    //Если это операции
    if (sUnit === sUnitCostJobsSpecs) {
        //Если "Оборудование план" операции сходится с выбранным оборудованием
        if (selectedEquip.includes(row["NEQUIP_PLAN"])) {
            //Если колонка выбора
            if (columnDef.name === "NSELECT") {
                return {
                    cellStyle: { backgroundColor: "#bce0de" },
                    data: (
                        <Box sx={STYLES.CHECK_BOX}>
                            <Checkbox
                                disabled={disabled}
                                checked={row[columnDef.name]}
                                //checked={row[columnDef.name] === 1}
                                onChange={() => handleSelectChange(row["NRN"], sUnit)}
                            />
                        </Box>
                    )
                };
            } else {
                return {
                    cellStyle: { backgroundColor: "#bce0de" },
                    data: row[columnDef.name]
                };
            }
        }
    }
    //Для колонки выбора
    if (columnDef.name === "NSELECT") {
        return {
            data: (
                <Box sx={STYLES.CHECK_BOX}>
                    <Checkbox
                        disabled={disabled}
                        checked={row[columnDef.name]}
                        //checked={row[columnDef.name] === 1}
                        onChange={() => handleSelectChange(row["NRN"], sUnit)}
                    />
                </Box>
            )
        };
    }
    return {
        data: row[columnDef.name]
    };
};

//Генерация представления ячейки заголовка группы
export const headCellRender = ({ columnDef }) => {
    if (columnDef.name === "NSELECT") {
        return {
            stackStyle: { padding: "2px", justifyContent: "space-around" },
            data: <Icon>done</Icon>
        };
    } else {
        return {
            stackStyle: { padding: "2px" },
            data: columnDef.caption
        };
    }
};

//-----------
//Тело модуля
//-----------

//Таблица информации об операциях сменного задания
const CostJobsSpecsDataGrid = ({ task, processIdent, clearSelectlist }) => {
    //Собственное состояние - таблица данных маршрутных листов
    const [costRouteLists, setCostRouteLists, modifySelectList] = useCostRouteLists(task, processIdent);

    //Собственное состояние - таблица данных операций
    const [costJobsSpecs, setCostJobsSpecs, issueCostJobsSpecs] = useCostJobsSpecs(task, costRouteLists.selectedRows, processIdent);

    //Собственное состояние - таблица рабочих центров
    const [costEquipment, setCostEquipment, includeCostEquipment, excludeCostEquipment] = useCostEquipment();

    //При изменении состояния сортировки маршрутных листов
    const costRouteListOrderChanged = ({ orders }) => setCostRouteLists(pv => ({ ...pv, orders: [...orders], pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц маршрутных листов
    const costRouteListPagesCountChanged = () => setCostRouteLists(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //При изменении состояния сортировки операций
    const costJobsSpecOrderChanged = ({ orders }) => setCostJobsSpecs(pv => ({ ...pv, orders: [...orders], pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц операций
    const costJobsSpecPagesCountChanged = () => setCostJobsSpecs(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //При изменении состояния сортировки рабочих центров
    const costEquipmentOrderChanged = ({ orders }) => setCostEquipment(pv => ({ ...pv, orders: [...orders], pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц рабочих центров
    const costEquipmentPagesCountChanged = () => setCostEquipment(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //При включении оборудования в операции
    const costJobsSpecIncludeCostEquipment = () => {
        //Делаем асинхронно, чтобы при ошибке ничего не обновлять
        const includeAsync = async () => {
            //Включаем оборудование в операции
            try {
                await includeCostEquipment({
                    NFCEQUIPMENT: costEquipment.selectedRows[0],
                    NFCJOBS: task,
                    SFCJOBSSP_LIST: costJobsSpecs.selectedRows.join(";")
                });
                //Необходимо обновить все данные
                setCostJobsSpecs(pv => ({ ...pv, selectedRows: [], reload: true }));
                setCostEquipment(pv => ({ ...pv, selectedRows: [], selectedLoaded: false, reload: true }));
            } catch (e) {
                throw new Error(e.message);
            }
        };
        //Включаем оборудование асинхронно
        includeAsync();
    };

    //При исключении оборудования из операции
    const costJobsSpecExcludeCostEquipment = () => {
        //Делаем асинхронно, чтобы при ошибке ничего не обновлять
        const excludeAsync = async () => {
            //Включаем оборудование в операции
            try {
                await excludeCostEquipment({
                    NFCEQUIPMENT: costEquipment.selectedRows[0],
                    NFCJOBS: task,
                    SFCJOBSSP_LIST: costJobsSpecs.selectedRows.join(";")
                });
                //Необходимо обновить данные о маршрутных листах и оборудовании
                setCostJobsSpecs(pv => ({ ...pv, selectedRows: [], reload: true }));
                setCostEquipment(pv => ({ ...pv, selectedRows: [], reload: true }));
            } catch (e) {
                throw new Error(e.message);
            }
        };
        //Исключаем операции асинхронно
        excludeAsync();
    };

    //Выдача задания операции
    const costJobsSpecIssue = () => {
        //Делаем асинхронно, чтобы при ошибке ничего не обновлять
        const issueAsync = async () => {
            //Включаем оборудование в операции
            try {
                await issueCostJobsSpecs({
                    NFCJOBS: task,
                    SFCJOBSSP_LIST: costJobsSpecs.selectedRows.join(";")
                });
                //Необходимо обновить данные о маршрутных листах и оборудовании
                clearSelectlist(processIdent);
                setCostRouteLists(pv => ({ ...pv, selectedRows: [], reload: true }));
                setCostEquipment(pv => ({ ...pv, selectedRows: [], reload: true }));
            } catch (e) {
                throw new Error(e.message);
            }
        };
        //Выдаем задание асинхронно
        issueAsync();
    };

    //При изменение состояния выбора
    const handleSelectChange = (NRN, sUnit, selectedLoaded) => {
        //Инициализируем строки таблицы
        let rows = [];
        //Индекс элемента в массиве
        let indexRow = null;
        //Исходим от раздела
        switch (sUnit) {
            //Маршрутные листы
            case sUnitCostRouteLists:
                //Инициализируем маршрутными листами
                rows = costRouteLists.rows;
                //Определяем индекс элемента в массиве
                indexRow = rows.findIndex(obj => obj.NRN == NRN);
                //Изменяем значение выбора
                rows[indexRow].NSELECT = !rows[indexRow].NSELECT;
                //Добавляем/удаляем маршрутный лист из селектлиста
                modifySelectList({ NFCROUTLST: NRN, NSELECT: rows[indexRow].NSELECT });
                //Актуализируем строки
                setCostRouteLists(pv => ({ ...pv, rows: rows, selectedRows: rows.reduce(selectedReducer, []) }));
                //Выходим
                break;
            //Операции
            case sUnitCostJobsSpecs:
                //Инициализируем операциями
                rows = costJobsSpecs.rows;
                //Определяем индекс элемента в массиве
                indexRow = rows.findIndex(obj => obj.NRN == NRN);
                //Изменяем значение выбора
                rows[indexRow].NSELECT = !rows[indexRow].NSELECT;
                //Актуализируем строки
                setCostJobsSpecs(pv => ({ ...pv, rows: rows, selectedRows: rows.reduce(selectedReducer, []) }));
                //Выходим
                break;
            //Рабочие центры
            case sUnitCostEquipment:
                //Инициализируем рабочими центрами
                rows = costEquipment.rows;
                //Определяем индекс элемента в массиве
                indexRow = rows.findIndex(obj => obj.NRN == NRN);
                //Изменяем значение выбора
                rows[indexRow].NSELECT = !rows[indexRow].NSELECT;
                //Актуализируем строки
                setCostEquipment(pv => ({ ...pv, rows: rows, selectedRows: rows.reduce(selectedReducer, []), selectedLoaded: selectedLoaded }));
                //Выходим
                break;
            default:
                return;
        }
    };

    //Генерация содержимого
    return (
        <div style={STYLES.CONTAINER}>
            <Grid container spacing={2}>
                <Grid item sx={STYLES.INFORMATION_HALF}>
                    <Typography variant={"h6"}>Маршрутные листы</Typography>
                    {costRouteLists.dataLoaded ? (
                        <>
                            <Box sx={STYLES.TABLE_BUTTONS}>
                                <Button
                                    variant="contained"
                                    size="small"
                                    disabled={costJobsSpecs.selectedRows.length === 0}
                                    onClick={costJobsSpecIssue}
                                >
                                    Выдать задания
                                </Button>
                            </Box>
                            <Box sx={STYLES.TABLE}>
                                <P8PDataGrid
                                    {...P8P_DATA_GRID_CONFIG_PROPS}
                                    columnsDef={costRouteLists.columnsDef}
                                    rows={costRouteLists.rows}
                                    size={P8P_DATA_GRID_SIZE.SMALL}
                                    morePages={costRouteLists.morePages}
                                    reloading={costRouteLists.reload}
                                    onOrderChanged={costRouteListOrderChanged}
                                    onPagesCountChanged={costRouteListPagesCountChanged}
                                    dataCellRender={prms => dataCellRender({ ...prms, handleSelectChange, sUnit: sUnitCostRouteLists })}
                                    headCellRender={prms => headCellRender({ ...prms })}
                                />
                                {costRouteLists.selectedRows.length > 0 ? (
                                    <>
                                        <Box sx={STYLES.OPERATIONS_SEPARATOR}>Операции выбранных маршрутных листов</Box>
                                        <P8PDataGrid
                                            {...P8P_DATA_GRID_CONFIG_PROPS}
                                            columnsDef={costJobsSpecs.columnsDef}
                                            rows={costJobsSpecs.rows}
                                            size={P8P_DATA_GRID_SIZE.SMALL}
                                            morePages={costJobsSpecs.morePages}
                                            reloading={costJobsSpecs.reload}
                                            onOrderChanged={costJobsSpecOrderChanged}
                                            onPagesCountChanged={costJobsSpecPagesCountChanged}
                                            dataCellRender={prms =>
                                                dataCellRender({
                                                    ...prms,
                                                    handleSelectChange,
                                                    sUnit: sUnitCostJobsSpecs,
                                                    selectedEquip: costEquipment.selectedRows
                                                })
                                            }
                                            headCellRender={prms => headCellRender({ ...prms })}
                                        />
                                    </>
                                ) : null}
                            </Box>
                        </>
                    ) : null}
                </Grid>
                <Grid item sx={STYLES.INFORMATION_HALF}>
                    <Typography variant={"h6"}>Рабочие центры</Typography>
                    {costEquipment.dataLoaded ? (
                        <>
                            <Box sx={STYLES.TABLE_BUTTONS}>
                                <Button
                                    variant="contained"
                                    size="small"
                                    disabled={
                                        costEquipment.selectedRows.length !== 1 ||
                                        (costEquipment.selectedRows.length === 1 && costJobsSpecs.selectedRows.length === 0) ||
                                        costEquipment.selectedLoaded
                                    }
                                    onClick={costJobsSpecIncludeCostEquipment}
                                >
                                    Включить в задание
                                </Button>
                                <Box ml={1}>
                                    <Button
                                        variant="contained"
                                        size="small"
                                        disabled={
                                            costEquipment.selectedRows.length !== 1 ||
                                            (costEquipment.selectedRows.length === 1 && costJobsSpecs.selectedRows.length === 0)
                                        }
                                        onClick={costJobsSpecExcludeCostEquipment}
                                    >
                                        Исключить из задания
                                    </Button>
                                </Box>
                            </Box>
                            <Box sx={STYLES.TABLE}>
                                <P8PDataGrid
                                    {...P8P_DATA_GRID_CONFIG_PROPS}
                                    columnsDef={costEquipment.columnsDef}
                                    rows={costEquipment.rows}
                                    size={P8P_DATA_GRID_SIZE.SMALL}
                                    morePages={costEquipment.morePages}
                                    reloading={costEquipment.reload}
                                    onOrderChanged={costEquipmentOrderChanged}
                                    onPagesCountChanged={costEquipmentPagesCountChanged}
                                    dataCellRender={prms =>
                                        dataCellRender({
                                            ...prms,
                                            handleSelectChange,
                                            sUnit: sUnitCostEquipment,
                                            selectedEquip: costEquipment.selectedRows
                                        })
                                    }
                                    headCellRender={prms => headCellRender({ ...prms })}
                                />
                            </Box>
                        </>
                    ) : null}
                </Grid>
            </Grid>
        </div>
    );
};

//Контроль свойств - Таблица информации об операциях сменного задания
CostJobsSpecsDataGrid.propTypes = {
    task: PropTypes.number.isRequired,
    processIdent: PropTypes.number,
    clearSelectlist: PropTypes.func
};

//----------------
//Интерфейс модуля
//----------------

export { CostJobsSpecsDataGrid };

/*
    Парус 8 - Панели мониторинга - ПУП - Производственная программа
    Компонент панели: Таблица приходов из подразделений
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Typography, Box } from "@mui/material"; //Интерфейсные элементы
import { P8PDataGrid, P8P_DATA_GRID_SIZE } from "../../../components/p8p_data_grid"; //Таблица данных
import { P8P_DATA_GRID_CONFIG_PROPS } from "../../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { useIncomFromDeps } from "./backend_dg"; //Собственные хуки таблиц

//---------
//Константы
//---------

//Стили
const STYLES = {
    CONTAINER: { textAlign: "center" },
    TABLE: { paddingTop: "15px" }
};

//-----------
//Тело модуля
//-----------

//Таблица приходов из подразделений
const IncomFromDepsDataGrid = ({ task, taskType }) => {
    //Собственное состояние - таблица данных
    const [incomFromDeps, setIncomFromDeps] = useIncomFromDeps(task, taskType);

    //При изменении состояния сортировки
    const handleOrderChanged = ({ orders }) => setIncomFromDeps(pv => ({ ...pv, orders: [...orders], pageNumber: 1, reload: true }));

    //При изменении количества отображаемых страниц
    const handlePagesCountChanged = () => setIncomFromDeps(pv => ({ ...pv, pageNumber: pv.pageNumber + 1, reload: true }));

    //Генерация содержимого
    return (
        <div style={STYLES.CONTAINER}>
            <Typography variant={"h6"}>Приходы из подразделений</Typography>
            <Box sx={STYLES.TABLE}>
                {incomFromDeps.dataLoaded ? (
                    <P8PDataGrid
                        {...P8P_DATA_GRID_CONFIG_PROPS}
                        columnsDef={incomFromDeps.columnsDef}
                        rows={incomFromDeps.rows}
                        size={P8P_DATA_GRID_SIZE.LARGE}
                        morePages={incomFromDeps.morePages}
                        reloading={incomFromDeps.reload}
                        onOrderChanged={handleOrderChanged}
                        onPagesCountChanged={handlePagesCountChanged}
                    />
                ) : null}
            </Box>
        </div>
    );
};

//Контроль свойств - Таблица приходов из подразделений
IncomFromDepsDataGrid.propTypes = {
    task: PropTypes.number.isRequired,
    taskType: PropTypes.number
};

//----------------
//Интерфейс модуля
//----------------

export { IncomFromDepsDataGrid };

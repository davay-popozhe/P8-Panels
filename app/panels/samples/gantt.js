/*
    Парус 8 - Панели мониторинга - Примеры для разработчиков
    Пример: Диаграмма Ганта "P8PGantt"
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useContext, useCallback, useEffect } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import {
    Typography,
    Grid,
    Stack,
    Icon,
    Box,
    FormControlLabel,
    Checkbox,
    Card,
    CardHeader,
    CardActions,
    Avatar,
    CardContent,
    Button
} from "@mui/material"; //Интерфейсные элементы
import { formatDateJSONDateOnly, formatDateRF } from "../../core/utils"; //Вспомогательные функции
import { P8PGantt } from "../../components/p8p_gantt"; //Диаграмма Ганта
import { P8P_GANTT_CONFIG_PROPS } from "../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером

//---------
//Константы
//---------

//Высота диаграммы Ганта
const GANTT_HEIGHT = "70vh";

//Ширина диаграммы Ганта
const GANTT_WIDTH = "98vw";

//Стили
const STYLES = {
    CONTAINER: { textAlign: "center", paddingTop: "20px" },
    TITLE: { paddingBottom: "15px" },
    GANTT_CONTAINER: { height: GANTT_HEIGHT, width: GANTT_WIDTH }
};

//---------------------------------------------
//Вспомогательные функции форматирования данных
//---------------------------------------------

//Формирование значения для колонки "Тип задачи"
const formatTaskTypeValue = value => {
    const [text, icon] = value == 0 ? ["Этап проекта", "check"] : ["Работа проекта", "work_outline"];
    return (
        <Stack direction="row" gap={0.5}>
            <Icon title={text}>{icon}</Icon>
            {text}
        </Stack>
    );
};

//Генерация кастомных представлений атрибутов задачи в редакторе
const taskAttributeRenderer = ({ task, attribute }) => {
    switch (attribute.name) {
        case "type":
            return formatTaskTypeValue(task.type);
        default:
            return null;
    }
};

//Генерация кастомного диалога задачи
const taskDialogRenderer = ({ task, close }) => {
    return (
        <Card>
            <CardHeader
                avatar={<Avatar sx={{ bgcolor: task.bgColor }}>{task.type == 0 ? "Эт" : "Ра"}</Avatar>}
                title={task.name}
                subheader={`с ${formatDateRF(task.start)} по ${formatDateRF(task.end)}`}
            />
            <CardContent>
                <Typography variant="body2" color="text.secondary">
                    Это пользовательский диалог с данными о задаче. Вы можете формировать такие указав свой функциональный компонент в качестве
                    свойства &quot;taskDialogRenderer&quot; компонента &quot;P8PGantt&quot;.
                </Typography>
            </CardContent>
            <CardActions disableSpacing>
                <Button size="small" onClick={close}>
                    Закрыть
                </Button>
            </CardActions>
        </Card>
    );
};

//-----------
//Тело модуля
//-----------

//Пример: Диаграмма Ганта "P8Gantt"
const Gantt = ({ title }) => {
    //Собственное состояние
    const [state, setState] = useState({
        init: false,
        dataLoaded: false,
        ident: null,
        ganttDef: {},
        ganttTasks: [],
        useCustomTaskDialog: false
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored } = useContext(BackEndСtx);

    //Загрузка данных диаграммы с сервера
    const loadData = useCallback(async () => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_SAMPLES.GANTT",
            args: { NIDENT: state.ident },
            attributeValueProcessor: (name, val) =>
                name == "numb" ? undefined : ["start", "end"].includes(name) ? formatDateJSONDateOnly(val) : val,
            respArg: "COUT"
        });
        setState(pv => ({ ...pv, dataLoaded: true, ganttDef: { ...data.XGANTT_DEF }, ganttTasks: [...data.XGANTT_TASKS] }));
    }, [state.ident, executeStored]);

    //Инициализация данных диаграммы
    const initData = useCallback(async () => {
        if (!state.init) {
            const data = await executeStored({ stored: "PKG_P8PANELS_SAMPLES.GANTT_INIT", args: { NIDENT: state.ident } });
            setState(pv => ({ ...pv, init: true, ident: data.NIDENT }));
        }
    }, [state.init, state.ident, executeStored]);

    //Изменение данных диаграммы
    const modifyData = useCallback(
        async ({ rn, start, end }) => {
            try {
                await executeStored({
                    stored: "PKG_P8PANELS_SAMPLES.GANTT_MODIFY",
                    args: { NIDENT: state.ident, NRN: rn, DDATE_FROM: new Date(start), DDATE_TO: new Date(end) }
                });
            } finally {
                loadData();
            }
        },
        [state.ident, executeStored, loadData]
    );

    //Обработка измненения сроков задачи в диаграмме Гантта
    const handleTaskDatesChange = ({ task, start, end, isMain }) => {
        if (isMain) modifyData({ rn: task.rn, start, end });
    };

    //При необходимости обновить данные таблицы
    useEffect(() => {
        if (state.ident) loadData();
    }, [state.ident, loadData]);

    //При подключении компонента к странице
    useEffect(() => {
        initData();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    //Генерация содержимого
    return (
        <div style={STYLES.CONTAINER}>
            <Typography sx={STYLES.TITLE} variant={"h6"}>
                {title}
            </Typography>
            <FormControlLabel
                control={<Checkbox onChange={() => setState(pv => ({ ...pv, useCustomTaskDialog: !pv.useCustomTaskDialog }))} />}
                label="Отображать пользовательский диалог задачи"
            />
            <Grid container spacing={0} direction="column" alignItems="center">
                <Grid item xs={12}>
                    {state.dataLoaded ? (
                        <Box sx={STYLES.GANTT_CONTAINER} p={1}>
                            <P8PGantt
                                {...P8P_GANTT_CONFIG_PROPS}
                                {...state.ganttDef}
                                height={GANTT_HEIGHT}
                                tasks={state.ganttTasks}
                                onTaskDatesChange={handleTaskDatesChange}
                                taskAttributeRenderer={taskAttributeRenderer}
                                taskDialogRenderer={state.useCustomTaskDialog ? taskDialogRenderer : null}
                            />
                        </Box>
                    ) : null}
                </Grid>
            </Grid>
        </div>
    );
};

//Контроль свойств - Пример: Диаграмма Ганта "P8Gantt"
Gantt.propTypes = {
    title: PropTypes.string.isRequired
};

//----------------
//Интерфейс модуля
//----------------

export { Gantt };

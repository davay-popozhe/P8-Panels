/*
    Парус 8 - Панели мониторинга
    Компонент: Диаграмма Ганта
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useEffect, useState, useCallback } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import {
    Box,
    IconButton,
    Icon,
    Typography,
    Dialog,
    DialogActions,
    DialogContent,
    TextField,
    Button,
    List,
    ListItem,
    ListItemText,
    Divider,
    Slider,
    Link
} from "@mui/material"; //Интерфейсные компоненты
import { P8PAppInlineError } from "./p8p_app_message"; //Встраиваемое сообщение об ошибке

//---------
//Константы
//---------

//Уровни масштаба
const P8P_GANTT_ZOOM = [0, 1, 2, 3, 4];

//Уровни масштаба (строковые наименования в терминах библиотеки)
const P8P_GANTT_ZOOM_VIEW_MODES = {
    0: "Quarter Day",
    1: "Half Day",
    2: "Day",
    3: "Week",
    4: "Month"
};

//Структура задачи
const P8P_GANTT_TASK_SHAPE = PropTypes.shape({
    id: PropTypes.string.isRequired,
    rn: PropTypes.number.isRequired,
    numb: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    fullName: PropTypes.string.isRequired,
    start: PropTypes.string.isRequired,
    end: PropTypes.string.isRequired,
    progress: PropTypes.number,
    dependencies: PropTypes.array,
    readOnly: PropTypes.bool,
    readOnlyDates: PropTypes.bool,
    readOnlyProgress: PropTypes.bool,
    bgColor: PropTypes.string,
    textColor: PropTypes.string
});

//Структура динамического атрибута задачи
const P8P_GANTT_TASK_ATTRIBUTE_SHAPE = PropTypes.shape({
    name: PropTypes.string.isRequired,
    caption: PropTypes.string.isRequired
});

//Структура описания цвета задачи
const P8P_GANTT_TASK_COLOR_SHAPE = PropTypes.shape({
    bgColor: PropTypes.string,
    textColor: PropTypes.string,
    desc: PropTypes.string.isRequired
});

//Стили
const STYLES = {
    TASK_EDITOR_LIST: { width: "100%", minWidth: 300, maxWidth: 700, bgcolor: "background.paper" }
};

//--------------------------------
//Вспомогательные классы и функции
//--------------------------------

//Проверка существования значения
const hasValue = value => typeof value !== "undefined" && value !== null && value !== "";

//Редактор задачи
const P8PGanttTaskEditor = ({
    task,
    taskAttributes,
    taskColors,
    onOk,
    onCancel,
    taskAttributeRenderer,
    numbCaption,
    nameCaption,
    startCaption,
    endCaption,
    progressCaption,
    legendCaption,
    okBtnCaption,
    cancelBtnCaption
}) => {
    //Собственное состояние
    const [state, setState] = useState({
        start: task.start,
        end: task.end,
        progress: task.progress
    });

    //При сохранении
    const handleOk = () => (onOk && state.start && state.end ? onOk({ task, start: state.start, end: state.end, progress: state.progress }) : null);

    //При отмене
    const handleCancel = () => (onCancel ? onCancel() : null);

    //При изменении сроков
    const handlePeriodChanged = e => {
        setState(prev => ({ ...prev, [e.target.name]: e.target.value }));
    };

    //При изменении прогресса
    const handleProgressChanged = (e, newValue) => {
        console.log(newValue);
        setState(prev => ({ ...prev, progress: newValue }));
    };

    //Описание легенды для задачи
    let legend = null;
    if (Array.isArray(taskColors)) {
        const colorDesc = taskColors.find(color => task.bgColor === color.bgColor && task.textColor === color.textColor);
        if (colorDesc)
            legend = (
                <ListItemText
                    secondaryTypographyProps={{
                        p: 1,
                        sx: {
                            ...(colorDesc.bgColor ? { backgroundColor: colorDesc.bgColor } : {}),
                            ...(colorDesc.textColor ? { color: colorDesc.textColor } : {})
                        }
                    }}
                    primary={legendCaption}
                    secondary={colorDesc.desc}
                />
            );
    }

    //Генерация содержимого
    return (
        <Dialog open onClose={handleCancel}>
            <DialogContent>
                <List sx={STYLES.TASK_EDITOR_LIST}>
                    <ListItem alignItems="flex-start">
                        <ListItemText primary={numbCaption} secondary={task.numb} />
                    </ListItem>
                    <Divider component="li" />
                    <ListItem alignItems="flex-start">
                        <ListItemText primary={nameCaption} secondary={task.fullName} />
                    </ListItem>
                    <Divider component="li" />
                    <ListItem alignItems="flex-start">
                        <ListItemText
                            secondaryTypographyProps={{ component: "span" }}
                            primary={startCaption}
                            secondary={
                                <TextField
                                    error={!state.start}
                                    disabled={task.readOnly === true || task.readOnlyDates === true}
                                    name="start"
                                    fullWidth
                                    required
                                    InputLabelProps={{ shrink: true }}
                                    type={"date"}
                                    value={state.start}
                                    onChange={handlePeriodChanged}
                                    variant="standard"
                                    size="small"
                                    margin="normal"
                                />
                            }
                        />
                    </ListItem>
                    <Divider component="li" />
                    <ListItem alignItems="flex-start">
                        <ListItemText
                            secondaryTypographyProps={{ component: "span" }}
                            primary={endCaption}
                            secondary={
                                <TextField
                                    error={!state.end}
                                    disabled={task.readOnly === true || task.readOnlyDates === true}
                                    name="end"
                                    fullWidth
                                    required
                                    InputLabelProps={{ shrink: true }}
                                    type={"date"}
                                    value={state.end}
                                    onChange={handlePeriodChanged}
                                    variant="standard"
                                    size="small"
                                    margin="normal"
                                />
                            }
                        />
                    </ListItem>
                    <Divider component="li" />
                    {hasValue(task.progress) ? (
                        <>
                            <ListItem alignItems="flex-start">
                                <ListItemText
                                    secondaryTypographyProps={{ component: "span" }}
                                    primary={`${progressCaption}${
                                        task.readOnly === true || task.readOnlyProgress === true ? ` (${task.progress}%)` : ""
                                    }`}
                                    secondary={
                                        <Slider
                                            disabled={task.readOnly === true || task.readOnlyProgress === true}
                                            defaultValue={task.progress}
                                            valueLabelDisplay="auto"
                                            onChange={handleProgressChanged}
                                        />
                                    }
                                />
                            </ListItem>
                            <Divider component="li" />
                        </>
                    ) : null}
                    {legend ? (
                        <>
                            <ListItem alignItems="flex-start">{legend}</ListItem>
                            <Divider component="li" />
                        </>
                    ) : null}
                    {Array.isArray(taskAttributes) && taskAttributes.length > 0
                        ? taskAttributes
                              .filter(attr => hasValue(task[attr.name]))
                              .map((attr, i) => {
                                  const defaultView = task[attr.name];
                                  const customView = taskAttributeRenderer ? taskAttributeRenderer({ task, attribute: attr }) : null;
                                  return (
                                      <React.Fragment key={i}>
                                          <ListItem alignItems="flex-start">
                                              <ListItemText
                                                  primary={attr.caption}
                                                  secondaryTypographyProps={{ component: "span" }}
                                                  secondary={customView ? customView : defaultView}
                                              />
                                          </ListItem>
                                          {i < taskAttributes.length - 1 ? <Divider component="li" /> : null}
                                      </React.Fragment>
                                  );
                              })
                        : null}
                </List>
            </DialogContent>
            <DialogActions>
                <Button disabled={!state.start || !state.end || task.readOnly} onClick={handleOk}>
                    {okBtnCaption}
                </Button>
                <Button onClick={handleCancel}>{cancelBtnCaption}</Button>
            </DialogActions>
        </Dialog>
    );
};

//Контроль свойств - Редактор задачи
P8PGanttTaskEditor.propTypes = {
    task: P8P_GANTT_TASK_SHAPE,
    taskAttributes: PropTypes.arrayOf(P8P_GANTT_TASK_ATTRIBUTE_SHAPE),
    taskColors: PropTypes.arrayOf(P8P_GANTT_TASK_COLOR_SHAPE),
    onOk: PropTypes.func,
    onCancel: PropTypes.func,
    taskAttributeRenderer: PropTypes.func,
    numbCaption: PropTypes.string.isRequired,
    nameCaption: PropTypes.string.isRequired,
    startCaption: PropTypes.string.isRequired,
    endCaption: PropTypes.string.isRequired,
    progressCaption: PropTypes.string.isRequired,
    legendCaption: PropTypes.string.isRequired,
    okBtnCaption: PropTypes.string.isRequired,
    cancelBtnCaption: PropTypes.string.isRequired
};

//-----------
//Тело модуля
//-----------

//Диаграмма Ганта
const P8PGantt = ({
    height,
    title,
    titleStyle,
    onTitleClick,
    zoomBar,
    readOnly,
    readOnlyDates,
    readOnlyProgress,
    zoom,
    tasks,
    taskAttributes,
    taskColors,
    onTaskDatesChange,
    onTaskProgressChange,
    taskAttributeRenderer,
    noDataFoundText,
    numbTaskEditorCaption,
    nameTaskEditorCaption,
    startTaskEditorCaption,
    endTaskEditorCaption,
    progressTaskEditorCaption,
    legendTaskEditorCaption,
    okTaskEditorBtnCaption,
    cancelTaskEditorBtnCaption
}) => {
    //Собственное состояние
    const [state, setState] = useState({
        noData: true,
        gantt: null,
        zoom: P8P_GANTT_ZOOM.includes(zoom) ? zoom : 3,
        editTask: null
    });

    //Отображение диаграммы
    const showGantt = useCallback(() => {
        if (!state.gantt) {
            // eslint-disable-next-line no-undef
            const gantt = new Gantt("#__gantt__", tasks, {
                view_mode: P8P_GANTT_ZOOM_VIEW_MODES[state.zoom],
                date_format: "YYYY-MM-DD",
                language: "ru",
                readOnly,
                readOnlyDates,
                readOnlyProgress,
                on_date_change: (task, start, end, isMain) => (onTaskDatesChange ? onTaskDatesChange({ task, start, end, isMain }) : null),
                on_progress_change: (task, progress) => (onTaskProgressChange ? onTaskProgressChange({ task, progress }) : null),
                on_click: openTaskEditor
            });
            setState(pv => ({ ...pv, gantt, noData: false }));
        } else {
            state.gantt.refresh(tasks);
            setState(pv => ({ ...pv, noData: false }));
        }
    }, [state.gantt, state.zoom, readOnly, readOnlyDates, readOnlyProgress, tasks, onTaskDatesChange, onTaskProgressChange]);

    //Обновление масштаба диаграммы
    const handleZoomChange = direction =>
        setState(pv => ({
            ...pv,
            zoom: pv.zoom + direction < 0 ? 0 : pv.zoom + direction >= P8P_GANTT_ZOOM.length ? P8P_GANTT_ZOOM.length - 1 : pv.zoom + direction
        }));

    //Открытие редактора задачи
    const openTaskEditor = task => setState(pv => ({ ...pv, editTask: { ...task } }));

    //При сохранении задачи в редакторе
    const handleTaskEditorSave = ({ task, start, end, progress }) => {
        setState(pv => ({ ...pv, editTask: null }));
        if (onTaskDatesChange && (task.start != start || task.end != end)) onTaskDatesChange({ task, start, end, isMain: true });
        if (onTaskProgressChange && task.progress != progress) onTaskProgressChange({ task, progress });
    };

    //При закрытии редактора задачи без сохранения
    const handleTaskEditorCancel = () => setState(pv => ({ ...pv, editTask: null }));

    //При изменении масштаба
    useEffect(() => {
        if (state.gantt) state.gantt.change_view_mode(P8P_GANTT_ZOOM_VIEW_MODES[state.zoom]);
    }, [state.gantt, state.zoom]);

    //При изменении списка задач
    useEffect(() => {
        if (Array.isArray(tasks) && tasks.length > 0) showGantt();
        else setState(pv => ({ ...pv, noData: true }));
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [tasks]);

    //Генерация содержимого
    return (
        <div>
            {state.gantt && state.noData ? <P8PAppInlineError text={noDataFoundText} /> : null}
            {state.gantt && !state.noData && title ? (
                <Typography p={1} sx={{ ...(titleStyle ? titleStyle : {}) }} align="center" color="textSecondary" variant="subtitle1">
                    {onTitleClick ? (
                        <Link component="button" variant="body2" underline="hover" onClick={() => onTitleClick()}>
                            {title}
                        </Link>
                    ) : (
                        title
                    )}
                </Typography>
            ) : null}
            {state.gantt && !state.noData && zoomBar ? (
                <Box p={1}>
                    <IconButton onClick={() => handleZoomChange(-1)} disabled={state.zoom == 0}>
                        <Icon>zoom_in</Icon>
                    </IconButton>
                    <IconButton onClick={() => handleZoomChange(1)} disabled={state.zoom == P8P_GANTT_ZOOM.length - 1}>
                        <Icon>zoom_out</Icon>
                    </IconButton>
                </Box>
            ) : null}
            {state.editTask ? (
                <P8PGanttTaskEditor
                    task={state.editTask}
                    taskAttributes={taskAttributes}
                    taskColors={taskColors}
                    onOk={handleTaskEditorSave}
                    onCancel={handleTaskEditorCancel}
                    taskAttributeRenderer={taskAttributeRenderer}
                    numbCaption={numbTaskEditorCaption}
                    nameCaption={nameTaskEditorCaption}
                    startCaption={startTaskEditorCaption}
                    endCaption={endTaskEditorCaption}
                    progressCaption={progressTaskEditorCaption}
                    legendCaption={legendTaskEditorCaption}
                    okBtnCaption={okTaskEditorBtnCaption}
                    cancelBtnCaption={cancelTaskEditorBtnCaption}
                />
            ) : null}
            <div style={{ height, display: state.noData ? "none" : "" }}>
                <svg id="__gantt__" width="100%"></svg>
            </div>
        </div>
    );
};

//Контроль свойств - Диаграмма Ганта
P8PGantt.propTypes = {
    height: PropTypes.string.isRequired,
    title: PropTypes.string,
    titleStyle: PropTypes.object,
    onTitleClick: PropTypes.func,
    zoomBar: PropTypes.bool,
    readOnly: PropTypes.bool,
    readOnlyDates: PropTypes.bool,
    readOnlyProgress: PropTypes.bool,
    zoom: PropTypes.number,
    tasks: PropTypes.arrayOf(P8P_GANTT_TASK_SHAPE).isRequired,
    taskAttributes: PropTypes.arrayOf(P8P_GANTT_TASK_ATTRIBUTE_SHAPE),
    taskColors: PropTypes.arrayOf(P8P_GANTT_TASK_COLOR_SHAPE),
    onTaskDatesChange: PropTypes.func,
    onTaskProgressChange: PropTypes.func,
    taskAttributeRenderer: PropTypes.func,
    noDataFoundText: PropTypes.string.isRequired,
    numbTaskEditorCaption: PropTypes.string.isRequired,
    nameTaskEditorCaption: PropTypes.string.isRequired,
    startTaskEditorCaption: PropTypes.string.isRequired,
    endTaskEditorCaption: PropTypes.string.isRequired,
    progressTaskEditorCaption: PropTypes.string.isRequired,
    legendTaskEditorCaption: PropTypes.string.isRequired,
    okTaskEditorBtnCaption: PropTypes.string.isRequired,
    cancelTaskEditorBtnCaption: PropTypes.string.isRequired
};

//----------------
//Интерфейс модуля
//----------------

export { P8P_GANTT_TASK_SHAPE, P8P_GANTT_TASK_ATTRIBUTE_SHAPE, P8P_GANTT_TASK_COLOR_SHAPE, P8PGantt };

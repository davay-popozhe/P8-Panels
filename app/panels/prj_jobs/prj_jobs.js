/*
    Парус 8 - Панели мониторинга - ПУП - Работы проектов
    Панель мониторинга: Корневая панель работ проектов
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useContext, useState, useCallback, useEffect } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Drawer, Fab, Box, Grid, List, ListItemButton, ListItemText, ListItemIcon, Icon, Typography, Stack } from "@mui/material"; //Интерфейсные элементы
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { MessagingСtx } from "../../context/messaging"; //Контекст сообщений
import { ApplicationСtx } from "../../context/application"; //Контекст приложения
import { P8P_GANTT_CONFIG_PROPS } from "../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { P8PGantt } from "../../components/p8p_gantt"; //Диаграмма Ганта
import { formatDateJSONDateOnly } from "../../core/utils"; //Вспомогательные функции

//---------
//Константы
//---------

//Высота диаграммы Ганта
const GANTT_HEIGHT = "650px";

//Ширина диаграммы Ганта
const GANTT_WIDTH = "98vw";

//Стили
const STYLES = {
    PROJECTS_LIST_ITEM_NOJOBS: { backgroundColor: "#ff000045" },
    PROJECTS_LIST_ITEM_PRIMARY: { wordWrap: "break-word" },
    PROJECTS_LIST_ITEM_SECONDARY: { wordWrap: "break-word", fontSize: "0.5rem", textTransform: "uppercase" },
    PROJECTS_LIST_ITEM_SECONDARY_NOJOBS: { color: "red" },
    PROJECTS_LIST_ITEM_SECONDARY_NOEDIT: { color: "gray" },
    PROJECTS_LIST_ITEM_SECONDARY_CHANGED: { color: "green" },
    PROJECTS_BUTTON: { position: "absolute" },
    PROJECTS_DRAWER: { width: "250px", flexShrink: 0, [`& .MuiDrawer-paper`]: { width: "250px", boxSizing: "border-box" } },
    GANTT_CONTAINER: { height: GANTT_HEIGHT, width: GANTT_WIDTH },
    GANTT_TITLE: { paddingLeft: "100px", paddingRight: "100px" }
};

//------------------------------------
//Вспомогательные функции и компоненты
//------------------------------------

//Формирование значения для колонки "Состояние" этапа
const formatStageStatusValue = value => {
    const [text, icon] =
        value == 0
            ? ["Зарегистрирован", "app_registration"]
            : value == 1
            ? ["Открыт", "lock_open"]
            : value == 2
            ? ["Закрыт", "lock_outline"]
            : value == 3
            ? ["Согласован", "thumb_up_alt"]
            : value == 4
            ? ["Исполнение прекращено", "block"]
            : ["Остановлен", "do_not_disturb_on"];
    return (
        <Stack direction="row" gap={0.5} alignItems="center">
            <Icon title={text}>{icon}</Icon>
            {text}
        </Stack>
    );
};

//Формирование значения для колонки "Состояние" работы
const formatJobStatusValue = value => {
    const [text, icon] =
        value == 0
            ? ["Не начата", "not_started"]
            : value == 1
            ? ["Выполняется", "loop"]
            : value == 2
            ? ["Выполнена", "task_alt"]
            : value == 3
            ? ["Остановлена", "do_not_disturb_on"]
            : ["Отменена", "cancel"];
    return (
        <Stack direction="row" gap={0.5} alignItems="center">
            <Icon title={text}>{icon}</Icon>
            {text}
        </Stack>
    );
};

//Список проектов
const ProjectsList = ({ projects = [], selectedProject, onClick } = {}) => {
    //Подключение к контексту сообщений
    const { InlineMsgErr } = useContext(MessagingСtx);

    //Генерация содержимого
    return projects.length > 0 ? (
        <List>
            {projects.map(p => (
                <ListItemButton
                    key={p.NRN}
                    sx={p.NJOBS == 0 ? STYLES.PROJECTS_LIST_ITEM_NOJOBS : null}
                    selected={p.NRN === selectedProject}
                    onClick={() => (onClick ? onClick(p) : null)}
                >
                    <ListItemIcon>
                        <Icon title={p.NEDITABLE == 1 ? "Можно редактировать" : "Редактирование недоступно"}>
                            {p.NEDITABLE == 1 ? "edit" : "edit_off"}
                        </Icon>
                    </ListItemIcon>
                    <ListItemText
                        primary={<Typography sx={STYLES.PROJECTS_LIST_ITEM_PRIMARY}>{p.SNAME}</Typography>}
                        secondary={
                            <Typography
                                sx={{
                                    ...STYLES.PROJECTS_LIST_ITEM_SECONDARY,
                                    ...(p.NJOBS == 0
                                        ? STYLES.PROJECTS_LIST_ITEM_SECONDARY_NOJOBS
                                        : p.NCHANGED == 1
                                        ? STYLES.PROJECTS_LIST_ITEM_SECONDARY_CHANGED
                                        : STYLES.PROJECTS_LIST_ITEM_SECONDARY_NOEDIT)
                                }}
                            >
                                {p.NJOBS == 1
                                    ? p.NEDITABLE == 1
                                        ? p.NCHANGED == 1
                                            ? "Изменён"
                                            : "Не изменён"
                                        : "Редактирование недоступно"
                                    : "Работы не определены"}
                            </Typography>
                        }
                    />
                </ListItemButton>
            ))}
        </List>
    ) : (
        <InlineMsgErr okBtn={false} text={"Нет доступных проектов"} />
    );
};

//Контроль свойств - Список проектов
ProjectsList.propTypes = {
    projects: PropTypes.array,
    selectedProject: PropTypes.number,
    onClick: PropTypes.func
};

//-----------
//Тело модуля
//-----------

//Корневая панель работ проектов
const PrjJobs = () => {
    //Собственное состояние
    let [state, setState] = useState({
        showProjectsList: false,
        init: false,
        ident: null,
        projects: [],
        projectsLoaded: false,
        selectedProjectJobsLoaded: false,
        selectedProject: null,
        selectedProjectDocRn: null,
        selectedProjectGanttDef: {},
        selectedProjectTasks: []
    });

    //Подключение к контексту приложения
    const { pOnlineShowDocument } = useContext(ApplicationСtx);

    //Подключение к контексту сообщений
    const { InlineMsgInfo } = useContext(MessagingСtx);

    //Подключение к контексту взаимодействия с сервером
    const { executeStored } = useContext(BackEndСtx);

    //Загрузка списка проектов
    const loadProjects = useCallback(async () => {
        if (!state.projectsLoaded) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_PROJECTS.JB_PRJCTS_LIST",
                args: {
                    NIDENT: state.ident
                },
                respArg: "COUT"
            });
            setState(pv => ({ ...pv, projectsLoaded: true, projects: [...(data?.XPROJECTS || [])] }));
        }
    }, [executeStored, state.ident, state.projectsLoaded]);

    //Загрузка списка работ проекта
    const loadProjectJobs = useCallback(
        async (tasksOnly = false) => {
            const data = await executeStored({
                stored: "PKG_P8PANELS_PROJECTS.JB_JOBS_LIST",
                args: {
                    NIDENT: state.ident,
                    NPRN: state.selectedProject,
                    NINCLUDE_DEF: tasksOnly === false ? 1 : 0
                },
                attributeValueProcessor: (name, val) =>
                    name == "numb" ? undefined : ["start", "end"].includes(name) ? formatDateJSONDateOnly(val) : val,
                respArg: "COUT"
            });
            setState(pv => ({
                ...pv,
                selectedProjectJobsLoaded: true,
                selectedProjectGanttDef: tasksOnly === true ? { ...pv.selectedProjectGanttDef } : data.XGANTT_DEF ? { ...data.XGANTT_DEF } : {},
                selectedProjectTasks: [...data.XGANTT_TASKS]
            }));
        },
        [executeStored, state.ident, state.selectedProject]
    );

    //Инициализация данных балансировки
    const initJobs = useCallback(async () => {
        if (!state.init) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_PROJECTS.JB_INIT",
                args: {
                    DBEGIN: null,
                    DFACT: null,
                    NDURATION_MEAS: 0,
                    SLAB_MEAS: null,
                    NINCLUDE_DEF: null,
                    NIDENT: state.ident
                }
            });
            setState(pv => ({ ...pv, init: true, ident: data.NIDENT }));
        }
    }, [state.init, state.ident, executeStored]);

    //При смене идентификатора процесса
    useEffect(() => {
        if (state.ident) loadProjects();
    }, [state.ident, loadProjects]);

    //При смене выбранного проекта
    useEffect(() => {
        if (state.selectedProject) loadProjectJobs(false);
    }, [state.selectedProject, loadProjectJobs]);

    //При подключении компонента к странице
    useEffect(() => {
        initJobs();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    //Обработка нажатия на элемент в списке проектов
    const handleProjectClick = project => {
        if (state.selectedProject != project.NRN) {
            setState(pv => ({
                ...pv,
                selectedProject: project.NRN,
                selectedProjectDocRn: project.NPROJECT,
                selectedProjectJobsLoaded: false,
                selectedProjectTasks: [],
                selectedProjectGanttDef: {},
                showProjectsList: false
            }));
        } else
            setState(pv => ({
                ...pv,
                selectedProjectJobsLoaded: false,
                selectedProject: null,
                selectedProjectDocRn: null,
                selectedProjectTasks: [],
                selectedProjectGanttDef: {},
                showProjectsList: false
            }));
    };

    //Отработка нажатия на заголовок плана-графика
    const handleTitleClick = () =>
        state.selectedProjectDocRn ? pOnlineShowDocument({ unitCode: "Projects", document: state.selectedProjectDocRn }) : null;

    //Обработка измненения сроков задачи в диаграмме Гантта
    const handleTaskDatesChange = ({ task, start, end, isMain }) => {
        console.log("ПОМЕНЯЛИ ДАТЫ");
        console.log(task);
        console.log(start);
        console.log(end);
        if (isMain) {
            console.log("ЭТО - ГЛАВНОЕ. ПОЙДЁМ НА СЕРВЕР...");
            loadProjectJobs(true);
        }
    };

    //Обработка изменения прогресса задачи в диаграмме Гантта
    const handleTaskProgressChange = ({ task, progress }) => {
        console.log("ПОМЕНЯЛИ % ГОТОВНОСТИ");
        console.log(task);
        console.log(progress);
    };

    //Генерация кастомных представлений атрибутов задачи в редакторе
    const taskAttributeRenderer = ({ task, attribute }) => {
        switch (attribute.name) {
            case "type":
                return task.type === 1 ? "Этап проекта" : "Работа проекта";
            case "state":
                return task.type === 1 ? formatStageStatusValue(task[attribute.name]) : formatJobStatusValue(task[attribute.name]);
            default:
                return null;
        }
    };

    //Генерация содержимого
    return (
        <Box p={2}>
            <Fab variant="extended" sx={STYLES.PROJECTS_BUTTON} onClick={() => setState(pv => ({ ...pv, showProjectsList: !pv.showProjectsList }))}>
                Проекты
            </Fab>
            <Drawer
                anchor={"left"}
                open={state.showProjectsList}
                onClose={() => setState(pv => ({ ...pv, showProjectsList: false }))}
                sx={STYLES.PROJECTS_DRAWER}
            >
                {state.projectsLoaded ? (
                    <ProjectsList projects={state.projects} selectedProject={state.selectedProject} onClick={handleProjectClick} />
                ) : null}
            </Drawer>
            {state.init == true ? (
                <Grid container spacing={1}>
                    <Grid item xs={12}>
                        {state.selectedProjectJobsLoaded ? (
                            <Box sx={STYLES.GANTT_CONTAINER} p={1}>
                                <P8PGantt
                                    {...P8P_GANTT_CONFIG_PROPS}
                                    {...state.selectedProjectGanttDef}
                                    height={GANTT_HEIGHT}
                                    titleStyle={STYLES.GANTT_TITLE}
                                    onTitleClick={handleTitleClick}
                                    tasks={state.selectedProjectTasks}
                                    onTaskDatesChange={handleTaskDatesChange}
                                    onTaskProgressChange={handleTaskProgressChange}
                                    taskAttributeRenderer={taskAttributeRenderer}
                                />
                            </Box>
                        ) : !state.selectedProject ? (
                            <InlineMsgInfo okBtn={false} text={"Укажите проект для отображения его плана-графика"} />
                        ) : null}
                    </Grid>
                </Grid>
            ) : null}
        </Box>
    );
};

//----------------
//Интерфейс модуля
//----------------

export { PrjJobs };

/*
    Парус 8 - Панели мониторинга - ПУП - Работы проектов
    Панель мониторинга: Корневая панель работ проектов
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useContext, useState, useCallback, useEffect } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import {
    Drawer,
    Fab,
    Box,
    Grid,
    List,
    ListItemButton,
    ListItemText,
    ListItemIcon,
    Icon,
    Typography,
    Divider,
    ListItem,
    Button,
    Dialog,
    DialogContent,
    DialogActions,
    TextField,
    DialogTitle
} from "@mui/material"; //Интерфейсные элементы
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { MessagingСtx } from "../../context/messaging"; //Контекст сообщений
import { ApplicationСtx } from "../../context/application"; //Контекст приложения
import { formatDateJSONDateOnly } from "../../core/utils"; //Вспомогательные функции
import { P8P_GANTT_CONFIG_PROPS } from "../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { P8PGantt } from "../../components/p8p_gantt"; //Диаграмма Ганта
import { formatDateRF } from "../../core/utils"; //Вспомогательные функции
import { BUTTONS } from "../../../app.text"; //Текстовые ресурсы и константы
import { ResMon } from "./res_mon"; //Монитор ресурсов
import { taskAttributeRenderer } from "./layouts"; //Дополнительная разметка и вёрстка клиентских элементов

//---------
//Константы
//---------

//Высота диаграммы Ганта
const GANTT_HEIGHT = "75vh";

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
    GANTT_TITLE: { paddingLeft: "100px", paddingRight: "120px" },
    PERIODS_BUTTON: { position: "absolute", right: "20px" },
    PERIODS_DRAWER: { width: "1200px", flexShrink: 0, [`& .MuiDrawer-paper`]: { width: "1200px", boxSizing: "border-box" } }
};

//Единицы измерения длительности
const DURATION_MEAS = {
    0: "День",
    1: "Неделя",
    2: "Декада",
    3: "Месяц",
    4: "Квартал",
    5: "Год"
};

//------------------------------------
//Вспомогательные функции и компоненты
//------------------------------------

//Диалог параметров инициализации панели
const InitDialog = ({ dateBegin, dateFact, onOk, onCancel }) => {
    //Собственное состояние - значения с-по
    const [values, setValues] = useState({ dateBegin: formatDateJSONDateOnly(dateBegin), dateFact: formatDateJSONDateOnly(dateFact) });

    //Отработка воода значения в фильтр
    const handleValueTextFieldChanged = e => setValues(prev => ({ ...prev, [e.target.name]: e.target.value }));

    //Генерация содержимого
    return (
        <Dialog
            open={true}
            aria-labelledby="init-dialog-title"
            aria-describedby="init-dialog-description"
            onClose={() => (onCancel ? onCancel() : null)}
        >
            <DialogTitle>Параметры инициализации</DialogTitle>
            <DialogContent>
                <TextField
                    style={{ padding: "10px" }}
                    name="dateBegin"
                    type="date"
                    value={values.dateBegin}
                    onChange={handleValueTextFieldChanged}
                    label="Начало (будет использован первый день месяца)"
                    variant="standard"
                    fullWidth
                />
                <TextField
                    style={{ padding: "10px" }}
                    name="dateFact"
                    type="date"
                    value={values.dateFact}
                    onChange={handleValueTextFieldChanged}
                    label="Факт на (будет использован последний день месяца)"
                    variant="standard"
                    fullWidth
                />
            </DialogContent>
            <DialogActions>
                <Button onClick={() => (onOk ? onOk({ dateBegin: new Date(values.dateBegin), dateFact: new Date(values.dateFact) }) : null)}>
                    {BUTTONS.OK}
                </Button>
                <Button onClick={() => (onCancel ? onCancel() : null)}>{BUTTONS.CANCEL}</Button>
            </DialogActions>
        </Dialog>
    );
};

//Контроль свойств - Диалог параметров инициализации панели
InitDialog.propTypes = {
    dateBegin: PropTypes.instanceOf(Date).isRequired,
    dateFact: PropTypes.instanceOf(Date).isRequired,
    onOk: PropTypes.func,
    onCancel: PropTypes.func
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
        needSave: false,
        showProjectsList: false,
        showPeriodsList: false,
        init: false,
        dateBegin: null,
        dateFact: null,
        durationMeas: null,
        labMeas: null,
        resourceStatus: null,
        ident: null,
        projects: [],
        projectsLoaded: false,
        selectedProjectJobsLoaded: false,
        selectedProject: null,
        selectedProjectDocRn: null,
        selectedProjectGanttDef: {},
        selectedProjectTasks: [],
        showInitDialog: false
    });

    //Подключение к контексту приложения
    const { pOnlineShowDocument } = useContext(ApplicationСtx);

    //Подключение к контексту сообщений
    const { InlineMsgInfo } = useContext(MessagingСtx);

    //Подключение к контексту взаимодействия с сервером
    const { executeStored } = useContext(BackEndСtx);

    //Загрузка списка проектов
    const loadProjects = useCallback(
        async (force = false) => {
            if (!state.projectsLoaded || force) {
                const data = await executeStored({
                    stored: "PKG_P8PANELS_PROJECTS.JB_PRJCTS_LIST",
                    args: { NIDENT: state.ident },
                    respArg: "COUT",
                    isArray: name => name === "XPROJECTS"
                });
                setState(pv => ({ ...pv, projectsLoaded: true, projects: [...(data?.XPROJECTS || [])] }));
            }
        },
        [executeStored, state.ident, state.projectsLoaded]
    );

    //Загрузка списка работ проекта
    const loadProjectJobs = useCallback(
        async (tasksOnly = false) => {
            const data = await executeStored({
                stored: "PKG_P8PANELS_PROJECTS.JB_JOBS_LIST",
                args: { NIDENT: state.ident, NPRN: state.selectedProject, NINCLUDE_DEF: tasksOnly === false ? 1 : 0 },
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

    //Изменение работы в графике
    const modifyJob = useCallback(
        async (job, dateFrom, dateTo, dateBegin, dateFact, durationMeas) => {
            let data = null;
            try {
                data = await executeStored({
                    stored: "PKG_P8PANELS_PROJECTS.JB_JOBS_MODIFY_PERIOD",
                    args: { NJB_JOBS: job, DDATE_FROM: dateFrom, DDATE_TO: dateTo, DBEGIN: dateBegin, DFACT: dateFact, NDURATION_MEAS: durationMeas }
                });
                if (data?.NRESOURCE_STATUS != -1) {
                    setState(pv => ({ ...pv, resourceStatus: data.NRESOURCE_STATUS, needSave: true }));
                    loadProjects(true);
                }
            } finally {
                loadProjectJobs(true);
            }
        },
        [executeStored, loadProjectJobs, loadProjects]
    );

    //Сохранение буфера балансировки в проекты
    const saveProjects = useCallback(async () => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_PROJECTS.JB_SAVE",
            args: { NIDENT: state.ident },
            respArg: "COUT"
        });
        setState(pv => ({ ...pv, needSave: false, projects: [...(data?.XPROJECTS || [])] }));
    }, [executeStored, state.ident]);

    //Инициализация данных балансировки
    const initJobs = useCallback(async () => {
        if (!state.init) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_PROJECTS.JB_INIT",
                args: {
                    DBEGIN: state.dateBegin ? state.dateBegin : null,
                    DFACT: state.dateFact ? state.dateFact : null,
                    NDURATION_MEAS: state.durationMeas,
                    SLAB_MEAS: state.labMeas,
                    NIDENT: state.ident
                }
            });
            setState(pv => ({
                ...pv,
                init: true,
                reInit: false,
                dateBegin: new Date(data.DBEGIN),
                dateFact: new Date(data.DFACT),
                durationMeas: data.NDURATION_MEAS,
                labMeas: data.SLAB_MEAS,
                resourceStatus: data.NRESOURCE_STATUS,
                ident: data.NIDENT
            }));
        }
    }, [state.init, state.dateBegin, state.dateFact, state.durationMeas, state.labMeas, state.ident, executeStored]);

    //Грузим список проектов при смене идентификатора процесса
    useEffect(() => {
        if (state.ident) loadProjects();
    }, [state.ident, loadProjects]);

    //При смене выбранного проекта
    useEffect(() => {
        if (state.selectedProject) loadProjectJobs(false);
    }, [state.selectedProject, loadProjectJobs]);

    //При изменении флага инициализации
    useEffect(() => {
        initJobs();
    }, [state.init, initJobs]);

    //Выбор проекта
    const selectPoject = (project, projectDocRn) => {
        setState(pv => ({
            ...pv,
            selectedProject: project,
            selectedProjectDocRn: projectDocRn,
            selectedProjectJobsLoaded: false,
            selectedProjectTasks: [],
            selectedProjectGanttDef: {},
            showProjectsList: false
        }));
    };

    //Сброс выбора проекта
    const unselectProject = () =>
        setState(pv => ({
            ...pv,
            selectedProjectJobsLoaded: false,
            selectedProject: null,
            selectedProjectDocRn: null,
            selectedProjectTasks: [],
            selectedProjectGanttDef: {},
            showProjectsList: false
        }));

    //Обработка нажатия на элемент в списке проектов
    const handleProjectClick = project => {
        if (state.selectedProject != project.NRN) selectPoject(project.NRN, project.NPROJECT);
        else unselectProject();
    };

    //Отработка нажатия на заголовок плана-графика
    const handleTitleClick = () =>
        state.selectedProjectDocRn ? pOnlineShowDocument({ unitCode: "Projects", document: state.selectedProjectDocRn }) : null;

    //Обработка измненения сроков задачи в диаграмме Гантта
    const handleTaskDatesChange = ({ task, start, end, isMain }) => {
        if (isMain) modifyJob(task.rn, new Date(start), new Date(end), new Date(state.dateBegin), new Date(state.dateFact), state.durationMeas);
    };

    //Отработка нажатия на отображения диалога параметров инициализации панели
    const handleShowInitDialogClick = () => setState(pv => ({ ...pv, showInitDialog: true }));

    //Отработка нажатия на "ОК" в диалоге параметров инициализации панели
    const handleOKInitDialogClick = values =>
        setState(pv => ({ ...pv, dateBegin: values.dateBegin, dateFact: values.dateFact, showInitDialog: false, init: false }));

    //Отработка нажатия на "Отмена" в диалоге параметров инициализации панели
    const handleCancelInitDialogClick = () => setState(pv => ({ ...pv, showInitDialog: false }));

    //Обработка нажатия на сохранение данных в проект
    const handleSaveToProjectsClick = () => saveProjects();

    //Обработка нажатия на проект в таблице детализации трудоёмкости по плану-графику монитора ресурсов
    const handlePlanJobsDtlProjectClick = ({ sender }) => {
        setState(pv => ({ ...pv, showPeriodsList: false }));
        if (state.selectedProject != sender.NJB_PRJCTS) selectPoject(sender.NJB_PRJCTS, sender.NPROJECT);
    };

    //Генерация содержимого
    return (
        <Box p={2}>
            {state.showInitDialog ? (
                <InitDialog
                    dateBegin={state.dateBegin}
                    dateFact={state.dateFact}
                    onOk={handleOKInitDialogClick}
                    onCancel={handleCancelInitDialogClick}
                />
            ) : null}
            <Fab variant="extended" sx={STYLES.PROJECTS_BUTTON} onClick={() => setState(pv => ({ ...pv, showProjectsList: !pv.showProjectsList }))}>
                Проекты
                {state.needSave ? (
                    <>
                        &nbsp;&nbsp;
                        <Icon sx={{ color: "orange" }}>save</Icon>
                    </>
                ) : null}
            </Fab>
            <Drawer
                anchor={"left"}
                open={state.showProjectsList}
                onClose={() => setState(pv => ({ ...pv, showProjectsList: false }))}
                sx={STYLES.PROJECTS_DRAWER}
            >
                {state.projectsLoaded ? (
                    <>
                        <List>
                            <ListItem>
                                <ListItemText
                                    secondary={
                                        <>
                                            <b>Начало: </b>
                                            {formatDateRF(state.dateBegin)}
                                            <br />
                                            <b>Факт на: </b>
                                            {formatDateRF(state.dateFact)}
                                            <br />
                                            <b>Длительность: </b>
                                            {DURATION_MEAS[state.durationMeas]}
                                            <br />
                                            <b>Трудоёмкость: </b>
                                            {state.labMeas}
                                        </>
                                    }
                                />
                            </ListItem>
                            <ListItem>
                                <Button fullWidth variant="contained" startIcon={<Icon>refresh</Icon>} onClick={handleShowInitDialogClick}>
                                    Переформировать...
                                </Button>
                            </ListItem>
                        </List>
                        <Divider />
                        {state.needSave ? (
                            <>
                                <List>
                                    <ListItem>
                                        <Button
                                            fullWidth
                                            color="warning"
                                            variant="contained"
                                            startIcon={<Icon>save</Icon>}
                                            onClick={handleSaveToProjectsClick}
                                        >
                                            Сохранить
                                        </Button>
                                    </ListItem>
                                </List>
                                <Divider />
                            </>
                        ) : null}
                        <ProjectsList projects={state.projects} selectedProject={state.selectedProject} onClick={handleProjectClick} />
                    </>
                ) : null}
            </Drawer>
            <Fab variant="extended" sx={STYLES.PERIODS_BUTTON} onClick={() => setState(pv => ({ ...pv, showPeriodsList: !pv.showPeriodsList }))}>
                Ресурсы
                {[0, 1].includes(state.resourceStatus) ? (
                    <>
                        &nbsp;&nbsp;
                        <Icon sx={{ color: state.resourceStatus === 0 ? "green" : "red" }}>{state.resourceStatus === 0 ? "done" : "error"}</Icon>
                    </>
                ) : null}
            </Fab>
            <Drawer
                anchor={"right"}
                open={state.showPeriodsList}
                onClose={() => setState(pv => ({ ...pv, showPeriodsList: false }))}
                sx={STYLES.PERIODS_DRAWER}
            >
                {state.ident ? <ResMon ident={state.ident} onPlanJobsDtlProjectClick={handlePlanJobsDtlProjectClick} /> : null}
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

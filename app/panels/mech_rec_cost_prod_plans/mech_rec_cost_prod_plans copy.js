/*
    Парус 8 - Панели мониторинга - ПУП - Производственная программа
    Панель мониторинга: Корневая панель производственной программы
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useContext, useState, useCallback, useEffect } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Drawer, Fab, Box, List, ListItemButton, ListItemText, Typography, Grid, TextField, Select, MenuItem, InputLabel } from "@mui/material"; //Интерфейсные элементы
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { MessagingСtx } from "../../context/messaging"; //Контекст сообщений
import { ApplicationСtx } from "../../context/application"; //Контекст приложения
import { P8P_GANTT_CONFIG_PROPS } from "../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { P8PGantt } from "../../components/p8p_gantt"; //Диаграмма Ганта
import { formatDateJSONDateOnly } from "../../core/utils"; //Вспомогательные функции
import { useFilteredPlans } from "./hooks"; //Вспомогательные хуки

//---------
//Константы
//---------

//Высота диаграммы Ганта
const GANTT_HEIGHT = "650px";

//Ширина диаграммы Ганта
const GANTT_WIDTH = "98vw";

//Стили
const STYLES = {
    PROJECTS_FINDER: { marginTop: "10px", marginLeft: "10px", width: "93%" },
    PROJECTS_LIST_ITEM_PRIMARY: { wordWrap: "break-word" },
    PROJECTS_LIST_ITEM_SECONDARY: { wordWrap: "break-word", fontSize: "0.5rem", textTransform: "uppercase" },
    PROJECTS_LIST_ITEM_SECONDARY_NOJOBS: { color: "red" },
    PROJECTS_LIST_ITEM_SECONDARY_NOEDIT: { color: "gray" },
    PROJECTS_LIST_ITEM_SECONDARY_CHANGED: { color: "green" },
    PROJECTS_BUTTON: { position: "absolute" },
    PROJECTS_DRAWER: {
        minWidth: "250px",
        display: "inline-block",
        flexShrink: 0,
        [`& .MuiDrawer-paper`]: { minWidth: "250px", display: "inline-block", boxSizing: "border-box" }
    },
    GANTT_CONTAINER: { height: GANTT_HEIGHT, width: GANTT_WIDTH },
    GANTT_TITLE: { paddingLeft: "100px", paddingRight: "120px" },
    PERIODS_BUTTON: { position: "absolute", right: "20px" },
    PERIODS_DRAWER: { width: "1000px", flexShrink: 0, [`& .MuiDrawer-paper`]: { width: "1000px", boxSizing: "border-box" } }
};

//Список проектов
const ProjectsList = ({ plans = [], selectedPlan, filter, setFilter, onClick } = {}) => {
    //Генерация содержимого
    return (
        <div>
            <TextField
                sx={STYLES.PROJECTS_FINDER}
                name="planFilter"
                label="План"
                value={filter}
                variant="standard"
                fullWidth
                onChange={event => {
                    setFilter(event.target.value);
                }}
            ></TextField>
            <List>
                {plans.map(p => (
                    <ListItemButton key={p.NRN} selected={p.NRN === selectedPlan} onClick={() => (onClick ? onClick(p) : null)}>
                        <ListItemText
                            primary={<Typography sx={STYLES.PROJECTS_LIST_ITEM_PRIMARY}>{p.SDOC_INFO}</Typography>}
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
                                ></Typography>
                            }
                        />
                    </ListItemButton>
                ))}
            </List>
        </div>
    );
};

//Контроль свойств - Список проектов
ProjectsList.propTypes = {
    plans: PropTypes.array,
    selectedPlan: PropTypes.number,
    onClick: PropTypes.func,
    filter: PropTypes.string,
    setFilter: PropTypes.func
};

//-----------
//Тело модуля
//-----------

//Корневая панель производственной программы
const MechRecCostProdPlans = () => {
    //Собственное состояние
    let [state, setState] = useState({
        init: false,
        showPlanList: false,
        plans: [],
        plansLoaded: false,
        selectedPlanSpecsLoaded: false,
        selectedPlan: null,
        selectedPlanMaxLevel: null,
        selectedPlanCurLevel: null,
        selectedPlanGanttDef: {},
        selectedPlanSpecs: []
    });

    const [filter, setFilter] = useState("");

    const filteredPlans = useFilteredPlans(state.plans, filter);

    //Подключение к контексту приложения
    const { pOnlineShowDocument } = useContext(ApplicationСtx);

    //Подключение к контексту сообщений
    const { InlineMsgInfo } = useContext(MessagingСtx);

    //Подключение к контексту взаимодействия с сервером
    const { executeStored } = useContext(BackEndСtx);

    // Инициализация планов
    const initPlans = useCallback(async () => {
        if (!state.init) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.PRODPLAN_INIT",
                args: {},
                respArg: "COUT"
            });
            setState(pv => ({
                ...pv,
                init: true,
                plans: [...(data?.XFCPRODPLANS || [])],
                plansLoaded: true
            }));
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [state.init, executeStored]);

    //Выбор плана
    const selectPlan = project => {
        setState(pv => ({
            ...pv,
            selectedPlan: project,
            selectedPlanSpecsLoaded: false,
            selectedPlanMaxLevel: null,
            selectedPlanCurLevel: null,
            selectedPlanSpecs: [],
            selectedPlanGanttDef: {},
            showPlanList: false
        }));
    };

    //Сброс выбора плана
    const unselectPlan = () =>
        setState(pv => ({
            ...pv,
            selectedPlanSpecsLoaded: false,
            selectedPlan: null,
            selectedPlanMaxLevel: null,
            selectedPlanCurLevel: null,
            selectedPlanSpecs: [],
            selectedPlanGanttDef: {},
            showPlanList: false
        }));

    //Загрузка списка спецификаций плана
    const loadPlanSpecs = useCallback(
        async (curMaxLevel = null, level = null) => {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.FCPRODPLANSP_GET",
                args: { NFCPRODPLAN: state.selectedPlan, NLEVEL: level },
                attributeValueProcessor: (name, val) =>
                    name == "numb" ? undefined : ["start", "end"].includes(name) ? formatDateJSONDateOnly(val) : val,
                respArg: "COUT"
            });
            let maxLevel = curMaxLevel ? curMaxLevel : 0;
            //Если есть данные
            if (data.XGANTT_TASKS) {
                //Обходим данные
                data.XGANTT_TASKS.forEach(el => {
                    // Если есть зависимости
                    if (el.dependencies) {
                        //Разбиваем их в array
                        el.dependencies = el.dependencies[0].split(",");
                    }
                    //Если уровень больше рассчитанного максимального
                    maxLevel = maxLevel < el.level ? el.level : maxLevel;
                });
            }
            setState(pv => ({
                ...pv,
                selectedPlanMaxLevel: maxLevel,
                selectedPlanCurLevel: level || level === 0 ? level : maxLevel,
                selectedPlanSpecsLoaded: true,
                selectedPlanGanttDef: data.XGANTT_DEF ? { ...data.XGANTT_DEF } : {},
                selectedPlanSpecs: [...(data?.XGANTT_TASKS || [])]
            }));
        },
        // eslint-disable-next-line react-hooks/exhaustive-deps
        [executeStored, state.ident, state.selectedPlan]
    );

    //Обработка нажатия на элемент в списке планов
    const handleProjectClick = project => {
        if (state.selectedPlan != project.NRN) selectPlan(project.NRN);
        else unselectPlan();
    };

    //Отработка нажатия на заголовок плана
    const handleTitleClick = () => {
        state.selectedPlan ? pOnlineShowDocument({ unitCode: "CostProductPlans", document: state.selectedPlan }) : null;
    };

    //При подключении компонента к странице
    useEffect(() => {
        initPlans();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    //При смене выбранного плана
    useEffect(() => {
        if (state.selectedPlan) loadPlanSpecs();
    }, [state.selectedPlan, loadPlanSpecs]);

    //Выбор уровня
    const handleChangeSelectList = selectedLevel => {
        loadPlanSpecs(state.selectedPlanMaxLevel, selectedLevel);
        setState(pv => ({ ...pv, selectedPlanCurLevel: selectedLevel }));
    };

    //Генерация содержимого
    return (
        <Box p={2}>
            <Fab variant="extended" sx={STYLES.PROJECTS_BUTTON} onClick={() => setState(pv => ({ ...pv, showPlanList: !pv.showPlanList }))}>
                Планы
            </Fab>
            <Drawer
                anchor={"left"}
                open={state.showPlanList}
                onClose={() => setState(pv => ({ ...pv, showPlanList: false }))}
                sx={STYLES.PROJECTS_DRAWER}
            >
                <ProjectsList
                    plans={filteredPlans}
                    selectedPlan={state.selectedPlan}
                    filter={filter}
                    setFilter={setFilter}
                    onClick={handleProjectClick}
                />
            </Drawer>
            {state.init == true ? (
                <Grid container spacing={1}>
                    <Grid item xs={12}>
                        {state.selectedPlanSpecsLoaded ? (
                            state.selectedPlanSpecs.length === 0 ? (
                                <InlineMsgInfo okBtn={false} text={"В плане отсутствуют записи спецификации"} />
                            ) : (
                                <Box sx={STYLES.GANTT_CONTAINER} p={1}>
                                    {state.selectedPlanMaxLevel ? (
                                        <Box sx={{ float: "right" }}>
                                            <InputLabel id="demo-simple-select-label">Уровень</InputLabel>
                                            <Select
                                                labelId="demo-simple-select-label"
                                                id="demo-simple-select"
                                                value={state.selectedPlanCurLevel}
                                                label="Уровень"
                                                onChange={event => {
                                                    handleChangeSelectList(event.target.value);
                                                }}
                                                defaultValue={state.selectedPlanCurLevel}
                                            >
                                                {[...Array(state.selectedPlanMaxLevel + 1).keys()].map(el => (
                                                    <MenuItem value={el} key={el}>
                                                        {el}
                                                    </MenuItem>
                                                ))}
                                            </Select>
                                        </Box>
                                    ) : null}
                                    <P8PGantt
                                        {...P8P_GANTT_CONFIG_PROPS}
                                        {...state.selectedPlanGanttDef}
                                        height={GANTT_HEIGHT}
                                        onTitleClick={handleTitleClick}
                                        titleStyle={STYLES.GANTT_TITLE}
                                        tasks={state.selectedPlanSpecs}
                                    />
                                </Box>
                            )
                        ) : !state.selectedPlan ? (
                            <InlineMsgInfo okBtn={false} text={"Укажите план для отображения его спецификации"} />
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

export { MechRecCostProdPlans };

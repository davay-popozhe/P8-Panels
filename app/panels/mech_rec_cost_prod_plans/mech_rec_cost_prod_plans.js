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
import { xml2JSON, formatDateJSONDateOnly } from "../../core/utils"; //Вспомогательные функции
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
    PLANS_FINDER: { marginTop: "10px", marginLeft: "10px", width: "93%" },
    PLANS_LIST_ITEM_PRIMARY: { wordWrap: "break-word" },
    PLANS_BUTTON: { position: "absolute" },
    PLANS_DRAWER: {
        minWidth: "250px",
        display: "inline-block",
        flexShrink: 0,
        [`& .MuiDrawer-paper`]: { minWidth: "250px", display: "inline-block", boxSizing: "border-box" }
    },
    GANTT_CONTAINER: { height: GANTT_HEIGHT, width: GANTT_WIDTH },
    GANTT_TITLE: { paddingLeft: "100px", paddingRight: "120px" }
};

//------------------------------------
//Вспомогательные функции и компоненты
//------------------------------------

//Разбор XML с данными спецификации производственной программы
const parseProdPlanSpXML = async xmlDoc => {
    const data = await xml2JSON({
        xmlDoc,
        attributeValueProcessor: (name, val) => (name == "numb" ? undefined : ["start", "end"].includes(name) ? formatDateJSONDateOnly(val) : val)
    });
    return data.XDATA;
};

//Список планов
const PlansList = ({ plans = [], selectedPlan, filter, setFilter, onClick } = {}) => {
    //Генерация содержимого
    return (
        <div>
            <TextField
                sx={STYLES.PLANS_FINDER}
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
                        <ListItemText primary={<Typography sx={STYLES.PLANS_LIST_ITEM_PRIMARY}>{p.SDOC_INFO}</Typography>} />
                    </ListItemButton>
                ))}
            </List>
        </div>
    );
};

//Контроль свойств - Список планов
PlansList.propTypes = {
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
        selectedPlanLevel: null,
        selectedPlanMenuItems: null,
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
                respArg: "COUT",
                isArray: name => name === "XFCPRODPLANS"
            });
            setState(pv => ({ ...pv, init: true, plans: [...(data?.XFCPRODPLANS || [])], plansLoaded: true }));
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
            selectedPlanLevel: null,
            selectedPlanMenuItems: null,
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
            selectedPlanLevel: null,
            selectedPlanMenuItems: null,
            selectedPlanSpecs: [],
            selectedPlanGanttDef: {},
            showPlanList: false
        }));

    //Загрузка списка спецификаций плана
    const loadPlanSpecs = useCallback(
        async (level = null) => {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.FCPRODPLANSP_GET",
                args: { NFCPRODPLAN: state.selectedPlan, NLEVEL: level }
            });
            let doc = await parseProdPlanSpXML(data.COUT);
            setState(pv => ({
                ...pv,
                selectedPlanMaxLevel: data.NMAX_LEVEL,
                selectedPlanLevel: level || level === 0 ? level : data.NMAX_LEVEL,
                selectedPlanMenuItems: state.selectedPlanMenuItems
                    ? state.selectedPlanMenuItems
                    : [...Array(data.NMAX_LEVEL).keys()].map(el => el + 1),
                selectedPlanSpecsLoaded: true,
                selectedPlanGanttDef: doc.XGANTT_DEF ? { ...doc.XGANTT_DEF } : {},
                selectedPlanSpecs: [...(doc?.XGANTT_TASKS || [])]
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
        loadPlanSpecs(selectedLevel);
        setState(pv => ({ ...pv, selectedPlanLevel: selectedLevel }));
    };

    //Генерация содержимого
    return (
        <Box p={2}>
            <Fab variant="extended" sx={STYLES.PLANS_BUTTON} onClick={() => setState(pv => ({ ...pv, showPlanList: !pv.showPlanList }))}>
                Планы
            </Fab>
            <Drawer
                anchor={"left"}
                open={state.showPlanList}
                onClose={() => setState(pv => ({ ...pv, showPlanList: false }))}
                sx={STYLES.PLANS_DRAWER}
            >
                <PlansList
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
                                                value={state.selectedPlanLevel}
                                                label="Уровень"
                                                onChange={event => {
                                                    handleChangeSelectList(event.target.value);
                                                }}
                                                defaultValue={state.selectedPlanLevel}
                                            >
                                                {state.selectedPlanMenuItems.map(el => (
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

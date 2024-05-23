/*
    Парус 8 - Панели мониторинга - ПУП - Мониторинг сборки изделий
    Панель мониторинга: Корневая панель мониторинга сборки изделий
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useContext } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Drawer, Fab, Box, List, ListItemButton, ListItemText, Typography, TextField, FormGroup, FormControlLabel, Checkbox } from "@mui/material"; //Интерфейсные элементы
import { ThemeProvider } from "@mui/material/styles"; //Подключение темы
import { MessagingСtx } from "../../context/messaging"; //Контекст сообщений
import { PlansList } from "./components/plans_list"; //Список планов
import { PlanDetail } from "./components/plan_detail"; //Детали плана
import { theme } from "./styles/themes"; //Стиль темы
import { useMechRecAssemblyMon, useFilteredPlanCtlgs } from "./hooks"; //Вспомогательные хуки

//---------
//Константы
//---------

//Стили
const STYLES = {
    PLANS_FINDER: { marginTop: "10px", marginLeft: "10px", width: "93%" },
    PLANS_CHECKBOX_HAVEDOCS: { alignContent: "space-around" },
    PLANS_LIST_ITEM_ZERODOCS: { backgroundColor: "#ebecec" },
    PLANS_LIST_ITEM_PRIMARY: { wordWrap: "break-word" },
    PLANS_LIST_ITEM_SECONDARY: { wordWrap: "break-word", fontSize: "0.6rem", textTransform: "uppercase" },
    PLANS_BUTTON: { position: "absolute" },
    PLANS_DRAWER: {
        width: "350px",
        display: "inline-block",
        flexShrink: 0,
        [`& .MuiDrawer-paper`]: { width: "350px", display: "inline-block", boxSizing: "border-box" }
    },
    PLANS_LIST_BOX: { paddingTop: "20px" }
};

//------------------------------------
//Вспомогательные функции и компоненты
//------------------------------------

//Склонения для документов
const DECLINATIONS = ["план", "плана", "планов"];

//Форматирование для отображения количества документов
const formatCountDocs = nCountDocs => {
    //Получаем последнюю цифру в значении
    let num = (nCountDocs % 100) % 10;
    //Документов
    if (nCountDocs > 10 && nCountDocs < 20) return `${nCountDocs} ${DECLINATIONS[2]}`;
    //Документа
    if (num > 1 && num < 5) return `${nCountDocs} ${DECLINATIONS[1]}`;
    //Документ
    if (num == 1) return `${nCountDocs} ${DECLINATIONS[0]}`;
    //Документов
    return `${nCountDocs} ${DECLINATIONS[2]}`;
};

//Список каталогов планов
const PlanCtlgsList = ({ planCtlgs = [], selectedPlanCtlg, filter, setFilter, onClick } = {}) => {
    //Генерация содержимого
    return (
        <div>
            <TextField
                sx={STYLES.PLANS_FINDER}
                name="planFilter"
                label="Каталог"
                value={filter.ctlgName}
                variant="standard"
                fullWidth
                onChange={event => {
                    setFilter(pv => ({ ...pv, ctlgName: event.target.value }));
                }}
            ></TextField>
            <FormGroup sx={STYLES.PLANS_CHECKBOX_HAVEDOCS}>
                <FormControlLabel
                    control={<Checkbox checked={filter.haveDocs} onChange={event => setFilter(pv => ({ ...pv, haveDocs: event.target.checked }))} />}
                    label="Только с планами"
                    labelPlacement="end"
                />
            </FormGroup>
            <List>
                {planCtlgs.map(p => (
                    <ListItemButton
                        sx={p.NCOUNT_DOCS == 0 ? STYLES.PLANS_LIST_ITEM_ZERODOCS : null}
                        key={p.NRN}
                        selected={p.NRN === selectedPlanCtlg}
                        onClick={() => (onClick ? onClick({ NRN: p.NRN, SNAME: p.SNAME, NMIN_YEAR: p.NMIN_YEAR, NMAX_YEAR: p.NMAX_YEAR }) : null)}
                    >
                        <ListItemText
                            primary={<Typography sx={STYLES.PLANS_LIST_ITEM_PRIMARY}>{p.SNAME}</Typography>}
                            secondary={<Typography sx={{ ...STYLES.PLANS_LIST_ITEM_SECONDARY }}>{formatCountDocs(p.NCOUNT_DOCS)}</Typography>}
                        />
                    </ListItemButton>
                ))}
            </List>
        </div>
    );
};

//Контроль свойств - Список каталогов планов
PlanCtlgsList.propTypes = {
    planCtlgs: PropTypes.array,
    selectedPlanCtlg: PropTypes.number,
    onClick: PropTypes.func,
    filter: PropTypes.object,
    setFilter: PropTypes.func
};

//-----------
//Тело модуля
//-----------

//Корневая панель мониторинга сборки изделий
const MechRecAssemblyMon = () => {
    //Собственное состояние
    const [state, setState, selectPlanCtlg, unselectPlanCtlg] = useMechRecAssemblyMon();

    //Состояние фильтра каталогов
    const [filter, setFilter] = useState({ ctlgName: "", haveDocs: false });

    //Состояние навигации по карточкам детализации
    const [planDetailNavigation, setPlanDetailNavigation] = useState({
        disableNavigatePrev: false,
        disableNavigateNext: false,
        currentPlanIndex: 0
    });

    //Массив отфильтрованных каталогов
    const filteredPlanCtgls = useFilteredPlanCtlgs(state.planCtlgs, filter);

    //Подключение к контексту сообщений
    const { InlineMsgInfo } = useContext(MessagingСtx);

    //Обработка нажатия на элемент в списке каталогов планов
    const handlePlanCtlgClick = planCtlg => {
        if (state.selectedPlanCtlg.NRN != planCtlg.NRN) selectPlanCtlg(planCtlg);
        else unselectPlanCtlg();
    };

    //Перемещение к нужному плану
    const navigateToPlan = planIndex => {
        if (planIndex < 0) planIndex = 0;
        if (planIndex > state.plans.length - 1) planIndex = state.plans.length - 1;
        setState(pv => ({
            ...pv,
            selectedPlan: { ...state.plans[planIndex] }
        }));
        setPlanDetailNavigation(pv => ({
            ...pv,
            disableNavigatePrev: planIndex == 0 ? true : false,
            disableNavigateNext: planIndex == state.plans.length - 1 ? true : false,
            currentPlanIndex: planIndex
        }));
    };

    //Обработка нажатия на документ плана
    const handlePlanClick = (plan, planIndex) => navigateToPlan(planIndex);

    //Обработка нажатия на кнопку "Назад"
    const handlePlanDetailBackClick = () => {
        setState(pv => ({ ...pv, selectedPlan: {} }));
    };

    //Обработка навигации из карточки с деталями плана
    const handlePlanDetailNavigateClick = direction => navigateToPlan(planDetailNavigation.currentPlanIndex + direction);

    //Генерация содержимого
    return (
        <Box p={2}>
            <ThemeProvider theme={theme}>
                <Fab variant="extended" sx={STYLES.PLANS_BUTTON} onClick={() => setState(pv => ({ ...pv, showPlanList: !pv.showPlanList }))}>
                    Программы
                </Fab>
                <Drawer
                    anchor={"left"}
                    open={state.showPlanList}
                    onClose={() => setState(pv => ({ ...pv, showPlanList: false }))}
                    sx={STYLES.PLANS_DRAWER}
                >
                    <PlanCtlgsList
                        planCtlgs={filteredPlanCtgls}
                        selectedPlanCtlg={state.selectedPlanCtlg.NRN}
                        filter={filter}
                        setFilter={setFilter}
                        onClick={handlePlanCtlgClick}
                    />
                </Drawer>
                {state.init == true ? (
                    state.selectedPlanCtlg.NRN ? (
                        <>
                            <Typography variant="h3" align="center" color="text.title.fontColor" py={2}>
                                {`${state.selectedPlanCtlg.SNAME} на ${state.selectedPlanCtlg.NMIN_YEAR} ${
                                    state.selectedPlanCtlg.NMIN_YEAR == state.selectedPlanCtlg.NMAX_YEAR
                                        ? "г."
                                        : `- ${state.selectedPlanCtlg.NMAX_YEAR} г.г.`
                                } `}
                            </Typography>
                            {state.plansLoaded == true ? (
                                state.selectedPlan.NRN ? (
                                    <PlanDetail
                                        plan={state.selectedPlan}
                                        disableNavigatePrev={planDetailNavigation.disableNavigatePrev}
                                        disableNavigateNext={planDetailNavigation.disableNavigateNext}
                                        onNavigate={handlePlanDetailNavigateClick}
                                        onBack={handlePlanDetailBackClick}
                                    />
                                ) : (
                                    <Box sx={STYLES.PLANS_LIST_BOX}>
                                        <PlansList plans={state.plans} onItemClick={handlePlanClick} />
                                    </Box>
                                )
                            ) : null}
                        </>
                    ) : (
                        <InlineMsgInfo okBtn={false} text={"Укажите каталог планов для отображения его спецификаций"} />
                    )
                ) : null}
            </ThemeProvider>
        </Box>
    );
};

//----------------
//Интерфейс модуля
//----------------

export { MechRecAssemblyMon };

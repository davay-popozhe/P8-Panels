/*
    Парус 8 - Панели мониторинга - ПУП - Мониторинг сборки изделий
    Панель мониторинга: Корневая панель мониторинга сборки изделий
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useContext } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import {
    Drawer,
    Fab,
    Box,
    List,
    ListItemButton,
    ListItemText,
    Typography,
    Grid,
    TextField,
    FormGroup,
    FormControlLabel,
    Checkbox,
    Container
} from "@mui/material"; //Интерфейсные элементы
import { ThemeProvider } from "@mui/material/styles"; //Подключение темы
import { MessagingСtx } from "../../context/messaging"; //Контекст сообщений
import { CardBlock } from "./blocks/cardBlock"; //Информация об объекте
import { CardDetail } from "./blocks/cardDetail"; //Детализация по объекту
import { theme } from "./styles/themes.js"; //Стиль темы
import { useFilteredPlanCtlgs } from "./hooks"; //Вспомогательные хуки
import { useMechRecAssemblyMon } from "./backend"; //Хук корневой панели мониторинга сборки изделий

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
    }
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
    const [state, setState, selectPlan, unselectPlan] = useMechRecAssemblyMon();

    //Состояние для фильтра каталогов
    const [filter, setFilter] = useState({ ctlgName: "", haveDocs: false });

    //Массив отфильтрованных каталогов
    const filteredPlanCtgls = useFilteredPlanCtlgs(state.planCtlgs, filter);

    //Подключение к контексту сообщений
    const { InlineMsgInfo } = useContext(MessagingСtx);

    //Обработка нажатия на элемент в списке каталогов планов
    const handleProjectClick = project => {
        if (state.selectedPlanCtlg.NRN != project.NRN) selectPlan(project);
        else unselectPlan();
    };

    //Обработка нажатия на карточку объекта
    const handleCardClick = plan => {
        setState(pv => ({
            ...pv,
            selectedPlan: { NRN: plan.NRN, SNUMB: plan.SNUMB, NPROGRESS: plan.NPROGRESS, SDETAIL: plan.SDETAIL, NYEAR: plan.NYEAR }
        }));
    };

    //Обработка нажатия на кнопку "Назад"
    const handleBackClick = () => {
        setState(pv => ({ ...pv, selectedPlan: { NRN: null, SNUMB: null, NPROGRESS: null, SDETAIL: null, NYEAR: null } }));
    };

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
                        onClick={handleProjectClick}
                    />
                </Drawer>
                {state.init == true ? (
                    state.selectedPlanCtlg.NRN ? (
                        <>
                            <Typography variant="h1" align="center" py={3}>
                                {`${state.selectedPlanCtlg.SNAME} на ${state.selectedPlanCtlg.NMIN_YEAR}г. - ${state.selectedPlanCtlg.NMAX_YEAR}г.`}
                            </Typography>
                            {state.plansLoaded == true ? (
                                state.selectedPlan.NRN ? (
                                    <CardDetail card={state.selectedPlan} handleBackClick={handleBackClick} />
                                ) : (
                                    <Container>
                                        <Grid container spacing={5}>
                                            {state.plans.map(el => (
                                                <Grid
                                                    item
                                                    xs={state.plans.length >= 5 ? 2.4 : 12 / state.plans.length}
                                                    key={el.NRN}
                                                    display="flex"
                                                    justifyContent="center"
                                                >
                                                    <CardBlock card={el} handleCardClick={handleCardClick} />
                                                </Grid>
                                            ))}
                                        </Grid>
                                    </Container>
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

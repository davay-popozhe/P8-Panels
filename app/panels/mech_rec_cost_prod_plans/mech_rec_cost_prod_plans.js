/*
    Парус 8 - Панели мониторинга - ПУП - Производственная программа
    Панель мониторинга: Корневая панель производственной программы
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
    List,
    ListItemButton,
    ListItemText,
    Typography,
    Grid,
    TextField,
    Select,
    MenuItem,
    InputLabel,
    FormGroup,
    FormControlLabel,
    Checkbox,
    Button,
    Dialog,
    DialogContent,
    DialogActions
} from "@mui/material"; //Интерфейсные элементы
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { MessagingСtx } from "../../context/messaging"; //Контекст сообщений
import { P8P_GANTT_CONFIG_PROPS } from "../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { P8PGantt } from "../../components/p8p_gantt"; //Диаграмма Ганта
import { xml2JSON, formatDateJSONDateOnly } from "../../core/utils"; //Вспомогательные функции
import { useFilteredPlanCtlgs } from "./hooks"; //Вспомогательные хуки
import { CostRouteListsDataGrid } from "./datagrids/fcroutlst";
import { IncomFromDepsDataGrid } from "./datagrids/incomefromdeps";

//---------
//Константы
//---------

//Склонения для документов
const DECLINATIONS = ["план", "плана", "планов"];

//Поля сортировки
const SORT_REP_DATE = "DREP_DATE";
const SORT_REP_DATE_TO = "DREP_DATE_TO";

//Высота диаграммы Ганта
const GANTT_HEIGHT = "75vh";

//Ширина диаграммы Ганта
const GANTT_WIDTH = "98vw";

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
    GANTT_CONTAINER: { height: GANTT_HEIGHT, width: GANTT_WIDTH },
    GANTT_TITLE: { paddingLeft: "100px", paddingRight: "120px" },
    SECOND_TABLE: { paddingTop: "30px" }
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

//Форматирование для отображения количества документов
const formatCountDocs = nCountDocs => {
    //Получаем последнюю цифру в значении
    let num = (nCountDocs % 100) % 10;
    //Документов
    if (nCountDocs > 10 && nCountDocs < 20) {
        return `${nCountDocs} ${DECLINATIONS[2]}`;
    }
    //Документа
    if (num > 1 && num < 5) {
        return `${nCountDocs} ${DECLINATIONS[1]}`;
    }
    //Документ
    if (num == 1) {
        return `${nCountDocs} ${DECLINATIONS[0]}`;
    }
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
                    control={
                        <Checkbox
                            checked={filter.haveDocs}
                            onChange={event => {
                                setFilter(pv => ({ ...pv, haveDocs: event.target.checked }));
                            }}
                        />
                    }
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
                        onClick={() => (onClick ? onClick(p) : null)}
                    >
                        <ListItemText
                            primary={<Typography sx={STYLES.PLANS_LIST_ITEM_PRIMARY}>{p.SNAME}</Typography>}
                            secondary={
                                <Typography
                                    sx={{
                                        ...STYLES.PLANS_LIST_ITEM_SECONDARY
                                    }}
                                >
                                    {formatCountDocs(p.NCOUNT_DOCS)}
                                </Typography>
                            }
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

//Корневая панель производственной программы
const MechRecCostProdPlans = () => {
    //Собственное состояние
    let [state, setState] = useState({
        init: false,
        showPlanList: false,
        planCtlgs: [],
        planCtlgsLoaded: false,
        selectedPlanCtlgSpecsLoaded: false,
        selectedPlanCtlg: null,
        selectedPlanCtlgMaxLevel: null,
        selectedPlanCtlgLevel: null,
        selectedPlanCtlgSort: null,
        selectedPlanCtlgMenuItems: null,
        selectedPlanCtlgGanttDef: {},
        selectedPlanCtlgSpecs: [],
        selectedTaskDetail: null,
        selectedTaskDetailType: null
    });
    //Состояние для фильтра каталогов
    const [filter, setFilter] = useState({ ctlgName: "", haveDocs: false });

    //Массив отфильтрованных каталогов
    const filteredPlanCtgls = useFilteredPlanCtlgs(state.planCtlgs, filter);

    //Подключение к контексту сообщений
    const { InlineMsgInfo } = useContext(MessagingСtx);

    //Подключение к контексту взаимодействия с сервером
    const { executeStored } = useContext(BackEndСtx);

    // Инициализация каталогов планов
    const initPlanCtlgs = useCallback(async () => {
        if (!state.init) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.ACATALOG_INIT",
                args: {},
                respArg: "COUT",
                isArray: name => name === "XFCPRODPLAN_CRNS"
            });
            setState(pv => ({ ...pv, init: true, planCtlgs: [...(data?.XFCPRODPLAN_CRNS || [])], planCtlgsLoaded: true }));
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [state.init, executeStored]);

    //Выбор каталога планов
    const selectPlan = project => {
        setState(pv => ({
            ...pv,
            selectedPlanCtlg: project,
            selectedPlanCtlgSpecsLoaded: false,
            selectedPlanCtlgMaxLevel: null,
            selectedPlanCtlgLevel: null,
            selectedPlanCtlgSort: null,
            selectedPlanCtlgMenuItems: null,
            selectedPlanCtlgSpecs: [],
            selectedPlanCtlgGanttDef: {},
            showPlanList: false,
            selectedTaskDetail: null,
            selectedTaskDetailType: null
        }));
    };

    //Сброс выбора каталога планов
    const unselectPlan = () =>
        setState(pv => ({
            ...pv,
            selectedPlanCtlgSpecsLoaded: false,
            selectedPlanCtlg: null,
            selectedPlanCtlgMaxLevel: null,
            selectedPlanCtlgLevel: null,
            selectedPlanCtlgSort: null,
            selectedPlanCtlgMenuItems: null,
            selectedPlanCtlgSpecs: [],
            selectedPlanCtlgGanttDef: {},
            showPlanList: false,
            selectedTaskDetail: null,
            selectedTaskDetailType: null
        }));

    //Загрузка списка спецификаций каталога планов
    const loadPlanCtglSpecs = useCallback(
        async (level = null, sort = null) => {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.FCPRODPLANSP_GET",
                args: { NCRN: state.selectedPlanCtlg, NLEVEL: level, SSORT_FIELD: sort }
            });
            let doc = await parseProdPlanSpXML(data.COUT);
            setState(pv => ({
                ...pv,
                selectedPlanCtlgMaxLevel: data.NMAX_LEVEL,
                selectedPlanCtlgLevel: level || level === 0 ? level : data.NMAX_LEVEL,
                selectedPlanCtlgSort: sort,
                selectedPlanCtlgMenuItems: state.selectedPlanCtlgMenuItems
                    ? state.selectedPlanCtlgMenuItems
                    : [...Array(data.NMAX_LEVEL).keys()].map(el => el + 1),
                selectedPlanCtlgSpecsLoaded: true,
                selectedPlanCtlgGanttDef: doc.XGANTT_DEF ? { ...doc.XGANTT_DEF } : {},
                selectedPlanCtlgSpecs: [...(doc?.XGANTT_TASKS || [])]
            }));
        },
        // eslint-disable-next-line react-hooks/exhaustive-deps
        [executeStored, state.ident, state.selectedPlanCtlg]
    );

    //Обработка нажатия на элемент в списке каталогов планов
    const handleProjectClick = project => {
        if (state.selectedPlanCtlg != project.NRN) selectPlan(project.NRN);
        else unselectPlan();
    };

    //При подключении компонента к странице
    useEffect(() => {
        initPlanCtlgs();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    //При смене выбранного каталога плана
    useEffect(() => {
        if (state.selectedPlanCtlg) loadPlanCtglSpecs(null, SORT_REP_DATE_TO);
    }, [state.selectedPlanCtlg, loadPlanCtglSpecs]);

    //Выбор уровня
    const handleChangeSelectLevel = selectedLevel => {
        loadPlanCtglSpecs(selectedLevel, state.selectedPlanCtlgSort);
        setState(pv => ({ ...pv, selectedPlanCtlgLevel: selectedLevel }));
    };

    //Выбор сортировки
    const handleChangeSelectSort = selectedSort => {
        loadPlanCtglSpecs(state.selectedPlanCtlgLevel, selectedSort);
        setState(pv => ({ ...pv, selectedPlanCtlgSort: selectedSort }));
    };

    //При закрытии окна детализации
    const handleTaskDetailClose = () => {
        setState(pv => ({ ...pv, selectedTaskDetail: null, selectedTaskDetailType: null }));
    };

    //При открытии окна детализации
    const handleTaskDetailOpen = (taskRn, taskType) => {
        setState(pv => ({ ...pv, selectedTaskDetail: taskRn, selectedTaskDetailType: taskType }));
    };

    //Генерация ссылки на документы анализа отклонений
    const taskAttributeRenderer = ({ task, attribute }) => {
        // Если есть информация о детализации и указан тип - делаем кнопку открытия документов
        if (attribute.name === "detail_list" && task.type !== null && task.type !== "") {
            return (
                <Button
                    onClick={() => {
                        handleTaskDetailOpen(task.rn, task.type);
                    }}
                >
                    {task[attribute.name]}
                </Button>
            );
        } else {
            return null;
        }
    };

    //Генерация содержимого
    return (
        <Box p={2}>
            <Fab variant="extended" sx={STYLES.PLANS_BUTTON} onClick={() => setState(pv => ({ ...pv, showPlanList: !pv.showPlanList }))}>
                Каталоги планов
            </Fab>
            <Drawer
                anchor={"left"}
                open={state.showPlanList}
                onClose={() => setState(pv => ({ ...pv, showPlanList: false }))}
                sx={STYLES.PLANS_DRAWER}
            >
                <PlanCtlgsList
                    planCtlgs={filteredPlanCtgls}
                    selectedPlanCtlg={state.selectedPlanCtlg}
                    filter={filter}
                    setFilter={setFilter}
                    onClick={handleProjectClick}
                />
            </Drawer>
            {state.init == true ? (
                <Grid container spacing={1}>
                    <Grid item xs={12}>
                        {state.selectedPlanCtlgSpecsLoaded ? (
                            state.selectedPlanCtlgSpecs.length === 0 ? (
                                <InlineMsgInfo okBtn={false} text={"В каталоге планов отсутствуют записи спецификации"} />
                            ) : (
                                <Box sx={STYLES.GANTT_CONTAINER} p={1}>
                                    {state.selectedPlanCtlgMaxLevel ? (
                                        <Box sx={{ display: "table", float: "right" }}>
                                            <Box sx={{ display: "table-cell", verticalAlign: "middle" }}>
                                                <InputLabel id="select-label-sort">Сортировка</InputLabel>
                                                <Select
                                                    labelId="select-label-sort"
                                                    id="select-sort"
                                                    value={state.selectedPlanCtlgSort}
                                                    label="Сортировка"
                                                    onChange={event => {
                                                        handleChangeSelectSort(event.target.value);
                                                    }}
                                                    defaultValue={state.selectedPlanCtlgLevel}
                                                >
                                                    <MenuItem value={SORT_REP_DATE_TO} key="1">
                                                        Дата выпуска
                                                    </MenuItem>
                                                    <MenuItem value={SORT_REP_DATE} key="2">
                                                        Дата запуска
                                                    </MenuItem>
                                                </Select>
                                            </Box>
                                            <Box sx={{ display: "table-cell", verticalAlign: "middle", paddingLeft: "15px" }}>
                                                <InputLabel id="select-label-level">До уровня</InputLabel>
                                                <Select
                                                    labelId="select-label-level"
                                                    id="select-level"
                                                    value={state.selectedPlanCtlgLevel}
                                                    label="Уровень"
                                                    onChange={event => {
                                                        handleChangeSelectLevel(event.target.value);
                                                    }}
                                                    defaultValue={state.selectedPlanCtlgLevel}
                                                >
                                                    {state.selectedPlanCtlgMenuItems.map(el => (
                                                        <MenuItem value={el} key={el}>
                                                            {el}
                                                        </MenuItem>
                                                    ))}
                                                </Select>
                                            </Box>
                                        </Box>
                                    ) : null}
                                    <P8PGantt
                                        {...P8P_GANTT_CONFIG_PROPS}
                                        {...state.selectedPlanCtlgGanttDef}
                                        height={GANTT_HEIGHT}
                                        titleStyle={STYLES.GANTT_TITLE}
                                        tasks={state.selectedPlanCtlgSpecs}
                                        taskAttributeRenderer={taskAttributeRenderer}
                                    />
                                </Box>
                            )
                        ) : !state.selectedPlanCtlg ? (
                            <InlineMsgInfo okBtn={false} text={"Укажите каталог планов для отображения их спецификаций"} />
                        ) : null}
                    </Grid>
                </Grid>
            ) : null}
            {state.selectedTaskDetail ? (
                <Dialog open onClose={handleTaskDetailClose} fullWidth maxWidth="xl">
                    <DialogContent>
                        {/* Если тип таска 0, 1 или 4 - основная таблица "Маршрутные листы" */}
                        {[0, 1, 4].includes(state.selectedTaskDetailType) ? (
                            <CostRouteListsDataGrid task={state.selectedTaskDetail} taskType={state.selectedTaskDetailType} />
                        ) : (
                            <Box>
                                {/* Если тип таска 2 или 3 - основная таблица "Приходы из подразделений" */}
                                <IncomFromDepsDataGrid task={state.selectedTaskDetail} taskType={state.selectedTaskDetailType} />
                                {/* Если тип 3 - необходимо добавить отдельную таблицу "Маршрутные листы" */}
                                {state.selectedTaskDetailType === 3 ? (
                                    <Box sx={STYLES.SECOND_TABLE}>
                                        <CostRouteListsDataGrid task={state.selectedTaskDetail} taskType={state.selectedTaskDetailType} />
                                    </Box>
                                ) : null}
                            </Box>
                        )}
                    </DialogContent>
                    <DialogActions>
                        <Button onClick={handleTaskDetailClose}>Закрыть</Button>
                    </DialogActions>
                </Dialog>
            ) : null}
        </Box>
    );
};

//----------------
//Интерфейс модуля
//----------------

export { MechRecCostProdPlans };

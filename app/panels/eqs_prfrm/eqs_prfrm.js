/*
    Парус 8 - Панели мониторинга - ТОиР - Выполнение работ
    Панель мониторинга: Корневая панель выполнения работ
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useContext, useCallback, useEffect } from "react"; //Классы React
import { Grid, Paper, Box } from "@mui/material"; //Интерфейсные компоненты
import { P8PDataGrid, P8P_DATA_GRID_SIZE } from "../../components/p8p_data_grid"; //Таблица данных
import { P8P_DATA_GRID_CONFIG_PROPS } from "../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { ApplicationСtx } from "../../context/application"; //Контекст приложения
import { MessagingСtx } from "../../context/messaging"; //Контекст сообщений
import { headCellRender, dataCellRender, groupCellRender, DIGITS_REG_EXP, MONTH_NAME_REG_EXP, DAY_NAME_REG_EXP } from "./layouts"; //Дополнительная разметка и вёрстка клиентских элементов
import { TEXTS } from "../../../app.text"; //Тектовые ресурсы и константы
import { Filter } from "./filter"; //Компонент фильтра
import { FilterDialog } from "./filter_dialog"; //Компонент диалогового окна фильтра отбора

//-----------
//Тело модуля
//-----------

//Корневая панель выполнения работ
const EqsPrfrm = () => {
    //Собственное состояние - таблица данных
    const [dataGrid, setDataGrid] = useState({
        dataLoaded: false,
        columnsDef: [],
        groups: [],
        rows: [],
        reload: false
    });

    //Состояние фильтра
    const [filter, setFilter] = useState({
        isOpen: false,
        isDefault: false,
        isSetByUser: false,
        values: {
            belong: "",
            prodObj: "",
            techServ: "",
            respDep: "",
            fromMonth: 1,
            fromYear: 1990,
            toMonth: 1,
            toYear: 1990
        }
    });

    //Состояние ячейки заголовка даты (по раскрытию/скрытию)
    const [activeRef, setActiveRef] = useState();

    //Состояние актуальности ссылки на ячейку
    const [refIsDeprecated, setRidFlag] = useState(true);

    //Подключение к контексту приложения
    const { pOnlineShowUnit } = useContext(ApplicationСtx);

    //Подключение к контексту взаимодействия с сервером
    const { executeStored } = useContext(BackEndСtx);

    //Подключение к контексту сообщений
    const { showMsgErr } = useContext(MessagingСtx);

    //Загрузка данных таблицы с сервера
    const loadData = useCallback(async () => {
        if (dataGrid.reload) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_EQUIPSRV.EQUIPSRV_GRID",
                args: {
                    SBELONG: filter.values.belong,
                    SPRODOBJ: filter.values.prodObj,
                    STECHSERV: filter.values.techServ,
                    SRESPDEP: filter.values.respDep,
                    NFROMMONTH: filter.values.fromMonth,
                    NFROMYEAR: filter.values.fromYear,
                    NTOMONTH: filter.values.toMonth,
                    NTOYEAR: filter.values.toYear
                },
                respArg: "COUT",
                attributeValueProcessor: (name, val) => (["caption", "name", "parent"].includes(name) ? undefined : val)
            });
            let cP = 0;
            let sP = 0;
            let cF = 0;
            let sF = 0;
            let properties = [];
            if (data.XROWS != null) {
                data.XROWS.map(row => {
                    properties = [];
                    Object.entries(row).forEach(([key, value]) => properties.push({ name: key, data: value }));
                    let info2 = properties.find(element => {
                        return element.name === "SINFO2";
                    });
                    if (info2 != undefined) {
                        if (info2.data == "План") {
                            properties.map(p => {
                                if (DAY_NAME_REG_EXP.test(p.name)) cP = cP + 1;
                            });
                        } else if (info2.data == "Факт") {
                            properties.map(p => {
                                if (DAY_NAME_REG_EXP.test(p.name)) cF = cF + 1;
                            });
                        }
                    } else {
                        properties.map(p => {
                            if (MONTH_NAME_REG_EXP.test(p.name)) {
                                let str = p.data;
                                let m = [];
                                let i = 0;
                                while ((m = DIGITS_REG_EXP.exec(str)) != null) {
                                    if (i == 0) sP = sP + Number(m[0].replace(",", "."));
                                    else {
                                        sF = sF + Number(m[0].replace(",", "."));
                                    }
                                    i++;
                                }
                            }
                        });
                    }
                });
            }
            setDataGrid(pv => ({
                ...pv,
                columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                rows: [...(data.XROWS || [])],
                groups: [...(data.XGROUPS || [])],
                dataLoaded: true,
                reload: false
            }));
        }
    }, [dataGrid.reload, filter, executeStored]);

    //Загрузка значений фильра по умолчанию
    const loadDefaultFilter = useCallback(async () => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_EQUIPSRV.GET_DEFAULT_FP",
            respArg: "COUT"
        });
        setFilter(pv => ({
            ...pv,
            values: { ...pv.values, belong: data.JURPERS, fromMonth: 1, fromYear: data.YEAR, toMonth: 12, toYear: data.YEAR },
            isDefault: true
        }));
    }, [executeStored]);

    //Отбор документа (ТОиР или Ремонтных ведомостей) по ячейке даты
    const showEquipSrv = async ({ date, workType, info }) => {
        const [techName, servKind] = info.split("_");
        let type;
        if (workType == "План") type = 0;
        else type = 1;
        let [year, month, day] = date.substring(1).split("_");
        const data = await executeStored({
            stored: "PKG_P8PANELS_EQUIPSRV.SELECT_EQUIPSRV",
            args: {
                SBELONG: filter.values.belong,
                SPRODOBJ: filter.values.prodObj,
                STECHSERV: filter.values.techServ ? filter.values.techServ : null,
                SRESPDEP: filter.values.respDep ? filter.values.respDep : null,
                STECHNAME: techName,
                SSRVKIND: servKind,
                NYEAR: Number(year),
                NMONTH: Number(month),
                NDAY: day ? Number(day) : null,
                NWORKTYPE: type
            }
        });
        if (data.NIDENT) {
            if (type == 0) pOnlineShowUnit({ unitCode: "EquipTechServices", inputParameters: [{ name: "in_SelectList_Ident", value: data.NIDENT }] });
            else pOnlineShowUnit({ unitCode: "EquipRepairSheets", inputParameters: [{ name: "in_Ident", value: data.NIDENT }] });
        } else showMsgErr(TEXTS.NO_DATA_FOUND);
    };

    //Показать/скрыть фильтр
    const setFilterOpen = isOpen => setFilter(pv => ({ ...pv, isOpen }));

    //Установить значение фильтра
    const setFilterValues = values => setFilter(pv => ({ ...pv, isSetByUser: true, values: { ...values } }));

    //Отработка события скрытия/раскрытия ячейки даты
    const handleClick = (e, ref) => {
        const curCell = ref.current;
        if (e.target.type == "button" || e.target.offsetParent.type == "button") {
            setActiveRef(curCell);
            setRidFlag(false);
        }
    };

    //При необходимости обновить данные таблицы
    useEffect(() => {
        loadData();
    }, [loadData, dataGrid.reload]);

    //При изменении фильтра
    useEffect(() => {
        if (filter.isSetByUser) setDataGrid({ reload: true });
    }, [
        filter.isSetByUser,
        filter.values.belong,
        filter.values.prodObj,
        filter.values.techServ,
        filter.values.respDep,
        filter.values.fromMonth,
        filter.values.fromYear,
        filter.values.toMonth,
        filter.values.toYear
    ]);

    //При нажатии скрытии/раскрытии ячейки даты, фокус на неё
    useEffect(() => {
        if (!refIsDeprecated) {
            if (activeRef) {
                var cellRect = activeRef.getBoundingClientRect();
                window.scrollTo(window.scrollX + cellRect.left + activeRef.clientWidth / 2 - window.innerWidth / 2, 0);
                setRidFlag(true);
            }
        }
        //eslint-disable-next-line react-hooks/exhaustive-deps
    }, [refIsDeprecated]);

    //При загрузке фильтра по умолчанию
    useEffect(() => {
        if (filter.isDefault) setFilterOpen(true);
    }, [filter.isDefault]);

    //При подключении к страницк
    useEffect(() => {
        loadDefaultFilter();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    //При открытии диалога фильтра
    const handleFilterClick = () => setFilterOpen(true);

    //При изменении фильтра в диалоге
    const handleFilterOk = filter => {
        setFilterValues(filter);
        setFilterOpen(false);
    };

    //При закрытии диалога фильтра
    const handleFilterCancel = () => setFilterOpen(false);

    //Генерация содержимого
    return (
        <div>
            {filter.isOpen ? <FilterDialog initial={filter.values} onOk={handleFilterOk} onCancel={handleFilterCancel} /> : null}
            <Filter filter={filter.values} onClick={handleFilterClick} />
            {dataGrid.dataLoaded ? (
                <Paper variant="outlined">
                    <Grid container spacing={1}>
                        <Grid item xs={12}>
                            <Box p={1}>
                                <P8PDataGrid
                                    {...P8P_DATA_GRID_CONFIG_PROPS}
                                    columnsDef={dataGrid.columnsDef}
                                    groups={dataGrid.groups}
                                    rows={dataGrid.rows}
                                    size={P8P_DATA_GRID_SIZE.LARGE}
                                    reloading={dataGrid.reload}
                                    headCellRender={prms => headCellRender({ ...prms }, handleClick)}
                                    dataCellRender={prms => dataCellRender({ ...prms }, showEquipSrv)}
                                    groupCellRender={prms => groupCellRender({ ...prms })}
                                    showCellRightBorder={true}
                                />
                            </Box>
                        </Grid>
                    </Grid>
                </Paper>
            ) : null}
        </div>
    );
};

//----------------
//Интерфейс модуля
//----------------

export { EqsPrfrm };

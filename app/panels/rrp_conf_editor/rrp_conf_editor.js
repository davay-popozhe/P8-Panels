/*
    Парус 8 - Панели мониторинга - РО - Редактор настройки регламентированного отчёта
    Панель мониторинга: Корневая панель редактора
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useCallback, useContext, useState, useEffect } from "react"; //Классы React
import { Box, Tab, Tabs, IconButton, Icon, Stack, Button } from "@mui/material"; //Интерфейсные компоненты
import { P8PDataGrid, P8P_DATA_GRID_SIZE } from "../../components/p8p_data_grid"; //Таблица данных
import { P8P_DATA_GRID_CONFIG_PROPS } from "../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { ApplicationСtx } from "../../context/application"; //Контекст приложения
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { NavigationCtx } from "../../context/navigation"; //Контекст навигации
import { MessagingСtx } from "../../context/messaging"; //Контекст сообщений
import { SectionTabPanel } from "./section_tab_panel"; //Компонент вкладки раздела
import { IUDFormDialog } from "./iud_form_dialog"; //Диалог добавления/исправления/удаления компонентов настройки регламентированного отчёта
import { dataCellRender } from "./layouts"; //Дополнительная разметка и вёрстка клиентских элементов
import { STATUSES } from "./iud_form_dialog"; //Статусы диалогового окна
import { TEXTS } from "../../../app.text"; //Текстовые константы
import { STYLES as COMMON_STYLES } from "./layouts"; //Общие стили

//---------
//Константы
//---------

//Стили
export const STYLES = {
    TABS_BOTTOM_LINE: { borderBottom: 1, borderColor: "divider" },
    TABS_PADDING: { paddingTop: 1, paddingBottom: 1 }
};

//-----------
//Тело модуля
//-----------

//Редактор настройки регламентированного отчёта
const RrpConfEditor = () => {
    const dataGrid = {
        rn: 0,
        code: "",
        name: "",
        dataLoaded: false,
        columnsDef: [],
        groups: [],
        rows: [],
        fixedHeader: false,
        fixedColumns: 0,
        reload: false
    };

    //Собственное состояние
    const [rrpDoc, setRrpDoc] = useState({
        docLoaded: false,
        sections: [],
        reload: true
    });

    //Состояние массива данных разделов
    const [dataGrids] = useState([]);

    //Состояние раздела
    const [tabValue, setTabValue] = useState("");

    //Состояние открытия диалогового окна
    const [formOpen, setForm] = useState(false);

    //Состояние диалогового окна
    const [formData, setFormData] = useState({
        rn: "",
        prn: "",
        sctnName: "",
        sctnCode: "",
        status: "",
        code: "",
        name: "",
        colName: "",
        colCode: "",
        colVCode: "",
        colVRn: 0,
        rowName: "",
        rowCode: "",
        rowVCode: "",
        rowVRn: 0
    });

    //Открытие диалогового окна
    const openForm = () => {
        setForm(true);
    };

    //Очистка диалогового окна
    const clearFormData = () => {
        setFormData({
            rn: "",
            prn: "",
            sctnName: "",
            sctnCode: "",
            status: "",
            code: "",
            name: "",
            colName: "",
            colCode: "",
            colVCode: "",
            colVRn: 0,
            rowName: "",
            rowCode: "",
            rowVCode: "",
            rowVRn: 0
        });
    };

    //Подключение к контексту взаимодействия с сервером
    const { executeStored } = useContext(BackEndСtx);

    //Подключение к контексту приложения
    const { pOnlineShowUnit } = useContext(ApplicationСtx);

    //Подключение к контексту навигации
    const { getNavigationSearch } = useContext(NavigationCtx);

    //Подключение к контексту сообщений
    const { showMsgErr } = useContext(MessagingСtx);

    //Переключение раздела
    const handleChange = (event, newValue) => {
        setTabValue(newValue);
    };

    //Отработка нажатия на кнопку добавления секции
    const addSectionClick = () => {
        setFormData({ status: STATUSES.CREATE, prn: Number(getNavigationSearch().NRN) });
        openForm();
    };

    //Отработка нажатия на кнопку исправления секции
    const editSectionClick = (rn, code, name) => {
        setFormData({ rn: rn, code: code, name: name, status: STATUSES.EDIT });
        openForm();
    };

    //Отработка нажатия на кнопку удаления секции
    const deleteSectionClick = (rn, code, name) => {
        setFormData({ rn: rn, code: code, name: name, status: STATUSES.DELETE });
        openForm();
    };

    //Отработка нажатия на кнопку добавления показателя раздела
    const addRRPCONFSCTNMRKClick = (prn, sctnCode, sctnName) => {
        setFormData({ status: STATUSES.RRPCONFSCTNMRK_CREATE, prn: prn, sctnCode: sctnCode, sctnName: sctnName });
        openForm();
    };

    //Отработка нажатия на кнопку исправления показателя раздела
    const editRRPCONFSCTNMRKClick = (rn, name) => {
        setFormData({ status: STATUSES.RRPCONFSCTNMRK_EDIT, rn: rn, name: name });
        openForm();
    };

    //Отработка нажатия на кнопку удаления показателя раздела
    const deleteRRPCONFSCTNMRKClick = (rn, name) => {
        setFormData({ status: STATUSES.RRPCONFSCTNMRK_DELETE, rn: rn, name: name });
        openForm();
    };

    //Формирование разделов
    const a11yProps = index => {
        return {
            id: `simple-tab-${index}`,
            "aria-controls": `simple-tabpanel-${index}`
        };
    };

    //Загрузка данных разделов регламентированного отчёта
    const loadData = useCallback(async () => {
        if (rrpDoc.reload) {
            //Переменная номера раздела с фокусом
            let tabFocus = 0;
            const data = await executeStored({
                stored: "PKG_P8PANELS_RRPCONFED.RRPCONF_GET_SECTIONS",
                args: {
                    NRN_RRPCONF: Number(getNavigationSearch().NRN)
                },
                respArg: "COUT"
            });
            //Флаг первой загрузки данных
            let firstLoad = dataGrids.length == 0 ? true : false;
            //Копирование массива уже загруженных разделов
            let cloneDGs = dataGrids.slice();
            //Массив из нескольких разделов и из одного
            const sections = data.SECTIONS ? (data.SECTIONS.length ? data.SECTIONS : [data.SECTIONS]) : [];
            //Заполнение очередного раздела по шаблону
            sections.map(s => {
                let dg = {};
                Object.assign(dg, dataGrid, {
                    rn: s.NRN,
                    code: s.SCODE,
                    name: s.SNAME,
                    dataLoaded: true,
                    columnsDef: [...(s.XDATA.XCOLUMNS_DEF || [])],
                    groups: [...(s.XDATA.XGROUPS || [])],
                    rows: [...(s.XDATA.XROWS || [])],
                    fixedHeader: s.XDATA.XDATA_GRID.fixedHeader,
                    fixedColumns: s.XDATA.XDATA_GRID.fixedColumns,
                    reload: false
                });
                //Ищем загружен ли уже раздел с таким же ид.
                const dgItem = dataGrids.find(x => x.rn === dg.rn);
                //Его индекс, если нет соответствия, то -1
                let index = dataGrids.indexOf(dgItem);
                //Если было соответствие
                if (dgItem) {
                    //Если в нём не найдено изменений
                    if (JSON.stringify(dgItem, null, 4) === JSON.stringify(dg, null, 4)) {
                        //То из копированного массива его удаляем
                        cloneDGs.splice(cloneDGs.indexOf(cloneDGs.find(x => x.rn === dgItem.rn)), 1);
                    } else {
                        //Иначе обновляем раздел в массиве
                        dataGrids[index] = dg;
                        //Удаляем из копированного массива
                        cloneDGs.splice(cloneDGs.indexOf(cloneDGs.find(x => x.rn === dg.rn)), 1);
                        //Устанавливаем фокус на обновлённый раздел
                        tabFocus = index;
                    }
                } else {
                    //Если раздел новый, то добавляем его в массив данных
                    dataGrids.push(dg);
                    //И устанавливаем на него фокус, если флаг первой загрузки = false
                    tabFocus = !firstLoad ? dataGrids.length - 1 : 0;
                }
            });
            //Обходим разделы, что остались в копированном массиве (на удаление)
            cloneDGs.map(s => {
                let curIndex = dataGrids.indexOf(dataGrids.find(x => x.rn === s.rn));
                //Устаревший раздел удаляем из массива данных
                dataGrids.splice(curIndex, 1);
                //Фокус на предшествующий раздел
                if (curIndex > 0) tabFocus = curIndex - 1;
                //Иначе фокус на следующий, если был удалён первый раздел
                else tabFocus = curIndex;
            });
            setRrpDoc(pv => ({
                ...pv,
                docLoaded: true,
                reload: false,
                sections: dataGrids
            }));
            setTabValue(tabFocus);
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [rrpDoc.reload, rrpDoc.docLoaded, dataGrid.reload, dataGrid.docLoaded, executeStored]);

    //Отбор показателя раздела по ид.
    const showRrpConfSctnMrk = async rn => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_RRPCONFED.RRPCONFSCTNMRK_GET_CODES",
            args: {
                NRN: rn
            }
        });
        if (data) {
            pOnlineShowUnit({
                unitCode: "RRPConfig",
                showMethod: "main_mrk_settings",
                inputParameters: [
                    { name: "in_CODE", value: data.SRRPCONF },
                    { name: "in_SCTN_CODE", value: data.SRRPCONFSCTN },
                    { name: "in_MRK_CODE", value: data.SRRPCONFSCTNMRK }
                ]
            });
        } else showMsgErr(TEXTS.NO_DATA_FOUND);
    };

    //При необходимости обновить данные таблицы
    useEffect(() => {
        loadData();
    }, [rrpDoc.reload, dataGrid.reload, loadData]);

    //При изменениях элемента
    const handleDialogReload = () => {
        setRrpDoc(pv => ({ ...pv, reload: true }));
    };

    //При закрытии диалога
    const handleDialogClose = () => {
        setForm(false);
        clearFormData();
    };

    //Генерация содержимого
    return (
        <Box sx={{ width: "100%" }}>
            {formOpen ? <IUDFormDialog initial={formData} onClose={handleDialogClose} onReload={handleDialogReload} /> : null}
            {rrpDoc.docLoaded ? (
                <Box>
                    <Stack direction="row" sx={STYLES.TABS_BOTTOM_LINE}>
                        <Tabs value={tabValue} onChange={handleChange} aria-label="section tab">
                            {rrpDoc.sections.map((s, i) => {
                                return (
                                    <Tab
                                        key={s.rn}
                                        {...a11yProps(i)}
                                        sx={{ padding: "10px" }}
                                        label={
                                            <Box sx={COMMON_STYLES.BOX_ROW}>
                                                {s.name}
                                                <IconButton component="span" onClick={() => editSectionClick(s.rn, s.code, s.name)}>
                                                    <Icon>edit</Icon>
                                                </IconButton>
                                                <IconButton component="span" onClick={() => deleteSectionClick(s.rn, s.code, s.name)}>
                                                    <Icon>delete</Icon>
                                                </IconButton>
                                            </Box>
                                        }
                                        wrapped
                                    />
                                );
                            })}
                        </Tabs>
                        <Box display="flex" justifyContent="center" alignItems="center">
                            <IconButton onClick={addSectionClick}>
                                <Icon>add</Icon>
                            </IconButton>
                        </Box>
                    </Stack>
                    {rrpDoc.sections.map((s, i) => {
                        return (
                            <SectionTabPanel key={s.rn} value={tabValue} index={i}>
                                <Button onClick={() => addRRPCONFSCTNMRKClick(s.rn, s.code, s.name)}>Добавить</Button>
                                {s.dataLoaded ? (
                                    <Box sx={{ ...STYLES.TABS_PADDING, ...COMMON_STYLES.BOX_ROW }}>
                                        <P8PDataGrid
                                            {...P8P_DATA_GRID_CONFIG_PROPS}
                                            containerComponentProps={{ elevation: 6, style: { width: window.innerWidth * 0.95 } }}
                                            columnsDef={s.columnsDef}
                                            groups={s.groups}
                                            rows={s.rows}
                                            fixedHeader={s.fixedHeader}
                                            fixedColumns={s.fixedColumns}
                                            size={P8P_DATA_GRID_SIZE.LARGE}
                                            reloading={s.reload}
                                            dataCellRender={prms =>
                                                dataCellRender({ ...prms }, showRrpConfSctnMrk, editRRPCONFSCTNMRKClick, deleteRRPCONFSCTNMRKClick)
                                            }
                                        />
                                    </Box>
                                ) : null}
                            </SectionTabPanel>
                        );
                    })}
                </Box>
            ) : null}
        </Box>
    );
};

//----------------
//Интерфейс модуля
//----------------

export { RrpConfEditor };

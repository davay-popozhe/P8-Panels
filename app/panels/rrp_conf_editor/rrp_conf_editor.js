/*
    Парус 8 - Редактор настройки регламентированного отчёта
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useCallback, useContext, useState, useEffect } from "react"; //Классы React
import { Box, Tab, Tabs, IconButton, Icon, Stack, Button } from "@mui/material"; //Интерфейсные компоненты
import { P8PDataGrid, P8P_DATA_GRID_SIZE } from "../../components/p8p_data_grid"; //Таблица данных
import { P8P_DATA_GRID_CONFIG_PROPS } from "../../config_wrapper"; //Подключение компонентов к настройкам приложения
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { NavigationCtx } from "../../context/navigation"; //Контекст навигации
import { CustomTabPanel } from "./custom_tab_panel"; //Кастомный Tab
import { ApplicationСtx } from "../../context/application"; //Контекст приложения
import { Statuses, dataCellRender } from "./layouts"; //Дополнительная разметка и вёрстка клиентских элементов
import { CustomDialog } from "./custom_dialog"; //Кастомное диалоговое окно

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
        filled: false,
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

    //Закрытие диалогового окна
    const closeForm = () => {
        setForm(false);
    };

    //Очистка диалогового окна
    const clearFormData = () => {
        setFormData({
            rn: "",
            code: "",
            name: ""
        });
    };

    //Подключение к контексту взаимодействия с сервером
    const { executeStored } = useContext(BackEndСtx);

    //Подключение к контексту приложения
    const { pOnlineShowDictionary } = useContext(ApplicationСtx);

    //Подключение к контексту навигации
    const { getNavigationSearch } = useContext(NavigationCtx);

    //Переключение раздела
    const handleChange = (event, newValue) => {
        setTabValue(newValue);
    };

    //Отработка нажатия на кнопку добавления секции
    const addSectionClick = () => {
        setFormData({ status: Statuses.CREATE, prn: Number(getNavigationSearch().NRN) });
        openForm();
    };

    //Отработка нажатия на кнопку исправления секции
    const editSectionClick = (rn, code, name) => {
        setFormData({ rn: rn, code: code, name: name, status: Statuses.EDIT });
        openForm();
    };

    //Отработка нажатия на кнопку удаления секции
    const deleteSectionClick = (rn, code, name) => {
        setFormData({ rn: rn, code: code, name: name, status: Statuses.DELETE });
        openForm();
    };

    //Отработка нажатия на кнопку добавления показателя раздела
    const addColumnRowClick = (prn, sctnCode, sctnName) => {
        setFormData({ status: Statuses.COLUMNROW_CREATE, prn: prn, sctnCode: sctnCode, sctnName: sctnName });
        openForm();
    };

    //Отработка нажатия на кнопку исправления показателя раздела
    const editColumnRowClick = (rn, name) => {
        setFormData({ status: Statuses.COLUMNROW_EDIT, rn: rn, name: name });
        openForm();
    };

    //Отработка нажатия на кнопку удаления показателя раздела
    const deleteColumnRowClick = (rn, name) => {
        setFormData({ status: Statuses.COLUMNROW_DELETE, rn: rn, name: name });
        openForm();
    };

    //Отработка нажатия на словарь граф
    const dictColumnClick = () => {
        pOnlineShowDictionary({
            unitCode: "RRPColumn",
            callBack: res =>
                res.success === true
                    ? setFormData(pv => ({
                          ...pv,
                          colCode: res.outParameters.out_CODE,
                          colVCode: res.outParameters.out_RRPVERSION_CODE,
                          colVRn: res.outParameters.out_RRPVERSION
                      }))
                    : null
        });
    };

    //Отработка нажатия на словарь строк
    const dictRowClick = () => {
        pOnlineShowDictionary({
            unitCode: "RRPRow",
            callBack: res =>
                res.success === true
                    ? setFormData(pv => ({
                          ...pv,
                          rowCode: res.outParameters.out_CODE,
                          rowVCode: res.outParameters.out_RRPVERSION_CODE,
                          rowVRn: res.outParameters.out_RRPVERSION
                      }))
                    : null
        });
    };

    //Нажатие на кнопку подтверждения создания/исправления/удаления на форме
    const formBtnOkClick = () => {
        let formStateProps = {};
        if (formData.status === (Statuses.CREATE || Statuses.EDIT || Statuses.COLUMNROW_CREATE))
            formStateProps = { ...formStateProps, code: document.querySelector("#code-outlined").value };
        if (formData.status === (Statuses.CREATE || Statuses.EDIT || Statuses.COLUMNROW_CREATE || Statuses.COLUMNROW_EDIT))
            formStateProps = { ...formStateProps, name: document.querySelector("#name-outlined").value };
        setFormData(pv => ({
            ...pv,
            ...formStateProps,
            filled: true
        }));
        closeForm();
    };

    //Формирование разделов
    const a11yProps = index => {
        return {
            id: `simple-tab-${index}`,
            "aria-controls": `simple-tabpanel-${index}`
        };
    };

    //Отработка изменений в разделе или показателе раздела
    const changeSections = useCallback(async () => {
        if (formData.filled) {
            switch (formData.status) {
                case Statuses.CREATE:
                    insertSections();
                    clearFormData();
                    break;
                case Statuses.EDIT:
                    updateSections();
                    clearFormData();
                    break;
                case Statuses.DELETE:
                    deleteSections();
                    clearFormData();
                    break;
                case Statuses.COLUMNROW_CREATE:
                    addColumnRow();
                    clearFormData();
                    break;
                case Statuses.COLUMNROW_EDIT:
                    editColumnRow();
                    clearFormData();
                    break;
                case Statuses.COLUMNROW_DELETE:
                    deleteColumnRow();
                    clearFormData();
                    break;
            }
            setRrpDoc(pv => ({ ...pv, reload: true }));
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [formData]);

    //Добавление раздела
    const insertSections = useCallback(async () => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_RRPCONFED.INSERT_RRPCONF_SECTIONS",
            args: {
                NPRN: formData.prn,
                SCODE: formData.code,
                SNAME: formData.name
            }
        });
        setFormData(pv => ({
            ...pv,
            rn: Number(data.NRN)
        }));
    }, [formData.prn, formData.code, formData.name, executeStored]);

    //Исправление раздела
    const updateSections = useCallback(async () => {
        await executeStored({
            stored: "PKG_P8PANELS_RRPCONFED.UPDATE_RRPCONF_SECTIONS",
            args: {
                NRN: formData.rn,
                SCODE: formData.code,
                SNAME: formData.name
            }
        });
    }, [formData.name, formData.code, formData.rn, executeStored]);

    //Удаление раздела
    const deleteSections = useCallback(async () => {
        await executeStored({
            stored: "PKG_P8PANELS_RRPCONFED.DELETE_RRPCONF_SECTIONS",
            args: {
                NRN: formData.rn
            }
        });
    }, [formData.rn, executeStored]);

    //Добавление показателя раздела
    const addColumnRow = useCallback(async () => {
        await executeStored({
            stored: "PKG_P8PANELS_RRPCONFED.INSERT_RRPCONF_COLUMNROW",
            args: {
                NPRN: formData.prn,
                SCODE: formData.code,
                SNAME: formData.name,
                SCOLCODE: formData.colCode,
                SCOLVER: formData.colVCode,
                SROWCODE: formData.rowCode,
                SROWVER: formData.rowVCode
            }
        });
    }, [executeStored, formData.code, formData.colVCode, formData.colCode, formData.name, formData.prn, formData.rowCode, formData.rowVCode]);

    //Исправление показателя раздела
    const editColumnRow = useCallback(async () => {
        await executeStored({
            stored: "PKG_P8PANELS_RRPCONFED.UPDATE_RRPCONF_COLUMNROW",
            args: { NRN: formData.rn, SNAME: formData.name }
        });
    }, [executeStored, formData.name, formData.rn]);

    //Удаление показателя раздела
    const deleteColumnRow = useCallback(async () => {
        await executeStored({ stored: "PKG_P8PANELS_RRPCONFED.DELETE_RRPCONF_COLUMNROW", args: { NRN: formData.rn } });
    }, [executeStored, formData.rn]);

    //Получение мнемокода и наименования показателя раздела
    const getSctnMrkCodeName = useCallback(async () => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_RRPCONFED.GET_RRPCONFSCTNMRK_CODE_NAME",
            args: { SSCTNCODE: formData.sctnCode, SROWCODE: formData.rowCode, SCOLUMNCODE: formData.colCode }
        });
        setFormData(pv => ({
            ...pv,
            code: data.SCODE,
            name: data.SNAME
        }));
    }, [executeStored, formData.colCode, formData.rowCode, formData.sctnCode]);

    //Загрузка данных разделов регламентированного отчёта
    const loadData = useCallback(async () => {
        if (rrpDoc.reload) {
            //Переменная номера раздела с фокусом
            let tabFocus = 0;
            const data = await executeStored({
                stored: "PKG_P8PANELS_RRPCONFED.GET_RRPCONF_SECTIONS",
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
            const sections = data.SECTIONS.length ? data.SECTIONS : [data.SECTIONS];
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
                tabFocus = curIndex - 1;
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

    //При необходимости обновить данные таблицы
    useEffect(() => {
        loadData();
    }, [rrpDoc.reload, dataGrid.reload, loadData]);

    //Обновление при изменении разделов
    useEffect(() => {
        changeSections();
    }, [changeSections]);

    //Получение наименования и мнемокода показателя раздела при заполнении необходимых полей
    useEffect(() => {
        formData.status == Statuses.COLUMNROW_CREATE && formData.sctnName && formData.sctnCode && formData.colCode && formData.rowCode
            ? getSctnMrkCodeName()
            : null;
    }, [formData.colCode, formData.rowCode, formData.sctnCode, formData.sctnName, formData.status, getSctnMrkCodeName]);

    //Генерация содержимого
    return (
        <Box sx={{ width: "100%" }}>
            {formOpen ? (
                <CustomDialog
                    formOpen={formOpen}
                    closeForm={closeForm}
                    curStatus={formData.status}
                    curCode={formData.code}
                    curName={formData.name}
                    curColCode={formData.colCode}
                    curRowCode={formData.rowCode}
                    btnOkClick={formBtnOkClick}
                    codeOnChange={v => setFormData(pv => ({ ...pv, code: v }))}
                    nameOnChange={v => setFormData(pv => ({ ...pv, name: v }))}
                    dictColumnClick={dictColumnClick}
                    dictRowClick={dictRowClick}
                />
            ) : null}
            {rrpDoc.docLoaded ? (
                <Box sx={{ borderBottom: 1, borderColor: "divider" }}>
                    <Stack direction="row">
                        <Tabs value={tabValue} onChange={handleChange} aria-label="section tab">
                            {rrpDoc.sections.map((s, i) => {
                                return (
                                    <Tab
                                        key={s.rn}
                                        {...a11yProps(i)}
                                        label={
                                            <Stack direction="row" textAlign="center">
                                                {s.name}
                                                <IconButton onClick={() => editSectionClick(s.rn, s.code, s.name)}>
                                                    <Icon>edit</Icon>
                                                </IconButton>
                                                <IconButton onClick={() => deleteSectionClick(s.rn, s.code, s.name)}>
                                                    <Icon>delete</Icon>
                                                </IconButton>
                                            </Stack>
                                        }
                                        wrapped
                                    />
                                );
                            })}
                        </Tabs>
                        <IconButton onClick={addSectionClick}>
                            <Icon>add</Icon>
                        </IconButton>
                    </Stack>
                    {rrpDoc.sections.map((s, i) => {
                        return (
                            <CustomTabPanel key={s.rn} value={tabValue} index={i}>
                                <Button variant="contained" onClick={() => addColumnRowClick(s.rn, s.code, s.name)}>
                                    + Добавить
                                </Button>
                                {s.dataLoaded ? (
                                    <P8PDataGrid
                                        {...P8P_DATA_GRID_CONFIG_PROPS}
                                        columnsDef={s.columnsDef}
                                        groups={s.groups}
                                        rows={s.rows}
                                        size={P8P_DATA_GRID_SIZE.LARGE}
                                        reloading={s.reload}
                                        dataCellRender={prms => dataCellRender({ ...prms }, editColumnRowClick, deleteColumnRowClick)}
                                    />
                                ) : null}
                            </CustomTabPanel>
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

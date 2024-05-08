//---------------------
//Подключение библиотек
//---------------------

import { useState, useCallback, useEffect, useContext } from "react"; //Классы React
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { object2Base64XML } from "../../core/utils"; //Вспомогательные функции

//---------
//Константы
//---------

//Размер страницы данных
const DATA_GRID_PAGE_SIZE = 5;
const DATA_GRID_PAGE_FCEQUIPMENT = 10;

//---------------------------------------------
//Вспомогательные функции форматирования данных
//---------------------------------------------

//Переиницализация выбранных значений строк (необходимо при сортировке или добавлении записей строк)
const updatingSelected = (rows, selectedRows) => {
    //Если полученный массив строк не пустой
    if (rows.length > 0 && selectedRows.length > 0) {
        //Устанавливаем выбор там, где он был установлен
        let updatedRows = rows.map(item => {
            if (selectedRows.includes(item.NRN)) {
                return { ...item, NSELECT: 1 };
            } else {
                return item;
            }
        });
        return updatedRows;
    }
    //Возвращаем
    return rows;
};

//-----------
//Тело модуля
//-----------

//Хук для таблицы маршрутных листов
const useCostRouteLists = (task, processIdent) => {
    //Собственное состояние - таблица данных
    const [costRouteLists, setCostRouteLists] = useState({
        task: null,
        dataLoaded: false,
        columnsDef: [],
        orders: null,
        rows: [],
        selectedRows: [],
        reload: true,
        pageNumber: 1,
        morePages: true
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored, SERV_DATA_TYPE_CLOB } = useContext(BackEndСtx);

    //Загрузка данных таблицы с сервера
    const loadData = useCallback(async () => {
        if (costRouteLists.reload) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.FCJOBSSP_FCROUTLST_DG_GET",
                args: {
                    NFCJOBS: task,
                    CORDERS: { VALUE: object2Base64XML(costRouteLists.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    NPAGE_NUMBER: costRouteLists.pageNumber,
                    NPAGE_SIZE: DATA_GRID_PAGE_SIZE,
                    NINCLUDE_DEF: costRouteLists.dataLoaded ? 0 : 1
                },
                respArg: "COUT",
                attributeValueProcessor: (name, val) => (["NSELECT"].includes(name) ? val === 1 : val)
            });
            setCostRouteLists(pv => ({
                ...pv,
                task: task,
                columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                rows:
                    pv.pageNumber == 1
                        ? updatingSelected([...(data.XROWS || [])], costRouteLists.selectedRows)
                        : updatingSelected([...pv.rows, ...(data.XROWS || [])], costRouteLists.selectedRows),
                dataLoaded: true,
                reload: false,
                morePages: (data.XROWS || []).length >= DATA_GRID_PAGE_SIZE
            }));
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [
        costRouteLists.reload,
        costRouteLists.filters,
        costRouteLists.orders,
        costRouteLists.dataLoaded,
        costRouteLists.pageNumber,
        executeStored,
        SERV_DATA_TYPE_CLOB
    ]);

    //Добавление/удаление записи в селектлисте
    const modifySelectList = useCallback(
        async prms => {
            try {
                if (prms.NSELECT) {
                    await executeStored({
                        stored: "PKG_P8PANELS_MECHREC.SELECTLIST_FCROUTLST_ADD",
                        args: { NIDENT: processIdent, NFCROUTLST: prms.NFCROUTLST }
                    });
                } else {
                    await executeStored({
                        stored: "PKG_P8PANELS_MECHREC.SELECTLIST_FCROUTLST_DEL",
                        args: { NIDENT: processIdent, NFCROUTLST: prms.NFCROUTLST }
                    });
                }
            } catch (e) {
                throw new Error(e.message);
            }
        },
        // eslint-disable-next-line react-hooks/exhaustive-deps
        [executeStored]
    );

    //При необходимости обновить данные таблицы
    useEffect(() => {
        loadData();
    }, [costRouteLists.reload, loadData]);

    //При изменении сменного задания
    useEffect(() => {
        setCostRouteLists(pv => ({
            ...pv,
            dataLoaded: false,
            columnsDef: [],
            orders: null,
            rows: [],
            selectedRows: [],
            reload: true,
            pageNumber: 1,
            morePages: true
        }));
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [task]);

    return [costRouteLists, setCostRouteLists, modifySelectList];
};

//Хук для таблицы операций
const useCostJobsSpecs = (task, fcroutlstList, processIdent) => {
    //Собственное состояние - таблица данных
    const [costJobsSpecs, setCostJobsSpecs] = useState({
        task: null,
        dataLoaded: false,
        columnsDef: [],
        orders: null,
        rows: [],
        selectedRows: [],
        reload: true,
        pageNumber: 1,
        morePages: true
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored, SERV_DATA_TYPE_CLOB } = useContext(BackEndСtx);

    //Загрузка данных таблицы с сервера
    const loadData = useCallback(async () => {
        if (costJobsSpecs.reload) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.FCJOBSSP_DG_GET",
                args: {
                    NFCJOBS: task,
                    NIDENT: processIdent,
                    //SFCROUTLST_LIST: fcroutlstList.join(","),
                    CORDERS: { VALUE: object2Base64XML(costJobsSpecs.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    NPAGE_NUMBER: costJobsSpecs.pageNumber,
                    NPAGE_SIZE: DATA_GRID_PAGE_SIZE,
                    NINCLUDE_DEF: costJobsSpecs.dataLoaded ? 0 : 1
                },
                respArg: "COUT",
                attributeValueProcessor: (name, val) => (["NSELECT"].includes(name) ? val === 1 : val)
            });
            setCostJobsSpecs(pv => ({
                ...pv,
                task: task,
                columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                rows:
                    pv.pageNumber == 1
                        ? updatingSelected([...(data.XROWS || [])], costJobsSpecs.selectedRows)
                        : updatingSelected([...pv.rows, ...(data.XROWS || [])], costJobsSpecs.selectedRows),
                dataLoaded: true,
                reload: false,
                morePages: (data.XROWS || []).length >= DATA_GRID_PAGE_SIZE
            }));
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [
        costJobsSpecs.reload,
        costJobsSpecs.filters,
        costJobsSpecs.orders,
        costJobsSpecs.dataLoaded,
        costJobsSpecs.pageNumber,
        executeStored,
        SERV_DATA_TYPE_CLOB
    ]);

    //Выдача задания
    const issueCostJobsSpecs = useCallback(
        async prms => {
            try {
                await executeStored({
                    stored: "PKG_P8PANELS_MECHREC.FCJOBSSP_ISSUE",
                    args: { NFCJOBS: prms.NFCJOBS, SFCJOBSSP_LIST: prms.SFCJOBSSP_LIST }
                });
            } catch (e) {
                throw new Error(e.message);
            }
        },
        [executeStored]
    );

    //При необходимости обновить данные таблицы
    useEffect(() => {
        loadData();
    }, [costJobsSpecs.reload, loadData]);

    //При изменении сменного задания
    useEffect(() => {
        setCostJobsSpecs(pv => ({
            ...pv,
            dataLoaded: false,
            columnsDef: [],
            orders: null,
            rows: [],
            selectedRows: [],
            reload: true,
            pageNumber: 1,
            morePages: true
        }));
    }, [task, fcroutlstList]);

    return [costJobsSpecs, setCostJobsSpecs, issueCostJobsSpecs];
};

//Хук для таблицы рабочих центров
const useCostEquipment = () => {
    //Собственное состояние - таблица данных
    const [costEquipment, setCostEquipment] = useState({
        dataLoaded: false,
        columnsDef: [],
        orders: null,
        rows: [],
        selectedRows: [],
        selectedLoaded: false,
        reload: true,
        pageNumber: 1,
        morePages: true
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored, SERV_DATA_TYPE_CLOB } = useContext(BackEndСtx);

    //Загрузка данных таблицы с сервера
    const loadData = useCallback(async () => {
        if (costEquipment.reload) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.FCEQUIPMENT_DG_GET",
                args: {
                    CORDERS: { VALUE: object2Base64XML(costEquipment.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    NPAGE_NUMBER: costEquipment.pageNumber,
                    NPAGE_SIZE: DATA_GRID_PAGE_FCEQUIPMENT,
                    NINCLUDE_DEF: costEquipment.dataLoaded ? 0 : 1
                },
                respArg: "COUT",
                attributeValueProcessor: (name, val) => (["NSELECT"].includes(name) ? val === 1 : val)
            });
            setCostEquipment(pv => ({
                ...pv,
                columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                rows:
                    pv.pageNumber == 1
                        ? updatingSelected([...(data.XROWS || [])], costEquipment.selectedRows)
                        : updatingSelected([...pv.rows, ...(data.XROWS || [])], costEquipment.selectedRows),
                dataLoaded: true,
                reload: false,
                morePages: (data.XROWS || []).length >= DATA_GRID_PAGE_FCEQUIPMENT
            }));
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [
        costEquipment.reload,
        costEquipment.filters,
        costEquipment.orders,
        costEquipment.dataLoaded,
        costEquipment.pageNumber,
        executeStored,
        SERV_DATA_TYPE_CLOB
    ]);

    //Включение оборудования в операции
    const includeCostEquipment = useCallback(
        async prms => {
            try {
                await executeStored({
                    stored: "PKG_P8PANELS_MECHREC.FCJOBSSP_INC_FCEQUIPMENT",
                    args: { NFCEQUIPMENT: prms.NFCEQUIPMENT, NFCJOBS: prms.NFCJOBS, SFCJOBSSP_LIST: prms.SFCJOBSSP_LIST }
                });
            } catch (e) {
                throw new Error(e.message);
            }
        },
        [executeStored]
    );

    //Исключение оборудования из операции
    const excludeCostEquipment = useCallback(
        async prms => {
            try {
                await executeStored({
                    stored: "PKG_P8PANELS_MECHREC.FCJOBSSP_EXC_FCEQUIPMENT",
                    args: { NFCEQUIPMENT: prms.NFCEQUIPMENT, NFCJOBS: prms.NFCJOBS, SFCJOBSSP_LIST: prms.SFCJOBSSP_LIST }
                });
            } catch (e) {
                throw new Error(e.message);
            }
        },
        [executeStored]
    );

    //При необходимости обновить данные таблицы
    useEffect(() => {
        loadData();
    }, [costEquipment.reload, loadData]);

    return [costEquipment, setCostEquipment, includeCostEquipment, excludeCostEquipment];
};

export { useCostRouteLists, useCostJobsSpecs, useCostEquipment, updatingSelected };

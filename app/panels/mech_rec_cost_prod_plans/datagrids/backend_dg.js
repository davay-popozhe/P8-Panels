//---------------------
//Подключение библиотек
//---------------------

import { useState, useCallback, useEffect, useContext } from "react";
import { BackEndСtx } from "../../../context/backend"; //Контекст взаимодействия с сервером
import { object2Base64XML, formatDateRF } from "../../../core/utils"; //Вспомогательные функции

//---------
//Константы
//---------

//Размер страницы данных
const DATA_GRID_PAGE_SIZE = 10;

//-----------
//Тело модуля
//-----------

//Хук для таблицы маршрутных листов
const useCostRouteLists = (task, taskType) => {
    //Собственное состояние - таблица данных
    const [costRouteLists, setCostRouteLists] = useState({
        dataLoaded: false,
        columnsDef: [],
        orders: null,
        rows: [],
        reload: true,
        pageNumber: 1,
        morePages: true,
        quantPlanSum: 0,
        uniqueNomns: []
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored, SERV_DATA_TYPE_CLOB } = useContext(BackEndСtx);

    //Загрузка данных таблицы с сервера
    const loadData = useCallback(async () => {
        if (costRouteLists.reload) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.FCROUTLST_DG_GET",
                args: {
                    NFCPRODPLANSP: task,
                    NTYPE: taskType,
                    CORDERS: { VALUE: object2Base64XML(costRouteLists.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    NPAGE_NUMBER: costRouteLists.pageNumber,
                    NPAGE_SIZE: DATA_GRID_PAGE_SIZE,
                    NINCLUDE_DEF: costRouteLists.dataLoaded ? 0 : 1
                },
                attributeValueProcessor: (name, val) => (["DEXEC_DATE", "DREL_DATE"].includes(name) ? formatDateRF(val) : val),
                respArg: "COUT"
            });
            setCostRouteLists(pv => ({
                ...pv,
                columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                rows: pv.pageNumber == 1 ? [...(data.XROWS || [])] : [...pv.rows, ...(data.XROWS || [])],
                dataLoaded: true,
                reload: false,
                morePages: (data.XROWS || []).length >= DATA_GRID_PAGE_SIZE,
                quantPlanSum: data.XROWS ? data.XROWS.reduce((a, b) => a + b["NQUANT_PLAN"], 0) : 0,
                uniqueNomns: data.XROWS
                    ? data.XROWS.reduce((accumulator, current) => {
                          if (!accumulator.find(item => item.SMATRES_PLAN_NOMEN === current.SMATRES_PLAN_NOMEN)) {
                              accumulator.push(current);
                          }
                          return accumulator;
                      }, [])
                    : []
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

    //При необходимости обновить данные таблицы
    useEffect(() => {
        loadData();
    }, [costRouteLists.reload, loadData]);

    return [costRouteLists, setCostRouteLists];
};

//Хук для таблицы приходов из подразделений
const useIncomFromDeps = (task, taskType) => {
    //Собственное состояние - таблица данных
    const [incomFromDeps, setIncomFromDeps] = useState({
        dataLoaded: false,
        columnsDef: [],
        orders: null,
        rows: [],
        reload: true,
        pageNumber: 1,
        morePages: true
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored, SERV_DATA_TYPE_CLOB } = useContext(BackEndСtx);

    //Загрузка данных таблицы с сервера
    const loadData = useCallback(async () => {
        if (incomFromDeps.reload) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.INCOMEFROMDEPS_DG_GET",
                args: {
                    NFCPRODPLANSP: task,
                    NTYPE: taskType,
                    CORDERS: { VALUE: object2Base64XML(incomFromDeps.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    NPAGE_NUMBER: incomFromDeps.pageNumber,
                    NPAGE_SIZE: DATA_GRID_PAGE_SIZE,
                    NINCLUDE_DEF: incomFromDeps.dataLoaded ? 0 : 1
                },
                attributeValueProcessor: (name, val) => (["DWORK_DATE"].includes(name) ? formatDateRF(val) : val),
                respArg: "COUT"
            });
            setIncomFromDeps(pv => ({
                ...pv,
                columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                rows: pv.pageNumber == 1 ? [...(data.XROWS || [])] : [...pv.rows, ...(data.XROWS || [])],
                dataLoaded: true,
                reload: false,
                morePages: (data.XROWS || []).length >= DATA_GRID_PAGE_SIZE
            }));
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [incomFromDeps.reload, incomFromDeps.orders, incomFromDeps.dataLoaded, incomFromDeps.pageNumber, executeStored, SERV_DATA_TYPE_CLOB]);

    //При необходимости обновить данные таблицы
    useEffect(() => {
        loadData();
    }, [incomFromDeps.reload, loadData]);

    return [incomFromDeps, setIncomFromDeps];
};

//Хук для таблицы товарных запасов
const useGoodsParties = mainRowRN => {
    //Собственное состояние - таблица данных
    const [goodsParties, setGoodsParties] = useState({
        dataLoaded: false,
        columnsDef: [],
        orders: null,
        rows: [],
        reload: true,
        pageNumber: 1,
        morePages: true
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored, SERV_DATA_TYPE_CLOB } = useContext(BackEndСtx);

    //Загрузка данных таблицы с сервера
    const loadData = useCallback(async () => {
        if (goodsParties.reload) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.GOODSPARTIES_DG_GET",
                args: {
                    NFCROUTLST: mainRowRN,
                    CORDERS: { VALUE: object2Base64XML(goodsParties.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    NPAGE_NUMBER: goodsParties.pageNumber,
                    NPAGE_SIZE: DATA_GRID_PAGE_SIZE,
                    NINCLUDE_DEF: goodsParties.dataLoaded ? 0 : 1
                },
                respArg: "COUT"
            });
            setGoodsParties(pv => ({
                ...pv,
                columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                rows: pv.pageNumber == 1 ? [...(data.XROWS || [])] : [...pv.rows, ...(data.XROWS || [])],
                dataLoaded: true,
                reload: false,
                morePages: (data.XROWS || []).length >= DATA_GRID_PAGE_SIZE
            }));
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [goodsParties.reload, goodsParties.orders, goodsParties.dataLoaded, goodsParties.pageNumber, executeStored, SERV_DATA_TYPE_CLOB]);

    //При необходимости обновить данные таблицы
    useEffect(() => {
        loadData();
    }, [goodsParties.reload, loadData]);

    return [goodsParties, setGoodsParties];
};

//Хук для таблицы строк комплектации
const useCostDeliveryLists = mainRowRN => {
    //Собственное состояние - таблица данных
    const [costDeliveryLists, setCostDeliveryLists] = useState({
        dataLoaded: false,
        columnsDef: [],
        orders: null,
        rows: [],
        reload: true,
        pageNumber: 1,
        morePages: true
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored, SERV_DATA_TYPE_CLOB } = useContext(BackEndСtx);

    //Загрузка данных таблицы строк комплектации с сервера
    const loadData = useCallback(async () => {
        if (costDeliveryLists.reload) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.FCDELIVERYLISTSP_DG_GET",
                args: {
                    NFCROUTLST: mainRowRN,
                    CORDERS: { VALUE: object2Base64XML(costDeliveryLists.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                    NPAGE_NUMBER: costDeliveryLists.pageNumber,
                    NPAGE_SIZE: DATA_GRID_PAGE_SIZE,
                    NINCLUDE_DEF: costDeliveryLists.dataLoaded ? 0 : 1
                },
                attributeValueProcessor: (name, val) => (name === "DRES_DATE_TO" ? formatDateRF(val) : val),
                respArg: "COUT"
            });
            setCostDeliveryLists(pv => ({
                ...pv,
                columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                rows: pv.pageNumber == 1 ? [...(data.XROWS || [])] : [...pv.rows, ...(data.XROWS || [])],
                dataLoaded: true,
                reload: false,
                morePages: (data.XROWS || []).length >= DATA_GRID_PAGE_SIZE
            }));
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [
        costDeliveryLists.reload,
        costDeliveryLists.orders,
        costDeliveryLists.dataLoaded,
        costDeliveryLists.pageNumber,
        executeStored,
        SERV_DATA_TYPE_CLOB
    ]);

    //При необходимости обновить данные таблицы
    useEffect(() => {
        loadData();
    }, [costDeliveryLists.reload, loadData]);

    return [costDeliveryLists, setCostDeliveryLists];
};

export { useCostRouteLists, useIncomFromDeps, useGoodsParties, useCostDeliveryLists };

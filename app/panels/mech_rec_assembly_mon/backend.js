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
const DATA_GRID_PAGE_SIZE = 10;

//-----------
//Тело модуля
//-----------

//Хук для основной таблицы панели
const useMechRecAssemblyMon = () => {
    //Собственное состояние
    let [state, setState] = useState({
        init: false,
        showPlanList: false,
        planCtlgs: [],
        planCtlgsLoaded: false,
        selectedPlanCtlg: { NRN: null, SNAME: null, NMIN_YEAR: null, NMAX_YEAR: null },
        plans: [],
        plansLoaded: false,
        selectedPlan: { NRN: null, SNUMB: null, NPROGRESS: null, SDETAIL: null, NYEAR: null }
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored } = useContext(BackEndСtx);

    //Инициализация каталогов планов
    const initPlanCtlgs = useCallback(async () => {
        if (!state.init) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.FCPRODPLAN_CTLG_INIT",
                args: {},
                respArg: "COUT",
                isArray: name => name === "XFCPRODPLAN_CRNS"
            });
            setState(pv => ({ ...pv, init: true, planCtlgs: [...(data?.XFCPRODPLAN_CRNS || [])], planCtlgsLoaded: true }));
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [state.init, executeStored]);

    //Получение информации о планах каталога
    const loadPlans = useCallback(
        async NCRN => {
            if (NCRN) {
                const data = await executeStored({
                    stored: "PKG_P8PANELS_MECHREC.FCPRODPLAN_GET",
                    args: { NCRN: NCRN },
                    respArg: "COUT",
                    isArray: name => name === "XFCPRODPLAN_INFO"
                });
                setState(pv => ({ ...pv, init: true, plans: [...(data?.XFCPRODPLAN_INFO || [])], plansLoaded: true }));
            }
            // eslint-disable-next-line react-hooks/exhaustive-deps
        },
        [executeStored]
    );

    //Выбор каталога планов
    const selectPlan = project => {
        setState(pv => ({
            ...pv,
            selectedPlanCtlg: project,
            showPlanList: false
        }));
    };

    //Сброс выбора каталога планов
    const unselectPlan = () =>
        setState(pv => ({
            ...pv,
            selectedPlanCtlg: { NRN: null, SNAME: null, NMIN_YEAR: null, NMAX_YEAR: null },
            showPlanList: false
        }));

    //При подключении компонента к странице
    useEffect(() => {
        initPlanCtlgs();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    //При изменении каталога
    useEffect(() => {
        //Если каталог выбран
        if (state.selectedPlanCtlg) {
            loadPlans(state.selectedPlanCtlg.NRN);
        } else {
            setState(pv => ({ ...pv, plans: [], plansLoaded: false }));
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [state.selectedPlanCtlg]);

    return [state, setState, selectPlan, unselectPlan];
};

//Хук для информации по производственным составам
const useCostProductComposition = nProdPlan => {
    //Собственное состояние
    let [costProductComposition, setCostProductComposition] = useState({
        init: false,
        showPlanList: false,
        products: [],
        selectedProduct: null
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored } = useContext(BackEndСtx);

    //Инициализация производственных составов
    const initCostProductComposition = useCallback(async () => {
        if (!costProductComposition.init) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.FCPRODCMP_DETAILS_GET",
                args: { NFCPRODPLAN: nProdPlan },
                respArg: "COUT",
                isArray: name => name === "XFCPRODCMP"
            });
            setCostProductComposition(pv => ({ ...pv, init: true, products: [...(data?.XFCPRODCMP || [])], productsLoaded: true }));
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [costProductComposition.init, executeStored]);

    //При подключении компонента к странице
    useEffect(() => {
        initCostProductComposition();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    return [costProductComposition, setCostProductComposition];
};

//Хук для таблицы маршрутных листов
const useCostRouteLists = (plan, product) => {
    //Собственное состояние - таблица данных
    const [costRouteLists, setCostRouteLists] = useState({
        dataLoaded: false,
        columnsDef: [],
        orders: null,
        rows: [],
        reload: true,
        pageNumber: 1,
        morePages: true,
        selectedProduct: null
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored, SERV_DATA_TYPE_CLOB } = useContext(BackEndСtx);

    //Загрузка данных таблицы с сервера
    const loadData = useCallback(
        async () => {
            if (costRouteLists.reload) {
                const data = await executeStored({
                    stored: "PKG_P8PANELS_MECHREC.FCROUTLST_MON_DG_GET",
                    args: {
                        NPRODCMPSP: product,
                        NFCPRODPLAN: plan,
                        CORDERS: { VALUE: object2Base64XML(costRouteLists.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                        NPAGE_NUMBER: costRouteLists.pageNumber,
                        NPAGE_SIZE: DATA_GRID_PAGE_SIZE,
                        NINCLUDE_DEF: costRouteLists.dataLoaded ? 0 : 1
                    },
                    respArg: "COUT"
                });
                setCostRouteLists(pv => ({
                    ...pv,
                    columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                    rows: pv.pageNumber == 1 ? [...(data.XROWS || [])] : [...pv.rows, ...(data.XROWS || [])],
                    dataLoaded: true,
                    reload: false,
                    morePages: (data.XROWS || []).length >= DATA_GRID_PAGE_SIZE
                }));
            }
        },
        // eslint-disable-next-line react-hooks/exhaustive-deps
        [costRouteLists.reload, costRouteLists.orders, costRouteLists.dataLoaded, costRouteLists.pageNumber, executeStored, SERV_DATA_TYPE_CLOB]
    );

    //При изменении продукта
    useEffect(() => {
        //Если продукт указан
        if (product) {
            //Принудительно обновляем состояние
            setCostRouteLists(pv => ({
                ...pv,
                dataLoaded: false,
                columnsDef: [],
                orders: null,
                rows: [],
                reload: true,
                pageNumber: 1,
                morePages: true,
                selectedProduct: null
            }));
            //Загружаем данные с учетом выбранного продукта
            loadData();
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [product]);

    //При необходимости обновить данные таблицы
    useEffect(() => {
        //Если продукт указан и необходимо стандартное обновление
        if (product) {
            loadData();
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [costRouteLists.reload, loadData]);

    //При изменении плана
    useEffect(() => {
        setCostRouteLists(pv => ({
            ...pv,
            dataLoaded: false,
            columnsDef: [],
            orders: null,
            rows: [],
            reload: true,
            pageNumber: 1,
            morePages: true,
            selectedProduct: null
        }));
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [plan]);

    return [costRouteLists, setCostRouteLists];
};

//Хук для таблицы комплектовочных ведомостей
const useCostDeliverySheets = (plan, product) => {
    //Собственное состояние - таблица данных
    const [costDeliverySheets, setCostDeliverySheets] = useState({
        dataLoaded: false,
        columnsDef: [],
        orders: null,
        rows: [],
        reload: true,
        pageNumber: 1,
        morePages: true,
        selectedProduct: null
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored, SERV_DATA_TYPE_CLOB } = useContext(BackEndСtx);

    //Загрузка данных таблицы с сервера
    const loadData = useCallback(
        async () => {
            if (costDeliverySheets.reload) {
                const data = await executeStored({
                    stored: "PKG_P8PANELS_MECHREC.FCDELIVSH_DG_GET",
                    args: {
                        NPRODCMPSP: product,
                        NFCPRODPLAN: plan,
                        CORDERS: { VALUE: object2Base64XML(costDeliverySheets.orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                        NPAGE_NUMBER: costDeliverySheets.pageNumber,
                        NPAGE_SIZE: DATA_GRID_PAGE_SIZE,
                        NINCLUDE_DEF: costDeliverySheets.dataLoaded ? 0 : 1
                    },
                    respArg: "COUT"
                });
                setCostDeliverySheets(pv => ({
                    ...pv,
                    columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                    rows: pv.pageNumber == 1 ? [...(data.XROWS || [])] : [...pv.rows, ...(data.XROWS || [])],
                    dataLoaded: true,
                    reload: false,
                    morePages: (data.XROWS || []).length >= DATA_GRID_PAGE_SIZE
                }));
            }
        },
        // eslint-disable-next-line react-hooks/exhaustive-deps
        [
            costDeliverySheets.reload,
            costDeliverySheets.orders,
            costDeliverySheets.dataLoaded,
            costDeliverySheets.pageNumber,
            executeStored,
            SERV_DATA_TYPE_CLOB
        ]
    );

    //При изменении продукта
    useEffect(() => {
        //Если продукт указан
        if (product) {
            //Принудительно обновляем состояние
            setCostDeliverySheets(pv => ({
                ...pv,
                dataLoaded: false,
                columnsDef: [],
                orders: null,
                rows: [],
                reload: true,
                pageNumber: 1,
                morePages: true
            }));
            //Загружаем данные с учетом выбранного продукта
            loadData();
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [product]);

    //При необходимости обновить данные таблицы
    useEffect(() => {
        //Если продукт указан и необходимо стандартное обновление
        if (product) {
            loadData();
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [costDeliverySheets.reload, loadData]);

    //При изменении плана
    useEffect(() => {
        setCostDeliverySheets(pv => ({
            ...pv,
            dataLoaded: false,
            columnsDef: [],
            orders: null,
            rows: [],
            reload: true,
            pageNumber: 1,
            morePages: true,
            selectedProduct: null
        }));
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [plan]);

    return [costDeliverySheets, setCostDeliverySheets];
};

export { useMechRecAssemblyMon, useCostProductComposition, useCostRouteLists, useCostDeliverySheets };

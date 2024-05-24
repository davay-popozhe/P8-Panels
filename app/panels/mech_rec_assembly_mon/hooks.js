/*
    Парус 8 - Панели мониторинга - ПУП - Мониторинг сборки изделий
    Кастомные хуки
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useCallback, useEffect, useContext } from "react"; //Классы React
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { object2Base64XML } from "../../core/utils"; //Вспомогательные функции

//---------
//Константы
//---------

//Размер страницы данных
const DATA_GRID_PAGE_SIZE = 50;

//-----------
//Тело модуля
//-----------

//Клиентский отбор каталогов по поисковой фразе и наличию планов
export const useFilteredPlanCtlgs = (planCtlgs, filter) => {
    const filteredPlanCtlgs = React.useMemo(() => {
        return planCtlgs.filter(
            catalog =>
                catalog.SNAME.toString().toLowerCase().includes(filter.ctlgName) &&
                (filter.haveDocs ? catalog.NCOUNT_DOCS > 0 : catalog.NCOUNT_DOCS >= 0)
        );
    }, [planCtlgs, filter]);

    return filteredPlanCtlgs;
};

//Хук для основной таблицы панели
const useMechRecAssemblyMon = () => {
    //Собственное состояние
    let [state, setState] = useState({
        init: false,
        showPlanList: false,
        planCtlgs: [],
        planCtlgsLoaded: false,
        selectedPlanCtlg: {},
        plans: [],
        plansLoaded: false,
        selectedPlan: {}
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored } = useContext(BackEndСtx);

    //Инициализация каталогов планов
    const initPlanCtlgs = useCallback(async () => {
        if (!state.init) {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.FCPRODPLAN_AM_CTLG_INIT",
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
    const selectPlanCtlg = planCtlg => {
        setState(pv => ({
            ...pv,
            selectedPlanCtlg: { ...planCtlg },
            selectedPlan: {},
            showPlanList: false
        }));
    };

    //Сброс выбора каталога планов
    const unselectPlanCtlg = () =>
        setState(pv => ({
            ...pv,
            selectedPlanCtlg: {},
            selectedPlan: {},
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

    return [state, setState, selectPlanCtlg, unselectPlanCtlg];
};

//Хук для информации по производственным составам
const useCostProductComposition = plan => {
    //Собственное состояние
    let [costProductComposition, setCostProductComposition] = useState({
        showPlanList: false,
        products: [],
        productsLoaded: false,
        model: null,
        selectedProduct: null
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored } = useContext(BackEndСtx);

    //При подключении компонента к странице
    useEffect(() => {
        const loadData = async () => {
            const data = await executeStored({
                stored: "PKG_P8PANELS_MECHREC.FCPRODCMP_DETAILS_GET",
                args: { NFCPRODPLAN: plan },
                respArg: "COUT",
                isArray: name => name === "XFCPRODCMP"
            });
            setCostProductComposition(pv => ({
                ...pv,
                products: [...(data?.XFCPRODCMP || [])],
                productsLoaded: true,
                model: data?.BMODEL,
                selectedProduct: null
            }));
        };
        if (plan) loadData();
    }, [plan, executeStored]);

    //Вернём данные
    return [costProductComposition, setCostProductComposition];
};

//Хук для таблицы детализации изделия
const useProductDetailsTable = (plan, product, orders, pageNumber, stored) => {
    //Собственное состояние - флаг загрузки
    const [isLoading, setLoading] = useState(true);

    //Собственное состояние - таблица данных
    const [data, setData] = useState({
        columnsDef: [],
        rows: [],
        morePages: true
    });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored, SERV_DATA_TYPE_CLOB } = useContext(BackEndСtx);

    //Загрузка данных при изменении зависимостей
    useEffect(() => {
        const loadData = async () => {
            try {
                setLoading(true);
                const data = await executeStored({
                    stored,
                    args: {
                        NPRODCMPSP: product,
                        NFCPRODPLAN: plan,
                        CORDERS: { VALUE: object2Base64XML(orders, { arrayNodeName: "orders" }), SDATA_TYPE: SERV_DATA_TYPE_CLOB },
                        NPAGE_NUMBER: pageNumber,
                        NPAGE_SIZE: DATA_GRID_PAGE_SIZE,
                        NINCLUDE_DEF: pageNumber == 1 ? 1 : 0
                    },
                    respArg: "COUT"
                });
                setData(pv => ({
                    ...pv,
                    columnsDef: data.XCOLUMNS_DEF ? [...data.XCOLUMNS_DEF] : pv.columnsDef,
                    rows: pageNumber == 1 ? [...(data.XROWS || [])] : [...pv.rows, ...(data.XROWS || [])],
                    morePages: DATA_GRID_PAGE_SIZE == 0 ? false : (data.XROWS || []).length >= DATA_GRID_PAGE_SIZE
                }));
            } finally {
                setLoading(false);
            }
        };
        if (plan && product) loadData();
    }, [plan, product, orders, pageNumber, stored, executeStored, SERV_DATA_TYPE_CLOB]);

    //Вернём данные
    return { data, isLoading };
};

export { useMechRecAssemblyMon, useCostProductComposition, useProductDetailsTable };

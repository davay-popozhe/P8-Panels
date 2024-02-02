/*
    Парус 8 - Панели мониторинга
    Компонент: Таблица - редьюсер состояния
*/

//---------
//Константы
//---------

//Типы действий
const P8P_TABLE_AT = {
    SET_HEADER: "SET_HEADER", //Установка заголовка таблицы
    TOGGLE_HEADER_EXPAND: "TOGGLE_HEADER_EXPAND" //Сворачивание/разворачивание уровня заголовка
};

//Состояние заголовка таблицы по умолчанию
const HEADER_INITIAL_STATE = () => ({
    columnsDef: [],
    displayLevels: [],
    displayLevelsColumns: {},
    displayDataColumnsCount: 0,
    displayDataColumns: []
});

//Состояние описания ячейки заголовка таблицы по умолчанию
const HEADER_COLUMN_INITIAL_STATE = ({ columnDef, objectsCopier }) => {
    const tmp = objectsCopier(columnDef);
    if (!hasValue(tmp.parent)) tmp.parent = "";
    if (!hasValue(tmp.expandable)) tmp.expandable = false;
    if (!hasValue(tmp.expanded)) tmp.expanded = true;
    return tmp;
};

//--------------------------------
//Вспомогательные классы и функции
//--------------------------------

//Проверка существования значения
const hasValue = value => typeof value !== "undefined" && value !== undefined && value !== null && value !== "";

//Определение высоты (в уровнях)  ячейки заголовка
const getDisplayColumnRowSpan = (displayTree, maxLevel) => {
    displayTree.forEach(columnDef => {
        columnDef.rowSpan = columnDef.hasChild ? maxLevel - columnDef.childMaxLevel + 1 : maxLevel - columnDef.level + 1;
        if (columnDef.hasChild) getDisplayColumnRowSpan(columnDef.child, maxLevel);
    });
};

//Определение ширины (в колонках) ячейки заголовка
const getDisplayColumnColSpan = (displayTree, columnDef) => {
    if (columnDef.hasChild) {
        let colSpan = 0;
        displayTree.forEach(cD => (cD.parent == columnDef.name ? (colSpan += getDisplayColumnColSpan(cD.child, cD)) : null));
        return colSpan;
    } else return 1;
};

//Формирование дерева отображаемых элементов заголовка
const buildDisplayTree = (columnsDef, parent, level) => {
    const baseBuild = (columnsDef, parent, level) => {
        let maxLevel = level - 1;
        const res = columnsDef
            .filter(columnDef => columnDef.parent == parent && columnDef.visible)
            .map(columnDef => {
                const [child, childMaxLevel] = columnDef.expanded ? baseBuild(columnsDef, columnDef.name, level + 1) : [[], level];
                if (childMaxLevel > maxLevel) maxLevel = childMaxLevel;
                const res = {
                    ...columnDef,
                    child,
                    hasChild: child.length > 0 ? true : false,
                    level,
                    childMaxLevel: child.length > 0 ? childMaxLevel : 0
                };
                return { ...res, colSpan: getDisplayColumnColSpan(child, res), rowSpan: 1 };
            });
        return [res, maxLevel];
    };
    const [displayTree, maxLevel] = baseBuild(columnsDef, parent, level);
    getDisplayColumnRowSpan(displayTree, maxLevel);
    return [displayTree, maxLevel];
};

//Формирование коллекции отображаемых колонок уровня
const buildDisplayLevelsColumns = (displayTree, maxLevel) => {
    const extractLevel = (displayTree, level) => {
        let res = [];
        displayTree.forEach(columnDef => {
            if (columnDef.level == level) res.push(columnDef);
            if (columnDef.hasChild) res = res.concat(extractLevel(columnDef.child, level));
        });
        return res;
    };
    const displayLevels = [...Array(maxLevel).keys()].map(i => i + 1);
    const displayLevelsColumns = {};
    displayLevels.forEach(level => (displayLevelsColumns[level] = extractLevel(displayTree, level)));
    return [displayLevels, displayLevelsColumns];
};

//Формирование коллекции отображаемых колонок данных
const buildDisplayDataColumns = (displayTree, expandable) => {
    const displayDataColumns = [];
    const traverseTree = displayTree => {
        displayTree.forEach(columnDef => (!columnDef.hasChild ? displayDataColumns.push(columnDef) : traverseTree(columnDef.child)));
    };
    traverseTree(displayTree);
    return [displayDataColumns, displayDataColumns.length + (expandable === true ? 1 : 0)];
};

//Формирование описания отображаемых колонок
const buildDisplay = ({ columnsDef, expandable }) => {
    //Сформируем дерево отображаемых колонок заголовка
    const [displayTree, maxLevel] = buildDisplayTree(columnsDef, "", 1);
    //Вытянем дерево в удобные для рендеринга структуры
    const [displayLevels, displayLevelsColumns] = buildDisplayLevelsColumns(displayTree, maxLevel);
    //Сформируем отображаемые колонки данных
    const [displayDataColumns, displayDataColumnsCount] = buildDisplayDataColumns(displayTree, expandable);
    //Вернём результат
    return [displayLevels, displayLevelsColumns, displayDataColumns, displayDataColumnsCount];
};

//Формирование описания заголовка
const buildHeaderDef = ({ columnsDef, expandable, objectsCopier }) => {
    //Инициализируем результат
    const res = HEADER_INITIAL_STATE();
    //Инициализируем внутренне описание колонок и поместим его в результат
    columnsDef.forEach(columnDef => res.columnsDef.push(HEADER_COLUMN_INITIAL_STATE({ columnDef, objectsCopier })));
    //Добавим в результат сведения об отображаемых данных
    [res.displayLevels, res.displayLevelsColumns, res.displayDataColumns, res.displayDataColumnsCount] = buildDisplay({
        columnsDef: res.columnsDef,
        expandable
    });
    //Сформируем дерево отображаемых колонок заголовка
    //const [displayTree, maxLevel] = buildDisplayTree(res.columnsDef, "", 1);
    //Вытянем дерево в удобные для рендеринга структуры
    //[res.displayLevels, res.displayLevelsColumns] = buildDisplayLevelsColumns(displayTree, maxLevel);
    //Сформируем отображаемые колонки данных
    //[res.displayDataColumns, res.displayDataColumnsCount] = buildDisplayDataColumns(displayTree, expandable);
    //Вернём результат
    return res;
};

//-----------
//Тело модуля
//-----------

//Обработчики действий
const handlers = {
    //Формирование заголовка
    [P8P_TABLE_AT.SET_HEADER]: (state, { payload }) => {
        const { columnsDef, expandable, objectsCopier } = payload;
        return {
            ...state,
            ...buildHeaderDef({ columnsDef, expandable, objectsCopier })
        };
    },
    [P8P_TABLE_AT.TOGGLE_HEADER_EXPAND]: (state, { payload }) => {
        const { columnName, expandable, objectsCopier } = payload;
        const columnsDef = objectsCopier(state.columnsDef);
        columnsDef.forEach(columnDef => (columnDef.name == columnName ? (columnDef.expanded = !columnDef.expanded) : null));
        const [displayLevels, displayLevelsColumns, displayDataColumns, displayDataColumnsCount] = buildDisplay({
            columnsDef,
            expandable
        });
        //const [displayTree, maxLevel] = buildDisplayTree(columnsDef, "", 1);
        //const [displayLevels, displayLevelsColumns] = buildDisplayLevelsColumns(displayTree, maxLevel);
        //const [displayDataColumns, displayDataColumnsCount] = buildDisplayDataColumns(displayTree, expandable);
        return {
            ...state,
            columnsDef,
            displayLevels,
            displayLevelsColumns,
            displayDataColumns,
            displayDataColumnsCount
        };
    },
    //Обработчик по умолчанию
    DEFAULT: state => state
};

//----------------
//Интерфейс модуля
//----------------

//Константы
export { P8P_TABLE_AT, HEADER_INITIAL_STATE, hasValue };

//Редьюсер состояния
export const p8pTableReducer = (state, action) => {
    //Подберём обработчик
    const handle = handlers[action.type] || handlers.DEFAULT;
    //Исполним его
    return handle(state, action);
};

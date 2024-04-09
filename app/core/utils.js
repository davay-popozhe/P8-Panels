/*
    Парус 8 - Панели мониторинга
    Ядро: Вспомогательные функции
*/

//---------------------
//Подключение библиотек
//---------------------

import { XMLParser, XMLBuilder } from "fast-xml-parser"; //Конвертация XML в JSON и JSON в XML
import dayjs from "dayjs"; //Работа с датами

//---------
//Константы
//---------

//Коды типовых размеров экранов
const DISPLAY_SIZE_CODE = {
    XS: "XS", //eXtra Small - супер маленький экран
    SM: "SM", //Small - маленький экран
    MD: "MD", //Middle - средний экран
    LG: "LG" //Large - большой экран
};

//Типовые размеры экранов
const DISPLAY_SIZE = {
    [DISPLAY_SIZE_CODE.XS]: { WIDTH_FROM: 0, WIDTH_TO: 767 }, //eXtra Small - супер маленький экран < 768px
    [DISPLAY_SIZE_CODE.SM]: { WIDTH_FROM: 768, WIDTH_TO: 991 }, //Small - маленький экран >= 768px
    [DISPLAY_SIZE_CODE.MD]: { WIDTH_FROM: 992, WIDTH_TO: 1199 }, //Middle - средний экран >= 992px
    [DISPLAY_SIZE_CODE.LG]: { WIDTH_FROM: 1200, WIDTH_TO: 1000000 } //Large - большой экран >= 1200px
};

//Типовые пути конвертации в массив (при переводе XML -> JSON)
const XML_ALWAYS_ARRAY_PATHS = [
    "XRESPOND.XPAYLOAD.XOUT_ARGUMENTS",
    "XRESPOND.XPAYLOAD.XROWS",
    "XRESPOND.XPAYLOAD.XCOLUMNS_DEF",
    "XRESPOND.XPAYLOAD.XCOLUMNS_DEF.values",
    "XRESPOND.XPAYLOAD.XGROUPS",
    "XRESPOND.XPAYLOAD.XGANTT_DEF.taskAttributes",
    "XRESPOND.XPAYLOAD.XGANTT_DEF.taskColors",
    "XRESPOND.XPAYLOAD.XGANTT_TASKS",
    "XRESPOND.XPAYLOAD.XGANTT_TASKS.dependencies",
    "XRESPOND.XPAYLOAD.XCHART.labels",
    "XRESPOND.XPAYLOAD.XCHART.datasets",
    "XRESPOND.XPAYLOAD.XCHART.datasets.data",
    "XRESPOND.XPAYLOAD.XCHART.datasets.items"
];

//Типовые шаблоны конвертации в массив (при переводе XML -> JSON)
const XML_ALWAYS_ARRAY_PATH_PATTERNS = [
    /(.*)XROWS$/,
    /(.*)XCOLUMNS_DEF$/,
    /(.*)XCOLUMNS_DEF.values$/,
    /(.*)XGROUPS$/,
    /(.*)XGANTT_DEF.taskAttributes$/,
    /(.*)XGANTT_DEF.taskColors$/,
    /(.*)XGANTT_TASKS$/,
    /(.*)XGANTT_TASKS.dependencies$/,
    /(.*)XCHART.labels$/,
    /(.*)XCHART.datasets$/,
    /(.*)XCHART.datasets.data$/,
    /(.*)XCHART.datasets.items$/
];

//Типовой постфикс тега для массива (при переводе XML -> JSON)
const XML_ALWAYS_ARRAY_POSTFIX = "__SYSTEM__ARRAY__";

//Типовые шаблоны конвертации значения атрибута в строку (при переводе XML -> JSON)
const XML_ATTR_ALWAYS_STR_PATH_PATTERNS = [
    /(.*)XCOLUMNS_DEF.name$/,
    /(.*)XCOLUMNS_DEF.caption$/,
    /(.*)XCOLUMNS_DEF.parent$/,
    /(.*)XGROUPS.name$/,
    /(.*)XGROUPS.caption$/
];

//-----------
//Тело модуля
//-----------

//Проверка существования значения
const hasValue = value => typeof value !== "undefined" && value !== null && value !== "";

//Проверка типа устройства
const getDisplaySize = () => {
    let res = DISPLAY_SIZE_CODE.MD;
    Object.keys(DISPLAY_SIZE).map(dspl => {
        if (window.innerWidth >= DISPLAY_SIZE[dspl].WIDTH_FROM && window.innerWidth <= DISPLAY_SIZE[dspl].WIDTH_TO) res = dspl;
    });
    return res;
};

//Глубокое копирование объекта
const deepCopyObject = obj => JSON.parse(JSON.stringify(obj));

//Конвертация объекта в Base64 XML
const object2Base64XML = (obj, builderOptions) => {
    const builder = new XMLBuilder(builderOptions);
    //onOrderChanged({ orders: btoa(ordersBuilder.build(newOrders)) });
    return btoa(unescape(encodeURIComponent(builder.build(obj))));
};

//Конвертация XML в JSON
const xml2JSON = ({ xmlDoc, isArray, transformTagName, tagValueProcessor, attributeValueProcessor, useDefaultPatterns = true }) => {
    return new Promise((resolve, reject) => {
        try {
            let opts = {
                ignoreDeclaration: true,
                ignoreAttributes: false,
                parseAttributeValue: true,
                attributeNamePrefix: ""
            };
            if (useDefaultPatterns) {
                opts.isArray = (name, jPath, isLeafNode, isAttribute) =>
                    XML_ALWAYS_ARRAY_PATHS.indexOf(jPath) !== -1 ||
                    XML_ALWAYS_ARRAY_PATH_PATTERNS.some(pattern => pattern.test(jPath)) ||
                    jPath.endsWith(XML_ALWAYS_ARRAY_POSTFIX) ||
                    (isArray ? isArray(name, jPath, isLeafNode, isAttribute) : undefined);
                opts.attributeValueProcessor = (name, val, jPath) =>
                    XML_ATTR_ALWAYS_STR_PATH_PATTERNS.some(pattern => pattern.test(`${jPath}.${name}`))
                        ? undefined
                        : attributeValueProcessor
                        ? attributeValueProcessor(name, val, jPath)
                        : val;
            } else {
                if (isArray) opts.isArray = isArray;
                if (attributeValueProcessor) opts.attributeValueProcessor = attributeValueProcessor;
            }
            if (transformTagName) opts.transformTagName = transformTagName;
            if (tagValueProcessor) opts.tagValueProcessor = tagValueProcessor;
            const parser = new XMLParser(opts);
            resolve(parser.parse(xmlDoc));
        } catch (e) {
            reject(e);
        }
    });
};

//Форматирование даты в формат РФ
const formatDateRF = value => (value ? dayjs(value).format("DD.MM.YYYY") : null);

//Форматирование даты в формат JSON (только дата, без времени)
const formatDateJSONDateOnly = value => (value ? dayjs(value).format("YYYY-MM-DD") : null);

//Форматирование числа в "Денежном" формате РФ
const formatNumberRFCurrency = value => (hasValue(value) ? new Intl.NumberFormat("ru-RU", { minimumFractionDigits: 2 }).format(value) : null);

//Формирование уникального идентификатора
const genGUID = () =>
    "10000000-1000-4000-8000-100000000000".replace(/[018]/g, c =>
        (c ^ (crypto.getRandomValues(new Uint8Array(1))[0] & (15 >> (c / 4)))).toString(16)
    );

//----------------
//Интерфейс модуля
//----------------

export {
    hasValue,
    getDisplaySize,
    deepCopyObject,
    object2Base64XML,
    xml2JSON,
    formatDateRF,
    formatDateJSONDateOnly,
    formatNumberRFCurrency,
    genGUID
};

/*
    Парус 8 - Панели мониторинга
    Ядро: Вспомогательные функции
*/

//---------------------
//Подключение библиотек
//---------------------

import { XMLBuilder } from "fast-xml-parser"; //Конвертация XML в JSON и JSON в XML
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

//Форматирование даты в формат РФ
const formatDateRF = value => (value ? dayjs(value).format("DD.MM.YYYY") : null);

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

export { hasValue, getDisplaySize, deepCopyObject, object2Base64XML, formatDateRF, formatNumberRFCurrency, genGUID };

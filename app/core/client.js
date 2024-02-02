/*
    Парус 8 - Панели мониторинга
    Ядро: Клиент для взаимодействия с сервером приложений "Парус 8 Онлайн"
*/

//---------------------
//Подключение библиотек
//---------------------

import { XMLParser, XMLBuilder } from "fast-xml-parser"; //Конвертация XML в JSON и JSON в XML
import dayjs from "dayjs"; //Работа с датами
import config from "../../app.config"; //Настройки приложения

//---------
//Константы
//---------

//Коды функций сервера
const SRV_FN_CODE_EXEC_STORED = "EXEC_STORED"; //Код функции сервера "Запуск хранимой процедуры"

//Типы данных сервера
const SERV_DATA_TYPE_STR = "STR"; //Тип данных "строка"
const SERV_DATA_TYPE_NUMB = "NUMB"; //Тип данных "число"
const SERV_DATA_TYPE_DATE = "DATE"; //Тип данных "дата"
const SERV_DATA_TYPE_CLOB = "CLOB"; //Тип данных "текст"

//Состояния ответов сервера
const RESP_STATUS_OK = "OK"; //Успех
const RESP_STATUS_ERR = "ERR"; //Ошибка

//Типовые ошибки клиента
const ERR_APPSERVER = "Ошибка сервера приложений"; //Общая ошибка клиента
const ERR_UNEXPECTED = "Неожиданный ответ сервера"; //Неожиданный ответ сервера
const ERR_NETWORK = "Ошибка соединения с сервером"; //Ошибка сети

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

//Типовой постфикс тега для массива (при переводе XML -> JSON)
const XML_ALWAYS_ARRAY_POSTFIX = "__SYSTEM__ARRAY__";

//-----------
//Тело модуля
//-----------

//Определение типа данных значения аргумента
const getServerDataType = value => {
    let res = SERV_DATA_TYPE_STR;
    if (typeof value == "number") res = SERV_DATA_TYPE_NUMB;
    if (value instanceof Date) res = SERV_DATA_TYPE_DATE;
    return res;
};

//Формирование стандартного ответа - ошибка
const makeRespErr = ({ message }) => ({ SSTATUS: RESP_STATUS_ERR, SMESSAGE: message });

//Разбор XML
const parseXML = (xmlDoc, isArray, transformTagName, tagValueProcessor, attributeValueProcessor) => {
    return new Promise((resolve, reject) => {
        try {
            let opts = {
                ignoreDeclaration: true,
                ignoreAttributes: false,
                parseAttributeValue: true,
                attributeNamePrefix: ""
            };
            if (isArray) opts.isArray = isArray;
            if (transformTagName) opts.transformTagName = transformTagName;
            if (tagValueProcessor) opts.tagValueProcessor = tagValueProcessor;
            if (attributeValueProcessor) opts.attributeValueProcessor = attributeValueProcessor;
            const parser = new XMLParser(opts);
            resolve(parser.parse(xmlDoc));
        } catch (e) {
            reject(e);
        }
    });
};

//Формирование XML
const buildXML = jsonObj => {
    return new Promise((resolve, reject) => {
        try {
            const builder = new XMLBuilder({ ignoreAttributes: false, oneListGroup: true });
            resolve(builder.build(jsonObj));
        } catch (e) {
            reject(e);
        }
    });
};

//Проверка ответа на наличие ошибки
const isRespErr = resp => resp && resp?.SSTATUS && resp?.SSTATUS === RESP_STATUS_ERR;

//Извлечение ошибки из ответа
const getRespErrMessage = resp => (isRespErr(resp) && resp.SMESSAGE ? resp.SMESSAGE : "");

//Извлечение полезного содержимого из ответа
const getRespPayload = resp => (resp && resp.XPAYLOAD ? resp.XPAYLOAD : null);

//Исполнение действия на сервере
const executeAction = async ({ serverURL, action, payload = {}, isArray, transformTagName, tagValueProcessor, attributeValueProcessor } = {}) => {
    console.log(`EXECUTING ${action ? action : ""} ON ${serverURL} WITH PAYLOAD:`);
    console.log(payload ? payload : "NO PAYLOAD");
    let response = null;
    let responseJSON = null;
    try {
        //Сформируем типовой запрос
        const rqBody = {
            XREQUEST: { SACTION: action, XPAYLOAD: payload }
        };
        //Выполняем запрос
        response = await fetch(serverURL, {
            method: "POST",
            body: await buildXML(rqBody),
            headers: {
                "content-type": "application/xml"
            }
        });
    } catch (e) {
        //Сетевая ошибка
        throw new Error(`${ERR_NETWORK}: ${e.message}`);
    }
    //Проверим на наличие ошибок HTTP - если есть вернём их
    if (!response.ok) throw new Error(`${ERR_APPSERVER}: ${response.statusText}`);
    //Ошибок нет - пробуем разобрать
    try {
        let responseText = await response.text();
        //console.log("SERVER RESPONSE TEXT:");
        //console.log(responseText);
        responseJSON = await parseXML(responseText, isArray, transformTagName, tagValueProcessor, attributeValueProcessor);
    } catch (e) {
        //Что-то пошло не так при парсинге
        throw new Error(ERR_UNEXPECTED);
    }
    //Разобрали, проверяем структуру ответа на обязательные атрибуты
    if (
        !responseJSON?.XRESPOND ||
        !responseJSON?.XRESPOND?.SSTATUS ||
        ![RESP_STATUS_ERR, RESP_STATUS_OK].includes(responseJSON?.XRESPOND?.SSTATUS) ||
        (responseJSON?.XRESPOND?.SSTATUS === RESP_STATUS_OK && responseJSON?.XRESPOND?.XPAYLOAD == undefined) ||
        (responseJSON?.XRESPOND?.SSTATUS === RESP_STATUS_ERR && responseJSON?.XRESPOND?.SMESSAGE == undefined)
    )
        throw new Error(ERR_UNEXPECTED);
    //Всё хорошо - возвращаем (без корня, он не нужен)
    console.log("SERVER RESPONSE JSON:");
    console.log(responseJSON.XRESPOND);
    return responseJSON.XRESPOND;
};

//Запуск хранимой процедуры
const executeStored = async ({
    stored,
    args,
    respArg,
    isArray,
    tagValueProcessor,
    attributeValueProcessor,
    throwError = true,
    spreadOutArguments = false
} = {}) => {
    let res = null;
    try {
        let serverArgs = [];
        if (args)
            for (const arg in args) {
                let typedArg = false;
                if (args[arg] && Object.hasOwn(args[arg], "VALUE") && Object.hasOwn(args[arg], "SDATA_TYPE") && args[arg]?.SDATA_TYPE)
                    typedArg = true;
                const dataType = typedArg ? args[arg].SDATA_TYPE : getServerDataType(args[arg]);
                let value = typedArg ? args[arg].VALUE : args[arg];
                if (dataType === SERV_DATA_TYPE_DATE) value = dayjs(value).format("YYYY-MM-DDTHH:mm:ss");
                serverArgs.push({ XARGUMENT: { SNAME: arg, VALUE: value, SDATA_TYPE: dataType } });
            }
        res = await executeAction({
            serverURL: `${config.SYSTEM.SERVER}${!config.SYSTEM.SERVER.endsWith("/") ? "/" : ""}Process`,
            action: SRV_FN_CODE_EXEC_STORED,
            payload: { SSTORED: stored, XARGUMENTS: serverArgs, SRESP_ARG: respArg },
            isArray: (name, jPath) =>
                XML_ALWAYS_ARRAY_PATHS.indexOf(jPath) !== -1 || jPath.endsWith(XML_ALWAYS_ARRAY_POSTFIX) || (isArray ? isArray(name, jPath) : false),
            tagValueProcessor,
            attributeValueProcessor
        });
        if (spreadOutArguments === true && Array.isArray(res?.XPAYLOAD?.XOUT_ARGUMENTS)) {
            let spreadArgs = {};
            for (let arg of res.XPAYLOAD.XOUT_ARGUMENTS) spreadArgs[arg.SNAME] = arg.VALUE;
            delete res.XPAYLOAD.XOUT_ARGUMENTS;
            res.XPAYLOAD = { ...res.XPAYLOAD, ...spreadArgs };
        }
    } catch (e) {
        if (throwError) throw e;
        else return makeRespErr({ message: e.message });
    }
    if (res.SSTATUS === RESP_STATUS_ERR && throwError === true) throw new Error(res.SMESSAGE);
    return res;
};

//Чтение конфигурации плагина
const getConfig = async ({ throwError = true } = {}) => {
    let res = null;
    try {
        res = await executeAction({
            serverURL: `${config.SYSTEM.SERVER}${!config.SYSTEM.SERVER.endsWith("/") ? "/" : ""}GetConfig`
        });
    } catch (e) {
        if (throwError) throw e;
        else return makeRespErr({ message: e.message });
    }
    if (res.SSTATUS === RESP_STATUS_ERR && throwError === true) throw new Error(res.SMESSAGE);
    return res;
};

//----------------
//Интерфейс модуля
//----------------

export default {
    SERV_DATA_TYPE_STR,
    SERV_DATA_TYPE_NUMB,
    SERV_DATA_TYPE_DATE,
    SERV_DATA_TYPE_CLOB,
    isRespErr,
    getRespErrMessage,
    getRespPayload,
    executeStored,
    getConfig
};

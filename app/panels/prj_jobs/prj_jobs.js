/*
    Парус 8 - Панели мониторинга - ПУП - Работы проектов
    Панель мониторинга: Корневая панель работ проектов
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useContext, useState } from "react"; //Классы React
import Button from "@mui/material/Button"; //Кнопка
import Typography from "@mui/material/Typography"; //Текст
import { NavigationCtx } from "../../context/navigation"; //Контекст навигации
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { MessagingСtx } from "../../context/messaging"; //Контекст сообщений
import { ApplicationСtx } from "../../context/application"; //Контекст приложения

//-----------
//Тело модуля
//-----------

//Корневая панель работ проектов
const PrjJobs = () => {
    //Собственное состояние
    let [result, setResult] = useState("");

    //Подключение к контексту навигации
    const { navigateBack, navigateRoot, isNavigationState, getNavigationState, navigatePanelByName } = useContext(NavigationCtx);

    //Подключение к контексту взаимодействия с сервером
    const { executeStored } = useContext(BackEndСtx);

    //Подключение к контексту сообщений
    const { MSG_TYPE, showMsgErr, showMsgWarn, showMsgInfo, InlineMsg, InlineMsgErr, InlineMsgInfo, InlineMsgWarn } = useContext(MessagingСtx);

    //Подключение к контексту приложения
    const { pOnlineShowTab, pOnlineShowDocument, pOnlineShowDictionary, pOnlineUserProcedure, pOnlineUserReport } = useContext(ApplicationСtx);

    //Выполнение запроса к серверу
    const makeReq = async throwError => {
        try {
            const data = await executeStored({
                throwError,
                showErrorMessage: false,
                stored: "UDO_P_P8PANELS_TEST",
                args: { NRN: 123, SCODE: "123", DDATE: new Date() },
                respArg: "COUT",
                spreadOutArguments: false
            });
            setResult(JSON.stringify(data));
        } catch (e) {
            setResult("");
            showMsgErr(e.message);
        }
    };

    //Отображение закладки
    const openTab = () => {
        const id = pOnlineShowTab({ id: "123", url: "Modules/p8-panels/#/prj_fin", caption: "Экономика проектов", onClose: handleTabClose });
        if (id) console.log(`Открыта закладка ${id}`);
        else console.log("Закладка не открыта");
    };

    //При сокрытии закладки
    const handleTabClose = id => console.log(`Закрыта закладка ${id}`);

    //Генерация содержимого
    return (
        <div>
            <InlineMsg
                variant={MSG_TYPE.WARN}
                text="Просто сообщение, очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень очень длинное"
                onOk={() => console.log("INLINE MESSAGE ON OK")}
            />
            <InlineMsgInfo text="Информация" onOk={() => console.log("INLINE INFO ON OK")} />
            <InlineMsgWarn text="Предупреждение" onOk={() => console.log("INLINE WARN ON OK")} />
            <InlineMsgErr text="Ошибка" onOk={() => console.log("INLINE ERR ON OK")} />
            <h1>Это панель работ!</h1>
            <br />
            <h2>Параметры: {isNavigationState() ? JSON.stringify(getNavigationState()) : "НЕ ПЕРЕДАНЫ"}</h2>
            <br />
            <Button onClick={() => navigatePanelByName("PrjFin", { someDataFromJobs: 321 })}>В панель финансов</Button>
            <br />
            <Button onClick={navigateBack}>Назад</Button>
            <br />
            <Button onClick={() => navigateRoot()}>Домой</Button>
            <br />
            <Button onClick={navigateBack}>Назад</Button>
            <br />
            <Button onClick={() => navigateRoot()}>Домой</Button>
            <br />
            <Button onClick={openTab}>Открыть закладку</Button>
            <br />
            <Button onClick={() => makeReq(false)}>Без Exception</Button>
            <br />
            <Button onClick={() => makeReq(true)}>С Exception</Button>
            <br />
            <Button
                onClick={() =>
                    showMsgWarn(
                        "Вы уверены?",
                        () => showMsgInfo("Делаем"),
                        () => showMsgErr("Не делаем")
                    )
                }
            >
                ВОРНИНГ
            </Button>
            <br />
            <Typography variant="h4">RESULT: {result}</Typography>
            <br />
            <div className="row">
                <div className="col">
                    <input id="dictionaryData" />
                    <button
                        onClick={() =>
                            pOnlineShowDictionary({
                                unitCode: "OKATO",
                                inputParameters: [
                                    {
                                        name: "in_CODE",
                                        value: document.getElementById("dictionaryData").value
                                    }
                                ],
                                callBack: res => {
                                    console.log(res);
                                    if (res.success === true) document.getElementById("dictionaryData").value = res.outParameters.out_CODE;
                                }
                            })
                        }
                    >
                        ...
                    </button>
                    <button
                        onClick={() =>
                            pOnlineUserProcedure({
                                code: "UDO_P_AGNLIST_INSERT",
                                inputParameters: [
                                    {
                                        name: "SOKATO",
                                        value: document.getElementById("dictionaryData").value
                                    }
                                ],

                                callBack: res => {
                                    console.log(res);
                                }
                            })
                        }
                    >
                        Добавить
                    </button>
                    <button
                        onClick={() =>
                            pOnlineUserReport({
                                code: "Список событий",
                                inputParameters: [
                                    {
                                        name: "DDATE_FROM",
                                        value: new Date()
                                    },
                                    {
                                        name: "SPERSON",
                                        value: "Иванов"
                                    }
                                ]
                            })
                        }
                    >
                        Список событий
                    </button>
                    <button onClick={() => pOnlineShowDocument({ unitCode: "AGNLIST", document: 28904399 })}>Раздел - КА - ФФФ</button>
                </div>
            </div>
        </div>
    );
};

//----------------
//Интерфейс модуля
//----------------

export { PrjJobs };

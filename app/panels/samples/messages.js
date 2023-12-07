/*
    Парус 8 - Панели мониторинга - Примеры для разработчиков
    Пример: Сообщения
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useContext, useState } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Typography, Divider, Button } from "@mui/material"; //Интерфейсные элементы
import { MessagingСtx } from "../../context/messaging"; //Контекст сообщений

//---------
//Константы
//---------

//Стили
const STYLES = {
    CONTAINER: { textAlign: "center", paddingTop: "20px" },
    TITLE: { paddingBottom: "15px" },
    DIVIDER: { margin: "15px" }
};

//-----------
//Тело модуля
//-----------

//Пример: Сообщения
const Messages = ({ title }) => {
    //Собственное состояние
    const [state, setState] = useState({ inlineErr: true, inlineWarn: true, inlineInfo: true });

    //Подключение к контексту сообщений
    const { showMsgErr, showMsgWarn, showMsgInfo, InlineMsgErr, InlineMsgInfo, InlineMsgWarn } = useContext(MessagingСtx);

    //Генерация содержимого
    return (
        <div style={STYLES.CONTAINER}>
            <Typography sx={STYLES.TITLE} variant={"h6"}>
                {title}
            </Typography>
            {/* Сообщение об ошибке (диалог) */}
            <Button variant="contained" onClick={() => showMsgErr("Что-то пошло не так :(")}>
                Ошибка
            </Button>
            <Divider sx={STYLES.DIVIDER} />
            {/* Предупреждение (диалог) */}
            <Button
                variant="contained"
                onClick={() =>
                    showMsgWarn(
                        "Вы уверены?",
                        () => showMsgInfo("Делаем!"),
                        () => showMsgErr("Не делаем :(")
                    )
                }
            >
                Предупреждение
            </Button>
            <Divider sx={STYLES.DIVIDER} />
            {/* Информация (диалог) */}
            <Button variant="contained" onClick={() => showMsgInfo("Ценная информация...")}>
                Информация
            </Button>
            <Divider sx={STYLES.DIVIDER} />
            {/* Ошибка (встраиваемое) */}
            {state.inlineErr ? (
                <>
                    <InlineMsgErr text="Ошибка" onOk={() => setState(pv => ({ ...pv, inlineErr: false }))} />
                    <Divider sx={STYLES.DIVIDER} />
                </>
            ) : null}
            {/* Предупреждение (встраиваемое) */}
            {state.inlineWarn ? (
                <>
                    <InlineMsgWarn text="Предупреждение" onOk={() => setState(pv => ({ ...pv, inlineWarn: false }))} />
                    <Divider sx={STYLES.DIVIDER} />
                </>
            ) : null}
            {/* Информация (встраиваемое) */}
            {state.inlineInfo ? <InlineMsgInfo text="Информация" onOk={() => setState(pv => ({ ...pv, inlineInfo: false }))} /> : null}
        </div>
    );
};

//Контроль свойств - Пример: Сообщения
Messages.propTypes = {
    title: PropTypes.string.isRequired
};

//----------------
//Интерфейс модуля
//----------------

export { Messages };

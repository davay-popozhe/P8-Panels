/*
    Парус 8 - Панели мониторинга - Примеры для разработчиков
    Панель мониторинга: Примеры для разработчиков
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState } from "react"; //Классы React
import { Button, Fab, Icon } from "@mui/material"; //Интерфейсные элементы
import { BUTTONS } from "../../../app.text"; //Текстовые ресурсы и константы
import { P8Online } from "./p8online"; //Пример: API для взаимодействия с "ПАРУС 8 Онлайн"
import { Mui } from "./mui"; //Пример: Компоненты MUI
import { Messages } from "./messages"; //Пример: Сообщения
import { Loader } from "./loader"; //Пример: Индикатор процесса

//---------
//Константы
//---------

//Режимы
const MODES = {
    P8ONLINE: { name: "P8ONLINE", caption: 'API для взаимодействия с "ПАРУС 8 Онлайн"', component: P8Online },
    MUI: { name: "MUI", caption: "Компоненты MUI", component: Mui },
    MESSAGES: { name: "MESSAGES", caption: "Сообщения", component: Messages },
    LOADER: { name: "LOADER", caption: "Индикатор процесса", component: Loader }
};

//Стили
const STYLES = {
    CONTAINER: { textAlign: "center", paddingTop: "20px" },
    BACK_BUTTON: { position: "absolute", left: "20px", marginTop: "20px" }
};

//-----------
//Тело модуля
//-----------

//Примеры
const Samples = () => {
    //Собственное состояние
    const [mode, setMode] = useState("");

    //Генерация содержимого
    return (
        <div>
            {mode ? (
                <div>
                    <Fab variant="extended" sx={STYLES.BACK_BUTTON} onClick={() => setMode("")}>
                        <Icon>arrow_back_ios</Icon>
                        {BUTTONS.NAVIGATE_BACK}
                    </Fab>
                    {React.createElement(MODES[mode]?.component || (() => {}), { title: MODES[mode]?.caption })}
                </div>
            ) : (
                <div style={STYLES.CONTAINER}>
                    {Object.entries(MODES).map(m => (
                        <div key={m[0]}>
                            <Button onClick={() => setMode(m[1].name)}>{m[1].caption}</Button>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
};

//----------------
//Интерфейс модуля
//----------------

export { Samples };

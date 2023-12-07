/*
    Парус 8 - Панели мониторинга - Примеры для разработчиков
    Пример: API для взаимодействия с "ПАРУС 8 Онлайн"
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useContext } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Typography, Button, Divider } from "@mui/material"; //Интерфейсные элементы
import { ApplicationСtx } from "../../context/application"; //Контекст приложения

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

//Пример: API для взаимодействия с "ПАРУС 8 Онлайн"
const P8Online = ({ title }) => {
    //Собственное состояние
    const [agent, setAgent] = useState("");

    //Подключение к контексту приложения
    const { pOnlineShowUnit, pOnlineShowTab, pOnlineShowDocument, pOnlineShowDictionary } = useContext(ApplicationСtx);

    //Генерация содержимого
    return (
        <div style={STYLES.CONTAINER}>
            <Typography sx={STYLES.TITLE} variant={"h6"}>
                {title}
            </Typography>
            {/* Открыть новую закладку */}
            <Button variant="contained" onClick={() => pOnlineShowTab({ caption: "PARUS.COM", url: "https://www.parus.com" })}>
                Открыть закладку
            </Button>
            <Divider sx={STYLES.DIVIDER} />
            {/* Открыть раздел */}
            <Button
                variant="contained"
                onClick={() => {
                    pOnlineShowUnit({
                        unitCode: "Contracts"
                    });
                }}
            >
                Открыть раздел Договоры
            </Button>
            <Divider sx={STYLES.DIVIDER} />
            {/* Открыть раздел в режиме словаря */}
            <Button
                variant="contained"
                onClick={() => {
                    pOnlineShowDictionary({
                        unitCode: "AGNLIST",
                        inputParameters: [
                            {
                                name: "in_AGNABBR",
                                value: agent
                            }
                        ],
                        callBack: res => (res.success === true ? setAgent(res.outParameters.out_AGNABBR) : null)
                    });
                }}
            >
                Выбрать контрагента
            </Button>
            {/* Позиционирование/отбор документа */}
            {agent ? (
                <>
                    <Divider sx={STYLES.DIVIDER} />
                    <Button
                        variant="contained"
                        onClick={() => {
                            pOnlineShowDocument({
                                unitCode: "AGNLIST",
                                document: agent,
                                inRnParameter: "in_AGNABBR"
                            });
                        }}
                    >{`Показать контрагента "${agent}"`}</Button>
                </>
            ) : null}
        </div>
    );
};

//Контроль свойств - Пример: API для взаимодействия с "ПАРУС 8 Онлайн"
P8Online.propTypes = {
    title: PropTypes.string.isRequired
};

//----------------
//Интерфейс модуля
//----------------

export { P8Online };

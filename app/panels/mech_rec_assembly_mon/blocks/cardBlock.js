/*
    Парус 8 - Панели мониторинга - ПУП - Мониторинг сборки изделий
    Панель мониторинга: Информация об объекте
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Typography, Box, ImageList, ImageListItem } from "@mui/material"; //Интерфейсные элементы
import { ProgressBox } from "../elements/progressBox"; //Блок информации по прогрессу объекта

//---------
//Константы
//---------

//Стили
const STYLES = {
    PLAN_INFO: {
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        flexDirection: "column",
        gap: "24px",
        border: "1px solid",
        borderRadius: "25px"
    }
};

//------------------------------------
//Вспомогательные функции и компоненты
//------------------------------------

//Картинка объекта
const CardImage = ({ card }) => {
    return (
        <Box width={180} height={180}>
            <ImageList variant="masonry" cols={1} gap={8}>
                <ImageListItem key={1}>
                    <img src={`data:image/png;base64,${card["#text"]}`} alt={"Image not loaded."} loading="lazy" width={180} />
                    {/* <img src={`./${airplaneImg}`} alt={"Image not loaded."} loading="lazy" width={180} /> */}
                </ImageListItem>
            </ImageList>
        </Box>
    );
};

//Контроль свойств - Заголовок первого уровня
CardImage.propTypes = {
    card: PropTypes.object
};

//-----------
//Тело модуля
//-----------

//Информация об объекте
const CardBlock = ({ card, handleCardClick }) => {
    return (
        <Box sx={STYLES.PLAN_INFO} onClick={() => handleCardClick(card)}>
            <CardImage card={card} />
            <Box textAlign="center">
                <Typography variant="UDO_body1" color="text.secondary.fontColor">
                    Номер борта
                </Typography>
                <Typography variant="h2">{card.SNUMB}</Typography>
            </Box>
            <ProgressBox
                prms={{
                    NPROGRESS: card.NPROGRESS,
                    SDETAIL: card.SDETAIL,
                    width: "155px",
                    height: "155px",
                    progressVariant: "h3",
                    detailVariant: "UDO_body2"
                }}
            />
            <Box>
                <Typography variant="UDO_body1" color="text.secondary.fontColor">
                    Год выпуска:
                </Typography>
                <Typography variant="subtitle1" mt={-1}>
                    {card.NYEAR}
                </Typography>
            </Box>
        </Box>
    );
};

//Контроль свойств - Заголовок первого уровня
CardBlock.propTypes = {
    card: PropTypes.object,
    handleCardClick: PropTypes.func
};

//----------------
//Интерфейс модуля
//----------------

export { CardBlock };

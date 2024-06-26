/*
    Парус 8 - Панели мониторинга - ПУП - Мониторинг сборки изделий
    Компонент: Элемент списка планов
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Typography, Box, ImageList, ImageListItem, Icon } from "@mui/material"; //Интерфейсные элементы
import { ProgressBox } from "./progress_box"; //Информация по прогрессу объекта

//---------
//Константы
//---------

//Стили
const STYLES = {
    CONTAINER: {
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        flexDirection: "column",
        gap: "24px",
        border: "1px solid",
        borderRadius: "25px",
        cursor: "pointer"
    },
    IMAGE_BOX: { width: "180px", height: "180px", alignItems: "center", justifyContent: "center", display: "flex" },
    IMAGE_LIST_ITEM: { textAlign: "center" },
    IMAGE_IMG: { width: "160px" }
};

//------------------------------------
//Вспомогательные функции и компоненты
//------------------------------------

//Изображение для элемента
const PlansListItemImage = ({ card }) => {
    return (
        <Box sx={STYLES.IMAGE_BOX}>
            <ImageList variant="masonry" cols={1} gap={8}>
                <ImageListItem key={1} sx={STYLES.IMAGE_LIST_ITEM}>
                    {card["BIMAGE"] ? (
                        <img src={`data:image/png;base64,${card["BIMAGE"]}`} loading="lazy" style={STYLES.IMAGE_IMG} />
                    ) : (
                        <Icon sx={{ fontSize: "5rem" }}>construction</Icon>
                    )}
                </ImageListItem>
            </ImageList>
        </Box>
    );
};

//Контроль свойств - Изображение для элемента
PlansListItemImage.propTypes = {
    card: PropTypes.object
};

//-----------
//Тело модуля
//-----------

//Элемент списка планов
const PlansListItem = ({ card, cardIndex, onClick }) => {
    return (
        <Box sx={STYLES.CONTAINER} onClick={() => (onClick ? onClick(card, cardIndex) : null)}>
            <PlansListItemImage card={card} />
            <Box textAlign="center">
                <Typography variant="UDO_body1" color="text.secondary.fontColor">
                    Номер борта
                </Typography>
                <Typography variant="h2">{card.SNUMB}</Typography>
            </Box>
            <ProgressBox
                progress={card.NPROGRESS}
                detail={card.SDETAIL}
                width={"155px"}
                height={"155px"}
                progressVariant={"h3"}
                detailVariant={"UDO_body2"}
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

//Контроль свойств - Элемент списка планов
PlansListItem.propTypes = {
    card: PropTypes.object,
    cardIndex: PropTypes.number,
    onClick: PropTypes.func
};

//----------------
//Интерфейс модуля
//----------------

export { PlansListItem };

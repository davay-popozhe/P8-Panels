/*
    Парус 8 - Панели мониторинга
    Компонент: Полноэкранный диалог
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Dialog, AppBar, Toolbar, IconButton, Typography, Icon, DialogContent, DialogTitle } from "@mui/material"; //Интерфейсные компоненты

//---------
//Константы
//---------

//Стили
const STYLES = {
    DIALOG_TITLE: { padding: 0 },
    APP_BAR: { position: "relative" },
    TITLE_TYPOGRAPHY: { ml: 2, flex: 1 }
};

//-----------
//Тело модуля
//-----------

//Полноэкранный диалог
const P8PFullScreenDialog = ({ title, onClose, children }) => {
    const handleClose = () => {
        onClose ? onClose() : null;
    };

    return (
        <Dialog fullScreen open onClose={handleClose} scroll="paper">
            <DialogTitle sx={STYLES.DIALOG_TITLE}>
                <AppBar sx={STYLES.APP_BAR}>
                    <Toolbar>
                        <IconButton edge="start" color="inherit" onClick={handleClose} aria-label="close">
                            <Icon>close</Icon>
                        </IconButton>
                        <Typography sx={STYLES.TITLE_TYPOGRAPHY} variant="h6" component="div">
                            {title}
                        </Typography>
                    </Toolbar>
                </AppBar>
            </DialogTitle>
            <DialogContent>{children}</DialogContent>
        </Dialog>
    );
};

//Контроль свойств - Полноэкранный диалог
P8PFullScreenDialog.propTypes = {
    title: PropTypes.string.isRequired,
    onClose: PropTypes.func,
    children: PropTypes.element
};

//----------------
//Интерфейс модуля
//----------------

export { P8PFullScreenDialog };

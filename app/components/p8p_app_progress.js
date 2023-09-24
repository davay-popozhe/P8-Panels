/*
    Парус 8 - Панели мониторинга
    Компонент: Индикатор процесса
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import Dialog from "@mui/material/Dialog"; //базовый класс диалога Material UI
import DialogTitle from "@mui/material/DialogTitle"; //Заголовок диалога
import DialogContent from "@mui/material/DialogContent"; //Содержимое диалога
import DialogContentText from "@mui/material/DialogContentText"; //Текст содержимого диалога
import LinearProgress from "@mui/material/LinearProgress"; //Индикатор

//-----------
//Тело модуля
//-----------

//Индикатора прогресса
const P8PAppProgress = props => {
    //Извлекаем необходимые свойства
    let { open, title, text } = props;

    //Генерация содержимого
    return (
        <div>
            <Dialog open={open || false} aria-labelledby="progress-dialog-title" aria-describedby="progress-dialog-description">
                {title ? <DialogTitle id="progress-dialog-title">{title}</DialogTitle> : null}
                <DialogContent>
                    <DialogContentText id="progress-dialog-description">{text}</DialogContentText>
                    <LinearProgress />
                </DialogContent>
            </Dialog>
        </div>
    );
};

//Контроль свойств - Индикатора прогресса
P8PAppProgress.propTypes = {
    open: PropTypes.bool,
    title: PropTypes.string,
    text: PropTypes.string.isRequired
};

//----------------
//Интерфейс модуля
//----------------

export { P8PAppProgress };

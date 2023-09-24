/*
    Парус 8 - Панели мониторинга
    Компонент: Сообщение
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
import DialogActions from "@mui/material/DialogActions"; //Область действий диалога
import Typography from "@mui/material/Typography"; //Текст
import Button from "@mui/material/Button"; //Кнопки
import Container from "@mui/material/Container"; //Контейнер
import Box from "@mui/material/Box"; //Обёртка

//---------
//Константы
//---------

//Варианты исполнения
const P8P_APP_MESSAGE_VARIANT = {
    INFO: "information",
    WARN: "warning",
    ERR: "error"
};

//Стили
const STYLES = {
    DEFAULT: {
        wordBreak: "break-word"
    },
    INFO: {
        titleText: {},
        bodyText: {}
    },
    WARN: {
        titleText: {
            color: "orange"
        },
        bodyText: {
            color: "orange"
        }
    },
    ERR: {
        titleText: {
            color: "red"
        },
        bodyText: {
            color: "red"
        }
    },
    INLINE_MESSAGE: {
        with: "100%",
        textAlign: "center"
    }
};

//-----------
//Тело модуля
//-----------

//Сообщение
const P8PAppMessage = ({ variant, title, titleText, cancelBtn, onCancel, cancelBtnCaption, okBtn, onOk, okBtnCaption, open, text }) => {
    //Подбор стиля и ресурсов
    let style = STYLES.INFO;
    switch (variant) {
        case P8P_APP_MESSAGE_VARIANT.INFO: {
            style = STYLES.INFO;
            break;
        }
        case P8P_APP_MESSAGE_VARIANT.WARN: {
            style = STYLES.WARN;
            break;
        }
        case P8P_APP_MESSAGE_VARIANT.ERR: {
            style = STYLES.ERR;
            break;
        }
    }

    //Заголовок
    let titlePart;
    if (title && titleText)
        titlePart = (
            <DialogTitle id="message-dialog-title" style={{ ...style.DEFAULT, ...style.titleText }}>
                {titleText}
            </DialogTitle>
        );

    //Кнопка Отмена
    let cancelBtnPart;
    if (cancelBtn && cancelBtnCaption && variant === P8P_APP_MESSAGE_VARIANT.WARN)
        cancelBtnPart = <Button onClick={() => (onCancel ? onCancel() : null)}>{cancelBtnCaption}</Button>;

    //Кнопка OK
    let okBtnPart;
    if (okBtn && okBtnCaption)
        okBtnPart = (
            <Button onClick={() => (onOk ? onOk() : null)} color="primary" autoFocus>
                {okBtnCaption}
            </Button>
        );

    //Все действия
    let actionsPart;
    if (cancelBtnPart || okBtnPart)
        actionsPart = (
            <DialogActions>
                {okBtnPart}
                {cancelBtnPart}
            </DialogActions>
        );

    //Генерация содержимого
    return (
        <Dialog
            open={open || false}
            aria-labelledby="message-dialog-title"
            aria-describedby="message-dialog-description"
            onClose={() => (onCancel ? onCancel() : null)}
        >
            {titlePart}
            <DialogContent>
                <DialogContentText id="message-dialog-description" style={style.bodyText}>
                    {text}
                </DialogContentText>
            </DialogContent>
            {actionsPart}
        </Dialog>
    );
};

//Контроль свойств - Сообщение
P8PAppMessage.propTypes = {
    variant: PropTypes.string.isRequired,
    title: PropTypes.bool,
    titleText: PropTypes.string,
    cancelBtn: PropTypes.bool,
    onCancel: PropTypes.func,
    cancelBtnCaption: PropTypes.string,
    okBtn: PropTypes.bool,
    onOk: PropTypes.func,
    okBtnCaption: PropTypes.string,
    open: PropTypes.bool,
    text: PropTypes.string
};

//Встроенное сообщение
const P8PAppInlineMessage = ({ variant, text, okBtn, onOk, okBtnCaption }) => {
    //Генерация содержимого
    return (
        <Container style={STYLES.INLINE_MESSAGE}>
            <Box p={5}>
                <Typography
                    color={variant === P8P_APP_MESSAGE_VARIANT.ERR ? "error" : variant === P8P_APP_MESSAGE_VARIANT.WARN ? "primary" : "textSecondary"}
                >
                    {text}
                </Typography>
                {okBtn && okBtnCaption ? (
                    <Box pt={2}>
                        <Button onClick={() => (onOk ? onOk() : null)} color="primary" autoFocus>
                            {okBtnCaption}
                        </Button>
                    </Box>
                ) : null}
            </Box>
        </Container>
    );
};

//Контроль свойств - Встроенное сообщение
P8PAppInlineMessage.propTypes = {
    variant: PropTypes.string.isRequired,
    text: PropTypes.string.isRequired,
    okBtn: PropTypes.bool,
    onOk: PropTypes.func,
    okBtnCaption: PropTypes.string
};

//Формирование типового сообщения
const buildVariantMessage = (props, variant) => {
    //Извлекаем необходимые свойства
    let { open, titleText } = props;

    //Генерация содержимого
    return <P8PAppMessage {...props} variant={variant} open={open === undefined ? true : open} title={titleText ? true : false} okBtn={true} />;
};

//Формирование типового встроенного сообщения
const buildVariantInlineMessage = (props, variant) => {
    //Генерация содержимого
    return <P8PAppInlineMessage {...props} variant={variant} />;
};

//Сообщение об ошибке
const P8PAppMessageErr = props => buildVariantMessage(props, P8P_APP_MESSAGE_VARIANT.ERR);

//Сообщение предупреждения
const P8PAppMessageWarn = props => buildVariantMessage(props, P8P_APP_MESSAGE_VARIANT.WARN);

//Сообщение информации
const P8PAppMessageInfo = props => buildVariantMessage(props, P8P_APP_MESSAGE_VARIANT.INFO);

//Встраиваемое сообщение об ошибке
const P8PAppInlineError = props => buildVariantInlineMessage(props, P8P_APP_MESSAGE_VARIANT.ERR);

//Встраиваемое cообщение предупреждения
const P8PAppInlineWarn = props => buildVariantInlineMessage(props, P8P_APP_MESSAGE_VARIANT.WARN);

//Встраиваемое сообщение информации
const P8PAppInlineInfo = props => buildVariantInlineMessage(props, P8P_APP_MESSAGE_VARIANT.INFO);

//----------------
//Интерфейс модуля
//----------------

export {
    P8P_APP_MESSAGE_VARIANT,
    P8PAppMessage,
    P8PAppMessageErr,
    P8PAppMessageWarn,
    P8PAppMessageInfo,
    P8PAppInlineMessage,
    P8PAppInlineError,
    P8PAppInlineWarn,
    P8PAppInlineInfo
};

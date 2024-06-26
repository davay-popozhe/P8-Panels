/*
    Парус 8 - Панели мониторинга - РО - Редактор настройки регламентированного отчёта
    Панель мониторинга: Диалог добавления/исправления/удаления компонентов настройки регламентированного отчёта
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Dialog, DialogTitle, IconButton, Icon, DialogContent, Typography, DialogActions, Button } from "@mui/material"; //Интерфейсные компоненты
//import { MessagingСtx } from "../../context/messaging";
import { IUDFormTextField } from "./iud_form_text_filed"; //Кастомные строки ввода
import { STATUSES, STYLES } from "./layouts"; //Статусы и стили диалогового окна

//---------------
//Тело компонента
//---------------

const IUDFormDialog = props => {
    //Свойства компонента
    const {
        formOpen,
        closeForm,
        curStatus,
        curCode,
        curName,
        curColCode,
        curRowCode,
        btnOkClick,
        codeOnChange,
        nameOnChange,
        dictColumnClick,
        dictRowClick
    } = props;

    //Подключение к контексту сообщений
    //const { showMsgWarn } = useContext(MessagingСtx);

    //Формирование заголовка диалогового окна
    const formTitle = () => {
        switch (curStatus) {
            case STATUSES.CREATE:
                return "Добавление раздела";
            case STATUSES.EDIT:
                return "Исправление раздела";
            case STATUSES.DELETE:
                return "Удаление раздела";
            case STATUSES.COLUMNROW_CREATE:
                return "Добавление показателя раздела";
            case STATUSES.COLUMNROW_EDIT:
                return "Исправление показателя раздела";
            case STATUSES.COLUMNROW_DELETE:
                return "Удаление показателя раздела";
        }
    };

    //Отрисовка диалогового окна
    const renderSwitch = () => {
        var btnText = "";
        switch (curStatus) {
            case STATUSES.CREATE:
            case STATUSES.COLUMNROW_CREATE:
                btnText = "Добавить";
                break;
            case STATUSES.EDIT:
            case STATUSES.COLUMNROW_EDIT:
                btnText = "Исправить";
                break;
            case STATUSES.DELETE:
            case STATUSES.COLUMNROW_DELETE:
                btnText = "Удалить";
                break;
        }
        return <Button onClick={btnOkClick}>{btnText}</Button>;
    };

    return (
        <Dialog open={formOpen} onClose={closeForm}>
            <DialogTitle>{formTitle()}</DialogTitle>
            <IconButton
                aria-label="close"
                onClick={closeForm}
                sx={{
                    position: "absolute",
                    right: 8,
                    top: 8,
                    color: theme => theme.palette.grey[500]
                }}
            >
                <Icon>close</Icon>
            </IconButton>
            <DialogContent>
                {curStatus == STATUSES.DELETE || curStatus == STATUSES.COLUMNROW_DELETE ? (
                    curStatus == STATUSES.DELETE ? (
                        <Typography>Вы хотите удалить раздел {curName}?</Typography>
                    ) : (
                        <Typography>Вы хотите удалить показатель раздела {curName}?</Typography>
                    )
                ) : (
                    <div>
                        {curStatus != STATUSES.COLUMNROW_EDIT ? (
                            <IUDFormTextField elementCode="code" elementValue={curCode} labelText="Мнемокод" changeFunc={codeOnChange} />
                        ) : null}
                        <IUDFormTextField elementCode="name" elementValue={curName} labelText="Наименование" changeFunc={nameOnChange} />
                        {curStatus == STATUSES.COLUMNROW_CREATE ? (
                            <div>
                                <IUDFormTextField
                                    elementCode="row"
                                    elementValue={curRowCode}
                                    labelText="Строка"
                                    changeFunc={dictRowClick}
                                    withDictionary={true}
                                />
                                <IUDFormTextField
                                    elementCode="column"
                                    elementValue={curColCode}
                                    labelText="Графа"
                                    changeFunc={dictColumnClick}
                                    withDictionary={true}
                                />
                            </div>
                        ) : null}
                    </div>
                )}
            </DialogContent>
            <DialogActions sx={STYLES.PADDING_DIALOG_BUTTONS_RIGHT}>
                {renderSwitch()}
                <Button onClick={closeForm}>Отмена</Button>
            </DialogActions>
        </Dialog>
    );
};

//Контроль свойств - Диалог
IUDFormDialog.propTypes = {
    formOpen: PropTypes.bool.isRequired,
    closeForm: PropTypes.func.isRequired,
    curStatus: PropTypes.oneOf(Object.values(STATUSES).filter(x => typeof x === "number")),
    curCode: PropTypes.string,
    curName: PropTypes.string,
    curColCode: PropTypes.string,
    curRowCode: PropTypes.string,
    btnOkClick: PropTypes.func.isRequired,
    codeOnChange: PropTypes.func.isRequired,
    nameOnChange: PropTypes.func.isRequired,
    dictColumnClick: PropTypes.func.isRequired,
    dictRowClick: PropTypes.func.isRequired
};

//--------------------
//Интерфейс компонента
//--------------------

export { IUDFormDialog };

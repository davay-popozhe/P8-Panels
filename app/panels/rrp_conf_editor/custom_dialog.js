/*
    Кастомный Dialog
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Dialog, DialogTitle, IconButton, Icon, DialogContent, Typography, DialogActions, Button } from "@mui/material"; //Интерфейсные компоненты
import { CustomFormControl } from "./custom_form_control"; //Кастомные строки ввода
import { Statuses, STYLES } from "./layouts"; //Статусы и стили диалогового окна

//-----------
//Тело модуля
//-----------

const CustomDialog = props => {
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

    //Формирование заголовка диалогового окна
    const formTitle = () => {
        switch (curStatus) {
            case Statuses.CREATE:
                return "Добавление раздела";
            case Statuses.EDIT:
                return "Исправление раздела";
            case Statuses.DELETE:
                return "Удаление раздела";
            case Statuses.COLUMNROW_CREATE:
                return "Добавление показателя раздела";
            case Statuses.COLUMNROW_EDIT:
                return "Исправление показателя раздела";
            case Statuses.COLUMNROW_DELETE:
                return "Удаление показателя раздела";
        }
    };

    //Отрисовка диалогового окна
    const renderSwitch = () => {
        var btnText = "";
        switch (curStatus) {
            case Statuses.CREATE:
            case Statuses.COLUMNROW_CREATE:
                btnText = "Добавить";
                break;
            case Statuses.EDIT:
            case Statuses.COLUMNROW_EDIT:
                btnText = "Исправить";
                break;
            case Statuses.DELETE:
            case Statuses.COLUMNROW_DELETE:
                btnText = "Удалить";
                break;
        }
        return (
            <Button variant="contained" onClick={btnOkClick}>
                {btnText}
            </Button>
        );
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
                {curStatus == Statuses.DELETE || curStatus == Statuses.COLUMNROW_DELETE ? (
                    curStatus == Statuses.DELETE ? (
                        <Typography>Вы хотите удалить раздел {curName}?</Typography>
                    ) : (
                        <Typography>Вы хотите удалить показатель раздела {curName}?</Typography>
                    )
                ) : (
                    <div>
                        {curStatus != Statuses.COLUMNROW_EDIT ? (
                            <CustomFormControl elementCode="code" elementValue={curCode} labelText="Мнемокод" changeFunc={codeOnChange} />
                        ) : null}
                        <CustomFormControl elementCode="name" elementValue={curName} labelText="Наименование" changeFunc={nameOnChange} />
                        {curStatus == Statuses.COLUMNROW_CREATE ? (
                            <div>
                                <CustomFormControl
                                    elementCode="column"
                                    elementValue={curColCode}
                                    labelText="Графа"
                                    changeFunc={dictColumnClick}
                                    withDictionary={true}
                                />
                                <CustomFormControl
                                    elementCode="row"
                                    elementValue={curRowCode}
                                    labelText="Строка"
                                    changeFunc={dictRowClick}
                                    withDictionary={true}
                                />
                            </div>
                        ) : null}
                    </div>
                )}
            </DialogContent>
            <DialogActions sx={STYLES.PADDING_DIALOG_BUTTONS_RIGHT}>
                {renderSwitch()}
                <Button variant="contained" onClick={closeForm}>
                    Отмена
                </Button>
            </DialogActions>
        </Dialog>
    );
};

CustomDialog.propTypes = {
    formOpen: PropTypes.bool.isRequired,
    closeForm: PropTypes.func.isRequired,
    curStatus: PropTypes.oneOf(Object.values(Statuses).filter(x => typeof x === "number")),
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

//----------------
//Интерфейс модуля
//----------------

export { CustomDialog };

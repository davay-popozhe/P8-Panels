/*
    Парус 8 - Панели мониторинга - РО - Редактор настройки регламентированного отчёта
    Панель мониторинга: Диалог добавления/исправления/удаления компонентов настройки регламентированного отчёта
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useContext } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Dialog, DialogTitle, IconButton, Icon, DialogContent, Typography, DialogActions, Button } from "@mui/material"; //Интерфейсные компоненты
//import { MessagingСtx } from "../../context/messaging";
import { ApplicationСtx } from "../../context/application"; //Контекст приложения
import { IUDFormTextField } from "./iud_form_text_field"; //Кастомные строки ввода
import { STATUSES } from "./layouts"; //Статусы и стили диалогового окна

//---------
//Константы
//---------

//Стили
const STYLES = {
    DIALOG_ACTIONS: { justifyContent: "center" },
    CLOSE_BUTTON: {
        position: "absolute",
        right: 8,
        top: 8,
        color: theme => theme.palette.grey[500]
    }
};

//Выбор подразделения
// const selectInsDepartment = (showDictionary, callBack) => {
//     showDictionary({
//         unitCode: "INS_DEPARTMENT",
//         callBack: res => (res.success === true ? callBack(res.outParameters.out_CODE) : callBack(null))
//     });
// };

//Выбор строки
const selectRow = (showDictionary, callBack) => {
    showDictionary({
        unitCode: "RRPRow",
        callBack: res =>
            res.success === true
                ? callBack(res.outParameters.out_CODE, res.outParameters.out_RRPVERSION_CODE, res.outParameters.out_RRPVERSION)
                : callBack(null)
    });
    // pOnlineShowDictionary({
    //     unitCode: "RRPRow",
    //     callBack: res =>
    //         res.success === true
    //             ? setFormData(pv => ({
    //                   ...pv,
    //                   rowCode: res.outParameters.out_CODE,
    //                   rowVCode: res.outParameters.out_RRPVERSION_CODE,
    //                   rowVRn: res.outParameters.out_RRPVERSION
    //               }))
    //             : null
    // });
};

//Выбор графы
const selectColumn = (showDictionary, callBack) => {
    showDictionary({
        unitCode: "RRPColumn",
        callBack: res =>
            res.success === true
                ? callBack(res.outParameters.out_CODE, res.outParameters.out_RRPVERSION_CODE, res.outParameters.out_RRPVERSION)
                : callBack(null)
    });
    // pOnlineShowDictionary({
    //     unitCode: "RRPColumn",
    //     callBack: res =>
    //         res.success === true
    //             ? setFormData(pv => ({
    //                   ...pv,
    //                   colCode: res.outParameters.out_CODE,
    //                   colVCode: res.outParameters.out_RRPVERSION_CODE,
    //                   colVRn: res.outParameters.out_RRPVERSION
    //               }))
    //             : null
    // });
};

//---------------
//Тело компонента
//---------------

const IUDFormDialog = ({ initial, onOk, onCancel }) => {
    //Свойства компонента
    // const {
    //     formOpen,
    //     closeForm,
    //     curStatus,
    //     curCode,
    //     curName,
    //     curColCode,
    //     curRowCode,
    //     btnOkClick,
    //     codeOnChange,
    //     nameOnChange,
    //     dictColumnClick,
    //     dictRowClick

    // } = props;

    //Собственное состояние
    const [formData, setFormData] = useState({ ...initial });

    //Подключение к контексту сообщений
    //const { showMsgWarn } = useContext(MessagingСtx);

    //Подключение к контексту приложения
    const { pOnlineShowDictionary } = useContext(ApplicationСtx);

    //При закрытии диалога без изменений
    const handleCancel = () => (onCancel ? onCancel() : null);

    //При закрытии диалога с изменениями
    const handleOK = () => (onOk ? onOk(formData) : null);

    //Формирование заголовка диалогового окна
    const formTitle = () => {
        switch (formData.status) {
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
        switch (formData.status) {
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
        return <Button onClick={handleOK}>{btnText}</Button>;
    };

    return (
        <Dialog open onClose={handleCancel}>
            <DialogTitle>{formTitle()}</DialogTitle>
            <IconButton aria-label="close" onClick={handleCancel} sx={STYLES.CLOSE_BUTTON}>
                <Icon>close</Icon>
            </IconButton>
            <DialogContent>
                {formData.status == STATUSES.DELETE || formData.status == STATUSES.COLUMNROW_DELETE ? (
                    formData.status == STATUSES.DELETE ? (
                        <Typography>Вы хотите удалить раздел {formData.name}?</Typography>
                    ) : (
                        <Typography>Вы хотите удалить показатель раздела {formData.name}?</Typography>
                    )
                ) : (
                    <div>
                        {formData.status != STATUSES.COLUMNROW_EDIT ? (
                            <IUDFormTextField elementCode="code" elementValue={formData.code} labelText="Мнемокод" onChange={handleOK} />
                        ) : null}
                        <IUDFormTextField elementCode="name" elementValue={formData.name} labelText="Наименование" onChange={handleOK} />
                        {formData.status == STATUSES.COLUMNROW_CREATE ? (
                            <div>
                                <IUDFormTextField
                                    elementCode="row"
                                    elementValue={formData.rowCode}
                                    labelText="Строка"
                                    onChange={handleOK}
                                    dictionary={callBack => selectRow(pOnlineShowDictionary, callBack)}
                                />
                                <IUDFormTextField
                                    elementCode="column"
                                    elementValue={formData.colCode}
                                    labelText="Графа"
                                    onChange={handleOK}
                                    dictionary={callBack => selectColumn(pOnlineShowDictionary, callBack)}
                                />
                            </div>
                        ) : null}
                    </div>
                )}
            </DialogContent>
            <DialogActions sx={STYLES.PADDING_DIALOG_BUTTONS_RIGHT}>
                {renderSwitch()}
                <Button onClick={handleCancel}>Отмена</Button>
            </DialogActions>
        </Dialog>
    );
};

//Контроль свойств - Диалог
IUDFormDialog.propTypes = {
    initial: PropTypes.object.isRequired,
    onOk: PropTypes.func,
    onCancel: PropTypes.func
};

//--------------------
//Интерфейс компонента
//--------------------

export { IUDFormDialog };

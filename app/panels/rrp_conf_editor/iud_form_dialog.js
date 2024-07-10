/*
    Парус 8 - Панели мониторинга - РО - Редактор настройки регламентированного отчёта
    Панель мониторинга: Диалог добавления/исправления/удаления компонентов настройки регламентированного отчёта
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState, useContext, useCallback, useEffect } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Dialog, DialogTitle, IconButton, Icon, DialogContent, Typography, DialogActions, Button } from "@mui/material"; //Интерфейсные компоненты
import { ApplicationСtx } from "../../context/application"; //Контекст приложения
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { IUDFormTextField } from "./iud_form_text_field"; //Компонент поля ввода
import { STATUSES } from "./layouts"; //Статусы и стили диалогового окна

//---------
//Константы
//---------

//Стили
const STYLES = {
    CLOSE_BUTTON: {
        position: "absolute",
        right: 8,
        top: 8,
        color: theme => theme.palette.grey[500]
    },
    PADDING_DIALOG_BUTTONS_RIGHT: { paddingRight: "32px" }
};

//---------------
//Тело компонента
//---------------

const IUDFormDialog = ({ initial, onClose, onReload }) => {
    //Собственное состояние
    const [formData, setFormData] = useState({ ...initial });

    //Подключение к контексту приложения
    const { pOnlineShowDictionary } = useContext(ApplicationСtx);

    //Подключение к контексту взаимодействия с сервером
    const { executeStored } = useContext(BackEndСtx);

    //При закрытии диалога без изменений
    const handleCancel = () => (onClose ? onClose() : null);

    //При закрытии диалога с изменениями
    const handleOK = () => {
        if (onClose) {
            changeSections();
            onClose();
        } else null;
    };

    //Отработка добавления/изсправления/удаления элемента
    const handleReload = () => {
        if (onReload) {
            onReload();
        } else null;
    };

    //При изменении значения элемента
    const handleDialogItemChange = (item, value) => setFormData(pv => ({ ...pv, [item]: value }));

    //Отработка изменений в разделе или показателе раздела
    const changeSections = useCallback(async () => {
        switch (formData.status) {
            case STATUSES.CREATE:
                await insertSections();
                break;
            case STATUSES.EDIT:
                await updateSections();
                break;
            case STATUSES.DELETE:
                await deleteSections();
                break;
            case STATUSES.RRPCONFSCTNMRK_CREATE:
                await addRRPCONFSCTNMRK();
                break;
            case STATUSES.RRPCONFSCTNMRK_EDIT:
                await editRRPCONFSCTNMRK();
                break;
            case STATUSES.RRPCONFSCTNMRK_DELETE:
                await deleteRRPCONFSCTNMRK();
                break;
        }
        handleReload();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [formData]);

    //Добавление раздела
    const insertSections = useCallback(async () => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_RRPCONFED.RRPCONFSCTN_INSERT",
            args: {
                NPRN: formData.prn,
                SCODE: formData.code,
                SNAME: formData.name
            }
        });
        setFormData(pv => ({
            ...pv,
            rn: Number(data.NRN)
        }));
    }, [formData.prn, formData.code, formData.name, executeStored]);

    //Исправление раздела
    const updateSections = useCallback(async () => {
        await executeStored({
            stored: "PKG_P8PANELS_RRPCONFED.RRPCONFSCTN_UPDATE",
            args: {
                NRN: formData.rn,
                SCODE: formData.code,
                SNAME: formData.name
            }
        });
    }, [formData.name, formData.code, formData.rn, executeStored]);

    //Удаление раздела
    const deleteSections = useCallback(async () => {
        await executeStored({
            stored: "PKG_P8PANELS_RRPCONFED.RRPCONFSCTN_DELETE",
            args: {
                NRN: formData.rn
            }
        });
    }, [formData.rn, executeStored]);

    //Добавление показателя раздела
    const addRRPCONFSCTNMRK = useCallback(async () => {
        await executeStored({
            stored: "PKG_P8PANELS_RRPCONFED.RRPCONFSCTNMRK_INSERT",
            args: {
                NPRN: formData.prn,
                SCODE: formData.code,
                SNAME: formData.name,
                SCOLCODE: formData.colCode,
                SCOLVER: formData.colVCode,
                SROWCODE: formData.rowCode,
                SROWVER: formData.rowVCode
            }
        });
    }, [executeStored, formData.code, formData.colVCode, formData.colCode, formData.name, formData.prn, formData.rowCode, formData.rowVCode]);

    //Исправление показателя раздела
    const editRRPCONFSCTNMRK = useCallback(async () => {
        await executeStored({
            stored: "PKG_P8PANELS_RRPCONFED.RRPCONFSCTNMRK_UPDATE",
            args: { NRN: formData.rn, SNAME: formData.name }
        });
    }, [executeStored, formData.name, formData.rn]);

    //Удаление показателя раздела
    const deleteRRPCONFSCTNMRK = useCallback(async () => {
        await executeStored({ stored: "PKG_P8PANELS_RRPCONFED.RRPCONFSCTNMRK_DELETE", args: { NRN: formData.rn } });
    }, [executeStored, formData.rn]);

    //Формирование заголовка диалогового окна
    const formTitle = () => {
        switch (formData.status) {
            case STATUSES.CREATE:
                return "Добавление раздела";
            case STATUSES.EDIT:
                return "Исправление раздела";
            case STATUSES.DELETE:
                return "Удаление раздела";
            case STATUSES.RRPCONFSCTNMRK_CREATE:
                return "Добавление показателя раздела";
            case STATUSES.RRPCONFSCTNMRK_EDIT:
                return "Исправление показателя раздела";
            case STATUSES.RRPCONFSCTNMRK_DELETE:
                return "Удаление показателя раздела";
        }
    };

    //Отрисовка диалогового окна
    const renderSwitch = () => {
        var btnText = "";
        switch (formData.status) {
            case STATUSES.CREATE:
            case STATUSES.RRPCONFSCTNMRK_CREATE:
                btnText = "Добавить";
                break;
            case STATUSES.EDIT:
            case STATUSES.RRPCONFSCTNMRK_EDIT:
                btnText = "Исправить";
                break;
            case STATUSES.DELETE:
            case STATUSES.RRPCONFSCTNMRK_DELETE:
                btnText = "Удалить";
                break;
        }
        return (
            <Button
                onClick={() => {
                    handleOK({ formData });
                }}
            >
                {btnText}
            </Button>
        );
    };

    //Выбор строки
    const selectRow = (showDictionary, callBack) => {
        showDictionary({
            unitCode: "RRPRow",
            callBack: res => {
                if (res.success === true) {
                    callBack(res.outParameters.out_CODE, res.outParameters.out_RRPVERSION_CODE, res.outParameters.out_RRPVERSION);
                    setFormData(pv => ({
                        ...pv,
                        rowCode: res.outParameters.out_CODE,
                        rowVCode: res.outParameters.out_RRPVERSION_CODE,
                        rowVRn: res.outParameters.out_RRPVERSION
                    }));
                } else callBack(null);
            }
        });
    };

    //Выбор графы
    const selectColumn = (showDictionary, callBack) => {
        showDictionary({
            unitCode: "RRPColumn",
            callBack: res => {
                if (res.success === true) {
                    callBack(res.outParameters.out_CODE, res.outParameters.out_RRPVERSION_CODE, res.outParameters.out_RRPVERSION);
                    setFormData(pv => ({
                        ...pv,
                        colCode: res.outParameters.out_CODE,
                        colVCode: res.outParameters.out_RRPVERSION_CODE,
                        colVRn: res.outParameters.out_RRPVERSION
                    }));
                } else callBack(null);
            }
        });
    };

    //Получение мнемокода и наименования показателя раздела
    const getSctnMrkCodeName = useCallback(async () => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_RRPCONFED.RRPCONFSCTNMRK_GET_CODE_NAME",
            args: { SSCTNCODE: formData.sctnCode, SROWCODE: formData.rowCode, SCOLUMNCODE: formData.colCode }
        });
        setFormData(pv => ({
            ...pv,
            code: data.SCODE,
            name: data.SNAME
        }));
    }, [executeStored, formData.colCode, formData.rowCode, formData.sctnCode]);

    //Получение наименования и мнемокода показателя раздела при заполнении необходимых полей
    useEffect(() => {
        formData.status == STATUSES.RRPCONFSCTNMRK_CREATE && formData.sctnName && formData.sctnCode && formData.colCode && formData.rowCode
            ? getSctnMrkCodeName()
            : null;
    }, [formData.colCode, formData.rowCode, formData.sctnCode, formData.sctnName, formData.status, getSctnMrkCodeName]);

    //Генерация содержимого
    return (
        <Dialog open onClose={handleCancel}>
            <DialogTitle>{formTitle()}</DialogTitle>
            <IconButton aria-label="close" onClick={handleCancel} sx={STYLES.CLOSE_BUTTON}>
                <Icon>close</Icon>
            </IconButton>
            <DialogContent>
                {formData.status == STATUSES.DELETE || formData.status == STATUSES.RRPCONFSCTNMRK_DELETE ? (
                    formData.status == STATUSES.DELETE ? (
                        <Typography>Вы хотите удалить раздел {formData.name}?</Typography>
                    ) : (
                        <Typography>Вы хотите удалить показатель раздела {formData.name}?</Typography>
                    )
                ) : (
                    <div>
                        {formData.status != STATUSES.RRPCONFSCTNMRK_EDIT ? (
                            <IUDFormTextField
                                elementCode="code"
                                elementValue={formData.code}
                                labelText="Мнемокод"
                                onChange={handleDialogItemChange}
                            />
                        ) : null}
                        <IUDFormTextField
                            elementCode="name"
                            elementValue={formData.name}
                            labelText="Наименование"
                            onChange={handleDialogItemChange}
                        />
                        {formData.status == STATUSES.RRPCONFSCTNMRK_CREATE ? (
                            <div>
                                <IUDFormTextField
                                    elementCode="row"
                                    elementValue={formData.rowCode}
                                    labelText="Строка"
                                    onChange={handleDialogItemChange}
                                    dictionary={callBack => selectRow(pOnlineShowDictionary, callBack)}
                                />
                                <IUDFormTextField
                                    elementCode="column"
                                    elementValue={formData.colCode}
                                    labelText="Графа"
                                    onChange={handleDialogItemChange}
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
    onClose: PropTypes.func,
    onReload: PropTypes.func
};

//--------------------
//Интерфейс компонента
//--------------------

export { IUDFormDialog };

/*
    Парус 8 - Панели мониторинга - ПУП - Экономика проектов
    Дополнительная разметка и вёрстка клиентских элементов
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import { Icon, Stack, Link } from "@mui/material"; //Интерфейсные компоненты
import { formatDateRF } from "../../core/utils"; //Вспомогательные функции

//-----------
//Тело модуля
//-----------

//Формирование значения для колонки "Состояние" этапа
const formatStageStatusValue = value => {
    const [text, icon] =
        value == 0
            ? ["Зарегистрирован", "app_registration"]
            : value == 1
            ? ["Открыт", "lock_open"]
            : value == 2
            ? ["Закрыт", "lock_outline"]
            : value == 3
            ? ["Согласован", "thumb_up_alt"]
            : value == 4
            ? ["Исполнение прекращено", "block"]
            : ["Остановлен", "do_not_disturb_on"];
    return (
        <Stack direction="row" gap={0.5} alignItems="center">
            <Icon title={text}>{icon}</Icon>
            {text}
        </Stack>
    );
};

//Формирование значения для колонки "Состояние" работы
const formatJobStatusValue = (value, addText = false, justifyContent = null) => {
    const [text, icon] =
        value == 0
            ? ["Не начата", "not_started"]
            : value == 1
            ? ["Выполняется", "loop"]
            : value == 2
            ? ["Выполнена", "task_alt"]
            : value == 3
            ? ["Остановлена", "do_not_disturb_on"]
            : ["Отменена", "cancel"];
    return (
        <Stack direction="row" gap={0.5} alignItems="center" {...(justifyContent ? { justifyContent } : {})}>
            <Icon title={text}>{icon}</Icon>
            {addText == true ? text : null}
        </Stack>
    );
};

//Генерация кастомных представлений атрибутов задачи в редакторе
export const taskAttributeRenderer = ({ task, attribute }) => {
    switch (attribute.name) {
        case "type":
            return task.type === 1 ? "Этап проекта" : "Работа проекта";
        case "state":
            return task.type === 1 ? formatStageStatusValue(task[attribute.name]) : formatJobStatusValue(task[attribute.name], true);
        default:
            return null;
    }
};

//Форматирование значений колонок в таблице детализации трудоёмкости по графику
export const planJobsDtlValueFormatter = ({ value, columnDef }) => {
    switch (columnDef.name) {
        case "NJOB_STATE":
            return formatJobStatusValue(value, false, "center");
        case "DJOB_BEG":
        case "DJOB_END":
            return formatDateRF(value);
    }
    return value;
};

//Генерация представления ячейки заголовка в таблице детализации трудоёмкости по графику
export const planJobsDtlHeadCellRender = ({ columnDef }) => {
    switch (columnDef.name) {
        case "NJOB_STATE":
            return {
                stackProps: { justifyContent: "center" },
                cellProps: { align: "center" }
            };
    }
};

//Генерация представления ячейки c данными в таблице детализации трудоёмкости по графику
export const planJobsDtlDataCellRender = ({ row, columnDef, onProjectClick }) => {
    switch (columnDef.name) {
        case "SPRJ":
            return {
                data: row[columnDef.name] ? (
                    <Link
                        component="button"
                        variant="body2"
                        align="left"
                        underline="hover"
                        onClick={() => (onProjectClick ? onProjectClick({ sender: row }) : null)}
                    >
                        {row[columnDef.name]}
                    </Link>
                ) : (
                    row[columnDef.name]
                )
            };
    }
};

//Форматирование значений колонок в таблице детализации трудоёмкости по отчетам
export const factRptDtlValueFormatter = ({ value, columnDef }) => {
    switch (columnDef.name) {
        case "NJOB_STATE":
            return formatJobStatusValue(value, false, "center");
        case "DJOB_BEG":
        case "DJOB_END":
            return formatDateRF(value);
    }
    return value;
};

//Генерация представления ячейки заголовка в таблице детализации трудоёмкости по отчетам
export const factRptDtlHeadCellRender = ({ columnDef }) => {
    switch (columnDef.name) {
        case "NJOB_STATE":
            return {
                stackProps: { justifyContent: "center" },
                cellProps: { align: "center" }
            };
    }
};

//Генерация представления ячейки c данными в таблице периодов балансировки
export const periodsDataCellRender = ({ row, columnDef, onLabPlanFOTClick, onLabFactRptClick, onLabPlanJobsClick }) => {
    switch (columnDef.name) {
        case "NLAB_PLAN_FOT":
        case "NLAB_FACT_RPT":
        case "NLAB_PLAN_JOBS":
            return {
                data: row[columnDef.name] ? (
                    <Link
                        component="button"
                        variant="body2"
                        align="left"
                        underline="hover"
                        onClick={() =>
                            columnDef.name === "NLAB_PLAN_FOT"
                                ? onLabPlanFOTClick
                                    ? onLabPlanFOTClick({ sender: row })
                                    : null
                                : columnDef.name === "NLAB_FACT_RPT"
                                ? onLabFactRptClick
                                    ? onLabFactRptClick({ sender: row })
                                    : null
                                : columnDef.name === "NLAB_PLAN_JOBS"
                                ? onLabPlanJobsClick
                                    ? onLabPlanJobsClick({ sender: row })
                                    : null
                                : null
                        }
                    >
                        {row[columnDef.name]}
                    </Link>
                ) : (
                    row[columnDef.name]
                )
            };
        case "NLAB_DIFF_RPT_FOT":
            return { data: <div style={{ color: row[columnDef.name] <= 0 ? "green" : "red" }}>{row[columnDef.name]}</div> };
        case "NLAB_DIFF_JOBS_FOT":
            return {
                data: (
                    <Stack direction="row" gap={0.5} alignItems="center" justifyContent="right">
                        <div style={{ color: row[columnDef.name] <= 0 ? "green" : "red" }}>{row[columnDef.name]}</div>
                        <Icon sx={{ color: row[columnDef.name] <= 0 ? "green" : "red" }}>{row[columnDef.name] <= 0 ? "done" : "error"}</Icon>
                    </Stack>
                )
            };
    }
};

/*
    Парус 8 - Панели мониторинга - ПУП - Графики проектов
    Дополнительная разметка и вёрстка клиентских элементов
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import { Icon, Stack, Link } from "@mui/material"; //Интерфейсные компоненты
import { formatDateRF } from "../../core/utils"; //Вспомогательные процедуры и функции

//---------
//Константы
//---------

//Шаблон имени ячейки месяца
const MONTH_COLUMN_REG_EXP = /[0-9]{4}_[0-9]{1,2}/;

//Стили
const STYLES = {
    GROUP_CELL: { padding: "2px" },
    GROUP_CELL_LINK: { textOverflow: "ellipsis", overflow: "hidden", whiteSpace: "pre", minWidth: "800px", maxWidth: "800px" },
    MONTH_CELL: { padding: "2px", maxWidth: "30px", overflow: "visible", fontSize: "smaller", whiteSpace: "nowrap" },
    MONTH_CELL_FILLED: state => ({ backgroundColor: state == 0 ? "lightyellow" : state == 1 ? "lightgreen" : "lightblue", cursor: "pointer" }),
    JOB_CELL: {
        padding: "2px",
        paddingLeft: "10px",
        maxWidth: "300px",
        textOverflow: "ellipsis",
        overflow: "hidden",
        whiteSpace: "pre",
        fontSize: "smaller"
    }
};

//-----------
//Тело модуля
//-----------

//Формирование значения для плашки этапа
const formatStageItemValue = (state, text) => {
    const [stateText, icon] =
        state == 0
            ? ["Зарегистрирован", "app_registration"]
            : state == 1
            ? ["Открыт", "lock_open"]
            : state == 2
            ? ["Закрыт", "lock_outline"]
            : state == 3
            ? ["Согласован", "thumb_up_alt"]
            : state == 4
            ? ["Исполнение прекращено", "block"]
            : ["Остановлен", "do_not_disturb_on"];
    return (
        <Stack direction="row" gap={0.5} alignItems="center">
            <Icon title={stateText}>{icon}</Icon>
            {text}
        </Stack>
    );
};

//Генерация представления ячейки заголовка группы
export const groupCellRender = ({ group, pOnlineShowDocument }) => ({
    cellStyle: STYLES.GROUP_CELL,
    data: (
        <Link
            component="button"
            variant="body2"
            align="left"
            sx={STYLES.GROUP_CELL_LINK}
            title={group.caption}
            onClick={() => pOnlineShowDocument({ unitCode: "Projects", document: group.name })}
        >
            {group.caption}
        </Link>
    )
});

//Генерация представления ячейки c данными
export const dataCellRender = ({ row, columnDef, pOnlineShowDocument }) => {
    if (MONTH_COLUMN_REG_EXP.test(columnDef.name)) {
        const dF = new Date(row.DFROM);
        const dT = new Date(row.DTO);
        const [year, month] = columnDef.name.split("_");
        const mF = new Date(year, month - 1, 1);
        const mT = new Date(year, month, 0);
        let cellStyle = {};
        let cellProps = {};
        let data = null;
        if ((dF <= mF && dT >= mT) || (dF >= mF && dF <= mT) || (dT >= mF && dT <= mT)) {
            if (year == dF.getFullYear() && month == dF.getMonth() + 1) data = formatStageItemValue(row.NSTATE, row.SRESP);
            cellStyle = STYLES.MONTH_CELL_FILLED(row.NSTATE);
            cellProps = {
                title: `${formatDateRF(dF)} - ${formatDateRF(dT)}`,
                onClick: () => pOnlineShowDocument({ unitCode: "ProjectsStages", document: row.NRN })
            };
        }
        return {
            cellStyle: { ...STYLES.MONTH_CELL, ...cellStyle },
            cellProps,
            data
        };
    }
    switch (columnDef.name) {
        case "SJOB":
            return {
                cellProps: { title: row[columnDef.name] },
                cellStyle: STYLES.JOB_CELL
            };
    }
};

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
    cellStyle: { padding: "2px" },
    data: (
        <Link component="button" variant="body2" align="left" onClick={() => pOnlineShowDocument({ unitCode: "Projects", document: group.name })}>
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
            cellStyle = { backgroundColor: row.NSTATE == 0 ? "lightyellow" : row.NSTATE == 1 ? "lightgreen" : "lightblue", cursor: "pointer" };
            cellProps = {
                title: `${formatDateRF(dF)} - ${formatDateRF(dT)}`,
                onClick: () => pOnlineShowDocument({ unitCode: "ProjectsStages", document: row.NRN })
            };
        }
        return {
            cellStyle: { padding: "2px", maxWidth: "30px", overflow: "visible", fontSize: "smaller", whiteSpace: "nowrap", ...cellStyle },
            cellProps,
            data
        };
    }
    switch (columnDef.name) {
        case "SJOB":
            return {
                cellProps: { title: row[columnDef.name] },
                cellStyle: {
                    padding: "2px",
                    maxWidth: "300px",
                    textOverflow: "ellipsis",
                    overflow: "hidden",
                    whiteSpace: "pre",
                    fontSize: "smaller"
                }
            };
    }
};

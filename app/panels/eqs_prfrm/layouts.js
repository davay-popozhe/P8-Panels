/*
    Парус 8 - Панели мониторинга - ТОиР - Выполнение работ
    Дополнительная разметка и вёрстка клиентских элементов
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { createRef } from "react"; //Классы React
import { Grid, Stack } from "@mui/material";

//---------
//Константы
//---------

//Шаблон чисел и имён ячеек дат
export const DIGITS_REG_EXP = /\d+,?\d*/g;
export const MONTH_NAME_REG_EXP = /_\d{4}_\d{1,2}/;
export const DAY_NAME_REG_EXP = /_\d{4}_\d{1,2}_\d{1,2}/;

export const STYLES = {
    HIDE_CELL_STYLE: { display: "none" },
    HCR_MAIN_STYLE: { border: "1px solid rgba(0, 0, 0)", textAlign: "center" },
    HCR_DATE_STYLE: { padding: "5px", minWidth: "25px", maxWidth: "25px" },
    DCR_MAIN_STYLE: { padding: "2px", border: "1px solid rgba(0, 0, 0) !important", textAlign: "center" },
    DCR_OBJECT_INFO_STYLE: { textAlign: "right", fontWeight: "bold" },
    DCR_PLAN_CELL_STYLE: { cursor: "pointer", backgroundColor: "lightblue", border: "1px solid rgba(0, 0, 0) !important" },
    DCR_FACT_RELATED_CELL_STYLE: { cursor: "pointer", backgroundColor: "green", border: "1px solid rgba(0, 0, 0) !important" },
    DCR_FACT_NOT_REALATED_CELL_STYLE: { cursor: "pointer", backgroundColor: "crimson", border: "1px solid rgba(0, 0, 0) !important" }
};

let curParent = "";
let x = 0;

//-----------
//Тело модуля
//-----------

const formatDate = date => {
    const [year, month, day] = date.substring(1).split("_");
    let nd;
    if (day == null) nd = `${month < 10 ? "0" + month : month}.${year}`;
    else nd = `${day < 10 ? "0" + day : day}.${month < 10 ? "0" + month : month}.${year}`;
    return nd;
};

export const headCellRender = ({ columnDef }, hClick) => {
    let cellStyle = STYLES.HCR_MAIN_STYLE; //{ border: "1px solid rgba(0, 0, 0)", textAlign: "center" };
    let cellProps = {};
    let stackStyle = {};
    let data = columnDef.caption;
    if (columnDef.expandable) {
        const ref = createRef();
        cellStyle = { ...cellStyle, padding: "5px" };
        cellProps = {
            ...cellProps,
            ref: ref,
            onClick: e => {
                hClick(e, ref);
            }
        };
        stackStyle = { flexDirection: "column" };
    }
    if (columnDef.name == "SOBJINFO" || columnDef.name == "SWRKTYPE") cellStyle = STYLES.HIDE_CELL_STYLE; //{ display: "none" };
    if (columnDef.name == "SINFO" || columnDef.name == "SWRKTYPE") {
        cellProps = { colSpan: 2 };
        if (columnDef.name == "SINFO") cellProps = { ...cellProps, rowSpan: 2 };
    }
    //if (columnDef.name == "SWRKTYPE") cellStyle = STYLES.HIDE_CELL_STYLE; //{ display: "none" };
    if (columnDef.visible && DAY_NAME_REG_EXP.test(columnDef.name)) {
        cellStyle = { ...cellStyle, ...STYLES.HCR_DATE_STYLE }; //{ ...cellStyle, padding: "5px", minWidth: "25px", maxWidth: "25px" };
        stackStyle = { justifyContent: "center" };
    }
    return { cellStyle, cellProps, stackStyle, data };
};

export const dataCellRender = ({ row, columnDef }, showEquipSrv) => {
    let cellStyle = STYLES.DCR_MAIN_STYLE; /*{
        padding: "2px",
        border: "1px solid rgba(0, 0, 0) !important",
        textAlign: "center"
    };*/
    let cellProps = {};
    let data = " ";
    if (row["SWRKTYPE"] == undefined) {
        if (columnDef.name == "SOBJINFO") {
            cellProps = { colSpan: 2 };
            cellStyle = { ...cellStyle, ...STYLES.DCR_OBJECT_INFO_STYLE }; //{ ...cellStyle, textAlign: "right", fontWeight: "bold" };
        }
        if (columnDef.name == "SWRKTYPE") cellStyle = STYLES.HIDE_CELL_STYLE; //{ display: "none" };
        if (columnDef.parent == "" && columnDef.expandable == true && columnDef.expanded == false) {
            curParent = columnDef.name;
            return { cellStyle: { ...cellStyle, height: "25px" }, data };
        } else if (columnDef.name != "SWRKTYPE" && columnDef.parent != "" && columnDef.expandable == false && columnDef.expanded == true) {
            if (columnDef.name.endsWith("_1")) {
                curParent = columnDef.parent;
                const [year, month] = curParent.substring(1).split("_");
                x = new Date(year, month, 0).getDate();
                cellProps = { colSpan: x };
                data = row[curParent];
                return { cellStyle, cellProps, data };
            } else {
                cellStyle = { display: "none" };
            }
        }
    }
    if (columnDef.name == "SOBJINFO" && row["SWRKTYPE"] == "План") {
        cellStyle = { ...cellStyle };
        cellProps = { rowSpan: 2 };
    }
    if (columnDef.name == "SOBJINFO" && row["SWRKTYPE"] == "Факт") {
        cellStyle = { display: "none" };
    }
    switch (row[columnDef.name]) {
        case "blue":
            cellStyle = { ...cellStyle, ...STYLES.DCR_PLAN_CELL_STYLE }; //{ ...cellStyle, cursor: "pointer", backgroundColor: "lightblue", border: "1px solid rgba(0, 0, 0) !important" };
            cellProps = {
                title: formatDate(columnDef.name),
                onClick: () => {
                    showEquipSrv({ date: columnDef.name, workType: row["SWRKTYPE"], info: row["groupName"] });
                }
            };
            return { cellStyle, cellProps, data };
        case "green":
            cellStyle = { ...cellStyle, ...STYLES.DCR_FACT_RELATED_CELL_STYLE }; //{ ...cellStyle, cursor: "pointer", backgroundColor: "green", border: "1px solid rgba(0, 0, 0) !important" };
            cellProps = {
                title: formatDate(columnDef.name),
                onClick: () => {
                    showEquipSrv({ date: columnDef.name, workType: row["SWRKTYPE"], info: row["groupName"] });
                }
            };
            return { cellStyle, cellProps, data };
        case "red":
            cellStyle = { ...cellStyle, ...STYLES.DCR_FACT_NOT_RELATED_CELL_STYLE }; //{ ...cellStyle, cursor: "pointer", backgroundColor: "crimson", border: "1px solid rgba(0, 0, 0) !important" };
            cellProps = {
                title: formatDate(columnDef.name),
                onClick: () => {
                    showEquipSrv({ date: columnDef.name, workType: row["SWRKTYPE"], info: row["groupName"] });
                }
            };
            return { cellStyle, cellProps, data };
        case "green red":
        case "red green":
            cellStyle = { ...cellStyle, padding: "unset" };
            cellProps = { title: formatDate(columnDef.name) };
            data = (
                <Stack sx={{ justifyContent: "center" }} direction="row">
                    <Grid container maxHeight="100%">
                        <Grid
                            item
                            xs={6}
                            sx={{ cursor: "pointer", backgroundColor: "green" }}
                            onClick={() => showEquipSrv({ date: columnDef.name, workType: row["SWRKTYPE"], info: row["groupName"] })}
                        >
                            <p style={{ display: "none" }}>g</p>
                        </Grid>
                        <Grid
                            item
                            xs={6}
                            sx={{ cursor: "pointer", backgroundColor: "crimson" }}
                            onClick={() => showEquipSrv({ date: columnDef.name, workType: row["SWRKTYPE"], info: row["groupName"] })}
                        >
                            <p style={{ display: "none" }}>r</p>
                        </Grid>
                    </Grid>
                </Stack>
            );
    }
    return { cellStyle, cellProps };
};

export const groupCellRender = () => {
    let cellStyle = STYLES.HIDE_CELL_STYLE; //{ display: "none" };
    return { cellStyle };
};

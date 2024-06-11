/*
    Парус 8 - 
    Дополнительная разметка и вёрстка клиентских элементов
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import { Stack, IconButton, Icon, Typography } from "@mui/material"; //Интерфейсные компоненты

//---------
//Константы
//---------

export const STYLES = {
    DIALOG_WINDOW_WIDTH: { width: 400 },
    PADDING_DIALOG_BUTTONS_RIGHT: { paddingRight: "32px" }
};

//Статусы диалогового окна
export const Statuses = { CREATE: 0, EDIT: 1, DELETE: 2, COLUMNROW_CREATE: 3, COLUMNROW_EDIT: 4, COLUMNROW_DELETE: 5 };

//-----------
//Тело модуля
//-----------

//Генерация представления ячейки c данными
export const dataCellRender = ({ row, columnDef }, editCR, deleteCR) => {
    let data = row[columnDef.name];
    columnDef.name != "SROW_NAME" && data != undefined && columnDef.visible == true
        ? (data = (
              <Stack direction="row">
                  <Typography width="-webkit-fill-available">{row[columnDef.name]}</Typography>
                  <IconButton justifyContent="flex-end" onClick={() => editCR(row["NRN_" + columnDef.name.substring(5)], row[columnDef.name])}>
                      <Icon>edit</Icon>
                  </IconButton>
                  <IconButton justifyContent="flex-end" onClick={() => deleteCR(row["NRN_" + columnDef.name.substring(5)], row[columnDef.name])}>
                      <Icon>delete</Icon>
                  </IconButton>
              </Stack>
          ))
        : null;
    return { data };
};

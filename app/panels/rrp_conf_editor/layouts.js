/*
    Парус 8 - Панели мониторинга - РО - Редактор настройки регламентированного отчёта
    Дополнительная разметка и вёрстка клиентских элементов
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import { Box, IconButton, Icon, Link } from "@mui/material"; //Интерфейсные компоненты

//---------
//Константы
//---------

//Стили
export const STYLES = {
    BOX_ROW: { display: "flex", justifyContent: "center", alignItems: "center" },
    LINK_STYLE: { component: "button", width: "-webkit-fill-available" }
};

//Статусы диалогового окна
export const STATUSES = { CREATE: 0, EDIT: 1, DELETE: 2, RRPCONFSCTNMRK_CREATE: 3, RRPCONFSCTNMRK_EDIT: 4, RRPCONFSCTNMRK_DELETE: 5 };

//-----------
//Тело модуля
//-----------

//Генерация представления ячейки c данными
export const dataCellRender = ({ row, columnDef }, showRrpConfSctnMrk, editCR, deleteCR) => {
    let data = row[columnDef.name];
    columnDef.name != "SROW_NAME" && data != undefined && columnDef.visible == true
        ? (data = (
              <Box sx={STYLES.BOX_ROW}>
                  <Link
                      sx={STYLES.LINK_STYLE}
                      onClick={() => {
                          showRrpConfSctnMrk(row["NRN_" + columnDef.name.substring(5)]);
                      }}
                  >
                      {row[columnDef.name]}
                  </Link>
                  <IconButton onClick={() => editCR(row["NRN_" + columnDef.name.substring(5)], row[columnDef.name])}>
                      <Icon>edit</Icon>
                  </IconButton>
                  <IconButton onClick={() => deleteCR(row["NRN_" + columnDef.name.substring(5)], row[columnDef.name])}>
                      <Icon>delete</Icon>
                  </IconButton>
              </Box>
          ))
        : null;
    return { data };
};

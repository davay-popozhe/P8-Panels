/*
    Парус 8 - Панели мониторинга - Примеры для разработчиков
    Пример: Компоненты MUI
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useEffect, useContext, useCallback, useState } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import { Typography, Grid, List, ListItemButton, ListItem, ListItemText, IconButton, Icon, Button, TextField, Box } from "@mui/material"; //Интерфейсные элементы
import { BackEndСtx } from "../../context/backend"; //Контекст взаимодействия с сервером
import { MessagingСtx } from "../../context/messaging"; //Контекст сообщений
import { ApplicationСtx } from "../../context/application"; //Контекст приложения

//---------
//Константы
//---------

//Стили
const STYLES = {
    CONTAINER: { textAlign: "center", paddingTop: "20px" },
    TITLE: { paddingBottom: "15px" },
    GRID_CONTAINER: { maxWidth: "500px" },
    GRID_TEM: { width: "100%" },
    LIST_CONTAINER: { marginTop: "10pt", maxHeight: "60vh", overflow: "auto", width: "100%" },
    LIST: { width: "100%", bgcolor: "background.paper" }
};

//-----------
//Тело модуля
//-----------

//Пример: Компоненты MUI
const Mui = ({ title }) => {
    //Собственное состояние - список контрагентов
    const [agents, setAgents] = useState([]);

    //Собственное состояние - форма добавления контрагента
    const [agentForm, setAgentForm] = useState({ agnAbbr: "", agnName: "" });

    //Подключение к контексту взаимодействия с сервером
    const { executeStored } = useContext(BackEndСtx);

    //Подключение к контексту сообщений
    const { showMsgWarn } = useContext(MessagingСtx);

    //Подключение к контексту приложения
    const { pOnlineShowDocument } = useContext(ApplicationСtx);

    //Загрузка списка контрагентов
    const agentsGet = useCallback(async () => {
        const data = await executeStored({
            stored: "PKG_P8PANELS_SAMPLES.AGNLIST_GET",
            respArg: "COUT"
        });
        setAgents([...data.AGENTS]);
    }, [executeStored]);

    //Добавление контрагента
    const agentInsert = useCallback(
        async (agnAbbr, agnName) => {
            await executeStored({
                stored: "PKG_P8PANELS_SAMPLES.AGNLIST_INSERT",
                args: {
                    SAGNABBR: agnAbbr,
                    SAGNNAME: agnName
                }
            });
            setAgentForm({ agnAbbr: "", agnName: "" });
            agentsGet();
        },
        [executeStored, agentsGet]
    );

    //Удаление контрагента
    const agentDelete = useCallback(
        async rn => {
            await executeStored({
                stored: "PKG_P8PANELS_SAMPLES.AGNLIST_DELETE",
                args: { NRN: rn }
            });
            agentsGet();
        },
        [executeStored, agentsGet]
    );

    //При нажатии на контрагента
    const handleAgnetClick = id => pOnlineShowDocument({ unitCode: "AGNLIST", document: id });

    //При добавлении контрагента
    const handleAgentInsert = () => agentInsert(agentForm.agnAbbr, agentForm.agnName);

    //При удалении контрагента
    const handleAgnetDeleteClick = id => showMsgWarn("Удалить контрагента?", () => agentDelete(id));

    //При вводе значения в форме
    const handleAgentFormChanged = e => {
        setAgentForm(pv => ({ ...pv, [e.target.name]: e.target.value }));
    };

    //При подключении компонента к странице
    useEffect(() => {
        agentsGet();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    //Генерация содержимого
    return (
        <div style={STYLES.CONTAINER}>
            <Typography sx={STYLES.TITLE} variant={"h6"}>
                {title}
            </Typography>
            <Box display="flex" justifyContent="center" alignItems="center">
                <Grid container spacing={0} direction="column" alignItems="center" justifyContent="center" sx={STYLES.GRID_CONTAINER}>
                    <Grid item xs={12} sx={STYLES.GRID_TEM}>
                        <TextField
                            name="agnAbbr"
                            label="Мнемокод"
                            value={agentForm.agnAbbr}
                            variant="standard"
                            fullWidth
                            onChange={handleAgentFormChanged}
                        />
                        <TextField
                            name="agnName"
                            label="Наименование"
                            value={agentForm.agnName}
                            variant="standard"
                            fullWidth
                            onChange={handleAgentFormChanged}
                        />
                        <Box pt="10px">
                            <Button onClick={handleAgentInsert} variant="contained" fullWidth>
                                Добавить контрагента
                            </Button>
                        </Box>
                    </Grid>
                    <Grid item xs={12} sx={STYLES.GRID_TEM}>
                        <Box sx={STYLES.LIST_CONTAINER}>
                            <List sx={STYLES.LIST}>
                                {agents.map(a => (
                                    <ListItem
                                        key={a.NRN}
                                        secondaryAction={
                                            <IconButton edge="end" title="Удалить контрагента" onClick={() => handleAgnetDeleteClick(a.NRN)}>
                                                <Icon>delete</Icon>
                                            </IconButton>
                                        }
                                        disablePadding
                                    >
                                        <ListItemButton onClick={() => handleAgnetClick(a.NRN)}>
                                            <ListItemText primary={a.SAGNABBR} secondary={a.SAGNNAME} />
                                        </ListItemButton>
                                    </ListItem>
                                ))}
                            </List>
                        </Box>
                    </Grid>
                </Grid>
            </Box>
        </div>
    );
};

//Контроль свойств - Пример: Компоненты MUI
Mui.propTypes = {
    title: PropTypes.string.isRequired
};

//----------------
//Интерфейс модуля
//----------------

export { Mui };

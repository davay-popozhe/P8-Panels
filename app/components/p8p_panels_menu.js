/*
    Парус 8 - Панели мониторинга
    Компонент: Меню панелей
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import {
    Button,
    Typography,
    Icon,
    Box,
    Card,
    CardActions,
    CardContent,
    CardMedia,
    Stack,
    Grid,
    Divider,
    List,
    ListItem,
    ListItemButton,
    ListItemIcon,
    ListItemText
} from "@mui/material"; //Интерфейсные компоненты

//---------
//Константы
//---------

//Типы меню
const P8P_PANELS_MENU_VARIANT = {
    DRAWER: "DRAWER",
    GRID: "GRID"
};

//Структура элемента описания панели
const P8P_PANELS_MENU_PANEL_SHAPE = PropTypes.shape({
    name: PropTypes.string.isRequired,
    caption: PropTypes.string.isRequired,
    desc: PropTypes.string.isRequired,
    group: PropTypes.string,
    icon: PropTypes.string.isRequired,
    path: PropTypes.string.isRequired,
    preview: PropTypes.string.isRequired,
    showInPanelsList: PropTypes.bool.isRequired,
    url: PropTypes.string.isRequired
});

//Стили
const STYLES = {
    CONTAINER: {
        display: "flex",
        justifyContent: "center",
        alignItems: "flex-start",
        minHeight: "100vh"
    },
    GRID: {
        maxWidth: 1200,
        direction: "row",
        justifyContent: "left",
        alignItems: "stretch"
    },
    PANEL_CARD: {
        maxWidth: 400,
        height: "100%",
        flexDirection: "column",
        display: "flex"
    },
    PANEL_CARD_MEDIA: {
        height: 140
    },
    PANEL_CARD_CONTENT_TITLE: {
        alignItems: "center"
    },
    PANEL_CARD_ACTIONS: {
        marginTop: "auto",
        display: "flex",
        justifyContent: "flex-end",
        alignItems: "flex-start"
    }
};

//--------------------------------
//Вспомогательные классы и функции
//--------------------------------

//Формирование групп
const getGroups = panels => {
    let res = [];
    let addDefaultGroup = false;
    for (const panel of panels)
        if (panel.showInPanelsList == true) {
            if (panel.group && !res.includes(panel.group)) res.push(panel.group);
            if (!panel.group) addDefaultGroup = true;
        }
    if (addDefaultGroup || res.length == 0) res.push(null);
    return res;
};

//Формирование ссылок на панели
const getPanelsLinks = ({ variant, panels, selectedPanel, defaultGroupTytle, navigateCaption, onItemNavigate }) => {
    //Получим группы
    let grps = getGroups(panels);

    //Построим ссылки
    const panelsLinks = [];
    for (const grp of grps) {
        if (!(grps.length == 1 && grps[0] == null))
            panelsLinks.push(
                variant === P8P_PANELS_MENU_VARIANT.GRID ? (
                    <Grid item xs={12} sm={12} md={12} lg={12} xl={12} key={grp}>
                        <Typography variant="h5" color="secondary">
                            {grp ? grp : defaultGroupTytle}
                        </Typography>
                    </Grid>
                ) : (
                    <Divider key={grp} />
                )
            );
        for (const panel of panels) {
            if (panel.showInPanelsList == true && ((grp && panel.group === grp) || (!grp && !panel.group)))
                panelsLinks.push(
                    variant === P8P_PANELS_MENU_VARIANT.GRID ? (
                        <Grid item xs={12} sm={6} md={4} lg={4} xl={4} key={panel.name}>
                            <Card sx={STYLES.PANEL_CARD}>
                                {panel.preview ? (
                                    <CardMedia component="img" alt={panel.name} image={panel.preview} sx={STYLES.PANEL_CARD_MEDIA} />
                                ) : null}
                                <CardContent>
                                    <Stack gap={1} direction="row" sx={STYLES.PANEL_CARD_CONTENT_TITLE}>
                                        {panel.icon ? <Icon>{panel.icon}</Icon> : null}
                                        <Typography variant="h5">{panel.caption}</Typography>
                                    </Stack>
                                    <Typography variant="body2" color="text.secondary">
                                        {panel.desc}
                                    </Typography>
                                </CardContent>
                                <CardActions sx={STYLES.PANEL_CARD_ACTIONS}>
                                    <Button size="large" onClick={() => (onItemNavigate ? onItemNavigate(panel) : null)}>
                                        {navigateCaption}
                                    </Button>
                                </CardActions>
                            </Card>
                        </Grid>
                    ) : (
                        <ListItem key={panel.name} disablePadding>
                            <ListItemButton
                                selected={selectedPanel?.name === panel.name}
                                onClick={() => (onItemNavigate ? onItemNavigate(panel) : null)}
                            >
                                <ListItemIcon>
                                    <Icon>{panel.icon}</Icon>
                                </ListItemIcon>
                                <ListItemText primary={panel.caption} />
                            </ListItemButton>
                        </ListItem>
                    )
                );
        }
    }

    //Вернём ссылки
    return panelsLinks;
};

//-----------
//Тело модуля
//-----------

//Меню панелей - сдвигающееся боковое меню
const P8PPanelsMenuDrawer = ({ onItemNavigate, panels = [], selectedPanel } = {}) => {
    //Формируем ссылки на панели
    const panelsLinks = getPanelsLinks({ variant: P8P_PANELS_MENU_VARIANT.DRAWER, panels, selectedPanel, onItemNavigate });

    //Генерация содержимого
    return <List sx={{ paddingTop: 0 }}>{panelsLinks}</List>;
};

//Контроль свойств - Меню панелей - сдвигающееся боковое меню
P8PPanelsMenuDrawer.propTypes = {
    onItemNavigate: PropTypes.func,
    panels: PropTypes.arrayOf(P8P_PANELS_MENU_PANEL_SHAPE).isRequired,
    selectedPanel: P8P_PANELS_MENU_PANEL_SHAPE
};

//Меню панелей - грид
const P8PPanelsMenuGrid = ({ onItemNavigate, navigateCaption, panels = [], defaultGroupTytle } = {}) => {
    //Формируем ссылки на панели
    const panelsLinks = getPanelsLinks({ variant: P8P_PANELS_MENU_VARIANT.GRID, panels, defaultGroupTytle, navigateCaption, onItemNavigate });

    //Генерация содержимого
    return (
        <Box sx={STYLES.CONTAINER}>
            <Grid container spacing={2} p={2} sx={STYLES.GRID}>
                {panelsLinks}
            </Grid>
        </Box>
    );
};

//Контроль свойств - Меню панелей - грид
P8PPanelsMenuGrid.propTypes = {
    onItemNavigate: PropTypes.func,
    navigateCaption: PropTypes.string.isRequired,
    panels: PropTypes.arrayOf(P8P_PANELS_MENU_PANEL_SHAPE).isRequired,
    defaultGroupTytle: PropTypes.string.isRequired
};

//----------------
//Интерфейс модуля
//----------------

export { P8P_PANELS_MENU_PANEL_SHAPE, P8PPanelsMenuDrawer, P8PPanelsMenuGrid };

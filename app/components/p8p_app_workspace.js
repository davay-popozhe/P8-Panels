/*
    Парус 8 - Панели мониторинга
    Компонент: Рабочее пространство
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import {
    AppBar,
    CssBaseline,
    Icon,
    Box,
    Toolbar,
    IconButton,
    Typography,
    Drawer,
    List,
    ListItemButton,
    ListItemIcon,
    ListItemText
} from "@mui/material"; //Интерфейсные компоненты
import { P8PPanelsMenuDrawer, P8P_PANELS_MENU_PANEL_SHAPE } from "./p8p_panels_menu";

//---------
//Константы
//---------

//Стили
const STYLES = {
    ROOT_BOX: { display: "flex" },
    APP_BAR: { position: "fixed" },
    APP_BAR_BUTTON: { mr: 2 },
    MAIN: { flexGrow: 1 }
};

//-----------
//Тело модуля
//-----------

//Рабочее пространство
const P8PAppWorkspace = ({ children, panels = [], selectedPanel, closeCaption, homeCaption, onHomeNavigate, onItemNavigate } = {}) => {
    //Собственное состояния
    const [open, setOpen] = useState(false);

    //Отработка открытия бокового меню
    const handleDrawerOpen = () => {
        setOpen(true);
    };

    //Отработка закрытия бового меню
    const handleDrawerClose = () => {
        setOpen(false);
    };

    //Отработка нажатия на домашнюю страницу
    const handleHomeClick = () => (onHomeNavigate ? onHomeNavigate() : null);

    //Отработка нажатия на элемент бокового меню
    const handleItemNavigate = panel => {
        handleDrawerClose();
        onItemNavigate ? onItemNavigate(panel) : null;
    };

    //Генерация содержимого
    return (
        <Box sx={STYLES.ROOT_BOX}>
            <CssBaseline />
            <AppBar sx={STYLES.APP_BAR}>
                <Toolbar>
                    <IconButton
                        color="inherit"
                        aria-label="open drawer"
                        onClick={open ? handleDrawerClose : handleDrawerOpen}
                        edge="start"
                        sx={STYLES.APP_BAR_BUTTON}
                    >
                        <Icon>{open ? "chevron_left" : "menu"}</Icon>
                    </IconButton>
                    <Typography variant="h6" noWrap component="div">
                        {selectedPanel?.caption}
                    </Typography>
                </Toolbar>
            </AppBar>
            <Drawer anchor="left" open={open} onClose={handleDrawerClose}>
                <List>
                    <ListItemButton onClick={handleDrawerClose}>
                        <ListItemIcon>
                            <Icon>close</Icon>
                        </ListItemIcon>
                        <ListItemText primary={closeCaption} />
                    </ListItemButton>
                    <ListItemButton onClick={handleHomeClick}>
                        <ListItemIcon>
                            <Icon>home</Icon>
                        </ListItemIcon>
                        <ListItemText primary={homeCaption} />
                    </ListItemButton>
                </List>
                <P8PPanelsMenuDrawer panels={panels} selectedPanel={selectedPanel} onItemNavigate={handleItemNavigate} />
            </Drawer>
            <main style={STYLES.MAIN}>
                <Toolbar />
                {children}
            </main>
        </Box>
    );
};

//Контроль свойств - Рабочее пространство
P8PAppWorkspace.propTypes = {
    children: PropTypes.element,
    panels: PropTypes.arrayOf(P8P_PANELS_MENU_PANEL_SHAPE).isRequired,
    selectedPanel: P8P_PANELS_MENU_PANEL_SHAPE,
    closeCaption: PropTypes.string.isRequired,
    homeCaption: PropTypes.string.isRequired,
    onHomeNavigate: PropTypes.func,
    onItemNavigate: PropTypes.func
};

//----------------
//Интерфейс модуля
//----------------

export { P8PAppWorkspace };

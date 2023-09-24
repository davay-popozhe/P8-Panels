/*
    Парус 8 - Панели мониторинга - ПУП - Экономика проектов
    Панель мониторинга: Корневая панель экономики проектов
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState } from "react"; //Классы React
import { Box } from "@mui/material"; //Интерфейсные компоненты
import { P8PFullScreenDialog } from "../../components/p8p_fullscreen_dialog"; //Полноэкранный диалог
import { Projects } from "./projects"; //Список проектов
import { Stages } from "./stages"; //Список этапов проекта

//-----------
//Тело модуля
//-----------

//Корневая панель экономики проекта
const PrjFin = () => {
    //Собственное состояние
    const [prjFinPanel, setPrjFinPanel] = useState({
        selectedProject: null,
        stagesFilters: []
    });

    //При открытии списка этапов проекта
    const handleStagesOpen = ({ project = {}, filters = [] } = {}) => {
        setPrjFinPanel(pv => ({ ...pv, selectedProject: { ...project }, stagesFilters: [...filters] }));
    };

    //При закрытии списка этапов проекта
    const handleStagesClose = () => {
        setPrjFinPanel(pv => ({ ...pv, selectedProject: null, stagesFilters: [] }));
    };

    //Генерация содержимого
    return (
        <Box p={2}>
            <Projects onStagesOpen={handleStagesOpen} />
            {prjFinPanel.selectedProject ? (
                <P8PFullScreenDialog title={`Этапы проекта "${prjFinPanel.selectedProject.SNAME_USL}"`} onClose={handleStagesClose}>
                    <Stages
                        project={prjFinPanel.selectedProject.NRN}
                        projectName={prjFinPanel.selectedProject.SNAME_USL}
                        filters={prjFinPanel.stagesFilters}
                    />
                </P8PFullScreenDialog>
            ) : null}
        </Box>
    );
};

//----------------
//Интерфейс модуля
//----------------

export { PrjFin };

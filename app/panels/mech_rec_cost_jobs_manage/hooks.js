/*
    Парус 8 - Панели мониторинга - ПУП - Выдача сменного задания
    Кастомные хуки
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React

//-----------
//Тело модуля
//-----------

//Клиентский отбор сменных заданий по поисковой фразе
export const useFilteredFcjobs = (jobs, filter) => {
    const filteredJobs = React.useMemo(() => {
        return jobs.filter(catalog => catalog.SDOC_INFO.toString().toLowerCase().includes(filter.jobName));
    }, [jobs, filter]);

    return filteredJobs;
};

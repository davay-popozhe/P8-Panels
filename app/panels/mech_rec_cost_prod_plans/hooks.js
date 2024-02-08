/*
    Парус 8 - Панели мониторинга - ПУП - Производственная программа
    Кастомные хуки
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React

//-----------
//Тело модуля
//-----------

//Клиентский отбор загруженных планов по поисковой фразе
export const useFilteredPlans = (plans, filter) => {
    const filteredPlans = React.useMemo(() => {
        return plans.filter(project => project.SDOC_INFO.toLowerCase().includes(filter));
    }, [plans, filter]);

    return filteredPlans;
};

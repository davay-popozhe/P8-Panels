/*
    Парус 8 - Панели мониторинга - ПУП - Производственный план цеха
    Кастомные хуки
*/

//---------------------
//Подключение библиотек
//---------------------

import React from "react"; //Классы React

//-----------
//Тело модуля
//-----------

//Клиентский отбор каталогов по поисковой фразе и наличию планов
export const useFilteredPlans = (plans, filter) => {
    const filteredPlans = React.useMemo(() => {
        return plans.filter(catalog => catalog.SDOC_INFO.toString().toLowerCase().includes(filter.planName));
    }, [plans, filter]);

    return filteredPlans;
};

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
export const useFilteredPlanCtlgs = (planCtlgs, filter) => {
    const filteredPlanCtlgs = React.useMemo(() => {
        return planCtlgs.filter(catalog => catalog.SNAME.toString().toLowerCase().includes(filter));
    }, [planCtlgs, filter]);

    return filteredPlanCtlgs;
};

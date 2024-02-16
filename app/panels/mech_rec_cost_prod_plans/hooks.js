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

//Клиентский отбор каталогов по поисковой фразе и наличию планов
export const useFilteredPlanCtlgs = (planCtlgs, filter) => {
    const filteredPlanCtlgs = React.useMemo(() => {
        return planCtlgs.filter(
            catalog =>
                catalog.SNAME.toString().toLowerCase().includes(filter.ctlgName) &&
                (filter.haveDocs ? catalog.NCOUNT_DOCS > 0 : catalog.NCOUNT_DOCS >= 0)
        );
    }, [planCtlgs, filter]);

    return filteredPlanCtlgs;
};

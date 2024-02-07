import React from "react";

export const useFilteredPlans = (plans, filter) => {
    const filteredPlans = React.useMemo(() => {
        return plans.filter(project => project.SDOC_INFO.toLowerCase().includes(filter));
    }, [plans, filter]);

    return filteredPlans;
};

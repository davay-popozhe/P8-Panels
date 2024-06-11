/*
    Парус 8 - Панели мониторинга - ПУП - Мониторинг сборки изделий
    Компонент: Список планов
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useState } from "react"; //Классы React
import { Container, Grid, IconButton, Icon } from "@mui/material"; //Интерфейсные элементы
import PropTypes from "prop-types"; //Контроль свойств компонента
import { PlansListItem } from "./plans_list_item"; //Элемент списка планов

//---------
//Константы
//---------

//Количество одновременно отображаемых элементов списка по умолчанию
const DEFAULT_PAGE_SIZE = 5;

//Стили
const STYLES = {
    PLAN_DOCUMENTS_LIST: { minWidth: "1024px" }
};

//-----------
//Тело модуля
//-----------

//Список планов
const PlansList = ({ plans, pageSize = DEFAULT_PAGE_SIZE, onItemClick }) => {
    //Состояние прокрутки списка отображаемых планов
    const [scroll, setScroll] = useState(0);

    //Отработка нажатия на прокрутку списка планов влево
    const handleScrollLeft = () => setScroll(pv => (pv <= 1 ? 0 : pv - 1));

    //Отработка нажатия на прокрутку списка планов вправо
    const handleScrollRight = () => setScroll(pv => (pv + pageSize >= plans.length ? pv : pv + 1));

    //Сборка представления
    return (
        <Container>
            <Grid container direction="row" justifyContent="center" alignItems="center" spacing={2} sx={STYLES.PLAN_DOCUMENTS_LIST}>
                <Grid item display="flex" justifyContent="center" xs={1}>
                    <IconButton onClick={handleScrollLeft} disabled={scroll <= 0}>
                        <Icon>navigate_before</Icon>
                    </IconButton>
                </Grid>
                {plans.map((el, i) =>
                    i >= scroll && i < scroll + pageSize ? (
                        <Grid item key={`${el.NRN}_${i}`} xs={2}>
                            <PlansListItem
                                card={el}
                                cardIndex={i}
                                onClick={(card, cardIndex) => (onItemClick ? onItemClick(card, cardIndex) : null)}
                            />
                        </Grid>
                    ) : null
                )}
                <Grid item display="flex" justifyContent="center" xs={1}>
                    <IconButton onClick={handleScrollRight} disabled={scroll + pageSize >= plans.length}>
                        <Icon>navigate_next</Icon>
                    </IconButton>
                </Grid>
            </Grid>
        </Container>
    );
};

//Контроль свойств - Список планов
PlansList.propTypes = {
    plans: PropTypes.arrayOf(PropTypes.object),
    pageSize: PropTypes.number,
    onItemClick: PropTypes.func
};

//----------------
//Интерфейс модуля
//----------------

export { PlansList };

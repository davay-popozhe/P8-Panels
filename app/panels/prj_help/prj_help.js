/*
    Парус 8 - Панели мониторинга - ПУП - Работы проектов
    Панель мониторинга: Описание макета (пользовательская инструкция)
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useContext, useState } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import {
    Box,
    Grid,
    Typography,
    Link,
    List,
    ListItem,
    ListItemButton,
    ListItemText,
    Divider,
    Table,
    TableHead,
    TableRow,
    TableCell,
    TableBody,
    Fab,
    Icon
} from "@mui/material"; //Интерфейсные элементы
import { BUTTONS } from "../../../app.text"; //Текстовые ресурсы
import { ApplicationСtx } from "../../context/application"; //Контекст приложения
import img211 from "./img/211.png"; //Изображение
import img212 from "./img/212.png"; //Изображение
import img213 from "./img/213.png"; //Изображение
import img214 from "./img/214.png"; //Изображение
import img215 from "./img/215.png"; //Изображение
import img221 from "./img/221.png"; //Изображение
import img222 from "./img/222.png"; //Изображение
import img223 from "./img/223.png"; //Изображение
import img231 from "./img/231.png"; //Изображение
import img232 from "./img/232.png"; //Изображение
import img241 from "./img/241.png"; //Изображение
import img242 from "./img/242.png"; //Изображение
import img243 from "./img/243.png"; //Изображение
import img244 from "./img/244.png"; //Изображение
import img245 from "./img/245.png"; //Изображение
import img31 from "./img/31.png"; //Изображение
import img32 from "./img/32.png"; //Изображение
import img33 from "./img/33.png"; //Изображение
import img34 from "./img/34.png"; //Изображение
import img35 from "./img/35.png"; //Изображение
import img36 from "./img/36.png"; //Изображение
import img411 from "./img/411.png"; //Изображение
import img412 from "./img/412.png"; //Изображение
import img421 from "./img/421.png"; //Изображение
import img422 from "./img/422.png"; //Изображение
import img431 from "./img/431.png"; //Изображение
import img432 from "./img/432.png"; //Изображение
import img433 from "./img/433.png"; //Изображение
import img434 from "./img/434.png"; //Изображение
import img441 from "./img/441.png"; //Изображение
import img442 from "./img/442.png"; //Изображение
import img443 from "./img/443.png"; //Изображение
import img444 from "./img/444.png"; //Изображение
import img451 from "./img/451.png"; //Изображение
import img461 from "./img/461.png"; //Изображение
import img471 from "./img/471.png"; //Изображение
import img711 from "./img/711.png"; //Изображение
import img721 from "./img/721.png"; //Изображение
import img722 from "./img/722.png"; //Изображение
import img723 from "./img/723.png"; //Изображение
import img741 from "./img/741.png"; //Изображение

//---------
//Константы
//---------

//Оглавление
const CONTENT = [
    { id: "prg1", caption: "1. Назначение документа" },
    { id: "prg2", caption: "2. Инициация проекта" },
    { id: "prg3", caption: "3. Планирование" },
    { id: "prg4", caption: "4. Исполнение" },
    { id: "prg5", caption: "5. Мониторинг и контроль" },
    { id: "prg6", caption: "6. Корректировка планов" },
    { id: "prg7", caption: "7. Завершение проекта" }
];

//Стили
const STYLES = {
    IMG_CONT: { textAlign: "center", padding: "10px" },
    IMG: { maxWidth: "100%", height: "auto" },
    PRGF_TABLE: { paddingTop: "20px", paddingBottom: "20px", display: "flex", justifyContent: "center" },
    TABLE: { width: "80%" },
    TABLE_TITLE: { backgroundColor: "lightgray" },
    TABLE_SUBTITLE: { textAlign: "center", backgroundColor: "#f3eded", fontWeight: "bold" },
    FAB_BACK: { position: "absolute", right: "20px", marginTop: "20px" }
};

//--------------------------------
//Вспомогательные функции и классы
//--------------------------------

//Переход к элементу страницы
const scrollToElement = id => document.getElementById(id).scrollIntoView();

//Заголовок первого уровня
const Hdr1 = ({ id, children }) => (
    <Typography {...(id ? { id } : {})} variant="h3" color="primary">
        {children}
    </Typography>
);

//Контроль свойств - Заголовок первого уровня
Hdr1.propTypes = {
    id: PropTypes.string,
    children: PropTypes.any
};

//Заголовок второго уровня
const Hdr2 = ({ id, children }) => (
    <Typography {...(id ? { id } : {})} variant="h4" color="secondary">
        {children}
    </Typography>
);

//Контроль свойств - Заголовок второго уровня
Hdr2.propTypes = {
    id: PropTypes.string,
    children: PropTypes.any
};

//Заголовок третьего уровня
const Hdr3 = ({ id, children }) => (
    <Typography {...(id ? { id } : {})} variant="h5" color="text.primary">
        {children}
    </Typography>
);

//Контроль свойств - Заголовок третьего уровня
Hdr3.propTypes = {
    id: PropTypes.string,
    children: PropTypes.any
};

//Параграф
const Prgf = ({ style, children }) => (
    <Typography sx={style} component="div" align="justify">
        {children}
    </Typography>
);

//Контроль свойств - Параграф
Prgf.propTypes = {
    style: PropTypes.object,
    children: PropTypes.any
};

//Изображение
const Img = ({ src }) => (
    <div style={STYLES.IMG_CONT}>
        <img src={`./${src}`} style={STYLES.IMG} />
    </div>
);

//Контроль свойств - Изображение
Img.propTypes = {
    src: PropTypes.string.isRequired
};

//Ссылка на раздел Системы
const UnitLink = ({ unitCode, children }) => {
    //Подключение к контексту приложения
    const { pOnlineShowUnit } = useContext(ApplicationСtx);

    //Генерация содержимого
    return (
        <Link component="button" variant="body2" align="left" underline="always" onClick={() => pOnlineShowUnit({ unitCode })}>
            {children}
        </Link>
    );
};

//Контроль свойств - Ссылка на раздел Системы
UnitLink.propTypes = {
    unitCode: PropTypes.string.isRequired,
    children: PropTypes.any
};

//Ссылка на главу инструкции
const ChapterLink = ({ id, dstId, onClick, children }) => {
    //Генерация содержимого
    return (
        <Link
            {...(id ? { id } : {})}
            component="button"
            variant="body2"
            align="left"
            underline="always"
            onClick={() => {
                scrollToElement(dstId);
                if (onClick && id) onClick(id);
            }}
        >
            {children}
        </Link>
    );
};

//Контроль свойств - Ссылка на главу инструкции
ChapterLink.propTypes = {
    id: PropTypes.string,
    dstId: PropTypes.string.isRequired,
    onClick: PropTypes.func,
    children: PropTypes.any
};

//Ссылка на информационную панель
const PanelLink = ({ panelName, children }) => {
    //Подключение к контексту приложения
    const { configUrlBase, findPanelByName, pOnlineShowTab } = useContext(ApplicationСtx);

    //Генерация содержимого
    return (
        <Link
            component="button"
            variant="body2"
            align="left"
            underline="always"
            onClick={() => {
                const panel = findPanelByName(panelName);
                if (panel) pOnlineShowTab({ id: panel.name, url: `${configUrlBase}${panel.url}`, caption: panel.caption });
            }}
        >
            {children}
        </Link>
    );
};

//Контроль свойств - Ссылка на информационную панель
PanelLink.propTypes = {
    panelName: PropTypes.string.isRequired,
    children: PropTypes.any
};

//-----------
//Тело модуля
//-----------

//Корневая панель работ проектов
const PrjHelp = () => {
    //Собственное состояние
    const [navStack, setNavStack] = useState([]);

    //Переход по оглавлению
    const handleTitleClick = id => {
        scrollToElement(id);
        setNavStack([]);
    };

    //Обработка на нажатие ссылки на раздел
    const handleChapterLinkClick = backId => {
        const tmp = [...navStack];
        tmp.push(backId);
        setNavStack(tmp);
    };

    //Обработка нажатия на кнопку "Назад"
    const handleBackClick = () => {
        if (navStack.length > 0) {
            const tmp = [...navStack];
            const backId = tmp.pop();
            scrollToElement(backId);
            setNavStack(tmp);
        }
    };

    //Генерация содержимого
    return (
        <Box>
            {navStack.length > 0 ? (
                <Fab variant="extended" color="primary" sx={STYLES.FAB_BACK} onClick={handleBackClick}>
                    <Icon>arrow_back_ios</Icon>
                    {BUTTONS.NAVIGATE_BACK}
                </Fab>
            ) : null}
            <Grid container spacing={1}>
                <Grid item xs={2}>
                    <Box p={2}>
                        <Typography variant="button">Управление экономикой проектов</Typography>
                    </Box>
                    <Divider />
                    <List>
                        {CONTENT.map((c, i) => (
                            <ListItem disablePadding key={i}>
                                <ListItemButton onClick={() => handleTitleClick(c.id)}>
                                    <ListItemText primary={c.caption} />
                                </ListItemButton>
                            </ListItem>
                        ))}
                    </List>
                </Grid>
                <Grid item xs={10} sx={{ display: "flex", flexDirection: "column", justifyContent: "center" }}>
                    <Box p={2} style={{ maxHeight: "91vh", overflow: "auto" }}>
                        <Hdr1>Управление экономикой проектов</Hdr1>
                        <Hdr2 id={"prg1"}>1. Назначение документа</Hdr2>
                        <Prgf>
                            Документ предназначен для ответственного экономиста по проекту НИОКР и содержит описание порядка применения средств
                            автоматизации на базе ПП “ПАРУС-Предприятие 8” при исполнении процесса управления экономикой проектов НИОКР на каждых его
                            этапах:
                            <p>1) Инициация проекта</p>
                            <p>2) Планирование</p>
                            <p>3) Исполнение</p>
                            <p>4) Мониторинг и контроль</p>
                            <p>5) Корректировка планов</p>
                            <p>6) Завершение проекта</p>
                        </Prgf>
                        <Hdr2 id={"prg2"}>2. Инициация проекта</Hdr2>
                        <Hdr3>2.1. Регистрация информации о проекте</Hdr3>
                        <Prgf>
                            В момент инициации проекта требуется зарегистрировать запись в соответствующем учетном регистре системы, доступ к которому
                            осуществляется из главного меню Учет &gt; <UnitLink unitCode={"Projects"}>Проекты</UnitLink>.
                        </Prgf>
                        <Img src={img211} />
                        <Prgf>
                            Система визуализирует окно параметров отбора проектов. При необходимости можно установить нужные фильтры и нажать кнопку
                            ОК.
                        </Prgf>
                        <Img src={img212} />
                        <Prgf>В открывшемся регистре требуется вызвать контекстное меню правой кнопкой мыши и выбрать пункт “Добавить”.</Prgf>
                        <Img src={img213} />
                        <Prgf>Система визуализирует окно параметров действия.</Prgf>
                        <Img src={img214} />
                        <Prgf>Требуется заполнить реквизиты проекта согласно правилам, приведенным ниже в таблице и нажать кнопку ОК.</Prgf>
                        <Prgf style={STYLES.PRGF_TABLE}>
                            <Table sx={STYLES.TABLE}>
                                <TableHead sx={STYLES.TABLE_TITLE}>
                                    <TableRow>
                                        <TableCell>№ п/п</TableCell>
                                        <TableCell>Наименование реквизита</TableCell>
                                        <TableCell>Правила заполнения</TableCell>
                                    </TableRow>
                                </TableHead>
                                <TableBody>
                                    <TableRow>
                                        <TableCell colSpan={3} sx={STYLES.TABLE_SUBTITLE}>
                                            Проект
                                        </TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>1</TableCell>
                                        <TableCell>Мнемокод</TableCell>
                                        <TableCell>Внутренний код проекта (номер заказа, шифр работ)</TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>2</TableCell>
                                        <TableCell>Наименование</TableCell>
                                        <TableCell>Полное наименование проекта</TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>3</TableCell>
                                        <TableCell>Условное наименование</TableCell>
                                        <TableCell>Согласованный с заказчиком код проекта</TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>4</TableCell>
                                        <TableCell>Ожидаемые результаты</TableCell>
                                        <TableCell>Заполнить при необходимости</TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>5</TableCell>
                                        <TableCell>Идентификатор государственного контракта</TableCell>
                                        <TableCell>Выбрать из словаря ИГК в том случае, если проекта выполняется в рамках ГОЗ</TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>6</TableCell>
                                        <TableCell>Документ-основание</TableCell>
                                        <TableCell>
                                            Указать номер договора с заказчиком, номер внутриорганизационного приказа либо иного документа инициации
                                            проекта
                                        </TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>7</TableCell>
                                        <TableCell>Тип</TableCell>
                                        <TableCell>Выбрать из словаря подходящий тип проекта</TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>8</TableCell>
                                        <TableCell>Внешний заказчик</TableCell>
                                        <TableCell>Выбрать из словаря в том случае, если проект инициирован внешним заказчиком</TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>9</TableCell>
                                        <TableCell>Подразделение-заказчик</TableCell>
                                        <TableCell>
                                            Выбрать из словаря в том случае, если проект является внутренним (например, НИОКР для собственных нужд,
                                            инвестиционные проекты …)
                                        </TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>10</TableCell>
                                        <TableCell>Ответственный</TableCell>
                                        <TableCell>Выбрать из словаря ответственного сотрудника за исполнение проектных работ</TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>11</TableCell>
                                        <TableCell>Подразделение-ответственный</TableCell>
                                        <TableCell>Выбрать из словаря ответственное подразделение-исполнитель проектных работ</TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>12</TableCell>
                                        <TableCell>Дата начала план</TableCell>
                                        <TableCell>Указать плановую дату начала выполнения проектных работ</TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>13</TableCell>
                                        <TableCell>Дата окончания план</TableCell>
                                        <TableCell>Указать плановую дату окончания выполнения проектных работ</TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell colSpan={3} sx={STYLES.TABLE_SUBTITLE}>
                                            Суммы, трудоемкость
                                        </TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>14</TableCell>
                                        <TableCell>Стоимость</TableCell>
                                        <TableCell>Задать плановую стоимость проекта</TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>15</TableCell>
                                        <TableCell>ЕИ трудоемкости</TableCell>
                                        <TableCell>Выбрать из словаря единицу измерения трудоемкости проекта</TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell colSpan={3} sx={STYLES.TABLE_SUBTITLE}>
                                            Настройки
                                        </TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>16</TableCell>
                                        <TableCell>Схема калькуляции</TableCell>
                                        <TableCell>Выбрать из словаря подходящую структуру плановой калькуляции по проекту</TableCell>
                                    </TableRow>
                                </TableBody>
                            </Table>
                        </Prgf>
                        <Prgf>
                            При начале выполнения проектных работ требуется перевести проект в состояние “Открыт” посредством соответствующего
                            действия контекстного меню раздела.
                        </Prgf>
                        <Img src={img215} />
                        <Hdr3>2.2. Регистрация этапов проекта</Hdr3>
                        <Prgf>Далее необходимо выполнить регистрацию этапов проекта.</Prgf>
                        <Prgf>
                            В подчиненной таблице “Этапы проекта” требуется вызвать контекстное меню правой кнопкой мыши и выбрать пункт “Добавить”.
                        </Prgf>
                        <Img src={img221} />
                        <Prgf>Система визуализирует окно параметров действия.</Prgf>
                        <Img src={img222} />
                        <Prgf>Требуется заполнить реквизиты этапа проекта согласно правилам, приведенным ниже в таблице и нажать кнопку ОК.</Prgf>
                        <Prgf style={STYLES.PRGF_TABLE}>
                            <Table sx={STYLES.TABLE}>
                                <TableHead sx={STYLES.TABLE_TITLE}>
                                    <TableRow>
                                        <TableCell>№ п/п</TableCell>
                                        <TableCell>Наименование реквизита</TableCell>
                                        <TableCell>Правила заполнения</TableCell>
                                    </TableRow>
                                </TableHead>
                                <TableBody>
                                    <TableRow>
                                        <TableCell colSpan={3} sx={STYLES.TABLE_SUBTITLE}>
                                            Этап проекта
                                        </TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>1</TableCell>
                                        <TableCell>Номер</TableCell>
                                        <TableCell>Указать номер этапа проекта п/п</TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>2</TableCell>
                                        <TableCell>Наименование</TableCell>
                                        <TableCell>Полное наименование этапа проекта</TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>3</TableCell>
                                        <TableCell>Ожидаемые результаты</TableCell>
                                        <TableCell>Заполнить при необходимости</TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>4</TableCell>
                                        <TableCell>Дата начала план</TableCell>
                                        <TableCell>Указать плановую дату начала выполнения этапа проектных работ</TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>5</TableCell>
                                        <TableCell>Дата окончания план</TableCell>
                                        <TableCell>Указать плановую дату окончания выполнения этапа проектных работ</TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell colSpan={3} sx={STYLES.TABLE_SUBTITLE}>
                                            Суммы, трудоемкость
                                        </TableCell>
                                    </TableRow>
                                    <TableRow>
                                        <TableCell>6</TableCell>
                                        <TableCell>Стоимость этапа</TableCell>
                                        <TableCell>Задать плановую стоимость этапа проекта</TableCell>
                                    </TableRow>
                                </TableBody>
                            </Table>
                        </Prgf>
                        <Prgf>
                            При начале выполнения проектных работ по этапу требуется перевести этап проекта проект в состояние “Открыт” посредством
                            соответствующего действия контекстного меню раздела.
                        </Prgf>
                        <Img src={img223} />
                        <Hdr3>2.3. Формирование шифра затрат</Hdr3>
                        <Prgf>
                            После регистрации этапа проекта требуется выделить запись этапа, вызвать правой кнопкой мыши контекстное меню и выбрать
                            пункт “ЦИТК. Указать шифр затрат”.
                        </Prgf>
                        <Img src={img231} />
                        <Prgf>Система визуализирует окно параметров действия.</Prgf>
                        <Img src={img232} />
                        <Prgf>
                            Номер шифра затрат система генерирует автоматически. При необходимости его можно исправить. Далее необходимо нажать копку
                            ОК.
                        </Prgf>
                        <Hdr3 id={"prg24"}>2.4. Регистрация договора с заказчиком</Hdr3>
                        <Prgf>
                            После заключения договора с заказчиком необходимо выделить законтрактованные этапы проекта, вызвать правой кнопкой мыши
                            контекстное меню и выбрать пункт Формирование &gt; Договор с внешним заказчиком.
                        </Prgf>
                        <Img src={img241} />
                        <Prgf>Система визуализирует окно параметров действия.</Prgf>
                        <Img src={img242} />
                        <Prgf>Необходимо заполнить параметры действия и нажать кнопку ОК.</Prgf>
                        <Prgf>
                            Система сформирует договор с заказчиком в <UnitLink unitCode="Contracts">соответствующем регистре системы</UnitLink>.
                            Договор связан с записью регистра “Проекты” посредством штатного механизма взаимосвязей документов.
                        </Prgf>
                        <Img src={img243} />
                        <Prgf>
                            Запись в регистре “Договоры” может быть отредактирована посредством штатных действий “Исправить” контекстного меню
                            заголовка раздела. Также может быть отредактирован каждый этап договора.
                        </Prgf>
                        <Prgf>
                            В момент двустороннего подписания договора требуется перевести документ в состояние “Утвержден” посредством
                            соответствующего действия контекстного меню раздела.
                        </Prgf>
                        <Img src={img244} />
                        <Prgf>
                            В момент перехода к двустороннему исполнению этапа договора требуется перевести этап в состояние “Открыт” посредством
                            соответствующего действия контекстного меню раздела.
                        </Prgf>
                        <Img src={img245} />
                        <Hdr2 id={"prg3"}>3. Планирование</Hdr2>
                        <Prgf>
                            При получении плановой калькуляции по этапу от службы ценообразования требуется зарегистрировать данный документ в
                            соответствующем регистре системы.
                        </Prgf>
                        <Img src={img31} />
                        <Prgf>Система визуализирует окно параметров действия.</Prgf>
                        <Img src={img32} />
                        <Prgf>Необходимо заполнить реквизиты плановой калькуляции и нажать кнопку ОК.</Prgf>
                        <Prgf>
                            Далее необходимо сформировать перечень статей калькуляции посредством одноименного действия контекстного меню раздела.
                        </Prgf>
                        <Img src={img33} />
                        <Prgf>
                            Далее необходимо указать плановые суммы прямых статей затрат посредством штатного действия “Исправить” контекстного меню.
                        </Prgf>
                        <Prgf>
                            Затем необходимо выполнить расчет косвенных статей затрат посредством одноименного действия контекстного меню раздела.
                        </Prgf>
                        <Img src={img34} />
                        <Prgf>
                            В момент двустороннегго согласования плановой калькуляции необходимо утвердить документ посредством одноименного действия
                            контекстного меню раздела.
                        </Prgf>
                        <Img src={img35} />
                        <Prgf>Затем документ необходимо пометить как действующий.</Prgf>
                        <Img src={img36} />
                        <Hdr2 id={"prg4"}>4. Исполнение</Hdr2>
                        <Hdr3 id={"prg41"}>4.1. Формирование авансового счета по договору с заказчиком</Hdr3>
                        <Prgf>
                            Необходимо отобрать договор с заказчиком в <UnitLink unitCode="Contracts">одноименном штатном регистре системы</UnitLink>,
                            выбрать этап, вызвать контекстное меню и выбрать пункт Формирование &gt; Счет на оплату.
                        </Prgf>
                        <Img src={img411} />
                        <Prgf>Система визуализирует окно реквизитов счета на оплату.</Prgf>
                        <Img src={img412} />
                        <Prgf>Необходимо заполнить реквизиты счета и нажать кнопку ОК.</Prgf>
                        <Prgf>
                            Система зарегистрирует документ в{" "}
                            <UnitLink unitCode="PaymentAccounts">соответствующем документарном регистре системы</UnitLink>.
                        </Prgf>
                        <Hdr3>4.2. Регистрация договоров с соисполнителями / поставщиками / подрядчиками</Hdr3>
                        <Prgf>
                            После заключения договора с соисполнителем / поставщиком / подрядчиком необходимо выбрать этап проекта, в рамках которого
                            был заключен договор, вызвать правой кнопкой мыши контекстное меню и выбрать пункт Формирование &gt; Договор с внешним
                            исполнителем.
                        </Prgf>
                        <Img src={img421} />
                        <Prgf>Система визуализирует окно параметров действия.</Prgf>
                        <Img src={img422} />
                        <Prgf>Необходимо заполнить параметры действия и нажать кнопку ОК.</Prgf>
                        <Prgf>
                            Система сформирует договор с исполнителем в <UnitLink unitCode="Contracts">соответствующем регистре системы</UnitLink>.
                        </Prgf>
                        <Prgf>
                            Запись в регистре “Договоры” может быть отредактирована посредством штатных действий “Исправить” контекстного меню
                            заголовка раздела. Также может быть отредактирован каждый этап договора.
                        </Prgf>
                        <Prgf>
                            В момент двустороннего подписания договора требуется перевести документ в состояние “Утвержден” посредством
                            соответствующего действия контекстного меню раздела аналогично тому, как это выполняется и для договора с заказчиком (см.
                            выше{" "}
                            <ChapterLink id={"back42from24_1"} dstId={"prg24"} onClick={handleChapterLinkClick}>
                                раздел 2.4
                            </ChapterLink>{" "}
                            настоящей Инструкции).
                        </Prgf>
                        <Prgf>
                            В момент перехода к двустороннему исполнению этапа договора требуется перевести этап в состояние “Открыт” посредством
                            соответствующего действия контекстного меню раздела аналогично тому, как это выполняется и для договора с заказчиком (см.
                            выше{" "}
                            <ChapterLink id={"back42from24_2"} dstId={"prg24"} onClick={handleChapterLinkClick}>
                                раздел 2.4
                            </ChapterLink>{" "}
                            настоящей Инструкции).
                        </Prgf>
                        <Hdr3>4.3. Регистрация счета по договору с исполнителем</Hdr3>
                        <Prgf>
                            При поступлении счета от исполнителя необходимо отобрать договор с исполнителем в{" "}
                            <UnitLink unitCode="Contracts">одноименном штатном регистре системы</UnitLink>, выбрать этап, вызвать контекстное меню и
                            выбрать пункт Формирование &gt; Входящий счет на оплату.
                        </Prgf>
                        <Img src={img431} />
                        <Prgf>Система визуализирует окно параметров действия.</Prgf>
                        <Img src={img432} />
                        <Prgf>Необходимо заполнить параметры и нажать кнопку ОК.</Prgf>
                        <Prgf>Система визуализирует окно реквизитов счета на оплату.</Prgf>
                        <Img src={img433} />
                        <Prgf>Необходимо заполнить реквизиты счета и нажать кнопку ОК.</Prgf>
                        <Prgf>
                            Система зарегистрирует документ в{" "}
                            <UnitLink unitCode="PaymentAccountsIn">соответствующем документарном регистре системы</UnitLink>.
                        </Prgf>
                        <Prgf>
                            Далее документ может быть отредактирован посредством штатных действий “Исправить” контекстного меню заголовка раздела.
                            Также может быть отредактирована спецификация документа.
                        </Prgf>
                        <Prgf>
                            По окончании редактирования счета документ подлежит утверждению посредством соответствующего действия контекстного меню
                            раздела.
                        </Prgf>
                        <Img src={img434} />
                        <Hdr3>4.4. Регистрация актов и товарных накладных по договору с исполнителем</Hdr3>
                        <Prgf>
                            При поступлении акта/товарной накладной от исполнителя необходимо отобрать договор с исполнителем в{" "}
                            <UnitLink unitCode="Contracts">одноименном штатном регистре системы</UnitLink>, выбрать этап, вызвать контекстное меню и
                            выбрать пункт Формирование &gt; Приходная накладная.
                        </Prgf>
                        <Img src={img441} />
                        <Prgf>Система визуализирует окно параметров действия.</Prgf>
                        <Img src={img442} />
                        <Prgf>Необходимо заполнить параметры и нажать кнопку ОК.</Prgf>
                        <Prgf>Система визуализирует буфер формирования документа.</Prgf>
                        <Img src={img443} />
                        <Prgf>Необходимо нажать кнопку ОК.</Prgf>
                        <Prgf>
                            Система зарегистрирует документ в{" "}
                            <UnitLink unitCode="IncomingInvoices">соответствующем документарном регистре системы</UnitLink>.
                        </Prgf>
                        <Prgf>
                            Далее документ может быть отредактирован посредством штатных действий “Исправить” контекстного меню заголовка раздела.
                            Также может быть отредактирована спецификация документа.
                        </Prgf>
                        <Prgf>
                            По окончании редактирования документ подлежит утверждению посредством соответствующего действия контекстного меню раздела.
                        </Prgf>
                        <Img src={img444} />
                        <Hdr3>4.5. Ведение реестра финансовых документов по проекту</Hdr3>
                        <Prgf>
                            Система позволяет получить доступ ко всем документам по данному этапу проекта с возможностью перехода в соответствующие
                            документарные регистры системы:
                            <p>
                                1) <UnitLink unitCode="PaymentAccounts">Счета на оплату</UnitLink>
                            </p>
                            <p>
                                2) <UnitLink unitCode="GoodsTransInvoicesToConsumers">Расходные накладные на отпуск потребителям</UnitLink>
                            </p>
                            <p>
                                3) <UnitLink unitCode="PaymentAccountsIn">Входящие счета на оплату</UnitLink>
                            </p>
                            <p>
                                4) <UnitLink unitCode="IncomingInvoices">Приходные накладные</UnitLink>
                            </p>
                        </Prgf>
                        <Img src={img451} />
                        <Hdr3>4.6. Учет фактической оплаты</Hdr3>
                        <Prgf>
                            Система позволяет получить доступ к фактически проведенным платежным поручениям по данному этапу проекта с возможностью
                            перехода в <UnitLink unitCode="PayNotes">соответствующий учетный регистр системы</UnitLink>.
                        </Prgf>
                        <Img src={img461} />
                        <Hdr3>4.7. Учет фактических затрат</Hdr3>
                        <Prgf>
                            Система позволяет получить доступ к фактическим затратам по данному этапу проекта с возможностью перехода в{" "}
                            <UnitLink unitCode="CostNotes">соответствующий учетный регистр системы</UnitLink>.
                        </Prgf>
                        <Img src={img471} />
                        <Hdr2 id={"prg5"}>5. Мониторинг и контроль</Hdr2>
                        <Prgf>
                            В информационной панели <PanelLink panelName="PrjFin">Экономика проектов</PanelLink> система обеспечивает мониторинг
                            исполнения проекта по следующим основным объектам контроля:
                            <p>1) Финансирование</p>
                            <p>2) Контрактация</p>
                            <p>3) Договоры с соисполнителями</p>
                            <p>4) Сроки</p>
                            <p>5) Затраты</p>
                            <p>6) Актирование</p>
                        </Prgf>
                        <Hdr2 id={"prg6"}>6. Корректировка планов</Hdr2>
                        <Prgf>
                            Система обеспечивает возможность корректировки экономической структуры проекта в том числе и в процессе его исполнения (с
                            сохранением истории изменений):
                            <p>1) Изменение стоимости этапов проекта (например, при увеличении/уменьшении объема работ)</p>
                            <p>2) Корректировку сроков этапов проекта (например, при изменении требований заказчика)</p>
                            <p>3) Добавление новых этапов проекта</p>
                            <p>4) Разделение этапов проекта</p>
                            <p>5) Объединение этапов проекта</p>
                            <p>
                                6) Корректировку плановой калькуляции путем регистрации новой версии документа (например, в результате подписания
                                протокола согласования фиксированной цены этапа проектных работ) – порядок регистрации документа описан выше в разделе
                                3 настоящей Инструкции
                            </p>
                        </Prgf>
                        <Prgf>
                            В случае изменения структуры этапов проекта (разделение либо объединение этапов проекта) в процессе его исполнения
                            обеспечивается возможность:
                            <p>1) Изменить привязку внешнего исполнителя (перенести с одного этапа на другой)</p>
                            <p>2) Выполнить переброску финансирования (как входящего, так и исходящего)</p>
                            <p>3) Выполнить переброску накопленных фактических затрат</p>
                        </Prgf>
                        <Hdr2 id={"prg7"}>7. Завершение проекта</Hdr2>
                        <Hdr3>7.1. Закрытие этапа проекта</Hdr3>
                        <Prgf>
                            По окончании выполнения проектных работ по этапу требуется перевести этап проекта в состояние “Закрыт” посредством
                            соответствующего действия контекстного меню раздела.
                        </Prgf>
                        <Img src={img711} />
                        <Hdr3>7.2. Формирование акта выполненных работ по договору с заказчиком</Hdr3>
                        <Prgf>
                            Необходимо отобрать договор с заказчиком в <UnitLink unitCode="Contracts">одноименном штатном регистре системы</UnitLink>,
                            выбрать этап, вызвать контекстное меню и выбрать пункт Формирование &gt; Расходная накладная на отпуск потребителям.
                        </Prgf>
                        <Img src={img721} />
                        <Prgf>Система визуализирует буфер формирования документа. Необходимо нажать кнопку ОК.</Prgf>
                        <Img src={img722} />
                        <Prgf>
                            Система зарегистрирует документ в{" "}
                            <UnitLink unitCode="GoodsTransInvoicesToConsumers">соответствующем документарном регистре системы</UnitLink>.
                        </Prgf>
                        <Prgf>
                            Далее документ может быть отредактирован посредством штатных действий “Исправить” контекстного меню заголовка раздела.
                            Также может быть отредактирована спецификация документа.
                        </Prgf>
                        <Prgf>
                            По окончании редактирования документ подлежит утверждению посредством соответствующего действия контекстного меню раздела.
                        </Prgf>
                        <Img src={img723} />
                        <Hdr3>7.3. Формирование счета на окончательный расчет с заказчиком</Hdr3>
                        <Prgf>
                            Порядок формирования счета на окончательный расчет полностью аналогичен порядку формирования авансового счета, подробно
                            описанному выше в{" "}
                            <ChapterLink id={"back73from41"} dstId={"prg41"} onClick={handleChapterLinkClick}>
                                разделе 4.1
                            </ChapterLink>{" "}
                            настоящей Инструкции.
                        </Prgf>
                        <Hdr3>7.4. Закрытие проекта</Hdr3>
                        <Prgf>
                            По окончании выполнения проектных работ по всем этапам требуется перевести проект в состояние “Закрыт” посредством
                            соответствующего действия контекстного меню раздела.
                        </Prgf>
                        <Img src={img741} />
                    </Box>
                </Grid>
            </Grid>
        </Box>
    );
};

//----------------
//Интерфейс модуля
//----------------

export { PrjHelp };

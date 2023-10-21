/*
    Парус 8 - Панели мониторинга - ПУП - Работы проектов
    Панель мониторинга: Описание макета (пользовательская инструкция)
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useContext } from "react"; //Классы React
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
    TableBody
} from "@mui/material"; //Интерфейсные элементы
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
    IMG: { textAlign: "center", padding: "10px" },
    PRGF_TABLE: { paddingTop: "20px", paddingBottom: "20px", display: "flex", justifyContent: "center" },
    TABLE: { width: "80%" },
    TABLE_TITLE: { backgroundColor: "lightgray" },
    TABLE_SUBTITLE: { textAlign: "center", backgroundColor: "#f3eded", fontWeight: "bold" }
};

//--------------------------------
//Вспомогательные функции и классы
//--------------------------------

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
    <div style={STYLES.IMG}>
        <img src={`./${src}`} />
    </div>
);

//Контроль свойств - Изображение
Img.propTypes = {
    src: PropTypes.string.isRequired
};

//Ссылка на раздел
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

//Контроль свойств - Ссылка на раздел
UnitLink.propTypes = {
    unitCode: PropTypes.string.isRequired,
    children: PropTypes.any
};

//-----------
//Тело модуля
//-----------

//Корневая панель работ проектов
const PrjHelp = () => {
    //Генерация содержимого
    return (
        <Box>
            <Grid container spacing={1}>
                <Grid item xs={2}>
                    <Box p={2}>
                        <Typography variant="button">Управление экономикой проектов</Typography>
                    </Box>
                    <Divider />
                    <List>
                        {CONTENT.map((c, i) => (
                            <ListItem disablePadding key={i}>
                                <ListItemButton
                                    onClick={() => {
                                        document.getElementById(c.id).scrollIntoView();
                                    }}
                                >
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
                        <Hdr3>2.4. Регистрация договора с заказчиком</Hdr3>
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
                        <Hdr2 id={"prg5"}>5. Мониторинг и контроль</Hdr2>
                        <Hdr2 id={"prg6"}>6. Корректировка планов</Hdr2>
                        <Hdr2 id={"prg7"}>7. Завершение проекта</Hdr2>
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

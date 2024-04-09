/*
    Парус 8 - Панели мониторинга
    Компонент: График
*/

//---------------------
//Подключение библиотек
//---------------------

import React, { useEffect, useRef } from "react"; //Классы React
import PropTypes from "prop-types"; //Контроль свойств компонента
import Chart from "chart.js/auto"; //Диаграммы и графики

//---------
//Константы
//---------

//Виды графиков
const P8P_CHART_TYPE = {
    BAR: "bar",
    LINE: "line",
    PIE: "pie",
    DOUGHNUT: "doughnut"
};

//Структура элемента набора данных
const P8P_CHART_DATASET_SHAPE = PropTypes.shape({
    label: PropTypes.string.isRequired,
    borderColor: PropTypes.oneOfType([PropTypes.string, PropTypes.arrayOf(PropTypes.string)]),
    backgroundColor: PropTypes.oneOfType([PropTypes.string, PropTypes.arrayOf(PropTypes.string)]),
    data: PropTypes.arrayOf(PropTypes.number),
    items: PropTypes.arrayOf(PropTypes.object)
});

//-----------
//Тело модуля
//-----------

//График
const P8PChart = ({ type, title, legendPosition, options, labels, datasets, onClick, style }) => {
    //Ссылки на DOM
    const chartCanvasRef = useRef(null);
    const chartRef = useRef(null);

    //Обработка нажатия на элемент графика
    const handleClick = e => {
        const bar = chartRef.current.getElementsAtEventForMode(e, "nearest", { intersect: true }, true)[0];
        if (onClick && bar)
            onClick({
                datasetIndex: bar.datasetIndex,
                itemIndex: bar.index,
                item: chartRef.current.data.datasets[bar.datasetIndex].items
                    ? chartRef.current.data.datasets[bar.datasetIndex].items[bar.index]
                    : null
            });
    };

    //При подключении к старнице
    useEffect(() => {
        if (!chartRef.current) {
            const ctx = chartCanvasRef.current.getContext("2d");
            chartRef.current = new Chart(ctx, {
                type,
                data: { labels: [...labels], datasets: [...datasets] },
                options: {
                    ...options,
                    ...{
                        responsive: true,
                        plugins: {
                            legend: {
                                display: legendPosition ? true : false,
                                position: legendPosition
                            },
                            title: {
                                display: title ? true : false,
                                text: title
                            }
                        }
                    },
                    onClick: handleClick
                }
            });
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    //При обновлении данных
    useEffect(() => {
        if (chartRef.current) {
            chartRef.current.data.labels = [...labels];
            chartRef.current.data.datasets = [...datasets];
            chartRef.current.update();
        }
    }, [datasets, labels]);

    //Генерация содержимого
    return (
        <div style={{ ...style }}>
            <canvas ref={chartCanvasRef} />
        </div>
    );
};

//Контроль свойств - График
P8PChart.propTypes = {
    type: PropTypes.string.isRequired,
    title: PropTypes.string,
    legendPosition: PropTypes.string,
    options: PropTypes.object,
    labels: PropTypes.arrayOf(PropTypes.string).isRequired,
    datasets: PropTypes.arrayOf(P8P_CHART_DATASET_SHAPE),
    onClick: PropTypes.func,
    style: PropTypes.object
};

//----------------
//Интерфейс модуля
//----------------

export { P8P_CHART_TYPE, P8PChart };

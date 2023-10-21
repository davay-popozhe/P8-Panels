/* eslint-disable */
/*
    Парус 8 - Панели мониторинга
    Настройки упаковщика
*/

//---------------------
//Подключение библиотек
//---------------------

const webpack = require("webpack");
const path = require("path");

//----------------
//Интерфейс модуля
//----------------

let mode = "development";
if (process.env.NODE_ENV == "production") mode = "production";

module.exports = {
    mode,
    entry: "./app/index.js",
    watch: mode == "development",
    watchOptions: {
        aggregateTimeout: 20
    },
    output: {
        path: path.resolve(__dirname, "dist"),
        publicPath: "/dist/",
        filename: "p8-panels.js"
    },
    module: {
        rules: [
            {
                test: /\.m?js$/,
                exclude: /node_modules/,
                use: {
                    loader: "babel-loader",
                    options: {
                        presets: ["@babel/preset-react"]
                    }
                }
            },
            {
                test: /\.(jpg|png|svg)$/,
                loader: "file-loader",
                options: {
                    name: "[path][name].[hash].[ext]"
                }
            }
        ]
    }
};

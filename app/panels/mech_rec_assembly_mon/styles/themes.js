import { createTheme } from "@mui/material/styles"; //Интерфейсные элементы

//Описание темы
const theme = createTheme({
    palette: {
        text: {
            title: { fontColor: "rgba(0, 0, 0, 0.65)" },
            secondary: { fontColor: "rgba(0, 0, 0, 0.298)" }
        }
    },
    typography: {
        h1: {
            fontSize: "40px",
            fontWeight: 400,
            textAlign: "center"
        },
        h2: {
            fontSize: "40px",
            fontWeight: 700,
            textAlign: "center"
        },
        h3: {
            fontSize: "30px",
            fontWeight: 700,
            textAlign: "center"
        },
        h4: {
            fontSize: "16px",
            fontWeight: 400,
            textAlign: "center"
        },
        subtitle1: {
            fontSize: "30px",
            fontWeight: 400,
            textAlign: "center"
        },
        subtitle2: {
            fontSize: "20px",
            fontWeight: 700,
            textAlign: "center"
        },
        UDO_body1: {
            fontSize: "14px",
            fontWeight: 400,
            textAlign: "center",
            wordWrap: "break-word",
            letterSpacing: "0.00938em",
            lineHeight: "1.5"
        },
        UDO_body2: {
            fontSize: "12px",
            fontWeight: 400,
            whiteSpace: "pre-line",
            textAlign: "center",
            wordWrap: "break-word",
            letterSpacing: "0.00938em",
            lineHeight: "1.5"
        },
        body3: {
            fontSize: "9px",
            whiteSpace: "pre-line",
            textAlign: "center"
        }
    }
});

export { theme };

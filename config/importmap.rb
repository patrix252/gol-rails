# Pin npm packages by running ./bin/importmap

pin "application"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "gol", to: "gol.js"
pin "bootstrap", to: "bootstrap.min.js"

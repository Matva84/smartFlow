// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "./holidays";
import "./redDotNotification";
import "./modaleEvent";
import "./modaleExpense";
import "./graphExpense";
import "./updateGraphExpense";
import "./global_expenses_chart";
import Chartkick from "chartkick"

// Chart.js est déjà inclus via le CDN dans le layout
Chartkick.use(window.Chart)



//import "./overTime";

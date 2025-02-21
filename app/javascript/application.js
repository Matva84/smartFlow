// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "./holidays";
import "./redDotNotification";
import "./modaleEvent";
import "./modaleExpense";
import "./graphExpense";
import "./updateGraphExpense";
import "./global_expenses_chart";
//import "./channels/communication_channel";
//import "./channels/employee_chat";
import "./channels/consumer";
import "./channels/chat";
import "./expenseCategory";
//import "./interactiveCard";

import "@rails/actioncable"
//import "./overTime";
import Chartkick from "chartkick"

// Chart.js est déjà inclus via le CDN dans le layout
Chartkick.use(window.Chart)

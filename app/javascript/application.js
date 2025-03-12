// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "./expenseCategory";
import "./global_expenses_chart";
import "./graphExpense";
import "./holidays";
import "./itemsDefinition";
import "./menu";
import "./modaleEvent";
import "./modaleExpense";
import "./redDotNotification";
import "./updateGraphExpense";
import "./modaleItem";

import "./channels/consumer";
import "./channels/chat";
import "./channels/readMessage";

//import "./interactiveCard";
//import "./channels/communication_channel";
//import "./channels/employee_chat";

import "@rails/actioncable"
//import "./overTime";
import Chartkick from "chartkick"

// Chart.js est déjà inclus via le CDN dans le layout
Chartkick.use(window.Chart)

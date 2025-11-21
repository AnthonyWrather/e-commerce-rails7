// Load all the controllers within this directory and all subdirectories.
// Controller files must be named *_controller.js.

import { application } from "./application"

// Manually register each controller
import CartController from "./cart_controller"
import ProductsController from "./products_controller"
import DashboardController from "./dashboard_controller.ts"
import QuantitiesController from "./quantities_controller.ts"

application.register("cart", CartController)
application.register("products", ProductsController)
application.register("dashboard", DashboardController)
application.register("quantities", QuantitiesController)

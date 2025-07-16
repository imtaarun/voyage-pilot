import express from "express";
import session from "express-session";
import cookieParser from "cookie-parser";
import { User } from "./models/user.model";
import authRoutes from "./routes/auth";
import indexRoutes from "./routes/index";
import config from "./config/defaults"
import { sequelize } from './config/sequelize'; 

const app = express();
var cors = require('cors')

// Set up CORS middleware
app.use(cors());

declare module "express-session" {
  interface SessionData {
    user: User;
  }
}

// Set up session middleware
app.use(
  session({
    secret: config.secret,
    resave: false,
    saveUninitialized: true,
    cookie: { secure: false, maxAge: config.maxAge },
  })
);

// cookie parser middleware
app.use(cookieParser());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Init Sequelize
// sequelize

// Use routes
app.use("/auth", authRoutes);
app.use("/", indexRoutes);

const PORT = config.port;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

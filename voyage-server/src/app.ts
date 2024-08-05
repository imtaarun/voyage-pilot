import express from "express";
import session from "express-session";
import cookieParser from "cookie-parser";
import { User } from "./models/User";
import authRoutes from "./routes/auth";
import config from "./config/defaults"

const app = express();

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

// Use routes
app.use("/", authRoutes);

const PORT = config.port;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

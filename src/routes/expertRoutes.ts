import { Router } from "express";
import { getAllExperts, getExpertById } from "../controllers/expertController.js";
import { authMiddleware } from "../middlewares/authMiddleware.js";

export const expertRouter = Router();

// Routes for psychologists / experts
expertRouter.get("/", authMiddleware, getAllExperts);
expertRouter.get("/:id", authMiddleware, getExpertById);

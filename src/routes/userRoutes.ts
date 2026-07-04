import { Router } from "express";
import { authMiddleware } from "../middlewares/authMiddleware.js";
import { updateProfile, saveFaceEmbedding } from "../controllers/userController.js";

export const userRoutes = Router();

userRoutes.put("/profile", authMiddleware, updateProfile);
userRoutes.post("/face-embedding", authMiddleware, saveFaceEmbedding);

import { Router } from "express";
import { authMiddleware } from "../middlewares/authMiddleware.js";
import { getActivityStats, getLastScreeningStats, getscreeningHistoryStats, getArticlesAnalysis } from "../controllers/grafikController.js";
export const grafikRoutes = Router();
grafikRoutes.get('/articles-analysis', getArticlesAnalysis);
grafikRoutes.get('/activities-stats/:childId', authMiddleware, getActivityStats);
grafikRoutes.get('/last-screening-stats/:childId', authMiddleware, getLastScreeningStats);
grafikRoutes.get('/screening-history-stats/:childId', authMiddleware, getscreeningHistoryStats);
//# sourceMappingURL=grafikRoutes.js.map
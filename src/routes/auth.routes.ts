import { Router } from "express";
import { authMiddleware } from "../middlewares/auth.middleware.js";
import { register } from "../controllers/auth/register.controller.js";
import { verifyOtp } from "../controllers/auth/verify-otp.controller.js";
import { login } from "../controllers/auth/login.controller.js";
import { getMe, logout } from "../controllers/auth/get-me.controller.js";
import { requestResetPassword } from "../controllers/auth/request-reset-password.controller.js";
import { resetPassword } from "../controllers/auth/reset-password.controller.js";

const router = Router();
    
router.post("/register", register);
router.post("/verify-otp", verifyOtp);
router.post("/login", login);
router.get("/me", authMiddleware, getMe);
router.post("/logout", authMiddleware, logout);
router.post("/request-reset-password", requestResetPassword);
router.post("/reset-password", resetPassword);

export default router;
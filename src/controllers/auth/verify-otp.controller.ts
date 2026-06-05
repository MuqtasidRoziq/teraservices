import "dotenv/config";
import { Request, Response } from "express";
import prisma from "../../lib/prisma.js";
import { successResponse, errorResponse } from "../../utils/response.js";
import { compareOtp } from "../../utils/otp.js";

export const verifyOtp = async (req: Request, res: Response) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return errorResponse(res, "Email dan OTP wajib diisi", 400);
    }

    const normalizedEmail = String(email).toLowerCase().trim();

    const otpData = await prisma.otpCode.findFirst({
      where: {
        email: normalizedEmail,
        purpose: "VERIFY_EMAIL",
        verifiedAt: null,
      },
      orderBy: {
        createdAt: "desc",
      },
    });

    if (!otpData) {
      return errorResponse(res, "OTP tidak ditemukan", 404);
    }

    if (otpData.expiresAt < new Date()) {
      return errorResponse(res, "OTP sudah kedaluwarsa", 400);
    }

    const isOtpValid = await compareOtp(String(otp), otpData.codeHash);

    if (!isOtpValid) {
      return errorResponse(res, "OTP tidak valid", 400);
    }

    await prisma.$transaction(async (tx) => {
      await tx.otpCode.update({
        where: {
          id: otpData.id,
        },
        data: {
          verifiedAt: new Date(),
        },
      });

      await tx.user.update({
        where: {
          email: normalizedEmail,
        },
        data: {
          isEmailVerified: true,
        },
      });
    });

    return successResponse(res, "Verifikasi OTP berhasil");
  } catch (error) {
    console.error(error);
    return errorResponse(res, "Terjadi kesalahan pada server", 500);
  }
};
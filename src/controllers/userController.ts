import { Response } from "express";
import prisma from "../lib/prisma.js";
import { successResponse, errorResponse } from "../utils/response.js";
import { AuthRequest } from "../middlewares/authMiddleware.js";

// Endpoint: Update Profil User
export const updateProfile = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.id;
    if (!userId) return errorResponse(res, "Unauthorized", 401);

    const { fullName, phone, profileImage } = req.body;

    const dataToUpdate: any = {};
    if (fullName) dataToUpdate.fullName = fullName;
    if (phone !== undefined) dataToUpdate.phone = phone; 
    if (profileImage !== undefined) dataToUpdate.profileImage = profileImage;

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: dataToUpdate,
      select: {
        id: true,
        fullName: true,
        email: true,
        phone: true,
        profileImage: true,
      }
    });

    return successResponse(res, "Profil berhasil diperbarui", updatedUser);
  } catch (error) {
    console.error("UPDATE PROFILE ERROR:", error);
    return errorResponse(res, "Gagal memperbarui profil", 500);
  }
};

// Endpoint: Simpan Face Embedding dari Flutter
export const saveFaceEmbedding = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.id;
    if (!userId) return errorResponse(res, "Unauthorized", 401);

    const { embedding, deviceName, deviceId } = req.body;

    if (!embedding) {
      return errorResponse(res, "Data embedding wajah wajib disertakan", 400);
    }

    // Menonaktifkan credential wajah lama milik user ini (opsional, jika 1 user = 1 wajah aktif)
    await prisma.faceCredential.updateMany({
      where: { userId },
      data: { isActive: false }
    });

    // Menyimpan embedding wajah baru
    const newCredential = await prisma.faceCredential.create({
      data: {
        userId,
        embedding,
        deviceName,
        deviceId,
        isActive: true
      }
    });

    // Memperbarui status Face Recognition di tabel User
    await prisma.user.update({
      where: { id: userId },
      data: { isFaceRecognitionActive: true }
    });

    return successResponse(res, "Data wajah berhasil disimpan", newCredential);
  } catch (error) {
    console.error("SAVE FACE EMBEDDING ERROR:", error);
    return errorResponse(res, "Gagal menyimpan data wajah", 500);
  }
};

import prisma from "../lib/prisma.js";
import { successResponse, errorResponse } from "../utils/response.js";
// GET /api/experts - Get all experts with optional realtime search & filter
export const getAllExperts = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;
        const { search, type, city, isActive } = req.query;
        const whereClause = {};
        if (type) {
            const typeStr = String(type).toUpperCase();
            if (["PSYCHOLOGIST", "PSYCHIATRIST", "THERAPIST"].includes(typeStr)) {
                whereClause.type = typeStr;
            }
        }
        if (city) {
            whereClause.city = {
                contains: String(city),
                mode: "insensitive"
            };
        }
        if (isActive !== undefined) {
            whereClause.isActive = String(isActive) === "true";
        }
        else {
            whereClause.isActive = true;
        }
        if (search) {
            const searchStr = String(search);
            whereClause.OR = [
                {
                    name: {
                        contains: searchStr,
                        mode: "insensitive"
                    }
                },
                {
                    specialization: {
                        contains: searchStr,
                        mode: "insensitive"
                    }
                },
                {
                    city: {
                        contains: searchStr,
                        mode: "insensitive"
                    }
                },
                {
                    practiceAddress: {
                        contains: searchStr,
                        mode: "insensitive"
                    }
                }
            ];
        }
        // Fetch total count and experts concurrently
        const [experts, total] = await Promise.all([
            prisma.expert.findMany({
                where: whereClause,
                orderBy: {
                    rating: "desc" // Order by rating (highest first)
                },
                skip,
                take: limit,
            }),
            prisma.expert.count({
                where: whereClause
            })
        ]);
        return successResponse(res, "Daftar psikolog/expert berhasil diambil", {
            experts,
            meta: {
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit),
            }
        });
    }
    catch (error) {
        console.error("GET ALL EXPERTS ERROR:", error);
        return errorResponse(res, "Terjadi kesalahan pada server", 500);
    }
};
// GET /api/experts/:id - Get detail of a single expert by ID
export const getExpertById = async (req, res) => {
    try {
        const { id } = req.params;
        if (!id) {
            return errorResponse(res, "ID expert wajib diisi", 400);
        }
        const expert = await prisma.expert.findUnique({
            where: {
                id: String(id)
            }
        });
        if (!expert) {
            return errorResponse(res, "Psikolog/expert tidak ditemukan", 404);
        }
        return successResponse(res, "Detail psikolog/expert berhasil diambil", expert);
    }
    catch (error) {
        console.error("GET EXPERT BY ID ERROR:", error);
        return errorResponse(res, "Terjadi kesalahan pada server", 500);
    }
};
//# sourceMappingURL=expertController.js.map
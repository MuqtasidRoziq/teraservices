import prisma from "../lib/prisma.js";
import { successResponse, errorResponse } from "../utils/response.js";
import Article from "../models/Article.js";
export const getActivityStats = async (req, res) => {
    try {
        const childId = String(req.params.childId);
        const weeklyProgress = await prisma.weeklyActivityProgress.findFirst({
            where: { childId },
            orderBy: { weekStartDate: 'desc' }
        });
        console.log("Hasil query weeklyProgress:", weeklyProgress);
        return successResponse(res, "Data statistik dashboard berhasil diambil", {
            progressPercent: weeklyProgress?.progressPercent,
            completedActivity: weeklyProgress?.completedActivity,
            totalActivity: weeklyProgress?.totalActivity
        });
    }
    catch (error) {
        console.error("DASHBOARD STATS ERROR:", error);
        return errorResponse(res, "Gagal mengambil data dashboard", 500);
    }
};
export const getLastScreeningStats = async (req, res) => {
    try {
        const childId = String(req.params.childId);
        const lastScreening = await prisma.screeningSession.findFirst({
            where: { childId,
                status: 'COMPLETED' },
            orderBy: { completedAt: 'desc' }
        });
        return successResponse(res, "data statistik secreening trakhir diambil", {
            radar: lastScreening ? {
                labels: ["Komunikasi", "Motorik", "Kognitif", "Sosial"],
                values: [
                    lastScreening.communicationSpeechScore,
                    lastScreening.physicalMotorScore,
                    lastScreening.cognitiveProblemSolvingScore,
                    lastScreening.socialEmotionalScore
                ]
            } : null
        });
    }
    catch (error) {
        console.error(res, error);
        return errorResponse(res, "gagal mengambil data screening terakhir", 500);
    }
};
export const getscreeningHistoryStats = async (req, res) => {
    try {
        const childId = String(req.params.childId);
        const screeningHistory = await prisma.screeningSession.findMany({
            where: { childId,
                status: 'COMPLETED' },
            orderBy: { completedAt: 'asc' },
            take: 5
        });
        return successResponse(res, "data berhasil diambil", {
            trend: screeningHistory.map(s => ({
                date: s.completedAt?.toISOString().split('T')[0],
                score: s.finalScore
            }))
        });
    }
    catch (error) {
        console.error(res, error);
        return errorResponse(res, "gagal mengambil data screening terakhir", 500);
    }
};
export const getArticlesAnalysis = async (req, res) => {
    try {
        // 1. Fetch all raw articles from MongoDB
        const rawArticles = await Article.find().lean();
        const totalRaw = rawArticles.length;
        // 2. Preprocessing & Data Cleaning
        // Filter out articles with missing/null/undefined key fields (judul, isi, kategori)
        let nullJudul = 0;
        let nullIsi = 0;
        let nullKategori = 0;
        let cleanCount = 0;
        const cleanedArticles = rawArticles.filter((art) => {
            let isValid = true;
            if (!art.judul) {
                nullJudul++;
                isValid = false;
            }
            if (!art.isi) {
                nullIsi++;
                isValid = false;
            }
            if (!art.kategori) {
                nullKategori++;
                isValid = false;
            }
            if (isValid) {
                cleanCount++;
            }
            return isValid;
        });
        const totalRemoved = totalRaw - cleanCount;
        // 3. Perform Analytics
        // Graph 1: Distribution of ABK Categories (based on article classification)
        const categoryDistribution = {};
        const categories = ["ADHD", "Autisme", "Speech Delay"];
        // Initialize
        categories.forEach(cat => {
            categoryDistribution[cat] = { count: 0, percentage: 0 };
        });
        cleanedArticles.forEach((art) => {
            const cat = art.kategori.trim();
            let standardCat = "Other";
            if (/adhd/i.test(cat))
                standardCat = "ADHD";
            else if (/autis/i.test(cat))
                standardCat = "Autisme";
            else if (/speech/i.test(cat) || /bicara/i.test(cat))
                standardCat = "Speech Delay";
            if (!categoryDistribution[standardCat]) {
                categoryDistribution[standardCat] = { count: 0, percentage: 0 };
            }
            categoryDistribution[standardCat].count++;
        });
        // Calculate percentages
        Object.keys(categoryDistribution).forEach(key => {
            if (cleanCount > 0) {
                categoryDistribution[key].percentage = Number(((categoryDistribution[key].count / cleanCount) * 100).toFixed(2));
            }
        });
        // Graph 2: Article Complexity & Reading Time Analysis by Category
        const categoryMetrics = {};
        categories.forEach(cat => {
            categoryMetrics[cat] = {
                totalWords: 0,
                totalParagraphs: 0,
                averageWordCount: 0,
                averageParagraphs: 0,
                averageReadingTimeMinutes: 0,
                articleCount: 0
            };
        });
        cleanedArticles.forEach((art) => {
            const cat = art.kategori.trim();
            let standardCat = "Other";
            if (/adhd/i.test(cat))
                standardCat = "ADHD";
            else if (/autis/i.test(cat))
                standardCat = "Autisme";
            else if (/speech/i.test(cat) || /bicara/i.test(cat))
                standardCat = "Speech Delay";
            if (!categoryMetrics[standardCat]) {
                categoryMetrics[standardCat] = {
                    totalWords: 0,
                    totalParagraphs: 0,
                    averageWordCount: 0,
                    averageParagraphs: 0,
                    averageReadingTimeMinutes: 0,
                    articleCount: 0
                };
            }
            // Count words
            const isiText = art.isi || "";
            const wordCount = art.jumlah_kata || isiText.split(/\s+/).filter(Boolean).length;
            // Count paragraphs
            const paragraphCount = art.jumlah_paragraf || isiText.split(/\n+/).filter(Boolean).length;
            categoryMetrics[standardCat].totalWords += wordCount;
            categoryMetrics[standardCat].totalParagraphs += paragraphCount;
            categoryMetrics[standardCat].articleCount++;
        });
        // Calculate averages (Reading speed assumed 200 words per minute)
        Object.keys(categoryMetrics).forEach(key => {
            const metrics = categoryMetrics[key];
            if (metrics.articleCount > 0) {
                metrics.averageWordCount = Math.round(metrics.totalWords / metrics.articleCount);
                metrics.averageParagraphs = Number((metrics.totalParagraphs / metrics.articleCount).toFixed(1));
                metrics.averageReadingTimeMinutes = Number((metrics.averageWordCount / 200).toFixed(2));
            }
        });
        // Graph 3: Timeline trend of published articles by month
        const timelineTrend = {};
        cleanedArticles.forEach((art) => {
            let pubDateStr = art.tanggal_publikasi || art.tanggalPublikasi;
            if (!pubDateStr)
                return;
            const dateObj = new Date(pubDateStr);
            if (isNaN(dateObj.getTime()))
                return;
            const year = dateObj.getFullYear();
            const month = String(dateObj.getMonth() + 1).padStart(2, "0");
            const yearMonth = `${year}-${month}`; // e.g. "2024-01"
            const cat = art.kategori.trim();
            let standardCat = "Other";
            if (/adhd/i.test(cat))
                standardCat = "ADHD";
            else if (/autis/i.test(cat))
                standardCat = "Autisme";
            else if (/speech/i.test(cat) || /bicara/i.test(cat))
                standardCat = "Speech Delay";
            if (!timelineTrend[yearMonth]) {
                timelineTrend[yearMonth] = { ADHD: 0, Autisme: 0, "Speech Delay": 0, Other: 0 };
            }
            timelineTrend[yearMonth][standardCat] = (timelineTrend[yearMonth][standardCat] || 0) + 1;
        });
        // Convert timeline trend to sorted array
        const sortedTimeline = Object.keys(timelineTrend)
            .sort()
            .map(ym => ({
            month: ym,
            ADHD: timelineTrend[ym].ADHD || 0,
            Autisme: timelineTrend[ym].Autisme || 0,
            "Speech Delay": timelineTrend[ym]["Speech Delay"] || 0,
            total: (timelineTrend[ym].ADHD || 0) + (timelineTrend[ym].Autisme || 0) + (timelineTrend[ym]["Speech Delay"] || 0)
        }));
        // Graph 4: Keyword cloud focus per category
        const keyTermsMap = {
            ADHD: ["hiperaktif", "impulsif", "fokus", "konsentrasi", "terapi"],
            Autisme: ["sosial", "interaksi", "sensorik", "komunikasi", "rutinitas"],
            "Speech Delay": ["bicara", "bahasa", "terlambat", "artikulasi", "suara"]
        };
        const termFrequencies = {
            ADHD: {},
            Autisme: {},
            "Speech Delay": {}
        };
        // Initialize frequencies
        Object.entries(keyTermsMap).forEach(([cat, terms]) => {
            terms.forEach(term => {
                termFrequencies[cat][term] = 0;
            });
        });
        cleanedArticles.forEach((art) => {
            const cat = art.kategori.trim();
            let standardCat = "Other";
            if (/adhd/i.test(cat))
                standardCat = "ADHD";
            else if (/autis/i.test(cat))
                standardCat = "Autisme";
            else if (/speech/i.test(cat) || /bicara/i.test(cat))
                standardCat = "Speech Delay";
            if (standardCat === "Other" || !keyTermsMap[standardCat])
                return;
            const fullText = `${art.judul} ${art.isi}`.toLowerCase();
            keyTermsMap[standardCat].forEach(term => {
                const regex = new RegExp(`\\b${term}\\b|${term}`, "gi");
                const matches = fullText.match(regex);
                if (matches) {
                    termFrequencies[standardCat][term] += matches.length;
                }
            });
        });
        // Format term frequencies for visualization
        const formattedTermFrequencies = Object.entries(termFrequencies).reduce((acc, [cat, terms]) => {
            acc[cat] = Object.entries(terms).map(([term, count]) => ({ text: term, value: count }));
            return acc;
        }, {});
        // Return the response with all charts data
        return successResponse(res, "Analisis big data artikel MongoDB berhasil digenerate", {
            preprocessing: {
                totalRawData: totalRaw,
                totalCleanedData: cleanCount,
                recordsRemoved: totalRemoved,
                issuesFound: {
                    nullJudul,
                    nullIsi,
                    nullKategori
                },
                pipelineSteps: [
                    "Mengambil dokumen mentah dari koleksi articles di MongoDB",
                    "Memfilter record yang tidak memiliki field penting (judul, isi, kategori)",
                    "Menyaring kategori agar konsisten (ADHD, Autisme, Speech Delay)",
                    "Melakukan agregasi statistik untuk visualisasi grafik"
                ]
            },
            charts: {
                // Grafik 1: Distribusi tipe ABK di Indonesia berdasarkan representasi artikel
                abkCategoryDistribution: Object.entries(categoryDistribution).map(([name, data]) => ({
                    name,
                    count: data.count,
                    percentage: data.percentage
                })),
                // Grafik 2: Rata-rata waktu baca dan panjang artikel per kategori
                complexityMetrics: Object.entries(categoryMetrics).map(([category, data]) => ({
                    category,
                    averageWordCount: data.averageWordCount,
                    averageParagraphs: data.averageParagraphs,
                    averageReadingTimeMinutes: data.averageReadingTimeMinutes,
                    articleCount: data.articleCount
                })),
                // Grafik 3: Tren publikasi artikel per bulan
                timelineTrend: sortedTimeline,
                keywordFocus: formattedTermFrequencies
            }
        });
    }
    catch (error) {
        console.error("BIG DATA ANALYSIS ERROR:", error);
        return errorResponse(res, "Gagal memproses data analisis artikel", 500);
    }
};
//# sourceMappingURL=grafikController.js.map
import prisma from "../src/lib/prisma";
import fs from "fs";
import csv from "csv-parser";

// Helper function to map specialization to ExpertType
const mapExpertType = (specialization: string): "PSYCHOLOGIST" | "PSYCHIATRIST" | "THERAPIST" => {
  const s = specialization.toLowerCase();
  if (s.includes("psikolog")) {
    return "PSYCHOLOGIST";
  }
  if (s.includes("psikiater") || s.includes("jiwa") || s.includes("sp.kj")) {
    return "PSYCHIATRIST";
  }
  return "THERAPIST";
};

const seedExperts = async () => {
  const csvFilePath = "prisma/data/data_psikolog_halodoc.csv";
  const experts: any[] = [];

  console.log("Reading CSV Psychologist data...");

  return new Promise((resolve, reject) => {
    if (!fs.existsSync(csvFilePath)) {
      reject(new Error(`CSV file not found at: ${csvFilePath}`));
      return;
    }

    fs.createReadStream(csvFilePath)
      .pipe(csv({
        mapHeaders: ({ header }) => header.replace(/^\ufeff/, "").trim()
      }))
      .on("data", (row) => {
        // Skip empty rows or rows without Name
        if (!row.Nama) return;

        const name = row.Nama.trim();
        const specialization = row.Spesialis ? row.Spesialis.trim() : "Psikolog";
        const type = mapExpertType(specialization);

        // Clean experience
        const experience = (row.Pengalaman && row.Pengalaman !== "-") ? row.Pengalaman.trim() : null;

        // Clean rating (e.g. 88% -> 4.4 out of 5 stars)
        let rating: number | null = null;
        if (row.Rating && row.Rating !== "-") {
          const percentage = parseFloat(row.Rating.replace("%", ""));
          if (!isNaN(percentage)) {
            rating = parseFloat(((percentage / 100) * 5).toFixed(1));
          }
        }

        // Clean photo
        const photo = (row.Foto && row.Foto !== "-" && row.Foto !== "https://d1e8la4lqf1h28.cloudfront.net/images/dummy.jpg") ? row.Foto.trim() : null;

        // Clean practiceAddress & city
        const practiceAddress = (row["Tempat Praktik"] && row["Tempat Praktik"] !== "-") ? row["Tempat Praktik"].trim() : null;
        let city: string | null = null;
        if (practiceAddress) {
          const parts = practiceAddress.split(",");
          city = parts[0].trim();
          if (city === "." || city === "") {
            city = parts[1] ? parts[1].trim() : "Indonesia";
          }
        }

        // Custom focus categories based on specialization
        let focusCategories: string[] = [];
        const specLower = specialization.toLowerCase();
        if (specLower.includes("anak") || specLower.includes("remaja")) {
          focusCategories = ["Tumbuh Kembang Anak", "Konseling Anak & Remaja", "Kesehatan Mental Anak"];
        } else if (specLower.includes("dewasa")) {
          focusCategories = ["Kesehatan Mental Dewasa", "Manajemen Stres", "Konseling Keluarga"];
        } else {
          focusCategories = ["Kesehatan Mental", "Terapi Perilaku", "Konseling Umum"];
        }

        // Custom education
        let education: string | null = null;
        if (type === "PSYCHOLOGIST") {
          education = "S1 Psikologi, S2 Profesi Psikologi Klinis";
        } else if (type === "PSYCHIATRIST") {
          education = "Spesialis Kedokteran Jiwa (Sp.KJ)";
        } else {
          education = specialization.includes("Sp. Anak") || specialization.includes("Sp.A")
            ? "Spesialis Anak (Sp.A)"
            : "Sarjana Terapi & Sertifikasi Profesional";
        }

        // Custom bio
        const bio = experience
          ? `Seorang ${specialization} profesional dengan pengalaman selama ${experience} dalam memberikan pelayanan konsultasi dan pendampingan terbaik bagi pasien.`
          : `Seorang ${specialization} profesional yang berdedikasi memberikan pelayanan konsultasi terbaik.`;

        // Standard service types
        const serviceTypes = ["Konsultasi Chat", "Konsultasi Video Call", "Konsultasi Offline"];

        experts.push({
          name,
          title: specialization, // mapping specialization as title (e.g. Psikolog Klinis Anak & Remaja)
          type,
          photo,
          specialization,
          focusCategories,
          serviceTypes,
          experience,
          education,
          bio,
          rating,
          practiceAddress,
          city,
          latitude: null,
          longitude: null,
          whatsappNumber: "+6281234567890",
          instagramUrl: "https://www.instagram.com/halodoc",
          websiteUrl: "https://www.halodoc.com",
          isActive: true
        });
      })
      .on("end", async () => {
        console.log(`Successfully parsed ${experts.length} expert records. Saving to database...`);
        try {
          // Clean existing experts
          await prisma.expert.deleteMany({});

          // Save new experts
          const result = await prisma.expert.createMany({
            data: experts,
            skipDuplicates: true,
          });

          console.log(`✅ Success! Seeded ${result.count} experts into the database.`);
          resolve(true);
        } catch (error) {
          console.error("❌ Failed to save experts to database:", error);
          reject(error);
        } finally {
          await prisma.$disconnect();
        }
      })
      .on("error", (error) => {
        console.error("❌ Error reading CSV file:", error);
        reject(error);
      });
  });
};

seedExperts();

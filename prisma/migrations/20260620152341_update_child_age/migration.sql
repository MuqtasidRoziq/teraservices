/*
  Warnings:

  - You are about to drop the column `maxAgeMonths` on the `ActivityTemplate` table. All the data in the column will be lost.
  - You are about to drop the column `minAgeMonths` on the `ActivityTemplate` table. All the data in the column will be lost.
  - You are about to drop the column `ageYear` on the `Child` table. All the data in the column will be lost.
  - You are about to drop the column `maxAgeYears` on the `ScreeningQuestion` table. All the data in the column will be lost.
  - You are about to drop the column `minAgeYears` on the `ScreeningQuestion` table. All the data in the column will be lost.

*/
-- DropIndex
DROP INDEX "ScreeningQuestion_minAgeYears_maxAgeYears_idx";

-- AlterTable
ALTER TABLE "ActivityTemplate" DROP COLUMN "maxAgeMonths",
DROP COLUMN "minAgeMonths",
ADD COLUMN     "maxAgeMonth" INTEGER,
ADD COLUMN     "minAgeMonth" INTEGER;

-- AlterTable
ALTER TABLE "Child" DROP COLUMN "ageYear";

-- AlterTable
ALTER TABLE "ScreeningQuestion" DROP COLUMN "maxAgeYears",
DROP COLUMN "minAgeYears",
ADD COLUMN     "maxAgeMonth" INTEGER,
ADD COLUMN     "minAgeMonth" INTEGER;

-- CreateIndex
CREATE INDEX "ScreeningQuestion_minAgeMonth_maxAgeMonth_idx" ON "ScreeningQuestion"("minAgeMonth", "maxAgeMonth");

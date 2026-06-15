/*
  Warnings:

  - You are about to drop the column `totalScore` on the `ScreeningSession` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "ScreeningQuestion" ADD COLUMN     "maxAgeYears" INTEGER,
ADD COLUMN     "minAgeYears" INTEGER,
ADD COLUMN     "sourceAuthor" TEXT,
ADD COLUMN     "sourceTitle" TEXT,
ADD COLUMN     "sourceUrl" TEXT,
ADD COLUMN     "sourceYear" INTEGER;

-- AlterTable
ALTER TABLE "ScreeningSession" DROP COLUMN "totalScore",
ADD COLUMN     "cognitiveProblemSolvingPercentage" DOUBLE PRECISION NOT NULL DEFAULT 0,
ADD COLUMN     "communicationSpeechPercentage" DOUBLE PRECISION NOT NULL DEFAULT 0,
ADD COLUMN     "finalScore" DOUBLE PRECISION NOT NULL DEFAULT 0,
ADD COLUMN     "physicalMotorPercentage" DOUBLE PRECISION NOT NULL DEFAULT 0,
ADD COLUMN     "rawTotalScore" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "socialEmotionalPercentage" DOUBLE PRECISION NOT NULL DEFAULT 0;

-- CreateIndex
CREATE INDEX "ScreeningQuestion_minAgeYears_maxAgeYears_idx" ON "ScreeningQuestion"("minAgeYears", "maxAgeYears");

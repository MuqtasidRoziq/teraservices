/*
  Warnings:

  - You are about to drop the column `sourceAuthor` on the `ScreeningQuestion` table. All the data in the column will be lost.
  - You are about to drop the column `sourceTitle` on the `ScreeningQuestion` table. All the data in the column will be lost.
  - You are about to drop the column `sourceUrl` on the `ScreeningQuestion` table. All the data in the column will be lost.
  - You are about to drop the column `sourceYear` on the `ScreeningQuestion` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "ScreeningQuestion" DROP COLUMN "sourceAuthor",
DROP COLUMN "sourceTitle",
DROP COLUMN "sourceUrl",
DROP COLUMN "sourceYear";

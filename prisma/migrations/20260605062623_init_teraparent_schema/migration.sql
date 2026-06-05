-- CreateEnum
CREATE TYPE "Role" AS ENUM ('USER', 'ADMIN');

-- CreateEnum
CREATE TYPE "Gender" AS ENUM ('MALE', 'FEMALE');

-- CreateEnum
CREATE TYPE "OtpPurpose" AS ENUM ('VERIFY_EMAIL', 'RESET_PASSWORD');

-- CreateEnum
CREATE TYPE "ScreeningDomain" AS ENUM ('COMMUNICATION_SPEECH', 'PHYSICAL_MOTOR', 'COGNITIVE_PROBLEM_SOLVING', 'SOCIAL_EMOTIONAL');

-- CreateEnum
CREATE TYPE "QuestionType" AS ENUM ('YES_NO', 'SCALE', 'MULTIPLE_CHOICE');

-- CreateEnum
CREATE TYPE "ScreeningStatus" AS ENUM ('IN_PROGRESS', 'COMPLETED');

-- CreateEnum
CREATE TYPE "IndicationType" AS ENUM ('ADHD', 'AUTISM', 'SPEECH_DELAY', 'DEVELOPMENT_CONCERN');

-- CreateEnum
CREATE TYPE "ActivityStatus" AS ENUM ('NOT_STARTED', 'IN_PROGRESS', 'COMPLETED', 'MISSED');

-- CreateEnum
CREATE TYPE "DifficultyLevel" AS ENUM ('EASY', 'MEDIUM', 'HARD');

-- CreateEnum
CREATE TYPE "ExpertType" AS ENUM ('PSYCHOLOGIST', 'PSYCHIATRIST', 'THERAPIST');

-- CreateEnum
CREATE TYPE "ExpertActionType" AS ENUM ('VIEW', 'WHATSAPP', 'INSTAGRAM', 'WEBSITE', 'SCHEDULE_WHATSAPP');

-- CreateEnum
CREATE TYPE "FaceAuthStatus" AS ENUM ('SUCCESS', 'FAILED');

-- CreateTable
CREATE TABLE "User" (
    "id" SERIAL NOT NULL,
    "fullName" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "phone" TEXT,
    "role" "Role" NOT NULL DEFAULT 'USER',
    "profileImage" TEXT,
    "isEmailVerified" BOOLEAN NOT NULL DEFAULT false,
    "isFaceRecognitionActive" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OtpCode" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER,
    "email" TEXT NOT NULL,
    "codeHash" TEXT NOT NULL,
    "purpose" "OtpPurpose" NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "verifiedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "OtpCode_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FaceCredential" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "embedding" JSONB NOT NULL,
    "deviceName" TEXT,
    "deviceId" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "FaceCredential_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FaceAuthLog" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER,
    "email" TEXT,
    "status" "FaceAuthStatus" NOT NULL,
    "distance" DOUBLE PRECISION,
    "threshold" DOUBLE PRECISION,
    "deviceInfo" TEXT,
    "ipAddress" TEXT,
    "message" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "FaceAuthLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Child" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "birthDate" TIMESTAMP(3),
    "ageMonths" INTEGER,
    "gender" "Gender" NOT NULL,
    "heightCm" DOUBLE PRECISION NOT NULL,
    "weightKg" DOUBLE PRECISION NOT NULL,
    "initialDevelopmentNote" TEXT,
    "photo" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Child_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "GrowthRecord" (
    "id" SERIAL NOT NULL,
    "childId" INTEGER NOT NULL,
    "heightCm" DOUBLE PRECISION NOT NULL,
    "weightKg" DOUBLE PRECISION NOT NULL,
    "recordedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "note" TEXT,

    CONSTRAINT "GrowthRecord_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ScreeningQuestion" (
    "id" SERIAL NOT NULL,
    "domain" "ScreeningDomain" NOT NULL,
    "question" TEXT NOT NULL,
    "type" "QuestionType" NOT NULL,
    "isRequired" BOOLEAN NOT NULL DEFAULT true,
    "orderNumber" INTEGER NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ScreeningQuestion_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ScreeningOption" (
    "id" SERIAL NOT NULL,
    "questionId" INTEGER NOT NULL,
    "label" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "score" INTEGER NOT NULL DEFAULT 0,
    "orderNumber" INTEGER NOT NULL,

    CONSTRAINT "ScreeningOption_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ScreeningSession" (
    "id" SERIAL NOT NULL,
    "childId" INTEGER NOT NULL,
    "status" "ScreeningStatus" NOT NULL DEFAULT 'IN_PROGRESS',
    "progressCurrentStep" INTEGER NOT NULL DEFAULT 0,
    "progressTotalStep" INTEGER NOT NULL DEFAULT 0,
    "totalScore" INTEGER NOT NULL DEFAULT 0,
    "communicationSpeechScore" INTEGER NOT NULL DEFAULT 0,
    "physicalMotorScore" INTEGER NOT NULL DEFAULT 0,
    "cognitiveProblemSolvingScore" INTEGER NOT NULL DEFAULT 0,
    "socialEmotionalScore" INTEGER NOT NULL DEFAULT 0,
    "mainIndication" "IndicationType",
    "indicationSummary" TEXT,
    "resultDescription" TEXT,
    "recommendationText" TEXT,
    "disclaimerText" TEXT NOT NULL DEFAULT 'Hasil screening ini bukan diagnosis final dan tidak menggantikan pemeriksaan profesional.',
    "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ScreeningSession_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ScreeningAnswer" (
    "id" SERIAL NOT NULL,
    "screeningSessionId" INTEGER NOT NULL,
    "questionId" INTEGER NOT NULL,
    "optionId" INTEGER,
    "answerValue" TEXT,
    "score" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ScreeningAnswer_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ActivityTemplate" (
    "id" SERIAL NOT NULL,
    "title" TEXT NOT NULL,
    "domain" "ScreeningDomain" NOT NULL,
    "relatedIndication" "IndicationType",
    "minAgeMonths" INTEGER,
    "maxAgeMonths" INTEGER,
    "description" TEXT NOT NULL,
    "purpose" TEXT NOT NULL,
    "durationMinutes" INTEGER NOT NULL,
    "difficulty" "DifficultyLevel" NOT NULL DEFAULT 'EASY',
    "toolsNeeded" JSONB,
    "steps" JSONB NOT NULL,
    "successIndicator" TEXT NOT NULL,
    "parentTips" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ActivityTemplate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DailyActivity" (
    "id" SERIAL NOT NULL,
    "childId" INTEGER NOT NULL,
    "screeningSessionId" INTEGER,
    "templateId" INTEGER,
    "title" TEXT NOT NULL,
    "domain" "ScreeningDomain" NOT NULL,
    "relatedIndication" "IndicationType",
    "description" TEXT NOT NULL,
    "purpose" TEXT NOT NULL,
    "durationMinutes" INTEGER NOT NULL,
    "difficulty" "DifficultyLevel" NOT NULL DEFAULT 'EASY',
    "toolsNeeded" JSONB,
    "steps" JSONB NOT NULL,
    "successIndicator" TEXT NOT NULL,
    "parentTips" TEXT,
    "scheduledDate" TIMESTAMP(3) NOT NULL,
    "reminderAt" TIMESTAMP(3),
    "status" "ActivityStatus" NOT NULL DEFAULT 'NOT_STARTED',
    "startedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "missedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "DailyActivity_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ActivityNote" (
    "id" SERIAL NOT NULL,
    "dailyActivityId" INTEGER NOT NULL,
    "childResponse" TEXT,
    "successLevel" INTEGER,
    "obstacleNote" TEXT,
    "parentNote" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ActivityNote_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WeeklyActivityProgress" (
    "id" SERIAL NOT NULL,
    "childId" INTEGER NOT NULL,
    "weekStartDate" TIMESTAMP(3) NOT NULL,
    "weekEndDate" TIMESTAMP(3) NOT NULL,
    "totalActivity" INTEGER NOT NULL DEFAULT 0,
    "completedActivity" INTEGER NOT NULL DEFAULT 0,
    "missedActivity" INTEGER NOT NULL DEFAULT 0,
    "progressPercent" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "WeeklyActivityProgress_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Expert" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "title" TEXT,
    "type" "ExpertType" NOT NULL,
    "photo" TEXT,
    "specialization" TEXT NOT NULL,
    "focusCategories" TEXT[],
    "serviceTypes" TEXT[],
    "experience" TEXT,
    "education" TEXT,
    "bio" TEXT,
    "rating" DOUBLE PRECISION,
    "practiceAddress" TEXT,
    "city" TEXT,
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "whatsappNumber" TEXT,
    "instagramUrl" TEXT,
    "websiteUrl" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Expert_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ExpertInteraction" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "childId" INTEGER,
    "expertId" INTEGER NOT NULL,
    "screeningSessionId" INTEGER,
    "actionType" "ExpertActionType" NOT NULL,
    "autoMessage" TEXT,
    "externalUrl" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ExpertInteraction_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "OtpCode_email_idx" ON "OtpCode"("email");

-- CreateIndex
CREATE INDEX "OtpCode_purpose_idx" ON "OtpCode"("purpose");

-- CreateIndex
CREATE INDEX "FaceCredential_userId_idx" ON "FaceCredential"("userId");

-- CreateIndex
CREATE INDEX "FaceCredential_isActive_idx" ON "FaceCredential"("isActive");

-- CreateIndex
CREATE INDEX "FaceAuthLog_userId_idx" ON "FaceAuthLog"("userId");

-- CreateIndex
CREATE INDEX "FaceAuthLog_email_idx" ON "FaceAuthLog"("email");

-- CreateIndex
CREATE INDEX "FaceAuthLog_status_idx" ON "FaceAuthLog"("status");

-- CreateIndex
CREATE INDEX "Child_userId_idx" ON "Child"("userId");

-- CreateIndex
CREATE INDEX "GrowthRecord_childId_idx" ON "GrowthRecord"("childId");

-- CreateIndex
CREATE INDEX "GrowthRecord_recordedAt_idx" ON "GrowthRecord"("recordedAt");

-- CreateIndex
CREATE INDEX "ScreeningQuestion_domain_idx" ON "ScreeningQuestion"("domain");

-- CreateIndex
CREATE INDEX "ScreeningQuestion_orderNumber_idx" ON "ScreeningQuestion"("orderNumber");

-- CreateIndex
CREATE INDEX "ScreeningOption_questionId_idx" ON "ScreeningOption"("questionId");

-- CreateIndex
CREATE INDEX "ScreeningSession_childId_idx" ON "ScreeningSession"("childId");

-- CreateIndex
CREATE INDEX "ScreeningSession_status_idx" ON "ScreeningSession"("status");

-- CreateIndex
CREATE INDEX "ScreeningSession_completedAt_idx" ON "ScreeningSession"("completedAt");

-- CreateIndex
CREATE INDEX "ScreeningAnswer_screeningSessionId_idx" ON "ScreeningAnswer"("screeningSessionId");

-- CreateIndex
CREATE INDEX "ScreeningAnswer_questionId_idx" ON "ScreeningAnswer"("questionId");

-- CreateIndex
CREATE INDEX "ActivityTemplate_domain_idx" ON "ActivityTemplate"("domain");

-- CreateIndex
CREATE INDEX "ActivityTemplate_relatedIndication_idx" ON "ActivityTemplate"("relatedIndication");

-- CreateIndex
CREATE INDEX "DailyActivity_childId_idx" ON "DailyActivity"("childId");

-- CreateIndex
CREATE INDEX "DailyActivity_scheduledDate_idx" ON "DailyActivity"("scheduledDate");

-- CreateIndex
CREATE INDEX "DailyActivity_status_idx" ON "DailyActivity"("status");

-- CreateIndex
CREATE INDEX "DailyActivity_domain_idx" ON "DailyActivity"("domain");

-- CreateIndex
CREATE UNIQUE INDEX "ActivityNote_dailyActivityId_key" ON "ActivityNote"("dailyActivityId");

-- CreateIndex
CREATE INDEX "WeeklyActivityProgress_childId_idx" ON "WeeklyActivityProgress"("childId");

-- CreateIndex
CREATE INDEX "WeeklyActivityProgress_weekStartDate_idx" ON "WeeklyActivityProgress"("weekStartDate");

-- CreateIndex
CREATE INDEX "Expert_type_idx" ON "Expert"("type");

-- CreateIndex
CREATE INDEX "Expert_city_idx" ON "Expert"("city");

-- CreateIndex
CREATE INDEX "Expert_isActive_idx" ON "Expert"("isActive");

-- CreateIndex
CREATE INDEX "ExpertInteraction_userId_idx" ON "ExpertInteraction"("userId");

-- CreateIndex
CREATE INDEX "ExpertInteraction_childId_idx" ON "ExpertInteraction"("childId");

-- CreateIndex
CREATE INDEX "ExpertInteraction_expertId_idx" ON "ExpertInteraction"("expertId");

-- CreateIndex
CREATE INDEX "ExpertInteraction_actionType_idx" ON "ExpertInteraction"("actionType");

-- AddForeignKey
ALTER TABLE "OtpCode" ADD CONSTRAINT "OtpCode_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FaceCredential" ADD CONSTRAINT "FaceCredential_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FaceAuthLog" ADD CONSTRAINT "FaceAuthLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Child" ADD CONSTRAINT "Child_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GrowthRecord" ADD CONSTRAINT "GrowthRecord_childId_fkey" FOREIGN KEY ("childId") REFERENCES "Child"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ScreeningOption" ADD CONSTRAINT "ScreeningOption_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES "ScreeningQuestion"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ScreeningSession" ADD CONSTRAINT "ScreeningSession_childId_fkey" FOREIGN KEY ("childId") REFERENCES "Child"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ScreeningAnswer" ADD CONSTRAINT "ScreeningAnswer_screeningSessionId_fkey" FOREIGN KEY ("screeningSessionId") REFERENCES "ScreeningSession"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ScreeningAnswer" ADD CONSTRAINT "ScreeningAnswer_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES "ScreeningQuestion"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ScreeningAnswer" ADD CONSTRAINT "ScreeningAnswer_optionId_fkey" FOREIGN KEY ("optionId") REFERENCES "ScreeningOption"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DailyActivity" ADD CONSTRAINT "DailyActivity_childId_fkey" FOREIGN KEY ("childId") REFERENCES "Child"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DailyActivity" ADD CONSTRAINT "DailyActivity_screeningSessionId_fkey" FOREIGN KEY ("screeningSessionId") REFERENCES "ScreeningSession"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DailyActivity" ADD CONSTRAINT "DailyActivity_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES "ActivityTemplate"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ActivityNote" ADD CONSTRAINT "ActivityNote_dailyActivityId_fkey" FOREIGN KEY ("dailyActivityId") REFERENCES "DailyActivity"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WeeklyActivityProgress" ADD CONSTRAINT "WeeklyActivityProgress_childId_fkey" FOREIGN KEY ("childId") REFERENCES "Child"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ExpertInteraction" ADD CONSTRAINT "ExpertInteraction_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ExpertInteraction" ADD CONSTRAINT "ExpertInteraction_childId_fkey" FOREIGN KEY ("childId") REFERENCES "Child"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ExpertInteraction" ADD CONSTRAINT "ExpertInteraction_expertId_fkey" FOREIGN KEY ("expertId") REFERENCES "Expert"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ExpertInteraction" ADD CONSTRAINT "ExpertInteraction_screeningSessionId_fkey" FOREIGN KEY ("screeningSessionId") REFERENCES "ScreeningSession"("id") ON DELETE SET NULL ON UPDATE CASCADE;

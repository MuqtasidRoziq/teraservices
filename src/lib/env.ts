import "dotenv/config";

export const ENV = {
  PORT: Number(process.env.PORT) || 3000,
  NODE_ENV: process.env.NODE_ENV || "development",
  DATABASE_URL: process.env.DATABASE_URL || "",
  JWT_SECRET: process.env.JWT_SECRET || "secret_dev",
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || "7d"
};
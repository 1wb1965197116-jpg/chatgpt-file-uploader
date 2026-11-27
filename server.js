import express from "express";
import multer from "multer";
import path from "node:path";
import fs from "node:fs";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const app = express();
const port = Number(process.env.PORT || 10000);
const uploadDir = process.env.UPLOAD_DIR || path.join(__dirname, "uploads");
fs.mkdirSync(uploadDir, { recursive: true });

const allowed = new Set([
  ".pdf", ".txt", ".md", ".docx", ".csv", ".json",
  ".png", ".jpg", ".jpeg", ".webp"
]);
const upload = multer({
  dest: uploadDir,
  limits: { fileSize: 20 * 1024 * 1024, files: 5 },
  fileFilter: (_req, file, callback) => {
    const ext = path.extname(file.originalname || "").toLowerCase();
    if (!allowed.has(ext)) return callback(new Error("Unsupported file type. Upload PDF, DOCX, TXT, MD, CSV, JSON, PNG, JPG, or WEBP files."));
    callback(null, true);
  }
});

app.disable("x-powered-by");
app.use(express.static(path.join(__dirname, "frontend/public")));

const buckets = new Map();
function uploadRateLimit(req, res, next) {
  const now = Date.now();
  const key = req.ip || req.socket.remoteAddress || "unknown";
  let bucket = buckets.get(key);
  if (!bucket || now >= bucket.resetAt) bucket = { count: 0, resetAt: now + 15 * 60 * 1000 };
  bucket.count += 1;
  buckets.set(key, bucket);
  if (bucket.count > 5) return res.status(429).json({ error: "Upload limit reached. Wait 15 minutes and try again." });
  next();
}

app.get("/health", (_req, res) => res.json({ ok: true, app: "ChatGPT File Uploader", maxFileBytes: 20 * 1024 * 1024 }));
app.get("/", (_req, res) => res.sendFile(path.join(__dirname, "frontend/public/index.html")));

app.post("/upload", uploadRateLimit, upload.array("files", 5), (req, res) => {
  if (!req.files?.length) return res.status(400).json({ error: "Select at least one supported file." });
  return res.json({
    status: "ok",
    persistence: process.env.UPLOAD_DIR ? "configured directory" : "temporary local storage",
    files: req.files.map(file => ({
      originalName: path.basename(file.originalname),
      size: file.size,
      mimeType: file.mimetype,
      storedName: file.filename
    }))
  });
});

app.use((err, _req, res, _next) => {
  if (err instanceof multer.MulterError) {
    const message = err.code === "LIMIT_FILE_SIZE" ? "Each file must be 20 MB or smaller." : "Upload limit exceeded.";
    return res.status(400).json({ error: message });
  }
  if (err.message?.startsWith("Unsupported file type")) return res.status(415).json({ error: err.message });
  console.error("Upload error:", err.message);
  return res.status(500).json({ error: "Upload failed." });
});

app.listen(port, "0.0.0.0", () => console.log("File Uploader listening on " + port));

// server.js
import express from "express";
import multer from "multer";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = 5000;

// Uploads folder
const uploadDir = path.join(__dirname, "uploads");

// Configure multer
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => cb(null, file.originalname)
});
const upload = multer({ storage });

// Enable JSON & form data parsing
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Upload endpoint
app.post("/upload", upload.array("files"), (req, res) => {
  if (!req.files || req.files.length === 0) {
    return res.status(400).send("No files uploaded.");
  }
  console.log(`Uploaded ${req.files.length} file(s)`);
  res.send("Files uploaded successfully!");
});

// Simple health check
app.get("/", (req, res) => res.send("Backend is running!"));

// Start server
app.listen(PORT, () => console.log(`Backend running at http://localhost:${PORT}`));

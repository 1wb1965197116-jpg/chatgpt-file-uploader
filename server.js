import express from "express";
import multer from "multer";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = 5000;

const upload = multer({ dest: path.join(__dirname, "uploads/") });

// Serve frontend static files
app.use(express.static(path.join(__dirname, "../frontend/public")));

// Handle file uploads
app.post("/upload", upload.array("files"), (req, res) => {
  console.log("Files uploaded:", req.files);
  res.send({ status: "ok", files: req.files.map(f => f.originalname) });
});

app.listen(PORT, () => {
  console.log(`Backend running at http://localhost:${PORT}`);
});

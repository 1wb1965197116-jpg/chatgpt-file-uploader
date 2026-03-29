import express from 'express';
import multer from 'multer';
import cors from 'cors';
import dotenv from 'dotenv';
dotenv.config();

const app = express();
app.use(cors());
const upload = multer({ dest: 'uploads/' });

app.post('/upload', upload.array('files'), (req,res)=>{ res.json({status:"OK"}); });
app.get('/', (req,res)=>res.send("Backend Live"));

app.listen(process.env.PORT || 3001, ()=>console.log("Backend running"));

import express, { type Express, type Request, type Response } from 'express';
import connection from "./db/index.js";
import { z } from 'zod';
import cors from 'cors'; // Gunakan import ES Module

const app: Express = express();
const port = 3000;

// Middleware CORS
app.use(cors());
app.use(express.json());

const CategorySchema = z.object({
  name: z.string().min(1, "Nama Kategori Wajib diisi"),
});

const PostSchema = z.object({
  category_id: z.number().int().positive(),
  title: z.string().min(1, "Judul wajib diisi"),
  content: z.string().min(1, "Konten wajib diisi"),
  author: z.string().min(1, "Author wajib diisi"),
});

// ================= CATEGORIES =================

app.get("/api/categories", async (req: Request, res: Response) => {
  const [data] = await connection.query(
    "SELECT * FROM categories"
  );

  res.status(200).json({
    message: "Get all categories",
    data: data
  });
});

app.get("/api/categories/:id", async (req: Request, res: Response) => {
  const [data] = await connection.query(
    "SELECT * FROM categories WHERE id = ?",
    [req.params.id]
  );

  res.status(200).json({
    message: "Get category by id",
    data: data
  });
});

app.post("/api/categories", async (req: Request, res: Response) => {
  try {
    const data = CategorySchema.parse(req.body);

    await connection.query(
      "INSERT INTO categories (name) VALUES (?)",
      [data.name]
    );

    res.status(201).json({
      message: "Category berhasil ditambahkan",
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: "Validasi gagal",
        errors: error.issues,
      });
    }

    res.status(500).json({
      message: "Internal Server Error",
    });
  }
});

app.put("/api/categories/:id", async (req: Request, res: Response) => {
  try {
    const data = CategorySchema.parse(req.body);

    await connection.query(
      "UPDATE categories SET name = ? WHERE id = ?",
      [data.name, req.params.id]
    );

    res.status(200).json({
      message: "Category berhasil diupdate",
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: "Validasi gagal",
        errors: error.issues,
      });
    }

    res.status(500).json({
      message: "Internal Server Error",
    });
  }
});

app.delete("/api/categories/:id", async (req: Request, res: Response) => {
  await connection.query(
    "DELETE FROM categories WHERE id = ?",
    [req.params.id]
  );

  res.status(200).json({
    message: "Category berhasil dihapus",
  });
});

// ================= POSTS =================

app.get("/api/posts", async (req: Request, res: Response) => {
  const [data] = await connection.query(`
    SELECT posts.*, categories.name AS category_name 
    FROM posts 
    LEFT JOIN categories ON posts.category_id = categories.id
  `);
  res.json({ message: "Get all posts", data });
});

app.get("/api/posts/:id", async (req: Request, res: Response) => {
  const [data]: any = await connection.query("SELECT * FROM posts WHERE id = ?", [req.params.id]);
  
  if (data.length === 0) {
    return res.status(404).json({ message: "Post tidak ditemukan" });
  }
  
  res.json({ message: "Get post by id", data: data[0] });
});

app.post("/api/posts", async (req: Request, res: Response) => {
  try {
    const data = PostSchema.parse(req.body);
    await connection.query(
      "INSERT INTO posts (category_id, title, content, author) VALUES (?, ?, ?, ?)",
      [data.category_id, data.title, data.content, data.author]
    );
    res.status(201).json({ message: "Post berhasil ditambahkan" });
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
});

app.put("/api/posts/:id", async (req: Request, res: Response) => {
  try {
    const data = PostSchema.parse(req.body);
    await connection.query(
      "UPDATE posts SET category_id = ?, title = ?, content = ?, author = ? WHERE id = ?",
      [data.category_id, data.title, data.content, data.author, req.params.id]
    );
    res.json({ message: "Post berhasil diperbarui" });
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
});

app.delete("/api/posts/:id", async (req: Request, res: Response) => {
  await connection.query("DELETE FROM posts WHERE id = ?", [req.params.id]);
  res.json({ message: "Post berhasil dihapus" });
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
const express = require("express");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { OAuth2Client } = require("google-auth-library");
const db = require("../models/db");
require("dotenv").config();

const router = express.Router();
const GOOGLE_CLIENT_ID = process.env.GOOGLE_CLIENT_ID;
const JWT_SECRET = process.env.JWT_SECRET;
const client = new OAuth2Client(GOOGLE_CLIENT_ID);

// Đăng ký
router.post("/register", async (req, res) => {
  const { username, password } = req.body;
  const hashedPassword = await bcrypt.hash(password, 10);

  db.query("INSERT INTO users (username, password) VALUES (?, ?)", [username, hashedPassword], (err) => {
    if (err) return res.status(400).json({ error: "Tên đăng nhập đã tồn tại" });
    res.json({ message: "Đăng ký thành công" });
  });
});

// Đăng nhập
router.post("/login", (req, res) => {
  const { username, password } = req.body;

  db.query("SELECT * FROM users WHERE username = ?", [username], async (err, results) => {
    if (err || results.length === 0) return res.status(400).json({ error: "Tài khoản không tồn tại" });

    const isMatch = await bcrypt.compare(password, results[0].password);
    if (!isMatch) return res.status(400).json({ error: "Mật khẩu không đúng" });

    const token = jwt.sign({ id: results[0].id, username }, JWT_SECRET, { expiresIn: "7d" });
    res.json({ token, username });
  });
});

// Đăng nhập với Google
router.post("/google-login", async (req, res) => {
  const { idToken } = req.body;
  try {
    const ticket = await client.verifyIdToken({ idToken, audience: GOOGLE_CLIENT_ID });
    const { sub: googleId, email, name, picture } = ticket.getPayload();

    db.query("SELECT * FROM users WHERE googleId = ? OR email = ?", [googleId, email], (err, results) => {
      if (results.length === 0) {
        db.query("INSERT INTO users (googleId, email, username, photoUrl) VALUES (?, ?, ?, ?)", [googleId, email, name, picture]);
      }

      const token = jwt.sign({ email }, JWT_SECRET, { expiresIn: "7d" });
      res.json({ token, username: name, email, photoUrl: picture });
    });
  } catch (error) {
    res.status(500).json({ error: "Lỗi xác thực Google" });
  }
});

// Đảm bảo export đúng
module.exports = router;

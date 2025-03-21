const express = require("express");
const db = require("../models/db");

const router = express.Router();

// Lấy danh sách user (trừ user hiện tại)
router.get("/users/:username", (req, res) => {
  const username = req.params.username;
  db.query("SELECT username FROM users WHERE username != ?", [username], (err, results) => {
    if (err) return res.status(500).json({ error: "Lỗi lấy danh sách user" });
    res.json(results.map(user => user.username));
  });
});

// Gửi lời mời kết bạn
router.post("/friend-request", (req, res) => {
  const { from, to } = req.body;

  db.query("INSERT INTO friends (user1, user2, status) VALUES (?, ?, 'pending')", [from, to], (err) => {
    if (err) return res.status(400).json({ error: "Lời mời đã tồn tại hoặc lỗi" });
    res.json({ message: "Lời mời kết bạn đã được gửi" });
  });
});

// Chấp nhận lời mời kết bạn
router.post("/accept-friend-request", (req, res) => {
  const { from, to } = req.body;

  db.query("UPDATE friends SET status='accepted' WHERE user1=? AND user2=?", [from, to], (err, result) => {
    if (err || result.affectedRows === 0) return res.status(400).json({ error: "Không tìm thấy lời mời" });
    res.json({ message: "Hai bạn đã trở thành bạn bè!" });
  });
});

module.exports = router;

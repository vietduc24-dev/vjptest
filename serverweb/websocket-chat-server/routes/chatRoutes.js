const express = require("express");
const db = require("../models/db");
const { decryptMessage } = require("../encryption");

const router = express.Router();

// Lấy lịch sử tin nhắn giữa hai người dùng
router.get("/messages/:sender/:receiver", (req, res) => {
  const { sender, receiver } = req.params;

  db.query(
    `SELECT sender, receiver, message FROM messages 
     WHERE (sender = ? AND receiver = ?) OR (sender = ? AND receiver = ?) 
     ORDER BY id ASC`,
    [sender, receiver, receiver, sender],
    (err, results) => {
      if (err) return res.status(500).json({ error: "Lỗi lấy lịch sử tin nhắn" });

      const messageHistory = results.map(msg => ({
        sender: msg.sender,
        receiver: msg.receiver,
        message: decryptMessage(msg.message),
      }));

      res.json(messageHistory);
    }
  );
});

// Đảm bảo export đúng
module.exports = router;

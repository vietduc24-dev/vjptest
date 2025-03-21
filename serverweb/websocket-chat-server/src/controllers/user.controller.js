const db = require('../config/database');

class UserController {
  async searchUsers(req, res) {
    try {
      const { q } = req.query;

      if (!q || q.trim().length < 2) {
        return res.status(400).json({ message: "Từ khóa tìm kiếm phải có ít nhất 2 ký tự" });
      }

      const [users] = await db.query(
        "SELECT username, full_name, avatar_url FROM users WHERE username LIKE ? AND username != ?",
        [`%${q}%`, req.user.username]
      );

      res.json(users.map(user => ({
        username: user.username,
        fullName: user.full_name,
        avatarUrl: user.avatar_url
      })));
    } catch (error) {
      console.error("❌ Lỗi tìm kiếm người dùng:", error);
      res.status(500).json({ message: "Lỗi server" });
    }
  }
}

module.exports = new UserController(); 
const db = require('../config/database');

class FriendController {
  async getFriends(req, res) {
    try {
      const [friends] = await db.query(
        `SELECT u.username, u.full_name, u.avatar_url
         FROM users u
         INNER JOIN friends f ON (
           (f.user1 = ? AND f.user2 = u.username) OR 
           (f.user2 = ? AND f.user1 = u.username)
         )
         WHERE f.status = 'accepted'`,
        [req.user.username, req.user.username]
      );

      res.json(friends.map(f => ({
        username: f.username,
        fullName: f.full_name,
        avatarUrl: f.avatar_url
      })));
    } catch (error) {
      console.error("❌ Lỗi lấy danh sách bạn bè:", error);
      res.status(500).json({ message: "Lỗi server" });
    }
  }

  async getFriendRequests(req, res) {
    try {
      const [requests] = await db.query(
        `SELECT u.username, u.full_name, u.avatar_url
         FROM users u
         INNER JOIN friends f ON f.user1 = u.username
         WHERE f.user2 = ? AND f.status = 'pending'`,
        [req.user.username]
      );

      res.json(requests);
    } catch (error) {
      console.error("❌ Lỗi lấy danh sách lời mời kết bạn:", error);
      res.status(500).json({ message: "Lỗi server" });
    }
  }

  async sendFriendRequest(req, res) {
    try {
      const { to } = req.body;

      await db.query(
        "INSERT INTO friends (user1, user2) VALUES (?, ?)",
        [req.user.username, to]
      );

      res.json({ message: "Đã gửi lời mời kết bạn" });
    } catch (error) {
      console.error("❌ Lỗi gửi lời mời kết bạn:", error);
      res.status(500).json({ message: "Lỗi server" });
    }
  }

  async acceptFriendRequest(req, res) {
    try {
      const { username } = req.params;

      await db.query(
        "UPDATE friends SET status = 'accepted' WHERE user1 = ? AND user2 = ? AND status = 'pending'",
        [username, req.user.username]
      );

      res.json({ message: "Đã chấp nhận lời mời kết bạn" });
    } catch (error) {
      console.error("❌ Lỗi chấp nhận lời mời kết bạn:", error);
      res.status(500).json({ message: "Lỗi server" });
    }
  }

  async rejectFriendRequest(req, res) {
    try {
      const { username } = req.params;

      await db.query(
        "DELETE FROM friends WHERE user1 = ? AND user2 = ? AND status = 'pending'",
        [username, req.user.username]
      );

      res.json({ message: "Đã từ chối lời mời kết bạn" });
    } catch (error) {
      console.error("❌ Lỗi từ chối lời mời kết bạn:", error);
      res.status(500).json({ message: "Lỗi server" });
    }
  }
}

module.exports = new FriendController(); 
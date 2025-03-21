const db = require('../config/database');
const { decryptMessage } = require('../utils/encryption');

class MessageController {
  async getPersonalMessages(req, res) {
    try {
      const { username } = req.params;
      const currentUser = req.user.username;

      // Kiểm tra mối quan hệ bạn bè
      const [friends] = await db.query(
        "SELECT * FROM friends WHERE ((user1 = ? AND user2 = ?) OR (user1 = ? AND user2 = ?)) AND status = 'accepted'",
        [currentUser, username, username, currentUser]
      );

      if (friends.length === 0) {
        return res.status(403).json({ message: "Bạn chưa kết bạn với người này" });
      }

      // Lấy lịch sử tin nhắn
      const [messages] = await db.query(
        `SELECT sender, receiver, message, created_at 
         FROM messages 
         WHERE (sender = ? AND receiver = ?) OR (sender = ? AND receiver = ?)
         ORDER BY created_at ASC`,
        [currentUser, username, username, currentUser]
      );

      // Giải mã tin nhắn
      const decryptedMessages = messages.map(msg => {
        try {
          return {
            sender: msg.sender,
            receiver: msg.receiver,
            message: decryptMessage(msg.message),
            timestamp: msg.created_at
          };
        } catch (error) {
          console.error("❌ Lỗi giải mã tin nhắn:", error);
          return {
            sender: msg.sender,
            receiver: msg.receiver,
            message: "Lỗi giải mã tin nhắn",
            timestamp: msg.created_at
          };
        }
      });

      res.json(decryptedMessages);
    } catch (error) {
      console.error("❌ Lỗi lấy lịch sử tin nhắn:", error);
      res.status(500).json({ message: "Lỗi server" });
    }
  }

  async getGroupMessages(req, res) {
    try {
      const { groupId } = req.params;
      const currentUser = req.user.username;

      // Kiểm tra người dùng có trong nhóm không
      const [members] = await db.query(
        "SELECT * FROM group_members WHERE group_id = ? AND username = ?",
        [groupId, currentUser]
      );

      if (members.length === 0) {
        return res.status(403).json({ message: "Bạn không phải thành viên của nhóm này" });
      }

      // Lấy lịch sử tin nhắn nhóm
      const [messages] = await db.query(
        `SELECT gm.*, u.full_name as sender_name, u.avatar_url as sender_avatar
         FROM group_messages gm
         JOIN users u ON gm.sender = u.username
         WHERE gm.group_id = ?
         ORDER BY gm.sent_at ASC`,
        [groupId]
      );

      // Giải mã tin nhắn
      const decryptedMessages = messages.map(msg => {
        try {
          return {
            id: msg.id,
            groupId: msg.group_id,
            sender: msg.sender,
            senderName: msg.sender_name,
            senderAvatar: msg.sender_avatar,
            message: decryptMessage(msg.message),
            timestamp: msg.sent_at
          };
        } catch (error) {
          console.error("❌ Lỗi giải mã tin nhắn nhóm:", error);
          return {
            id: msg.id,
            groupId: msg.group_id,
            sender: msg.sender,
            senderName: msg.sender_name,
            senderAvatar: msg.sender_avatar,
            message: "Lỗi giải mã tin nhắn",
            timestamp: msg.sent_at
          };
        }
      });

      res.json(decryptedMessages);
    } catch (error) {
      console.error("❌ Lỗi lấy tin nhắn nhóm:", error);
      res.status(500).json({ message: "Lỗi server" });
    }
  }
}

module.exports = new MessageController(); 
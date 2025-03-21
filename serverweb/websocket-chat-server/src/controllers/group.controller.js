const db = require('../config/database');
const crypto = require('crypto');

class GroupController {
  async createGroup(req, res) {
    try {
      const { name, members } = req.body;
      const groupId = crypto.randomUUID();

      await db.query(
        "INSERT INTO groups (id, name, creator) VALUES (?, ?, ?)",
        [groupId, name, req.user.username]
      );

      const memberValues = [...members, req.user.username].map(member => [groupId, member]);
      await db.query(
        "INSERT INTO group_members (group_id, username) VALUES ?",
        [memberValues]
      );

      res.status(201).json({
        message: "Tạo nhóm thành công",
        group: {
          id: groupId,
          name,
          creator: req.user.username,
          members: [...members, req.user.username]
        }
      });
    } catch (error) {
      console.error("❌ Lỗi tạo nhóm:", error);
      res.status(500).json({ message: "Lỗi server" });
    }
  }

  async getGroups(req, res) {
    try {
      const [groups] = await db.query(
        `SELECT g.*, COUNT(gm.username) as member_count 
         FROM groups g 
         JOIN group_members gm ON g.id = gm.group_id 
         WHERE g.id IN (SELECT group_id FROM group_members WHERE username = ?)
         GROUP BY g.id`,
        [req.user.username]
      );

      res.json(groups);
    } catch (error) {
      console.error("❌ Lỗi lấy danh sách nhóm:", error);
      res.status(500).json({ message: "Lỗi server" });
    }
  }

  async getGroupInfo(req, res) {
    try {
      const { groupId } = req.params;

      const [groups] = await db.query(
        `SELECT g.*, GROUP_CONCAT(gm.username) as members
         FROM groups g
         JOIN group_members gm ON g.id = gm.group_id
         WHERE g.id = ? AND EXISTS (
           SELECT 1 FROM group_members 
           WHERE group_id = g.id AND username = ?
         )
         GROUP BY g.id`,
        [groupId, req.user.username]
      );

      if (groups.length === 0) {
        return res.status(404).json({ message: "Không tìm thấy nhóm hoặc bạn không phải thành viên" });
      }

      const group = groups[0];
      group.members = group.members.split(',');

      res.json(group);
    } catch (error) {
      console.error("❌ Lỗi lấy thông tin nhóm:", error);
      res.status(500).json({ message: "Lỗi server" });
    }
  }

  async addMember(req, res) {
    try {
      const { groupId } = req.params;
      const { username } = req.body;

      // Kiểm tra quyền
      const [groups] = await db.query(
        "SELECT * FROM groups WHERE id = ? AND creator = ?",
        [groupId, req.user.username]
      );

      if (groups.length === 0) {
        return res.status(403).json({ message: "Bạn không có quyền thêm thành viên" });
      }

      await db.query(
        "INSERT INTO group_members (group_id, username) VALUES (?, ?)",
        [groupId, username]
      );

      res.json({ message: "Đã thêm thành viên vào nhóm" });
    } catch (error) {
      console.error("❌ Lỗi thêm thành viên:", error);
      res.status(500).json({ message: "Lỗi server" });
    }
  }

  async removeMember(req, res) {
    try {
      const { groupId, username } = req.params;

      // Kiểm tra quyền
      const [groups] = await db.query(
        "SELECT * FROM groups WHERE id = ? AND creator = ?",
        [groupId, req.user.username]
      );

      if (groups.length === 0) {
        return res.status(403).json({ message: "Bạn không có quyền xóa thành viên" });
      }

      await db.query(
        "DELETE FROM group_members WHERE group_id = ? AND username = ?",
        [groupId, username]
      );

      res.json({ message: "Đã xóa thành viên khỏi nhóm" });
    } catch (error) {
      console.error("❌ Lỗi xóa thành viên:", error);
      res.status(500).json({ message: "Lỗi server" });
    }
  }

  async leaveGroup(req, res) {
    try {
      const { groupId } = req.params;

      // Kiểm tra không phải creator
      const [groups] = await db.query(
        "SELECT * FROM groups WHERE id = ? AND creator = ?",
        [groupId, req.user.username]
      );

      if (groups.length > 0) {
        return res.status(400).json({ message: "Creator không thể rời nhóm" });
      }

      await db.query(
        "DELETE FROM group_members WHERE group_id = ? AND username = ?",
        [groupId, req.user.username]
      );

      res.json({ message: "Đã rời khỏi nhóm" });
    } catch (error) {
      console.error("❌ Lỗi rời nhóm:", error);
      res.status(500).json({ message: "Lỗi server" });
    }
  }
}

module.exports = new GroupController(); 
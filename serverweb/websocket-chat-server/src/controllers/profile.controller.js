const db = require('../config/database');

class ProfileController {
  async getProfile(req, res) {
    try {
      const [users] = await db.query(
        "SELECT username, company_name, full_name, phone, nationality, package_type, avatar_url FROM users WHERE username = ?",
        [req.user.username]
      );

      if (users.length === 0) {
        return res.status(404).json({ message: "Không tìm thấy thông tin người dùng" });
      }

      const user = users[0];
      res.json({
        username: user.username,
        companyName: user.company_name,
        fullName: user.full_name,
        phone: user.phone,
        nationality: user.nationality,
        packageType: user.package_type,
        avatarUrl: user.avatar_url
      });
    } catch (error) {
      console.error("❌ Lỗi lấy profile:", error);
      res.status(500).json({ message: "Lỗi server" });
    }
  }

  async updateProfile(req, res) {
    try {
      const { companyName, phone } = req.body;

      // Validate phone number
      const phoneRegex = /^[0-9]{10,11}$/;
      if (!phoneRegex.test(phone)) {
        return res.status(400).json({ message: "Số điện thoại không hợp lệ" });
      }

      await db.query(
        "UPDATE users SET company_name = ?, phone = ? WHERE username = ?",
        [companyName, phone, req.user.username]
      );

      res.json({ message: "Cập nhật thông tin thành công" });
    } catch (error) {
      console.error("❌ Lỗi cập nhật profile:", error);
      res.status(500).json({ message: "Lỗi server" });
    }
  }

  async uploadAvatar(req, res) {
    try {
      if (!req.file) {
        return res.status(400).json({ message: "Không có file được upload" });
      }

      const avatarUrl = req.file.path;

      await db.query(
        "UPDATE users SET avatar_url = ? WHERE username = ?",
        [avatarUrl, req.user.username]
      );

      res.json({
        message: "Upload avatar thành công",
        avatarUrl
      });
    } catch (error) {
      console.error("❌ Lỗi upload avatar:", error);
      res.status(500).json({ message: "Lỗi upload avatar" });
    }
  }
}

module.exports = new ProfileController(); 
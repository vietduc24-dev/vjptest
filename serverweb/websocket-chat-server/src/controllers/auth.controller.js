const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../config/database');

class AuthController {
  async register(req, res) {
    try {
      const { username, password, companyName, fullName, phone, nationality, packageType, referralCode } = req.body;

      // Validate input
      if (!username || !password || !companyName || !fullName || !phone || !nationality || !packageType) {
        return res.status(400).json({ message: "Vui lòng điền đầy đủ thông tin" });
      }

      // Validate email format
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(username)) {
        return res.status(400).json({ message: "Email không hợp lệ" });
      }
      // Validate phone number
      const phoneRegex = /^[0-9]{10,11}$/;
      if (!phoneRegex.test(phone)) {
        return res.status(400).json({ message: "Số điện thoại không hợp lệ" });
      }
      // Check if email exists
      const [users] = await db.query("SELECT username FROM users WHERE username = ?", [username]);
      if (users.length > 0) {
        return res.status(400).json({ message: "Email đã được sử dụng" });
      }
      // Hash password
      const hashedPassword = await bcrypt.hash(password, 10);
      // Insert new user
      const [result] = await db.query(
        `INSERT INTO users (username, password, company_name, full_name, phone, nationality, package_type, referral_code)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [username, hashedPassword, companyName, fullName, phone, nationality, packageType, referralCode]
      );
      // Generate JWT token
      const token = jwt.sign({ username }, process.env.JWT_SECRET, { expiresIn: '24h' });
      res.status(201).json({
        message: "Đăng ký thành công",
        token,
        user: {
          username,
          companyName,
          fullName,
          phone,
          nationality,
          packageType,
          referralCode
        }
      });
    } catch (error) {
      console.error("❌ Lỗi đăng ký:", error);
      res.status(500).json({ message: "Lỗi server" });
    }
  }

  async login(req, res) {
    try {
      const { username, password } = req.body;

      const [users] = await db.query("SELECT * FROM users WHERE username = ?", [username]);
      if (users.length === 0) {
        return res.status(401).json({ message: "Tài khoản không tồn tại" });
      }

      const user = users[0];
      const match = await bcrypt.compare(password, user.password);
      if (!match) {
        return res.status(401).json({ message: "Mật khẩu không đúng" });
      }

      const token = jwt.sign({ username }, process.env.JWT_SECRET, { expiresIn: '24h' });

      res.json({
        message: "Đăng nhập thành công",
        token,
        user: {
          username: user.username,
          companyName: user.company_name,
          fullName: user.full_name,
          phone: user.phone,
          nationality: user.nationality,
          packageType: user.package_type,
          avatarUrl: user.avatar_url
        }
      });
    } catch (error) {
      console.error("❌ Lỗi đăng nhập:", error);
      res.status(500).json({ message: "Lỗi server" });
    }
  }

  async googleLogin(req, res) {
    try {
      const { email, displayName, photoURL } = req.body;

      // Check if user exists
      const [users] = await db.query("SELECT * FROM users WHERE username = ?", [email]);
      
      let user;
      if (users.length === 0) {
        // Create new user
        const [result] = await db.query(
          `INSERT INTO users (username, full_name, avatar_url, nationality, package_type)
           VALUES (?, ?, ?, ?, ?)`,
          [email, displayName || email.split('@')[0], photoURL, 'VN', 'Basic']
        );

        user = {
          username: email,
          fullName: displayName || email.split('@')[0],
          avatarUrl: photoURL,
          nationality: 'VN',
          packageType: 'Basic'
        };
      } else {
        user = users[0];
      }

      const token = jwt.sign({ username: email }, process.env.JWT_SECRET, { expiresIn: '24h' });

      res.json({
        message: "Đăng nhập Google thành công",
        token,
        user: {
          username: user.username,
          fullName: user.full_name,
          companyName: user.company_name,
          phone: user.phone,
          nationality: user.nationality,
          packageType: user.package_type,
          avatarUrl: user.avatar_url
        }
      });
    } catch (error) {
      console.error("❌ Lỗi đăng nhập Google:", error);
      res.status(500).json({ message: "Lỗi server" });
    }
  }
}

module.exports = new AuthController(); 
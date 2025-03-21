const WebSocket = require('ws');
const jwt = require('jsonwebtoken');
const db = require('../config/database');
const { encryptMessage, decryptMessage } = require('../utils/encryption');

class WebSocketService {
  constructor() {
    this.server = null;
    this.clients = new Map(); // Map lưu trữ các client đã đăng nhập: key là socket, value là username
  }

  initialize(port = 8090) {
    this.server = new WebSocket.Server({ port });
    console.log(`🚀 WebSocket Server running on ws://localhost:${port}`);

    this.server.on('connection', this.handleConnection.bind(this));
  }

  handleConnection(socket) {
    console.log("🔵 New client connected");

    socket.on('message', async (message) => {
      let data;
      try {
        data = JSON.parse(message);
      } catch (e) {
        console.error("❌ Lỗi parse JSON:", e);
        return;
      }

      // Xử lý xác thực WebSocket
      if (data.type === 'ws_auth') {
        this.handleAuthentication(socket, data);
      }
      // Gửi tin nhắn cá nhân
      else if (data.type === 'message') {
        this.handlePersonalMessage(socket, data);
      }
      // Gửi tin nhắn nhóm
      else if (data.type === 'group_message') {
        this.handleGroupMessage(socket, data);
      }
    });

    socket.on('close', () => {
      this.clients.delete(socket);
      console.log("🔴 Client disconnected");
    });
  }

  async handleAuthentication(socket, data) {
    if (!data.token) {
      return socket.send(JSON.stringify({ type: "error", message: "Token không hợp lệ" }));
    }

    try {
      const decoded = jwt.verify(data.token, process.env.JWT_SECRET);
      this.clients.set(socket, decoded.username);
      socket.send(JSON.stringify({ type: "ws_auth_success" }));
      console.log(`✅ Client authenticated: ${decoded.username}`);
    } catch (error) {
      console.error("❌ Lỗi xác thực token:", error);
      socket.send(JSON.stringify({ type: "error", message: "Token không hợp lệ" }));
    }
  }

  async handlePersonalMessage(socket, data) {
    // Kiểm tra đăng nhập
    if (!this.clients.has(socket)) {
      return socket.send(JSON.stringify({ type: "error", message: "Bạn chưa đăng nhập" }));
    }

    const sender = this.clients.get(socket);
    
    // Kiểm tra tính hợp lệ của người gửi
    if (sender !== data.sender) {
      return socket.send(JSON.stringify({ type: "error", message: "Người gửi không hợp lệ" }));
    }

    try {
      // Kiểm tra mối quan hệ bạn bè
      const [friends] = await db.query(
        "SELECT * FROM friends WHERE ((user1 = ? AND user2 = ?) OR (user1 = ? AND user2 = ?)) AND status = 'accepted'",
        [sender, data.receiver, data.receiver, sender]
      );

      if (friends.length === 0) {
        return socket.send(JSON.stringify({ type: "error", message: "Bạn chưa kết bạn với người này" }));
      }

      // Lưu tin nhắn vào DB
      const encryptedText = encryptMessage(data.message);
      await db.query(
        "INSERT INTO messages (sender, receiver, message) VALUES (?, ?, ?)",
        [sender, data.receiver, encryptedText]
      );

      console.log("✅ Tin nhắn đã được lưu vào DB.");
      
      // Gửi tin nhắn cho các client liên quan (người gửi và người nhận)
      this.server.clients.forEach(client => {
        const clientUsername = this.clients.get(client);
        if (client.readyState === WebSocket.OPEN &&
            (clientUsername === sender || clientUsername === data.receiver)) {
          client.send(JSON.stringify({
            type: "message",
            sender: sender,
            receiver: data.receiver,
            message: data.message,
            timestamp: new Date().toISOString()
          }));
        }
      });
    } catch (error) {
      console.error("❌ Lỗi xử lý tin nhắn cá nhân:", error);
      socket.send(JSON.stringify({ type: "error", message: "Lỗi gửi tin nhắn" }));
    }
  }

  async handleGroupMessage(socket, data) {
    // Kiểm tra đăng nhập
    if (!this.clients.has(socket)) {
      return socket.send(JSON.stringify({ type: "error", message: "Bạn chưa đăng nhập" }));
    }

    const sender = this.clients.get(socket);
    
    // Kiểm tra tính hợp lệ của người gửi
    if (sender !== data.sender) {
      return socket.send(JSON.stringify({ type: "error", message: "Người gửi không hợp lệ" }));
    }

    try {
      // Kiểm tra người gửi có trong nhóm không
      const [members] = await db.query(
        "SELECT * FROM group_members WHERE group_id = ? AND username = ?",
        [data.group_id, sender]
      );

      if (members.length === 0) {
        return socket.send(JSON.stringify({ type: "error", message: "Bạn không phải thành viên của nhóm này" }));
      }

      // Lưu tin nhắn vào database
      const encryptedMessage = encryptMessage(data.message);
      await db.query(
        "INSERT INTO group_messages (group_id, sender, message) VALUES (?, ?, ?)",
        [data.group_id, sender, encryptedMessage]
      );

      // Lấy danh sách thành viên nhóm
      const [groupMembers] = await db.query(
        "SELECT username FROM group_members WHERE group_id = ?",
        [data.group_id]
      );

      // Gửi tin nhắn cho tất cả thành viên trong nhóm
      const memberUsernames = groupMembers.map(m => m.username);
      this.server.clients.forEach(client => {
        const clientUsername = this.clients.get(client);
        if (client.readyState === WebSocket.OPEN && memberUsernames.includes(clientUsername)) {
          client.send(JSON.stringify({
            type: "group_message",
            group_id: data.group_id,
            sender: sender,
            message: data.message,
            timestamp: new Date().toISOString()
          }));
        }
      });
    } catch (error) {
      console.error("❌ Lỗi xử lý tin nhắn nhóm:", error);
      socket.send(JSON.stringify({ type: "error", message: "Lỗi gửi tin nhắn" }));
    }
  }
}

module.exports = new WebSocketService(); 
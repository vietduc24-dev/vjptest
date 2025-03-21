const WebSocket = require("ws");
const db = require("../models/db");
const { encryptMessage } = require("../encryption");


// Map lưu trữ các client đã đăng nhập: key là socket, value là username
let clients = new Map();

module.exports = (server) => {
  const wss = new WebSocket.Server({ server });

  wss.on("connection", (socket) => {
    console.log("🔵 New client connected");

    socket.on("message", (message) => {
      let data;
      try {
        data = JSON.parse(message);
      } catch (e) {
        console.error("❌ Lỗi parse JSON:", e);
        return;
      }

      // Xác thực đăng nhập
      if (data.type === "login") {
        const { username } = data;
        clients.set(socket, username);
        console.log(`✅ ${username} đã kết nối vào WebSocket`);
        socket.send(JSON.stringify({ type: "login_success", username }));
      }

      // Gửi tin nhắn
      else if (data.type === "message") {
        const sender = clients.get(socket);
        const { receiver, message } = data;

        // Lưu tin nhắn vào DB
        const encryptedText = encryptMessage(message);
        db.query(
          "INSERT INTO messages (sender, receiver, message) VALUES (?, ?, ?)",
          [sender, receiver, encryptedText],
          (err) => {
            if (err) {
              console.error("❌ Lỗi lưu tin nhắn:", err);
              return;
            }

            console.log(`📩 Tin nhắn từ ${sender} -> ${receiver}: ${message}`);

            // Gửi tin nhắn cho cả người gửi và người nhận
            wss.clients.forEach((client) => {
              if (clients.get(client) === receiver || clients.get(client) === sender) {
                client.send(JSON.stringify({ type: "message", sender, receiver, message }));
              }
            });
          }
        );
      }
    });

    socket.on("close", () => {
      clients.delete(socket);
      console.log("🔴 Client disconnected");
    });
  });
};

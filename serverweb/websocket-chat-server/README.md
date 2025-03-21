# Chat Server API

Hệ thống chat server với REST API và WebSocket.

## Cấu trúc dự án

```
websocket-chat-server/
├── src/
│   ├── config/         # Cấu hình database, multer, ...
│   ├── controllers/    # Xử lý logic cho các routes
│   ├── middlewares/    # Middleware xác thực, ...
│   ├── models/         # Mô hình dữ liệu
│   ├── routes/         # Định nghĩa routes
│   ├── services/       # Services (WebSocket, ...)
│   ├── utils/          # Tiện ích (mã hóa, ...)
│   └── app.js          # Express app
├── .env                # Biến môi trường
├── package.json        # Thông tin dự án và dependencies
└── server.js           # Entry point
```

## Cài đặt

1. Clone repository
2. Cài đặt dependencies:
   ```
   npm install
   ```
3. Tạo file `.env` với các biến môi trường cần thiết
4. Khởi động server:
   ```
   npm start
   ```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Đăng ký tài khoản
- `POST /api/auth/login` - Đăng nhập
- `POST /api/auth/google-login` - Đăng nhập bằng Google

### Profile
- `GET /api/profile` - Lấy thông tin profile
- `PUT /api/profile` - Cập nhật profile
- `POST /api/profile/upload-avatar` - Upload avatar

### Friends
- `GET /api/friends` - Lấy danh sách bạn bè
- `GET /api/friends/requests` - Lấy danh sách lời mời kết bạn
- `POST /api/friends/requests` - Gửi lời mời kết bạn
- `PUT /api/friends/requests/:username/accept` - Chấp nhận lời mời kết bạn
- `DELETE /api/friends/requests/:username` - Từ chối lời mời kết bạn

### Groups
- `POST /api/groups` - Tạo nhóm chat
- `GET /api/groups` - Lấy danh sách nhóm
- `GET /api/groups/:groupId` - Lấy thông tin nhóm
- `POST /api/groups/:groupId/members` - Thêm thành viên vào nhóm
- `DELETE /api/groups/:groupId/members/:username` - Xóa thành viên khỏi nhóm
- `DELETE /api/groups/:groupId/leave` - Rời nhóm

### Messages
- `GET /api/messages/personal/:username` - Lấy lịch sử tin nhắn cá nhân
- `GET /api/messages/group/:groupId` - Lấy lịch sử tin nhắn nhóm

### Users
- `GET /api/users/search` - Tìm kiếm người dùng

## WebSocket

WebSocket được sử dụng cho việc gửi/nhận tin nhắn realtime.

### Xác thực WebSocket
```javascript
// Kết nối WebSocket
const socket = new WebSocket('ws://localhost:8090');

// Xác thực
socket.send(JSON.stringify({
  type: 'ws_auth',
  token: 'your_jwt_token'
}));
```

### Gửi tin nhắn cá nhân
```javascript
socket.send(JSON.stringify({
  type: 'message',
  sender: 'user1@example.com',
  receiver: 'user2@example.com',
  message: 'Hello!'
}));
```

### Gửi tin nhắn nhóm
```javascript
socket.send(JSON.stringify({
  type: 'group_message',
  sender: 'user1@example.com',
  group_id: 'group_uuid',
  message: 'Hello everyone!'
}));
``` 
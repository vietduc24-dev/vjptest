const app = require('./src/app');
const websocketService = require('./src/services/websocket.service');
require('dotenv').config();

const PORT = process.env.PORT || 3000;

// Khởi động REST API server
app.listen(PORT, () => {
  console.log(`🚀 REST API Server running on http://localhost:${PORT}`);
});

// Khởi động WebSocket server
websocketService.initialize(8090);

console.log('✅ Server started successfully'); 
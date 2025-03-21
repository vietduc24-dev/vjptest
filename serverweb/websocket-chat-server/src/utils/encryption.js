const crypto = require('crypto');
require('dotenv').config();

const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY || 'your-secret-key-32-chars-long-123'; // Phải đủ 32 ký tự
const IV_LENGTH = 16; // Độ dài của IV cho AES

/**
 * Mã hóa tin nhắn
 * @param {string} text - Tin nhắn cần mã hóa
 * @returns {string} - Tin nhắn đã mã hóa dạng JSON
 */
function encryptMessage(text) {
  try {
    const iv = crypto.randomBytes(IV_LENGTH);
    const cipher = crypto.createCipheriv('aes-256-cbc', Buffer.from(ENCRYPTION_KEY), iv);
    let encrypted = cipher.update(text);
    encrypted = Buffer.concat([encrypted, cipher.final()]);
    
    const encryptedData = {
      iv: iv.toString('hex'),
      content: encrypted.toString('hex')
    };
    
    return JSON.stringify(encryptedData);
  } catch (error) {
    console.error('❌ Lỗi mã hóa tin nhắn:', error);
    return JSON.stringify({ error: 'Encryption failed' });
  }
}

/**
 * Giải mã tin nhắn
 * @param {string} encryptedJson - Tin nhắn đã mã hóa dạng JSON
 * @returns {string} - Tin nhắn gốc
 */
function decryptMessage(encryptedJson) {
  try {
    const encryptedData = JSON.parse(encryptedJson);
    const iv = Buffer.from(encryptedData.iv, 'hex');
    const encryptedText = Buffer.from(encryptedData.content, 'hex');
    const decipher = crypto.createDecipheriv('aes-256-cbc', Buffer.from(ENCRYPTION_KEY), iv);
    let decrypted = decipher.update(encryptedText);
    decrypted = Buffer.concat([decrypted, decipher.final()]);
    return decrypted.toString();
  } catch (error) {
    console.error('❌ Lỗi giải mã tin nhắn:', error);
    return 'Decryption failed';
  }
}

module.exports = {
  encryptMessage,
  decryptMessage
}; 
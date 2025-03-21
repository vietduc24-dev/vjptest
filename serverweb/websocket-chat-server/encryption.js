const CryptoJS = require("crypto-js");

const SECRET_KEY = "my32charlongsupersecretkey123456"; // Chính xác 32 ký tự


function encryptMessage(message) {
    const key = CryptoJS.enc.Utf8.parse(SECRET_KEY);
    const iv = CryptoJS.lib.WordArray.random(16);

    const encrypted = CryptoJS.AES.encrypt(message, key, {
        iv: iv,
        mode: CryptoJS.mode.CBC,
        padding: CryptoJS.pad.Pkcs7,
    });

    console.log("🔑 IV khi mã hóa:", CryptoJS.enc.Base64.stringify(iv));
    console.log("🔐 Tin nhắn sau khi mã hóa:", encrypted.toString());

    return JSON.stringify({
        iv: CryptoJS.enc.Base64.stringify(iv),
        message: encrypted.toString(),
    });
}
// Decrypt message
function decryptMessage(encryptedMessage) {
    try {
        console.log("📥 Dữ liệu tin nhắn nhận được:", encryptedMessage);

        if (!encryptedMessage.startsWith("{") || !encryptedMessage.endsWith("}")) {
            console.warn("⚠️ Tin nhắn không phải JSON hợp lệ:", encryptedMessage);
            return encryptedMessage;
        }

        const data = JSON.parse(encryptedMessage);

        if (!data.iv || !data.message) {
            console.error("❌ Thiếu IV hoặc message:", data);
            return "🔴 Dữ liệu mã hóa bị lỗi";
        }

        const key = CryptoJS.enc.Utf8.parse(SECRET_KEY);
        const iv = CryptoJS.enc.Base64.parse(data.iv);

        console.log("🔑 IV khi giải mã:", data.iv);
        console.log("🔑 SECRET_KEY khi giải mã:", SECRET_KEY);
        console.log("🔑 Độ dài SECRET_KEY:", SECRET_KEY.length);

        const decrypted = CryptoJS.AES.decrypt(data.message, key, {
            iv: iv,
            mode: CryptoJS.mode.CBC,
            padding: CryptoJS.pad.Pkcs7,
        });

        const decryptedText = decrypted.toString(CryptoJS.enc.Utf8);

        console.log("🔓 Tin nhắn sau khi giải mã:", decryptedText);

        if (!decryptedText) {
            throw new Error("🔴 Giải mã ra chuỗi rỗng");
        }

        return decryptedText;
    } catch (e) {
        console.error("❌ Lỗi giải mã tin nhắn:", e);
        return "🔴 Lỗi giải mã";
    }
}


module.exports = { encryptMessage, decryptMessage };

const crypto = require("crypto");

const TOKEN_LIFETIME_SECONDS = 60 * 60 * 24 * 7;

function getSecret() {
  return process.env.TOKEN_SECRET || "dev-secret-change-me";
}

function toBase64Url(text) {
  return Buffer.from(text, "utf8").toString("base64url");
}

function sign(input) {
  return crypto
    .createHmac("sha256", getSecret())
    .update(input)
    .digest("base64url");
}

function issueToken(userId) {
  const payload = {
    sub: userId,
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + TOKEN_LIFETIME_SECONDS
  };
  const encoded = toBase64Url(JSON.stringify(payload));
  const signature = sign(encoded);
  return `${encoded}.${signature}`;
}

function verifyToken(token) {
  if (!token || !token.includes(".")) {
    return null;
  }

  const [encoded, incomingSig] = token.split(".");
  const validSig = sign(encoded);
  if (incomingSig !== validSig) {
    return null;
  }

  const payload = JSON.parse(Buffer.from(encoded, "base64url").toString("utf8"));
  if (payload.exp < Math.floor(Date.now() / 1000)) {
    return null;
  }

  return payload;
}

module.exports = {
  issueToken,
  verifyToken
};

const crypto = require("crypto");
const store = require("../store/jsonStore");
const { hashPassword, verifyPassword } = require("./passwordService");

function toPublicUser(user) {
  return {
    id: user.id,
    name: user.name,
    phone: user.phone,
    createdAt: user.createdAt
  };
}

function createUser({ name, phone, password }) {
  let created = null;

  store.transaction((db) => {
    const existing = db.users.find((u) => u.phone === phone);
    if (existing) {
      const error = new Error("Phone already registered");
      error.statusCode = 409;
      throw error;
    }

    created = {
      id: crypto.randomUUID(),
      name,
      phone,
      passwordHash: hashPassword(password),
      createdAt: new Date().toISOString()
    };

    db.users.push(created);
    return db;
  });

  return toPublicUser(created);
}

function authenticate({ phone, password }) {
  const db = store.read();
  const user = db.users.find((u) => u.phone === phone);
  if (!user || !verifyPassword(password, user.passwordHash)) {
    const error = new Error("Invalid phone or password");
    error.statusCode = 401;
    throw error;
  }
  return toPublicUser(user);
}

function findById(userId) {
  const db = store.read();
  const user = db.users.find((u) => u.id === userId);
  return user ? toPublicUser(user) : null;
}

function findByPhone(phone) {
  const db = store.read();
  const user = db.users.find((u) => u.phone === phone);
  return user ? toPublicUser(user) : null;
}

module.exports = {
  createUser,
  authenticate,
  findById,
  findByPhone
};

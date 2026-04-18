const crypto = require("crypto");
const store = require("../store/jsonStore");
const userService = require("./userService");

function createCircle({ ownerId, name }) {
  let created = null;

  store.transaction((db) => {
    created = {
      id: crypto.randomUUID(),
      name,
      createdAt: new Date().toISOString()
    };

    db.circles.push(created);
    db.circleMembers.push({
      id: crypto.randomUUID(),
      circleId: created.id,
      userId: ownerId,
      invitedPhone: null,
      role: "owner",
      label: "Owner",
      createdAt: new Date().toISOString()
    });

    return db;
  });

  return created;
}

function addMember({ requesterId, circleId, phone, label }) {
  let created = null;

  store.transaction((db) => {
    const ownerLink = db.circleMembers.find(
      (m) => m.circleId === circleId && m.userId === requesterId && m.role === "owner"
    );
    if (!ownerLink) {
      const error = new Error("Only circle owner can add members");
      error.statusCode = 403;
      throw error;
    }

    const linkedUser = userService.findByPhone(phone);
    const duplicate = db.circleMembers.find((m) => {
      if (m.circleId !== circleId) {
        return false;
      }
      if (linkedUser && m.userId) {
        return m.userId === linkedUser.id;
      }
      return !m.userId && m.invitedPhone === phone;
    });

    if (duplicate) {
      const error = new Error("Member already exists in this circle");
      error.statusCode = 409;
      throw error;
    }

    created = {
      id: crypto.randomUUID(),
      circleId,
      userId: linkedUser ? linkedUser.id : null,
      invitedPhone: linkedUser ? null : phone,
      role: "member",
      label: label || "Family",
      createdAt: new Date().toISOString()
    };

    db.circleMembers.push(created);
    return db;
  });

  return created;
}

function isUserInCircle({ userId, circleId }) {
  const db = store.read();
  return db.circleMembers.some(
    (member) => member.circleId === circleId && member.userId === userId
  );
}

function isUserOwnerOfCircle({ userId, circleId }) {
  const db = store.read();
  return db.circleMembers.some(
    (member) =>
      member.circleId === circleId &&
      member.userId === userId &&
      member.role === "owner"
  );
}

function getCircleById(circleId) {
  const db = store.read();
  return db.circles.find((circle) => circle.id === circleId) || null;
}

function listForUser(userId) {
  const db = store.read();
  const visibleCircleIds = new Set(
    db.circleMembers.filter((m) => m.userId === userId).map((m) => m.circleId)
  );

  return db.circles
    .filter((c) => visibleCircleIds.has(c.id))
    .map((circle) => {
      const members = db.circleMembers
        .filter((m) => m.circleId === circle.id)
        .map((member) => {
          const linkedUser = member.userId
            ? db.users.find((u) => u.id === member.userId)
            : null;

          return {
            id: member.id,
            role: member.role,
            label: member.label,
            userId: member.userId,
            phone: linkedUser ? linkedUser.phone : member.invitedPhone,
            status: member.userId ? "active" : "pending"
          };
        });

      return {
        id: circle.id,
        name: circle.name,
        createdAt: circle.createdAt,
        members
      };
    });
}

module.exports = {
  createCircle,
  addMember,
  listForUser,
  isUserInCircle,
  isUserOwnerOfCircle,
  getCircleById
};

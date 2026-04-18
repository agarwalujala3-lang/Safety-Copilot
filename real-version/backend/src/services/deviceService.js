const crypto = require("crypto");
const store = require("../store/jsonStore");

const SUPPORTED_PLATFORMS = new Set(["android", "ios", "web"]);

function validatePlatform(platform) {
  if (!SUPPORTED_PLATFORMS.has(platform)) {
    const error = new Error("Platform must be one of: android, ios, web");
    error.statusCode = 400;
    throw error;
  }
}

function registerDevice({ userId, deviceId, fcmToken, platform, appVersion }) {
  validatePlatform(platform);
  if (!fcmToken) {
    const error = new Error("fcmToken is required");
    error.statusCode = 400;
    throw error;
  }

  let result = null;
  store.transaction((db) => {
    const id = deviceId || crypto.randomUUID();
    const existing = db.devices.find(
      (device) => device.userId === userId && device.deviceId === id
    );

    if (existing) {
      existing.fcmToken = fcmToken;
      existing.platform = platform;
      existing.appVersion = appVersion || existing.appVersion || null;
      existing.lastSeenAt = new Date().toISOString();
      result = existing;
      return db;
    }

    const created = {
      id: crypto.randomUUID(),
      userId,
      deviceId: id,
      fcmToken,
      platform,
      appVersion: appVersion || null,
      lastSeenAt: new Date().toISOString(),
      batteryLevel: null,
      isCharging: null,
      lastHeartbeatAt: null,
      lastLocation: null
    };

    db.devices.push(created);
    result = created;
    return db;
  });

  return result;
}

function heartbeat({
  userId,
  deviceId,
  batteryLevel,
  isCharging,
  lat,
  lng,
  tripId
}) {
  if (!deviceId) {
    const error = new Error("deviceId is required");
    error.statusCode = 400;
    throw error;
  }

  let updated = null;
  store.transaction((db) => {
    const device = db.devices.find(
      (item) => item.userId === userId && item.deviceId === deviceId
    );
    if (!device) {
      const error = new Error("Device not registered");
      error.statusCode = 404;
      throw error;
    }

    device.lastHeartbeatAt = new Date().toISOString();
    device.lastSeenAt = device.lastHeartbeatAt;
    device.isCharging = typeof isCharging === "boolean" ? isCharging : device.isCharging;
    device.batteryLevel = Number.isFinite(batteryLevel) ? batteryLevel : device.batteryLevel;
    device.tripId = tripId || null;

    if (Number.isFinite(lat) && Number.isFinite(lng)) {
      device.lastLocation = {
        lat,
        lng,
        capturedAt: device.lastHeartbeatAt
      };
    }

    updated = device;
    return db;
  });

  return updated;
}

function listMyDevices(userId) {
  const db = store.read();
  return db.devices.filter((device) => device.userId === userId);
}

module.exports = {
  registerDevice,
  heartbeat,
  listMyDevices
};

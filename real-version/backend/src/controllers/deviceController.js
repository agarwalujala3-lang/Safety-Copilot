const deviceService = require("../services/deviceService");

function register(req, res, next) {
  try {
    const { deviceId, fcmToken, platform, appVersion } = req.body;
    const device = deviceService.registerDevice({
      userId: req.user.id,
      deviceId,
      fcmToken,
      platform,
      appVersion
    });
    return res.status(201).json({ device });
  } catch (error) {
    if (error.statusCode) {
      return res.status(error.statusCode).json({ message: error.message });
    }
    return next(error);
  }
}

function heartbeat(req, res, next) {
  try {
    const { deviceId, batteryLevel, isCharging, lat, lng, tripId } = req.body;
    const device = deviceService.heartbeat({
      userId: req.user.id,
      deviceId,
      batteryLevel: Number.isFinite(Number(batteryLevel)) ? Number(batteryLevel) : undefined,
      isCharging:
        typeof isCharging === "boolean"
          ? isCharging
          : isCharging === undefined
            ? undefined
            : String(isCharging).toLowerCase() === "true",
      lat: Number.isFinite(Number(lat)) ? Number(lat) : undefined,
      lng: Number.isFinite(Number(lng)) ? Number(lng) : undefined,
      tripId
    });

    return res.json({ device });
  } catch (error) {
    if (error.statusCode) {
      return res.status(error.statusCode).json({ message: error.message });
    }
    return next(error);
  }
}

function myDevices(req, res, next) {
  try {
    const devices = deviceService.listMyDevices(req.user.id);
    return res.json({ devices });
  } catch (error) {
    if (error.statusCode) {
      return res.status(error.statusCode).json({ message: error.message });
    }
    return next(error);
  }
}

module.exports = {
  register,
  heartbeat,
  myDevices
};

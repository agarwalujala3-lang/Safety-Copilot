const tripService = require("../services/tripService");

function parseNumber(value, fieldName) {
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) {
    const error = new Error(`Invalid number for ${fieldName}`);
    error.statusCode = 400;
    throw error;
  }
  return parsed;
}

function start(req, res, next) {
  try {
    const {
      circleId,
      destinationName,
      destinationLat,
      destinationLng,
      etaSeconds,
      routePoints
    } = req.body;

    if (!circleId || !destinationName) {
      return res.status(400).json({
        message: "circleId and destinationName are required"
      });
    }

    const trip = tripService.startTrip({
      userId: req.user.id,
      circleId,
      destinationName,
      destinationLat: parseNumber(destinationLat, "destinationLat"),
      destinationLng: parseNumber(destinationLng, "destinationLng"),
      etaSeconds: Number.isFinite(Number(etaSeconds))
        ? Number(etaSeconds)
        : undefined,
      routePoints: Array.isArray(routePoints)
        ? routePoints
            .filter((p) => p && Number.isFinite(Number(p.lat)) && Number.isFinite(Number(p.lng)))
            .map((p) => ({ lat: Number(p.lat), lng: Number(p.lng) }))
        : []
    });

    return res.status(201).json({ trip });
  } catch (error) {
    if (error.statusCode) {
      return res.status(error.statusCode).json({ message: error.message });
    }
    return next(error);
  }
}

function activeMe(req, res, next) {
  try {
    const trip = tripService.getActiveTripForUser(req.user.id);
    return res.json({ trip });
  } catch (error) {
    if (error.statusCode) {
      return res.status(error.statusCode).json({ message: error.message });
    }
    return next(error);
  }
}

function byId(req, res, next) {
  try {
    const trip = tripService.getTripForUser({
      userId: req.user.id,
      tripId: req.params.tripId
    });
    return res.json({ trip });
  } catch (error) {
    if (error.statusCode) {
      return res.status(error.statusCode).json({ message: error.message });
    }
    return next(error);
  }
}

function ingestLocation(req, res, next) {
  try {
    const { lat, lng, speedMps, batteryLevel, isCharging, capturedAt } = req.body;
    const payload = tripService.ingestLocation({
      userId: req.user.id,
      tripId: req.params.tripId,
      lat: parseNumber(lat, "lat"),
      lng: parseNumber(lng, "lng"),
      speedMps: Number.isFinite(Number(speedMps)) ? Number(speedMps) : undefined,
      batteryLevel: Number.isFinite(Number(batteryLevel))
        ? Number(batteryLevel)
        : undefined,
      isCharging: Boolean(isCharging),
      capturedAt
    });
    return res.status(201).json(payload);
  } catch (error) {
    if (error.statusCode) {
      return res.status(error.statusCode).json({ message: error.message });
    }
    return next(error);
  }
}

function markArrived(req, res, next) {
  try {
    const trip = tripService.markArrived({
      userId: req.user.id,
      tripId: req.params.tripId
    });
    return res.json({ trip });
  } catch (error) {
    if (error.statusCode) {
      return res.status(error.statusCode).json({ message: error.message });
    }
    return next(error);
  }
}

function end(req, res, next) {
  try {
    const trip = tripService.endTrip({
      userId: req.user.id,
      tripId: req.params.tripId
    });
    return res.json({ trip });
  } catch (error) {
    if (error.statusCode) {
      return res.status(error.statusCode).json({ message: error.message });
    }
    return next(error);
  }
}

function sos(req, res, next) {
  try {
    const { mode, lat, lng, note } = req.body;
    const result = tripService.triggerSOS({
      userId: req.user.id,
      tripId: req.params.tripId,
      mode,
      lat: Number.isFinite(Number(lat)) ? Number(lat) : undefined,
      lng: Number.isFinite(Number(lng)) ? Number(lng) : undefined,
      note
    });
    return res.status(201).json(result);
  } catch (error) {
    if (error.statusCode) {
      return res.status(error.statusCode).json({ message: error.message });
    }
    return next(error);
  }
}

function locations(req, res, next) {
  try {
    const limit = Number.isFinite(Number(req.query.limit))
      ? Number(req.query.limit)
      : 100;
    const locationsData = tripService.listTripLocations({
      userId: req.user.id,
      tripId: req.params.tripId,
      limit
    });
    return res.json({ locations: locationsData });
  } catch (error) {
    if (error.statusCode) {
      return res.status(error.statusCode).json({ message: error.message });
    }
    return next(error);
  }
}

module.exports = {
  start,
  activeMe,
  byId,
  ingestLocation,
  markArrived,
  end,
  sos,
  locations
};

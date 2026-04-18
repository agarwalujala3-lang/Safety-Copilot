const crypto = require("crypto");
const store = require("../store/jsonStore");
const circleService = require("./circleService");
const { distanceMeters, distanceToPolylineMeters } = require("./geoService");

const ALERT_TYPE = {
  ARRIVAL: "arrival",
  SOS: "sos",
  SILENT_SOS: "silent_sos",
  DEVIATION: "deviation",
  DELAY: "delay",
  OFFLINE: "offline",
  LOW_BATTERY: "low_battery"
};

const ALERT_SEVERITY = {
  [ALERT_TYPE.ARRIVAL]: "low",
  [ALERT_TYPE.SOS]: "critical",
  [ALERT_TYPE.SILENT_SOS]: "critical",
  [ALERT_TYPE.DEVIATION]: "high",
  [ALERT_TYPE.DELAY]: "medium",
  [ALERT_TYPE.OFFLINE]: "high",
  [ALERT_TYPE.LOW_BATTERY]: "medium"
};

const RULES = {
  arrivalRadiusMeters: 120,
  arrivalStabilitySeconds: 45,
  deviationThresholdMeters: 300,
  lowBatteryThreshold: 15,
  offlineThresholdSeconds: 180,
  delayGraceSeconds: 10 * 60
};

function nowIso() {
  return new Date().toISOString();
}

function getActiveTripForUser(db, userId) {
  return db.trips.find((trip) => trip.userId === userId && trip.status === "active");
}

function assertUserInCircle(userId, circleId) {
  const allowed = circleService.isUserInCircle({ userId, circleId });
  if (!allowed) {
    const error = new Error("User is not a member of this trusted circle");
    error.statusCode = 403;
    throw error;
  }
}

function createAlert(db, { tripId, userId, type, message, meta }) {
  const alert = {
    id: crypto.randomUUID(),
    tripId,
    userId,
    type,
    severity: ALERT_SEVERITY[type] || "low",
    message,
    meta: meta || {},
    createdAt: nowIso()
  };
  db.alerts.push(alert);
  return alert;
}

function shouldThrottleAlert(db, { tripId, type, throttleSeconds }) {
  const latest = [...db.alerts]
    .reverse()
    .find((alert) => alert.tripId === tripId && alert.type === type);
  if (!latest) {
    return false;
  }
  const ageSeconds =
    (Date.now() - new Date(latest.createdAt).getTime()) / 1000;
  return ageSeconds < throttleSeconds;
}

function startTrip({
  userId,
  circleId,
  destinationName,
  destinationLat,
  destinationLng,
  etaSeconds,
  routePoints
}) {
  assertUserInCircle(userId, circleId);

  let created = null;
  store.transaction((db) => {
    const active = getActiveTripForUser(db, userId);
    if (active) {
      const error = new Error("You already have an active trip");
      error.statusCode = 409;
      throw error;
    }

    created = {
      id: crypto.randomUUID(),
      userId,
      circleId,
      destinationName,
      destinationLat,
      destinationLng,
      routePoints: Array.isArray(routePoints) ? routePoints : [],
      etaSeconds: Number.isFinite(etaSeconds) ? etaSeconds : null,
      expectedArrivalAt: Number.isFinite(etaSeconds)
        ? new Date(Date.now() + etaSeconds * 1000).toISOString()
        : null,
      status: "active",
      startedAt: nowIso(),
      lastHeartbeatAt: nowIso(),
      lastLocationAt: null,
      arrivedAt: null,
      endedAt: null,
      arrivalCandidateAt: null
    };

    db.trips.push(created);
    return db;
  });

  return created;
}

function getTripById(tripId) {
  const db = store.read();
  return db.trips.find((trip) => trip.id === tripId) || null;
}

function getTripForUser({ userId, tripId }) {
  const trip = getTripById(tripId);
  assertTripAccess(userId, trip);
  return trip;
}

function getActiveTripForUserRead(userId) {
  const db = store.read();
  return getActiveTripForUser(db, userId) || null;
}

function assertTripAccess(userId, trip) {
  if (!trip) {
    const error = new Error("Trip not found");
    error.statusCode = 404;
    throw error;
  }

  const isOwner = trip.userId === userId;
  const isCircleMember = circleService.isUserInCircle({
    userId,
    circleId: trip.circleId
  });
  if (!isOwner && !isCircleMember) {
    const error = new Error("Not allowed to access this trip");
    error.statusCode = 403;
    throw error;
  }
}

function ingestLocation({
  userId,
  tripId,
  lat,
  lng,
  speedMps,
  batteryLevel,
  isCharging,
  capturedAt
}) {
  let result = null;

  store.transaction((db) => {
    const trip = db.trips.find((item) => item.id === tripId);
    assertTripAccess(userId, trip);
    if (trip.userId !== userId) {
      const error = new Error("Only trip owner can post location");
      error.statusCode = 403;
      throw error;
    }
    if (trip.status !== "active") {
      const error = new Error("Trip is not active");
      error.statusCode = 409;
      throw error;
    }

    const captured = capturedAt ? new Date(capturedAt) : new Date();
    if (Number.isNaN(captured.getTime())) {
      const error = new Error("Invalid capturedAt timestamp");
      error.statusCode = 400;
      throw error;
    }

    const location = {
      id: crypto.randomUUID(),
      tripId,
      userId,
      lat,
      lng,
      speedMps: Number.isFinite(speedMps) ? speedMps : null,
      batteryLevel: Number.isFinite(batteryLevel) ? batteryLevel : null,
      isCharging: Boolean(isCharging),
      capturedAt: captured.toISOString()
    };
    db.tripLocations.push(location);

    trip.lastHeartbeatAt = nowIso();
    trip.lastLocationAt = location.capturedAt;
    if (location.batteryLevel !== null) {
      trip.lastBatteryLevel = location.batteryLevel;
    }

    const generatedAlerts = [];
    const distToDest = distanceMeters(
      lat,
      lng,
      trip.destinationLat,
      trip.destinationLng
    );

    if (distToDest <= RULES.arrivalRadiusMeters) {
      if (!trip.arrivalCandidateAt) {
        trip.arrivalCandidateAt = nowIso();
      } else {
        const inZoneSeconds =
          (Date.now() - new Date(trip.arrivalCandidateAt).getTime()) / 1000;
        if (inZoneSeconds >= RULES.arrivalStabilitySeconds) {
          trip.status = "arrived";
          trip.arrivedAt = nowIso();
          const alert = createAlert(db, {
            tripId: trip.id,
            userId: trip.userId,
            type: ALERT_TYPE.ARRIVAL,
            message: "Traveler reached destination safely.",
            meta: { destinationName: trip.destinationName }
          });
          generatedAlerts.push(alert);
        }
      }
    } else {
      trip.arrivalCandidateAt = null;
    }

    const polylineDistance = distanceToPolylineMeters(
      { lat, lng },
      trip.routePoints
    );
    if (
      polylineDistance !== null &&
      polylineDistance > RULES.deviationThresholdMeters &&
      !shouldThrottleAlert(db, {
        tripId,
        type: ALERT_TYPE.DEVIATION,
        throttleSeconds: 10 * 60
      })
    ) {
      const alert = createAlert(db, {
        tripId,
        userId,
        type: ALERT_TYPE.DEVIATION,
        message: "Traveler deviated significantly from planned route.",
        meta: {
          routeOffsetMeters: Math.round(polylineDistance)
        }
      });
      generatedAlerts.push(alert);
    }

    if (
      Number.isFinite(location.batteryLevel) &&
      location.batteryLevel <= RULES.lowBatteryThreshold &&
      !shouldThrottleAlert(db, {
        tripId,
        type: ALERT_TYPE.LOW_BATTERY,
        throttleSeconds: 30 * 60
      })
    ) {
      const alert = createAlert(db, {
        tripId,
        userId,
        type: ALERT_TYPE.LOW_BATTERY,
        message: "Traveler battery is critically low.",
        meta: { batteryLevel: location.batteryLevel }
      });
      generatedAlerts.push(alert);
    }

    if (
      trip.expectedArrivalAt &&
      Date.now() >
        new Date(trip.expectedArrivalAt).getTime() +
          RULES.delayGraceSeconds * 1000 &&
      !shouldThrottleAlert(db, {
        tripId,
        type: ALERT_TYPE.DELAY,
        throttleSeconds: 15 * 60
      })
    ) {
      const alert = createAlert(db, {
        tripId,
        userId,
        type: ALERT_TYPE.DELAY,
        message: "Traveler is delayed beyond expected arrival window.",
        meta: {
          expectedArrivalAt: trip.expectedArrivalAt
        }
      });
      generatedAlerts.push(alert);
    }

    result = {
      trip,
      location,
      generatedAlerts
    };

    return db;
  });

  return result;
}

function markArrived({ userId, tripId }) {
  let updated = null;
  store.transaction((db) => {
    const trip = db.trips.find((item) => item.id === tripId);
    assertTripAccess(userId, trip);
    if (trip.userId !== userId) {
      const error = new Error("Only trip owner can mark arrival");
      error.statusCode = 403;
      throw error;
    }
    if (trip.status !== "active") {
      const error = new Error("Trip is not active");
      error.statusCode = 409;
      throw error;
    }
    trip.status = "arrived";
    trip.arrivedAt = nowIso();
    createAlert(db, {
      tripId: trip.id,
      userId: trip.userId,
      type: ALERT_TYPE.ARRIVAL,
      message: "Traveler reached destination safely.",
      meta: { destinationName: trip.destinationName }
    });
    updated = trip;
    return db;
  });
  return updated;
}

function endTrip({ userId, tripId }) {
  let updated = null;
  store.transaction((db) => {
    const trip = db.trips.find((item) => item.id === tripId);
    assertTripAccess(userId, trip);
    if (trip.userId !== userId) {
      const error = new Error("Only trip owner can end trip");
      error.statusCode = 403;
      throw error;
    }
    if (trip.status === "ended" || trip.status === "cancelled") {
      const error = new Error("Trip already ended");
      error.statusCode = 409;
      throw error;
    }
    trip.status = "ended";
    trip.endedAt = nowIso();
    updated = trip;
    return db;
  });
  return updated;
}

function triggerSOS({ userId, tripId, mode, lat, lng, note }) {
  let response = null;
  store.transaction((db) => {
    const trip = db.trips.find((item) => item.id === tripId);
    assertTripAccess(userId, trip);
    if (trip.userId !== userId) {
      const error = new Error("Only trip owner can trigger SOS");
      error.statusCode = 403;
      throw error;
    }

    const sosEvent = {
      id: crypto.randomUUID(),
      tripId,
      userId,
      mode: mode === "silent" ? "silent" : "normal",
      lat: Number.isFinite(lat) ? lat : null,
      lng: Number.isFinite(lng) ? lng : null,
      note: note || null,
      createdAt: nowIso()
    };
    db.sosEvents.push(sosEvent);

    const type = sosEvent.mode === "silent" ? ALERT_TYPE.SILENT_SOS : ALERT_TYPE.SOS;
    const alert = createAlert(db, {
      tripId,
      userId,
      type,
      message:
        sosEvent.mode === "silent"
          ? "Silent emergency triggered by traveler."
          : "Emergency SOS triggered by traveler.",
      meta: {
        lat: sosEvent.lat,
        lng: sosEvent.lng,
        note: sosEvent.note
      }
    });

    response = { sosEvent, alert };
    return db;
  });

  return response;
}

function runOfflineChecks(userId) {
  store.transaction((db) => {
    const activeTrips = db.trips.filter(
      (trip) => trip.userId === userId && trip.status === "active"
    );

    activeTrips.forEach((trip) => {
      if (!trip.lastHeartbeatAt) {
        return;
      }
      const secondsSinceHeartbeat =
        (Date.now() - new Date(trip.lastHeartbeatAt).getTime()) / 1000;
      if (secondsSinceHeartbeat < RULES.offlineThresholdSeconds) {
        return;
      }

      if (
        shouldThrottleAlert(db, {
          tripId: trip.id,
          type: ALERT_TYPE.OFFLINE,
          throttleSeconds: 10 * 60
        })
      ) {
        return;
      }

      createAlert(db, {
        tripId: trip.id,
        userId,
        type: ALERT_TYPE.OFFLINE,
        message: "Traveler appears offline. Last heartbeat exceeded threshold.",
        meta: {
          lastHeartbeatAt: trip.lastHeartbeatAt
        }
      });
    });

    return db;
  });
}

function listAlertsForUser(userId) {
  runOfflineChecks(userId);
  const db = store.read();
  const myCircleIds = new Set(
    db.circleMembers.filter((member) => member.userId === userId).map((member) => member.circleId)
  );
  const allowedTripIds = new Set(
    db.trips
      .filter((trip) => trip.userId === userId || myCircleIds.has(trip.circleId))
      .map((trip) => trip.id)
  );

  return db.alerts
    .filter((alert) => allowedTripIds.has(alert.tripId))
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
}

function acknowledgeAlert({ userId, alertId }) {
  let updated = null;
  store.transaction((db) => {
    const alert = db.alerts.find((item) => item.id === alertId);
    if (!alert) {
      const error = new Error("Alert not found");
      error.statusCode = 404;
      throw error;
    }

    const trip = db.trips.find((item) => item.id === alert.tripId);
    const isOwner = trip && trip.userId === userId;
    const isCircleMember =
      trip &&
      db.circleMembers.some(
        (member) => member.circleId === trip.circleId && member.userId === userId
      );

    if (!isOwner && !isCircleMember) {
      const error = new Error("Not allowed to acknowledge this alert");
      error.statusCode = 403;
      throw error;
    }

    alert.acknowledgedAt = nowIso();
    alert.acknowledgedBy = userId;
    updated = alert;
    return db;
  });
  return updated;
}

function listTripLocations({ userId, tripId, limit = 100 }) {
  const db = store.read();
  const trip = db.trips.find((item) => item.id === tripId);
  assertTripAccess(userId, trip);

  return db.tripLocations
    .filter((location) => location.tripId === tripId)
    .sort((a, b) => new Date(a.capturedAt) - new Date(b.capturedAt))
    .slice(-Math.max(1, Math.min(500, limit)));
}

module.exports = {
  startTrip,
  getTripById,
  getTripForUser,
  getActiveTripForUser: getActiveTripForUserRead,
  ingestLocation,
  markArrived,
  endTrip,
  triggerSOS,
  listAlertsForUser,
  listTripLocations,
  acknowledgeAlert
};

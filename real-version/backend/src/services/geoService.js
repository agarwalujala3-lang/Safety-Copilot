const EARTH_RADIUS_METERS = 6371000;

function toRadians(value) {
  return (value * Math.PI) / 180;
}

function distanceMeters(aLat, aLng, bLat, bLng) {
  const dLat = toRadians(bLat - aLat);
  const dLng = toRadians(bLng - aLng);
  const lat1 = toRadians(aLat);
  const lat2 = toRadians(bLat);

  const h =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1) *
      Math.cos(lat2) *
      Math.sin(dLng / 2) *
      Math.sin(dLng / 2);

  return 2 * EARTH_RADIUS_METERS * Math.asin(Math.sqrt(h));
}

function toXYMeters(baseLat, baseLng, pointLat, pointLng) {
  const x = distanceMeters(baseLat, baseLng, baseLat, pointLng) *
    Math.sign(pointLng - baseLng);
  const y = distanceMeters(baseLat, baseLng, pointLat, baseLng) *
    Math.sign(pointLat - baseLat);
  return { x, y };
}

function distanceToSegmentMeters(point, segA, segB) {
  const a = toXYMeters(point.lat, point.lng, segA.lat, segA.lng);
  const b = toXYMeters(point.lat, point.lng, segB.lat, segB.lng);

  const vx = b.x - a.x;
  const vy = b.y - a.y;
  const wx = -a.x;
  const wy = -a.y;

  const len2 = vx * vx + vy * vy;
  if (len2 === 0) {
    return Math.sqrt(a.x * a.x + a.y * a.y);
  }

  const t = Math.max(0, Math.min(1, (wx * vx + wy * vy) / len2));
  const px = a.x + t * vx;
  const py = a.y + t * vy;
  return Math.sqrt(px * px + py * py);
}

function distanceToPolylineMeters(point, polylinePoints) {
  if (!Array.isArray(polylinePoints) || polylinePoints.length < 2) {
    return null;
  }

  let min = Number.POSITIVE_INFINITY;
  for (let i = 0; i < polylinePoints.length - 1; i += 1) {
    const dist = distanceToSegmentMeters(
      point,
      polylinePoints[i],
      polylinePoints[i + 1]
    );
    if (dist < min) {
      min = dist;
    }
  }

  return Number.isFinite(min) ? min : null;
}

module.exports = {
  distanceMeters,
  distanceToPolylineMeters
};

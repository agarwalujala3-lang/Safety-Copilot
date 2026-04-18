const API_BASE =
  import.meta.env.VITE_API_BASE || "http://localhost:4002/api/v1";

async function request(path, { method = "GET", token, body } = {}) {
  const headers = {
    "Content-Type": "application/json"
  };
  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  const response = await fetch(`${API_BASE}${path}`, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined
  });

  const data = await response.json().catch(() => ({}));
  if (!response.ok) {
    const message = data.message || `Request failed (${response.status})`;
    throw new Error(message);
  }
  return data;
}

export const api = {
  register: (payload) =>
    request("/auth/register", { method: "POST", body: payload }),
  login: (payload) => request("/auth/login", { method: "POST", body: payload }),
  me: (token) => request("/auth/me", { token }),
  createCircle: (token, payload) =>
    request("/circles", { method: "POST", token, body: payload }),
  addMember: (token, circleId, payload) =>
    request(`/circles/${circleId}/members`, {
      method: "POST",
      token,
      body: payload
    }),
  myCircles: (token) => request("/circles/my", { token }),
  startTrip: (token, payload) =>
    request("/trips/start", { method: "POST", token, body: payload }),
  activeTrip: (token) => request("/trips/active/me", { token }),
  sendLocation: (token, tripId, payload) =>
    request(`/trips/${tripId}/location`, { method: "POST", token, body: payload }),
  markArrived: (token, tripId) =>
    request(`/trips/${tripId}/arrive`, { method: "POST", token }),
  endTrip: (token, tripId) =>
    request(`/trips/${tripId}/end`, { method: "POST", token }),
  tripLocations: (token, tripId) => request(`/trips/${tripId}/locations`, { token }),
  triggerSos: (token, tripId, payload) =>
    request(`/trips/${tripId}/sos`, { method: "POST", token, body: payload }),
  myAlerts: (token) => request("/alerts/my", { token }),
  ackAlert: (token, alertId) =>
    request(`/alerts/${alertId}/ack`, { method: "POST", token }),
  registerDevice: (token, payload) =>
    request("/devices/register", { method: "POST", token, body: payload }),
  heartbeat: (token, payload) =>
    request("/devices/heartbeat", { method: "POST", token, body: payload }),
  myDevices: (token) => request("/devices/my", { token })
};

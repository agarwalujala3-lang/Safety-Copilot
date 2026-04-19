import { useEffect, useMemo, useState } from "react";
import { motion } from "framer-motion";
import SafetyOrb3D from "./components/SafetyOrb3D";
import { api } from "./services/api";

const defaultAuthForm = { name: "", phone: "", password: "" };

function toNumber(value, fallback = 0) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function randomAround(value, maxOffset = 0.0009) {
  return value + (Math.random() * 2 - 1) * maxOffset;
}

function normalizePhone(value) {
  return String(value || "").replace(/[^0-9+]/g, "");
}

function getOrCreateDeviceId() {
  const existing = localStorage.getItem("safety_device_id");
  if (existing) {
    return existing;
  }
  const id =
    typeof crypto !== "undefined" && crypto.randomUUID
      ? crypto.randomUUID()
      : `dev-${Date.now()}-${Math.round(Math.random() * 100000)}`;
  localStorage.setItem("safety_device_id", id);
  return id;
}

function resolveHealthUrl() {
  const apiBase = import.meta.env.VITE_API_BASE || "http://localhost:4002/api/v1";
  return apiBase.replace(/\/api\/v1\/?$/, "/health");
}

function formatTimestamp(value) {
  if (!value) {
    return "not synced yet";
  }
  try {
    return new Date(value).toLocaleString();
  } catch {
    return "not synced yet";
  }
}

export default function App() {
  const [authMode, setAuthMode] = useState("login");
  const [authForm, setAuthForm] = useState(defaultAuthForm);
  const [token, setToken] = useState(() => localStorage.getItem("safety_token") || "");
  const [user, setUser] = useState(null);
  const [circles, setCircles] = useState([]);
  const [alerts, setAlerts] = useState([]);
  const [devices, setDevices] = useState([]);
  const [activeTrip, setActiveTrip] = useState(null);
  const [tripLocations, setTripLocations] = useState([]);
  const [busy, setBusy] = useState(false);
  const [status, setStatus] = useState("Ready");
  const [error, setError] = useState("");
  const [backendOnline, setBackendOnline] = useState(true);
  const [lastSyncAt, setLastSyncAt] = useState("");
  const [autoRefresh, setAutoRefresh] = useState(true);

  const [circleName, setCircleName] = useState("Family");
  const [memberPhone, setMemberPhone] = useState("");
  const [memberLabel, setMemberLabel] = useState("Family");

  const [tripForm, setTripForm] = useState({
    circleId: "",
    destinationName: "Home",
    destinationLat: "28.6139",
    destinationLng: "77.2090",
    etaSeconds: "1800"
  });

  const [locationForm, setLocationForm] = useState({
    lat: "28.6130",
    lng: "77.2082",
    speedMps: "6.2",
    batteryLevel: "64",
    isCharging: false
  });
  const [deviceId] = useState(getOrCreateDeviceId);
  const healthUrl = useMemo(resolveHealthUrl, []);

  const activeCircleId = useMemo(() => {
    if (tripForm.circleId) {
      return tripForm.circleId;
    }
    if (circles[0]?.id) {
      return circles[0].id;
    }
    return "";
  }, [tripForm.circleId, circles]);

  async function bootstrap(sessionToken) {
    if (!sessionToken) {
      return;
    }
    const [meResp, circlesResp, activeResp, alertsResp, devicesResp] = await Promise.all([
      api.me(sessionToken),
      api.myCircles(sessionToken),
      api.activeTrip(sessionToken),
      api.myAlerts(sessionToken),
      api.myDevices(sessionToken)
    ]);

    setUser(meResp.user);
    setCircles(circlesResp.circles || []);
    setActiveTrip(activeResp.trip || null);
    setAlerts(alertsResp.alerts || []);
    setDevices(devicesResp.devices || []);

    if (activeResp.trip?.id) {
      const locResp = await api.tripLocations(sessionToken, activeResp.trip.id);
      setTripLocations(locResp.locations || []);
    } else {
      setTripLocations([]);
    }

    setLastSyncAt(new Date().toISOString());
  }

  async function checkBackendHealth() {
    try {
      const response = await fetch(healthUrl, {
        method: "GET",
        cache: "no-store"
      });
      setBackendOnline(response.ok);
    } catch {
      setBackendOnline(false);
    }
  }

  useEffect(() => {
    if (!token) {
      return;
    }
    withAction(async () => {
      await api.registerDevice(token, {
        deviceId,
        fcmToken: `web-token-${deviceId}`,
        platform: "web",
        appVersion: "web-1.0.0"
      });
      await bootstrap(token);
      await checkBackendHealth();
    }).catch((err) => {
      setError(err.message);
      setToken("");
      localStorage.removeItem("safety_token");
    });
  }, [token]);

  useEffect(() => {
    if (!token || !autoRefresh) {
      return;
    }

    const syncInterval = setInterval(() => {
      refreshDashboard().catch(() => {});
    }, 45000);

    const healthInterval = setInterval(() => {
      checkBackendHealth().catch(() => {});
    }, 20000);

    return () => {
      clearInterval(syncInterval);
      clearInterval(healthInterval);
    };
  }, [token, autoRefresh]);

  useEffect(() => {
    if (!token) {
      return;
    }

    function isTypingTarget(target) {
      const tag = target?.tagName?.toLowerCase?.() || "";
      return tag === "input" || tag === "textarea" || tag === "select";
    }

    function handleShortcuts(event) {
      if (!event.shiftKey || isTypingTarget(event.target)) {
        return;
      }
      const key = event.key.toLowerCase();
      if (key === "r") {
        event.preventDefault();
        refreshDashboard().catch(() => {});
      }
      if (key === "m" && activeTrip) {
        event.preventDefault();
        sendSimulatedLocation().catch(() => {});
      }
      if (key === "s" && activeTrip) {
        event.preventDefault();
        triggerSOS("normal").catch(() => {});
      }
      if (key === "a" && activeTrip) {
        event.preventDefault();
        triggerSOS("silent").catch(() => {});
      }
    }

    window.addEventListener("keydown", handleShortcuts);
    return () => window.removeEventListener("keydown", handleShortcuts);
  }, [token, activeTrip, locationForm]);

  async function withAction(action, successMessage) {
    try {
      setError("");
      setBusy(true);
      const result = await action();
      if (successMessage) {
        setStatus(successMessage);
      }
      return result;
    } catch (err) {
      setError(err.message);
      return null;
    } finally {
      setBusy(false);
    }
  }

  async function handleAuthSubmit(event) {
    event.preventDefault();
    const cleanPhone = normalizePhone(authForm.phone);
    const digits = cleanPhone.replace(/\D/g, "");
    if (digits.length < 10) {
      setError("Enter a valid phone number (at least 10 digits).");
      return;
    }

    await withAction(async () => {
      if (authMode === "register") {
        await api.register({
          ...authForm,
          phone: cleanPhone
        });
      }
      const loginResp = await api.login({
        phone: cleanPhone,
        password: authForm.password
      });
      setToken(loginResp.token);
      localStorage.setItem("safety_token", loginResp.token);
      setAuthForm(defaultAuthForm);
    }, "Authenticated");
  }

  async function refreshDashboard() {
    await withAction(async () => {
      await bootstrap(token);
      await checkBackendHealth();
    }, "Dashboard refreshed");
  }

  async function createCircle() {
    const response = await withAction(
      async () => api.createCircle(token, { name: circleName }),
      "Trusted circle created"
    );
    if (response) {
      await refreshDashboard();
      setTripForm((prev) => ({ ...prev, circleId: response.circle.id }));
    }
  }

  async function addMember() {
    if (!activeCircleId) {
      setError("Create/select a circle before adding member");
      return;
    }
    const cleanPhone = normalizePhone(memberPhone);
    const digits = cleanPhone.replace(/\D/g, "");
    if (digits.length < 10) {
      setError("Enter a valid member phone number (at least 10 digits).");
      return;
    }
    const response = await withAction(
      async () =>
        api.addMember(token, activeCircleId, {
          phone: cleanPhone,
          label: memberLabel
        }),
      "Member added to trusted circle"
    );
    if (response) {
      setMemberPhone("");
      await refreshDashboard();
    }
  }

  async function startTrip() {
    const circleId = activeCircleId;
    if (!circleId) {
      setError("Please create a trusted circle first");
      return;
    }

    const payload = {
      circleId,
      destinationName: tripForm.destinationName,
      destinationLat: toNumber(tripForm.destinationLat),
      destinationLng: toNumber(tripForm.destinationLng),
      etaSeconds: toNumber(tripForm.etaSeconds, 1800),
      routePoints: [
        {
          lat: toNumber(locationForm.lat),
          lng: toNumber(locationForm.lng)
        },
        {
          lat: toNumber(tripForm.destinationLat),
          lng: toNumber(tripForm.destinationLng)
        }
      ]
    };
    const response = await withAction(
      async () => api.startTrip(token, payload),
      "Trip started and sharing is now live"
    );
    if (response) {
      setActiveTrip(response.trip);
      await refreshDashboard();
    }
  }

  async function sendManualLocation() {
    if (!activeTrip) {
      setError("No active trip");
      return;
    }

    await withAction(
      async () =>
        api.sendLocation(token, activeTrip.id, {
          lat: toNumber(locationForm.lat),
          lng: toNumber(locationForm.lng),
          speedMps: toNumber(locationForm.speedMps, 0),
          batteryLevel: toNumber(locationForm.batteryLevel, 100),
          isCharging: locationForm.isCharging
        }),
      "Location ping sent"
    );
    await api.heartbeat(token, {
      deviceId,
      tripId: activeTrip.id,
      batteryLevel: toNumber(locationForm.batteryLevel, 100),
      isCharging: locationForm.isCharging,
      lat: toNumber(locationForm.lat),
      lng: toNumber(locationForm.lng)
    });
    await refreshDashboard();
  }

  async function sendSimulatedLocation() {
    if (!activeTrip) {
      setError("No active trip");
      return;
    }
    const lat = randomAround(toNumber(activeTrip.destinationLat), 0.005);
    const lng = randomAround(toNumber(activeTrip.destinationLng), 0.005);
    setLocationForm((prev) => ({
      ...prev,
      lat: lat.toFixed(6),
      lng: lng.toFixed(6),
      speedMps: (4 + Math.random() * 10).toFixed(2),
      batteryLevel: Math.max(5, Number(prev.batteryLevel) - 1).toString()
    }));

    await withAction(
      async () =>
        api.sendLocation(token, activeTrip.id, {
          lat,
          lng,
          speedMps: 4 + Math.random() * 8,
          batteryLevel: Math.max(5, toNumber(locationForm.batteryLevel) - 1),
          isCharging: false
        }),
      "Simulated location emitted"
    );
    await api.heartbeat(token, {
      deviceId,
      tripId: activeTrip.id,
      batteryLevel: Math.max(5, toNumber(locationForm.batteryLevel) - 1),
      isCharging: false,
      lat,
      lng
    });
    await refreshDashboard();
  }

  async function acknowledgeAlert(alertId) {
    await withAction(
      async () => api.ackAlert(token, alertId),
      "Alert acknowledged"
    );
    await refreshDashboard();
  }

  async function triggerSOS(mode) {
    if (!activeTrip) {
      setError("No active trip");
      return;
    }
    await withAction(
      async () =>
        api.triggerSos(token, activeTrip.id, {
          mode,
          lat: toNumber(locationForm.lat),
          lng: toNumber(locationForm.lng),
          note: mode === "silent" ? "covert trigger from app" : "manual emergency button"
        }),
      mode === "silent" ? "Silent SOS triggered" : "SOS triggered"
    );
    await refreshDashboard();
  }

  async function arriveTrip() {
    if (!activeTrip) {
      setError("No active trip");
      return;
    }
    await withAction(async () => api.markArrived(token, activeTrip.id), "Trip marked as arrived");
    await refreshDashboard();
  }

  async function endTrip() {
    if (!activeTrip) {
      setError("No active trip");
      return;
    }
    await withAction(async () => api.endTrip(token, activeTrip.id), "Trip ended");
    await refreshDashboard();
  }

  function logout() {
    setToken("");
    setUser(null);
    setCircles([]);
    setAlerts([]);
    setDevices([]);
    setActiveTrip(null);
    setTripLocations([]);
    localStorage.removeItem("safety_token");
  }

  if (!token) {
    return (
      <div className="auth-shell">
        <motion.div
          className="auth-card"
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.65 }}
        >
          <h1>Safety Copilot</h1>
          <p>Cloud-ready personal safety app with smart alerts.</p>
          <form onSubmit={handleAuthSubmit} className="stack">
            {authMode === "register" && (
              <input
                placeholder="Name"
                value={authForm.name}
                onChange={(e) => setAuthForm({ ...authForm, name: e.target.value })}
                required
              />
            )}
            <input
              placeholder="Phone (10+ digits)"
              value={authForm.phone}
              onChange={(e) =>
                setAuthForm({
                  ...authForm,
                  phone: normalizePhone(e.target.value)
                })
              }
              required
            />
            <input
              placeholder="Password"
              type="password"
              value={authForm.password}
              onChange={(e) => setAuthForm({ ...authForm, password: e.target.value })}
              required
            />
            <button disabled={busy} type="submit">
              {busy ? "Please wait..." : authMode === "register" ? "Create Account" : "Login"}
            </button>
          </form>
          <button
            className="linkish"
            onClick={() => setAuthMode(authMode === "login" ? "register" : "login")}
          >
            Switch to {authMode === "login" ? "Register" : "Login"}
          </button>
          {error && <p className="error">{error}</p>}
        </motion.div>
        <SafetyOrb3D />
      </div>
    );
  }

  const pendingAlerts = alerts.filter((alert) => !alert.acknowledgedAt);
  const criticalCount = pendingAlerts.filter(
    (alert) => alert.severity === "critical"
  ).length;
  const highCount = pendingAlerts.filter((alert) => alert.severity === "high").length;
  const mediumCount = pendingAlerts.filter(
    (alert) => alert.severity === "medium"
  ).length;
  const lowCount = pendingAlerts.filter((alert) => alert.severity === "low").length;

  return (
    <main className="dashboard">
      <header className="topbar">
        <div>
          <h1>Safety Copilot Console</h1>
          <p>
            Traveler: <strong>{user?.name}</strong> ({user?.phone})
          </p>
        </div>
        <div className="topbar-actions">
          <span className={`status-chip ${backendOnline ? "up" : "down"}`}>
            {backendOnline ? "Backend Online" : "Backend Degraded"}
          </span>
          <span className="status-chip neutral">
            Last Sync: {formatTimestamp(lastSyncAt)}
          </span>
          <button onClick={refreshDashboard} disabled={busy}>
            Refresh
          </button>
          <button onClick={logout}>Logout</button>
        </div>
      </header>

      <section className="hero-grid">
        <motion.article
          className="panel glass"
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.55 }}
        >
          <h2>Command Bridge</h2>
          <p>{status}</p>
          {error && <p className="error">{error}</p>}
          <div className="command-strip">
            <button disabled={busy} onClick={refreshDashboard}>
              Sync Now
            </button>
            <button disabled={busy || !activeTrip} onClick={sendSimulatedLocation}>
              Simulate Step
            </button>
            <button
              className="danger subtle"
              disabled={busy || !activeTrip}
              onClick={() => triggerSOS("silent")}
            >
              Silent Alert
            </button>
          </div>
          <label className="toggle-row">
            <input
              type="checkbox"
              checked={autoRefresh}
              onChange={(event) => setAutoRefresh(event.target.checked)}
            />
            <span>Auto-refresh telemetry every 45s</span>
          </label>
          <p className="shortcut-line">
            Shortcuts: <strong>Shift+R</strong> refresh, <strong>Shift+M</strong>{" "}
            simulate, <strong>Shift+S</strong> SOS, <strong>Shift+A</strong> silent SOS
          </p>
          <div className="stats-grid">
            <div>
              <span>Trusted Circles</span>
              <strong>{circles.length}</strong>
            </div>
            <div>
              <span>Alerts</span>
              <strong>{alerts.length}</strong>
            </div>
            <div>
              <span>Trip</span>
              <strong>{activeTrip ? activeTrip.status : "none"}</strong>
            </div>
            <div>
              <span>Devices</span>
              <strong>{devices.length}</strong>
            </div>
          </div>
        </motion.article>
        <motion.article
          className="panel orb-card"
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7 }}
        >
          <h2>3D Safety Core</h2>
          <p>Real-time trust and risk engine visualization.</p>
          <SafetyOrb3D />
        </motion.article>
      </section>

      <section className="threat-bar">
        <div className="threat-item critical">
          <span>Critical</span>
          <strong>{criticalCount}</strong>
        </div>
        <div className="threat-item high">
          <span>High</span>
          <strong>{highCount}</strong>
        </div>
        <div className="threat-item medium">
          <span>Medium</span>
          <strong>{mediumCount}</strong>
        </div>
        <div className="threat-item low">
          <span>Low</span>
          <strong>{lowCount}</strong>
        </div>
      </section>

      <section className="workspace-grid">
        <article className="panel">
          <h3>Trusted Circle</h3>
          <div className="stack">
            <input value={circleName} onChange={(e) => setCircleName(e.target.value)} />
            <button disabled={busy} onClick={createCircle}>
              Create Circle
            </button>
          </div>

          <div className="stack">
            <select
              value={activeCircleId}
              onChange={(e) => setTripForm({ ...tripForm, circleId: e.target.value })}
            >
              <option value="">Select circle</option>
              {circles.map((circle) => (
                <option key={circle.id} value={circle.id}>
                  {circle.name}
                </option>
              ))}
            </select>
            <input
              placeholder="Member phone"
              value={memberPhone}
              onChange={(e) => setMemberPhone(e.target.value)}
            />
            <input
              placeholder="Label"
              value={memberLabel}
              onChange={(e) => setMemberLabel(e.target.value)}
            />
            <button disabled={busy} onClick={addMember}>
              Add Member
            </button>
          </div>
        </article>

        <article className="panel">
          <h3>Trip Controls</h3>
          <div className="stack">
            <input
              placeholder="Destination name"
              value={tripForm.destinationName}
              onChange={(e) => setTripForm({ ...tripForm, destinationName: e.target.value })}
            />
            <input
              placeholder="Destination lat"
              value={tripForm.destinationLat}
              onChange={(e) => setTripForm({ ...tripForm, destinationLat: e.target.value })}
            />
            <input
              placeholder="Destination lng"
              value={tripForm.destinationLng}
              onChange={(e) => setTripForm({ ...tripForm, destinationLng: e.target.value })}
            />
            <input
              placeholder="ETA seconds"
              value={tripForm.etaSeconds}
              onChange={(e) => setTripForm({ ...tripForm, etaSeconds: e.target.value })}
            />
            <button disabled={busy || !!activeTrip} onClick={startTrip}>
              Start Trip
            </button>
            <button disabled={busy || !activeTrip} onClick={arriveTrip}>
              Mark Arrived
            </button>
            <button disabled={busy || !activeTrip} onClick={endTrip}>
              End Trip
            </button>
          </div>
        </article>

        <article className="panel">
          <h3>Live Location + SOS</h3>
          <div className="stack">
            <input
              placeholder="Latitude"
              value={locationForm.lat}
              onChange={(e) => setLocationForm({ ...locationForm, lat: e.target.value })}
            />
            <input
              placeholder="Longitude"
              value={locationForm.lng}
              onChange={(e) => setLocationForm({ ...locationForm, lng: e.target.value })}
            />
            <input
              placeholder="Speed m/s"
              value={locationForm.speedMps}
              onChange={(e) => setLocationForm({ ...locationForm, speedMps: e.target.value })}
            />
            <input
              placeholder="Battery"
              value={locationForm.batteryLevel}
              onChange={(e) => setLocationForm({ ...locationForm, batteryLevel: e.target.value })}
            />
            <button disabled={busy || !activeTrip} onClick={sendManualLocation}>
              Send Location Ping
            </button>
            <button disabled={busy || !activeTrip} onClick={sendSimulatedLocation}>
              Simulate Movement
            </button>
            <button className="danger" disabled={busy || !activeTrip} onClick={() => triggerSOS("normal")}>
              Trigger SOS
            </button>
            <button className="danger subtle" disabled={busy || !activeTrip} onClick={() => triggerSOS("silent")}>
              Trigger Silent SOS
            </button>
          </div>
        </article>
      </section>

      <section className="workspace-grid">
        <article className="panel">
          <h3>Recent Alerts</h3>
          <ul className="feed">
            {alerts.slice(0, 8).map((alert) => (
              <li key={alert.id}>
                <span className={`tag ${alert.severity}`}>{alert.type}</span>
                <p>{alert.message}</p>
                <small>{new Date(alert.createdAt).toLocaleString()}</small>
                <div className="feed-actions">
                  {alert.acknowledgedAt ? (
                    <small>
                      acknowledged {new Date(alert.acknowledgedAt).toLocaleString()}
                    </small>
                  ) : (
                    <button onClick={() => acknowledgeAlert(alert.id)} disabled={busy}>
                      Acknowledge
                    </button>
                  )}
                </div>
              </li>
            ))}
            {alerts.length === 0 && <li>No alerts yet.</li>}
          </ul>
        </article>

        <article className="panel">
          <h3>Location Stream</h3>
          <ul className="feed">
            {tripLocations.slice(-8).map((location) => (
              <li key={location.id}>
                <p>
                  {location.lat.toFixed(5)}, {location.lng.toFixed(5)}
                </p>
                <small>
                  speed {location.speedMps ?? "-"} | battery {location.batteryLevel ?? "-"}%
                </small>
              </li>
            ))}
            {tripLocations.length === 0 && <li>No location points yet.</li>}
          </ul>
        </article>
      </section>
    </main>
  );
}

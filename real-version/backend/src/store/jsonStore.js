const fs = require("fs");
const path = require("path");
const os = require("os");

const PROJECT_DB_PATH = path.join(__dirname, "..", "..", "data", "db.json");
const IS_LAMBDA = Boolean(process.env.AWS_LAMBDA_FUNCTION_NAME);
const DB_PATH = process.env.DB_PATH ||
  (IS_LAMBDA ? path.join(os.tmpdir(), "safety-db.json") : PROJECT_DB_PATH);

const defaultDb = () => ({
  users: [],
  circles: [],
  circleMembers: [],
  trips: [],
  tripLocations: [],
  alerts: [],
  sosEvents: [],
  devices: []
});

function ensureDb() {
  if (!fs.existsSync(DB_PATH)) {
    if (IS_LAMBDA && fs.existsSync(PROJECT_DB_PATH)) {
      fs.copyFileSync(PROJECT_DB_PATH, DB_PATH);
      return;
    }
    fs.writeFileSync(DB_PATH, JSON.stringify(defaultDb(), null, 2), "utf8");
  }
}

function read() {
  ensureDb();
  const text = fs.readFileSync(DB_PATH, "utf8");
  const parsed = JSON.parse(text);
  // Lightweight schema migration for existing files.
  const merged = {
    ...defaultDb(),
    ...parsed
  };
  return merged;
}

function write(nextDb) {
  fs.writeFileSync(DB_PATH, JSON.stringify(nextDb, null, 2), "utf8");
}

function transaction(mutator) {
  const db = read();
  const updated = mutator(db);
  write(updated);
  return updated;
}

module.exports = {
  read,
  write,
  transaction
};

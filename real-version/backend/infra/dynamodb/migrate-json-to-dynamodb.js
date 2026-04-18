/* eslint-disable no-console */
const fs = require("fs");
const path = require("path");
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");

const region = process.env.AWS_REGION || "ap-south-1";
const prefix = process.env.TABLE_PREFIX || "safety_copilot";
const dbPath = process.env.DB_PATH || path.join(__dirname, "..", "..", "data", "db.json");

const table = {
  users: `${prefix}_users`,
  circles: `${prefix}_circles`,
  circleMembers: `${prefix}_circle_members`,
  trips: `${prefix}_trips`,
  tripLocations: `${prefix}_trip_locations`,
  alerts: `${prefix}_alerts`,
  devices: `${prefix}_devices`
};

async function main() {
  const client = new DynamoDBClient({ region });
  const doc = DynamoDBDocumentClient.from(client);

  const raw = fs.readFileSync(dbPath, "utf8");
  const db = JSON.parse(raw);

  for (const user of db.users || []) {
    await doc.send(
      new PutCommand({
        TableName: table.users,
        Item: {
          userId: user.id,
          ...user
        }
      })
    );
  }

  for (const circle of db.circles || []) {
    await doc.send(
      new PutCommand({
        TableName: table.circles,
        Item: {
          circleId: circle.id,
          ...circle
        }
      })
    );
  }

  for (const member of db.circleMembers || []) {
    await doc.send(
      new PutCommand({
        TableName: table.circleMembers,
        Item: {
          circleId: member.circleId,
          memberId: member.id,
          ...member
        }
      })
    );
  }

  for (const trip of db.trips || []) {
    await doc.send(
      new PutCommand({
        TableName: table.trips,
        Item: {
          tripId: trip.id,
          ...trip
        }
      })
    );
  }

  for (const location of db.tripLocations || []) {
    await doc.send(
      new PutCommand({
        TableName: table.tripLocations,
        Item: {
          tripId: location.tripId,
          capturedAt: location.capturedAt,
          ...location
        }
      })
    );
  }

  for (const alert of db.alerts || []) {
    await doc.send(
      new PutCommand({
        TableName: table.alerts,
        Item: {
          alertId: alert.id,
          ...alert
        }
      })
    );
  }

  for (const device of db.devices || []) {
    await doc.send(
      new PutCommand({
        TableName: table.devices,
        Item: {
          userId: device.userId,
          deviceId: device.deviceId,
          ...device
        }
      })
    );
  }

  console.log("Migration complete.");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});

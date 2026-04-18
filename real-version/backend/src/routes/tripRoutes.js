const express = require("express");
const tripController = require("../controllers/tripController");
const { authenticate } = require("../middleware/authenticate");

const router = express.Router();

router.use(authenticate);
router.post("/start", tripController.start);
router.get("/active/me", tripController.activeMe);
router.get("/:tripId", tripController.byId);
router.get("/:tripId/locations", tripController.locations);
router.post("/:tripId/location", tripController.ingestLocation);
router.post("/:tripId/arrive", tripController.markArrived);
router.post("/:tripId/end", tripController.end);
router.post("/:tripId/sos", tripController.sos);

module.exports = router;

const express = require("express");
const { authenticate } = require("../middleware/authenticate");
const alertController = require("../controllers/alertController");

const router = express.Router();

router.use(authenticate);
router.get("/my", alertController.myAlerts);
router.post("/:alertId/ack", alertController.acknowledge);

module.exports = router;

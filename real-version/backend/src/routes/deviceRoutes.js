const express = require("express");
const { authenticate } = require("../middleware/authenticate");
const deviceController = require("../controllers/deviceController");

const router = express.Router();

router.use(authenticate);
router.post("/register", deviceController.register);
router.post("/heartbeat", deviceController.heartbeat);
router.get("/my", deviceController.myDevices);

module.exports = router;

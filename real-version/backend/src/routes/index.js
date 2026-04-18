const express = require("express");
const authRoutes = require("./authRoutes");
const circleRoutes = require("./circleRoutes");
const tripRoutes = require("./tripRoutes");
const alertRoutes = require("./alertRoutes");
const deviceRoutes = require("./deviceRoutes");

const router = express.Router();

router.use("/auth", authRoutes);
router.use("/circles", circleRoutes);
router.use("/trips", tripRoutes);
router.use("/alerts", alertRoutes);
router.use("/devices", deviceRoutes);

module.exports = router;

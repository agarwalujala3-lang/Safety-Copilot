const express = require("express");
const circleController = require("../controllers/circleController");
const { authenticate } = require("../middleware/authenticate");

const router = express.Router();

router.use(authenticate);
router.post("/", circleController.create);
router.post("/:circleId/members", circleController.addMember);
router.get("/my", circleController.myCircles);

module.exports = router;

const circleService = require("../services/circleService");

function create(req, res, next) {
  try {
    const { name } = req.body;
    if (!name || name.trim().length < 3) {
      return res
        .status(400)
        .json({ message: "Circle name is required (min 3 characters)" });
    }

    const circle = circleService.createCircle({
      ownerId: req.user.id,
      name: name.trim()
    });
    return res.status(201).json({ circle });
  } catch (error) {
    if (error.statusCode) {
      return res.status(error.statusCode).json({ message: error.message });
    }
    return next(error);
  }
}

function addMember(req, res, next) {
  try {
    const { phone, label } = req.body;
    if (!phone) {
      return res.status(400).json({ message: "Phone is required" });
    }

    const member = circleService.addMember({
      requesterId: req.user.id,
      circleId: req.params.circleId,
      phone,
      label
    });
    return res.status(201).json({ member });
  } catch (error) {
    if (error.statusCode) {
      return res.status(error.statusCode).json({ message: error.message });
    }
    return next(error);
  }
}

function myCircles(req, res) {
  const circles = circleService.listForUser(req.user.id);
  return res.json({ circles });
}

module.exports = {
  create,
  addMember,
  myCircles
};

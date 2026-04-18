const tripService = require("../services/tripService");

function myAlerts(req, res, next) {
  try {
    const alerts = tripService.listAlertsForUser(req.user.id);
    return res.json({ alerts });
  } catch (error) {
    if (error.statusCode) {
      return res.status(error.statusCode).json({ message: error.message });
    }
    return next(error);
  }
}

function acknowledge(req, res, next) {
  try {
    const alert = tripService.acknowledgeAlert({
      userId: req.user.id,
      alertId: req.params.alertId
    });
    return res.json({ alert });
  } catch (error) {
    if (error.statusCode) {
      return res.status(error.statusCode).json({ message: error.message });
    }
    return next(error);
  }
}

module.exports = {
  myAlerts,
  acknowledge
};

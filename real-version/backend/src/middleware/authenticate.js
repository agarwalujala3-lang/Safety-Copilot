const tokenService = require("../services/tokenService");
const userService = require("../services/userService");

function authenticate(req, res, next) {
  const header = req.headers.authorization || "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;

  if (!token) {
    return res.status(401).json({ message: "Missing bearer token" });
  }

  const payload = tokenService.verifyToken(token);
  if (!payload) {
    return res.status(401).json({ message: "Invalid or expired token" });
  }

  const user = userService.findById(payload.sub);
  if (!user) {
    return res.status(401).json({ message: "User not found" });
  }

  req.user = user;
  return next();
}

module.exports = {
  authenticate
};

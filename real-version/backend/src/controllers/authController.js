const userService = require("../services/userService");
const tokenService = require("../services/tokenService");

function requireFields(body, fields) {
  const missing = fields.find((field) => !body[field]);
  if (missing) {
    const error = new Error(`Missing field: ${missing}`);
    error.statusCode = 400;
    throw error;
  }
}

function register(req, res, next) {
  try {
    requireFields(req.body, ["name", "phone", "password"]);
    const user = userService.createUser(req.body);
    return res.status(201).json({ user });
  } catch (error) {
    if (error.statusCode) {
      return res.status(error.statusCode).json({ message: error.message });
    }
    return next(error);
  }
}

function login(req, res, next) {
  try {
    requireFields(req.body, ["phone", "password"]);
    const user = userService.authenticate(req.body);
    const token = tokenService.issueToken(user.id);
    return res.json({ token, user });
  } catch (error) {
    if (error.statusCode) {
      return res.status(error.statusCode).json({ message: error.message });
    }
    return next(error);
  }
}

function me(req, res) {
  return res.json({ user: req.user });
}

module.exports = {
  register,
  login,
  me
};

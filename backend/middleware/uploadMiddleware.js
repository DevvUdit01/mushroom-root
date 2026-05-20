const multer = require("multer");
const path = require("path");
const fs = require("fs");

// PRODUCT STORAGE
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const dir = "uploads/products";
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + "-" + Math.round(Math.random() * 1e9) + path.extname(file.originalname));
  },
});

// PROFILE IMAGE STORAGE
const profileStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    const dir = "uploads/profiles";
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: function (req, file, cb) {
    cb(null, "profile-" + req.user.id + "-" + Date.now() + path.extname(file.originalname));
  },
});

// FILE FILTER (both)
const fileFilter = (req, file, cb) => {
  if (file.mimetype.startsWith("image/")) {
    cb(null, true);
  } else {
    cb(new Error("Only images allowed"), false);
  }
};

const upload = multer({ storage, fileFilter });
const uploadProfile = multer({ storage: profileStorage, fileFilter, limits: { fileSize: 5 * 1024 * 1024 } });

module.exports = { upload, uploadProfile };
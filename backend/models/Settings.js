const mongoose = require("mongoose");

const settingsSchema = new mongoose.Schema(
  {
    deliveryCharge: Number,

    minimumOrder: Number,

    supportNumber: String,

    appVersion: String,

    razorpayKey: String,
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("Settings", settingsSchema);
const mongoose = require("mongoose");

const addressSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },

    fullAddress: String,

    landmark: String,

    city: String,

    state: String,

    pincode: String,

    addressType: {
      type: String,
      enum: ["home", "office", "other"],
      default: "home",
    },

    latitude: Number,

    longitude: Number,
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("Address", addressSchema);
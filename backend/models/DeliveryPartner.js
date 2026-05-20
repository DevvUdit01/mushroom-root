const mongoose = require("mongoose");

const deliveryPartnerSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },

    name: String,

    phone: String,

    vehicleType: String,

    vehicleNumber: String,

    profileImage: String,

    isOnline: {
      type: Boolean,
      default: false,
    },

    currentLocation: {
      latitude: Number,
      longitude: Number,
    },

    totalDeliveries: {
      type: Number,
      default: 0,
    },

    earnings: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model(
  "DeliveryPartner",
  deliveryPartnerSchema
);
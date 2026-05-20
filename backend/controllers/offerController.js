const Offer = require("../models/Offer");

const getSpecialOffer = async (req, res) => {
  try {
    let offer = await Offer.findOne({ isActive: true });

    // If no offer exists, create a dummy one dynamically as requested
    if (!offer) {
      offer = await Offer.create({
        title: "Get 25% OFF",
        discountText: "25% OFF",
        description: "On your first order today!",
        badgeText: "LIMITED TIME",
        isActive: true,
      });
    }

    res.status(200).json({
      success: true,
      offer,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  getSpecialOffer,
};

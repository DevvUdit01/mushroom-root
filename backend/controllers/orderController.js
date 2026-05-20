const Order = require("../models/Order");
const Cart = require("../models/Cart");
const User = require("../models/User");

// PLACE NEW ORDER FROM CART
const placeOrder = async (req, res) => {
  try {
    const userId = req.user.id;
    const { paymentMethod } = req.body; // 'cod' or 'online'

    // 1. Find user's cart
    const cart = await Cart.findOne({ userId }).populate("products.productId");
    if (!cart || cart.products.length === 0) {
      return res.status(400).json({
        success: false,
        message: "Your cart is empty",
      });
    }

    // 2. Fetch User to get Address
    const user = await User.findById(userId);
    if (!user || !user.address || !user.address.fullAddress) {
      return res.status(400).json({
        success: false,
        message: "Delivery address not found. Please update your profile.",
      });
    }

    // 3. Format products for Order
    const orderProducts = cart.products.map((item) => ({
      productId: item.productId._id,
      quantity: item.quantity,
      price: item.price,
    }));

    // 4. Calculate final totals (mocking delivery/tax logic)
    const deliveryCharge = 30; // standard mock charge
    const tax = cart.totalPrice * 0.05; // 5% mock tax
    const totalAmount = cart.totalPrice + deliveryCharge + tax;

    // 5. Create Order
    const order = await Order.create({
      customerId: userId,
      vendorId: cart.vendorId,
      products: orderProducts,
      totalAmount: totalAmount,
      deliveryCharge: deliveryCharge,
      tax: tax,
      paymentMethod: paymentMethod || "cod",
      paymentStatus: paymentMethod === "online" ? "paid" : "pending",
      orderStatus: "pending",
      deliveryAddress: user.address,
    });

    // 6. Empty the cart
    await Cart.deleteOne({ _id: cart._id });

    res.status(201).json({
      success: true,
      message: "Order placed successfully",
      order,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  placeOrder,
};

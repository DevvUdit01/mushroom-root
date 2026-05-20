const jwt = require("jsonwebtoken");
const User = require("../models/User");
const Order = require("../models/Order");
const Notification = require("../models/Notification");

// UPLOAD PROFILE PHOTO
const uploadProfilePhoto = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: "No image file provided" });
    }

    // Build accessible URL path
    const imagePath = req.file.path.replace(/\\/g, "/"); // normalize Windows paths
    const imageUrl = `${imagePath}`;

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { profileImage: imageUrl },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    res.status(200).json({
      success: true,
      message: "Profile photo updated",
      profileImage: imageUrl,
      user,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Generate OTP
const generateOTP = () => {
  return "1234";
};

// SEND OTP
const sendOTP = async (req, res) => {
  try {
    const { phone } = req.body;
    if (!phone) {
      return res.status(400).json({ success: false, message: "Phone number is required" });
    }
    let user = await User.findOne({ phone });
    const otp = generateOTP();
    const otpExpiry = new Date(Date.now() + 5 * 60 * 1000);
    if (!user) {
      user = await User.create({ phone, otp, otpExpiry });
    } else {
      user.otp = otp;
      user.otpExpiry = otpExpiry;
      await user.save();
    }
    console.log("OTP:", otp);
    res.status(200).json({ success: true, message: "OTP sent successfully", otp });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// VERIFY OTP
const verifyOTP = async (req, res) => {
  try {
    const { phone, otp } = req.body;
    const user = await User.findOne({ phone });
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    if (user.otp !== otp) {
      return res.status(400).json({ success: false, message: "Invalid OTP" });
    }
    if (user.otpExpiry < new Date()) {
      return res.status(400).json({ success: false, message: "OTP expired" });
    }
    user.isVerified = true;
    user.otp = null;
    user.otpExpiry = null;
    await user.save();
    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "30d" }
    );
    res.status(200).json({ success: true, message: "Login successful", token, user });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// REGISTER / COMPLETE PROFILE (called after OTP verify)
const registerUser = async (req, res) => {
  try {
    const { name, email, phone, role, fullAddress, city, state, pincode, latitude, longitude } = req.body;
    const user = await User.findOne({ phone });
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    user.name = name || user.name;
    user.email = email || user.email;
    if (role) user.role = role;
    user.address = {
      fullAddress,
      city,
      state,
      pincode,
      location: { latitude, longitude },
    };
    await user.save();
    res.status(200).json({ success: true, message: "User registered successfully", user });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET PROFILE
const getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    res.status(200).json({ success: true, user });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// UPDATE PROFILE (name, email)
const updateProfile = async (req, res) => {
  try {
    const { name, email } = req.body;
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    if (name !== undefined && name.trim() !== "") user.name = name.trim();
    if (email !== undefined) user.email = email.trim() || null;
    await user.save();
    res.status(200).json({ success: true, message: "Profile updated successfully", user });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// UPDATE LOCATION
const updateLocation = async (req, res) => {
  try {
    const { latitude, longitude, fullAddress, city, state, pincode } = req.body;
    const updateFields = {};
    if (fullAddress !== undefined) updateFields["address.fullAddress"] = fullAddress;
    if (city !== undefined) updateFields["address.city"] = city;
    if (state !== undefined) updateFields["address.state"] = state;
    if (pincode !== undefined) updateFields["address.pincode"] = pincode;
    if (latitude !== undefined) updateFields["address.location.latitude"] = latitude;
    if (longitude !== undefined) updateFields["address.location.longitude"] = longitude;
    const user = await User.findByIdAndUpdate(
      req.user.id,
      { $set: updateFields },
      { new: true }
    );
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    res.status(200).json({ success: true, message: "Location updated successfully", address: user.address });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET USER'S ORDER HISTORY
const getOrders = async (req, res) => {
  try {
    const orders = await Order.find({ customerId: req.user.id })
      .populate("vendorId", "shopName shopImage")
      .populate("products.productId", "productName images sellingPrice mrpPrice unit")
      .sort({ createdAt: -1 });
    res.status(200).json({ success: true, orders });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET USER NOTIFICATIONS
const getNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({ userId: req.user.id })
      .sort({ createdAt: -1 })
      .limit(50);
    res.status(200).json({ success: true, notifications });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// MARK SINGLE NOTIFICATION AS READ
const markNotificationRead = async (req, res) => {
  try {
    const { id } = req.params;
    await Notification.findOneAndUpdate({ _id: id, userId: req.user.id }, { isRead: true });
    res.status(200).json({ success: true, message: "Notification marked as read" });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// MARK ALL NOTIFICATIONS AS READ
const markAllNotificationsRead = async (req, res) => {
  try {
    await Notification.updateMany({ userId: req.user.id, isRead: false }, { isRead: true });
    res.status(200).json({ success: true, message: "All notifications marked as read" });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  sendOTP,
  verifyOTP,
  getProfile,
  updateProfile,
  uploadProfilePhoto,
  registerUser,
  updateLocation,
  getOrders,
  getNotifications,
  markNotificationRead,
  markAllNotificationsRead,
};
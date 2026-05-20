const jwt = require("jsonwebtoken");
const User = require("../models/User");
const Vendor = require("../models/Vendor");
const Product = require("../models/Product");
const Category = require("../models/Category");
const Order = require("../models/Order");

// ADMIN LOGIN — Phone + Password (credentials stored in .env)
const adminLogin = async (req, res) => {
  try {
    const { phone, password } = req.body;

    if (!phone || !password) {
      return res.status(400).json({ success: false, message: "Phone and password are required" });
    }

    // Check against env-stored admin credentials
    if (
      phone !== process.env.ADMIN_PHONE ||
      password !== process.env.ADMIN_PASSWORD
    ) {
      return res.status(401).json({ success: false, message: "Invalid admin credentials" });
    }

    // Find or create admin user in DB
    let adminUser = await User.findOne({ phone });
    if (!adminUser) {
      adminUser = await User.create({ phone, role: "admin", isVerified: true, name: "Admin" });
    } else if (adminUser.role !== "admin") {
      adminUser.role = "admin";
      await adminUser.save();
    }

    const token = jwt.sign(
      { id: adminUser._id, role: adminUser.role },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.status(200).json({
      success: true,
      message: "Admin login successful",
      token,
      user: adminUser
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};


// 1. MAKE ADMIN (HELPER UTILITY)
const makeAdmin = async (req, res) => {
  try {
    const { phone } = req.body;
    if (!phone) {
      return res.status(400).json({ success: false, message: "Phone number is required" });
    }

    let user = await User.findOne({ phone });
    if (!user) {
      // Create user if not exists
      user = await User.create({
        phone,
        role: "admin",
        isVerified: true
      });
    } else {
      user.role = "admin";
      await user.save();
    }

    res.status(200).json({
      success: true,
      message: `Successfully promoted ${phone} to admin!`,
      user
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 2. GET SYSTEM STATS
const getStats = async (req, res) => {
  try {
    const totalOrders = await Order.countDocuments();
    const totalCustomers = await User.countDocuments({ role: "customer" });
    const totalVendors = await Vendor.countDocuments();
    const totalProducts = await Product.countDocuments();

    // Calculate total revenue from delivered orders
    const deliveredOrders = await Order.find({ orderStatus: "delivered" });
    const totalRevenue = deliveredOrders.reduce((sum, order) => sum + (order.totalAmount || 0), 0);

    // Get order status distribution for charts
    const pendingOrders = await Order.countDocuments({ orderStatus: "pending" });
    const acceptedOrders = await Order.countDocuments({ orderStatus: "accepted" });
    const packedOrders = await Order.countDocuments({ orderStatus: "packed" });
    const outForDeliveryOrders = await Order.countDocuments({ orderStatus: "out_for_delivery" });
    const deliveredOrdersCount = await Order.countDocuments({ orderStatus: "delivered" });
    const cancelledOrders = await Order.countDocuments({ orderStatus: "cancelled" });

    // Recent 5 orders
    const recentOrders = await Order.find()
      .populate("customerId", "name phone")
      .populate("vendorId", "shopName")
      .sort({ createdAt: -1 })
      .limit(5);

    // Recent 5 vendors
    const recentVendors = await Vendor.find()
      .populate("userId", "name phone")
      .sort({ createdAt: -1 })
      .limit(5);

    res.status(200).json({
      success: true,
      stats: {
        totalOrders,
        totalCustomers,
        totalVendors,
        totalProducts,
        totalRevenue,
        orderStatusDistribution: {
          pending: pendingOrders,
          accepted: acceptedOrders,
          packed: packedOrders,
          out_for_delivery: outForDeliveryOrders,
          delivered: deliveredOrdersCount,
          cancelled: cancelledOrders
        }
      },
      recentOrders,
      recentVendors
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 3. GET ALL VENDORS
const getVendors = async (req, res) => {
  try {
    const vendors = await Vendor.find().populate("userId", "name email phone role isVerified profileImage");
    res.status(200).json({
      success: true,
      vendors
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 4. APPROVE / SUSPEND VENDOR
const approveVendor = async (req, res) => {
  try {
    const { id } = req.params;
    const { isApproved } = req.body; // boolean

    const vendor = await Vendor.findById(id);
    if (!vendor) {
      return res.status(404).json({ success: false, message: "Vendor not found" });
    }

    vendor.isApproved = isApproved;
    await vendor.save();

    // If approved, verify the associated user role is "vendor"
    if (vendor.userId) {
      const user = await User.findById(vendor.userId);
      if (user) {
        user.role = isApproved ? "vendor" : "customer";
        await user.save();
      }
    }

    res.status(200).json({
      success: true,
      message: `Vendor shop '${vendor.shopName}' is now ${isApproved ? "Approved" : "Suspended"}`,
      vendor
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 5. GET ALL ORDERS
const getOrders = async (req, res) => {
  try {
    const orders = await Order.find()
      .populate("customerId", "name email phone address")
      .populate("vendorId", "shopName ownerName phone address")
      .populate("products.productId", "productName mrpPrice sellingPrice images unit weight")
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      orders
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 6. UPDATE ORDER STATUS
const updateOrderStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { orderStatus, paymentStatus } = req.body;

    const order = await Order.findById(id);
    if (!order) {
      return res.status(404).json({ success: false, message: "Order not found" });
    }

    if (orderStatus) {
      order.orderStatus = orderStatus;
      // If delivered, mark paymentStatus as paid if COD
      if (orderStatus === "delivered" && order.paymentMethod === "cod") {
        order.paymentStatus = "paid";
      }
    }

    if (paymentStatus) {
      order.paymentStatus = paymentStatus;
    }

    await order.save();

    res.status(200).json({
      success: true,
      message: "Order status updated successfully",
      order
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 7. GET ALL PRODUCTS
const getProducts = async (req, res) => {
  try {
    const products = await Product.find()
      .populate("vendorId", "shopName ownerName")
      .populate("categoryId", "name")
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      products
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 8. DELETE PRODUCT
const deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const product = await Product.findByIdAndDelete(id);
    if (!product) {
      return res.status(404).json({ success: false, message: "Product not found" });
    }

    res.status(200).json({
      success: true,
      message: "Product deleted successfully"
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 9. ADD CATEGORY
const addCategory = async (req, res) => {
  try {
    const { name, image, icon } = req.body;
    if (!name) {
      return res.status(400).json({ success: false, message: "Category name is required" });
    }

    const category = await Category.create({
      name,
      image: image || "",
      icon: icon || "",
      isActive: true
    });

    res.status(201).json({
      success: true,
      message: "Category added successfully",
      category
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 10. DELETE CATEGORY
const deleteCategory = async (req, res) => {
  try {
    const { id } = req.params;
    const category = await Category.findByIdAndDelete(id);
    if (!category) {
      return res.status(404).json({ success: false, message: "Category not found" });
    }

    res.status(200).json({
      success: true,
      message: "Category deleted successfully"
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  adminLogin,
  getStats,
  getVendors,
  approveVendor,
  getOrders,
  updateOrderStatus,
  getProducts,
  deleteProduct,
  addCategory,
  deleteCategory
};

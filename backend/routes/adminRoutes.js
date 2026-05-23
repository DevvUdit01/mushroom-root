const express = require("express");
const router = express.Router();
const { protect } = require("../middleware/authMiddleware");

const {
  adminLogin,
  getStats,
  getVendors,
  approveVendor,
  getOrders,
  updateOrderStatus,
  getProducts,
  deleteProduct,
  addCategory,
  deleteCategory,
  toggleProductFeatured
} = require("../controllers/adminController");

// Admin role authorization middleware
const isAdmin = (req, res, next) => {
  if (req.user && req.user.role === "admin") {
    next();
  } else {
    res.status(403).json({
      success: false,
      message: "Access denied. Admin authorization required."
    });
  }
};

// PUBLIC: Secure admin login with phone + password (no OTP, no make-admin exploit)
router.post("/login", adminLogin);

// PROTECTED: All admin operations require valid JWT + admin role
router.get("/stats", protect, isAdmin, getStats);
router.get("/vendors", protect, isAdmin, getVendors);
router.put("/vendors/:id/approve", protect, isAdmin, approveVendor);
router.get("/orders", protect, isAdmin, getOrders);
router.put("/orders/:id/status", protect, isAdmin, updateOrderStatus);
router.get("/products", protect, isAdmin, getProducts);
router.delete("/products/:id", protect, isAdmin, deleteProduct);
router.put("/products/:id/feature", protect, isAdmin, toggleProductFeatured);
router.post("/categories", protect, isAdmin, addCategory);
router.delete("/categories/:id", protect, isAdmin, deleteCategory);

module.exports = router;

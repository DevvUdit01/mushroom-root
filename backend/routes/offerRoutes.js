const express = require("express");
const router = express.Router();

const { getSpecialOffer } = require("../controllers/offerController");

router.get("/special", getSpecialOffer);

module.exports = router;

const express = require("express");
const router = express.Router();
const likedProductController = require("../controllers/LinkedProductController");

router.post("/like", likedProductController.likeProduct);
router.get("/:userId", likedProductController.getLikedProducts);

module.exports = router;

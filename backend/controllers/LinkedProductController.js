const LikedProduct = require("../models/LikedProductSchema");

// Like a product
exports.likeProduct = async (req, res) => {
    try {
        const { userId, productId } = req.body;

        // Check if the product is already liked
        const existingLike = await LikedProduct.findOne({ userId, productId });
        if (existingLike) {
            return res.status(400).json({ message: "Product already liked" });
        }

        const likedProduct = new LikedProduct({ userId, productId });
        await likedProduct.save();

        res.status(201).json({ message: "Product liked successfully", likedProduct });
    } catch (error) {
        res.status(500).json({ error: "Internal server error" });
    }
};

// Get all liked products for a user
exports.getLikedProducts = async (req, res) => {
    try {
        const likedProducts = await LikedProduct.find({ userId: req.params.userId }).populate("productId");
        res.status(200).json(likedProducts);
    } catch (error) {
        res.status(500).json({ error: "Internal server error" });
    }
};
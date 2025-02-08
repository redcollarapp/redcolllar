
const express = require('express');
const router = express.Router();
const cartController = require('../controllers/CartController');

// Define routes
router.get('/', cartController.getCartItems); // Get all cart items
router.get('/:id', cartController.getCartItemById); // Get cart item by ID
router.post('/', cartController.addToCart); // Add item to cart
router.put('/:id', cartController.updateCartItem); 
router.delete('/:id', cartController.deleteCartItem); 

module.exports = router;

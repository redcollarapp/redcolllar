const express = require('express');
const router = express.Router();
const orderController = require('../controllers/OrderController');

// ✅ Routes for Order API
router.get('/fetch-all-orders', orderController.getAllOrders);
router.get('/fetch-order-by-id/:id', orderController.getOrderById);
router.get('/user/:userId', orderController.getOrdersByUserId);
router.post('/create-orders', orderController.createOrder);
router.put('/update-orders/:id', orderController.updateOrder);
router.delete('/delete-orders/:id', orderController.deleteOrder);

module.exports = router;

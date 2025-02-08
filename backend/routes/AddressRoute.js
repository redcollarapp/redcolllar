const express = require('express');
const router = express.Router();
const addressController = require('../controllers/AddressController');

// ✅ Routes for Address API
router.get('/fetch-all-addresses', addressController.getAllAddresses);
router.get('/fetch-address-by-id/:id', addressController.getAddressById);
router.get('/user/:user', addressController.getAddressByUserId);
router.post('/create-addresses', addressController.createAddress);
router.put('/update-addresses/:id', addressController.updateAddress);
router.delete('/delete-addresses/:id', addressController.deleteAddress);

module.exports = router;

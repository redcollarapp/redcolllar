const express = require('express');
const router = express.Router();
const promotionsController = require('../controllers/PromotionController');


// ✅ Routes for Promotion API
router.get('/promotions-getAll', promotionsController.getAllPromotions); 
router.get('/promotions-getById/:id', promotionsController.getPromotionById); 
router.post('/promotions-create', promotionsController.createPromotion); 
router.put('/promotions-update/:id', promotionsController.updatePromotion); 
router.delete('/promotions-delete/:id', promotionsController.deletePromotion); 
router.get('/get-image/:imageName', promotionsController.getImage); 

module.exports = router;

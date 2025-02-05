const Promo = require('../models/PromotionsSchema'); // Import Promo model
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Define the upload directory inside 'uploads/promotions'
const uploadDir = path.join(__dirname, '..', 'uploads', 'promotions');

// Create the 'promotions' folder if it doesn't exist
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Set up multer storage for image upload in 'uploads/promotions'
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir); // Save image to 'uploads/promotions' folder
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const extname = path.extname(file.originalname); // Get file extension
    cb(null, file.fieldname + '-' + uniqueSuffix + extname); // Create unique filename
  },
});

const upload = multer({ 
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // Limit file size to 10MB
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/jpg']; // Allowed file types
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true); // Accept the file
    } else {
      cb(new Error('Only .jpg, .jpeg, .png files are allowed!'), false); // Reject the file
    }
  }
});

// Get all promotions
exports.getAllPromotions = async (req, res) => {
  try {
    const promotions = await Promo.find();
    res.status(200).json({
      message:"fetch promotions successfully",
      data:promotions
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get a promotion by ID
exports.getPromotionById = async (req, res) => {
  try {
    const promotion = await Promo.findById(req.params.id);
    if (!promotion) {
      return res.status(404).json({ message: 'Promotion not found' });
    }
    res.status(200).json(promotion);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Create a new promotion
exports.createPromotion = async (req, res) => {
  upload.single('Image')(req, res, async (err) => {
    if (err instanceof multer.MulterError) {
      return res.status(500).json({ message: err.message });
    } else if (err) {
      return res.status(400).json({ message: 'Invalid file format' });
    }

    try {
      if (!req.file) {
        return res.status(400).json({ message: 'No file uploaded' });
      }

      const { title } = req.body;
      const imageUrl = `/uploads/promotions/${req.file.filename}`; // Generate the image URL

      const newPromotion = new Promo({ title, Image: imageUrl });
      await newPromotion.save();

      res.status(201).json({
        message: 'Promotion created successfully',
        promotion: newPromotion,
        image: imageUrl
      });
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  });
};

// Update a promotion by ID
exports.updatePromotion = async (req, res) => {
  const { title, Image } = req.body;

  // Handle image upload in update
  upload.single('Image')(req, res, async (err) => {
    if (err instanceof multer.MulterError) {
      return res.status(500).json({ message: err.message });
    } else if (err) {
      return res.status(400).json({ message: 'Invalid file format' });
    }

    try {
      let updatedPromotionData = { title };

      // If a new image file is uploaded, include the new image URL
      if (req.file) {
        const newImageUrl = `/uploads/promotions/${req.file.filename}`;
        updatedPromotionData.Image = newImageUrl;
      }

      const updatedPromotion = await Promo.findByIdAndUpdate(
        req.params.id,
        updatedPromotionData,
        { new: true, runValidators: true }
      );

      if (!updatedPromotion) {
        return res.status(404).json({ message: 'Promotion not found' });
      }

      res.status(200).json(updatedPromotion);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  });
};

// Delete a promotion by ID
exports.deletePromotion = async (req, res) => {
  try {
    const deletedPromotion = await Promo.findByIdAndDelete(req.params.id);
    if (!deletedPromotion) {
      return res.status(404).json({ message: 'Promotion not found' });
    }
    res.status(200).json({ message: 'Promotion deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Serve the uploaded image
exports.getImage = (req, res) => {
  const imageName = req.params.imageName;
  const imagePath = path.join(__dirname, '..', 'uploads', 'promotions', imageName); // Adjust path to promotions folder

  res.sendFile(imagePath, (err) => {
    if (err) {
      res.status(404).json({ message: 'Image not found' });
    }
  });
};

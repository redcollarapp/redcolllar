const Review = require('../models/ReviewSchema'); // Import Review model
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Define the upload directory for review images
const uploadDir = path.join(__dirname, '..', 'uploads', 'reviews');

// Create the 'reviews' folder if it doesn't exist
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Set up multer storage for image upload in 'uploads/reviews'
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir); // Save image to 'uploads/reviews' folder
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

// Get all reviews for a product
exports.getAllReviews = async (req, res) => {
  try {
    const reviews = await Review.find({ product: req.params.productId })
      .populate('user')
      .populate('product');
    res.status(200).json(reviews);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching reviews', error: err.message });
  }
};

// Get a specific review by ID
exports.getReviewById = async (req, res) => {
  try {
    const review = await Review.findById(req.params.id)
      .populate('user')
      .populate('product');
    if (!review) {
      return res.status(404).json({ message: 'Review not found' });
    }
    res.status(200).json(review);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching review', error: err.message });
  }
};

// Create a new review with image handling
exports.createReview = async (req, res) => {
  upload.array('images', 5)(req, res, async (err) => { // Allow up to 5 image uploads
    if (err instanceof multer.MulterError) {
      return res.status(500).json({ message: err.message });
    } else if (err) {
      return res.status(400).json({ message: 'Invalid file format' });
    }

    try {
      const { user, product, rating, comment } = req.body;
      const images = req.files ? req.files.map(file => `/uploads/reviews/${file.filename}`) : []; // Map file paths

      const newReview = new Review({
        user,
        product,
        rating,
        comment,
        images,
      });

      await newReview.save();
      res.status(201).json(newReview);
    } catch (err) {
      res.status(500).json({ message: 'Error creating review', error: err.message });
    }
  });
};

// Update a review with image handling
exports.updateReview = async (req, res) => {
  upload.array('images', 5)(req, res, async (err) => { // Allow up to 5 image uploads
    if (err instanceof multer.MulterError) {
      return res.status(500).json({ message: err.message });
    } else if (err) {
      return res.status(400).json({ message: 'Invalid file format' });
    }

    try {
      const updatedData = { ...req.body };

      // Handle images if they are uploaded
      if (req.files) {
        updatedData.images = req.files.map(file => `/uploads/reviews/${file.filename}`);
      }

      const updatedReview = await Review.findByIdAndUpdate(req.params.id, updatedData, { new: true });

      if (!updatedReview) {
        return res.status(404).json({ message: 'Review not found' });
      }

      res.status(200).json(updatedReview);
    } catch (err) {
      res.status(500).json({ message: 'Error updating review', error: err.message });
    }
  });
};

// Delete a review
exports.deleteReview = async (req, res) => {
  try {
    const deletedReview = await Review.findByIdAndDelete(req.params.id);
    if (!deletedReview) {
      return res.status(404).json({ message: 'Review not found' });
    }
    res.status(200).json({ message: 'Review deleted successfully' });
  } catch (err) {
    res.status(500).json({ message: 'Error deleting review', error: err.message });
  }
};

// Serve the uploaded image
exports.getReviewImage = (req, res) => {
  const imageName = req.params.imageName;
  const imagePath = path.join(__dirname, '..', 'uploads', 'reviews', imageName); // Adjust path to reviews folder

  res.sendFile(imagePath, (err) => {
    if (err) {
      res.status(404).json({ message: 'Image not found' });
    }
  });
};

const Product = require('../models/ProductSchema');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Define the upload directory for product images
const uploadDir = path.join(__dirname, '..', 'uploads', 'products');

// Create the 'products' folder if it doesn't exist
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Set up multer storage for image upload in 'uploads/products'
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir); // Save image to 'uploads/products' folder
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

// Get all products
exports.getAllProducts = async (req, res) => {
  try {
    const products = await Product.find();
    res.status(200).json(products);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching products', error: err.message });
  }
};

// Get a product by ID
exports.getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }
    res.status(200).json(product);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching product', error: err.message });
  }
};


exports.getProductsByCategory = async (req, res) => {
  try {
    const { categoryId } = req.params; // Extract categoryId from request parameters
    const products = await Product.find({ category: categoryId });

    if (products.length === 0) {
      return res.status(404).json({ message: 'No products found for this category' });
    }

    res.status(200).json(products);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching products', error: err.message });
  }
};


// Create a new product with image handling
exports.createProduct = async (req, res) => {
  upload.array('images')(req, res, async (err) => { 
    if (err instanceof multer.MulterError) {
      return res.status(500).json({ message: err.message });
    } else if (err) {
      return res.status(400).json({ message: 'Invalid file format' });
    }

    try {
      const { name, description, category, brand, original_price, discount_percentage, color, sizes, stock_quantity, gender, age_category, similar_products, rating, is_active ,deliveryOption} = req.body;

      // Ensure color and sizes are arrays (in case they come as strings, we'll convert them to arrays)
      const colorArray = Array.isArray(color) ? color : JSON.parse(color);
      const sizeArray = Array.isArray(sizes) ? sizes : JSON.parse(sizes);

      // Generate image URLs for the uploaded files
      const images = req.files ? req.files.map(file => `/uploads/products/${file.filename}`) : [];

      const newProduct = new Product({
        name,
        description,
        category,
        brand,
        original_price,
        discount_percentage,
        color: colorArray, // Ensure it's an array
        sizes: sizeArray,   // Ensure it's an array
        stock_quantity,
        images,
        gender,
        age_category,
        similar_products,
        rating,
        is_active,
        deliveryOption
      });

      await newProduct.save();
      res.status(201).json(newProduct);
    } catch (err) {
      res.status(500).json({ message: 'Error creating product', error: err.message });
    }
  });
};

// Update a product with image handling
exports.updateProduct = async (req, res) => {
  upload.array('images')(req, res, async (err) => { // Allow up to 5 image uploads
    if (err instanceof multer.MulterError) {
      return res.status(500).json({ message: err.message });
    } else if (err) {
      return res.status(400).json({ message: 'Invalid file format' });
    }

    try {
      const updatedData = { ...req.body };

      // Handle color and sizes arrays if they are stringified
      if (updatedData.color && typeof updatedData.color === 'string') {
        updatedData.color = JSON.parse(updatedData.color); // Convert stringified array to actual array
      }
      if (updatedData.sizes && typeof updatedData.sizes === 'string') {
        updatedData.sizes = JSON.parse(updatedData.sizes); // Convert stringified array to actual array
      }

      // Handle images if they are uploaded
      if (req.files) {
        updatedData.images = req.files.map(file => `/uploads/products/${file.filename}`);
      }

      const updatedProduct = await Product.findByIdAndUpdate(req.params.id, updatedData, { new: true });

      if (!updatedProduct) {
        return res.status(404).json({ message: 'Product not found' });
      }

      res.status(200).json(updatedProduct);
    } catch (err) {
      res.status(500).json({ message: 'Error updating product', error: err.message });
    }
  });
};

// Delete a product
exports.deleteProduct = async (req, res) => {
  try {
    const deletedProduct = await Product.findByIdAndDelete(req.params.id);
    if (!deletedProduct) {
      return res.status(404).json({ message: 'Product not found' });
    }
    res.status(200).json({ message: 'Product deleted successfully' });
  } catch (err) {
    res.status(500).json({ message: 'Error deleting product', error: err.message });
  }
};

// Serve the uploaded product image
exports.getProductImage = (req, res) => {
  const imageName = req.params.imageName;
  const imagePath = path.join(__dirname, '..', 'uploads', 'products', imageName);

  res.sendFile(imagePath, (err) => {
    if (err) {
      res.status(404).json({ message: 'Image not found' });
    }
  });
};

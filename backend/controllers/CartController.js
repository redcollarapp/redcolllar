const AddToCart = require('../models/CartSchema'); // Import Cart Model

// GET all cart items
exports.getCartItems = async (req, res) => {
  try {
    const cartItems = await AddToCart.find().populate('user').populate('product'); // Populate user and product details
    res.status(200).json(cartItems);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// GET cart item by ID
exports.getCartItemById = async (req, res) => {
  try {
    const cartItem = await AddToCart.findById(req.params.id).populate('user').populate('product');
    if (!cartItem) {
      return res.status(404).json({ message: 'Cart item not found' });
    }
    res.status(200).json(cartItem);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ADD item to cart (POST)
exports.addToCart = async (req, res) => {
  try {
    const { user, product, quantity, selected_color, selected_size, total_price } = req.body;

    const newCartItem = new AddToCart({
      user,
      product,
      quantity,
      selected_color,
      selected_size,
      total_price
    });

    const savedCartItem = await newCartItem.save();
    res.status(201).json(savedCartItem);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// UPDATE cart item (PUT)
exports.updateCartItem = async (req, res) => {
  try {
    const updatedCartItem = await AddToCart.findByIdAndUpdate(req.params.id, req.body, { new: true });
    
    if (!updatedCartItem) {
      return res.status(404).json({ message: 'Cart item not found' });
    }
    
    res.status(200).json(updatedCartItem);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// DELETE cart item
exports.deleteCartItem = async (req, res) => {
  try {
    const deletedCartItem = await AddToCart.findByIdAndDelete(req.params.id);
    
    if (!deletedCartItem) {
      return res.status(404).json({ message: 'Cart item not found' });
    }
    
    res.status(200).json({ message: 'Cart item deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


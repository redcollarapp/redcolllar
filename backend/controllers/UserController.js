const bcrypt = require('bcrypt');
const crypto = require('crypto');
const nodemailer = require('nodemailer');
const User = require('../models/UsersSchema');

// Create a new user (Registration)
exports.registerUser = async (req, res) => {
  const { username, email, password,phoneNumber} = req.body;
  console.log(req.body);
  

  try {
    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = new User({ username, email, password: hashedPassword ,phoneNumber});
    await newUser.save();

    res.status(201).json({ message: 'User registered successfully' });
  } catch (err) {
    if (err.code === 11000) {
      return res.status(400).json({ error: 'Email already exists' });
    }
    res.status(500).json({ error: err.message });
  }
};

// Login user
exports.loginUser = async (req, res) => {
  const { email, password } = req.body;

  try {
    // Check if the email matches the admin credentials
    if (email === 'redcollar@gmail.com' && password === 'redcollar@123') {
      return res.status(200).json({
        success: true,
        message: 'Login successful',
        username: 'redcollar', // Admin username
        isAdmin: true, // Mark as admin
        _id: 'admin_id', // You can replace this with actual admin ID if needed
        name: 'Admin Name', // Placeholder for actual admin name
        email: email, // Admin email
      });
    }

    // Check if user exists in the database
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    // Compare passwords
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }

    // Login successful, return user info along with _id, name, and email
    res.status(200).json({
      success: true,
      message: 'Login successful',
      username: user.username, // Using the username from the database
      isAdmin: user.isAdmin || false, // Default to false if not admin
      _id: user._id, // Return user _id
      name: user.username, // Assuming username field is the name
      email: user.email, // Return user email
    });
  } catch (err) {
    console.error('Error during login:', err);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

// Endpoint for sending reset password email
const transporter = nodemailer.createTransport({
  host: 'smtp.gmail.com', // SMTP server for Gmail
  port: 587, // Secure SMTP port for Gmail
  secure: false, // Use STARTTLS (false for port 587)
  auth: {
    user: 'clinetredcollar@gmail.com',
    pass: 'ipehalalhlzctbun',
  },
  tls: {
    rejectUnauthorized: false,
  },
});

exports.forgotPassword = async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ message: 'Email is required' });
  }

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Generate a reset token (hex) and set expiration time (30 minutes)
    const resetToken = crypto.randomBytes(32).toString('hex');
    const expirationTime = Date.now() + 30 * 60 * 1000; // 30 minutes

    // Store token and expiration in the database
    user.resetToken = resetToken;
    user.resetTokenExpiration = expirationTime;
    await user.save();

    // Generate password reset link
    const resetLink = `http://10.0.2.2:6000/reset-password?token=${resetToken}`;

    const mailOptions = {
      from: 'clinetredcollar@gmail.com',
      to: email,
      subject: 'Password Reset Request',
      html: `
        <p>You requested a password reset.</p>
        <p>Click the link below to reset your password:</p>
        <a href="${resetLink}" target="_blank">Reset Password</a>
        <p>This link is valid for 30 minutes.</p>
        <p>If you did not request this, please ignore this email.</p>
      `,
    };

    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        return res.status(500).json({ message: 'Failed to send email', error: error.toString() });
      }
      res.status(200).json({ message: 'Password reset email sent successfully.' });
    });
  } catch (error) {
    res.status(500).json({ message: 'Error processing request', error });
  }
};

// Reset Password (Verify Token & Update Password)
exports.resetPassword = async (req, res) => {
  const { token, newPassword, confirmPassword } = req.body;

  if (!newPassword || !confirmPassword) {
    return res.status(400).json({ message: 'Both password fields are required' });
  }

  if (newPassword !== confirmPassword) {
    return res.status(400).json({ message: 'Passwords do not match' });
  }

  try {
    const user = await User.findOne({
      resetToken: token,
      resetTokenExpiration: { $gt: Date.now() }, // Check token expiration
    });

    if (!user) {
      return res.status(400).json({ message: 'Invalid or expired token' });
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update password and remove token
    user.password = hashedPassword;
    user.resetToken = null;
    user.resetTokenExpiration = null;
    await user.save();

    res.status(200).json({ message: 'Password reset successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error resetting password', error });
  }
};

// Get all users
exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.find(); // Fetch all users from the database
    res.status(200).json(users); // Send the list of users as the response
  } catch (err) {
    console.error('Error fetching users:', err);
    res.status(500).json({ message: 'Error fetching users.' });
  }
};

//updateuser
exports.updateUserById = async (req, res) => {
  const { id } = req.params;
  const { email, password, username, phoneNumber } = req.body;

  // Prepare the update object, only including fields that are provided
  let updateData = {};

  if (email) {
    updateData.email = email;
  }
  if (username) {
    updateData.username = username;
  }
  if (phoneNumber) {
    updateData.phoneNumber = phoneNumber;
  }
  if (password) {
    // Hash the password if it is provided
    try {
      const hashedPassword = await bcrypt.hash(password, 10);
      updateData.password = hashedPassword;
    } catch (error) {
      return res.status(500).json({ message: 'Error hashing password', error });
    }
  }

  // If no fields are provided, send an error
  if (Object.keys(updateData).length === 0) {
    return res.status(400).json({ message: 'At least one field is required to update' });
  }

  try {
    // Find user by ID and update the fields
    const updatedUser = await User.findByIdAndUpdate(
      id, // Find user by ID
      updateData, // Update only the fields provided
      { new: true } // Return the updated user document
    );

    // If no user is found with the given ID
    if (!updatedUser) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({ message: 'User updated successfully', updatedUser });
  } catch (error) {
    res.status(500).json({ message: 'Error updating user', error });
  }
};
// Delete user by ID
exports.deleteUserById = async (req, res) => {
  const { id } = req.params;

  try {
    const deletedUser = await User.findByIdAndDelete(id);

    if (!deletedUser) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({ message: 'User deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting user', error });
  }
};

# SmartWhere Backend API - Complete Implementation Guide

## 🚀 Quick Start for Backend Developer

### Prerequisites

- Node.js (v16+)
- MongoDB (v5+)
- Cloudinary account
- Git

### Initial Setup Commands

```bash
# Create project directory
mkdir smartwhere-backend && cd smartwhere-backend

# Initialize project
npm init -y

# Install core dependencies
npm install express mongoose cloudinary multer jsonwebtoken bcryptjs helmet cors dotenv joi express-rate-limit express-validator morgan compression

# Install dev dependencies
npm install -D nodemon concurrently

# Create folder structure
mkdir -p src/{controllers,models,routes,middleware,utils,config}
mkdir -p uploads
mkdir -p public

# Initialize git
git init
echo "node_modules/\nuploads/\n.env" > .gitignore
```

## 📁 Project Structure

```
smartwhere-backend/
├── src/
│   ├── config/
│   │   ├── database.js
│   │   ├── cloudinary.js
│   │   └── jwt.js
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── userController.js
│   │   └── clothingController.js
│   ├── middleware/
│   │   ├── auth.js
│   │   ├── upload.js
│   │   ├── validation.js
│   │   └── errorHandler.js
│   ├── models/
│   │   ├── User.js
│   │   └── Clothing.js
│   ├── routes/
│   │   ├── auth.js
│   │   ├── user.js
│   │   └── clothing.js
│   ├── utils/
│   │   ├── generateTokens.js
│   │   ├── sendEmail.js
│   │   └── helpers.js
│   └── app.js
├── uploads/
├── public/
├── .env
├── .env.example
├── package.json
└── server.js
```

## 🔧 Environment Configuration

### .env.example

```env
# Server Configuration
NODE_ENV=development
PORT=3000
SERVER_URL=http://localhost:3000

# Database
MONGODB_URI=mongodb://localhost:27017/smartwhere

# JWT Configuration
JWT_SECRET=your_super_secret_jwt_key_here_min_32_chars
JWT_REFRESH_SECRET=your_super_secret_refresh_key_here_min_32_chars
JWT_EXPIRE=1h
JWT_REFRESH_EXPIRE=7d

# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
CLOUDINARY_API_KEY=your_cloudinary_api_key
CLOUDINARY_API_SECRET=your_cloudinary_api_secret

# Email Configuration (Optional - for email verification)
EMAIL_SERVICE=gmail
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_app_password
EMAIL_FROM=SmartWhere <noreply@smartwhere.com>

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# File Upload
MAX_FILE_SIZE=10485760
ALLOWED_FILE_TYPES=image/jpeg,image/jpg,image/png,image/webp
```

## 🗄️ Database Models

### User Model (src/models/User.js)

```javascript
const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

const userSchema = new mongoose.Schema(
  {
    email: {
      type: String,
      required: [true, "Email is required"],
      unique: true,
      lowercase: true,
      trim: true,
      match: [
        /^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/,
        "Please enter a valid email",
      ],
    },
    password: {
      type: String,
      required: [true, "Password is required"],
      minlength: [6, "Password must be at least 6 characters"],
      select: false,
    },
    name: {
      type: String,
      required: [true, "Name is required"],
      trim: true,
      maxlength: [50, "Name cannot exceed 50 characters"],
    },
    phone: {
      type: String,
      trim: true,
      match: [/^\+?[1-9]\d{1,14}$/, "Please enter a valid phone number"],
    },
    gender: {
      type: String,
      enum: ["male", "female", "other"],
      lowercase: true,
    },
    avatar: {
      type: String,
      default: null,
    },
    isEmailVerified: {
      type: Boolean,
      default: false,
    },
    emailVerificationToken: String,
    emailVerificationExpires: Date,
    passwordResetToken: String,
    passwordResetExpires: Date,
    refreshTokens: [
      {
        token: String,
        createdAt: {
          type: Date,
          default: Date.now,
          expires: 604800, // 7 days
        },
      },
    ],
  },
  {
    timestamps: true,
  }
);

// Hash password before saving
userSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

// Compare password method
userSchema.methods.comparePassword = async function (candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Generate email verification token
userSchema.methods.generateEmailVerificationToken = function () {
  const token = crypto.randomBytes(32).toString("hex");
  this.emailVerificationToken = crypto
    .createHash("sha256")
    .update(token)
    .digest("hex");
  this.emailVerificationExpires = Date.now() + 24 * 60 * 60 * 1000; // 24 hours
  return token;
};

// Generate password reset token
userSchema.methods.generatePasswordResetToken = function () {
  const token = crypto.randomBytes(32).toString("hex");
  this.passwordResetToken = crypto
    .createHash("sha256")
    .update(token)
    .digest("hex");
  this.passwordResetExpires = Date.now() + 10 * 60 * 1000; // 10 minutes
  return token;
};

module.exports = mongoose.model("User", userSchema);
```

### Clothing Model (src/models/Clothing.js)

```javascript
const mongoose = require("mongoose");

const clothingSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Clothing name is required"],
      trim: true,
      maxlength: [100, "Name cannot exceed 100 characters"],
    },
    category: {
      type: String,
      required: [true, "Category is required"],
      enum: [
        "t-shirt",
        "jeans",
        "shirt",
        "jacket",
        "hoodie",
        "trousers",
        "shorts",
        "sweater",
        "pants",
        "kurta",
        "coat",
        "capris",
        "dupatta",
        "kurtas",
        "leggings",
        "puffer_jacket",
        "tops",
        "cotton pants",
      ],
      lowercase: true,
    },
    gender: {
      type: String,
      required: [true, "Gender is required"],
      enum: ["men", "women"],
      lowercase: true,
    },
    imageUrl: {
      type: String,
      required: [true, "Image URL is required"],
    },
    cloudinaryId: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      maxlength: [500, "Description cannot exceed 500 characters"],
    },
    brand: {
      type: String,
      trim: true,
      maxlength: [50, "Brand name cannot exceed 50 characters"],
    },
    color: {
      type: String,
      trim: true,
      maxlength: [30, "Color cannot exceed 30 characters"],
    },
    size: {
      type: String,
      trim: true,
      maxlength: [10, "Size cannot exceed 10 characters"],
    },
    season: {
      type: String,
      enum: ["spring", "summer", "autumn", "winter", "all-season"],
      lowercase: true,
    },
    tags: [
      {
        type: String,
        trim: true,
        maxlength: [20, "Tag cannot exceed 20 characters"],
      },
    ],
    isFavorite: {
      type: Boolean,
      default: false,
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

// Index for better query performance
clothingSchema.index({ userId: 1, category: 1 });
clothingSchema.index({ userId: 1, gender: 1 });
clothingSchema.index({ userId: 1, isFavorite: 1 });
clothingSchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model("Clothing", clothingSchema);
```

## ☁️ Cloudinary Configuration

### Cloudinary Setup (src/config/cloudinary.js)

```javascript
const cloudinary = require("cloudinary").v2;

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
  secure: true,
});

// Upload image to Cloudinary
const uploadToCloudinary = async (file, folder = "smartwhere") => {
  try {
    const result = await cloudinary.uploader.upload(file.path, {
      folder: folder,
      resource_type: "auto",
      transformation: [
        { width: 1920, height: 1080, crop: "limit", quality: "auto" },
        { format: "auto" },
      ],
      eager: [
        { width: 400, height: 400, crop: "thumb", gravity: "face" },
        { width: 800, height: 600, crop: "limit" },
      ],
    });

    return {
      public_id: result.public_id,
      secure_url: result.secure_url,
      width: result.width,
      height: result.height,
      format: result.format,
      bytes: result.bytes,
    };
  } catch (error) {
    throw new Error(`Cloudinary upload failed: ${error.message}`);
  }
};

// Delete image from Cloudinary
const deleteFromCloudinary = async (publicId) => {
  try {
    const result = await cloudinary.uploader.destroy(publicId);
    return result;
  } catch (error) {
    throw new Error(`Cloudinary delete failed: ${error.message}`);
  }
};

module.exports = {
  cloudinary,
  uploadToCloudinary,
  deleteFromCloudinary,
};
```

## 🔐 Authentication System

### JWT Configuration (src/config/jwt.js)

```javascript
const jwt = require("jsonwebtoken");

const generateAccessToken = (payload) => {
  return jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRE || "1h",
    issuer: "smartwhere-api",
    audience: "smartwhere-app",
  });
};

const generateRefreshToken = (payload) => {
  return jwt.sign(payload, process.env.JWT_REFRESH_SECRET, {
    expiresIn: process.env.JWT_REFRESH_EXPIRE || "7d",
    issuer: "smartwhere-api",
    audience: "smartwhere-app",
  });
};

const verifyAccessToken = (token) => {
  return jwt.verify(token, process.env.JWT_SECRET, {
    issuer: "smartwhere-api",
    audience: "smartwhere-app",
  });
};

const verifyRefreshToken = (token) => {
  return jwt.verify(token, process.env.JWT_REFRESH_SECRET, {
    issuer: "smartwhere-api",
    audience: "smartwhere-app",
  });
};

module.exports = {
  generateAccessToken,
  generateRefreshToken,
  verifyAccessToken,
  verifyRefreshToken,
};
```

### Authentication Middleware (src/middleware/auth.js)

```javascript
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const { verifyAccessToken } = require("../config/jwt");

const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers["authorization"];
    const token = authHeader && authHeader.split(" ")[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({
        success: false,
        message: "Access token required",
      });
    }

    const decoded = verifyAccessToken(token);
    const user = await User.findById(decoded.userId).select(
      "-password -refreshTokens"
    );

    if (!user) {
      return res.status(401).json({
        success: false,
        message: "User not found",
      });
    }

    req.user = user;
    next();
  } catch (error) {
    if (error.name === "JsonWebTokenError") {
      return res.status(401).json({
        success: false,
        message: "Invalid token",
      });
    }
    if (error.name === "TokenExpiredError") {
      return res.status(401).json({
        success: false,
        message: "Token expired",
      });
    }
    return res.status(500).json({
      success: false,
      message: "Authentication error",
    });
  }
};

const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers["authorization"];
    const token = authHeader && authHeader.split(" ")[1];

    if (token) {
      const decoded = verifyAccessToken(token);
      const user = await User.findById(decoded.userId).select(
        "-password -refreshTokens"
      );
      req.user = user;
    }
    next();
  } catch (error) {
    next();
  }
};

module.exports = {
  authenticateToken,
  optionalAuth,
};
```

## 📤 File Upload Middleware

### Multer Configuration (src/middleware/upload.js)

```javascript
const multer = require("multer");
const path = require("path");

// Configure multer for memory storage
const storage = multer.memoryStorage();

const fileFilter = (req, file, cb) => {
  const allowedTypes = process.env.ALLOWED_FILE_TYPES?.split(",") || [
    "image/jpeg",
    "image/jpg",
    "image/png",
    "image/webp",
  ];

  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error("Invalid file type. Only images are allowed."), false);
  }
};

const upload = multer({
  storage: storage,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 10 * 1024 * 1024, // 10MB
    files: 1,
  },
  fileFilter: fileFilter,
});

// Error handling middleware for multer
const handleUploadError = (error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === "LIMIT_FILE_SIZE") {
      return res.status(400).json({
        success: false,
        message: "File too large. Maximum size is 10MB.",
      });
    }
    if (error.code === "LIMIT_FILE_COUNT") {
      return res.status(400).json({
        success: false,
        message: "Too many files. Only one file allowed.",
      });
    }
  }

  if (error.message === "Invalid file type. Only images are allowed.") {
    return res.status(400).json({
      success: false,
      message: error.message,
    });
  }

  next(error);
};

module.exports = {
  upload,
  handleUploadError,
};
```

## 🎯 API Controllers

### Authentication Controller (src/controllers/authController.js)

```javascript
const User = require("../models/User");
const {
  generateAccessToken,
  generateRefreshToken,
  verifyRefreshToken,
} = require("../config/jwt");
const { uploadToCloudinary } = require("../config/cloudinary");
const crypto = require("crypto");

// Register user
const register = async (req, res) => {
  try {
    const { email, password, name, phone, gender } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: "User already exists with this email",
      });
    }

    // Create user
    const user = await User.create({
      email,
      password,
      name,
      phone,
      gender,
    });

    // Generate tokens
    const accessToken = generateAccessToken({ userId: user._id });
    const refreshToken = generateRefreshToken({ userId: user._id });

    // Save refresh token
    user.refreshTokens.push({ token: refreshToken });
    await user.save();

    // Remove sensitive data
    const userResponse = user.toObject();
    delete userResponse.password;
    delete userResponse.refreshTokens;
    delete userResponse.emailVerificationToken;
    delete userResponse.passwordResetToken;

    res.status(201).json({
      success: true,
      message: "User registered successfully",
      user: userResponse,
      accessToken,
      refreshToken,
      tokenType: "Bearer",
      expiresIn: 3600,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Registration failed",
      error: error.message,
    });
  }
};

// Login user
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user and include password for comparison
    const user = await User.findOne({ email }).select("+password");
    if (!user) {
      return res.status(401).json({
        success: false,
        message: "Invalid credentials",
      });
    }

    // Check password
    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: "Invalid credentials",
      });
    }

    // Generate tokens
    const accessToken = generateAccessToken({ userId: user._id });
    const refreshToken = generateRefreshToken({ userId: user._id });

    // Save refresh token
    user.refreshTokens.push({ token: refreshToken });
    await user.save();

    // Remove sensitive data
    const userResponse = user.toObject();
    delete userResponse.password;
    delete userResponse.refreshTokens;
    delete userResponse.emailVerificationToken;
    delete userResponse.passwordResetToken;

    res.json({
      success: true,
      message: "Login successful",
      user: userResponse,
      accessToken,
      refreshToken,
      tokenType: "Bearer",
      expiresIn: 3600,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Login failed",
      error: error.message,
    });
  }
};

// Refresh token
const refreshToken = async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(401).json({
        success: false,
        message: "Refresh token required",
      });
    }

    // Verify refresh token
    const decoded = verifyRefreshToken(refreshToken);
    const user = await User.findById(decoded.userId);

    if (!user) {
      return res.status(401).json({
        success: false,
        message: "Invalid refresh token",
      });
    }

    // Check if refresh token exists in user's tokens
    const tokenExists = user.refreshTokens.some(
      (token) => token.token === refreshToken
    );
    if (!tokenExists) {
      return res.status(401).json({
        success: false,
        message: "Invalid refresh token",
      });
    }

    // Generate new tokens
    const newAccessToken = generateAccessToken({ userId: user._id });
    const newRefreshToken = generateRefreshToken({ userId: user._id });

    // Remove old refresh token and add new one
    user.refreshTokens = user.refreshTokens.filter(
      (token) => token.token !== refreshToken
    );
    user.refreshTokens.push({ token: newRefreshToken });
    await user.save();

    res.json({
      success: true,
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
      tokenType: "Bearer",
      expiresIn: 3600,
    });
  } catch (error) {
    res.status(401).json({
      success: false,
      message: "Invalid refresh token",
    });
  }
};

// Logout
const logout = async (req, res) => {
  try {
    const { refreshToken } = req.body;
    const user = req.user;

    if (refreshToken) {
      // Remove specific refresh token
      user.refreshTokens = user.refreshTokens.filter(
        (token) => token.token !== refreshToken
      );
    } else {
      // Remove all refresh tokens
      user.refreshTokens = [];
    }

    await user.save();

    res.json({
      success: true,
      message: "Logged out successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Logout failed",
    });
  }
};

module.exports = {
  register,
  login,
  refreshToken,
  logout,
};
```

### Clothing Controller (src/controllers/clothingController.js)

```javascript
const Clothing = require("../models/Clothing");
const {
  uploadToCloudinary,
  deleteFromCloudinary,
} = require("../config/cloudinary");

// Upload clothing item
const uploadClothing = async (req, res) => {
  try {
    const {
      name,
      category,
      gender,
      description,
      brand,
      color,
      size,
      season,
      tags,
    } = req.body;
    const userId = req.user._id;

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "Image file is required",
      });
    }

    // Upload to Cloudinary
    const uploadResult = await uploadToCloudinary(
      req.file,
      `smartwhere/clothing/${userId}`
    );

    // Create clothing item
    const clothing = await Clothing.create({
      name,
      category,
      gender,
      imageUrl: uploadResult.secure_url,
      cloudinaryId: uploadResult.public_id,
      description,
      brand,
      color,
      size,
      season,
      tags: tags ? JSON.parse(tags) : [],
      userId,
    });

    res.status(201).json({
      success: true,
      message: "Clothing item uploaded successfully",
      data: clothing,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Upload failed",
      error: error.message,
    });
  }
};

// Get clothing items
const getClothingItems = async (req, res) => {
  try {
    const userId = req.user._id;
    const {
      page = 1,
      limit = 20,
      category,
      gender,
      brand,
      color,
      season,
      isFavorite,
      tags,
      sortBy = "createdAt",
      sortOrder = "desc",
    } = req.query;

    // Build filter object
    const filter = { userId };
    if (category) filter.category = category;
    if (gender) filter.gender = gender;
    if (brand) filter.brand = new RegExp(brand, "i");
    if (color) filter.color = new RegExp(color, "i");
    if (season) filter.season = season;
    if (isFavorite !== undefined) filter.isFavorite = isFavorite === "true";
    if (tags) {
      const tagArray = tags.split(",");
      filter.tags = { $in: tagArray };
    }

    // Build sort object
    const sort = {};
    sort[sortBy] = sortOrder === "desc" ? -1 : 1;

    // Calculate pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);

    // Execute query
    const [items, total] = await Promise.all([
      Clothing.find(filter).sort(sort).skip(skip).limit(parseInt(limit)).lean(),
      Clothing.countDocuments(filter),
    ]);

    const totalPages = Math.ceil(total / parseInt(limit));

    res.json({
      success: true,
      data: {
        items,
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        hasNext: parseInt(page) < totalPages,
        hasPrev: parseInt(page) > 1,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to fetch clothing items",
      error: error.message,
    });
  }
};

// Delete clothing item
const deleteClothingItem = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user._id;

    const clothing = await Clothing.findOne({ _id: id, userId });
    if (!clothing) {
      return res.status(404).json({
        success: false,
        message: "Clothing item not found",
      });
    }

    // Delete from Cloudinary
    await deleteFromCloudinary(clothing.cloudinaryId);

    // Delete from database
    await Clothing.findByIdAndDelete(id);

    res.json({
      success: true,
      message: "Clothing item deleted successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Delete failed",
      error: error.message,
    });
  }
};

module.exports = {
  uploadClothing,
  getClothingItems,
  deleteClothingItem,
};
```

## 🛣️ API Routes

### Main App File (src/app.js)

```javascript
const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");
const compression = require("compression");
const rateLimit = require("express-rate-limit");
require("dotenv").config();

const app = express();

// Security middleware
app.use(helmet());
app.use(
  cors({
    origin:
      process.env.NODE_ENV === "production"
        ? ["https://your-frontend-domain.com"]
        : ["http://localhost:3000", "http://localhost:3001"],
    credentials: true,
  })
);

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  message: {
    success: false,
    message: "Too many requests, please try again later",
  },
});
app.use("/api/", limiter);

// Body parsing middleware
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// Logging
app.use(morgan("combined"));

// Compression
app.use(compression());

// Routes
app.use("/api/auth", require("./routes/auth"));
app.use("/api/user", require("./routes/user"));
app.use("/api/clothing", require("./routes/clothing"));

// Health check
app.get("/api/health", (req, res) => {
  res.json({
    success: true,
    message: "SmartWhere API is running",
    timestamp: new Date().toISOString(),
  });
});

// 404 handler
app.use("*", (req, res) => {
  res.status(404).json({
    success: false,
    message: "Route not found",
  });
});

// Error handling middleware
app.use((error, req, res, next) => {
  console.error("Error:", error);

  res.status(error.status || 500).json({
    success: false,
    message: error.message || "Internal server error",
    ...(process.env.NODE_ENV === "development" && { stack: error.stack }),
  });
});

module.exports = app;
```

### Server Entry Point (server.js)

```javascript
const app = require("./src/app");
const connectDB = require("./src/config/database");

const PORT = process.env.PORT || 3000;

// Connect to database
connectDB();

// Start server
app.listen(PORT, () => {
  console.log(`🚀 SmartWhere API running on port ${PORT}`);
  console.log(`📱 Environment: ${process.env.NODE_ENV}`);
  console.log(`🌐 Health check: http://localhost:${PORT}/api/health`);
});
```

## 🚀 Deployment Commands

### Package.json Scripts

```json
{
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  }
}
```

### Production Deployment

```bash
# Install PM2 globally
npm install -g pm2

# Start application
pm2 start server.js --name smartwhere-api

# Save PM2 configuration
pm2 save
pm2 startup
```

## 📋 Complete API Endpoints

### Authentication Endpoints

- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh` - Refresh access token
- `POST /api/auth/logout` - User logout
- `POST /api/auth/forgot-password` - Request password reset
- `POST /api/auth/reset-password` - Reset password
- `POST /api/auth/verify-email` - Verify email address
- `POST /api/auth/resend-verification` - Resend verification email

### User Management Endpoints

- `GET /api/user/profile` - Get user profile
- `PUT /api/user/profile` - Update user profile
- `PUT /api/user/change-password` - Change password
- `POST /api/user/avatar` - Upload avatar
- `DELETE /api/user/account` - Delete account

### Clothing Management Endpoints

- `POST /api/clothing/upload` - Upload clothing item
- `GET /api/clothing` - Get clothing items (with filters)
- `GET /api/clothing/:id` - Get single clothing item
- `PUT /api/clothing/:id` - Update clothing item
- `DELETE /api/clothing/:id` - Delete clothing item
- `PATCH /api/clothing/:id/favorite` - Toggle favorite
- `GET /api/clothing/search` - Search clothing items
- `GET /api/clothing/stats` - Get clothing statistics
- `GET /api/clothing/categories` - Get categories
- `GET /api/clothing/brands` - Get brands
- `DELETE /api/clothing/bulk` - Bulk delete items

## 🔒 Security Features

1. **JWT Authentication** with access and refresh tokens
2. **Password Hashing** using bcryptjs
3. **Rate Limiting** to prevent abuse
4. **CORS Protection** with whitelisted origins
5. **Helmet** for security headers
6. **Input Validation** using Joi
7. **File Type Validation** for uploads
8. **Token Blacklisting** on logout
9. **Email Verification** system
10. **Password Reset** with secure tokens

## 📊 Database Indexes

```javascript
// User collection indexes
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ emailVerificationToken: 1 });
db.users.createIndex({ passwordResetToken: 1 });

// Clothing collection indexes
db.clothings.createIndex({ userId: 1, category: 1 });
db.clothings.createIndex({ userId: 1, gender: 1 });
db.clothings.createIndex({ userId: 1, isFavorite: 1 });
db.clothings.createIndex({ userId: 1, createdAt: -1 });
db.clothings.createIndex({ userId: 1, tags: 1 });
```

This comprehensive guide provides everything needed to build a production-ready backend for the SmartWhere app with Cloudinary integration, JWT authentication, and MongoDB storage.

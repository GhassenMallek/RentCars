const mongoose = require("mongoose");
const userModel = new mongoose.Schema({

    fullname: String,
    Patent: String,
    email: String,
    Phone: Number,
    image: { type: String, },
    password: String,
    region: String,
    state: String,
    description: String,
    verified: {
        type: Boolean,
        default: false
    },
    verifiedPhone: {
        type: Boolean,
        default: false
    },
    newsletter: { type: Boolean, default: false },
    bannned: { type: Boolean, default: false }
});

module.exports = mongoose.model("user", userModel);
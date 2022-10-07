const mongoose = require("mongoose");
const adminModel = new mongoose.Schema({

    
    email: String,
    password: String,
});

module.exports = mongoose.model("admin", adminModel);
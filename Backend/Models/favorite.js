const mongoose = require("mongoose");
const favoriteModel = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
    },
    car: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'car',
        require: true,
    },
    
})

module.exports = mongoose.model("favoriteModel", favoriteModel);
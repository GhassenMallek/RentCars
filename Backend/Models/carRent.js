const mongoose = require("mongoose");
//const uniqueValidator = require('mongoose-unique-validator');


const carRent = new mongoose.Schema({



    owner: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'user',
        require: true,
    },
    tenant: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'user',
        require: true,
    },
    car: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'car',
        require: true,
    },

    price: {
        type: Number,
        // required: true
    },

    // availablity: { type: Boolean, default: false },
    locationDatefrom: { type: Date },
    locationDateto: { type: Date }


});

module.exports = mongoose.model("carRent", carRent);
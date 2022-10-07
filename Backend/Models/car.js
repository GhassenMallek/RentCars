const mongoose = require("mongoose");
//const uniqueValidator = require('mongoose-unique-validator');


const car = new mongoose.Schema({



    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'user',
        require: true,
    },
    brand: {
        type: String,
        enum: ['Alfa Romeo', 'Audi', 'BMW', 'BYD', 'Changan', 'Chery', 'Chevrolet',
            'Cupra', 'Dacia', 'DFSK', 'Dongfeng', 'Faw', 'Fiat', 'Foday', 'Ford',
            'Geely', 'Great Wall', 'Haval', 'Honda', 'Huanghai', 'Hyundai',
            'Jaguar', 'Jeep', 'KIA', 'Land Rover', 'Mercedes-Benz', 'MG', 'Porsche',
            'Renault', 'Seat', 'Skoda', 'Soueast', 'Ssangyong', 'Suzuki',
            'Volkswagen', 'Toyota', 'Other'
        ],
        default: 'Other',
        // required: true
    },
    price: {
        type: Number,
        // required: true
    },
    image: {
        type: String,
        // type: [String],
        // required: true
    },
    Model: {
        type: String,
        // required: true
    },

    Description: { type: String },
    Criteria: { type: String }, //Gear - color - fuel ...
    position: { type: String },
    availablity: { type: Boolean, default: false },
    locationDatefrom: { type: Date },
    locationDateto: { type: Date }


});

module.exports = mongoose.model("car", car);
const mongoose = require('mongoose');

const rateSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.String,
        ref: 'user',
        require: true,
    },
    rate: { type: Number, required: true },
});

module.exports = mongoose.model('rate', rateSchema);
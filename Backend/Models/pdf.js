const mongoose = require('mongoose');

const pdfSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.String,
        ref: 'user',
        required: true,
    },
    car: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'car',
        require: true,
    },

    pdffile: { type: String, required: true },
});

module.exports = mongoose.model('pdf', pdfSchema);
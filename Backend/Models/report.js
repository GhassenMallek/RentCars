const mongoose = require('mongoose');

const reportSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.String,
        ref: 'user',
        require: true,
    },
    report: { type: String, required: true },
});

module.exports = mongoose.model('report', reportSchema);
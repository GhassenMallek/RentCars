const express = require('express');

const router = express.Router();
const RateCtrl = require('../Controller/rate');
var app = express();

router.get('/:id', RateCtrl.getRates);
router.get('/', RateCtrl.getAllUser);
router.post('/', RateCtrl.addNewRate);

module.exports = router;
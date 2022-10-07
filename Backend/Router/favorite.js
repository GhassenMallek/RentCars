const express = require('express');

const router = express.Router();
const Controller = require('../controller/favorite');

router.post('/', Controller.add);
router.get('/', Controller.getAllByuser);
router.get('/all', Controller.getAllUser);
router.delete('/', Controller.delete);

module.exports = router;
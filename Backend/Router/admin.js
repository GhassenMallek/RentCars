const express = require('express');

const router = express.Router();
const UserCtrl = require('../Controller/admin');
const multer = require('../middleware/multer');
var app = express();

//paths
router.post('/', multer, UserCtrl.signup);
router.post('/login', UserCtrl.login);
module.exports = router;
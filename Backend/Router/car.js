const express = require('express');

const router = express.Router();
const carCtrl = require('../Controller/car');
const multer = require('../middleware/multer');
// const multer = require('../middleware/multercar');
var app = express();

//paths
router.get('/carsearch', carCtrl.getCarsbyName);

router.get('/', carCtrl.getCars);
router.get('/:id', carCtrl.getCarbyid);
router.get('/userdetails/:id', carCtrl.getCarbyidDetails);
router.get('/carsearch', carCtrl.getCarsbyName);
router.post('/', multer, carCtrl.addNewCar);

module.exports = router;
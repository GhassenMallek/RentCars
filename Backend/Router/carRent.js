const express = require('express');

const router = express.Router();
const carCtrl = require('../Controller/carRent');
var app = express();

//paths
router.get('/', carCtrl.getAllCars);
router.get('/details/:id', carCtrl.getDetailsRentedCarbyid);
router.get('/:car', carCtrl.getCarbyid);
router.get('/owner/:ownerID', carCtrl.getCarbyidOwner);
router.post('/', carCtrl.addNewCar);

module.exports = router;
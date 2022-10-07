const express = require("express");
const router = express.Router();
const controller = require("../controller/pdf");
const multer = require("../middleware/pdf");


router.post("/", multer, controller.addNewRate);
router.get('/:user', controller.getFifebyidUser);





module.exports = router;
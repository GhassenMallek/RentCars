const express = require('express');

const router = express.Router();
const ReportCtrl = require('../Controller/report');
var app = express();
router.post("/", ReportCtrl.add);
router.post("/", ReportCtrl.getAll);
router.put("/update",ReportCtrl.updateProfile);


module.exports = router;
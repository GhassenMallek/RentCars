const express = require('express');

const router = express.Router();
const UserCtrl = require('../Controller/user');
const multer = require('../middleware/multer');
const User = require('../Models/user');
var app = express();

//paths
router.get('/num', UserCtrl.getUserNumber);
router.get('/:id', UserCtrl.getUserbyid);
router.get('/', UserCtrl.getAllUser);

router.post('/', multer, UserCtrl.signup);
router.delete('/:id', UserCtrl.deleteUser);
router.get('/confirmation/:email/:token', UserCtrl.confirmmail);
router.post('/login', UserCtrl.login);
router.post("/reset", UserCtrl.resetPassword);
router.patch("/reset", getUserEmail, UserCtrl.updatePassword);
router.post('/pay', UserCtrl.create_payment_json);
router.post('/sendphone', UserCtrl.sendconfirmPhone);
router.post('/confirmsendphone/:phone', UserCtrl.confirmPhone);
async function getUserEmail(req, res, next) {
    try {
        user = await User.find({ email: req.body.email });
        if (user == null) {
            return res.status(404).json({ message: "cannot find user" });
        }
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
    res.user = user[0];
    console.log(user[0]);
    next();
}
module.exports = router;
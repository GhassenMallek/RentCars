const User = require('../Models/admin');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const Token = require('../Models/Token');
const nodemailer = require("nodemailer");
const crypto = require('crypto');
const cloudinary = require('../middleware/cloudinary');
const paypal = require('paypal-rest-sdk');
const { log } = require('console');
paypalconfig = require('../middleware/paypall');

exports.login = (req, res, next) => {
    User.findOne({ email: req.body.email })
        .then(user => {
            if (!user) {
                return res.status(404).json({ error: 'Invalid user ' });
            } else {
                bcrypt.compare(req.body.password, user.password)
                    .then(valid => {
                        if (!valid) {
                            return res.status(401).json({ error: 'wrong password' });
                        }
                        res.status(200).json({
                            user: user,
                            token: jwt.sign({ userId: user._id },
                                'RANDOM_TOKEN_SECRET', { expiresIn: '24h' }
                            )
                        });
                    })
                    .catch(error => res.status(500).json({ error }));
            }

        });
}

exports.signup = async (req, res) => {
    await User.init();
   
    const hashedPass = await bcrypt.hash(req.body.password, 10)
    const user = new User({
        email: req.body.email,
        password: hashedPass,
    })
    const tokenJWT = jwt.sign({ username: req.body.email }, "SECRET")

    var token = new Token({ email: user.email, token: crypto.randomBytes(16).toString('hex') });
    await token.save();
    await user.save();
    return res.status(201).json({ token: tokenJWT, user: user, reponse: "good" })

}
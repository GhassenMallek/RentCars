const User = require('../Models/user');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const Token = require('../Models/Token');
const nodemailer = require("nodemailer");
const crypto = require('crypto');
const cloudinary = require('../middleware/cloudinary');
const paypal = require('paypal-rest-sdk');
const { log } = require('console');
paypalconfig = require('../middleware/paypall');
var val;
var valConfirmPhone;
exports.getUserNumber = async(req, res) => {
  console.log('getUserNumber');
  const array = await User.find()
    res.status(200).json(array.length)
}
//get user by id
exports.getUserbyid = (req, res, next) => {
        User.findOne({ _id: req.params.id })
            .then(user => res.status(200).json(user))
            .catch(error => res.status(404).json({ message: "user not found Check id " }));
    }
    //get all user
exports.getAllUser = (req, res, next) => {
        User.find()
            .then(user => res.status(200).json({ users: user }))
            .catch(error => res.status(400).json({ error }));
    }
    //delete user
exports.deleteUser = (req, res, next) => {
        User.deleteOne({ _id: req.params.id })
            .then(() => res.status(200).json({ message: 'User deleted !' }))
            .catch(error => res.status(400).json({ message: "Check id" }));
    }
    //sign up
exports.signup = async(req, res) => {
    console.log("sign")
    await User.init();
    const array = await User.find()
    const array1 = []
    const arrayPhone = []
    const BreakError = {};
    try {
        array.forEach(element => {
            if (element.email) {
                array1.push(element.email)
                if (req.body.email == element.email) {
                    throw BreakError;
                }
            }
            if (element.Phone) {
                arrayPhone.push(element.Phone)
                if (req.body.Phone == element.Phone) {
                    throw BreakError;
                }
            }
        });
    } catch (err) {
        if (err == BreakError) {
            return res.status(409).json({
                message: 'email or phone already used !',
            })
        }
    }
    console.log('he');
    const photoCloudinary = await cloudinary.uploader.upload(req.file.path)
    const hashedPass = await bcrypt.hash(req.body.password, 10)
    const user = new User({
        fullname: req.body.fullname,
        Patent: req.body.Patent,
        email: req.body.email,
        Phone: req.body.Phone,
        description: req.body.description,
        verified: req.body.verified,
        verifiedPhone: req.body.verifiedPhone,
        region: req.body.region,
        state: req.body.state,
        newsletter: req.body.newsletter,
        password: hashedPass,
        image: photoCloudinary.url,
    })
    const tokenJWT = jwt.sign({ username: req.body.email }, "SECRET")
    try {
        var token = new Token({ email: user.email, token: crypto.randomBytes(16).toString('hex') });
        var smtpTrans = nodemailer.createTransport({
            service: 'outlook',
            auth: {
                user: process.env.email_app,
                pass: process.env.password_app,
            }
        });
        val = '\nhttp:\/\/' + req.headers.host + '\/user\/confirmation\/' + user.email + '\/' + token.token;
        fname = user.fullname;
        var messages = {
            from: process.env.email_app,
            to: user.email,
            subject: 'Account Verification Link',
            // attachments: [{
            //         filename: "logo.png",
            //         path: "./logo.png",
            //         cid: 'logo.ee'
            //     },
            // ],
            html: template(fname, val),
        };
        smtpTrans.sendMail(messages, async function(err) {
            if (err) {
                console.log(err);
                return res.status(500).send({ msg: err });
            } else {
                await token.save();
                await user.save();
                sendconfirmPhone(req.body.Phone);
                console.log('hello');
                return res.status(201).json({ token: tokenJWT, user: user, reponse: "good" })
            }
        });
    } catch (error) {
        console.log("error");
        return res.status(400).json({ reponse: error.message })
    }
};
async function sendconfirmPhone(phone) {
    valConfirmPhone = Math.floor(1000 + Math.random() * 9000);
    console.log(valConfirmPhone);
    const accountSid = process.env.accountSid;
    const authToken = process.env.authToken;
    const client = require('twilio')(accountSid, authToken);
    client.messages
        .create({
            body: 'Rent car access code : ' + valConfirmPhone,
            messagingServiceSid: process.env.messagingServiceSid,
            to: phone
        })
        .then(() => res.status(200).json({
            message: " successfully sended"
        }));
}
exports.sendconfirmPhone = (async(req, res, next) => {
    valConfirmPhone = Math.floor(1000 + Math.random() * 9000);
    console.log(valConfirmPhone);
    const accountSid = process.env.accountSid;
    const authToken = process.env.authToken;
    const client = require('twilio')(accountSid, authToken);
    client.messages
        .create({
            body: 'Rent car access code : ' + valConfirmPhone,
            messagingServiceSid: process.env.messagingServiceSid,
            to: req.body.Phone
        })
        .then(() => res.status(200).json({
            message: " successfully sended"
        }));
})
exports.confirmPhone = ((req, res, next) => {
    User.findOne({ Phone: req.params.phone },
        async function(err, user) {
            if (user.verifiedPhone == false) {
                if (req.body.confirmPhone == valConfirmPhone) {
                    const updateuser = {
                        $set: {
                            verifiedPhone: true,
                        },
                    };
                    await User.updateOne(user, updateuser);
                    res.status(200).json({
                        message: "successfully verified"
                    })
                } else {
                    res.status(400).json({
                        message: " not successfully verified"
                    })
                }
            } else {
                res.status(401).json({
                    message: " already verified"
                })
            }
        })
})
exports.confirmmail = (async(req, res, next) => {
    Token.findOne({ token: req.params.token }, function(err, token) {
        // token is not found into database i.e. token may have expired
        if (!token) {
            return res.status(400).send({ msg: 'Your verification link may have expired. Please click on resend for verify your Email.' });
        }
        // if token is found then check valid user
        else {
            User.findOne({ email: token.email, email: req.params.email }, function(err, user) {
                // not valid user
                if (!user) {
                    return res.status(401).send({ msg: 'We were unable to find a user for this verification. Please SignUp!' });
                }
                // user is already verified
                else if (user.verified) {
                    fname = user.fullname;
                    return res.status(200).send(
                        `
                    <!DOCTYPE html >
                    <html>
                    <head>
                      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                      <!-- Facebook sharing information tags -->
                      <meta property="og:title" content="Confirm Email">
                      <title>Confirm Email</title>
                      <style type="text/css">
                        #outlook a{
                            padding:0;
                          }
                          body{
                            width:100% !important;
                          }
                          .ReadMsgBody{
                            width:100%;
                          }
                          .ExternalClass{
                            width:100%;
                          }
                          body{
                            -webkit-text-size-adjust:none;
                          }
                          body{
                            margin:0;
                            padding:0;
                          }
                          img{
                            border:0;
                            height:auto;
                            line-height:100%;
                            outline:none;
                            text-decoration:none;
                          }
                          table td{
                            border-collapse:collapse;
                          }
                          #backgroundTable{
                            height:100% !important;
                            margin:0;
                            padding:0;
                            width:100% !important;
                          }
                        /*
                        @tab Page
                        @section background color
                        @tip Set the background color for your email. You may want to choose one that matches your company's branding.
                        @theme page
                        */
                          body,#backgroundTable{
                            /*@editable*/background-color:#FAFAFA;
                          }
                        /*
                        @tab Page
                        @section email border
                        @tip Set the border for your email.
                        */
                          #templateContainer{
                            /*@editable*/border:1px none #DDDDDD;
                          }
                        /*
                        @tab Page
                        @section heading 1
                        @tip Set the styling for all first-level headings in your emails. These should be the largest of your headings.
                        @style heading 1
                        */
                          h1,.h1{
                            /*@editable*/color:#202020;
                            display:block;
                            /*@editable*/font-family:Arial;
                            /*@editable*/font-size:24px;
                            /*@editable*/font-weight:bold;
                            /*@editable*/line-height:100%;
                            margin-top:20px;
                            margin-right:0;
                            margin-bottom:20px;
                            margin-left:0;
                            /*@editable*/text-align:center;
                          }
                        /*
                        @tab Page
                        @section heading 2
                        @tip Set the styling for all second-level headings in your emails.
                        @style heading 2
                        */
                          h2,.h2{
                            /*@editable*/color:#202020;
                            display:block;
                            /*@editable*/font-family:Arial;
                            /*@editable*/font-size:30px;
                            /*@editable*/font-weight:bold;
                            /*@editable*/line-height:100%;
                            margin-top:0;
                            margin-right:0;
                            margin-bottom:10px;
                            margin-left:0;
                            /*@editable*/text-align:center;
                          }
                        /*
                        @tab Page
                        @section heading 3
                        @tip Set the styling for all third-level headings in your emails.
                        @style heading 3
                        */
                          h3,.h3{
                            /*@editable*/color:#202020;
                            display:block;
                            /*@editable*/font-family:Arial;
                            /*@editable*/font-size:26px;
                            /*@editable*/font-weight:bold;
                            /*@editable*/line-height:100%;
                            margin-top:0;
                            margin-right:0;
                            margin-bottom:10px;
                            margin-left:0;
                            /*@editable*/text-align:center;
                          }
                        /*
                        @tab Page
                        @section heading 4
                        @tip Set the styling for all fourth-level headings in your emails. These should be the smallest of your headings.
                        @style heading 4
                        */
                          h4,.h4{
                            /*@editable*/color:#202020;
                            display:block;
                            /*@editable*/font-family:Arial;
                            /*@editable*/font-size:13px;
                            /*@editable*/font-weight:bold;
                            /*@editable*/line-height:100%;
                            margin-top:0;
                            margin-right:0;
                            margin-bottom:10px;
                            margin-left:0;
                            /*@editable*/text-align:center;
                          }
                        /*
                        @tab Header
                        @section preheader style
                        @tip Set the background color for your email's preheader area.
                        @theme page
                        */
                          #templatePreheader{
                            /*@editable*/background-color:#FAFAFA;
                          }
                        /*
                        @tab Header
                        @section preheader text
                        @tip Set the styling for your email's preheader text. Choose a size and color that is easy to read.
                        */
                          .preheaderContent div{
                            /*@editable*/color:#505050;
                            /*@editable*/font-family:Arial;
                            /*@editable*/font-size:10px;
                            /*@editable*/line-height:100%;
                            /*@editable*/text-align:left;
                          }
                        /*
                        @tab Header
                        @section preheader link
                        @tip Set the styling for your email's preheader links. Choose a color that helps them stand out from your text.
                        */
                          .preheaderContent div a:link,.preheaderContent div a:visited,.preheaderContent div a .yshortcuts {
                            /*@editable*/color:#336699;
                            /*@editable*/font-weight:normal;
                            /*@editable*/text-decoration:underline;
                          }
                          .preheaderContent img{
                            display:inline;
                            height:auto;
                            margin-bottom:10px;
                            max-width:280px;
                          }
                        /*
                        @tab Header
                        @section header style
                        @tip Set the background color and border for your email's header area.
                        @theme header
                        */
                          #templateHeader{
                            /*@editable*/background-color:#FFFFFF;
                            /*@editable*/border-bottom:0;
                          }
                        /*
                        @tab Header
                        @section header text
                        @tip Set the styling for your email's header text. Choose a size and color that is easy to read.
                        */
                          .headerContent{
                            /*@editable*/color:#202020;
                            /*@editable*/font-family:Arial;
                            /*@editable*/font-size:34px;
                            /*@editable*/font-weight:bold;
                            /*@editable*/line-height:100%;
                            /*@editable*/padding:0;
                            /*@editable*/text-align:left;
                            /*@editable*/vertical-align:middle;
                            background-color: #FAFAFA;
                              padding-bottom: 14px;
                          }
                        /*
                        @tab Header
                        @section header link
                        @tip Set the styling for your email's header links. Choose a color that helps them stand out from your text.
                        */
                          .headerContent a:link,.headerContent a:visited,.headerContent a .yshortcuts {
                            /*@editable*/color:#336699;
                            /*@editable*/font-weight:normal;
                            /*@editable*/text-decoration:underline;
                          }
                          #headerImage{
                            height:auto;
                            max-width:400px !important;
                          }
                        /*
                        @tab Body
                        @section body style
                        @tip Set the background color for your email's body area.
                        */
                          #templateContainer,.bodyContent{
                            /*@editable*/background-color:#FFFFFF;
                          }
                        /*
                        @tab Body
                        @section body text
                        @tip Set the styling for your email's main content text. Choose a size and color that is easy to read.
                        @theme main
                        */
                          .bodyContent div{
                            /*@editable*/color:#505050;
                            /*@editable*/font-family:Arial;
                            /*@editable*/font-size:14px;
                            /*@editable*/line-height:150%;
                            /*@editable*/text-align:left;
                          }
                        /*
                        @tab Body
                        @section body link
                        @tip Set the styling for your email's main content links. Choose a color that helps them stand out from your text.
                        */
                          .bodyContent div a:link,.bodyContent div a:visited,.bodyContent div a .yshortcuts {
                            /*@editable*/color:#336699;
                            /*@editable*/font-weight:normal;
                            /*@editable*/text-decoration:underline;
                          }
                          .bodyContent img{
                            display:inline;
                            height:auto;
                            margin-bottom:10px;
                            max-width:280px;
                          }
                        /*
                        @tab Footer
                        @section footer style
                        @tip Set the background color and top border for your email's footer area.
                        @theme footer
                        */
                          #templateFooter{
                            /*@editable*/background-color:#FFFFFF;
                            /*@editable*/border-top:0;
                          }
                        /*
                        @tab Footer
                        @section footer text
                        @tip Set the styling for your email's footer text. Choose a size and color that is easy to read.
                        @theme footer
                        */
                          .footerContent {
                            background-color: #fafafa;
                          }
                          .footerContent div{
                            /*@editable*/color:#707070;
                            /*@editable*/font-family:Arial;
                            /*@editable*/font-size:11px;
                            /*@editable*/line-height:150%;
                            /*@editable*/text-align:left;
                          }
                        /*
                        @tab Footer
                        @section footer link
                        @tip Set the styling for your email's footer links. Choose a color that helps them stand out from your text.
                        */
                          .footerContent div a:link,.footerContent div a:visited,.footerContent div a .yshortcuts {
                            /*@editable*/color:#336699;
                            /*@editable*/font-weight:normal;
                            /*@editable*/text-decoration:underline;
                          }
                          .footerContent img{
                            display:inline;
                          }
                        /*
                        @tab Footer
                        @section social bar style
                        @tip Set the background color and border for your email's footer social bar.
                        @theme footer
                        */
                          #social{
                            /*@editable*/background-color:#FAFAFA;
                            /*@editable*/border:0;
                          }
                        /*
                        @tab Footer
                        @section social bar style
                        @tip Set the background color and border for your email's footer social bar.
                        */
                          #social div{
                            /*@editable*/text-align:left;
                          }
                        /*
                        @tab Footer
                        @section utility bar style
                        @tip Set the background color and border for your email's footer utility bar.
                        @theme footer
                        */
                          #utility{
                            /*@editable*/background-color:#FFFFFF;
                            /*@editable*/border:0;
                          }
                        /*
                        @tab Footer
                        @section utility bar style
                        @tip Set the background color and border for your email's footer utility bar.
                        */
                          #utility div{
                            /*@editable*/text-align:left;
                          }
                          #monkeyRewards img{
                            display:inline;
                            height:auto;
                            max-width:280px;
                          }
                        /*
                        ATAVIST CUSTOM STYLES
                         */
                        .buttonText {
                          color: #4A90E2;
                          text-decoration: none;
                          font-weight: normal;
                          display: block;
                          border: 2px solid #585858;
                          padding: 10px 80px;
                          font-family: Arial;
                        }
                        #supportSection, .supportContent {
                          background-color: white;
                          font-family: arial;
                          font-size: 12px;
                          border-top: 1px solid #e4e4e4;
                        }
                        .bodyContent table {
                          padding-bottom: 10px;
                        }
                        .footerContent p {
                          margin: 0;
                          margin-top: 2px;
                        }
                        .headerContent.centeredWithBackground {
                          background-color: #F4EEE2;
                          text-align: center;
                          padding-top: 20px;
                          padding-bottom: 20px;
                        }
                         @media only screen and (min-device-width: 320px) and (max-device-width: 480px) {
                                h1 {
                                    font-size: 40px !important;
                                }
                                .content {
                                    font-size: 22px !important;
                                }
                                .bodyContent p {
                                    font-size: 22px !important;
                                }
                                .buttonText {
                                    font-size: 22px !important;
                                }
                                p {
                                    font-size: 16px !important;
                                }
                                .footerContent p {
                                    padding-left: 5px !important;
                                }
                                .mainContainer {
                                    padding-bottom: 0 !important;
                                }
                            }
                      </style>
                    </head>
                    <body leftmargin="0" marginwidth="0" topmargin="0" marginheight="0" offset="0" style="width:100% ;-webkit-text-size-adjust:none;margin:0;padding:0;background-color:#FAFAFA;">
                      <center>
                        <table border="0" cellpadding="0" cellspacing="0" height="100%" width="100%" id="backgroundTable" style="height:100% ;margin:0;padding:0;width:100% ;background-color:#FAFAFA;">
                          <tr>
                            <td align="center" valign="top" style="border-collapse:collapse;">
                              <!-- // Begin Template Preheader \\ -->
                              <table border="0" cellpadding="10" cellspacing="0" width="450" id="templatePreheader" style="background-color:#FAFAFA;">
                                <tr>
                                  <td valign="top" class="preheaderContent" style="border-collapse:collapse;">
                                    <!-- // Begin Module: Standard Preheader \\ -->
                                    <table border="0" cellpadding="10" cellspacing="0" width="100%">
                                      <tr>
                                        <td valign="top" style="border-collapse:collapse;">
                                          <!-- <div mc:edit="std_preheader_content">
                                                                         Use this area to offer a short teaser of your email's content. Text here will show in the preview area of some email clients.
                                                                      </div>
                                                                      -->
                                        </td>
                                      </tr>
                                    </table>
                                    <!-- // End Module: Standard Preheader \\ -->
                                  </td>
                                </tr>
                              </table>
                                    <!-- // Begin Template Header \\ -->
                                    <table border="0" cellpadding="0" cellspacing="0" width="450" id="templateHeader" style="background-color:#FFFFFF;border-bottom:0;">
                                      <tr>
                              <!-- // End Template Preheader \\ -->
                              <table border="0" cellpadding="0" cellspacing="0" width="450" id="templateContainer" style="border:1px none #DDDDDD;background-color:#FFFFFF;">
                                <tr>
                                  <td align="center" valign="top" style="border-collapse:collapse;">
                                        <td class="headerContent centeredWithBackground" style="border-collapse:collapse;color:#202020;font-family:Arial;font-size:34px;font-weight:bold;line-height:100%;padding:0;text-align:center;vertical-align:middle;background-color:#F4EEE8;padding-bottom:20px;padding-top:20px;">
                                          <!-- // Begin Module: Standard Header Image \\ -->
                                          <h1 style="color:#114E60;display:block;font-family:Arial;font-size:24px;font-weight:bold;line-height:100%;margin-top:20px;margin-right:0;margin-bottom:20px;margin-left:0;text-align:center;">Showapp application</h1>
                                          <!-- // End Module: Standard Header Image \\ -->
                                      </tr>
                                    </table>
                                    <!-- // End Template Header \\ -->
                                  </td>
                                </tr>
                                <tr>
                                  <td align="center" valign="top" style="border-collapse:collapse;">
                                    <!-- // Begin Template Body \\ -->
                                    <table border="1" cellpadding="0" cellspacing="0" width="450" id="templateBody">
                                      <tr>
                                        <td valign="top" class="bodyContent" style="border-collapse:collapse;background-color:#F3F4ED;">
                                          <!-- // Begin Module: Standard Content \\ -->
                                          <table border="0" cellpadding="12" cellspacing="0" width="100%" style="padding-bottom:10px;">
                                            <tr>
                                              <td valign="top" style="padding-bottom:1rem;border-collapse:collapse;" class="mainContainer">
                                                <div style="text-align:center;color:#FF96AD;font-family:Arial;font-size:14px;line-height:150%;">
                                                <br>
                                                  <br>
                                                  <h1 class="h1" style="color:#114E60;display:block;font-family:Arial;font-size:24px;font-weight:bold;line-height:100%;margin-top:20px;margin-right:0;margin-bottom:20px;margin-left:0;text-align:left;">Hello ${fname} ,</h1>
                                                </div>
                                              </td>
                                            </tr>
                                            <tr>
                                              <td align="left" style="border-collapse:collapse;">
                                                <table border="0" cellpadding="0" cellspacing="0" style="padding-bottom:10px;">
                                                  <tbody>
                                                    <tr align="center">
                                                      <td align="left" valign="middle" style="border-collapse:collapse;">
                                                        <p class="buttonText" href="#" target="_blank" style="color: #325288;text-decoration: none;font-weight: normal;display: all ;border: 0px solid #022E57;padding: 10px 6px;font-size:15px;font-family: TimeNewroman;">Thank you for using our application your account is already verified</p>
                                                        <p class="buttonText" href="#" target="_blank" style="color: #325288;text-decoration: none;font-weight: normal;display: all ;border: 0px solid #022E57;padding: 10px 60px;font-size:10px;font-family: TimeNewroman;"></p>
                                                        <p class="h1" style="color:#114E60;font-family:TimeNewroman;font-size:20px;font-weight:bold;text-align:right;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Thank you!</>
                                                      </td>
                                                    </tr>
                                                  </tbody>
                                                </table>
                                              </td>
                                            </tr>
                                          </table>
                                          <!-- // End Module: Standard Content \\ -->
                                        </td>
                                      </tr>
                                    </table>
                                    <!-- // End Template Body \\ -->
                                  </td>
                                </tr>
                                <tr>
                                  <td align="center" valign="top" style="border-collapse:collapse;">
                                    <!-- // Begin Support Section \\ -->
                                    <table border="0" cellpadding="10" cellspacing="0" width="450" id="supportSection"  style="background-color:black;font-family:arial;font-size:12px;border-top:1px solid #e4e4e4;">
                                      <tr>
                                        <td valign="top" class="supportContent" style="border-collapse:collapse;background-color:#F4EEE8;font-family:arial;font-size:12px;border-top:1px solid #e4e4e4;">
                                          <!-- // Begin Module: Standard Footer \\ -->
                                          <table border="0" cellpadding="10" cellspacing="0" width="100%">
                                            <tr>
                                              <td valign="top" width="100%" style="border-collapse:collapse;">
                                                <br>
                                                <div style="text-align: center; color: #02475E;">
                                                  <p>Questions? Get your answers here:&nbsp;
                                                  showapp.application@gmail.com.</p>
                                                </div>
                                                <br>
                                              </td>
                                            </tr>
                                          </table>
                                          <!-- // End Module: Standard Footer \\ -->
                                        </td>
                                      </tr>
                                    </table>
                                    <!-- // Begin Support Section \\ -->
                                  </td>
                                </tr>
                                <tr>
                                  <td align="center" valign="top" style="border-collapse:collapse;">
                                    <!-- // Begin Template Footer \\ -->
                                    <table border="0" cellpadding="10" cellspacing="0" width="450" id="templateFooter" style="background-color:#FFFFFF;border-top:0;">
                                      <tr>
                                        <td valign="top" class="footerContent" style="padding-left:0;border-collapse:collapse;background-color:#fafafa;">
                                          <div style="text-align:center;color:#02475E;font-family:Arial;font-size:11px;line-height:150%;">
                                            <p style="text-align:right;margin:0;margin-top:2px;">showapp                      | Copyright © 2021 | All rights reserved</p>
                                          </div>
                                          <!-- // End Module: Standard Footer \\ -->
                                        </td>
                                      </tr>
                                    </table>
                                    <!-- // End Template Footer \\ -->
                                  </td>
                                </tr>
                              </table>
                              <br>
                            </td>
                          </tr>
                        </table>
                      </center>
                    </body>
                    </html>
                `
                    );
                }
                // verify user
                else {
                    fname = user.fullname;
                    const filter = { _id: user._id };
                    const updateDoc = {
                        $set: {
                            verified: true
                        },
                    };
                    console.log(User.verified);
                    // change Verified to true
                    User.verified = true;
                    User.updateOne(filter, updateDoc, function(err) {
                        User.findOne({ email: token.email, email: req.params.email }, function(err, user) { console.log(User.verified) });
                        // error occur
                        if (err) {
                            return res.status(500).send({ msg: err.message });
                        }
                        // account successfully verified
                        else {
                            return res.status(200).send(`
                          <!DOCTYPE html >
                          <html>
                          <head>
                            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                            <!-- Facebook sharing information tags -->
                            <meta property="og:title" content="Confirm Email">
                            <title>Confirm Email</title>
                            <style type="text/css">
                              #outlook a{
                                  padding:0;
                                }
                                body{
                                  width:100% !important;
                                }
                                .ReadMsgBody{
                                  width:100%;
                                }
                                .ExternalClass{
                                  width:100%;
                                }
                                body{
                                  -webkit-text-size-adjust:none;
                                }
                                body{
                                  margin:0;
                                  padding:0;
                                }
                                img{
                                  border:0;
                                  height:auto;
                                  line-height:100%;
                                  outline:none;
                                  text-decoration:none;
                                }
                                table td{
                                  border-collapse:collapse;
                                }
                                #backgroundTable{
                                  height:100% !important;
                                  margin:0;
                                  padding:0;
                                  width:100% !important;
                                }
                              /*
                              @tab Page
                              @section background color
                              @tip Set the background color for your email. You may want to choose one that matches your company's branding.
                              @theme page
                              */
                                body,#backgroundTable{
                                  /*@editable*/background-color:#FAFAFA;
                                }
                              /*
                              @tab Page
                              @section email border
                              @tip Set the border for your email.
                              */
                                #templateContainer{
                                  /*@editable*/border:1px none #DDDDDD;
                                }
                              /*
                              @tab Page
                              @section heading 1
                              @tip Set the styling for all first-level headings in your emails. These should be the largest of your headings.
                              @style heading 1
                              */
                                h1,.h1{
                                  /*@editable*/color:#202020;
                                  display:block;
                                  /*@editable*/font-family:Arial;
                                  /*@editable*/font-size:24px;
                                  /*@editable*/font-weight:bold;
                                  /*@editable*/line-height:100%;
                                  margin-top:20px;
                                  margin-right:0;
                                  margin-bottom:20px;
                                  margin-left:0;
                                  /*@editable*/text-align:center;
                                }
                              /*
                              @tab Page
                              @section heading 2
                              @tip Set the styling for all second-level headings in your emails.
                              @style heading 2
                              */
                                h2,.h2{
                                  /*@editable*/color:#202020;
                                  display:block;
                                  /*@editable*/font-family:Arial;
                                  /*@editable*/font-size:30px;
                                  /*@editable*/font-weight:bold;
                                  /*@editable*/line-height:100%;
                                  margin-top:0;
                                  margin-right:0;
                                  margin-bottom:10px;
                                  margin-left:0;
                                  /*@editable*/text-align:center;
                                }
                              /*
                              @tab Page
                              @section heading 3
                              @tip Set the styling for all third-level headings in your emails.
                              @style heading 3
                              */
                                h3,.h3{
                                  /*@editable*/color:#202020;
                                  display:block;
                                  /*@editable*/font-family:Arial;
                                  /*@editable*/font-size:26px;
                                  /*@editable*/font-weight:bold;
                                  /*@editable*/line-height:100%;
                                  margin-top:0;
                                  margin-right:0;
                                  margin-bottom:10px;
                                  margin-left:0;
                                  /*@editable*/text-align:center;
                                }
                              /*
                              @tab Page
                              @section heading 4
                              @tip Set the styling for all fourth-level headings in your emails. These should be the smallest of your headings.
                              @style heading 4
                              */
                                h4,.h4{
                                  /*@editable*/color:#202020;
                                  display:block;
                                  /*@editable*/font-family:Arial;
                                  /*@editable*/font-size:13px;
                                  /*@editable*/font-weight:bold;
                                  /*@editable*/line-height:100%;
                                  margin-top:0;
                                  margin-right:0;
                                  margin-bottom:10px;
                                  margin-left:0;
                                  /*@editable*/text-align:center;
                                }
                              /*
                              @tab Header
                              @section preheader style
                              @tip Set the background color for your email's preheader area.
                              @theme page
                              */
                                #templatePreheader{
                                  /*@editable*/background-color:#FAFAFA;
                                }
                              /*
                              @tab Header
                              @section preheader text
                              @tip Set the styling for your email's preheader text. Choose a size and color that is easy to read.
                              */
                                .preheaderContent div{
                                  /*@editable*/color:#505050;
                                  /*@editable*/font-family:Arial;
                                  /*@editable*/font-size:10px;
                                  /*@editable*/line-height:100%;
                                  /*@editable*/text-align:left;
                                }
                              /*
                              @tab Header
                              @section preheader link
                              @tip Set the styling for your email's preheader links. Choose a color that helps them stand out from your text.
                              */
                                .preheaderContent div a:link,.preheaderContent div a:visited,.preheaderContent div a .yshortcuts {
                                  /*@editable*/color:#336699;
                                  /*@editable*/font-weight:normal;
                                  /*@editable*/text-decoration:underline;
                                }
                                .preheaderContent img{
                                  display:inline;
                                  height:auto;
                                  margin-bottom:10px;
                                  max-width:280px;
                                }
                              /*
                              @tab Header
                              @section header style
                              @tip Set the background color and border for your email's header area.
                              @theme header
                              */
                                #templateHeader{
                                  /*@editable*/background-color:#FFFFFF;
                                  /*@editable*/border-bottom:0;
                                }
                              /*
                              @tab Header
                              @section header text
                              @tip Set the styling for your email's header text. Choose a size and color that is easy to read.
                              */
                                .headerContent{
                                  /*@editable*/color:#202020;
                                  /*@editable*/font-family:Arial;
                                  /*@editable*/font-size:34px;
                                  /*@editable*/font-weight:bold;
                                  /*@editable*/line-height:100%;
                                  /*@editable*/padding:0;
                                  /*@editable*/text-align:left;
                                  /*@editable*/vertical-align:middle;
                                  background-color: #FAFAFA;
                                    padding-bottom: 14px;
                                }
                              /*
                              @tab Header
                              @section header link
                              @tip Set the styling for your email's header links. Choose a color that helps them stand out from your text.
                              */
                                .headerContent a:link,.headerContent a:visited,.headerContent a .yshortcuts {
                                  /*@editable*/color:#336699;
                                  /*@editable*/font-weight:normal;
                                  /*@editable*/text-decoration:underline;
                                }
                                #headerImage{
                                  height:auto;
                                  max-width:400px !important;
                                }
                              /*
                              @tab Body
                              @section body style
                              @tip Set the background color for your email's body area.
                              */
                                #templateContainer,.bodyContent{
                                  /*@editable*/background-color:#FFFFFF;
                                }
                              /*
                              @tab Body
                              @section body text
                              @tip Set the styling for your email's main content text. Choose a size and color that is easy to read.
                              @theme main
                              */
                                .bodyContent div{
                                  /*@editable*/color:#505050;
                                  /*@editable*/font-family:Arial;
                                  /*@editable*/font-size:14px;
                                  /*@editable*/line-height:150%;
                                  /*@editable*/text-align:left;
                                }
                              /*
                              @tab Body
                              @section body link
                              @tip Set the styling for your email's main content links. Choose a color that helps them stand out from your text.
                              */
                                .bodyContent div a:link,.bodyContent div a:visited,.bodyContent div a .yshortcuts {
                                  /*@editable*/color:#336699;
                                  /*@editable*/font-weight:normal;
                                  /*@editable*/text-decoration:underline;
                                }
                                .bodyContent img{
                                  display:inline;
                                  height:auto;
                                  margin-bottom:10px;
                                  max-width:280px;
                                }
                              /*
                              @tab Footer
                              @section footer style
                              @tip Set the background color and top border for your email's footer area.
                              @theme footer
                              */
                                #templateFooter{
                                  /*@editable*/background-color:#FFFFFF;
                                  /*@editable*/border-top:0;
                                }
                              /*
                              @tab Footer
                              @section footer text
                              @tip Set the styling for your email's footer text. Choose a size and color that is easy to read.
                              @theme footer
                              */
                                .footerContent {
                                  background-color: #fafafa;
                                }
                                .footerContent div{
                                  /*@editable*/color:#707070;
                                  /*@editable*/font-family:Arial;
                                  /*@editable*/font-size:11px;
                                  /*@editable*/line-height:150%;
                                  /*@editable*/text-align:left;
                                }
                              /*
                              @tab Footer
                              @section footer link
                              @tip Set the styling for your email's footer links. Choose a color that helps them stand out from your text.
                              */
                                .footerContent div a:link,.footerContent div a:visited,.footerContent div a .yshortcuts {
                                  /*@editable*/color:#336699;
                                  /*@editable*/font-weight:normal;
                                  /*@editable*/text-decoration:underline;
                                }
                                .footerContent img{
                                  display:inline;
                                }
                              /*
                              @tab Footer
                              @section social bar style
                              @tip Set the background color and border for your email's footer social bar.
                              @theme footer
                              */
                                #social{
                                  /*@editable*/background-color:#FAFAFA;
                                  /*@editable*/border:0;
                                }
                              /*
                              @tab Footer
                              @section social bar style
                              @tip Set the background color and border for your email's footer social bar.
                              */
                                #social div{
                                  /*@editable*/text-align:left;
                                }
                              /*
                              @tab Footer
                              @section utility bar style
                              @tip Set the background color and border for your email's footer utility bar.
                              @theme footer
                              */
                                #utility{
                                  /*@editable*/background-color:#FFFFFF;
                                  /*@editable*/border:0;
                                }
                              /*
                              @tab Footer
                              @section utility bar style
                              @tip Set the background color and border for your email's footer utility bar.
                              */
                                #utility div{
                                  /*@editable*/text-align:left;
                                }
                                #monkeyRewards img{
                                  display:inline;
                                  height:auto;
                                  max-width:280px;
                                }
                              /*
                              ATAVIST CUSTOM STYLES
                               */
                              .buttonText {
                                color: #4A90E2;
                                text-decoration: none;
                                font-weight: normal;
                                display: block;
                                border: 2px solid #585858;
                                padding: 10px 80px;
                                font-family: Arial;
                              }
                              #supportSection, .supportContent {
                                background-color: white;
                                font-family: arial;
                                font-size: 12px;
                                border-top: 1px solid #e4e4e4;
                              }
                              .bodyContent table {
                                padding-bottom: 10px;
                              }
                              .footerContent p {
                                margin: 0;
                                margin-top: 2px;
                              }
                              .headerContent.centeredWithBackground {
                                background-color: #F4EEE2;
                                text-align: center;
                                padding-top: 20px;
                                padding-bottom: 20px;
                              }
                               @media only screen and (min-device-width: 320px) and (max-device-width: 480px) {
                                      h1 {
                                          font-size: 40px !important;
                                      }
                                      .content {
                                          font-size: 22px !important;
                                      }
                                      .bodyContent p {
                                          font-size: 22px !important;
                                      }
                                      .buttonText {
                                          font-size: 22px !important;
                                      }
                                      p {
                                          font-size: 16px !important;
                                      }
                                      .footerContent p {
                                          padding-left: 5px !important;
                                      }
                                      .mainContainer {
                                          padding-bottom: 0 !important;
                                      }
                                  }
                            </style>
                          </head>
                          <body leftmargin="0" marginwidth="0" topmargin="0" marginheight="0" offset="0" style="width:100% ;-webkit-text-size-adjust:none;margin:0;padding:0;background-color:#FAFAFA;">
                            <center>
                              <table border="0" cellpadding="0" cellspacing="0" height="100%" width="100%" id="backgroundTable" style="height:100% ;margin:0;padding:0;width:100% ;background-color:#FAFAFA;">
                                <tr>
                                  <td align="center" valign="top" style="border-collapse:collapse;">
                                    <!-- // Begin Template Preheader \\ -->
                                    <table border="0" cellpadding="10" cellspacing="0" width="450" id="templatePreheader" style="background-color:#FAFAFA;">
                                      <tr>
                                        <td valign="top" class="preheaderContent" style="border-collapse:collapse;">
                                          <!-- // Begin Module: Standard Preheader \\ -->
                                          <table border="0" cellpadding="10" cellspacing="0" width="100%">
                                            <tr>
                                              <td valign="top" style="border-collapse:collapse;">
                                                <!-- <div mc:edit="std_preheader_content">
                                                                               Use this area to offer a short teaser of your email's content. Text here will show in the preview area of some email clients.
                                                                            </div>
                                                                            -->
                                              </td>
                                            </tr>
                                          </table>
                                          <!-- // End Module: Standard Preheader \\ -->
                                        </td>
                                      </tr>
                                    </table>
                                          <!-- // Begin Template Header \\ -->
                                          <table border="0" cellpadding="0" cellspacing="0" width="450" id="templateHeader" style="background-color:#FFFFFF;border-bottom:0;">
                                            <tr>
                                    <!-- // End Template Preheader \\ -->
                                    <table border="0" cellpadding="0" cellspacing="0" width="450" id="templateContainer" style="border:1px none #DDDDDD;background-color:#FFFFFF;">
                                      <tr>
                                        <td align="center" valign="top" style="border-collapse:collapse;">
                                              <td class="headerContent centeredWithBackground" style="border-collapse:collapse;color:#202020;font-family:Arial;font-size:34px;font-weight:bold;line-height:100%;padding:0;text-align:center;vertical-align:middle;background-color:#F4EEE8;padding-bottom:20px;padding-top:20px;">
                                                <!-- // Begin Module: Standard Header Image \\ -->
                                                <h1 style="color:#114E60;display:block;font-family:Arial;font-size:24px;font-weight:bold;line-height:100%;margin-top:20px;margin-right:0;margin-bottom:20px;margin-left:0;text-align:center;">Showapp application</h1>
                                                <!-- // End Module: Standard Header Image \\ -->
                                            </tr>
                                          </table>
                                          <!-- // End Template Header \\ -->
                                        </td>
                                      </tr>
                                      <tr>
                                        <td align="center" valign="top" style="border-collapse:collapse;">
                                          <!-- // Begin Template Body \\ -->
                                          <table border="1" cellpadding="0" cellspacing="0" width="450" id="templateBody">
                                            <tr>
                                              <td valign="top" class="bodyContent" style="border-collapse:collapse;background-color:#F3F4ED;">
                                                <!-- // Begin Module: Standard Content \\ -->
                                                <table border="0" cellpadding="12" cellspacing="0" width="100%" style="padding-bottom:10px;">
                                                  <tr>
                                                    <td valign="top" style="padding-bottom:1rem;border-collapse:collapse;" class="mainContainer">
                                                      <div style="text-align:center;color:#FF96AD;font-family:Arial;font-size:14px;line-height:150%;">
                                                      <br>
                                                        <br>
                                                        <h1 class="h1" style="color:#114E60;display:block;font-family:Arial;font-size:24px;font-weight:bold;line-height:100%;margin-top:20px;margin-right:0;margin-bottom:20px;margin-left:0;text-align:left;">Hello ${fname} ,</h1>
                                                      </div>
                                                    </td>
                                                  </tr>
                                                  <tr>
                                                    <td align="left" style="border-collapse:collapse;">
                                                      <table border="0" cellpadding="0" cellspacing="0" style="padding-bottom:10px;">
                                                        <tbody>
                                                          <tr align="center">
                                                            <td align="left" valign="middle" style="border-collapse:collapse;">
                                                              <p class="buttonText" href="#" target="_blank" style="color: #325288;text-decoration: none;font-weight: normal;display: all ;border: 0px solid #022E57;padding: 10px 6px;font-size:15px;font-family: TimeNewroman;">Thank you for using our application your account is  successfully verified</p>
                                                              <p class="buttonText" href="#" target="_blank" style="color: #325288;text-decoration: none;font-weight: normal;display: all ;border: 0px solid #022E57;padding: 10px 60px;font-size:10px;font-family: TimeNewroman;"></p>
                                                              <p class="h1" style="color:#114E60;font-family:TimeNewroman;font-size:20px;font-weight:bold;text-align:right;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Thank you!</>
                                                            </td>
                                                          </tr>
                                                        </tbody>
                                                      </table>
                                                    </td>
                                                  </tr>
                                                </table>
                                                <!-- // End Module: Standard Content \\ -->
                                              </td>
                                            </tr>
                                          </table>
                                          <!-- // End Template Body \\ -->
                                        </td>
                                      </tr>
                                      <tr>
                                        <td align="center" valign="top" style="border-collapse:collapse;">
                                          <!-- // Begin Support Section \\ -->
                                          <table border="0" cellpadding="10" cellspacing="0" width="450" id="supportSection"  style="background-color:black;font-family:arial;font-size:12px;border-top:1px solid #e4e4e4;">
                                            <tr>
                                              <td valign="top" class="supportContent" style="border-collapse:collapse;background-color:#F4EEE8;font-family:arial;font-size:12px;border-top:1px solid #e4e4e4;">
                                                <!-- // Begin Module: Standard Footer \\ -->
                                                <table border="0" cellpadding="10" cellspacing="0" width="100%">
                                                  <tr>
                                                    <td valign="top" width="100%" style="border-collapse:collapse;">
                                                      <br>
                                                      <div style="text-align: center; color: #02475E;">
                                                        <p>Questions? Get your answers here:&nbsp;
                                                        showapp.application@gmail.com.</p>
                                                      </div>
                                                      <br>
                                                    </td>
                                                  </tr>
                                                </table>
                                                <!-- // End Module: Standard Footer \\ -->
                                              </td>
                                            </tr>
                                          </table>
                                          <!-- // Begin Support Section \\ -->
                                        </td>
                                      </tr>
                                      <tr>
                                        <td align="center" valign="top" style="border-collapse:collapse;">
                                          <!-- // Begin Template Footer \\ -->
                                          <table border="0" cellpadding="10" cellspacing="0" width="450" id="templateFooter" style="background-color:#FFFFFF;border-top:0;">
                                            <tr>
                                              <td valign="top" class="footerContent" style="padding-left:0;border-collapse:collapse;background-color:#fafafa;">
                                                <div style="text-align:center;color:#02475E;font-family:Arial;font-size:11px;line-height:150%;">
                                                  <p style="text-align:right;margin:0;margin-top:2px;">showapp                      | Copyright © 2021 | All rights reserved</p>
                                                </div>
                                                <!-- // End Module: Standard Footer \\ -->
                                              </td>
                                            </tr>
                                          </table>
                                          <!-- // End Template Footer \\ -->
                                        </td>
                                      </tr>
                                    </table>
                                    <br>
                                  </td>
                                </tr>
                              </table>
                            </center>
                          </body>
                          </html>
                      `);
                        }
                    });
                }
            });
        }
    });
});
//login
exports.login = (req, res, next) => {
    User.findOne({ email: req.body.email })
        .then(user => {
            if (!user) {
                return res.status(404).json({ error: 'Invalid user ' });
            } else if (user.verified) {
                if (user.bannned) { return res.status(401).json({ error: 'Banned user ' }); }
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
            } else if (!user.verified) {
                return res.status(409).json({ error: 'please verify your account' });
            } else if (user.bannned) {
                return res.status(401).json({ error: 'your account is banned ' });
            } else {
                return res.status(500).json({ error: 'server error' });
            }
        })
        .catch(error => res.status(500).json({ error }));
};
//forget password
exports.resetPassword = (req, res, next) => {
        val = Math.floor(1000 + Math.random() * 9000);
        console.log(val);
        try {
            let email = req.body.email;
            User.find({ email: email }).then((user) => {
                compte = user[0];
                if (compte) {
                    var transporter = nodemailer.createTransport({
                        service: "outlook",
                        auth: {
                            user: process.env.email_app,
                            pass: process.env.password_app,
                        },
                    });
                    var mailOptions = {
                        from: process.env.email_app,
                        to: compte.email,
                        subject: "Reset password",
                        // attachments: [{
                        //         filename: "logo.png",
                        //         path: "./logo.png",
                        //         cid: 'logo.ee'
                        //     },
                        // ],
                        html: templateReset(val),
                    };
                    transporter.sendMail(mailOptions, async function(error, info) {
                        if (error) {
                            console.log(error);
                        } else {
                            console.log("Email sent: " + info.response);
                        }
                    });
                    res.json("true");
                } else {
                    res.json("false");
                }
            });
        } catch (error) {
            console.log(error);
        }
    }
    //update password
exports.updatePassword = (async(req, res, next) => {
    if (req.body.password != null) {
        if (req.body.code == val) {
            res.user.password = req.body.password;
            // req.body.password = hashedPass
            try {
                const hashedPass = await bcrypt.hash(req.body.password, 10)
                res.user.updateOne({ password: req.body.password = hashedPass })
                    .then(() => res.status(200).json({
                        //"password": req.body.password,
                        message: "Your password has been successfully reset"
                    }));
            } catch (error) {
                res.status(400).json({ message: error.message });
            }
        } else {
            res.json({ code: false });
        }
    }
});
// paypal
exports.create_payment_json = (async(req, res, next) => {
    const create_payment_json = {
        "intent": "sale",
        "payer": {
            "payment_method": "paypal"
        },
        "redirect_urls": {
            "return_url": "http://localhost:3000/success",
            "cancel_url": "http://localhost:3000/cancel"
        },
        "transactions": [{
            "item_list": {
                "items": [{
                    "name": "Redhock Bar Soap",
                    "sku": "001",
                    "price": "25.00",
                    "currency": "USD",
                    "quantity": 1
                }]
            },
            "amount": {
                "currency": "USD",
                "total": "25.00"
            },
            "description": "Washing Bar soap"
        }]
    };
    paypal.payment.create(create_payment_json, function(error, payment) {
        if (error) {
            throw error;
        } else {
            for (let i = 0; i < payment.links.length; i++) {
                if (payment.links[i].rel === 'approval_url') {
                    res.redirect(payment.links[i].href);
                }
            }
        }
    });
});

function template(fname, val) {
    return `
  <!DOCTYPE html >
  <html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <!-- Facebook sharing information tags -->
    <meta property="og:title" content="Confirm Email">
    <title>Confirm Email</title>
      <style type="text/css">
      #outlook a{
          padding:0;
        }
        body{
          width:100% !important;
        }
        .ReadMsgBody{
          width:100%;
        }
        .ExternalClass{
          width:100%;
        }
        body{
          -webkit-text-size-adjust:none;
        }
        body{
          margin:0;
          padding:0;
        }
        img{
          border:0;
          height:auto;
          line-height:100%;
          outline:none;
          text-decoration:none;
        }
        table td{
          border-collapse:collapse;
        }
        #backgroundTable{
          height:100% !important;
          margin:0;
          padding:0;
          width:100% !important;
        }
      /*
      @tab Page
      @section background color
      @tip Set the background color for your email. You may want to choose one that matches your company's branding.
      @theme page
      */
        body,#backgroundTable{
          /*@editable*/background-color:#FAFAFA;
        }
      /*
      @tab Page
      @section email border
      @tip Set the border for your email.
      */
        #templateContainer{
          /*@editable*/border:1px none #DDDDDD;
        }
      /*
      @tab Page
      @section heading 1
      @tip Set the styling for all first-level headings in your emails. These should be the largest of your headings.
      @style heading 1
      */
        h1,.h1{
          /*@editable*/color:#202020;
          display:block;
          /*@editable*/font-family:Arial;
          /*@editable*/font-size:24px;
          /*@editable*/font-weight:bold;
          /*@editable*/line-height:100%;
          margin-top:20px;
          margin-right:0;
          margin-bottom:20px;
          margin-left:0;
          /*@editable*/text-align:center;
        }
      /*
      @tab Page
      @section heading 2
      @tip Set the styling for all second-level headings in your emails.
      @style heading 2
      */
        h2,.h2{
          /*@editable*/color:#202020;
          display:block;
          /*@editable*/font-family:Arial;
          /*@editable*/font-size:30px;
          /*@editable*/font-weight:bold;
          /*@editable*/line-height:100%;
          margin-top:0;
          margin-right:0;
          margin-bottom:10px;
          margin-left:0;
          /*@editable*/text-align:center;
        }
      /*
      @tab Page
      @section heading 3
      @tip Set the styling for all third-level headings in your emails.
      @style heading 3
      */
        h3,.h3{
          /*@editable*/color:#202020;
          display:block;
          /*@editable*/font-family:Arial;
          /*@editable*/font-size:26px;
          /*@editable*/font-weight:bold;
          /*@editable*/line-height:100%;
          margin-top:0;
          margin-right:0;
          margin-bottom:10px;
          margin-left:0;
          /*@editable*/text-align:center;
        }
      /*
      @tab Page
      @section heading 4
      @tip Set the styling for all fourth-level headings in your emails. These should be the smallest of your headings.
      @style heading 4
      */
        h4,.h4{
          /*@editable*/color:#202020;
          display:block;
          /*@editable*/font-family:Arial;
          /*@editable*/font-size:13px;
          /*@editable*/font-weight:bold;
          /*@editable*/line-height:100%;
          margin-top:0;
          margin-right:0;
          margin-bottom:10px;
          margin-left:0;
          /*@editable*/text-align:center;
        }
      /*
      @tab Header
      @section preheader style
      @tip Set the background color for your email's preheader area.
      @theme page
      */
        #templatePreheader{
          /*@editable*/background-color:#FAFAFA;
        }
      /*
      @tab Header
      @section preheader text
      @tip Set the styling for your email's preheader text. Choose a size and color that is easy to read.
      */
        .preheaderContent div{
          /*@editable*/color:#505050;
          /*@editable*/font-family:Arial;
          /*@editable*/font-size:10px;
          /*@editable*/line-height:100%;
          /*@editable*/text-align:left;
        }
      /*
      @tab Header
      @section preheader link
      @tip Set the styling for your email's preheader links. Choose a color that helps them stand out from your text.
      */
        .preheaderContent div a:link,.preheaderContent div a:visited,.preheaderContent div a .yshortcuts {
          /*@editable*/color:#336699;
          /*@editable*/font-weight:normal;
          /*@editable*/text-decoration:underline;
        }
        .preheaderContent img{
          display:inline;
          height:auto;
          margin-bottom:10px;
          max-width:280px;
        }
      /*
      @tab Header
      @section header style
      @tip Set the background color and border for your email's header area.
      @theme header
      */
        #templateHeader{
          /*@editable*/background-color:#FFFFFF;
          /*@editable*/border-bottom:0;
        }
      /*
      @tab Header
      @section header text
      @tip Set the styling for your email's header text. Choose a size and color that is easy to read.
      */
        .headerContent{
          /*@editable*/color:#202020;
          /*@editable*/font-family:Arial;
          /*@editable*/font-size:34px;
          /*@editable*/font-weight:bold;
          /*@editable*/line-height:100%;
          /*@editable*/padding:0;
          /*@editable*/text-align:left;
          /*@editable*/vertical-align:middle;
          background-color: #FAFAFA;
            padding-bottom: 14px;
        }
      /*
      @tab Header
      @section header link
      @tip Set the styling for your email's header links. Choose a color that helps them stand out from your text.
      */
        .headerContent a:link,.headerContent a:visited,.headerContent a .yshortcuts {
          /*@editable*/color:#336699;
          /*@editable*/font-weight:normal;
          /*@editable*/text-decoration:underline;
        }
        #headerImage{
          height:auto;
          max-width:400px !important;
        }
      /*
      @tab Body
      @section body style
      @tip Set the background color for your email's body area.
      */
        #templateContainer,.bodyContent{
          /*@editable*/background-color:#FFFFFF;
        }
      /*
      @tab Body
      @section body text
      @tip Set the styling for your email's main content text. Choose a size and color that is easy to read.
      @theme main
      */
        .bodyContent div{
          /*@editable*/color:#505050;
          /*@editable*/font-family:Arial;
          /*@editable*/font-size:14px;
          /*@editable*/line-height:150%;
          /*@editable*/text-align:left;
        }
      /*
      @tab Body
      @section body link
      @tip Set the styling for your email's main content links. Choose a color that helps them stand out from your text.
      */
        .bodyContent div a:link,.bodyContent div a:visited,.bodyContent div a .yshortcuts {
          /*@editable*/color:#336699;
          /*@editable*/font-weight:normal;
          /*@editable*/text-decoration:underline;
        }
        .bodyContent img{
          display:inline;
          height:auto;
          margin-bottom:10px;
          max-width:280px;
        }
      /*
      @tab Footer
      @section footer style
      @tip Set the background color and top border for your email's footer area.
      @theme footer
      */
        #templateFooter{
          /*@editable*/background-color:#FFFFFF;
          /*@editable*/border-top:0;
        }
      /*
      @tab Footer
      @section footer text
      @tip Set the styling for your email's footer text. Choose a size and color that is easy to read.
      @theme footer
      */
        .footerContent {
          background-color: #fafafa;
        }
        .footerContent div{
          /*@editable*/color:#707070;
          /*@editable*/font-family:Arial;
          /*@editable*/font-size:11px;
          /*@editable*/line-height:150%;
          /*@editable*/text-align:left;
        }
      /*
      @tab Footer
      @section footer link
      @tip Set the styling for your email's footer links. Choose a color that helps them stand out from your text.
      */
        .footerContent div a:link,.footerContent div a:visited,.footerContent div a .yshortcuts {
          /*@editable*/color:#336699;
          /*@editable*/font-weight:normal;
          /*@editable*/text-decoration:underline;
        }
        .footerContent img{
          display:inline;
        }
      /*
      @tab Footer
      @section social bar style
      @tip Set the background color and border for your email's footer social bar.
      @theme footer
      */
        #social{
          /*@editable*/background-color:#FAFAFA;
          /*@editable*/border:0;
        }
      /*
      @tab Footer
      @section social bar style
      @tip Set the background color and border for your email's footer social bar.
      */
        #social div{
          /*@editable*/text-align:left;
        }
      /*
      @tab Footer
      @section utility bar style
      @tip Set the background color and border for your email's footer utility bar.
      @theme footer
      */
        #utility{
          /*@editable*/background-color:#FFFFFF;
          /*@editable*/border:0;
        }
      /*
      @tab Footer
      @section utility bar style
      @tip Set the background color and border for your email's footer utility bar.
      */
        #utility div{
          /*@editable*/text-align:left;
        }
        #monkeyRewards img{
          display:inline;
          height:auto;
          max-width:280px;
        }
      /*
      ATAVIST CUSTOM STYLES
       */
      .buttonText {
        color: #4A90E2;
        text-decoration: none;
        font-weight: normal;
        display: block;
        border: 2px solid #585858;
        padding: 10px 80px;
        font-family: Arial;
      }
      #supportSection, .supportContent {
        background-color: white;
        font-family: arial;
        font-size: 12px;
        border-top: 1px solid #e4e4e4;
      }
      .bodyContent table {
        padding-bottom: 10px;
      }
      .footerContent p {
        margin: 0;
        margin-top: 2px;
      }
      .headerContent.centeredWithBackground {
        background-color: #F4EEE2;
        text-align: center;
        padding-top: 20px;
        padding-bottom: 20px;
      }
       @media only screen and (min-device-width: 320px) and (max-device-width: 480px) {
              h1 {
                  font-size: 40px !important;
              }
              .content {
                  font-size: 22px !important;
              }
              .bodyContent p {
                  font-size: 22px !important;
              }
              .buttonText {
                  font-size: 22px !important;
              }
              p {
                  font-size: 16px !important;
              }
              .footerContent p {
                  padding-left: 5px !important;
              }
              .mainContainer {
                  padding-bottom: 0 !important;
              }
          }
          .button-25 {
            background-color: #36A9AE;
            background-image: linear-gradient(#37ADB2, #329CA0);
            border: 1px solid #2A8387;
            border-radius: 4px;
            box-shadow: rgba(0, 0, 0, 0.12) 0 1px 1px;
            color: #FFFFFF;
            cursor: pointer;
            display: block;
            font-family: -apple-system,".SFNSDisplay-Regular","Helvetica Neue",Helvetica,Arial,sans-serif;
            font-size: 17px;
            line-height: 100%;
            margin: 0;
            outline: 0;
            padding: 11px 15px 12px;
            text-align: center;
            transition: box-shadow .05s ease-in-out,opacity .05s ease-in-out;
            user-select: none;
            -webkit-user-select: none;
            touch-action: manipulation;
            width: 100%;
          }
          .button-25:hover {
            box-shadow: rgba(255, 255, 255, 0.3) 0 0 2px inset, rgba(0, 0, 0, 0.4) 0 1px 2px;
            text-decoration: none;
            transition-duration: .15s, .15s;
          }
          .button-25:active {
            box-shadow: rgba(0, 0, 0, 0.15) 0 2px 4px inset, rgba(0, 0, 0, 0.4) 0 1px 1px;
          }
          .button-25:disabled {
            cursor: not-allowed;
            opacity: .6;
          }
          .button-25:disabled:active {
            pointer-events: none;
          }
          .button-25:disabled:hover {
            box-shadow: none;
          }
    </style>
  </head>
  <body leftmargin="0" marginwidth="0" topmargin="0" marginheight="0" offset="0" style="width:100% ;-webkit-text-size-adjust:none;margin:0;padding:0;background-color:#FAFAFA;">
    <center>
      <table border="0" cellpadding="0" cellspacing="0" height="100%" width="100%" id="backgroundTable" style="height:100% ;margin:0;padding:0;width:100% ;background-color:#FAFAFA;">
        <tr>
          <td align="center" valign="top" style="border-collapse:collapse;">
            <!-- // Begin Template Preheader \\ -->
            <table border="0" cellpadding="10" cellspacing="0" width="450" id="templatePreheader" style="background-color:#FAFAFA;">
              <tr>
                <td valign="top" class="preheaderContent" style="border-collapse:collapse;">
                  <!-- // Begin Module: Standard Preheader \\ -->
                  <table border="0" cellpadding="10" cellspacing="0" width="100%">
                    <tr>
                      <td valign="top" style="border-collapse:collapse;">
                        <!-- <div mc:edit="std_preheader_content">
                           Use this area to offer a short teaser of your email's content. Text here will show in the preview area of some email clients.
                          </div>
                                                    -->
                      </td>
                    </tr>
                  </table>
                  <!-- // End Module: Standard Preheader \\ -->
                </td>
              </tr>
            </table>
                  <!-- // Begin Template Header \\ -->
                  <table border="0" cellpadding="0" cellspacing="0" width="450" id="templateHeader" style="background-color:#FFFFFF;border-bottom:0;">
                    <tr>
            <!-- // End Template Preheader \\ -->
            <table border="0" cellpadding="0" cellspacing="0" width="450" id="templateContainer" style="border:1px none #DDDDDD;background-color:#FFFFFF;">
              <tr>
                <td align="center" valign="top" style="border-collapse:collapse;">
                      <td class="headerContent centeredWithBackground" style="border-collapse:collapse;color:#202020;font-family:Arial;font-size:34px;font-weight:bold;line-height:100%;padding:0;text-align:center;vertical-align:middle;background-color:#F4EEE8;padding-bottom:20px;padding-top:20px;">
                        <!-- // Begin Module: Standard Header Image \\ -->
                        <img width="130" src="cid:logo.ee" id="headerImage campaign-icon">
                        <!-- // End Module: Standard Header Image \\ -->
                    </tr>
                  </table>
                  <!-- // End Template Header \\ -->
                </td>
              </tr>
              <tr>
                <td align="center" valign="top" style="border-collapse:collapse;">
                  <!-- // Begin Template Body \\ -->
                  <table border="1" cellpadding="0" cellspacing="0" width="450" id="templateBody">
                    <tr>
                      <td valign="top" class="bodyContent" style="border-collapse:collapse;background-color:#F3F4ED;">
                        <!-- // Begin Module: Standard Content \\ -->
                        <table border="0" cellpadding="12" cellspacing="0" width="100%" style="padding-bottom:10px;">
                          <tr>
                            <td valign="top" style="padding-bottom:1rem;border-collapse:collapse;" class="mainContainer">
                              <div style="text-align:center;color:#FF96AD;font-family:Arial;font-size:14px;line-height:150%;">
                              <br>
                                <br>
                                <h1 class="h1" style="color:#114E60;display:block;font-family:Arial;font-size:24px;font-weight:bold;line-height:100%;margin-top:20px;margin-right:0;margin-bottom:20px;margin-left:0;text-align:left;">Hello ${fname} ,</h1>
                              </div>
                            </td>
                          </tr>
                          <tr>
                            <td align="left" style="border-collapse:collapse;">
                              <table border="0" cellpadding="0" cellspacing="0" style="padding-bottom:10px;">
                                <tbody>
                                  <tr align="center">
                                    <td align="left" valign="middle" style="border-collapse:collapse;">
                                      <p class="buttonText" href="#" target="_blank" style="color: #325288;text-decoration: none;font-weight: normal;display: all ;border: 0px solid #022E57;padding: 10px 6px;font-size:15px;font-family: TimeNewroman;">Thank you for using our application you can verify your account by clicking on the link bellow</p>
                                      <p class="buttonText" href="#" target="_blank" style="color: #325288;text-decoration: none;font-weight: normal;display: all ;border: 0px solid #022E57;padding: 10px 60px;font-size:10px;font-family: TimeNewroman;"><a href="${val}" class="button-25" >Confirm mail</a></p>
                                      <p class="h1" style="color:#114E60;font-family:TimeNewroman;font-size:20px;font-weight:bold;text-align:right;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Thank you!</>
                                    </td>
                                  </tr>
                                </tbody>
                              </table>
                            </td>
                          </tr>
                        </table>
                        <!-- // End Module: Standard Content \\ -->
                      </td>
                    </tr>
                  </table>
                  <!-- // End Template Body \\ -->
                </td>
              </tr>
              <tr>
                <td align="center" valign="top" style="border-collapse:collapse;">
                  <!-- // Begin Support Section \\ -->
                  <table border="0" cellpadding="10" cellspacing="0" width="450" id="supportSection"  style="background-color:black;font-family:arial;font-size:12px;border-top:1px solid #e4e4e4;">
                    <tr>
                      <td valign="top" class="supportContent" style="border-collapse:collapse;background-color:#F4EEE8;font-family:arial;font-size:12px;border-top:1px solid #e4e4e4;">
                        <!-- // Begin Module: Standard Footer \\ -->
                        <table border="0" cellpadding="10" cellspacing="0" width="100%">
                          <tr>
                            <td valign="top" width="100%" style="border-collapse:collapse;">
                              <br>
                              <div style="text-align: center; color: #02475E;">
                                <p>Questions? Get your answers here:&nbsp;
                                showapp.application@gmail.com.</p>
                              </div>
                              <br>
                            </td>
                          </tr>
                        </table>
                        <!-- // End Module: Standard Footer \\ -->
                      </td>
                    </tr>
                  </table>
                  <!-- // Begin Support Section \\ -->
                </td>
              </tr>
              <tr>
                <td align="center" valign="top" style="border-collapse:collapse;">
                  <!-- // Begin Template Footer \\ -->
                  <table border="0" cellpadding="10" cellspacing="0" width="450" id="templateFooter" style="background-color:#FFFFFF;border-top:0;">
                    <tr>
                      <td valign="top" class="footerContent" style="padding-left:0;border-collapse:collapse;background-color:#fafafa;">
                        <div style="text-align:center;color:#02475E;font-family:Arial;font-size:11px;line-height:150%;">
                          <p style="text-align:right;margin:0;margin-top:2px;">showapp                      | Copyright © 2021 | All rights reserved</p>
                        </div>
                        <!-- // End Module: Standard Footer \\ -->
                      </td>
                    </tr>
                  </table>
                  <!-- // End Template Footer \\ -->
                </td>
              </tr>
            </table>
            <br>
          </td>
        </tr>
      </table>
    </center>
  </body>
  </html>
`
}

function templateReset(val) {
    return `
<!DOCTYPE html >
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<!-- Facebook sharing information tags -->
<meta property="og:title" content="Reset Your Password">
<title>Reset Your password</title>
<style type="text/css">
  #outlook a{
      padding:0;
    }
    body{
      width:100% !important;
    }
    .ReadMsgBody{
      width:100%;
    }
    .ExternalClass{
      width:100%;
    }
    body{
      -webkit-text-size-adjust:none;
    }
    body{
      margin:0;
      padding:0;
    }
    img{
      border:0;
      height:auto;
      line-height:100%;
      outline:none;
      text-decoration:none;
    }
    table td{
      border-collapse:collapse;
    }
    #backgroundTable{
      height:100% !important;
      margin:0;
      padding:0;
      width:100% !important;
    }
  /*
  @tab Page
  @section background color
  @tip Set the background color for your email. You may want to choose one that matches your company's branding.
  @theme page
  */
    body,#backgroundTable{
      /*@editable*/background-color:#FAFAFA;
    }
  /*
  @tab Page
  @section email border
  @tip Set the border for your email.
  */
    #templateContainer{
      /*@editable*/border:1px none #DDDDDD;
    }
  /*
  @tab Page
  @section heading 1
  @tip Set the styling for all first-level headings in your emails. These should be the largest of your headings.
  @style heading 1
  */
    h1,.h1{
      /*@editable*/color:#202020;
      display:block;
      /*@editable*/font-family:Arial;
      /*@editable*/font-size:24px;
      /*@editable*/font-weight:bold;
      /*@editable*/line-height:100%;
      margin-top:20px;
      margin-right:0;
      margin-bottom:20px;
      margin-left:0;
      /*@editable*/text-align:center;
    }
  /*
  @tab Page
  @section heading 2
  @tip Set the styling for all second-level headings in your emails.
  @style heading 2
  */
    h2,.h2{
      /*@editable*/color:#202020;
      display:block;
      /*@editable*/font-family:Arial;
      /*@editable*/font-size:30px;
      /*@editable*/font-weight:bold;
      /*@editable*/line-height:100%;
      margin-top:0;
      margin-right:0;
      margin-bottom:10px;
      margin-left:0;
      /*@editable*/text-align:center;
    }
  /*
  @tab Page
  @section heading 3
  @tip Set the styling for all third-level headings in your emails.
  @style heading 3
  */
    h3,.h3{
      /*@editable*/color:#202020;
      display:block;
      /*@editable*/font-family:Arial;
      /*@editable*/font-size:26px;
      /*@editable*/font-weight:bold;
      /*@editable*/line-height:100%;
      margin-top:0;
      margin-right:0;
      margin-bottom:10px;
      margin-left:0;
      /*@editable*/text-align:center;
    }
  /*
  @tab Page
  @section heading 4
  @tip Set the styling for all fourth-level headings in your emails. These should be the smallest of your headings.
  @style heading 4
  */
    h4,.h4{
      /*@editable*/color:#202020;
      display:block;
      /*@editable*/font-family:Arial;
      /*@editable*/font-size:22px;
      /*@editable*/font-weight:bold;
      /*@editable*/line-height:100%;
      margin-top:0;
      margin-right:0;
      margin-bottom:10px;
      margin-left:0;
      /*@editable*/text-align:center;
    }
  /*
  @tab Header
  @section preheader style
  @tip Set the background color for your email's preheader area.
  @theme page
  */
    #templatePreheader{
      /*@editable*/background-color:#FAFAFA;
    }
  /*
  @tab Header
  @section preheader text
  @tip Set the styling for your email's preheader text. Choose a size and color that is easy to read.
  */
    .preheaderContent div{
      /*@editable*/color:#505050;
      /*@editable*/font-family:Arial;
      /*@editable*/font-size:10px;
      /*@editable*/line-height:100%;
      /*@editable*/text-align:left;
    }
  /*
  @tab Header
  @section preheader link
  @tip Set the styling for your email's preheader links. Choose a color that helps them stand out from your text.
  */
    .preheaderContent div a:link,.preheaderContent div a:visited,.preheaderContent div a .yshortcuts {
      /*@editable*/color:#336699;
      /*@editable*/font-weight:normal;
      /*@editable*/text-decoration:underline;
    }
    .preheaderContent img{
      display:inline;
      height:auto;
      margin-bottom:10px;
      max-width:280px;
    }
  /*
  @tab Header
  @section header style
  @tip Set the background color and border for your email's header area.
  @theme header
  */
    #templateHeader{
      /*@editable*/background-color:#FFFFFF;
      /*@editable*/border-bottom:0;
    }
  /*
  @tab Header
  @section header text
  @tip Set the styling for your email's header text. Choose a size and color that is easy to read.
  */
    .headerContent{
      /*@editable*/color:#202020;
      /*@editable*/font-family:Arial;
      /*@editable*/font-size:34px;
      /*@editable*/font-weight:bold;
      /*@editable*/line-height:100%;
      /*@editable*/padding:0;
      /*@editable*/text-align:left;
      /*@editable*/vertical-align:middle;
      background-color: #FAFAFA;
        padding-bottom: 14px;
    }
  /*
  @tab Header
  @section header link
  @tip Set the styling for your email's header links. Choose a color that helps them stand out from your text.
  */
    .headerContent a:link,.headerContent a:visited,.headerContent a .yshortcuts {
      /*@editable*/color:#336699;
      /*@editable*/font-weight:normal;
      /*@editable*/text-decoration:underline;
    }
    #headerImage{
      height:auto;
      max-width:400px !important;
    }
  /*
  @tab Body
  @section body style
  @tip Set the background color for your email's body area.
  */
    #templateContainer,.bodyContent{
      /*@editable*/background-color:#FFFFFF;
    }
  /*
  @tab Body
  @section body text
  @tip Set the styling for your email's main content text. Choose a size and color that is easy to read.
  @theme main
  */
    .bodyContent div{
      /*@editable*/color:#505050;
      /*@editable*/font-family:Arial;
      /*@editable*/font-size:14px;
      /*@editable*/line-height:150%;
      /*@editable*/text-align:left;
    }
  /*
  @tab Body
  @section body link
  @tip Set the styling for your email's main content links. Choose a color that helps them stand out from your text.
  */
    .bodyContent div a:link,.bodyContent div a:visited,.bodyContent div a .yshortcuts {
      /*@editable*/color:#336699;
      /*@editable*/font-weight:normal;
      /*@editable*/text-decoration:underline;
    }
    .bodyContent img{
      display:inline;
      height:auto;
      margin-bottom:10px;
      max-width:280px;
    }
  /*
  @tab Footer
  @section footer style
  @tip Set the background color and top border for your email's footer area.
  @theme footer
  */
    #templateFooter{
      /*@editable*/background-color:#FFFFFF;
      /*@editable*/border-top:0;
    }
  /*
  @tab Footer
  @section footer text
  @tip Set the styling for your email's footer text. Choose a size and color that is easy to read.
  @theme footer
  */
    .footerContent {
      background-color: #fafafa;
    }
    .footerContent div{
      /*@editable*/color:#707070;
      /*@editable*/font-family:Arial;
      /*@editable*/font-size:11px;
      /*@editable*/line-height:150%;
      /*@editable*/text-align:left;
    }
  /*
  @tab Footer
  @section footer link
  @tip Set the styling for your email's footer links. Choose a color that helps them stand out from your text.
  */
    .footerContent div a:link,.footerContent div a:visited,.footerContent div a .yshortcuts {
      /*@editable*/color:#336699;
      /*@editable*/font-weight:normal;
      /*@editable*/text-decoration:underline;
    }
    .footerContent img{
      display:inline;
    }
  /*
  @tab Footer
  @section social bar style
  @tip Set the background color and border for your email's footer social bar.
  @theme footer
  */
    #social{
      /*@editable*/background-color:#FAFAFA;
      /*@editable*/border:0;
    }
  /*
  @tab Footer
  @section social bar style
  @tip Set the background color and border for your email's footer social bar.
  */
    #social div{
      /*@editable*/text-align:left;
    }
  /*
  @tab Footer
  @section utility bar style
  @tip Set the background color and border for your email's footer utility bar.
  @theme footer
  */
    #utility{
      /*@editable*/background-color:#FFFFFF;
      /*@editable*/border:0;
    }
  /*
  @tab Footer
  @section utility bar style
  @tip Set the background color and border for your email's footer utility bar.
  */
    #utility div{
      /*@editable*/text-align:left;
    }
    #monkeyRewards img{
      display:inline;
      height:auto;
      max-width:280px;
    }
  /*
  ATAVIST CUSTOM STYLES 
   */
  .buttonText {
    color: #4A90E2;
    text-decoration: none;
    font-weight: normal;
    display: block;
    border: 2px solid #585858;
    padding: 10px 80px;
    font-family: Arial;
  }
  #supportSection, .supportContent {
    background-color: white;
    font-family: arial;
    font-size: 12px;
    border-top: 1px solid #e4e4e4;
  }
  .bodyContent table {
    padding-bottom: 10px;
  }
  .footerContent p {
    margin: 0;
    margin-top: 2px;
  }
  .headerContent.centeredWithBackground {
    background-color: #F4EEE2;
    text-align: center;
    padding-top: 20px;
    padding-bottom: 20px;
  }
   @media only screen and (min-device-width: 320px) and (max-device-width: 480px) {
          h1 {
              font-size: 40px !important;
          }
          .content {
              font-size: 22px !important;
          }
          .bodyContent p {
              font-size: 22px !important;
          }
          .buttonText {
              font-size: 22px !important;
          }
          p {
              font-size: 16px !important;
          }
          .footerContent p {
              padding-left: 5px !important;
          }
          .mainContainer {
              padding-bottom: 0 !important;   
          }
      }
</style>
</head>
<body leftmargin="0" marginwidth="0" topmargin="0" marginheight="0" offset="0" style="width:100% ;-webkit-text-size-adjust:none;margin:0;padding:0;background-color:#FAFAFA;">
<center>
  <table border="0" cellpadding="0" cellspacing="0" height="100%" width="100%" id="backgroundTable" style="height:100% ;margin:0;padding:0;width:100% ;background-color:#FAFAFA;">
    <tr>
      <td align="center" valign="top" style="border-collapse:collapse;">
        <!-- // Begin Template Preheader \\ -->
        <table border="0" cellpadding="10" cellspacing="0" width="450" id="templatePreheader" style="background-color:#FAFAFA;">
          <tr>
            <td valign="top" class="preheaderContent" style="border-collapse:collapse;">
              <!-- // Begin Module: Standard Preheader \\ -->
              <table border="0" cellpadding="10" cellspacing="0" width="100%">
                <tr>
                  <td valign="top" style="border-collapse:collapse;">
                    <!-- <div mc:edit="std_preheader_content">
                                                   Use this area to offer a short teaser of your email's content. Text here will show in the preview area of some email clients.
                                                </div>
                                                -->
                  </td>
                </tr>
              </table>
              <!-- // End Module: Standard Preheader \\ -->
            </td>
          </tr>
        </table>
        <!-- // End Template Preheader \\ -->
        <table border="0" cellpadding="0" cellspacing="0" width="450" id="templateContainer" style="border:1px none #DDDDDD;background-color:#FFFFFF;">
          <tr>
            <td align="center" valign="top" style="border-collapse:collapse;">
              <!-- // Begin Template Header \\ -->
              <table border="0" cellpadding="0" cellspacing="0" width="450" id="templateHeader" style="background-color:#FFFFFF;border-bottom:0;">
                <tr>
                  <td class="headerContent centeredWithBackground" style="border-collapse:collapse;color:#202020;font-family:Arial;font-size:34px;font-weight:bold;line-height:100%;padding:0;text-align:center;vertical-align:middle;background-color:#F4EEE2;padding-bottom:20px;padding-top:20px;">
                    <!-- // Begin Module: Standard Header Image \\ -->
                    <img width="130" src="cid:logo.ee" id="headerImage campaign-icon">
                    <!-- // End Module: Standard Header Image \\ -->
                </tr>
              </table>
              <!-- // End Template Header \\ -->
            </td>
          </tr>
          <tr>
            <td align="center" valign="top" style="border-collapse:collapse;">
              <!-- // Begin Template Body \\ -->
              <table border="0" cellpadding="0" cellspacing="0" width="450" id="templateBody">
                <tr>
                  <td valign="top" class="bodyContent" style="border-collapse:collapse;background-color:#FFFFFF;">
                    <!-- // Begin Module: Standard Content \\ -->
                    <table border="0" cellpadding="12" cellspacing="0" width="100%" style="padding-bottom:10px;">
                      <tr>
                        <td valign="top" style="padding-bottom:1rem;border-collapse:collapse;" class="mainContainer">
                          <div style="text-align:center;color:#505050;font-family:Arial;font-size:14px;line-height:150%;">
                            <h1 class="h1" style="color:#202020;display:block;font-family:Arial;font-size:24px;font-weight:bold;line-height:100%;margin-top:20px;margin-right:0;margin-bottom:20px;margin-left:0;text-align:center;">Reset Your Password</h1>
                            <p>Reset code : </p>
                          </div>
                        </td>
                      </tr>
                      <tr>
                        <td align="center" style="border-collapse:collapse;">
                          <table border="0" cellpadding="0" cellspacing="0" style="padding-bottom:10px;">
                            <tbody>
                              <tr align="center">
                                <td align="center" valign="middle" style="border-collapse:collapse;">
                                  <p class="buttonText" href="#" target="_blank" style="color: #4A90E2;text-decoration: none;font-weight: normal;display: block;border: 2px solid #585858;padding: 10px 60px;font-family: Arial;">${val}</p>
                                </td>
                              </tr>
                            </tbody>
                          </table>
                        </td>
                      </tr>
                    </table>
                    <!-- // End Module: Standard Content \\ -->
                  </td>
                </tr>
              </table>
              <!-- // End Template Body \\ -->
            </td>
          </tr>
          <tr>
            <td align="center" valign="top" style="border-collapse:collapse;">
              <!-- // Begin Support Section \\ -->
              <table border="0" cellpadding="10" cellspacing="0" width="450" id="supportSection" style="background-color:white;font-family:arial;font-size:12px;border-top:1px solid #e4e4e4;">
                <tr>
                  <td valign="top" class="supportContent" style="border-collapse:collapse;background-color:white;font-family:arial;font-size:12px;border-top:1px solid #e4e4e4;">
                    <!-- // Begin Module: Standard Footer \\ -->
                    <table border="0" cellpadding="10" cellspacing="0" width="100%">
                      <tr>
                        <td valign="top" width="100%" style="border-collapse:collapse;">
                          <br>
                          <div style="text-align: center; color: #c9c9c9;">
                            <p>Questions? Get your answers here:&nbsp;
                            showapp.application@gmail.com .</p>
                          </div>
                          <br>
                        </td>
                      </tr>
                    </table>
                    <!-- // End Module: Standard Footer \\ -->
                  </td>
                </tr>
              </table>
              <!-- // Begin Support Section \\ -->
            </td>
          </tr>
          <tr>
            <td align="center" valign="top" style="border-collapse:collapse;">
              <!-- // Begin Template Footer \\ -->
              <table border="0" cellpadding="10" cellspacing="0" width="450" id="templateFooter" style="background-color:#FFFFFF;border-top:0;">
                <tr>
                  <td valign="top" class="footerContent" style="padding-left:0;border-collapse:collapse;background-color:#fafafa;">
                    <div style="text-align:center;color:#c9c9c9;font-family:Arial;font-size:11px;line-height:150%;">
                      <p style="text-align:left;margin:0;margin-top:2px;">Showapp application                 Copyright © 2021 | All rights reserved</p>
                    </div>
                    <!-- // End Module: Standard Footer \\ -->
                  </td>
                </tr>
              </table>
              <!-- // End Template Footer \\ -->
            </td>
          </tr>
        </table>
        <br>
      </td>
    </tr>
  </table>
</center>
</body>
</html>
`
}
const Car = require('../Models/car');
const cloudinary = require('../middleware/cloudinary');
const fs = require('fs');
const { log } = require('console');
const fsPromises = require('fs').promises
    //create
exports.addNewCar = async(req, res, next) => {
    const photoCloudinary = await cloudinary.uploader.upload(req.file.path)
    const car = new Car({
        user: req.body.user,
        brand: req.body.brand,
        price: req.body.price,
        position: req.body.position,
        Criteria: req.body.Criteria,
        Description: req.body.Description,
        Model: req.body.Model,
        availablity: req.body.availablity,
        locationDatefrom: req.body.locationDatefrom,
        locationDateto: req.body.locationDateto,
        image: photoCloudinary.url
    });
    await car.save()
        .then(() => res.status(201).json({ message: 'car saved !' }))
        .catch(error => res.status(400).json({ message: 'car not saved error 400 check id company!', error }));
}
exports.getCars = (req, res, next) => {
    Car.find()
        .then(car => res.status(200).json({ Car: car }))
        .catch(error => res.status(400).json({ error }));
}
async function uploadToCloudinary(locaFilePath) {
    // locaFilePath :
    // path of image which was just uploaded to images folder
    var mainFolderName = "images"
        // filePathOnCloudinary :
        // path of image we want when it is uploded to cloudinary
    var filePathOnCloudinary = mainFolderName + "/" + locaFilePath
    return cloudinary.uploader.upload(locaFilePath, { "public_id": filePathOnCloudinary })
        .then((result) => {
            // Image has been successfully uploaded on cloudinary
            // So we dont need local image file anymore
            // Remove file from local uploads folder 
            fs.unlinkSync(locaFilePath)
            return {
                message: "Success",
                url: result.url
            };
        }).catch((error) => {
            // Remove file from local uploads folder 
            fs.unlinkSync(locaFilePath)
            return { message: "Fail", };
        });
}
exports.getCarbyidDetails = (req, res, next) => {
    Car.findOne({ _id: req.params.id }).populate('user')
        .then(Car => res.status(200).json(Car))
        .catch(error => res.status(404).json({ message: "user not found Check id " }));
}
exports.getCarbyid = (req, res, next) => {
    Car.findOne({ _id: req.params.id })
        .then(Car => res.status(200).json(Car))
        .catch(error => res.status(404).json({ message: "user not found Check id " }));
}
exports.getCarsbyName = (req, res, next) => {
    Car.find({ Model: { $regex: req.body.Model } })
        .then(car => res.status(200).json({ Car: car }))
        .catch(error => res.status(500).json({ error }));
}
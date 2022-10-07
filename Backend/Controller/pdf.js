const FilePdf = require("../Models/pdf");
const cloudinary = require('../middleware/cloudinary');

exports.addNewRate = async(req, res, next) => {
    const photoCloudinary = await cloudinary.uploader.upload(req.file.path)
    const filePdf = new FilePdf({
        user: req.body.user,
        car: req.body.car,
        pdffile: photoCloudinary.url,
    });
    console.log(filePdf);
    await filePdf.save()
        .then(() => res.status(201).json({ message: 'rate saved !' }))
        .catch(error => res.status(500).json({ message: 'rate not saved error 400 check id company!', error }));
}
exports.getFifebyidUser = (req, res, next) => {
    FilePdf.find({ user: req.params.user })
        .then(files => res.status(200).json(files))
        .catch(error => res.status(404).json({ message: "user not found Check id " }));
}
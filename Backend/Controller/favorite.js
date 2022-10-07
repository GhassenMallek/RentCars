const Favorite = require('../Models/favorite');

exports.add = async (req, res, next) => {

    const array = await Favorite.find()
    const array1 = []
    const BreakError = {};
    try {
        array.forEach(element => {
            if (element.car) {
                array1.push(element.car)
                if (req.body.car == element.car) {
                    throw BreakError;
                }
            }
            
        });
    } catch (err) {
        if (err == BreakError) {
            return res.status(409).json({
                message: 'fav already added !',
            })
        }
    }



    const favorites = new Favorite({
        ...req.body
    });
    await favorites.save()
        .then(() => res.status(201).json({ message: 'saved !' }))
        .catch(error => res.status(400).json({ error }));
}
exports.getAllByuser = (req, res, next) => {
    Favorite.find({ user: req.body.user }).populate('car')
        .then(favorite => res.status(200).json({ favorites: favorite }))
        .catch(error => res.status(400).json({ error }));
}
exports.delete = (req, res, next) => {
    Favorite.deleteOne({ car: req.body.car })
        .then(() => res.status(200).json({ message: 'fav deleted !' }))
        .catch(error => res.status(400).json({ message: "Check id" }));
}
exports.getAllUser = (req, res, next) => {
    Favorite.find()
        .then(fav => res.status(200).json({ favs: fav }))
        .catch(error => res.status(400).json({ error }));
}
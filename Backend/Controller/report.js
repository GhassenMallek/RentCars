const Report = require('../Models/report');
const User = require('../Models/user');

exports.add = async(req, res, next) => {
    const commande = new Commande({
       ...req.body
    });
    await commande.save()
        .then(() => res.status(201).json({ message: 'saved !' }))
        .catch(error => res.status(400).json({ error }));
}
exports.getAll = (req, res, next) => {
    News.find()
        .then(news => res.status(200).json({ news : news }))
        .catch(error => res.status(400).json({ error }));
}
exports.updateProfile = async (req, res) =>{
    const { email,bannned, } = req.body
  
  let user = await User.findOneAndUpdate(
    { email: email },
    {
      $set: {
        bannned
       
      },
    }
  )
  
  return res.send({ message: "Profile updated successfully"})
  }
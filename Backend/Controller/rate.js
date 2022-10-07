const Rate = require('../Models/rate');
exports.addNewRate = async(req, res, next) => {
    const rate = new Rate({
        user: req.body.user,
        rate: req.body.rate,
    });
    await rate.save()
        .then(() => res.status(201).json({ message: 'rate saved !' }))
        .catch(error => res.status(400).json({ message: 'rate not saved error 400 check id company!', error }));
}
exports.getRates = async(req, res, next) => {
    console.log(req.params.id);

    var moyrate = []
    var user = []
    moyrate = await Rate.find({ User: req.params.user })



    var x;
    var ratef = 0;
    const ratetab = [];
    moyrate.forEach(element => {
        ratetab.push(element.rate)
    })
    somme = 0;
    for (i = 0; i < ratetab.length; i++)
        somme = somme + ratetab[i];


    ratef = (somme / ratetab.length);

    console.log(somme);
    res.status(200).json(ratef)

}
exports.getAllUser = (req, res, next) => {
    Rate.find()
        .then(user => res.status(200).json({ users: user }))
        .catch(error => res.status(400).json({ error }));
}
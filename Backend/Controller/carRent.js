const Car = require('../Models/carRent');
exports.addNewCar = async(req, res) => {



    const start = new Date(req.body.locationDatefrom);
    start.setDate(start.getDate() + 1);

    const end = new Date(req.body.locationDateto);
    end.setDate(end.getDate() + 1);





    console.log(start);
    console.log(end);
    const car = new Car({
        owner: req.body.owner,
        tenant: req.body.tenant,
        car: req.body.car,
        price: req.body.price,
        locationDateto: end,
        locationDatefrom: start,

    });
    await car.save()
        .then(() => res.status(201).json({ message: 'car rented successfully' }))
        .catch(error => res.status(400).json({ message: 'car not saved error 400 check id company!', error }));
}
exports.getDetailsRentedCarbyid = (req, res, next) => {
    Car.find({ _id: req.params.id }).populate('tenant').populate('car')
        .then(Cars => res.status(200).json({ Cars }))
        .catch(error => res.status(404).json({ message: "car not found Check id " }));
}

exports.getAllCars = (res) => {
    Car.find()
        .then(car => res.status(200).json({ Car: car }))
        .catch(error => res.status(400).json({ error }));
}
exports.getCarbyid = async(req, res) => {

    const array = await Car.find({ car: req.params.car })

    from = []
    to = []
    array.forEach(element => {
        from.push(element.locationDatefrom)
        to.push(element.locationDateto)
    })
    date = new Date();
    days = [];
    console.log(from);
    console.log(to);
    for (i = 0; i < from.length; i++) {
        d = new Date(from[i]);
        days.push(d);
        do {

            end = new Date(to[i]);
            date = d.addDays(1);
            days.push(date);
            console.log("newdate :" + date);
            console.log("test : " + date == new Date(to[i]));
            d = date;
        }
        while (date < end);
    }
    console.log(days);
    res.status(200).json(Object.assign({}, days))

}
exports.getCarbyidOwner = async(req, res) => {
    Car.find({ owner: req.params.ownerID }).populate('tenant').populate('car')
        .then(car => res.status(200).json({ Cars: car }))
        .catch(error => res.status(400).json({ error }));
}



Date.prototype.addDays = function(days) {
    var date = new Date(this.valueOf());
    date.setDate(date.getDate() + days);
    return date;
}
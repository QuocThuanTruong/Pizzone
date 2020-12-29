const formidable = require('formidable');
const fs = require('fs')
const path = require('path');
const rimraf = require('rimraf')

const cloudinary = require('cloudinary').v2;

cloudinary.config({
    cloud_name: process.env.CLOUD_NAME,
    api_key: process.env.API_KEY,
    api_secret: process.env.API_SECRET
});

const userModel = require('./model')

exports.index = (req, res, next) => {
    const dataContext = {
        cart: req.user ? req.user.cart : global.cart,
        isLogin: req.user ? true : false,
        user: req.user
    }

    res.render('../components/user/views/editProfile', dataContext);
}

exports.edit = async (req, res, next) => {
    const dataContext = {
        cart: req.user ? req.user.cart : global.cart,
        isLogin: req.user ? true : false,
        user: req.user
    }

    res.render('../components/user/views/editProfile', dataContext);
}

exports.editInfo = async (req, res, next) => {
    fs.mkdirSync(path.join(__dirname, '..', 'tempImages'), { recursive: true })
    const form = formidable({multiples: true, keepExtensions: true, uploadDir : path.join(__dirname, '..', 'tempImages')})

    let oldUser = req.user

    await form.parse(req, async (err, fields, files) => {
        if (err) {
            return
        }

        let newUser = userModel.modify(fields, req.params.id)
        newUser.user_id = oldUser.user_id;

        const avatarPicker = files.avatarPicker
        if (avatarPicker) {
            if (avatarPicker.name) {
                await cloudinary.uploader.upload(avatarPicker.path,
                    {
                        folder: 'WebFinalProject/Images/user/'+newUser.user_id,
                        public_id: 'avatar',
                        overwrite: true
                    }, (err, res) => {
                        newUser.avatar = res.secure_url
                    })
            }
            else {
                newUser.avatar = ""
            }
        } else {
            newUser.avatar = oldUser.avatar
        }

        rimraf.sync(path.join(__dirname, '..', 'tempImages'))

        console.log(newUser)

        const _ = await userModel.update(newUser)
        const user = await userModel.getUserById(newUser.user_id)

        req.login(user, {}, function(err) {
            if (err) {
                console.log(err)
            }

            const dataContext = {
                cart: req.user ? req.user.cart : global.cart,
                isLogin: req.user ? true : false,
                user: req.user
            }

            res.render('../components/user/views/editProfile', dataContext);
        })
    })
}

exports.chagePassword = (req, res, next) => {
    const dataContext = {
        cart: req.user ? req.user.cart : global.cart,
        isLogin: req.user ? true : false,
        user: req.user
    }

    res.render('../components/user/views/changePassword', dataContext);
}

exports.orders = (req, res, next) => {
    const dataContext = {
        cart: req.user ? req.user.cart : global.cart,
        isLogin: req.user ? true : false,
        user: req.user
    }

    res.render('../components/user/views/orders', dataContext);
}


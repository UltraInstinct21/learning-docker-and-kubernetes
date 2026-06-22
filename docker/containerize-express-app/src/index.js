const bodyParser = require('body-parser')
const express = require('express')

const app = express()

const port = process.env.PORT

const users = []

app.use(bodyParser.json())


app.get('/', (req,res) => {
    res.send(`Hello World from ${process.env.APP_ENV}`)
})


//register
app.post('/users', (req,res) => {
    const newUserId = req.body.userId
    if (!newUserId) {
        return res.status(400).send("Missing userId")
    }


    if (users.includes(newUserId)) {
        return res.status(400).send("User already registered")
    }


    users.push(newUserId)

    return res.status(201).send("User created")

})


app.get('/users', (req, res) => {
    return res.json({users})
})


//get users

app.listen(port, () => {
    console.log(`Server listening on port ${port}`)
})
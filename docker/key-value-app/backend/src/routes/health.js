const express = require("express");

const HealthRouter = express.Router();

HealthRouter.get("/", (req, res) => {
    res.status(200).send("Status:Healthy :)");
})

module.exports = {HealthRouter};
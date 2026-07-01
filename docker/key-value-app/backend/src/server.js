const express = require("express");
const mongoose = require("mongoose");
const bodyParser = require("body-parser");
const cors = require("cors");
const dotenv = require("dotenv");

const {HealthRouter} = require("./routes/health");
const {router} = require("./routes/store");

dotenv.config();

const app = express();
app.use(bodyParser.json());
app.use(cors());

app.use("/health", HealthRouter);
app.use("/store", router);

const PORT = process.env.PORT || 3000;

const MONGODB_PORT = process.env.MONGODB_PORT || 27017;

mongoose.connect(`mongodb://${process.env.KEY_VALUE_USER}:${process.env.KEY_VALUE_PASSWORD}@${process.env.MONGODB_HOST}:${MONGODB_PORT}/${process.env.KEY_VALUE_DB}`).then(() => {
    console.log("Connected to MongoDB");
    app.listen(PORT, () => {
        console.log(`Server is running on port ${PORT}`);
    });
})
    .catch((err) => {
        console.log("Error connecting to MongoDB", err);
    });



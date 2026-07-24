const express = require("express");

const app = express();

app.get("/", (req, res) => {
    res.send('<h1 style="color:red">Red</h1>');
});

app.listen(80, () => {
    console.log("Server started on port 80");
});
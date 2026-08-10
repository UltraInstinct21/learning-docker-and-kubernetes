const express = require("express");
const mongoose = require("mongoose");
const app = express();



app.get ('/', (req,res) =>{
    res.send('Hello Notebook!')
})



app.listen(process.env.PORT, () => {
    console.log(`Server is running on port ${process.env.PORT}`);
})
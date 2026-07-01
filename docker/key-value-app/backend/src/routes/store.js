const express = require("express");
const {keyValue} = require("../models/keyValue");

const router = express.Router();

router.post('/', async (req, res) => {
    const {key, value} = req.body;

    if(!key || !value) {
        return res.status(400).send("Key and value are required");
    }

    try {
        const existingKV = await keyValue.findOne({key});
        if(existingKV) {
            return res.status(400).send("Key already exists");
        }

        const kv = new keyValue({key, value});
        await kv.save();
        res.status(201).send("Key-value pair created successfully");
    }catch(err) {
        console.log("Error creating key-value pair", err);
        res.status(500).send("Error creating key-value pair");
    }
})

router.get('/:key', async (req, res) => {
    const {key} = req.params;

    try {
        const kv = await keyValue.findOne({key});
        if(!kv) {
            return res.status(404).send("Key not found");
        }
        res.status(200).json({key: kv.key, value: kv.value});
    }catch(err) {
        console.log("Error getting key-value pair", err);
        res.status(500).send("Error getting key-value pair");
    }
})

router.put('/:key', async (req, res) => {
    const {key} = req.params;
    const {value} = req.body;

    if(!value) {
        return res.status(400).send("Value is required");
    }

    try {
        const kv = await keyValue.findOneAndUpdate({key}, {value}, {new: true});
        if(!kv) {
            return res.status(404).send("Key not found");
        }
        res.status(200).send("Key-value pair updated successfully");
    }catch(err) {
        console.log("Error updating key-value pair", err);
        res.status(500).send("Error updating key-value pair");
    }
})

router.delete('/:key', async (req, res) => {
    const {key} = req.params;

    try {
        const kv = await keyValue.findOneAndDelete({key});
        if(!kv) {
            return res.status(404).send("Key not found");
        }
        res.status(200).send("Key-value pair deleted successfully");
    }catch(err) {
        console.log("Error deleting key-value pair", err);
        res.status(500).send("Error deleting key-value pair");
    }
})



module.exports = {router};
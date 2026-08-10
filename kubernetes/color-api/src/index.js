// =============================================================================
// MICROSERVICE: COLOR API
// =============================================================================
// Designed for Kubernetes load balancing and networking demonstrations.
// Returns the container's hostname (`os.hostname()`), which in Kubernetes
// corresponds to the Pod Name.
//
// Endpoints:
// - GET /           : Returns HTML with color and hostname
// - GET /api        : Returns JSON { color, hostname }
// - GET /api?format=text : Returns plain text "Color is <color>"
// =============================================================================

const express = require("express");
const os = require("os");

const app = express();

const color = "blue";

app.get("/", (req, res) => {
    res.send(`<h1 style="color:${color}">${color}</h1>
    <p>Hostname: ${os.hostname()}</p>`);
});

app.get("/api", (req, res) => {
    const format = req.query.format;

    if (format === "text") {
        res.send(`Color is ${color}`);
    } else {
        res.json({ color, hostname: os.hostname() });
    }
});

app.listen(80, () => {
    console.log("Server started on port 80");
});
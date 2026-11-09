// =============================================================================
// MICROSERVICE: COLOR API
// =============================================================================
// Designed for Kubernetes load balancing, networking, and health-probe demonstrations.
// Returns the container's hostname (`os.hostname()`), which in Kubernetes
// corresponds to the Pod Name.
//
// Endpoints:
// - GET /           : Returns HTML with color and hostname
// - GET /api        : Returns JSON { color, hostname }
// - GET /api?format=text : Returns plain text "Color is <color>"
// - GET /ready      : Readiness probe endpoint. Returns 200 'ok' when ready,
//                     returns 503 when FAIL_READINESS=true (simulates unready pod).
// - GET /up         : Startup probe endpoint. Always returns 200 'ok'.
// - GET /health     : Liveness probe endpoint. Returns 200 'ok' when healthy,
//                     returns 503 when FAIL_LIVENESS=true (simulates deadlock/crash).
//
// Environment Variables:
// - DELAY_STARTUP   : When 'true', blocks startup for 60s to illustrate startup probes.
// - FAIL_LIVENESS   : When 'true', /health returns 503 to illustrate liveness probe failure.
// - FAIL_READINESS  : When 'true', /ready returns 503 (~50% chance) to illustrate readiness failure.
// =============================================================================

const express = require("express");
const os = require("os");

const app = express();

const color = "blue";

const delay_startup = process.env.DELAY_STARTUP === 'true';
const fail_liveness = process.env.FAIL_LIVENESS === 'true';
const fail_readiness = process.env.FAIL_READINESS === 'true' ? Math.random() < 0.5 : false;

console.log(`Delay Startup : ${delay_startup}`)
console.log(`Fail Liveness : ${fail_liveness}`)
console.log(`Fail Readiness : ${fail_readiness}`)
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

app.get("/ready", (req, res) => {
    if (fail_readiness) {
        return res.sendStatus(503)
    }

    res.send('ok')
})

app.get("/up", (req, res) => {
    res.send('ok')
})


app.get("/health", (req, res) => {
    if (fail_liveness) {
        return res.sendStatus(503)
    }

    res.send('ok')
})

if (delay_startup) {
    const start = Date.now();

    // purposefully block even exec for 60s. To illustrate startup probes
    while (Date.now() - start < 60000) {}
}

app.listen(80, () => {
    console.log("Server started on port 80");
});
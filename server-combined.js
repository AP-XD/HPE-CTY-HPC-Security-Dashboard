const http = require('http');
const fs = require('fs');

// Create server for port 7001
http.createServer((req, res) => {
    if (req.url === '/') {
        // Load JSON file
        fs.readFile('./trivy-cis-status.json', 'utf8', (err, data) => {
            if (err) {
                res.writeHead(500, { 'Content-Type': 'text/plain' });
                res.end('Error loading ./trivy-cis-status.json');
            } else {
                // Serve JSON data
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(data);
            }
        });
    } else {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('Page not found');
    }
}).listen(7001);
console.log('Server listening on port 7001');
// Create server for port 7000
http.createServer((req, res) => {
    if (req.url === '/') {
        // Load JSON file
        fs.readFile('./kube-bench.json', 'utf8', (err, data) => {
            if (err) {
                res.writeHead(500, { 'Content-Type': 'text/plain' });
                res.end('Error loading kube-bench.json');
            } else {
                // Serve JSON data
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(data);
            }
        });
    } else {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('Page not found');
    }
}).listen(7000);

console.log('Server listening on port 7000');
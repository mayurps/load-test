const http = require("http");
const fs = require("fs");
const path = require("path");

const payload = Buffer.alloc(2048); // 2 KB static payload
let requestCount = 0;
let errorCount = 0;

// Logger setup
const logFile = path.join(__dirname, 'server.log');
const logStream = fs.createWriteStream(logFile, { flags: 'a' });

function log(message) {
    const logLine = `${message}\n`;
    logStream.write(logLine);
    // Also output critical messages to console
    if (message.includes('ERROR') || message.includes('Server running') || message.includes('shutting down')) {
        console.log(message);
    }
}

function logError(message) {
    const logLine = `${message}\n`;
    logStream.write(logLine);
    console.error(message); // Always show errors on console
}

const server = http.createServer((req, res) => {
    requestCount++;
    const reqId = requestCount;
    const startTime = Date.now();
    
    log(`[${new Date().toISOString()}] #${reqId} ${req.method} ${req.url} from ${req.socket.remoteAddress}`);
    
    res.on('error', (err) => {
        errorCount++;
        logError(`[${new Date().toISOString()}] #${reqId} ERROR: ${err.message}`);
    });
    
    res.on('finish', () => {
        const duration = Date.now() - startTime;
        log(`[${new Date().toISOString()}] #${reqId} COMPLETED in ${duration}ms (Total: ${requestCount}, Errors: ${errorCount})`);
    });
    
    res.writeHead(200, {
        "Content-Type": "application/octet-stream",
        "Content-Length": payload.length,
        "Connection": "keep-alive"
    });
    res.end(payload);
});

server.on('error', (err) => {
    logError(`[${new Date().toISOString()}] SERVER ERROR: ${err.message}`);
    if (err.code === 'EADDRINUSE') {
        logError('Port 8080 is already in use');
        process.exit(1);
    }
});

server.on('clientError', (err, socket) => {
    errorCount++;
    logError(`[${new Date().toISOString()}] CLIENT ERROR: ${err.message}`);
    socket.end('HTTP/1.1 400 Bad Request\r\n\r\n');
});

server.listen(8080, () => {
    log(`[${new Date().toISOString()}] Server running on port 8080`);
    log(`[${new Date().toISOString()}] Process: PID=${process.pid}, Memory=${Math.round(process.memoryUsage().heapUsed / 1024 / 1024)}MB`);
    log(`[${new Date().toISOString()}] Logging to: ${logFile}`);
});

// Log memory usage every 10 seconds
setInterval(() => {
    const mem = process.memoryUsage();
    log(`[${new Date().toISOString()}] STATS - Requests: ${requestCount}, Errors: ${errorCount}, Memory: ${Math.round(mem.heapUsed / 1024 / 1024)}MB / ${Math.round(mem.rss / 1024 / 1024)}MB RSS`);
}, 10000);

// Graceful shutdown
process.on('SIGTERM', () => {
    log(`[${new Date().toISOString()}] SIGTERM received, shutting down gracefully`);
    server.close(() => {
        log(`[${new Date().toISOString()}] Server closed. Total requests: ${requestCount}, Errors: ${errorCount}`);
        logStream.end();
        process.exit(0);
    });
});

process.on('SIGINT', () => {
    log(`[${new Date().toISOString()}] SIGINT received, shutting down gracefully`);
    server.close(() => {
        log(`[${new Date().toISOString()}] Server closed. Total requests: ${requestCount}, Errors: ${errorCount}`);
        logStream.end();
        process.exit(0);
    });
});

const dns = require('node:dns');
const http = require('node:http');
const net = require('node:net');
const { spawn } = require('node:child_process');

const [opencode, ...args] = process.argv.slice(2);
if (!opencode) {
  console.error('Usage: opencode-ipv4 <opencode binary> [args...]');
  process.exit(2);
}

// Bun's fetch can wait on an unreachable IPv6 address. A local CONNECT
// proxy resolves destinations to IPv4 without changing system networking.
const proxy = http.createServer((_request, response) => {
  response.writeHead(405).end();
});

proxy.on('connect', (request, client, head) => {
  const [host, portText] = request.url.split(':');
  if (!host || Number(portText) !== 443) {
    client.end('HTTP/1.1 403 Forbidden\r\n\r\n');
    return;
  }

  dns.lookup(host, { family: 4 }, (lookupError, address) => {
    if (lookupError) {
      client.end('HTTP/1.1 502 Bad Gateway\r\n\r\n');
      return;
    }

    const upstream = net.connect({ host: address, port: 443 });
    upstream.once('connect', () => {
      client.write('HTTP/1.1 200 Connection Established\r\n\r\n');
      if (head.length) upstream.write(head);
      client.pipe(upstream);
      upstream.pipe(client);
    });
    upstream.on('error', () => client.destroy());
    client.on('error', () => upstream.destroy());
  });
});

proxy.listen(0, '127.0.0.1', () => {
  const address = proxy.address();
  const child = spawn(opencode, args, {
    stdio: 'inherit',
    env: {
      ...process.env,
      HTTPS_PROXY: `http://127.0.0.1:${address.port}`,
      NO_PROXY: ['localhost', '127.0.0.1', '::1', process.env.NO_PROXY]
        .filter(Boolean)
        .join(','),
    },
  });

  child.on('error', (error) => {
    console.error(error.message);
    proxy.close();
    process.exitCode = 1;
  });
  child.on('exit', (code, signal) => {
    proxy.close();
    process.exitCode = code ?? (signal === 'SIGINT' ? 130 : 1);
  });
});

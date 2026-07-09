/**
 * GitHub Raw Proxy Worker for Aaryan Host
 * Domains: codes.asj.qzz.io, ptero.asj.qzz.io
 * Made by Aaryan
 */

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const hostname = url.hostname;
    const path = url.pathname;

    // Log the request
    console.info({ message: 'Proxy request received', hostname, path });

    // --- Determine which GitHub repository to use ---
    let githubBaseUrl = '';

    if (hostname === 'ptero.asj.qzz.io') {
      // For ptero subdomain, serve the ptero.sh script
      githubBaseUrl = 'https://raw.githubusercontent.com/saggaraaryan311-sys/aaryanhost-ui/refs/heads/main';
      // If root path, default to ptero.sh
      const filePath = path === '/' || path === '' ? '/ptero.sh' : path;
      return fetchAndProxy(githubBaseUrl + filePath);
    } 
    else if (hostname === 'codes.asj.qzz.io') {
      // For codes subdomain, serve the Codes.sh script
      githubBaseUrl = 'https://raw.githubusercontent.com/saggaraaryan311-sys/aaryanhost-ui/refs/heads/main';
      const filePath = path === '/' || path === '' ? '/Codes.sh' : path;
      return fetchAndProxy(githubBaseUrl + filePath);
    }
    else {
      // Handle unexpected subdomains or direct access
      return new Response(`
╔══════════════════════════════════════════════════════════════╗
║        🚀 AARYAN HOST - RAW FILE SERVER                    ║
╠══════════════════════════════════════════════════════════════╣
║                                                             ║
║  USAGE:                                                     ║
║  https://ptero.asj.qzz.io/     - For Pterodactyl Installer  ║
║  https://codes.asj.qzz.io/     - For Codes Installer        ║
║                                                             ║
║  Made with ❤️ by Aaryan                                     ║
╚══════════════════════════════════════════════════════════════╝
`, {
        headers: {
          'Content-Type': 'text/plain',
          'Access-Control-Allow-Origin': '*',
        },
      });
    }
  },
};

// Helper function to fetch and proxy content from GitHub
async function fetchAndProxy(proxyUrl) {
  try {
    const response = await fetch(proxyUrl, {
      headers: {
        'User-Agent': 'Cloudflare-Worker',
      },
    });

    if (response.ok) {
      const newResponse = new Response(response.body, response);
      newResponse.headers.set('Access-Control-Allow-Origin', '*');
      newResponse.headers.set('Content-Type', 'text/plain');
      newResponse.headers.set('Cache-Control', 'public, max-age=3600');
      return newResponse;
    }

    if (response.status === 404) {
      return new Response(`
❌ FILE NOT FOUND

The requested file does not exist on GitHub.
URL: ${proxyUrl}
`, {
        status: 404,
        headers: {
          'Content-Type': 'text/plain',
          'Access-Control-Allow-Origin': '*',
        },
      });
    }
  } catch (e) {
    console.error({ message: 'Error fetching file', error: e.message });
  }

  return new Response('❌ Error fetching file from GitHub', {
    status: 500,
    headers: {
      'Content-Type': 'text/plain',
      'Access-Control-Allow-Origin': '*',
    },
  });
}

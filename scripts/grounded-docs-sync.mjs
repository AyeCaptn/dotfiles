#!/usr/bin/env node

// Queue core docs and refresh cached versions through the running MCP service.
import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { setTimeout } from 'node:timers/promises';

const root = dirname(dirname(fileURLToPath(import.meta.url)));
const cli = join(root, 'bin/grounded-docs');
const config = join(process.env.XDG_CONFIG_HOME ?? join(process.env.HOME, '.config'), 'grounded-docs');
const packageDir = execFileSync(cli, ['package-path'], {encoding: 'utf8'}).trim();
const pkg = join(packageDir, 'package.json');
const require = createRequire(pkg);
const {Client} = await import(pathToFileURL(require.resolve('@modelcontextprotocol/sdk/client/index.js')));
const {StreamableHTTPClientTransport} = await import(pathToFileURL(require.resolve('@modelcontextprotocol/sdk/client/streamableHttp.js')));

async function main() {
  // launchd starts this job alongside the server.
  let ready = false;
  for (let attempt = 0; attempt < 60; attempt++) {
    try {
      const response = await fetch('http://127.0.0.1:6280/', {signal: AbortSignal.timeout(2000)});
      await response.body?.cancel();
      if (response.ok) { ready = true; break; }
    } catch { /* The service may still be starting. */ }
    await setTimeout(2000);
  }
  if (!ready) throw new Error('Grounded Docs did not become available on port 6280.');

  const libraries = JSON.parse(execFileSync(cli, ['list', '--output', 'json', '--quiet'], {encoding: 'utf8', timeout: 30000}));
  const sources = JSON.parse(readFileSync(join(config, 'sources.json'), 'utf8'));
  const existing = new Map();
  for (const library of libraries) {
    for (const version of library.versions) {
      existing.set(JSON.stringify([library.name.toLowerCase(), version.version]), version);
    }
  }
  const client = new Client({name: 'dotfiles-docs-refresh', version: '1.0.0'});
  let failures = 0;
  let queued = 0;
  async function queue(name, args) {
    try {
      const result = await client.callTool({name, arguments: args});
      const text = result.content.filter(item => item.type === 'text').map(item => item.text).join('\n');
      if (result.isError) throw new Error(text);
      queued++;
      console.log(`${args.library}${args.version ? ' ' + args.version : ''}: ${text}`);
    } catch (error) {
      failures++;
      console.error(`${args.library}: ${error.message}`);
    }
  }
  try {
    await client.connect(new StreamableHTTPClientTransport(new URL('http://127.0.0.1:6280/mcp')));
    const reindexed = new Set();
    for (const source of sources) {
      const key = JSON.stringify([source.name.toLowerCase(), source.version ?? '']);
      const info = existing.get(key);
      if (info && ['queued', 'running', 'updating'].includes(info.status)) continue;
      if (info?.sourceUrl === source.url && info.documentCount > 0) continue;
      await queue('scrape_docs', {
        library: source.name, url: source.url,
        ...(source.version ? {version: source.version} : {}),
        ...(source.scope ? {scope: source.scope} : {}),
        ...(source.includePatterns ? {includePatterns: source.includePatterns} : {}),
      });
      reindexed.add(key);
    }
    for (const [key, info] of existing) {
      if (reindexed.has(key)) continue;
      if (['queued', 'running', 'updating'].includes(info.status) || !info.sourceUrl) continue;
      const [library, version] = JSON.parse(key);
      await queue('refresh_version', {library, ...(version ? {version} : {})});
    }
  } finally {
    await client.close();
  }
  console.log(`Queued ${queued} documentation job(s); ${failures} scheduling failure(s). See the dashboard for indexing results.`);
  process.exitCode = failures ? 1 : 0;
}

main().catch(error => {
  console.error(`grounded-docs sync: ${error.message}`);
  process.exitCode = 1;
});

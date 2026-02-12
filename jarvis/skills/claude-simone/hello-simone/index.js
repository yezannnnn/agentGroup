#!/usr/bin/env node
import { program } from 'commander';
import chalk from 'chalk';
import { installMCP } from './install-mcp.js';
import { installLegacy } from './install-legacy.js';

console.log(chalk.cyan.bold(`
╔═══════════════════════════════════════╗
║          🤖 SIMONE INSTALLER          ║
╚═══════════════════════════════════════╝
`));

program
  .name('hello-simone')
  .description('Install Simone - AI-powered project management')
  .version('0.6.0')
  .option('--mcp', 'Install MCP version (early preview)')
  .option('--legacy', 'Install legacy version (default)')
  .option('--dry-run', 'Preview installation without making changes')
  .parse();

const options = program.opts();

async function main() {
  try {
    if (options.mcp) {
      console.log(chalk.yellow('🚀 Installing Simone MCP Server (Early Preview)\n'));
      await installMCP(options.dryRun);
    } else {
      console.log(chalk.green('📦 Installing Simone Legacy Version\n'));
      await installLegacy(options.dryRun);
    }
  } catch (error) {
    console.error(chalk.red('\n❌ Installation failed:'), error.message);
    process.exit(1);
  }
}

main();
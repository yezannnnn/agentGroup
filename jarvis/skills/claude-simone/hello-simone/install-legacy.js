import chalk from 'chalk';
import inquirer from 'inquirer';
import ora from 'ora';
import { promises as fs } from 'fs';
import path from 'path';

export async function installLegacy(dryRun = false) {
  console.log(chalk.green.bold('✅  STABLE VERSION\n'));
  console.log(chalk.white(
    'Installing the stable, production-ready version of Simone.\n' +
    'This is the recommended version for most users.\n'
  ));

  const spinner = ora();

  try {
    // Create directory structure
    spinner.start('Creating .simone directory structure...');
    
    const directories = [
      '.simone',
      '.simone/01_PROJECT_DOCS',
      '.simone/02_REQUIREMENTS',
      '.simone/03_SPRINTS',
      '.simone/04_TASKS',
      '.simone/04_TASKS/GENERAL'
    ];

    if (!dryRun) {
      for (const dir of directories) {
        await fs.mkdir(dir, { recursive: true });
      }
    }
    
    spinner.succeed('Created directory structure');

    // Create project manifest
    spinner.start('Creating project manifest...');
    
    const manifestContent = `# PROJECT MANIFEST

## Project Name
[Your Project Name]

## Project Description
[Brief description of your project]

## Project Status
- Created: ${new Date().toISOString().split('T')[0]}
- Status: Active
- Version: 0.0.1

## Team
- AI Assistant: Claude
- Human: [Your Name]

---
*Managed by Simone Legacy System*
`;

    if (!dryRun) {
      await fs.writeFile('.simone/00_PROJECT_MANIFEST.md', manifestContent);
    }
    
    spinner.succeed('Created project manifest');

    console.log(chalk.green.bold('\n✅ Simone installation complete!\n'));
    console.log(chalk.cyan('To get started:'));
    console.log(chalk.white('  1. Navigate to your project directory'));
    console.log(chalk.white('  2. Run /simone:initialize in Claude Code\n'));
    console.log(chalk.gray('For experimental MCP version: npx hello-simone --mcp'));

  } catch (error) {
    spinner.fail('Installation failed');
    throw error;
  }
}
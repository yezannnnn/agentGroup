#!/usr/bin/env node

import { readFileSync, writeFileSync } from 'fs';
import { execSync } from 'child_process';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const rootDir = join(__dirname, '..');
const versionsFile = join(__dirname, 'versions.json');

// Read versions.json
function getVersions() {
  return JSON.parse(readFileSync(versionsFile, 'utf8'));
}

// Write versions.json
function saveVersions(versions) {
  versions.updated = new Date().toISOString().split('T')[0];
  writeFileSync(versionsFile, JSON.stringify(versions, null, 2) + '\n');
}

// Get current git tags
function getGitTags() {
  try {
    const tags = execSync('git tag -l', { encoding: 'utf8' }).trim().split('\n');
    return tags.filter(t => t);
  } catch {
    return [];
  }
}

// Create git tag
function createTag(tag, message) {
  execSync(`git tag -a ${tag} -m "${message}"`, { stdio: 'inherit' });
  console.log(`✅ Created tag: ${tag}`);
}

// Commands
const commands = {
  list() {
    const versions = getVersions();
    console.log('\n📦 Component Versions:\n');
    
    for (const [id, component] of Object.entries(versions.components)) {
      const tag = `${component.tagPrefix}${component.version}`;
      const hasTag = getGitTags().includes(tag);
      console.log(`${component.name} (${id})`);
      console.log(`  Version: ${component.version}`);
      console.log(`  Type: ${component.type}`);
      console.log(`  Tag: ${tag} ${hasTag ? '✅' : '❌ (not tagged)'}`);
      console.log(`  Path: ${component.path}`);
      console.log('');
    }
  },

  tag(componentId) {
    if (!componentId) {
      console.error('❌ Please specify a component: legacy, hello-simone, or mcp-server');
      process.exit(1);
    }

    const versions = getVersions();
    const component = versions.components[componentId];
    
    if (!component) {
      console.error(`❌ Unknown component: ${componentId}`);
      process.exit(1);
    }

    const tag = `${component.tagPrefix}${component.version}`;
    
    if (getGitTags().includes(tag)) {
      console.error(`❌ Tag ${tag} already exists`);
      process.exit(1);
    }

    // For npm packages, verify package.json version matches
    if (component.type === 'npm') {
      const packageJsonPath = join(rootDir, component.path, 'package.json');
      const packageJson = JSON.parse(readFileSync(packageJsonPath, 'utf8'));
      
      if (packageJson.version !== component.version) {
        console.error(`❌ Version mismatch!`);
        console.error(`   versions.json: ${component.version}`);
        console.error(`   package.json: ${packageJson.version}`);
        console.error(`\nRun 'npm run version:sync' to fix this.`);
        process.exit(1);
      }
    }

    createTag(tag, `Release ${component.name} v${component.version}`);
  },

  sync() {
    const versions = getVersions();
    let updated = false;

    for (const [id, component] of Object.entries(versions.components)) {
      if (component.type === 'npm') {
        const packageJsonPath = join(rootDir, component.path, 'package.json');
        try {
          const packageJson = JSON.parse(readFileSync(packageJsonPath, 'utf8'));
          
          if (packageJson.version !== component.version) {
            console.log(`📝 Updating ${id}: ${component.version} → ${packageJson.version}`);
            component.version = packageJson.version;
            updated = true;
          }
        } catch (err) {
          console.warn(`⚠️  Could not read package.json for ${id}`);
        }
      }
    }

    if (updated) {
      saveVersions(versions);
      console.log('\n✅ versions.json updated');
    } else {
      console.log('\n✅ All versions are in sync');
    }
  },

  'migrate-tags'() {
    const existingTags = getGitTags();
    
    // Handle legacy v0.3.5 tag
    if (existingTags.includes('v0.3.5') && !existingTags.includes('legacy/v0.3.5')) {
      console.log('🔄 Migrating v0.3.5 to legacy/v0.3.5...');
      
      // Get the commit hash for the existing tag
      const commit = execSync('git rev-list -n 1 v0.3.5', { encoding: 'utf8' }).trim();
      
      // Create new tag at same commit
      execSync(`git tag -a legacy/v0.3.5 ${commit} -m "Legacy Simone v0.3.5 (migrated from v0.3.5)"`, { stdio: 'inherit' });
      
      console.log('✅ Created legacy/v0.3.5');
      console.log('ℹ️  Original v0.3.5 tag preserved for compatibility');
    } else if (existingTags.includes('legacy/v0.3.5')) {
      console.log('✅ legacy/v0.3.5 already exists');
    } else {
      console.log('❌ No v0.3.5 tag found to migrate');
    }
  }
};

// Main
const command = process.argv[2];

if (!command || !commands[command]) {
  console.log(`
📦 Simone Version Manager

Usage: node scripts/version-manager.js <command>

Commands:
  list          Show all component versions and their tags
  tag <id>      Create a git tag for a component (legacy, hello-simone, mcp-server)
  sync          Sync versions.json with package.json files
  migrate-tags  Migrate old tags to new naming scheme

Examples:
  node scripts/version-manager.js list
  node scripts/version-manager.js tag mcp-server
  node scripts/version-manager.js sync
`);
  process.exit(1);
}

commands[command](process.argv[3]);
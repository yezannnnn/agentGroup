import { describe, it, expect } from 'vitest';
import { detectActivityType } from './activity-types.js';

describe('detectActivityType', () => {
  it('should detect create activities', () => {
    expect(detectActivityType('Created new feature')).toBe('create');
    expect(detectActivityType('Add authentication module')).toBe('create');
    expect(detectActivityType('Generated test files')).toBe('create');
    expect(detectActivityType('Initialize project')).toBe('create');
    expect(detectActivityType('new component added')).toBe('create');
  });

  it('should detect update activities', () => {
    expect(detectActivityType('Updated dependencies')).toBe('update');
    expect(detectActivityType('Modified configuration')).toBe('update');
    expect(detectActivityType('Changed database schema')).toBe('update');
    expect(detectActivityType('Edit README file')).toBe('update');
  });

  it('should detect fix activities', () => {
    expect(detectActivityType('Fixed authentication bug')).toBe('fix');
    expect(detectActivityType('Repaired broken tests')).toBe('fix');
    expect(detectActivityType('Resolved merge conflict')).toBe('fix');
    expect(detectActivityType('Solved performance issue')).toBe('fix');
    expect(detectActivityType('Patched security vulnerability')).toBe('fix');
  });

  it('should detect review activities', () => {
    expect(detectActivityType('Reviewed pull request')).toBe('review');
    expect(detectActivityType('Check code quality')).toBe('review');
    expect(detectActivityType('Examined test coverage')).toBe('review');
    expect(detectActivityType('Inspect database queries')).toBe('review');
  });

  it('should detect research activities', () => {
    expect(detectActivityType('Researched authentication methods')).toBe('research');
    expect(detectActivityType('Investigated performance issues')).toBe('research');
    expect(detectActivityType('Explored new frameworks')).toBe('research');
    expect(detectActivityType('Search for best practices')).toBe('research');
  });

  it('should detect document activities', () => {
    expect(detectActivityType('Documented API endpoints')).toBe('document');
    expect(detectActivityType('Write user guide')).toBe('document');
    expect(detectActivityType('Described architecture')).toBe('document');
    expect(detectActivityType('Explained configuration options')).toBe('document');
  });

  it('should detect test activities', () => {
    expect(detectActivityType('Tested new feature')).toBe('test');
    expect(detectActivityType('Verify bug fix')).toBe('test');
    expect(detectActivityType('Validated user input')).toBe('test');
    expect(detectActivityType('Check API responses')).toBe('test');
  });

  it('should detect deploy activities', () => {
    expect(detectActivityType('Deployed to production')).toBe('deploy');
    expect(detectActivityType('Released version 2.0')).toBe('deploy');
    expect(detectActivityType('Published npm package')).toBe('deploy');
    expect(detectActivityType('Launched new feature')).toBe('deploy');
  });

  it('should detect configure activities', () => {
    expect(detectActivityType('Configured CI/CD pipeline')).toBe('configure');
    expect(detectActivityType('Setup development environment')).toBe('configure');
    expect(detectActivityType('Installed dependencies')).toBe('configure');
    expect(detectActivityType('Config file updated')).toBe('configure');
  });

  it('should detect refactor activities', () => {
    expect(detectActivityType('Refactored authentication module')).toBe('refactor');
    expect(detectActivityType('Reorganized project structure')).toBe('refactor');
    expect(detectActivityType('Restructured database schema')).toBe('refactor');
    expect(detectActivityType('Clean up code')).toBe('refactor');
  });

  it('should detect delete activities', () => {
    expect(detectActivityType('Deleted unused files')).toBe('delete');
    expect(detectActivityType('Removed deprecated API')).toBe('delete');
    expect(detectActivityType('Clean up old branches')).toBe('delete');
    expect(detectActivityType('Drop unused table')).toBe('delete');
  });

  it('should detect analyze activities', () => {
    expect(detectActivityType('Analyzed performance metrics')).toBe('analyze');
    expect(detectActivityType('Assessed security risks')).toBe('analyze');
    expect(detectActivityType('Evaluated code quality')).toBe('analyze');
    expect(detectActivityType('Measured test coverage')).toBe('analyze');
  });

  it('should detect plan activities', () => {
    expect(detectActivityType('Planned sprint tasks')).toBe('plan');
    expect(detectActivityType('Designed new architecture')).toBe('plan');
    expect(detectActivityType('Architected microservices')).toBe('plan');
    expect(detectActivityType('Outlined implementation steps')).toBe('plan');
  });

  it('should detect debug activities', () => {
    expect(detectActivityType('Debugged authentication issue')).toBe('debug');
    expect(detectActivityType('Troubleshooted deployment failure')).toBe('debug');
    expect(detectActivityType('Diagnosed memory leak')).toBe('debug');
    expect(detectActivityType('Traced execution flow')).toBe('debug');
  });

  it('should be case insensitive', () => {
    expect(detectActivityType('CREATED NEW FEATURE')).toBe('create');
    expect(detectActivityType('Updated Dependencies')).toBe('update');
    expect(detectActivityType('FiXeD bUg')).toBe('fix');
  });

  it('should detect keyword anywhere in the string', () => {
    expect(detectActivityType('Successfully created new feature after refactoring')).toBe('create');
    expect(detectActivityType('The team reviewed and fixed the bug')).toBe('review');
  });

  it('should prioritize first matching keyword type', () => {
    // 'create' comes before 'test' in the keywords object
    expect(detectActivityType('Created tests for new feature')).toBe('create');
  });

  it('should extract first word when no keywords match', () => {
    expect(detectActivityType('Implemented OAuth integration')).toBe('implemented');
    expect(detectActivityType('Optimized database queries')).toBe('optimized');
    expect(detectActivityType('Migrated to TypeScript')).toBe('migrated');
  });

  it('should return "other" for very short first words or no words', () => {
    expect(detectActivityType('Do stuff')).toBe('other'); // "Do" is too short
    expect(detectActivityType('Is working')).toBe('other'); // "Is" is too short
    expect(detectActivityType('')).toBe('other');
    expect(detectActivityType('   ')).toBe('other');
  });

  it('should handle special characters and punctuation', () => {
    expect(detectActivityType('Created: new feature!')).toBe('create');
    expect(detectActivityType('[FIX] Authentication bug')).toBe('fix');
    expect(detectActivityType('- Updated dependencies')).toBe('update');
  });
});
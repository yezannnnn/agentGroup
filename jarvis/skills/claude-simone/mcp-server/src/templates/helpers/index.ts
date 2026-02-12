/**
 * @module TemplateHelpers
 * @description Exports all custom Handlebars helpers for the templating system
 */

import Handlebars from 'handlebars';

/**
 * Register all custom Handlebars helpers
 */
export function registerHelpers(): void {
  // Register equality helper for comparisons
  Handlebars.registerHelper('eq', function(a: any, b: any) {
    return a === b;
  });
  
  // Register comparison helpers
  Handlebars.registerHelper('lt', function(a: any, b: any) {
    return a < b;
  });
  
  Handlebars.registerHelper('lte', function(a: any, b: any) {
    return a <= b;
  });
  
  Handlebars.registerHelper('gt', function(a: any, b: any) {
    return a > b;
  });
  
  Handlebars.registerHelper('gte', function(a: any, b: any) {
    return a >= b;
  });
  
  // Register logical helpers
  Handlebars.registerHelper('or', function(...args: any[]) {
    // Remove the options hash from arguments
    args.pop(); // Remove options hash
    return args.some(arg => !!arg);
  });
  
  Handlebars.registerHelper('and', function(...args: any[]) {
    // Remove the options hash from arguments
    args.pop(); // Remove options hash
    return args.every(arg => !!arg);
  });
  
  Handlebars.registerHelper('not', function(value: any) {
    return !value;
  });
}
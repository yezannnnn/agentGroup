export interface PromptArgument {
  name: string;
  description: string;
  required?: boolean;
  default?: string;
}

export interface PromptTemplate {
  name: string;
  description: string;
  arguments?: PromptArgument[];
  template: string;
}

export interface TemplateContext {
  PROJECT_PATH: string;
  PROJECT_NAME: string;
  TIMESTAMP: string;
  [key: string]: any; // Allow dynamic arguments
}
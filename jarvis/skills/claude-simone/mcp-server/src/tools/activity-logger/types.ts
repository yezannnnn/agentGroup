export interface LogActivityParams {
  activity: string;
  tool_name: string;
  success?: boolean;
  error?: string;
  tags?: string[];
  context?: string;
  files_affected?: string[];
  issue_number?: number;
  link?: string;
}

export interface ActivityLogEntry {
  id: number;
  timestamp: string;
  activity: string;
  activity_type: string;
  tool_name: string;
  success: boolean;
  error?: string;
  context?: string;
  issue_number?: number;
  link?: string;
}
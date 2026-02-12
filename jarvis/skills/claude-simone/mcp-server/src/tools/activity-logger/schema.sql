-- Activity logging schema for Simone

-- Core activity log table
CREATE TABLE activity_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    activity TEXT NOT NULL,
    activity_type TEXT NOT NULL,
    tool_name TEXT NOT NULL,
    success BOOLEAN DEFAULT 1,
    error TEXT,
    context TEXT,
    issue_number INTEGER,
    link TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Activity-specific tags table
CREATE TABLE activity_tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL
);

-- Many-to-many relationship for activity log tags
CREATE TABLE activity_log_tags (
    activity_id INTEGER,
    tag_id INTEGER,
    PRIMARY KEY (activity_id, tag_id),
    FOREIGN KEY (activity_id) REFERENCES activity_log(id),
    FOREIGN KEY (tag_id) REFERENCES activity_tags(id)
);

-- Files affected by activities
CREATE TABLE activity_files (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    activity_id INTEGER,
    file_path TEXT NOT NULL,
    operation TEXT,
    FOREIGN KEY (activity_id) REFERENCES activity_log(id)
);

-- Indexes for performance
CREATE INDEX idx_activity_log_timestamp ON activity_log(timestamp);
CREATE INDEX idx_activity_log_tool_name ON activity_log(tool_name);
CREATE INDEX idx_activity_log_activity_type ON activity_log(activity_type);
CREATE INDEX idx_activity_log_success ON activity_log(success);
CREATE INDEX idx_activity_tags_name ON activity_tags(name);
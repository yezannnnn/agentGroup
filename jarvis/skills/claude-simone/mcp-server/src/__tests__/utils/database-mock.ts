import Database from 'better-sqlite3';
import { DatabaseConnection } from '../../tools/database.js';

export function createTestDatabase(): Database.Database {
  // Create in-memory database for testing
  return new Database(':memory:');
}

export function createInMemoryDatabase(): Database.Database {
  // Alias for createTestDatabase - used by integration tests
  return createTestDatabase();
}

export async function createTestDatabaseConnection(): Promise<DatabaseConnection> {
  const dbConnection = new DatabaseConnection(':memory:');
  await dbConnection.initialize();
  return dbConnection;
}

export function setupTestDatabase() {
  let db: Database.Database;
  let dbConnection: DatabaseConnection;

  beforeEach(async () => {
    db = createTestDatabase();
    dbConnection = await createTestDatabaseConnection();
  });

  afterEach(() => {
    // Close database with error handling
    if (db) {
      try {
        if (!db.inTransaction) {
          db.close();
        }
      } catch (error) {
        // Database might already be closed
        console.warn('Database cleanup error:', error);
      }
    }
    
    if (dbConnection && dbConnection.db) {
      try {
        if (!dbConnection.db.inTransaction) {
          dbConnection.db.close();
        }
      } catch (error) {
        // Database might already be closed
        console.warn('Database connection cleanup error:', error);
      }
    }
  });

  return {
    getDb: () => db,
    getConnection: () => dbConnection,
  };
}
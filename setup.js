const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

async function setupDatabase() {
  console.log('🚀 Setting up Sales Leaderboard Database...\n');

  let connection;

  try {
    // Connect without database first
    connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      port: process.env.DB_PORT,
      multipleStatements: true
    });

    console.log('✅ Connected to MySQL');

    // Create database if not exists
    await connection.query(`CREATE DATABASE IF NOT EXISTS ${process.env.DB_NAME}`);
    console.log(`✅ Database '${process.env.DB_NAME}' created/verified`);

    // Use the database
    await connection.query(`USE ${process.env.DB_NAME}`);

    // Read and execute schema SQL
    const schemaPath = path.join(__dirname, 'database', 'schema.sql');
    const schemaSql = fs.readFileSync(schemaPath, 'utf8');

    await connection.query(schemaSql);
    console.log('✅ Tables created and sample data inserted');

    // Verify setup
    const [agents] = await connection.query('SELECT COUNT(*) as count FROM agents');
    const [sales] = await connection.query('SELECT COUNT(*) as count FROM sales');

    console.log(`\n📊 Setup Summary:`);
    console.log(`   - Agents: ${agents[0].count}`);
    console.log(`   - Sales: ${sales[0].count}`);
    console.log('\n✨ Database setup completed successfully!');
    console.log('\n🚀 You can now run: npm start');

  } catch (error) {
    console.error('❌ Setup failed:', error.message);
    process.exit(1);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

setupDatabase();
const pool = require('../config/database');

// Add new sale
exports.addSale = async (req, res) => {
  try {
    const { agent_name, amount, notes } = req.body;

    // Validation
    if (!agent_name || !amount) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: agent_name and amount'
      });
    }

    if (amount <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Amount must be greater than 0'
      });
    }

    // Check if agent exists
    const [agents] = await pool.query(
      'SELECT agent_id FROM agents WHERE name = ?',
      [agent_name]
    );

    let agent_id;

    if (agents.length > 0) {
      agent_id = agents[0].agent_id;
    } else {
      // Create new agent
      const [result] = await pool.query(
        'INSERT INTO agents (name) VALUES (?)',
        [agent_name]
      );
      agent_id = result.insertId;
    }

    // Insert sale
    const [saleResult] = await pool.query(
      'INSERT INTO sales (agent_id, amount, notes) VALUES (?, ?, ?)',
      [agent_id, amount, notes || null]
    );

    // Get updated agent stats
    const [stats] = await pool.query(
      `SELECT 
        COUNT(*) as total_deals,
        SUM(amount) as total_sales
      FROM sales 
      WHERE agent_id = ?`,
      [agent_id]
    );

    res.status(201).json({
      success: true,
      message: 'Sale added successfully',
      data: {
        sale_id: saleResult.insertId,
        agent_name,
        amount: parseFloat(amount),
        total_sales: parseFloat(stats[0].total_sales),
        total_deals: stats[0].total_deals
      }
    });

  } catch (error) {
    console.error('Add sale error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to add sale',
      error: error.message
    });
  }
};

// Get all sales (with filters)
exports.getAllSales = async (req, res) => {
  try {
    const { agent_id, limit = 50, offset = 0 } = req.query;

    let query = `
      SELECT 
        s.sale_id,
        s.amount,
        s.sale_date,
        s.notes,
        a.name as agent_name,
        a.email as agent_email
      FROM sales s
      JOIN agents a ON s.agent_id = a.agent_id
    `;

    const params = [];

    if (agent_id) {
      query += ' WHERE s.agent_id = ?';
      params.push(agent_id);
    }

    query += ' ORDER BY s.sale_date DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), parseInt(offset));

    const [sales] = await pool.query(query, params);

    res.json({
      success: true,
      count: sales.length,
      sales: sales.map(sale => ({
        sale_id: sale.sale_id,
        agent_name: sale.agent_name,
        agent_email: sale.agent_email,
        amount: parseFloat(sale.amount),
        sale_date: sale.sale_date,
        notes: sale.notes
      }))
    });

  } catch (error) {
    console.error('Get sales error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch sales',
      error: error.message
    });
  }
};

// Delete sale (optional - for admin)
exports.deleteSale = async (req, res) => {
  try {
    const { id } = req.params;

    const [result] = await pool.query(
      'DELETE FROM sales WHERE sale_id = ?',
      [id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Sale not found'
      });
    }

    res.json({
      success: true,
      message: 'Sale deleted successfully'
    });

  } catch (error) {
    console.error('Delete sale error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete sale',
      error: error.message
    });
  }
};
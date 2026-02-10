const pool = require('../config/database');

// Get leaderboard with ranking
exports.getLeaderboard = async (req, res) => {
  try {
    const { period = 'today' } = req.query;

    // Build date filter based on period
    let dateFilter = '';
    switch (period.toLowerCase()) {
      case 'today':
        dateFilter = "AND DATE(s.sale_date) = CURDATE()";
        break;
      case 'week':
        dateFilter = "AND s.sale_date >= DATE_SUB(NOW(), INTERVAL 7 DAY)";
        break;
      case 'month':
        dateFilter = "AND s.sale_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)";
        break;
      case 'all':
      default:
        dateFilter = "";
        break;
    }

    // Get leaderboard with ranking
    const query = `
      SELECT 
        a.agent_id,
        a.name,
        a.email,
        COALESCE(SUM(s.amount), 0) as total_sales,
        COALESCE(COUNT(s.sale_id), 0) as total_deals,
        RANK() OVER (ORDER BY COALESCE(SUM(s.amount), 0) DESC) as ranking
      FROM agents a
      LEFT JOIN sales s ON a.agent_id = s.agent_id ${dateFilter}
      WHERE a.status = 'active'
      GROUP BY a.agent_id, a.name, a.email
      HAVING total_sales > 0
      ORDER BY total_sales DESC, total_deals DESC
    `;

    const [leaderboard] = await pool.query(query);

    // Calculate summary statistics
    const totalSales = leaderboard.reduce((sum, agent) => sum + parseFloat(agent.total_sales), 0);
    const totalAgents = leaderboard.length;

    res.json({
      success: true,
      period,
      total_agents: totalAgents,
      total_sales: totalSales,
      average_per_agent: totalAgents > 0 ? totalSales / totalAgents : 0,
      leaderboard: leaderboard.map(agent => ({
        rank: agent.ranking,
        agent_id: agent.agent_id,
        name: agent.name,
        email: agent.email,
        total_sales: parseFloat(agent.total_sales),
        total_deals: agent.total_deals
      }))
    });

  } catch (error) {
    console.error('Leaderboard error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch leaderboard',
      error: error.message
    });
  }
};

// Get agent details
exports.getAgentDetails = async (req, res) => {
  try {
    const { id, name } = req.query;

    if (!id && !name) {
      return res.status(400).json({
        success: false,
        message: 'Please provide either agent id or name'
      });
    }

    // Get agent info
    const agentQuery = id 
      ? 'SELECT * FROM agents WHERE agent_id = ?'
      : 'SELECT * FROM agents WHERE name = ?';
    
    const [agents] = await pool.query(agentQuery, [id || name]);

    if (agents.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Agent not found'
      });
    }

    const agent = agents[0];

    // Get statistics
    const [stats] = await pool.query(
      `SELECT 
        COUNT(*) as total_deals,
        COALESCE(SUM(amount), 0) as total_sales,
        COALESCE(AVG(amount), 0) as avg_sale,
        COALESCE(MAX(amount), 0) as highest_sale,
        COALESCE(MIN(amount), 0) as lowest_sale
      FROM sales 
      WHERE agent_id = ?`,
      [agent.agent_id]
    );

    // Get recent sales
    const [recentSales] = await pool.query(
      `SELECT 
        sale_id,
        amount,
        sale_date,
        notes
      FROM sales 
      WHERE agent_id = ?
      ORDER BY sale_date DESC
      LIMIT 10`,
      [agent.agent_id]
    );

    // Get current rank
    const [rankResult] = await pool.query(
      `SELECT ranking FROM (
        SELECT 
          a.agent_id,
          RANK() OVER (ORDER BY COALESCE(SUM(s.amount), 0) DESC) as ranking
        FROM agents a
        LEFT JOIN sales s ON a.agent_id = s.agent_id
        WHERE a.status = 'active'
        GROUP BY a.agent_id
      ) ranked
      WHERE agent_id = ?`,
      [agent.agent_id]
    );

    res.json({
      success: true,
      agent: {
        agent_id: agent.agent_id,
        name: agent.name,
        email: agent.email,
        phone: agent.phone,
        joined_date: agent.joined_date,
        status: agent.status,
        current_rank: rankResult.length > 0 ? rankResult[0].ranking : null
      },
      statistics: {
        total_deals: stats[0].total_deals,
        total_sales: parseFloat(stats[0].total_sales),
        average_sale: parseFloat(stats[0].avg_sale),
        highest_sale: parseFloat(stats[0].highest_sale),
        lowest_sale: parseFloat(stats[0].lowest_sale)
      },
      recent_sales: recentSales.map(sale => ({
        sale_id: sale.sale_id,
        amount: parseFloat(sale.amount),
        date: sale.sale_date,
        notes: sale.notes
      }))
    });

  } catch (error) {
    console.error('Agent details error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch agent details',
      error: error.message
    });
  }
};

const express = require('express');
const router = express.Router();
const salesController = require('../controllers/salescontroller');
const leaderboardController = require('../controllers/leaderboardcontroller');

// Sales routes
router.post('/sales', salesController.addSale);
router.get('/sales', salesController.getAllSales);
router.delete('/sales/:id', salesController.deleteSale);

// Leaderboard routes
router.get('/leaderboard', leaderboardController.getLeaderboard);
router.get('/agent', leaderboardController.getAgentDetails);

module.exports = router;
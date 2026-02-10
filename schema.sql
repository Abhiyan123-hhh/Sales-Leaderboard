```sql
-- Sales Leaderboard Database Schema for Node.js
-- Drop existing tables if they exist
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS agents;

-- Create agents table
CREATE TABLE agents (
    agent_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    joined_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_name (name),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create sales table
CREATE TABLE sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    agent_id INT NOT NULL,
    amount DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id) ON DELETE CASCADE,
    INDEX idx_agent_date (agent_id, sale_date),
    INDEX idx_sale_date (sale_date),
    INDEX idx_amount (amount)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert sample agents
INSERT INTO agents (name, email, phone) VALUES
('Ram Sharma', 'ram.sharma@company.com', '9841234567'),
('Sita Karki', 'sita.karki@company.com', '9851234568'),
('Hari Thapa', 'hari.thapa@company.com', '9861234569'),
('Geeta Gurung', 'geeta.gurung@company.com', '9871234570'),
('Mohan Rai', 'mohan.rai@company.com', '9881234571'),
('Krishna Shrestha', 'krishna.shrestha@company.com', '9891234572'),
('Sunita Tamang', 'sunita.tamang@company.com', '9801234573');

-- Insert sample sales data (realistic distribution)
INSERT INTO sales (agent_id, amount, sale_date, notes) VALUES
-- Ram Sharma (Top performer - 500,000 total, 12 deals)
(1, 50000, DATE_SUB(NOW(), INTERVAL 1 HOUR), 'Corporate client'),
(1, 45000, DATE_SUB(NOW(), INTERVAL 3 HOUR), 'Referral'),
(1, 60000, DATE_SUB(NOW(), INTERVAL 5 HOUR), 'Premium package'),
(1, 35000, DATE_SUB(NOW(), INTERVAL 1 DAY), 'Regular sale'),
(1, 70000, DATE_SUB(NOW(), INTERVAL 2 DAY), 'Large order'),
(1, 40000, DATE_SUB(NOW(), INTERVAL 3 DAY), 'Repeat customer'),
(1, 55000, DATE_SUB(NOW(), INTERVAL 4 DAY), 'New client'),
(1, 30000, DATE_SUB(NOW(), INTERVAL 5 DAY), 'Standard package'),
(1, 45000, DATE_SUB(NOW(), INTERVAL 6 DAY), 'Enterprise'),
(1, 25000, DATE_SUB(NOW(), INTERVAL 1 WEEK), 'Small business'),
(1, 30000, DATE_SUB(NOW(), INTERVAL 2 WEEK), 'Startup'),
(1, 15000, DATE_SUB(NOW(), INTERVAL 3 WEEK), 'Basic package'),

-- Sita Karki (Second place - 420,000 total, 15 deals)
(2, 35000, DATE_SUB(NOW(), INTERVAL 2 HOUR), 'Mid-size client'),
(2, 40000, DATE_SUB(NOW(), INTERVAL 4 HOUR), 'Upgrade sale'),
(2, 25000, DATE_SUB(NOW(), INTERVAL 6 HOUR), 'New customer'),
(2, 30000, DATE_SUB(NOW(), INTERVAL 1 DAY), 'Renewal'),
(2, 45000, DATE_SUB(NOW(), INTERVAL 2 DAY), 'Premium'),
(2, 20000, DATE_SUB(NOW(), INTERVAL 3 DAY), 'Standard'),
(2, 35000, DATE_SUB(NOW(), INTERVAL 4 DAY), 'Corporate'),
(2, 28000, DATE_SUB(NOW(), INTERVAL 5 DAY), 'Small biz'),
(2, 32000, DATE_SUB(NOW(), INTERVAL 6 DAY), 'Referral'),
(2, 22000, DATE_SUB(NOW(), INTERVAL 1 WEEK), 'Basic'),
(2, 38000, DATE_SUB(NOW(), INTERVAL 2 WEEK), 'Enterprise'),
(2, 27000, DATE_SUB(NOW(), INTERVAL 3 WEEK), 'Standard'),
(2, 33000, DATE_SUB(NOW(), INTERVAL 4 WEEK), 'Premium'),
(2, 18000, DATE_SUB(NOW(), INTERVAL 5 WEEK), 'Starter'),
(2, 32000, DATE_SUB(NOW(), INTERVAL 6 WEEK), 'Professional'),

-- Hari Thapa (Third place - 350,000 total, 10 deals)
(3, 45000, DATE_SUB(NOW(), INTERVAL 3 HOUR), 'Large client'),
(3, 38000, DATE_SUB(NOW(), INTERVAL 1 DAY), 'Mid-tier'),
(3, 42000, DATE_SUB(NOW(), INTERVAL 2 DAY), 'Corporate'),
(3, 30000, DATE_SUB(NOW(), INTERVAL 3 DAY), 'Standard'),
(3, 35000, DATE_SUB(NOW(), INTERVAL 4 DAY), 'Premium'),
(3, 28000, DATE_SUB(NOW(), INTERVAL 1 WEEK), 'Regular'),
(3, 40000, DATE_SUB(NOW(), INTERVAL 2 WEEK), 'Enterprise'),
(3, 33000, DATE_SUB(NOW(), INTERVAL 3 WEEK), 'Professional'),
(3, 29000, DATE_SUB(NOW(), INTERVAL 4 WEEK), 'Business'),
(3, 30000, DATE_SUB(NOW(), INTERVAL 5 WEEK), 'Standard'),

-- Geeta Gurung (260,000 total, 13 deals)
(4, 25000, DATE_SUB(NOW(), INTERVAL 4 HOUR), 'New account'),
(4, 22000, DATE_SUB(NOW(), INTERVAL 1 DAY), 'Renewal'),
(4, 18000, DATE_SUB(NOW(), INTERVAL 2 DAY), 'Upgrade'),
(4, 20000, DATE_SUB(NOW(), INTERVAL 3 DAY), 'Standard'),
(4, 24000, DATE_SUB(NOW(), INTERVAL 4 DAY), 'Premium'),
(4, 19000, DATE_SUB(NOW(), INTERVAL 5 DAY), 'Basic'),
(4, 21000, DATE_SUB(NOW(), INTERVAL 1 WEEK), 'Professional'),
(4, 23000, DATE_SUB(NOW(), INTERVAL 2 WEEK), 'Business'),
(4, 17000, DATE_SUB(NOW(), INTERVAL 3 WEEK), 'Starter'),
(4, 20000, DATE_SUB(NOW(), INTERVAL 4 WEEK), 'Standard'),
(4, 22000, DATE_SUB(NOW(), INTERVAL 5 WEEK), 'Mid-tier'),
(4, 15000, DATE_SUB(NOW(), INTERVAL 6 WEEK), 'Basic'),
(4, 14000, DATE_SUB(NOW(), INTERVAL 7 WEEK), 'Entry'),

-- Mohan Rai (235,000 total, 11 deals)
(5, 28000, DATE_SUB(NOW(), INTERVAL 5 HOUR), 'Corporate'),
(5, 22000, DATE_SUB(NOW(), INTERVAL 1 DAY), 'Business'),
(5, 25000, DATE_SUB(NOW(), INTERVAL 2 DAY), 'Professional'),
(5, 18000, DATE_SUB(NOW(), INTERVAL 3 DAY), 'Standard'),
(5, 20000, DATE_SUB(NOW(), INTERVAL 1 WEEK), 'Mid-tier'),
(5, 24000, DATE_SUB(NOW(), INTERVAL 2 WEEK), 'Premium'),
(5, 19000, DATE_SUB(NOW(), INTERVAL 3 WEEK), 'Regular'),
(5, 21000, DATE_SUB(NOW(), INTERVAL 4 WEEK), 'Business'),
(5, 23000, DATE_SUB(NOW(), INTERVAL 5 WEEK), 'Professional'),
(5, 17000, DATE_SUB(NOW(), INTERVAL 6 WEEK), 'Basic'),
(5, 18000, DATE_SUB(NOW(), INTERVAL 7 WEEK), 'Standard'),

-- Krishna Shrestha (180,000 total, 9 deals)
(6, 22000, DATE_SUB(NOW(), INTERVAL 6 HOUR), 'New client'),
(6, 18000, DATE_SUB(NOW(), INTERVAL 1 DAY), 'Renewal'),
(6, 25000, DATE_SUB(NOW(), INTERVAL 2 DAY), 'Upgrade'),
(6, 20000, DATE_SUB(NOW(), INTERVAL 1 WEEK), 'Standard'),
(6, 19000, DATE_SUB(NOW(), INTERVAL 2 WEEK), 'Professional'),
(6, 21000, DATE_SUB(NOW(), INTERVAL 3 WEEK), 'Business'),
(6, 17000, DATE_SUB(NOW(), INTERVAL 4 WEEK), 'Basic'),
(6, 20000, DATE_SUB(NOW(), INTERVAL 5 WEEK), 'Mid-tier'),
(6, 18000, DATE_SUB(NOW(), INTERVAL 6 WEEK), 'Regular'),

-- Sunita Tamang (155,000 total, 10 deals)
(7, 18000, DATE_SUB(NOW(), INTERVAL 7 HOUR), 'Standard'),
(7, 16000, DATE_SUB(NOW(), INTERVAL 1 DAY), 'Basic'),
(7, 14000, DATE_SUB(NOW(), INTERVAL 2 DAY), 'Starter'),
(7, 17000, DATE_SUB(NOW(), INTERVAL 1 WEEK), 'Professional'),
(7, 15000, DATE_SUB(NOW(), INTERVAL 2 WEEK), 'Regular'),
(7, 16000, DATE_SUB(NOW(), INTERVAL 3 WEEK), 'Business'),
(7, 13000, DATE_SUB(NOW(), INTERVAL 4 WEEK), 'Entry'),
(7, 15000, DATE_SUB(NOW(), INTERVAL 5 WEEK), 'Standard'),
(7, 16000, DATE_SUB(NOW(), INTERVAL 6 WEEK), 'Mid-tier'),
(7, 15000, DATE_SUB(NOW(), INTERVAL 7 WEEK), 'Basic');
```

---
const Database = require('better-sqlite3');
const path = require('path');
const fs = require('fs');

const dbDir = path.join(__dirname, '../../data');
const dbPath = path.join(dbDir, 'portfolio.db');

// 确保数据目录存在
if (!fs.existsSync(dbDir)) {
  fs.mkdirSync(dbDir, { recursive: true });
}

const db = new Database(dbPath);

// 启用外键约束
db.pragma('foreign_keys = ON');

// 创建持仓表
db.exec(`
  CREATE TABLE IF NOT EXISTS holdings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    symbol TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK(type IN ('stock', 'crypto', 'fund', 'other')),
    quantity REAL NOT NULL,
    avg_cost REAL,
    currency TEXT DEFAULT 'USD',
    exchange TEXT,
    category TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS prices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    symbol TEXT NOT NULL,
    price REAL NOT NULL,
    currency TEXT DEFAULT 'USD',
    source TEXT,
    fetched_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(symbol, fetched_at)
  );

  CREATE INDEX IF NOT EXISTS idx_prices_symbol ON prices(symbol);
  CREATE INDEX IF NOT EXISTS idx_prices_fetched_at ON prices(fetched_at);

  CREATE TABLE IF NOT EXISTS settings (
    key TEXT PRIMARY KEY,
    value TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );
`);

// 初始化默认设置
const initSettings = db.prepare(`
  INSERT OR IGNORE INTO settings (key, value) VALUES
    ('base_currency', 'USD'),
    ('theme', 'dark'),
    ('password', ''),
    ('update_interval', '300')
`);
initSettings.run();

// 持仓操作方法
const Holding = {
  getAll: () => {
    return db.prepare('SELECT * FROM holdings ORDER BY symbol').all();
  },

  getById: (id) => {
    return db.prepare('SELECT * FROM holdings WHERE id = ?').get(id);
  },

  getBySymbol: (symbol) => {
    return db.prepare('SELECT * FROM holdings WHERE symbol = ?').get(symbol);
  },

  create: (holding) => {
    const stmt = db.prepare(`
      INSERT INTO holdings (symbol, name, type, quantity, avg_cost, currency, exchange, category)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `);
    return stmt.run(
      holding.symbol,
      holding.name,
      holding.type,
      holding.quantity,
      holding.avg_cost,
      holding.currency || 'USD',
      holding.exchange || null,
      holding.category || null
    );
  },

  update: (id, holding) => {
    const stmt = db.prepare(`
      UPDATE holdings
      SET symbol = ?, name = ?, type = ?, quantity = ?, avg_cost = ?,
          currency = ?, exchange = ?, category = ?, updated_at = CURRENT_TIMESTAMP
      WHERE id = ?
    `);
    return stmt.run(
      holding.symbol,
      holding.name,
      holding.type,
      holding.quantity,
      holding.avg_cost,
      holding.currency || 'USD',
      holding.exchange || null,
      holding.category || null,
      id
    );
  },

  delete: (id) => {
    return db.prepare('DELETE FROM holdings WHERE id = ?').run(id);
  }
};

// 价格操作方法
const Price = {
  getLatest: (symbol) => {
    return db.prepare(`
      SELECT * FROM prices
      WHERE symbol = ?
      ORDER BY fetched_at DESC
      LIMIT 1
    `).get(symbol);
  },

  getAllLatest: () => {
    return db.prepare(`
      SELECT * FROM prices p1
      WHERE fetched_at = (
        SELECT MAX(fetched_at)
        FROM prices p2
        WHERE p2.symbol = p1.symbol
      )
      ORDER BY symbol
    `).all();
  },

  create: (price) => {
    const stmt = db.prepare(`
      INSERT INTO prices (symbol, price, currency, source)
      VALUES (?, ?, ?, ?)
    `);
    return stmt.run(price.symbol, price.price, price.currency || 'USD', price.source || 'API');
  },

  cleanOldPrices: (daysToKeep = 7) => {
    const stmt = db.prepare(`
      DELETE FROM prices
      WHERE fetched_at < datetime('now', '-' || ? || ' days')
    `);
    return stmt.run(daysToKeep);
  }
};

// 设置操作方法
const Setting = {
  get: (key) => {
    return db.prepare('SELECT value FROM settings WHERE key = ?').get(key);
  },

  set: (key, value) => {
    const stmt = db.prepare(`
      INSERT INTO settings (key, value) VALUES (?, ?)
      ON CONFLICT(key) DO UPDATE SET value = ?, updated_at = CURRENT_TIMESTAMP
    `);
    return stmt.run(key, value, value);
  },

  getAll: () => {
    return db.prepare('SELECT * FROM settings').all();
  }
};

module.exports = {
  db,
  Holding,
  Price,
  Setting
};

// 如果直接运行此文件，初始化示例数据
if (require.main === module) {
  console.log('初始化数据库...');

  // 插入示例持仓数据
  const sampleHoldings = [
    { symbol: 'BTC', name: 'Bitcoin', type: 'crypto', quantity: 4.86, currency: 'USD', category: '加密货币' },
    { symbol: 'TSLA', name: 'Tesla', type: 'stock', quantity: 300, currency: 'USD', exchange: 'NASDAQ', category: '电动汽车' },
    { symbol: 'XIACY', name: 'Xiaomi', type: 'stock', quantity: 1600, currency: 'USD', exchange: 'OTC', category: '消费电子' },
    { symbol: 'NVDA', name: 'NVIDIA', type: 'stock', quantity: 70, currency: 'USD', exchange: 'NASDAQ', category: '半导体' },
    { symbol: 'AMZN', name: 'Amazon', type: 'stock', quantity: 40, currency: 'USD', exchange: 'NASDAQ', category: '电商' },
    { symbol: 'NFLX', name: 'Netflix', type: 'stock', quantity: 30, currency: 'USD', exchange: 'NASDAQ', category: '流媒体' },
    { symbol: 'AAPL', name: 'Apple', type: 'stock', quantity: 45, currency: 'USD', exchange: 'NASDAQ', category: '消费电子' },
    { symbol: 'COIN', name: 'Coinbase', type: 'stock', quantity: 30, currency: 'USD', exchange: 'NASDAQ', category: '加密货币' },
    { symbol: 'CIRC', name: 'Circle', type: 'stock', quantity: 25, currency: 'USD', exchange: 'NYSE', category: '金融科技' },
    { symbol: 'MSFT', name: 'Microsoft', type: 'stock', quantity: 11, currency: 'USD', exchange: 'NASDAQ', category: '科技' },
    { symbol: 'CLSK', name: 'CleanSpark', type: 'stock', quantity: 135, currency: 'USD', exchange: 'NASDAQ', category: '比特币挖矿' },
    { symbol: '3690.HK', name: 'Meituan', type: 'stock', quantity: 200, currency: 'HKD', exchange: 'HKEX', category: '本地生活' },
    { symbol: 'HZNI', name: 'Horizon', type: 'stock', quantity: 3000, currency: 'USD', exchange: 'NASDAQ', category: 'AI科技' },
    { symbol: '3056.HK', name: 'PanFund HK3056', type: 'fund', quantity: 200, currency: 'HKD', exchange: 'HKEX', category: '基金' }
  ];

  sampleHoldings.forEach(holding => {
    try {
      Holding.create(holding);
      console.log(`✓ 添加持仓: ${holding.symbol}`);
    } catch (err) {
      if (err.message.includes('UNIQUE')) {
        console.log(`- 持仓已存在: ${holding.symbol}`);
      } else {
        console.error(`✗ 添加持仓失败: ${holding.symbol}`, err.message);
      }
    }
  });

  console.log('数据库初始化完成！');
  console.log(`数据库位置: ${dbPath}`);
}

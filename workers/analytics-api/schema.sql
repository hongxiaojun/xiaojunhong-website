-- Analytics Database Schema for Cloudflare D1
-- This schema tracks page views, podcast plays, and visitor statistics

-- Pages table: stores unique pages and their metadata
CREATE TABLE IF NOT EXISTS pages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    path TEXT NOT NULL UNIQUE,
    title TEXT,
    type TEXT DEFAULT 'page', -- 'page', 'article', 'podcast', 'note'
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Page views table: tracks individual page views
CREATE TABLE IF NOT EXISTS page_views (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    page_id INTEGER NOT NULL,
    session_id TEXT, -- Optional: for session tracking
    ip_hash TEXT, -- Hashed IP for unique visitor counting
    user_agent TEXT,
    referrer TEXT,
    country TEXT,
    device_type TEXT, -- 'mobile', 'tablet', 'desktop'
    browser TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (page_id) REFERENCES pages(id) ON DELETE CASCADE
);

-- Podcast plays table: tracks podcast audio plays
CREATE TABLE IF NOT EXISTS podcast_plays (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    page_id INTEGER NOT NULL,
    session_id TEXT,
    ip_hash TEXT,
    user_agent TEXT,
    play_duration INTEGER DEFAULT 0, -- Duration in seconds
    completed BOOLEAN DEFAULT FALSE, -- Whether the user listened to the end
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (page_id) REFERENCES pages(id) ON DELETE CASCADE
);

-- Daily stats table: aggregated daily statistics
CREATE TABLE IF NOT EXISTS daily_stats (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date DATE NOT NULL UNIQUE,
    total_visitors INTEGER DEFAULT 0,
    total_views INTEGER DEFAULT 0,
    total_plays INTEGER DEFAULT 0,
    unique_articles_viewed INTEGER DEFAULT 0,
    unique_podcasts_played INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_page_views_page_id ON page_views(page_id);
CREATE INDEX IF NOT EXISTS idx_page_views_created_at ON page_views(created_at);
CREATE INDEX IF NOT EXISTS idx_page_views_ip_hash ON page_views(ip_hash);
CREATE INDEX IF NOT EXISTS idx_podcast_plays_page_id ON podcast_plays(page_id);
CREATE INDEX IF NOT EXISTS idx_podcast_plays_created_at ON podcast_plays(created_at);
CREATE INDEX IF NOT EXISTS idx_daily_stats_date ON daily_stats(date);
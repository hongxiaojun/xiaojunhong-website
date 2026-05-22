/**
 * Cloudflare Workers Analytics API
 * Provides real-time statistics tracking for xiaojunhong.space
 */

export default {
  async fetch(request, env) {
    const corsHeaders = {
      'Access-Control-Allow-Origin': env.CORS_ORIGIN || '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    };

    // Handle CORS preflight requests
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    const url = new URL(request.url);
    const path = url.pathname;

    try {
      // Route: POST /api/track/pageview - Track page views
      if (path === '/api/track/pageview' && request.method === 'POST') {
        return await handlePageView(request, env, corsHeaders);
      }

      // Route: POST /api/track/podcast - Track podcast plays
      if (path === '/api/track/podcast' && request.method === 'POST') {
        return await handlePodcastPlay(request, env, corsHeaders);
      }

      // Route: GET /api/stats/page - Get page statistics
      if (path === '/api/stats/page' && request.method === 'GET') {
        return await getPageStats(url, env, corsHeaders);
      }

      // Route: GET /api/stats/total - Get total website statistics
      if (path === '/api/stats/total' && request.method === 'GET') {
        return await getTotalStats(env, corsHeaders);
      }

      // Route: GET /api/stats/podcast - Get podcast statistics
      if (path === '/api/stats/podcast' && request.method === 'GET') {
        return await getPodcastStats(url, env, corsHeaders);
      }

      // Route: GET /api/health - Health check
      if (path === '/api/health' && request.method === 'GET') {
        return jsonResponse({ status: 'ok', timestamp: new Date().toISOString() }, corsHeaders);
      }

      // 404 for unknown routes
      return jsonResponse({ error: 'Not found' }, corsHeaders, 404);

    } catch (error) {
      console.error('API Error:', error);
      return jsonResponse({ error: 'Internal server error', message: error.message }, corsHeaders, 500);
    }
  }
};

/**
 * Handle page view tracking
 */
async function handlePageView(request, env, corsHeaders) {
  const data = await request.json();
  const { path: pagePath, title, type = 'page', sessionId } = data;

  if (!pagePath) {
    return jsonResponse({ error: 'Path is required' }, corsHeaders, 400);
  }

  // Get client info
  const userAgent = request.headers.get('User-Agent') || '';
  const referrer = request.headers.get('Referer') || '';
  const cf = request.cf || {};
  const country = cf.country || null;

  // Simple device detection
  const deviceType = detectDeviceType(userAgent);
  const browser = detectBrowser(userAgent);

  // Generate IP hash for unique visitor tracking (privacy-focused)
  const ip = request.headers.get('CF-Connecting-IP') || 'unknown';
  const ipHash = await hashString(ip);

  // Use prepared statements for security and performance
  try {
    // First, ensure the page exists in our database
    await env.DB.prepare(`
      INSERT INTO pages (path, title, type)
      VALUES (?, ?, ?)
      ON CONFLICT(path) DO UPDATE SET
        title = COALESCE(excluded.title, pages.title),
        updated_at = CURRENT_TIMESTAMP
    `).bind(pagePath, title, type).run();

    // Get the page ID
    const pageResult = await env.DB.prepare(
      'SELECT id FROM pages WHERE path = ?'
    ).bind(pagePath).first();

    if (!pageResult) {
      throw new Error('Failed to create/find page');
    }

    // Check if this session has already viewed this page recently (prevent duplicate counting)
    const recentView = await env.DB.prepare(`
      SELECT id FROM page_views
      WHERE page_id = ? AND session_id = ?
      AND created_at > datetime('now', '-1 hour')
    `).bind(pageResult.id, sessionId).first();

    let isNewView = !recentView;

    // Only record if it's a new view (within the last hour)
    if (isNewView) {
      await env.DB.prepare(`
        INSERT INTO page_views (page_id, session_id, ip_hash, user_agent, referrer, country, device_type, browser)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      `).bind(pageResult.id, sessionId, ipHash, userAgent, referrer, country, deviceType, browser).run();
    }

    // Update daily stats
    await updateDailyStats(env.DB, 'view', isNewView);

    // Get updated view count
    const viewCount = await env.DB.prepare(`
      SELECT COUNT(*) as count FROM page_views WHERE page_id = ?
    `).bind(pageResult.id).first();

    return jsonResponse({
      success: true,
      isNewView,
      viewCount: viewCount.count,
      path: pagePath
    }, corsHeaders);

  } catch (error) {
    console.error('Page view error:', error);
    return jsonResponse({ error: 'Failed to track page view' }, corsHeaders, 500);
  }
}

/**
 * Handle podcast play tracking
 */
async function handlePodcastPlay(request, env, corsHeaders) {
  const data = await request.json();
  const { path: pagePath, sessionId, duration = 0, completed = false } = data;

  if (!pagePath) {
    return jsonResponse({ error: 'Path is required' }, corsHeaders, 400);
  }

  const userAgent = request.headers.get('User-Agent') || '';
  const ip = request.headers.get('CF-Connecting-IP') || 'unknown';
  const ipHash = await hashString(ip);

  try {
    // Ensure the page exists
    await env.DB.prepare(`
      INSERT INTO pages (path, type)
      VALUES (?, 'podcast')
      ON CONFLICT(path) DO UPDATE SET updated_at = CURRENT_TIMESTAMP
    `).bind(pagePath).run();

    const pageResult = await env.DB.prepare(
      'SELECT id FROM pages WHERE path = ?'
    ).bind(pagePath).first();

    if (!pageResult) {
      throw new Error('Failed to create/find podcast page');
    }

    // Check for recent plays from this session (prevent spamming)
    const recentPlay = await env.DB.prepare(`
      SELECT id FROM podcast_plays
      WHERE page_id = ? AND session_id = ?
      AND created_at > datetime('now', '-5 minutes')
    `).bind(pageResult.id, sessionId).first();

    let isNewPlay = !recentPlay;

    if (isNewPlay) {
      await env.DB.prepare(`
        INSERT INTO podcast_plays (page_id, session_id, ip_hash, user_agent, play_duration, completed)
        VALUES (?, ?, ?, ?, ?, ?)
      `).bind(pageResult.id, sessionId, ipHash, userAgent, duration, completed).run();
    }

    // Update daily stats
    await updateDailyStats(env.DB, 'play', isNewPlay);

    // Get total play count
    const playCount = await env.DB.prepare(`
      SELECT COUNT(*) as count FROM podcast_plays WHERE page_id = ?
    `).bind(pageResult.id).first();

    return jsonResponse({
      success: true,
      isNewPlay,
      playCount: playCount.count,
      path: pagePath
    }, corsHeaders);

  } catch (error) {
    console.error('Podcast play error:', error);
    return jsonResponse({ error: 'Failed to track podcast play' }, corsHeaders, 500);
  }
}

/**
 * Get page statistics
 */
async function getPageStats(url, env, corsHeaders) {
  const pagePath = url.searchParams.get('path');

  if (!pagePath) {
    return jsonResponse({ error: 'Path parameter is required' }, corsHeaders, 400);
  }

  try {
    const pageResult = await env.DB.prepare(`
      SELECT p.*,
             (SELECT COUNT(*) FROM page_views WHERE page_id = p.id) as views,
             (SELECT COUNT(DISTINCT ip_hash) FROM page_views WHERE page_id = p.id) as unique_visitors
      FROM pages p
      WHERE p.path = ?
    `).bind(pagePath).first();

    if (!pageResult) {
      return jsonResponse({ views: 0, uniqueVisitors: 0 }, corsHeaders);
    }

    return jsonResponse({
      path: pagePath,
      views: pageResult.views || 0,
      uniqueVisitors: pageResult.unique_visitors || 0,
      title: pageResult.title,
      type: pageResult.type
    }, corsHeaders);

  } catch (error) {
    console.error('Get page stats error:', error);
    return jsonResponse({ error: 'Failed to get page statistics' }, corsHeaders, 500);
  }
}

/**
 * Get total website statistics
 */
async function getTotalStats(env, corsHeaders) {
  try {
    // Get totals from database
    const totalViews = await env.DB.prepare(
      'SELECT COUNT(*) as count FROM page_views'
    ).first();

    const uniqueVisitors = await env.DB.prepare(
      'SELECT COUNT(DISTINCT ip_hash) as count FROM page_views'
    ).first();

    const totalPlays = await env.DB.prepare(
      'SELECT COUNT(*) as count FROM podcast_plays'
    ).first();

    const uniquePages = await env.DB.prepare(
      'SELECT COUNT(DISTINCT page_id) as count FROM page_views'
    ).first();

    // Get today's stats
    const todayViews = await env.DB.prepare(`
      SELECT COUNT(*) as count FROM page_views
      WHERE date(created_at) = date('now')
    `).first();

    return jsonResponse({
      totalViews: totalViews.count || 0,
      uniqueVisitors: uniqueVisitors.count || 0,
      totalPlays: totalPlays.count || 0,
      uniquePagesViewed: uniquePages.count || 0,
      todayViews: todayViews.count || 0,
      timestamp: new Date().toISOString()
    }, corsHeaders);

  } catch (error) {
    console.error('Get total stats error:', error);
    return jsonResponse({ error: 'Failed to get total statistics' }, corsHeaders, 500);
  }
}

/**
 * Get podcast statistics
 */
async function getPodcastStats(url, env, corsHeaders) {
  const pagePath = url.searchParams.get('path');

  if (!pagePath) {
    return jsonResponse({ error: 'Path parameter is required' }, corsHeaders, 400);
  }

  try {
    const stats = await env.DB.prepare(`
      SELECT
        COUNT(*) as total_plays,
        COUNT(DISTINCT ip_hash) as unique_listeners,
        AVG(play_duration) as avg_duration,
        SUM(CASE WHEN completed = 1 THEN 1 ELSE 0 END) as completed_listens
      FROM podcast_plays
      WHERE page_id = (SELECT id FROM pages WHERE path = ?)
    `).bind(pagePath).first();

    return jsonResponse({
      path: pagePath,
      totalPlays: stats.total_plays || 0,
      uniqueListeners: stats.unique_listeners || 0,
      avgDuration: Math.round(stats.avg_duration || 0),
      completedListens: stats.completed_listens || 0
    }, corsHeaders);

  } catch (error) {
    console.error('Get podcast stats error:', error);
    return jsonResponse({ error: 'Failed to get podcast statistics' }, corsHeaders, 500);
  }
}

/**
 * Update daily statistics
 */
async function updateDailyStats(db, type, isNew) {
  if (!isNew) return; // Only update for unique actions

  const today = new Date().toISOString().split('T')[0];

  try {
    await db.prepare(`
      INSERT INTO daily_stats (date)
      VALUES (?)
      ON CONFLICT(date) DO UPDATE SET updated_at = CURRENT_TIMESTAMP
    `).bind(today).run();

    if (type === 'view') {
      await db.prepare(`
        UPDATE daily_stats
        SET total_views = total_views + 1,
            unique_articles_viewed = (SELECT COUNT(DISTINCT page_id) FROM page_views)
        WHERE date = ?
      `).bind(today).run();
    } else if (type === 'play') {
      await db.prepare(`
        UPDATE daily_stats
        SET total_plays = total_plays + 1,
            unique_podcasts_played = (SELECT COUNT(DISTINCT page_id) FROM podcast_plays)
        WHERE date = ?
      `).bind(today).run();
    }

    // Update total visitors
    await db.prepare(`
      UPDATE daily_stats
      SET total_visitors = (SELECT COUNT(DISTINCT ip_hash) FROM page_views)
      WHERE date = ?
    `).bind(today).run();

  } catch (error) {
    console.error('Update daily stats error:', error);
    // Don't throw - stats updates shouldn't break the main functionality
  }
}

/**
 * Helper functions
 */

// Simple hash function for IP addresses (SHA-256)
async function hashString(str) {
  const encoder = new TextEncoder();
  const data = encoder.encode(str);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

// Detect device type from user agent
function detectDeviceType(userAgent) {
  const ua = userAgent.toLowerCase();
  if (/mobile|android|iphone|ipod|blackberry|opera mini|iemobile|wpdesktop/i.test(ua)) {
    return 'mobile';
  } else if (/tablet|ipad|kindle|silk|iplaybook|tablet/i.test(ua)) {
    return 'tablet';
  }
  return 'desktop';
}

// Detect browser from user agent
function detectBrowser(userAgent) {
  const ua = userAgent.toLowerCase();
  if (/chrome|crios/i.test(ua) && !/edge|opr|brave/i.test(ua)) return 'Chrome';
  if (/firefox/i.test(ua)) return 'Firefox';
  if (/safari/i.test(ua) && !/chrome/i.test(ua)) return 'Safari';
  if (/edge/i.test(ua)) return 'Edge';
  if (/opr|opera/i.test(ua)) return 'Opera';
  if (/brave/i.test(ua)) return 'Brave';
  return 'Other';
}

// JSON response helper
function jsonResponse(data, corsHeaders, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });
}
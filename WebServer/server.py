#!/usr/bin/env python3
"""
OpenLife Reborn - Modern Stats Web Server
Fetches stats from the official site and displays them beautifully.
"""

from flask import Flask, render_template_string, jsonify
import requests
from bs4 import BeautifulSoup
import os
import time
from functools import lru_cache

app = Flask(__name__)

# Configuration
OPENLIFE_URL = os.environ.get('OPENLIFE_URL', 'http://openlifereborn.com')
REFRESH_INTERVAL = 60  # seconds

# Cache for stats
_stats_cache = {'data': None, 'timestamp': 0}


def fetch_stats():
    """Fetch stats from the OpenLife website."""
    global _stats_cache
    
    # Return cached data if fresh enough
    if _stats_cache['data'] and (time.time() - _stats_cache['timestamp']) < REFRESH_INTERVAL:
        return _stats_cache['data']
    
    try:
        response = requests.get(OPENLIFE_URL, timeout=10)
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # Parse the stats from the HTML
        stats = parse_stats(soup)
        
        _stats_cache = {'data': stats, 'timestamp': time.time()}
        return stats
    except Exception as e:
        print(f"Error fetching stats: {e}")
        return _stats_cache['data'] or {}


def parse_stats(soup):
    """Parse statistics from the HTML."""
    stats = {}
    
    # Find all tables and extract data
    tables = soup.find_all('table')
    
    # Extract general stats (Currently Playing, AIs, Season, etc.)
    text = soup.get_text()
    
    # Parse Currently Playing
    if 'Currently Playing:' in text:
        for line in text.split('\n'):
            if 'Currently Playing:' in line:
                stats['players'] = line.split('Currently Playing:')[1].strip().split()[0]
            if 'AIs:' in line:
                stats['ais'] = line.split('AIs:')[1].strip().split()[0]
            if 'Starving:' in line:
                stats['starving'] = line.split('Starving:')[1].strip().split()[0]
            if 'Season:' in line:
                stats['season'] = line.split('Season:')[1].strip()
            if 'Score:' in line and 'count:' in line:
                try:
                    score_line = line.split('Score:')[1].strip()
                    stats['total_score'] = score_line.split('count:')[1].strip().split()[0]
                    stats['human_score'] = score_line.split('human:')[1].strip().split()[0]
                except:
                    pass
    
    # Parse player table (first table after "NameAgePrestigePowerGeneration")
    players = []
    if len(tables) > 0:
        rows = tables[0].find_all('tr')
        for row in rows[1:]:  # Skip header
            cols = row.find_all(['td', 'th'])
            if len(cols) >= 5:
                player = {
                    'name': cols[0].get_text(strip=True),
                    'age': cols[1].get_text(strip=True),
                    'prestige': cols[2].get_text(strip=True),
                    'power': cols[3].get_text(strip=True),
                    'generation': cols[4].get_text(strip=True)
                }
                if player['name']:
                    players.append(player)
    stats['players_list'] = players[:20]  # Top 20
    
    # Parse leaderboard (IDPrestigeFemale PrestigeMale PrestigeCoins)
    leaderboard = []
    if len(tables) > 1:
        rows = tables[1].find_all('tr')
        for row in rows[1:]:
            cols = row.find_all(['td', 'th'])
            if len(cols) >= 4:
                entry = {
                    'name': cols[0].get_text(strip=True),
                    'prestige_female': cols[1].get_text(strip=True),
                    'prestige_male': cols[2].get_text(strip=True),
                    'coins': cols[3].get_text(strip=True)
                }
                if entry['name']:
                    leaderboard.append(entry)
    stats['leaderboard'] = leaderboard[:20]
    
    # Parse food statistics
    food_stats = []
    if len(tables) > 2:
        rows = tables[2].find_all('tr')
        for row in rows[1:]:
            cols = row.find_all(['td', 'th'])
            if len(cols) >= 2:
                food_stats.append({
                    'food': cols[0].get_text(strip=True),
                    'percent': cols[1].get_text(strip=True)
                })
    stats['food'] = food_stats[:15]
    
    # Parse death causes
    deaths = []
    if len(tables) > 3:
        rows = tables[3].find_all('tr')
        for row in rows[1:]:
            cols = row.find_all(['td', 'th'])
            if len(cols) >= 4:
                deaths.append({
                    'cause': cols[0].get_text(strip=True),
                    'total': cols[1].get_text(strip=True),
                    'last_day': cols[2].get_text(strip=True),
                    'last_hour': cols[3].get_text(strip=True)
                })
    stats['deaths'] = deaths[:15]
    
    return stats


# HTML Template with modern design
HTML_TEMPLATE = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OpenLife Reborn - Statistics</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-primary: #0f0f13;
            --bg-secondary: #1a1a24;
            --bg-card: #22222e;
            --accent: #7c5cff;
            --accent-hover: #9473ff;
            --text-primary: #ffffff;
            --text-secondary: #a0a0b0;
            --text-muted: #6b6b7b;
            --border: #2a2a3a;
            --success: #4ade80;
            --warning: #fbbf24;
            --danger: #f87171;
            --info: #60a5fa;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: var(--bg-primary);
            color: var(--text-primary);
            min-height: 100vh;
            line-height: 1.6;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 2rem;
        }
        
        header {
            text-align: center;
            margin-bottom: 3rem;
            padding: 2rem 0;
            border-bottom: 1px solid var(--border);
        }
        
        h1 {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
            background: linear-gradient(135deg, var(--accent) 0%, #a78bfa 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        .subtitle {
            color: var(--text-secondary);
            font-size: 1rem;
        }
        
        .status-bar {
            display: flex;
            justify-content: center;
            gap: 2rem;
            flex-wrap: wrap;
            margin-bottom: 2rem;
        }
        
        .status-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 1.25rem 2rem;
            text-align: center;
            min-width: 140px;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        
        .status-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(124, 92, 255, 0.15);
        }
        
        .status-value {
            font-size: 2rem;
            font-weight: 700;
            color: var(--accent);
        }
        
        .status-label {
            font-size: 0.875rem;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        
        .season-badge {
            display: inline-block;
            padding: 0.25rem 1rem;
            border-radius: 20px;
            font-size: 0.875rem;
            font-weight: 500;
        }
        
        .season-spring { background: #22c55e20; color: #22c55e; }
        .season-summer { background: #f59e0b20; color: #f59e0b; }
        .season-autumn { background: #f9731620; color: #f97316; }
        .season-winter { background: #3b82f620; color: #3b82f6; }
        
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 1.5rem;
            margin-top: 2rem;
        }
        
        .card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 12px;
            overflow: hidden;
        }
        
        .card-header {
            padding: 1rem 1.5rem;
            border-bottom: 1px solid var(--border);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .card-title {
            font-size: 1.125rem;
            font-weight: 600;
        }
        
        .card-body {
            padding: 0;
            overflow-x: auto;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.875rem;
        }
        
        th, td {
            padding: 0.75rem 1rem;
            text-align: left;
            border-bottom: 1px solid var(--border);
        }
        
        th {
            background: var(--bg-secondary);
            font-weight: 500;
            color: var(--text-secondary);
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.05em;
        }
        
        tr:hover {
            background: var(--bg-secondary);
        }
        
        .rank {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 24px;
            height: 24px;
            border-radius: 6px;
            font-size: 0.75rem;
            font-weight: 600;
            margin-right: 0.5rem;
        }
        
        .rank-1 { background: #fbbf24; color: #000; }
        .rank-2 { background: #94a3b8; color: #000; }
        .rank-3 { background: #cd7f32; color: #000; }
        
        .player-name {
            font-weight: 500;
            color: var(--text-primary);
        }
        
        .player-class {
            font-size: 0.75rem;
            padding: 0.125rem 0.5rem;
            border-radius: 4px;
            margin-left: 0.5rem;
        }
        
        .class-noble { background: #fbbf2420; color: #fbbf24; }
        .class-commoner { background: #3b82f620; color: #3b82f6; }
        .class-serf { background: #6b728020; color: #9ca3af; }
        
        .prestige {
            color: var(--success);
            font-weight: 600;
        }
        
        .coins {
            color: #fbbf24;
            font-weight: 500;
        }
        
        footer {
            text-align: center;
            padding: 2rem;
            color: var(--text-muted);
            font-size: 0.875rem;
            border-top: 1px solid var(--border);
            margin-top: 3rem;
        }
        
        .last-updated {
            color: var(--text-muted);
            font-size: 0.75rem;
        }
        
        @media (max-width: 768px) {
            .container { padding: 1rem; }
            h1 { font-size: 1.75rem; }
            .status-bar { gap: 1rem; }
            .status-card { min-width: 100px; padding: 1rem; }
            .grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>OpenLife Reborn</h1>
            <p class="subtitle">Live Server Statistics</p>
        </header>
        
        <div class="status-bar">
            <div class="status-card">
                <div class="status-value">{{ stats.players or '0' }}</div>
                <div class="status-label">Players Online</div>
            </div>
            <div class="status-card">
                <div class="status-value">{{ stats.ais or '0' }}</div>
                <div class="status-label">AIs Active</div>
            </div>
            <div class="status-card">
                <div class="status-value">{{ stats.starving or '0' }}</div>
                <div class="status-label">Starving</div>
            </div>
            <div class="status-card">
                <div class="status-value">
                    <span class="season-badge season-{{ stats.season|lower if stats.season else 'spring' }}">{{ stats.season or 'Unknown' }}</span>
                </div>
                <div class="status-label">Current Season</div>
            </div>
            <div class="status-card">
                <div class="status-value">{{ stats.total_score or '0' }}</div>
                <div class="status-label">Total Score</div>
            </div>
        </div>
        
        <div class="grid">
            <div class="card">
                <div class="card-header">
                    <span class="card-title">👥 Online Players</span>
                </div>
                <div class="card-body">
                    <table>
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Age</th>
                                <th>Prestige</th>
                                <th>Power</th>
                            </tr>
                        </thead>
                        <tbody>
                            {% for player in stats.players_list[:15] %}
                            <tr>
                                <td>
                                    <span class="player-name">{{ player.name }}</span>
                                </td>
                                <td>{{ player.age }}</td>
                                <td class="prestige">{{ player.prestige }}</td>
                                <td>{{ player.power }}</td>
                            </tr>
                            {% else %}
                            <tr>
                                <td colspan="4" style="text-align: center; color: var(--text-muted);">No players online</td>
                            </tr>
                            {% endfor %}
                        </tbody>
                    </table>
                </div>
            </div>
            
            <div class="card">
                <div class="card-header">
                    <span class="card-title">🏆 Leaderboard</span>
                </div>
                <div class="card-body">
                    <table>
                        <thead>
                            <tr>
                                <th>Rank</th>
                                <th>Name</th>
                                <th>Prestige</th>
                                <th>Coins</th>
                            </tr>
                        </thead>
                        <tbody>
                            {% for entry in stats.leaderboard[:15] %}
                            <tr>
                                <td>
                                    {% if loop.index == 1 %}<span class="rank rank-1">1</span>
                                    {% elif loop.index == 2 %}<span class="rank rank-2">2</span>
                                    {% elif loop.index == 3 %}<span class="rank rank-3">3</span>
                                    {% else %}{{ loop.index }}{% endif %}
                                </td>
                                <td class="player-name">{{ entry.name }}</td>
                                <td class="prestige">{{ entry.prestige_female }}/{{ entry.prestige_male }}</td>
                                <td class="coins">{{ entry.coins }}</td>
                            </tr>
                            {% endfor %}
                        </tbody>
                    </table>
                </div>
            </div>
            
            <div class="card">
                <div class="card-header">
                    <span class="card-title">🍖 Food Statistics</span>
                </div>
                <div class="card-body">
                    <table>
                        <thead>
                            <tr>
                                <th>Food</th>
                                <th>% Eaten</th>
                            </tr>
                        </thead>
                        <tbody>
                            {% for food in stats.food[:12] %}
                            <tr>
                                <td>{{ food.food }}</td>
                                <td>{{ food.percent }}</td>
                            </tr>
                            {% endfor %}
                        </tbody>
                    </table>
                </div>
            </div>
            
            <div class="card">
                <div class="card-header">
                    <span class="card-title">💀 Death Causes</span>
                </div>
                <div class="card-body">
                    <table>
                        <thead>
                            <tr>
                                <th>Cause</th>
                                <th>Total</th>
                                <th>Last Day</th>
                                <th>Last Hour</th>
                            </tr>
                        </thead>
                        <tbody>
                            {% for death in stats.deaths[:12] %}
                            <tr>
                                <td>{{ death.cause }}</td>
                                <td>{{ death.total }}</td>
                                <td>{{ death.last_day }}</td>
                                <td>{{ death.last_hour }}</td>
                            </tr>
                            {% endfor %}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
        <footer>
            <p>OpenLife Reborn - A community-driven OneHourOneLife server</p>
            <p class="last-updated">Stats automatically refresh every 60 seconds</p>
        </footer>
    </div>
    
    <script>
        // Auto-refresh every 60 seconds
        setTimeout(() => window.location.reload(), 60000);
    </script>
</body>
</html>
'''


@app.route('/')
def index():
    stats = fetch_stats()
    return render_template_string(HTML_TEMPLATE, stats=stats)


@app.route('/api/stats')
def api_stats():
    """JSON API for stats."""
    stats = fetch_stats()
    return jsonify(stats)


@app.route('/health')
def health():
    return jsonify({'status': 'ok'})


if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    print(f"Starting OpenLife Reborn Stats Server on port {port}...")
    app.run(host='0.0.0.0', port=port, debug=False)

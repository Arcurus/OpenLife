# OpenLife Reborn - Modern Web Server

A modern, beautiful stats dashboard for OpenLife Reborn server.

## Setup

```bash
# Install dependencies
pip install flask requests beautifulsoup4

# Run the server
python server.py
```

## Features

- Modern dark theme UI
- Real-time stats updates
- Beautiful data visualizations
- Responsive design
- Player leaderboards
- Game statistics (deaths, food, ages)
- Season and AI status

## Configuration

Edit `server.py` to set:
- `OPENLIFE_URL`: Base URL of the OpenLife server (default: http://openlifereborn.com)
- `REFRESH_INTERVAL`: How often to fetch new stats (default: 60 seconds)
- `PORT`: Server port (default: 5000)

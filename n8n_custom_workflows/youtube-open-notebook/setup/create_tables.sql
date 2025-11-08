-- AI LaunchKit: YouTube to Open Notebook - Table Setup
-- This script can be used if you prefer SQL over UI
-- Execute with: cat create_tables.sql | docker exec -i postgres psql -U postgres -d postgres

-- Note: n8n uses the 'postgres' database in AI LaunchKit (not a separate 'n8n' database)
-- This SQL creates the underlying PostgreSQL tables if you prefer automation

BEGIN;

-- Create youtube_channels table
CREATE TABLE IF NOT EXISTS youtube_channels (
  id SERIAL PRIMARY KEY,
  channel_id TEXT UNIQUE NOT NULL,
  channel_name TEXT NOT NULL,
  channel_url TEXT NOT NULL,
  original_language TEXT NOT NULL,
  enabled BOOLEAN NOT NULL DEFAULT true,
  notebook_name TEXT NOT NULL,
  notebook_id TEXT,
  last_sync TIMESTAMP WITH TIME ZONE,
  video_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create youtube_videos table
CREATE TABLE IF NOT EXISTS youtube_videos (
  id SERIAL PRIMARY KEY,
  video_id TEXT UNIQUE NOT NULL,
  channel_id TEXT NOT NULL,
  title TEXT NOT NULL,
  url TEXT NOT NULL,
  duration_seconds INTEGER NOT NULL,
  published_date TIMESTAMP WITH TIME ZONE NOT NULL,
  thumbnail_url TEXT,
  detected_language TEXT,
  needs_translation BOOLEAN DEFAULT false,
  status TEXT NOT NULL DEFAULT 'discovered',
  skip_reason TEXT,
  notebook_entry_url TEXT,
  discovered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  processed_at TIMESTAMP WITH TIME ZONE,
  error_message TEXT,
  
  -- Foreign key to channels
  CONSTRAINT fk_channel 
    FOREIGN KEY (channel_id) 
    REFERENCES youtube_channels(channel_id)
    ON DELETE CASCADE
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_youtube_videos_channel_status 
  ON youtube_videos(channel_id, status);

CREATE INDEX IF NOT EXISTS idx_youtube_videos_status 
  ON youtube_videos(status);

CREATE INDEX IF NOT EXISTS idx_youtube_videos_discovered 
  ON youtube_videos(discovered_at DESC);

-- Insert example channels (optional - comment out if not needed)
INSERT INTO youtube_channels (
  channel_id, 
  channel_name, 
  channel_url, 
  original_language, 
  enabled, 
  notebook_name
) VALUES 
  (
    'UCXuqSBlHAE6Xw-yeJA0Tunw',
    'Linus Tech Tips',
    'youtube.com/@LinusTechTips',
    'en',
    true,
    'YT: Linus Tech Tips'
  ),
  (
    'UCZYTClx2T1of7BRZ86-8fow',
    'SciShow',
    'youtube.com/@SciShow',
    'en',
    true,
    'YT: SciShow'
  )
ON CONFLICT (channel_id) DO NOTHING;

COMMIT;

-- Verify tables were created
SELECT 'youtube_channels' as table_name, count(*) as row_count FROM youtube_channels
UNION ALL
SELECT 'youtube_videos', count(*) FROM youtube_videos;

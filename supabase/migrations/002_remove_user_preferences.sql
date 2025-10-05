-- Remove user_preferences table as it's no longer needed
-- The chat system now uses user_medical_preferences directly

-- Drop the index first
DROP INDEX IF EXISTS idx_user_preferences_user_id;

-- Drop the table
DROP TABLE IF EXISTS user_preferences;
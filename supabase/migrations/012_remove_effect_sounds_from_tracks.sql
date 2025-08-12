-- Remove E001-E006 effect sounds from tracks table
-- These should only be used in the app's nature sound selector, not as regular tracks

-- Delete effect sound tracks from tracks table
DELETE FROM tracks WHERE code IN ('E001', 'E002', 'E003', 'E004', 'E005', 'E006');

-- Remove any theme-track relationships for these effect sounds
DELETE FROM theme_tracks WHERE track_id IN (
  SELECT id FROM tracks WHERE code IN ('E001', 'E002', 'E003', 'E004', 'E005', 'E006')
);

-- Remove any track-keyword relationships for these effect sounds
DELETE FROM track_keywords WHERE track_id IN (
  SELECT id FROM tracks WHERE code IN ('E001', 'E002', 'E003', 'E004', 'E005', 'E006')
);
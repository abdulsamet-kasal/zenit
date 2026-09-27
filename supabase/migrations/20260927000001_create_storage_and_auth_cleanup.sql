-- 20260927000001_create_storage_and_auth_cleanup.sql
-- Storage bucket for complaint photos and RLS policies

-- 1. Create complaint-photos bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'complaint-photos',
    'complaint-photos',
    true,
    10485760, -- 10MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg']
)
ON CONFLICT (id) DO UPDATE SET
    public = true,
    file_size_limit = 10485760,
    allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg'];

-- 2. Storage policies
DROP POLICY IF EXISTS "Public complaint photos are viewable by everyone" ON storage.objects;
CREATE POLICY "Public complaint photos are viewable by everyone"
ON storage.objects FOR SELECT
USING (bucket_id = 'complaint-photos');

DROP POLICY IF EXISTS "Anyone can upload complaint photos" ON storage.objects;
CREATE POLICY "Anyone can upload complaint photos"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'complaint-photos');

DROP POLICY IF EXISTS "Users can update their complaint photos" ON storage.objects;
CREATE POLICY "Users can update their complaint photos"
ON storage.objects FOR UPDATE
USING (bucket_id = 'complaint-photos');

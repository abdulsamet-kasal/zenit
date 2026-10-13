-- ==========================================
-- 20261013000000_harden_public_rls.sql
-- Herkese açık (anon) yazma/silme politikalarını sıkılaştırma
--
-- Sorun: complaints / likes / confirmations / comments / disputes /
-- citizen_profiles tablolarında `USING (true)` / `WITH CHECK (true)`
-- ile anon her satırı yazıp silebiliyordu. Bu migration:
--  1. Anon'a yalnızca okuma (SELECT) bırakır.
--  2. INSERT'leri giriş yapmış kullanıcılarla (authenticated) sınırlar
--     ve author_id/user_id = auth.uid() koşulu koyar.
--  3. UPDATE/DELETE'i yalnızca kaydın sahibine verir.
--  4. citizen_profiles'ta kullanıcının yalnızca kendi satırını
--     okuyup yazmasına izin verir.
--
-- NOT: complaints.author_id TEXT tutuluyor (auth.uid() UUID).
-- Karşılaştırma için ::text dönüşümü yapılır.
-- Uygulama signUp'ta citizen_profiles.user_id = auth uid yazdığı için
-- bu migration mevcut akışla uyumludur.
-- ==========================================

-- ---------- COMPLAINTS ----------
DROP POLICY IF EXISTS "Public insert access for complaints" ON public.complaints;
DROP POLICY IF EXISTS "Update complaints access" ON public.complaints;
DROP POLICY IF EXISTS "Public delete access for complaints" ON public.complaints;
DROP POLICY IF EXISTS "Delete own complaint access" ON public.complaints;

-- Okuma herkese açık kalır (anon SELECT politikası ilk migration'da var).
-- Yazma: yalnızca giriş yapmış kullanıcı, kendi author_id'si ile.
CREATE POLICY "Authenticated users can insert own complaints"
    ON public.complaints FOR INSERT
    TO authenticated
    WITH CHECK (author_id = (auth.uid())::text);

-- Güncelleme: yalnızca kaydın sahibi.
CREATE POLICY "Owners can update own complaints"
    ON public.complaints FOR UPDATE
    TO authenticated
    USING (author_id = (auth.uid())::text)
    WITH CHECK (author_id = (auth.uid())::text);

-- Silme: yalnızca kaydın sahibi.
CREATE POLICY "Owners can delete own complaints"
    ON public.complaints FOR DELETE
    TO authenticated
    USING (author_id = (auth.uid())::text);

-- ---------- COMPLAINT LIKES ----------
DROP POLICY IF EXISTS "Public insert likes" ON public.complaint_likes;
DROP POLICY IF EXISTS "Public delete likes" ON public.complaint_likes;

CREATE POLICY "Authenticated users can insert own likes"
    ON public.complaint_likes FOR INSERT
    TO authenticated
    WITH CHECK (user_id = (auth.uid())::text);

CREATE POLICY "Users can delete own likes"
    ON public.complaint_likes FOR DELETE
    TO authenticated
    USING (user_id = (auth.uid())::text);

-- ---------- COMPLAINT CONFIRMATIONS ----------
DROP POLICY IF EXISTS "Public insert confirmations" ON public.complaint_confirmations;
DROP POLICY IF EXISTS "Public delete confirmations" ON public.complaint_confirmations;

CREATE POLICY "Authenticated users can insert own confirmations"
    ON public.complaint_confirmations FOR INSERT
    TO authenticated
    WITH CHECK (user_id = (auth.uid())::text);

CREATE POLICY "Users can delete own confirmations"
    ON public.complaint_confirmations FOR DELETE
    TO authenticated
    USING (user_id = (auth.uid())::text);

-- ---------- COMMENTS ----------
DROP POLICY IF EXISTS "Public insert comments" ON public.complaint_comments;

CREATE POLICY "Authenticated users can insert own comments"
    ON public.complaint_comments FOR INSERT
    TO authenticated
    WITH CHECK (author_id = (auth.uid())::text);

-- ---------- DISPUTES ----------
DROP POLICY IF EXISTS "Public insert disputes" ON public.complaint_disputes;

CREATE POLICY "Authenticated users can insert own disputes"
    ON public.complaint_disputes FOR INSERT
    TO authenticated
    WITH CHECK (author_id = (auth.uid())::text);

-- ---------- CITIZEN PROFILES ----------
DROP POLICY IF EXISTS "Public read profiles" ON public.citizen_profiles;
DROP POLICY IF EXISTS "Public write profiles" ON public.citizen_profiles;

-- Her kullanıcı yalnızca kendi profil satırını okur/yazar.
CREATE POLICY "Users can read own profile"
    ON public.citizen_profiles FOR SELECT
    TO authenticated
    USING (user_id = (auth.uid())::text);

CREATE POLICY "Users can insert own profile"
    ON public.citizen_profiles FOR INSERT
    TO authenticated
    WITH CHECK (user_id = (auth.uid())::text);

CREATE POLICY "Users can update own profile"
    ON public.citizen_profiles FOR UPDATE
    TO authenticated
    USING (user_id = (auth.uid())::text)
    WITH CHECK (user_id = (auth.uid())::text);

CREATE POLICY "Users can delete own profile"
    ON public.citizen_profiles FOR DELETE
    TO authenticated
    USING (user_id = (auth.uid())::text);

-- ---------- STORAGE: complaint-photos ----------
-- Herkese açık okuma kalır; yazma giriş yapmış kullanıcıya iner.
DROP POLICY IF EXISTS "Anyone can upload complaint photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their complaint photos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload complaint photos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update complaint photos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete own complaint photos" ON storage.objects;

CREATE POLICY "Authenticated users can upload complaint photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'complaint-photos');

CREATE POLICY "Authenticated users can update complaint photos"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'complaint-photos');

CREATE POLICY "Authenticated users can delete own complaint photos"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'complaint-photos' AND owner = auth.uid());

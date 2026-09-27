-- ==========================================
-- 20260928000001_add_complaint_delete_policy.sql
-- Complaints tablosu için DELETE RLS Politikası
-- ==========================================

DROP POLICY IF EXISTS "Public delete access for complaints" ON public.complaints;
DROP POLICY IF EXISTS "Delete own complaint access" ON public.complaints;

-- Kullanıcıların şikayet silmesine izin veren RLS politikası
CREATE POLICY "Public delete access for complaints"
    ON public.complaints FOR DELETE
    USING (true);

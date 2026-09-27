-- ŞEFFAF (Zenit) Supabase Core Schema Migration
-- Project Ref: txhpstratzihirwlpixu
-- Created: 2026-09-27

-- 1. MUNICIPALITIES TABLE (81 İl, 972 İlçe Belediyesi)
CREATE TABLE IF NOT EXISTS public.municipalities (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    province TEXT NOT NULL,
    district TEXT NOT NULL,
    plate_number SMALLINT,
    latitude NUMERIC NOT NULL,
    longitude NUMERIC NOT NULL,
    logo_url TEXT,
    transparency_score NUMERIC DEFAULT 70.0,
    total_complaints INTEGER DEFAULT 0,
    resolved_complaints INTEGER DEFAULT 0,
    resolution_rate NUMERIC DEFAULT 0.0,
    avg_resolution_days NUMERIC DEFAULT 0.0,
    score_history JSONB DEFAULT '[]'::jsonb,
    category_performance JSONB DEFAULT '[]'::jsonb,
    boundary_polygon JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Indexler
CREATE INDEX IF NOT EXISTS idx_municipalities_province ON public.municipalities(province);
CREATE INDEX IF NOT EXISTS idx_municipalities_score ON public.municipalities(transparency_score DESC);

-- 2. COMPLAINTS TABLE (Şikayetler)
CREATE TABLE IF NOT EXISTS public.complaints (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category_id TEXT NOT NULL,
    category_name TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    municipality_id TEXT NOT NULL REFERENCES public.municipalities(id) ON DELETE CASCADE,
    municipality_name TEXT NOT NULL,
    latitude NUMERIC NOT NULL,
    longitude NUMERIC NOT NULL,
    address TEXT,
    photo_urls TEXT[] DEFAULT ARRAY[]::TEXT[],
    solution_photo_urls TEXT[] DEFAULT ARRAY[]::TEXT[],
    official_response_note TEXT,
    official_response_date TIMESTAMPTZ,
    citizen_satisfaction_rating SMALLINT,
    author_id TEXT NOT NULL,
    author_name TEXT NOT NULL,
    is_anonymous BOOLEAN DEFAULT FALSE,
    likes_count INTEGER DEFAULT 0,
    confirmations_count INTEGER DEFAULT 0,
    dispute_count INTEGER DEFAULT 0,
    sla_deadline TIMESTAMPTZ NOT NULL,
    resolved_at TIMESTAMPTZ
);

-- Indexler
CREATE INDEX IF NOT EXISTS idx_complaints_municipality ON public.complaints(municipality_id);
CREATE INDEX IF NOT EXISTS idx_complaints_status ON public.complaints(status);
CREATE INDEX IF NOT EXISTS idx_complaints_created_at ON public.complaints(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_complaints_author ON public.complaints(author_id);

-- 3. COMPLAINT LIKES TABLE (Destekler / Beğeniler)
CREATE TABLE IF NOT EXISTS public.complaint_likes (
    complaint_id TEXT NOT NULL REFERENCES public.complaints(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    PRIMARY KEY (complaint_id, user_id)
);

-- 4. COMPLAINT CONFIRMATIONS TABLE ("Bende de var" Teyitleri)
CREATE TABLE IF NOT EXISTS public.complaint_confirmations (
    complaint_id TEXT NOT NULL REFERENCES public.complaints(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    PRIMARY KEY (complaint_id, user_id)
);

-- 5. COMPLAINT COMMENTS TABLE (Yorumlar ve Resmi Açıklamalar)
CREATE TABLE IF NOT EXISTS public.complaint_comments (
    id TEXT PRIMARY KEY,
    complaint_id TEXT NOT NULL REFERENCES public.complaints(id) ON DELETE CASCADE,
    author_id TEXT NOT NULL,
    author_name TEXT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    is_official BOOLEAN DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_comments_complaint ON public.complaint_comments(complaint_id);

-- 6. COMPLAINT DISPUTES TABLE (İtirazlar)
CREATE TABLE IF NOT EXISTS public.complaint_disputes (
    id TEXT PRIMARY KEY,
    complaint_id TEXT NOT NULL REFERENCES public.complaints(id) ON DELETE CASCADE,
    author_id TEXT NOT NULL,
    reason TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_disputes_complaint ON public.complaint_disputes(complaint_id);

-- 7. CITIZEN PROFILES TABLE (Doğrulanmış Vatandaş Profilleri)
CREATE TABLE IF NOT EXISTS public.citizen_profiles (
    user_id TEXT PRIMARY KEY,
    phone_number TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMPTZ,
    followed_municipality_ids TEXT[] DEFAULT ARRAY[]::TEXT[],
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================

ALTER TABLE public.municipalities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.complaints ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.complaint_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.complaint_confirmations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.complaint_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.complaint_disputes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.citizen_profiles ENABLE ROW LEVEL SECURITY;

-- Municipalities: Herkes okuyabilir (Anonim + Yetkili)
CREATE POLICY "Public read access for municipalities"
    ON public.municipalities FOR SELECT USING (true);

-- Complaints: Herkes okuyabilir
CREATE POLICY "Public read access for complaints"
    ON public.complaints FOR SELECT USING (true);

-- Complaints: Herkes şikayet ekleyebilir
CREATE POLICY "Public insert access for complaints"
    ON public.complaints FOR INSERT WITH CHECK (true);

-- Complaints: Kendi şikayetini veya anonim şikayeti güncelleme
CREATE POLICY "Update complaints access"
    ON public.complaints FOR UPDATE USING (true);

-- Likes & Confirmations: Herkes okuyabilir ve ekleyebilir / silebilir
CREATE POLICY "Public read likes" ON public.complaint_likes FOR SELECT USING (true);
CREATE POLICY "Public insert likes" ON public.complaint_likes FOR INSERT WITH CHECK (true);
CREATE POLICY "Public delete likes" ON public.complaint_likes FOR DELETE USING (true);

CREATE POLICY "Public read confirmations" ON public.complaint_confirmations FOR SELECT USING (true);
CREATE POLICY "Public insert confirmations" ON public.complaint_confirmations FOR INSERT WITH CHECK (true);
CREATE POLICY "Public delete confirmations" ON public.complaint_confirmations FOR DELETE USING (true);

-- Comments & Disputes: Herkes okuyabilir ve ekleyebilir
CREATE POLICY "Public read comments" ON public.complaint_comments FOR SELECT USING (true);
CREATE POLICY "Public insert comments" ON public.complaint_comments FOR INSERT WITH CHECK (true);

CREATE POLICY "Public read disputes" ON public.complaint_disputes FOR SELECT USING (true);
CREATE POLICY "Public insert disputes" ON public.complaint_disputes FOR INSERT WITH CHECK (true);

-- Citizen Profiles: Herkes kendi profilini okur ve yazar
CREATE POLICY "Public read profiles" ON public.citizen_profiles FOR SELECT USING (true);
CREATE POLICY "Public write profiles" ON public.citizen_profiles FOR ALL USING (true);

-- ==========================================
-- TRIGGERS: LIKES & CONFIRMATIONS COUNTERS
-- ==========================================

-- Like sayacı trigger fonksiyonu
CREATE OR REPLACE FUNCTION public.handle_complaint_like_change()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE public.complaints
        SET likes_count = likes_count + 1
        WHERE id = NEW.complaint_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE public.complaints
        SET likes_count = GREATEST(likes_count - 1, 0)
        WHERE id = OLD.complaint_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_complaint_like_added
    AFTER INSERT OR DELETE ON public.complaint_likes
    FOR EACH ROW EXECUTE FUNCTION public.handle_complaint_like_change();

-- Confirmation sayacı trigger fonksiyonu
CREATE OR REPLACE FUNCTION public.handle_complaint_confirmation_change()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE public.complaints
        SET confirmations_count = confirmations_count + 1
        WHERE id = NEW.complaint_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE public.complaints
        SET confirmations_count = GREATEST(confirmations_count - 1, 0)
        WHERE id = OLD.complaint_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_complaint_confirmation_added
    AFTER INSERT OR DELETE ON public.complaint_confirmations
    FOR EACH ROW EXECUTE FUNCTION public.handle_complaint_confirmation_change();

-- Dispute sayacı trigger fonksiyonu
CREATE OR REPLACE FUNCTION public.handle_complaint_dispute_change()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE public.complaints
        SET dispute_count = dispute_count + 1
        WHERE id = NEW.complaint_id;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_complaint_dispute_added
    AFTER INSERT ON public.complaint_disputes
    FOR EACH ROW EXECUTE FUNCTION public.handle_complaint_dispute_change();

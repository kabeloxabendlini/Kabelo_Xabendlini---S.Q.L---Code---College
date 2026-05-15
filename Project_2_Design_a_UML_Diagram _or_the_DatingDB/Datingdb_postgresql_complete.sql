-- ============================================================
--  DATABASE: DatingDB  (Revised)
--  PostgreSQL DDL + Sample Data
--
--  Changes from original:
--  1. profession.profession  → UNIQUE constraint (was already present,
--     now explicitly documented and enforced with a named constraint)
--  2. zip_code PK column     → INT with CHECK (zip_code BETWEEN 0 AND 9999)
--                              to prevent any value with more than 4 digits
--  3. zip_code table         → 'state' column renamed to 'province'
--  4. zip_code table         → all 9 SA provinces, 2 cities each (18 rows)
--  5. Each contact           → at least 3 interests in contact_interest
--  6. my_contacts            → 16 contacts (exceeds the 15-contact minimum)
-- ============================================================

CREATE DATABASE project_2_analysis;

-- -----------------------------------------------------------
-- 1. PROFESSION
--    Guideline 1: UNIQUE constraint on profession column.
--    The constraint is named uq_profession for clarity.
-- -----------------------------------------------------------
CREATE TABLE profession (
    prof_id    SERIAL        NOT NULL,
    profession VARCHAR(100)  NOT NULL,
    CONSTRAINT pk_profession PRIMARY KEY (prof_id),
    CONSTRAINT uq_profession UNIQUE (profession)   -- Guideline 1
);

-- -----------------------------------------------------------
-- 2. ZIP_CODE  (natural key — the zip code number itself is the PK)
--    Guideline 2: CHECK constraint limits zip_code to 4 digits max
--                 (0 – 9999).  A 5-digit value like 10001 will be
--                 rejected at INSERT / UPDATE time.
--    Guideline 3: 'state' column replaced by 'province'.
-- -----------------------------------------------------------
CREATE TABLE zip_code (
    zip_code  INT           NOT NULL,
    city      VARCHAR(100)  NOT NULL,
    province  VARCHAR(100)  NOT NULL,              -- Guideline 3
    CONSTRAINT pk_zip_code   PRIMARY KEY (zip_code),
    CONSTRAINT chk_zip_4dig  CHECK (zip_code BETWEEN 0 AND 9999)  -- Guideline 2
);

-- -----------------------------------------------------------
-- 3. STATUS
-- -----------------------------------------------------------
CREATE TABLE status (
    status_id  SERIAL       NOT NULL,
    status     VARCHAR(50)  NOT NULL,
    CONSTRAINT pk_status  PRIMARY KEY (status_id),
    CONSTRAINT uq_status  UNIQUE (status)
);

-- -----------------------------------------------------------
-- 4. MY_CONTACTS  (central table)
-- -----------------------------------------------------------
CREATE TABLE my_contacts (
    contact_id  SERIAL        NOT NULL,
    last_name   VARCHAR(80)   NOT NULL,
    first_name  VARCHAR(80)   NOT NULL,
    phone       VARCHAR(25),
    email       VARCHAR(150)  NOT NULL,
    gender      VARCHAR(20),
    birthday    DATE,
    prof_id     INT,
    zip_code    INT,
    status_id   INT,
    CONSTRAINT pk_my_contacts    PRIMARY KEY (contact_id),
    CONSTRAINT uq_contact_email  UNIQUE (email),
    CONSTRAINT fk_contact_prof   FOREIGN KEY (prof_id)
        REFERENCES profession (prof_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_contact_zip    FOREIGN KEY (zip_code)
        REFERENCES zip_code (zip_code)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_contact_status FOREIGN KEY (status_id)
        REFERENCES status (status_id)
        ON UPDATE CASCADE ON DELETE SET NULL
);

-- -----------------------------------------------------------
-- 5. INTERESTS
-- -----------------------------------------------------------
CREATE TABLE interests (
    interest_id  SERIAL        NOT NULL,
    interest     VARCHAR(100)  NOT NULL,
    CONSTRAINT pk_interests PRIMARY KEY (interest_id),
    CONSTRAINT uq_interest  UNIQUE (interest)
);

-- -----------------------------------------------------------
-- 6. SEEKING
-- -----------------------------------------------------------
CREATE TABLE seeking (
    seeking_id  SERIAL        NOT NULL,
    seeking     VARCHAR(100)  NOT NULL,
    CONSTRAINT pk_seeking PRIMARY KEY (seeking_id),
    CONSTRAINT uq_seeking UNIQUE (seeking)
);

-- -----------------------------------------------------------
-- 7. CONTACT_INTEREST  (M:M bridge)
-- -----------------------------------------------------------
CREATE TABLE contact_interest (
    contact_id   INT  NOT NULL,
    interest_id  INT  NOT NULL,
    CONSTRAINT pk_contact_interest PRIMARY KEY (contact_id, interest_id),
    CONSTRAINT fk_ci_contact  FOREIGN KEY (contact_id)
        REFERENCES my_contacts (contact_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_ci_interest FOREIGN KEY (interest_id)
        REFERENCES interests (interest_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- -----------------------------------------------------------
-- 8. CONTACT_SEEKING  (M:M bridge)
-- -----------------------------------------------------------
CREATE TABLE contact_seeking (
    contact_id  INT  NOT NULL,
    seeking_id  INT  NOT NULL,
    CONSTRAINT pk_contact_seeking PRIMARY KEY (contact_id, seeking_id),
    CONSTRAINT fk_cs_contact FOREIGN KEY (contact_id)
        REFERENCES my_contacts (contact_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_cs_seeking FOREIGN KEY (seeking_id)
        REFERENCES seeking (seeking_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- ============================================================
--  INDEXES
-- ============================================================
CREATE INDEX idx_contact_prof    ON my_contacts      (prof_id);
CREATE INDEX idx_contact_zip     ON my_contacts      (zip_code);
CREATE INDEX idx_contact_status  ON my_contacts      (status_id);
CREATE INDEX idx_ci_interest     ON contact_interest (interest_id);
CREATE INDEX idx_cs_seeking      ON contact_seeking  (seeking_id);

-- ============================================================
--  SAMPLE DATA
-- ============================================================

-- -----------------------------------------------------------
-- 1. PROFESSION  (Guideline 1: uq_profession enforces no duplicates)
-- -----------------------------------------------------------
INSERT INTO profession (profession) VALUES
    ('Software Engineer'),
    ('Teacher'),
    ('Doctor'),
    ('Accountant'),
    ('Designer'),
    ('Entrepreneur'),
    ('Nurse'),
    ('Lawyer'),
    ('Architect'),
    ('Marketing Manager');

SELECT * FROM profession;

-- -----------------------------------------------------------
-- 2. ZIP_CODE
--    Guideline 3: column is now 'province' not 'state'
--    Guideline 4: all 9 SA provinces, 2 cities each = 18 rows
--    Guideline 2: all values are between 0 and 9999 (4 digits max)
--
--    Province            City 1           City 2
--    ──────────────────────────────────────────────
--    KwaZulu-Natal       Durban (4001)    Pietermaritzburg (3200)
--    Western Cape        Cape Town (8001) Stellenbosch (7600)
--    Gauteng             Johannesburg (2000) Pretoria (0001)
--    Eastern Cape        Port Elizabeth (6001) East London (5201)
--    Limpopo             Polokwane (0700) Tzaneen (0850)
--    Mpumalanga          Nelspruit (1200) Witbank (1035)
--    Free State          Bloemfontein (9300) Welkom (9460)
--    North West          Rustenburg (0299) Mafikeng (2745)
--    Northern Cape       Kimberley (8300) Upington (8800)
-- -----------------------------------------------------------
INSERT INTO zip_code (zip_code, city, province) VALUES
    -- KwaZulu-Natal
    (4001, 'Durban',            'KwaZulu-Natal'),
    (3200, 'Pietermaritzburg',  'KwaZulu-Natal'),
    -- Western Cape
    (8001, 'Cape Town',         'Western Cape'),
    (7600, 'Stellenbosch',      'Western Cape'),
    -- Gauteng
    (2000, 'Johannesburg',      'Gauteng'),
    (0001, 'Pretoria',          'Gauteng'),
    -- Eastern Cape
    (6001, 'Port Elizabeth',    'Eastern Cape'),
    (5201, 'East London',       'Eastern Cape'),
    -- Limpopo
    (0700, 'Polokwane',         'Limpopo'),
    (0850, 'Tzaneen',           'Limpopo'),
    -- Mpumalanga
    (1200, 'Nelspruit',         'Mpumalanga'),
    (1035, 'Witbank',           'Mpumalanga'),
    -- Free State
    (9300, 'Bloemfontein',      'Free State'),
    (9460, 'Welkom',            'Free State'),
    -- North West
    (0299, 'Rustenburg',        'North West'),
    (2745, 'Mafikeng',          'North West'),
    -- Northern Cape
    (8300, 'Kimberley',         'Northern Cape'),
    (8800, 'Upington',          'Northern Cape');

SELECT * FROM zip_code;

-- -----------------------------------------------------------
-- 3. STATUS
-- -----------------------------------------------------------
INSERT INTO status (status) VALUES
    ('Single'),
    ('Divorced'),
    ('Widowed'),
    ('Separated');

SELECT * FROM status;

-- -----------------------------------------------------------
-- 4. MY_CONTACTS  — 16 contacts (Guideline 6: more than 15)
--
--    prof_id:   1=Engineer 2=Teacher 3=Doctor 4=Accountant
--               5=Designer 6=Entrepreneur 7=Nurse 8=Lawyer
--               9=Architect 10=Marketing Manager
--    status_id: 1=Single 2=Divorced 3=Widowed 4=Separated
-- -----------------------------------------------------------

INSERT INTO my_contacts
    (last_name, first_name, phone, email, gender, birthday, prof_id, zip_code, status_id)
VALUES
    -- 1
    ('Xabendlini', 'Kabelo',   '0821234567', 'kabelo.x@mail.com',   'Male',   '2006-02-26', 1, 4001, 1),
    -- 2
    ('Nkosi',      'Thabo',    '0839876543', 'thabo.n@mail.com',    'Male',   '1985-07-22', 3, 8001, 2),
    -- 3
    ('Dlamini',    'Zanele',   '0761112233', 'zanele.d@mail.com',   'Female', '1993-11-05', 2, 2000, 1),
    -- 4
    ('Smith',      'Jane',     '0714445566', 'jane.s@mail.com',     'Female', '1988-01-30', 4, 0001, 3),
    -- 5
    ('Maqubela',   'Bantu',    '0607778899', 'bantu.m@mail.com',    'Male',   '1995-06-18', 5, 4001, 1),
    -- 6
    ('Patel',      'Amara',    '0823334455', 'amara.p@mail.com',    'Female', '1991-09-09', 6, 6001, 4),
    -- 7
    ('Mokoena',    'Lerato',   '0796667788', 'lerato.m@mail.com',   'Female', '1987-04-25', 1, 8001, 1),
    -- 8
    ('Mthembu',    'Sipho',    '0835556677', 'sipho.m@mail.com',    'Male',   '1992-12-01', 3, 2000, 2),
    -- 9
    ('Van Wyk',    'Elke',     '0712223344', 'elke.v@mail.com',     'Female', '1990-03-14', 8, 7600, 1),
    -- 10
    ('Botha',      'Ruan',     '0841112233', 'ruan.b@mail.com',     'Male',   '1983-09-07', 9, 5201, 2),
    -- 11
    ('Shabalala',  'Nomsa',    '0769998877', 'nomsa.s@mail.com',    'Female', '1997-08-19', 7, 3200, 1),
    -- 12
    ('Ferreira',   'Luca',     '0826664433', 'luca.f@mail.com',     'Male',   '1989-05-31', 10, 0700, 4),
    -- 13
    ('Sithole',    'Lungelo',  '0731234890', 'lungelo.si@mail.com', 'Male',   '1994-10-22', 2, 1200, 1),
    -- 14
    ('Jansen',     'Mia',      '0858904321', 'mia.j@mail.com',      'Female', '1986-12-11', 4, 9300, 3),
    -- 15
    ('Molefe',     'Dineo',    '0779876001', 'dineo.m@mail.com',    'Female', '1998-02-03', 5, 0299, 1),
    -- 16
    ('Govender',   'Priya',    '0843214567', 'priya.g@mail.com',    'Female', '1991-07-16', 6, 8300, 2);

SELECT * FROM my_contacts;

-- -----------------------------------------------------------
-- 5. INTERESTS
-- -----------------------------------------------------------
INSERT INTO interests (interest) VALUES
    ('Hiking'),        -- 1
    ('Cooking'),       -- 2
    ('Reading'),       -- 3
    ('Gaming'),        -- 4
    ('Travel'),        -- 5
    ('Music'),         -- 6
    ('Fitness'),       -- 7
    ('Photography'),   -- 8
    ('Dancing'),       -- 9
    ('Painting');      -- 10

SELECT * FROM interests;

-- -----------------------------------------------------------
-- 6. SEEKING
-- -----------------------------------------------------------
INSERT INTO seeking (seeking) VALUES
    ('Friendship'),
    ('Long-term relationship'),
    ('Short-term relationship'),
    ('Marriage'),
    ('Casual dating');

SELECT * FROM seeking;

-- -----------------------------------------------------------
-- 7. CONTACT_INTEREST
--    Guideline 5: every contact has AT LEAST 3 interests.
--
--    contact_id → interests assigned
--    ─────────────────────────────────────────────────────
--    1  Kabelo    → Hiking(1), Travel(5), Fitness(7), Music(6)
--    2  Thabo     → Cooking(2), Music(6), Gaming(4)
--    3  Zanele    → Reading(3), Photography(8), Dancing(9)
--    4  Jane      → Cooking(2), Reading(3), Fitness(7), Painting(10)
--    5  Bantu     → Gaming(4), Music(6), Photography(8)
--    6  Amara     → Hiking(1), Travel(5), Photography(8), Dancing(9)
--    7  Lerato    → Reading(3), Fitness(7), Painting(10)
--    8  Sipho     → Gaming(4), Hiking(1), Music(6)
--    9  Elke      → Reading(3), Travel(5), Photography(8), Fitness(7)
--    10 Ruan      → Hiking(1), Cooking(2), Gaming(4)
--    11 Nomsa     → Dancing(9), Music(6), Painting(10)
--    12 Luca      → Travel(5), Photography(8), Fitness(7)
--    13 Lungelo   → Gaming(4), Hiking(1), Cooking(2), Music(6)
--    14 Mia       → Reading(3), Dancing(9), Photography(8)
--    15 Dineo     → Fitness(7), Travel(5), Painting(10)
--    16 Priya     → Cooking(2), Music(6), Dancing(9), Travel(5)
-- -----------------------------------------------------------
INSERT INTO contact_interest (contact_id, interest_id) VALUES
    -- Kabelo (4 interests)
    (1, 1), (1, 5), (1, 7), (1, 6),
    -- Thabo (3 interests)
    (2, 2), (2, 6), (2, 4),
    -- Zanele (3 interests)
    (3, 3), (3, 8), (3, 9),
    -- Jane (4 interests)
    (4, 2), (4, 3), (4, 7), (4, 10),
    -- Bantu (3 interests)
    (5, 4), (5, 6), (5, 8),
    -- Amara (4 interests)
    (6, 1), (6, 5), (6, 8), (6, 9),
    -- Lerato (3 interests)
    (7, 3), (7, 7), (7, 10),
    -- Sipho (3 interests)
    (8, 4), (8, 1), (8, 6),
    -- Elke (4 interests)
    (9, 3), (9, 5), (9, 8), (9, 7),
    -- Ruan (3 interests)
    (10, 1), (10, 2), (10, 4),
    -- Nomsa (3 interests)
    (11, 9), (11, 6), (11, 10),
    -- Luca (3 interests)
    (12, 5), (12, 8), (12, 7),
    -- Lungelo (4 interests)
    (13, 4), (13, 1), (13, 2), (13, 6),
    -- Mia (3 interests)
    (14, 3), (14, 9), (14, 8),
    -- Dineo (3 interests)
    (15, 7), (15, 5), (15, 10),
    -- Priya (4 interests)
    (16, 2), (16, 6), (16, 9), (16, 5);

SELECT * FROM contact_interest;

-- -----------------------------------------------------------
-- 8. CONTACT_SEEKING
-- -----------------------------------------------------------
INSERT INTO contact_seeking (contact_id, seeking_id) VALUES
    (1,  2), (1,  4),   -- Kabelo:  Long-term, Marriage
    (2,  3),            -- Thabo:   Short-term
    (3,  2),            -- Zanele:  Long-term
    (4,  1), (4,  2),   -- Jane:    Friendship, Long-term
    (5,  5),            -- Bantu:   Casual dating
    (6,  2), (6,  4),   -- Amara:   Long-term, Marriage
    (7,  1), (7,  2),   -- Lerato:  Friendship, Long-term
    (8,  3), (8,  5),   -- Sipho:   Short-term, Casual dating
    (9,  2),            -- Elke:    Long-term
    (10, 1), (10, 5),   -- Ruan:    Friendship, Casual dating
    (11, 2), (11, 4),   -- Nomsa:   Long-term, Marriage
    (12, 3),            -- Luca:    Short-term
    (13, 1), (13, 2),   -- Lungelo: Friendship, Long-term
    (14, 2), (14, 4),   -- Mia:     Long-term, Marriage
    (15, 5),            -- Dineo:   Casual dating
    (16, 2), (16, 1);   -- Priya:   Long-term, Friendship

SELECT * FROM contact_seeking;

-- ============================================================
--  VERIFY — views
-- ============================================================
SELECT * FROM vw_contact_profile;
SELECT * FROM vw_contact_interests;
SELECT * FROM vw_contact_seeking;

CREATE OR REPLACE VIEW vw_contact_interests AS
SELECT
    c.contact_id,
    c.first_name,
    c.last_name,
    STRING_AGG(i.interest, ', ' ORDER BY i.interest) AS interests
FROM  my_contacts      c
JOIN  contact_interest ci ON c.contact_id   = ci.contact_id
JOIN  interests        i  ON ci.interest_id = i.interest_id
GROUP BY c.contact_id, c.first_name, c.last_name;

CREATE OR REPLACE VIEW vw_contact_seeking AS
SELECT
    c.contact_id,
    c.first_name,
    c.last_name,
    STRING_AGG(sk.seeking, ', ' ORDER BY sk.seeking) AS seeking
FROM  my_contacts     c
JOIN  contact_seeking cs ON c.contact_id  = cs.contact_id
JOIN  seeking         sk ON cs.seeking_id = sk.seeking_id
GROUP BY c.contact_id, c.first_name, c.last_name;

-- ============================================================
--  CONSTRAINT VIOLATION TESTS
--  Run each block individually to see the error message.
-- ============================================================

-- Guideline 1 — uq_profession: duplicate profession name
-- ERROR: duplicate key value violates unique constraint "uq_profession"
INSERT INTO profession (profession) VALUES ('Doctor');

-- Guideline 2 — chk_zip_4dig: zip_code exceeds 4 digits (> 9999)
-- ERROR: new row for relation "zip_code" violates check constraint "chk_zip_4dig"
INSERT INTO zip_code (zip_code, city, province) VALUES (10001, 'Nowhere', 'Gauteng');

-- FK violation: contact references a non-existent zip_code
-- ERROR: insert or update on table "my_contacts" violates foreign key constraint "fk_contact_zip"
INSERT INTO my_contacts (last_name, first_name, email, zip_code)
VALUES ('Ghost', 'User', 'ghost@mail.com', 9999);

-- UNIQUE email violation on my_contacts
-- ERROR: duplicate key value violates unique constraint "uq_contact_email"
INSERT INTO my_contacts (last_name, first_name, email)
VALUES ('Clone', 'User', 'kabelo.x@mail.com');

-- ============================================================
--  END OF SCRIPT
-- ============================================================

-- ============================================================
--  VIEWS
-- ============================================================
CREATE OR REPLACE VIEW vw_contact_profile AS
SELECT
    c.contact_id,
    c.first_name,
    c.last_name,
    c.phone,
    c.email,
    c.gender,
    c.birthday,
    p.profession,
    z.city,
    z.province,                -- Guideline 3: was z.state
    z.zip_code,
    s.status
FROM  my_contacts c
LEFT JOIN profession p ON c.prof_id   = p.prof_id
LEFT JOIN zip_code   z ON c.zip_code  = z.zip_code
LEFT JOIN status     s ON c.status_id = s.status_id;
-- ============================================================
--  DATABASE: DatingDB
--  Forward Engineered DDL — PostgreSQL syntax
--  Tables: profession | zip_code | status | my_contacts
--          interests  | seeking  | contact_interest | contact_seeking
-- ============================================================

CREATE DATABASE project_2_analysis;

-- -----------------------------------------------------------
-- 1. PROFESSION
-- -----------------------------------------------------------
CREATE TABLE profession (
    prof_id    SERIAL        NOT NULL,
    profession VARCHAR(100)  NOT NULL,
    CONSTRAINT pk_profession PRIMARY KEY (prof_id),
    CONSTRAINT uq_profession UNIQUE (profession)
);

-- -----------------------------------------------------------
-- 2. ZIP_CODE
-- -----------------------------------------------------------
CREATE TABLE zip_code (
    zip_code  INT           NOT NULL,
    city      VARCHAR(100)  NOT NULL,
    state     VARCHAR(100)  NOT NULL,
    CONSTRAINT pk_zip_code PRIMARY KEY (zip_code)
);

-- -----------------------------------------------------------
-- 3. STATUS
-- -----------------------------------------------------------
CREATE TABLE status (
    status_id  SERIAL       NOT NULL,
    status     VARCHAR(50)  NOT NULL,
    CONSTRAINT pk_status PRIMARY KEY (status_id),
    CONSTRAINT uq_status UNIQUE (status)
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
-- 7. CONTACT_INTEREST  (M:M bridge table)
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
-- 8. CONTACT_SEEKING  (M:M bridge table)
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
CREATE INDEX idx_contact_prof    ON my_contacts     (prof_id);
CREATE INDEX idx_contact_zip     ON my_contacts     (zip_code);
CREATE INDEX idx_contact_status  ON my_contacts     (status_id);
CREATE INDEX idx_ci_interest     ON contact_interest (interest_id);
CREATE INDEX idx_cs_seeking      ON contact_seeking  (seeking_id);

-- ============================================================
--  VIEWS  (GROUP_CONCAT → STRING_AGG in PostgreSQL)
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
    z.state,
    z.zip_code,
    s.status
FROM  my_contacts c
LEFT JOIN profession p ON c.prof_id   = p.prof_id
LEFT JOIN zip_code   z ON c.zip_code  = z.zip_code
LEFT JOIN status     s ON c.status_id = s.status_id;

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
FROM  my_contacts    c
JOIN  contact_seeking cs ON c.contact_id  = cs.contact_id
JOIN  seeking        sk  ON cs.seeking_id = sk.seeking_id
GROUP BY c.contact_id, c.first_name, c.last_name;


-- ============================================================
--  SAMPLE DATA
--  Insert order: lookups first, my_contacts second,
--                bridge tables last
-- ============================================================

-- -----------------------------------------------------------
-- 1. PROFESSION data
-- -----------------------------------------------------------
INSERT INTO profession (profession) VALUES
    ('Software Engineer'),
    ('Teacher'),
    ('Doctor'),
    ('Accountant'),
    ('Designer'),
    ('Entrepreneur');

SELECT * FROM profession;

-- -----------------------------------------------------------
-- 2. ZIP_CODE data
-- -----------------------------------------------------------
INSERT INTO zip_code (zip_code, city, state) VALUES
    (4001, 'Durban',        'KwaZulu-Natal'),
    (8001, 'Cape Town',     'Western Cape'),
    (2000, 'Johannesburg',  'Gauteng'),
    (0001, 'Pretoria',      'Gauteng'),
    (6001, 'Port Elizabeth', 'Eastern Cape');

SELECT * FROM zip_code;

-- -----------------------------------------------------------
-- 3. STATUS data
-- -----------------------------------------------------------
INSERT INTO status (status) VALUES
    ('Single'),
    ('Divorced'),
    ('Widowed'),
    ('Separated');

SELECT * FROM status;

-- -----------------------------------------------------------
-- 4. MY_CONTACTS data
--    prof_id:   1=Engineer 2=Teacher 3=Doctor 4=Accountant 5=Designer 6=Entrepreneur
--    zip_code:  4001=Durban 8001=Cape Town 2000=Jhb 0001=Pretoria 6001=PE
--    status_id: 1=Single 2=Divorced 3=Widowed 4=Separated
-- -----------------------------------------------------------
INSERT INTO my_contacts (last_name, first_name, phone, email, gender, birthday, prof_id, zip_code, status_id) VALUES
    ('Xabendlini', 'Kabelo',  '0821234567', 'kabeloxabendlini385@gmail.com',  'Male',   '2006-02-26', 1, 4001, 1);
    ('Nkosi',      'Thabo',   '0839876543', 'thabo.n@mail.com',   'Male',   '1985-07-22', 3, 8001, 2),
    ('Dlamini',    'Zanele',  '0761112233', 'zanele.d@mail.com',  'Female', '1993-11-05', 2, 2000, 1),
    ('Smith',      'Jane',    '0714445566', 'jane.s@mail.com',    'Female', '1988-01-30', 4, 0001, 3),
    ('Maqubela',   'Bantu',   '0607778899', 'bantu.m@mail.com',   'Male',   '1995-06-18', 5, 4001, 1),
    ('Patel',      'Amara',   '0823334455', 'amara.p@mail.com',   'Female', '1991-09-09', 6, 6001, 4),
    ('Mokoena',    'Lerato',  '0796667788', 'lerato.m@mail.com',  'Female', '1987-04-25', 1, 8001, 1),
    ('Mthembu',    'Sipho',   '0835556677', 'sipho.m@mail.com',   'Male',   '1992-12-01', 3, 2000, 2);

SELECT * FROM my_contacts;

-- -----------------------------------------------------------
-- 5. INTERESTS data
-- -----------------------------------------------------------
INSERT INTO interests (interest) VALUES
    ('Hiking'),
    ('Cooking'),
    ('Reading'),
    ('Gaming'),
    ('Travel'),
    ('Music'),
    ('Fitness'),
    ('Photography');

SELECT * FROM interests;

-- -----------------------------------------------------------
-- 6. SEEKING data
-- -----------------------------------------------------------
INSERT INTO seeking (seeking) VALUES
    ('Friendship'),
    ('Long-term relationship'),
    ('Short-term relationship'),
    ('Marriage'),
    ('Casual dating');

SELECT * FROM seeking;

-- -----------------------------------------------------------
-- 7. CONTACT_INTEREST data  (M:M — each contact gets interests)
--    Check contact_id values from SELECT above before running
-- -----------------------------------------------------------
INSERT INTO contact_interest (contact_id, interest_id) VALUES
    (1, 1), (1, 5), (1, 7),   -- Kabelo:  Hiking, Travel, Fitness
    (2, 2), (2, 6),            -- Thabo:   Cooking, Music
    (3, 3), (3, 8),            -- Zanele:  Reading, Photography
    (4, 2), (4, 3), (4, 7),   -- Jane:    Cooking, Reading, Fitness
    (5, 4), (5, 6),            -- Bantu:   Gaming, Music
    (6, 1), (6, 5), (6, 8),   -- Amara:   Hiking, Travel, Photography
    (7, 3), (7, 7),            -- Lerato:  Reading, Fitness
    (8, 4), (8, 1);            -- Sipho:   Gaming, Hiking

SELECT * FROM contact_interest;

-- -----------------------------------------------------------
-- 8. CONTACT_SEEKING data  (M:M — each contact gets seeking values)
-- -----------------------------------------------------------
INSERT INTO contact_seeking (contact_id, seeking_id) VALUES
    (1, 2), (1, 4),   -- Kabelo:  Long-term, Marriage
    (2, 3),           -- Thabo:   Short-term
    (3, 2),           -- Zanele:  Long-term
    (4, 1), (4, 2),   -- Jane:    Friendship, Long-term
    (5, 5),           -- Bantu:   Casual dating
    (6, 2), (6, 4),   -- Amara:   Long-term, Marriage
    (7, 1), (7, 2),   -- Lerato:  Friendship, Long-term
    (8, 3), (8, 5);   -- Sipho:   Short-term, Casual dating

SELECT * FROM contact_seeking;

-- ============================================================
--  VERIFY — run the views to see everything joined together
-- ============================================================

-- Full profile with profession, location and status
SELECT * FROM vw_contact_profile;

-- Each contact with their interests listed
SELECT * FROM vw_contact_interests;

-- Each contact with what they are seeking
SELECT * FROM vw_contact_seeking;

-- ============================================================
--  END OF SCRIPT
-- ============================================================
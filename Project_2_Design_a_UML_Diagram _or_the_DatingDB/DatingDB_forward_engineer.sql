-- ============================================================
--  DATABASE: DatingDB
--  Forward Engineered DDL — from UML / Schema Diagram
--  Tables: profession | zip_code | status | my_contacts
--          interests  | seeking  | contact_interest | contact_seeking
--  Compatible: MySQL 8+ / PostgreSQL 13+
-- ============================================================

-- -----------------------------------------------------------
-- 1. PROFESSION  (lookup — one-to-many → my_contacts)
-- -----------------------------------------------------------
CREATE TABLE profession (
    prof_id    INT           NOT NULL AUTO_INCREMENT,
    profession VARCHAR(100)  NOT NULL,
    CONSTRAINT pk_profession  PRIMARY KEY (prof_id),
    CONSTRAINT uq_profession  UNIQUE (profession)
);

-- -----------------------------------------------------------
-- 2. ZIP_CODE  (lookup — one-to-many → my_contacts)
-- -----------------------------------------------------------
CREATE TABLE zip_code (
    zip_code  INT           NOT NULL,
    city      VARCHAR(100)  NOT NULL,
    state     VARCHAR(100)  NOT NULL,
    CONSTRAINT pk_zip_code  PRIMARY KEY (zip_code)
);

-- -----------------------------------------------------------
-- 3. STATUS  (lookup — one-to-many → my_contacts)
-- -----------------------------------------------------------
CREATE TABLE status (
    status_id  INT           NOT NULL AUTO_INCREMENT,
    status     VARCHAR(50)   NOT NULL,
    CONSTRAINT pk_status  PRIMARY KEY (status_id),
    CONSTRAINT uq_status  UNIQUE (status)
);

-- -----------------------------------------------------------
-- 4. MY_CONTACTS  (central table)
--    FK → profession, zip_code, status
-- -----------------------------------------------------------
CREATE TABLE my_contacts (
    contact_id  INT           NOT NULL AUTO_INCREMENT,
    last_name   VARCHAR(80)   NOT NULL,
    first_name  VARCHAR(80)   NOT NULL,
    phone       VARCHAR(25),
    email       VARCHAR(150)  NOT NULL,
    gender      VARCHAR(20),
    birthday    DATE,

    -- Foreign keys (one-to-many lookups)
    prof_id     INT,
    zip_code    INT,
    status_id   INT,

    CONSTRAINT pk_my_contacts   PRIMARY KEY (contact_id),
    CONSTRAINT uq_contact_email UNIQUE (email),

    CONSTRAINT fk_contact_prof  FOREIGN KEY (prof_id)
        REFERENCES profession (prof_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_contact_zip   FOREIGN KEY (zip_code)
        REFERENCES zip_code (zip_code)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_contact_status FOREIGN KEY (status_id)
        REFERENCES status (status_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- -----------------------------------------------------------
-- 5. INTERESTS  (lookup for M:M via contact_interest)
-- -----------------------------------------------------------
CREATE TABLE interests (
    interest_id  INT           NOT NULL AUTO_INCREMENT,
    interest     VARCHAR(100)  NOT NULL,
    CONSTRAINT pk_interests  PRIMARY KEY (interest_id),
    CONSTRAINT uq_interest   UNIQUE (interest)
);

-- -----------------------------------------------------------
-- 6. SEEKING  (lookup for M:M via contact_seeking)
-- -----------------------------------------------------------
CREATE TABLE seeking (
    seeking_id  INT           NOT NULL AUTO_INCREMENT,
    seeking     VARCHAR(100)  NOT NULL,
    CONSTRAINT pk_seeking  PRIMARY KEY (seeking_id),
    CONSTRAINT uq_seeking  UNIQUE (seeking)
);

-- -----------------------------------------------------------
-- 7. CONTACT_INTEREST  (join / bridge table — M:M)
--    Composite PK: (contact_id, interest_id)
--    A contact can have the same interest_id many times
--    in concept, but only once per row in this table.
--    The interests table holds each interest only once.
-- -----------------------------------------------------------
CREATE TABLE contact_interest (
    contact_id   INT  NOT NULL,
    interest_id  INT  NOT NULL,

    CONSTRAINT pk_contact_interest  PRIMARY KEY (contact_id, interest_id),

    CONSTRAINT fk_ci_contact  FOREIGN KEY (contact_id)
        REFERENCES my_contacts (contact_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_ci_interest FOREIGN KEY (interest_id)
        REFERENCES interests (interest_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- -----------------------------------------------------------
-- 8. CONTACT_SEEKING  (join / bridge table — M:M)
--    Composite PK: (contact_id, seeking_id)
-- -----------------------------------------------------------
CREATE TABLE contact_seeking (
    contact_id  INT  NOT NULL,
    seeking_id  INT  NOT NULL,

    CONSTRAINT pk_contact_seeking  PRIMARY KEY (contact_id, seeking_id),

    CONSTRAINT fk_cs_contact  FOREIGN KEY (contact_id)
        REFERENCES my_contacts (contact_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_cs_seeking  FOREIGN KEY (seeking_id)
        REFERENCES seeking (seeking_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ============================================================
--  INDEXES
-- ============================================================
CREATE INDEX idx_contact_prof     ON my_contacts     (prof_id);
CREATE INDEX idx_contact_zip      ON my_contacts     (zip_code);
CREATE INDEX idx_contact_status   ON my_contacts     (status_id);
CREATE INDEX idx_ci_interest      ON contact_interest (interest_id);
CREATE INDEX idx_cs_seeking       ON contact_seeking  (seeking_id);

-- ============================================================
--  VIEW — full contact profile with all lookups joined
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
LEFT JOIN profession p  ON c.prof_id   = p.prof_id
LEFT JOIN zip_code   z  ON c.zip_code  = z.zip_code
LEFT JOIN status     s  ON c.status_id = s.status_id;

-- ============================================================
--  VIEW — contact with all their interests (aggregated)
-- ============================================================
CREATE OR REPLACE VIEW vw_contact_interests AS
SELECT
    c.contact_id,
    c.first_name,
    c.last_name,
    GROUP_CONCAT(i.interest ORDER BY i.interest SEPARATOR ', ') AS interests
FROM  my_contacts    c
JOIN  contact_interest ci ON c.contact_id  = ci.contact_id
JOIN  interests        i  ON ci.interest_id = i.interest_id
GROUP BY c.contact_id, c.first_name, c.last_name;

-- ============================================================
--  VIEW — contact with all their seeking entries (aggregated)
-- ============================================================
CREATE OR REPLACE VIEW vw_contact_seeking AS
SELECT
    c.contact_id,
    c.first_name,
    c.last_name,
    GROUP_CONCAT(sk.seeking ORDER BY sk.seeking SEPARATOR ', ') AS seeking
FROM  my_contacts   c
JOIN  contact_seeking cs ON c.contact_id = cs.contact_id
JOIN  seeking        sk  ON cs.seeking_id = sk.seeking_id
GROUP BY c.contact_id, c.first_name, c.last_name;

-- ============================================================
--  END OF SCRIPT
-- ============================================================

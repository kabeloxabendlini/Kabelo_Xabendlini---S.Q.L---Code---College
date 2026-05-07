CREATE DATABASE project_1_analysis;

-- ============================================================
--  DATABASE: EmployeeDB
--  Forward Engineered DDL — PostgreSQL syntax
--  Tables: Department | Roles | Salaries | Overtime_Hours | Employees
-- ============================================================

-- -----------------------------------------------------------
-- 1. DEPARTMENT
-- -----------------------------------------------------------
CREATE TABLE Department (
    depart_id    SERIAL         NOT NULL,
    depart_name  VARCHAR(100)   NOT NULL,
    depart_city  VARCHAR(100),
    CONSTRAINT pk_department  PRIMARY KEY (depart_id),
    CONSTRAINT uq_depart_name UNIQUE (depart_name)
);

-- -----------------------------------------------------------
-- 2. ROLES
-- -----------------------------------------------------------
CREATE TABLE Roles (
    role_id  SERIAL        NOT NULL,
    role     VARCHAR(100)  NOT NULL,
    CONSTRAINT pk_roles PRIMARY KEY (role_id),
    CONSTRAINT uq_role  UNIQUE (role)
);

-- -----------------------------------------------------------
-- 3. SALARIES
-- -----------------------------------------------------------
CREATE TABLE Salaries (
    salary_id  SERIAL          NOT NULL,
    salary_pa  DECIMAL(12, 2)  NOT NULL,
    CONSTRAINT pk_salaries PRIMARY KEY (salary_id),
    CONSTRAINT chk_salary  CHECK (salary_pa >= 0)
);

-- -----------------------------------------------------------
-- 4. OVERTIME_HOURS
-- -----------------------------------------------------------
CREATE TABLE Overtime_Hours (
    overtime_id    SERIAL  NOT NULL,
    overtime_hours INT     NOT NULL DEFAULT 0,
    CONSTRAINT pk_overtime  PRIMARY KEY (overtime_id),
    CONSTRAINT chk_ot_hours CHECK (overtime_hours >= 0)
);

-- -----------------------------------------------------------
-- 5. EMPLOYEES  (central table — all FKs live here)
-- -----------------------------------------------------------
CREATE TABLE Employees (
    emp_id       SERIAL        NOT NULL,
    first_name   VARCHAR(80)   NOT NULL,
    surname      VARCHAR(80)   NOT NULL,
    gender       VARCHAR(20),
    address      VARCHAR(255),
    email        VARCHAR(150)  NOT NULL,

    -- Foreign keys
    depart_id    INT,
    role_id      INT,
    salary_id    INT,
    overtime_id  INT,

    CONSTRAINT pk_employees    PRIMARY KEY (emp_id),
    CONSTRAINT uq_email        UNIQUE (email),

    CONSTRAINT fk_emp_dept     FOREIGN KEY (depart_id)
        REFERENCES Department (depart_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_emp_role     FOREIGN KEY (role_id)
        REFERENCES Roles (role_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_emp_salary   FOREIGN KEY (salary_id)
        REFERENCES Salaries (salary_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_emp_overtime FOREIGN KEY (overtime_id)
        REFERENCES Overtime_Hours (overtime_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- ============================================================
--  INDEXES
-- ============================================================
CREATE INDEX idx_emp_depart   ON Employees (depart_id);
CREATE INDEX idx_emp_role     ON Employees (role_id);
CREATE INDEX idx_emp_salary   ON Employees (salary_id);
CREATE INDEX idx_emp_overtime ON Employees (overtime_id);
CREATE INDEX idx_emp_surname  ON Employees (surname);

-- ============================================================
--  VIEW — full employee detail
-- ============================================================
CREATE OR REPLACE VIEW vw_employee_detail AS
SELECT
    e.emp_id,
    e.first_name,
    e.surname,
    e.gender,
    e.address,
    e.email,
    d.depart_name,
    d.depart_city,
    r.role,
    s.salary_pa,
    o.overtime_hours
FROM Employees e
LEFT JOIN Department     d ON e.depart_id   = d.depart_id
LEFT JOIN Roles          r ON e.role_id     = r.role_id
LEFT JOIN Salaries       s ON e.salary_id   = s.salary_id
LEFT JOIN Overtime_Hours o ON e.overtime_id = o.overtime_id;

-- ============================================================
--  END OF CREATE TABLES
-- ============================================================



-- ============================================================
--  EmployeeDB — Sample Data (PostgreSQL)
--  Insert order matters: lookup tables first, Employees last
-- ============================================================

-- -----------------------------------------------------------
-- 1. DEPARTMENT
-- -----------------------------------------------------------
INSERT INTO Department (depart_name, depart_city) VALUES
    ('Human Resources',  'Durban'),
    ('Finance',          'Johannesburg'),
    ('Information Technology', 'Cape Town'),
    ('Operations',       'Pretoria');

SELECT * FROM Department;

-- -----------------------------------------------------------
-- 2. ROLES
-- -----------------------------------------------------------
INSERT INTO Roles (role) VALUES
    ('Manager'),
    ('Developer'),
    ('Accountant'),
    ('HR Officer'),
    ('Systems Analyst');

SELECT * FROM Roles;

-- -----------------------------------------------------------
-- 3. SALARIES
-- -----------------------------------------------------------
INSERT INTO Salaries (salary_pa) VALUES
    (25000.00),
    (38000.00),
    (52000.00),
    (67000.00),
    (85000.00);

SELECT * FROM Salaries;

-- -----------------------------------------------------------
-- 4. OVERTIME_HOURS
-- -----------------------------------------------------------
INSERT INTO Overtime_Hours (overtime_hours) VALUES
    (0),
    (5),
    (12),
    (20),
    (35);

SELECT * FROM Overtime_Hours;

-- -----------------------------------------------------------
-- 5. EMPLOYEES
-- Check the IDs returned above before inserting.
-- depart_id 1=HR, 2=Finance, 3=IT, 4=Operations
-- role_id   1=Manager, 2=Developer, 3=Accountant, 4=HR Officer, 5=Analyst
-- salary_id 1=25000, 2=38000, 3=52000, 4=67000, 5=85000
-- overtime_id 1=0hrs, 2=5hrs, 3=12hrs, 4=20hrs, 5=35hrs
-- -----------------------------------------------------------
INSERT INTO Employees (first_name, surname, gender, address, email, depart_id, role_id, salary_id, overtime_id) VALUES
    ('Kabelo',  'Xabendlini', 'Male',   '12 Main Rd, Durban',        'kabelo.x@company.co.za',   1, 4, 2, 1),
    ('Thabo',   'Nkosi',      'Male',   '88 Beach Rd, Cape Town',    'thabo.n@company.co.za',    3, 2, 4, 3),
    ('Zanele',  'Dlamini',    'Female', '45 West Ave, Johannesburg',  'zanele.d@company.co.za',   2, 3, 3, 2),
    ('Jane',    'Smith',      'Female', '7 Oak St, Pretoria',         'jane.s@company.co.za',     4, 1, 5, 4),
    ('Sipho',   'Mthembu',   'Male',   '33 Pine Rd, Durban',         'sipho.m@company.co.za',    3, 5, 3, 3),
    ('Amara',   'Patel',      'Female', '19 Elm Rd, Cape Town',       'amara.p@company.co.za',    2, 3, 2, 1),
    ('Bantu',   'Maqubela',   'Male',   '5 Hill St, Johannesburg',    'bantu.m@company.co.za',    1, 4, 2, 2),
    ('Lerato',  'Mokoena',    'Female', '66 River Rd, Pretoria',      'lerato.m@company.co.za',   4, 1, 5, 5);

SELECT * FROM Employees;

-- -----------------------------------------------------------
-- Full detail view — joins all tables together
-- -----------------------------------------------------------
SELECT * FROM vw_employee_detail;

-- ============================================================
--  END OF SCRIPT
-- ============================================================
-- CREATE TABLE teachers (
-- 	id bigserial,
-- 	first_name varchar(25),
-- 	last_name varchar(50),
-- 	school varchar(50),
-- 	hire_date date,
-- 	salary numeric
-- );

-- INSERT INTO teachers (first_name, last_name, school, hire_date, salary)
-- VALUES ('Janet', 'Smith', 'F.D. Roosevelt HS', '2011-10-30', 36200),
-- 	   ('Lee', 'Reynolds', 'F.D. Roosevelt HS', '1993-05-22', 65000),
-- 	   ('Samuel', 'Cole', 'Myers Middle School', '2005-08-01', 43500),
-- 	   ('Samantha', 'Bush', 'Myers Middle School', '2011-10-30', 36200),
-- 	   ('Betty', 'Diaz', 'Myers Middle School', '2005-08-30', 43500),
-- 	   ('Kathleen', 'Roush', 'F.D. Roosevelt HS', '2010-10-22', 38500);

-- SELECT * FROM teachers;
-- CREATE TABLE animal_types (
--     type_id SERIAL PRIMARY KEY,
--     common_name VARCHAR(100) NOT NULL,
--     scientific_name VARCHAR(150),
--     classification VARCHAR(50), -- Mammal, Bird, Reptile, etc.
--     diet VARCHAR(50),           -- Herbivore, Carnivore, Omnivore
--     habitat VARCHAR(100),       -- Savannah, Arctic, Jungle, etc.
--     conservation_status VARCHAR(50) -- Endangered, Vulnerable, etc.
-- );

-- SELECT * FROM animal_types;
-- INSERT INTO animal_types (common_name, scientific_name, classification, diet, habitat, conservation_status)
-- VALUES
-- ('Lion', 'Panthera leo', 'Mammal', 'Carnivore', 'Savannah', 'Vulnerable'),
-- ('Giraffe', 'Giraffa camelopardalis', 'Mammal', 'Herbivore', 'Savannah', 'Vulnerable'),
-- ('Penguin', 'Aptenodytes forsteri', 'Bird', 'Carnivore', 'Antarctic', 'Near Threatened');


-- INSERT INTO animal_types (common_name, scientific_name, classification, diet, habitat, conservation_status)
-- VALUES ('African Elephant', 'Loxodonta africana', 'Mammal',
CREATE TABLE animals (
    animal_id SERIAL PRIMARY KEY,
    name VARCHAR(100), -- Optional (not all animals are named)
    type_id INT NOT NULL,
    date_of_birth DATE,
    sex VARCHAR(10),
    arrival_date DATE,
    health_status VARCHAR(100),
    enclosure_number VARCHAR(50),  -- 👈 missing comma added here

    CONSTRAINT fk_animal_type
        FOREIGN KEY (type_id)
        REFERENCES animal_types(type_id)
        ON DELETE CASCADE
);

INSERT INTO animals (name, type_id, date_of_birth, sex, arrival_date, health_status, enclosure_number)
VALUES
('Simba', 1, '2018-05-10', 'Male', '2019-06-01', 'Healthy', 'A1'),
('Melman', 2, '2015-03-20', 'Male', '2016-07-15', 'Healthy', 'B2'),
('Pingu', 3, '2020-11-01', 'Female', '2021-01-10', 'Under Observation', 'C3');
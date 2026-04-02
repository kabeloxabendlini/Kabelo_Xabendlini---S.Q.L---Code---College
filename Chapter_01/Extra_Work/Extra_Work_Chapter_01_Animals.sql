-- CREATE TABLE animals (
--     animal_id SERIAL PRIMARY KEY,
--     name VARCHAR(100),
--     type_id INT NOT NULL,
--     date_of_birth DATE,
--     sex VARCHAR(10),
--     arrival_date DATE,
--     health_status VARCHAR(100),
--     enclosure_number VARCHAR(50),

--     CONSTRAINT fk_animal_type
--         FOREIGN KEY (type_id)
--         REFERENCES animal_types(type_id)
--         ON DELETE CASCADE
-- );

INSERT INTO animals (name, type_id, date_of_birth, sex, arrival_date, health_status, enclosure_number)
VALUES
('Simba', 1, '2018-05-10', 'Male', '2019-06-01', 'Healthy', 'A1'),
('Melman', 2, '2015-03-20', 'Male', '2016-07-15', 'Healthy', 'B2'),
('Pingu', 3, '2020-11-01', 'Female', '2021-01-10', 'Under Observation', 'C3');

SELECT * FROM public.animals
ORDER BY animal_id ASC 
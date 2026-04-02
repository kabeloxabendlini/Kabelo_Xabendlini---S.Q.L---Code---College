-- CREATE TABLE animal_types (
--     type_id SERIAL PRIMARY KEY,
--     common_name VARCHAR(100) NOT NULL,
--     scientific_name VARCHAR(150),
--     classification VARCHAR(50), -- Mammal, Bird, Reptile, etc.
--     diet VARCHAR(50),           -- Herbivore, Carnivore, Omnivore
--     habitat VARCHAR(100),       -- Savannah, Arctic, Jungle, etc.
--     conservation_status VARCHAR(50) -- Endangered, Vulnerable, etc.
-- );

INSERT INTO animal_types (common_name, scientific_name, classification, diet, habitat, conservation_status)
VALUES
('Lion', 'Panthera leo', 'Mammal', 'Carnivore', 'Savannah', 'Vulnerable'),
('Giraffe', 'Giraffa camelopardalis', 'Mammal', 'Herbivore', 'Savannah', 'Vulnerable'),
('Penguin', 'Aptenodytes forsteri', 'Bird', 'Carnivore', 'Antarctic', 'Near Threatened');

SELECT * FROM public.animal_types
ORDER BY type_id ASC 
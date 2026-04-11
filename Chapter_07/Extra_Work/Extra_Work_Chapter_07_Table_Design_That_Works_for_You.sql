-- CREATE TABLE albums (
--     album_id            bigserial,
--     album_catalog_code  varchar(100) NOT NULL,
--     album_title         text         NOT NULL,
--     album_artist        text         NOT NULL,
--     album_release_date  date,
--     album_genre         varchar(40),
--     album_description   text,
--     CONSTRAINT albums_id_key PRIMARY KEY (album_id),
--     CONSTRAINT albums_catalog_code_unique UNIQUE (album_catalog_code)
-- );

-- CREATE TABLE songs (
--     song_id     bigserial,
--     song_title  text    NOT NULL,
--     song_artist text    NOT NULL,
--     album_id    bigint  NOT NULL REFERENCES albums (album_id) ON DELETE CASCADE,
--     CONSTRAINT songs_id_key PRIMARY KEY (song_id)
-- );

CREATE INDEX albums_title_idx      ON albums (album_title);
CREATE INDEX albums_artist_idx     ON albums (album_artist);
CREATE INDEX albums_genre_idx      ON albums (album_genre);
CREATE INDEX albums_release_idx    ON albums (album_release_date);
CREATE INDEX songs_title_idx       ON songs (song_title);
CREATE INDEX songs_album_id_idx    ON songs (album_id);
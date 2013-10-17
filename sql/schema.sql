DROP TABLE IF EXISTS events CASCADE;
DROP SEQUENCE IF EXISTS event_id_seq;

DROP TABLE IF EXISTS users CASCADE;
DROP SEQUENCE IF EXISTS user_id_seq;

CREATE SEQUENCE user_id_seq;
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('user_id_seq'),
    email TEXT NOT NULL
);

CREATE SEQUENCE event_id_seq;
CREATE TABLE events (
    event_id    INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('event_id_seq'),
    event_uuid  UUID NOT NULL DEFAULT uuid_generate_v4(),
    user_id     INTEGER NOT NULL REFERENCES users(user_id),
    name        TEXT NOT NULL,
    url         TEXT,
    description TEXT
);

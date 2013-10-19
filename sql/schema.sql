CREATE SEQUENCE user_id_seq;
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('user_id_seq'),
    email TEXT NOT NULL
);

CREATE TABLE events (
    event_id    UUID NOT NULL,
    user_id     INTEGER NOT NULL REFERENCES users(user_id),
    name        TEXT,
    url         TEXT,
    description TEXT,
    start_date  DATE,
    end_date    DATE,
    start_time  TIME WITHOUT TIME ZONE,
    end_time    TIME WITHOUT TIME ZONE,
    attributes  JSON,
    created     TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    updated     TIMESTAMP WITHOUT TIME ZONE,
    keypass     TEXT NOT NULL
);

CREATE TABLE queued_events (
    LIKE events INCLUDING ALL
);

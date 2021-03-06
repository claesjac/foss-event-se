DROP TABLE users CASCADE;
DROP SEQUENCE user_id_seq;

DROP TABLE events;
DROP TABLE queued_events;

DROP FUNCTION create_event(TEXT, TEXT);
DROP FUNCTION update_event(TEXT, TEXT, UUID, TEXT, TEXT, TEXT, TEXT, POINT, DATE, DATE, TIME WITHOUT TIME ZONE, TIME WITHOUT TIME ZONE, JSON);
DROP FUNCTION approve_event(UUID);
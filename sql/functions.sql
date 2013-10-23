CREATE OR REPLACE FUNCTION create_event(_email TEXT, _keypass TEXT) RETURNS UUID AS $$
DECLARE
    _user_id INTEGER;
    _event_id UUID;
BEGIN
    SELECT user_id INTO _user_id FROM users WHERE LOWER(email) = LOWER(_email);
    IF NOT FOUND THEN
        RAISE NOTICE 'No user with given email %, creating one...', _email;
        INSERT INTO USERS (email) VALUES(_email) RETURNING user_id INTO _user_id;        
    END IF;
    
    _event_id := uuid_generate_v4();
    
    INSERT INTO queued_events (event_id, user_id, keypass) VALUES(_event_id, _user_id, encode(digest(_keypass, 'sha1'), 'hex'));
    
    RAISE NOTICE 'Created event % for user %', _event_id, _user_id;

    RETURN _event_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_event(
    _email TEXT, _keypass TEXT,
    _event_id UUID, _name TEXT, _description TEXT, _url TEXT,
    _address TEXT, _location POINT,
    _start_date DATE, _end_date DATE, _start_time TIME WITHOUT TIME ZONE, _end_time TIME WITHOUT TIME ZONE, 
    _attributes JSON
) RETURNS VOID AS $$
DECLARE
    _user_id INTEGER;
    _event_keypass TEXT;
    _event_user_id INTEGER;
BEGIN
    SELECT user_id INTO _user_id FROM users WHERE LOWER(email) = LOWER(_email);
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No user with given email %', _email;
    END IF;

    _keypass := encode(digest(_keypass, 'sha1'), 'hex');
    
    SELECT user_id, keypass INTO _event_user_id, _keypass FROM queued_events WHERE event_id = _event_id;
    IF NOT FOUND THEN
        SELECT user_id, keypass INTO _event_user_id, _event_keypass FROM events WHERE event_id = _event_id;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'No event registered with that UUID for the given user';
        END IF;            

        IF _user_id != _event_user_id THEN
            RAISE EXCEPTION 'Events can only be edited by originating poster';
        END IF;
        
        IF _event_keypass != _keypass THEN
            RAISE EXCEPTION 'Update not allowed. Wrong keypass';
        END IF;
        
        INSERT INTO queued_events (event_id, user_id, name) VALUES(_event_id, _user_id, _name);
    ELSE
        IF _user_id != _event_user_id THEN
            RAISE EXCEPTION 'Events can only be edited by originating poster';
        END IF;

        IF _event_keypass != _keypass THEN
            RAISE EXCEPTION 'Update not allowed. Wrong keypass';
        END IF;
    END IF;
    
    UPDATE queued_events 
       SET name = _name, description = _description, 
           url = _url,
           address = _address, location = _location,
           start_date = _start_date, end_date = _end_date,
           start_time = _start_time, end_time = _end_time,
           attributes = _attributes,
           updated = NOW()
     WHERE event_id = _event_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION approve_event(_event_id UUID) RETURNS VOID AS $$
BEGIN
    DELETE FROM events WHERE event_id = _event_id;
    INSERT INTO events SELECT * FROM queued_events WHERE event_id = _event_id;
    DELETE FROM queued_events WHERE event_id = _event_id;
END;
$$ LANGUAGE plpgsql;

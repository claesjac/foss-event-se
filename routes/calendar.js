/*
 * GET home page.
 */

exports.view = function(req, res) {
    global.pg.query("\
  SELECT event_id, name, description, url, start_date::text, end_date::text, start_time, end_time, attributes \
    FROM events \
   WHERE start_date > NOW() - interval '1 week' \
ORDER BY start_date, start_time ASC",
    function(err, result) {
        if (err) {
            console.error(err);
            res.json(500, {"msg": err});
            return
        }
        
        events = [];
        for (i = 0; i < result.rowCount; i++) {
            row = result.rows[i];
            
            all_day = !row.start_time && !row.end_time ? true : false;
            
            start = row.start_date;
            if (row.start_time) {
                start += "T" + row.start_time;
            }

            end = row.end_date;
            if (row.end_time) {
                end += "T" + row.end_time;
            }
            
            event = {
                "id": row.event_id,
                "title": row.name,
                "description": row.description,
                "allDay": all_day,
                "start": start,
                "end": end,
                "url": row.url,
            };
                        
            events.push(event);
        }
        
        res.json(200, events);
    });
};
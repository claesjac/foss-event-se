/*
 * GET home page.
 */

exports.create = function(req, res) {    
    email = req.body.email;
    keypass = req.body.keypass;
    
    if (!(email && keypass)) {
        res.render("error", {message: "missing email or keypass"});
        return;
    }
    
    global.pg.query("SELECT create_event($1, $2) AS event_id", [email, keypass], function(err, result) {
        if (err) {
            res.render("error", {message: err});
            return;
        }

        res.cookie("email", email);
        res.cookie("keypass", keypass);
        
        res.redirect("/update/" + result.rows[0].event_id);
    });
};

function render_update_page(event_id, req, res) {
    global.pg.query("\
SELECT event_id, name, description, url, address, location, start_date::text, end_date::text, start_time::text, end_time::text, attributes::text \
  FROM queued_events \
 WHERE event_id = $1 \
", [event_id], function(err, result) {
        if (err) {
            res.render("error", {message: err});
            return;
        }
        
        if (result.rowCount == 0) {
            res.render("error", {message: "No event with id " + event_id});
            return;        
        }

        if (result.rowCount > 1) {
            res.render("error", {message: "Too many rows returned for id " + event_id});
            return;        
        }
        
        evt = result.rows[0];
        console.log(evt);
        
        location = evt.location ? evt.location.match(/^\((-?\d+\.\d+)\s*,\s*(-?\d+\.\d+)\)$/) : ["", "",""];
        
        console.log(location);
        
        res.render("update", {
            event_id: event_id,
            name: evt.name,
            description: evt.description,
            url: evt.url,
            start_date: evt.start_date,
            start_time: evt.start_time,
            end_date: evt.end_date,
            end_time: evt.end_time,
            attributes: evt.attributes,
            address: evt.address,
            lat: location[1],
            lng: location[2],
        });
    });
}

exports.update = function(req, res) {
    event_id = req.param("event_id");
    if (!event_id) {
        res.render("error", { message: "No event ID given" });
        return;        
    }
    
    if (!req.cookies) {
        res.render("error", { message: "No cookies" });
        return;
    }
    
    email = req.cookies.email;
    keypass = req.cookies.keypass;
    
    if (!(email && keypass)) {
        res.render("error", { message: "Not authenticated" });
        return;
    }
    
    if (req.body && req.body.action == "save") {
        name = req.body.name || "Inget namn angivet...";
        url = req.body.url || null;  
        description = req.body.description || null;
        start_date = req.body.start_date || null;
        start_time = req.body.start_time || null;
        end_date = req.body.end_date || null;
        end_time = req.body.end_time || null;
        attributes = req.body.attributes || null;   
        address = req.body.address || null;
        lat = req.body.lat || null;
        lng = req.body.lng || null;
        
        location = lat && lng ? lat + ", " + lng : null;
        
        global.pg.query(
            "SELECT update_event($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)", 
            [ email, keypass, event_id, name, description, url, address, location, start_date, end_date, start_time, end_time, attributes ],
            function (err, result) {
                if (err) {
                    res.render("error", { message: err });
                    return;
                }
                
                render_update_page(event_id, req, res);
            }
        )

        return;
    }
    
    render_update_page(event_id, req, res);
}


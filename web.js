
/**
 * Module dependencies.
 */

var express = require('express')
   , pg = require('pg').native
   , connectionString = process.env.DATABASE_URL || 'postgres://localhost:5432/foss-event-se'
   , http = require('http')
   , path = require('path')
   , routes = require('./routes')
   , calendar = require('./routes/calendar')
   , events = require('./routes/events')
   , client;

var app = express();

client = new pg.Client(connectionString);
client.connect();

// all environments
app.set('port', process.env.PORT || 5000);
app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.bodyParser());
app.use(express.cookieParser());
app.use(express.methodOverride());
app.use(app.router);
app.use(express.static(path.join(__dirname, 'public')));

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

global.pg = client;

app.get('/', routes.index);
app.get('/calendar', calendar.view);
app.post('/create', events.create);
app.get('/update/:event_id', events.update);
app.post('/update/:event_id', events.update);

http.createServer(app).listen(app.get('port'), function() {
  console.log('Express server listening on port ' + app.get('port'));
});

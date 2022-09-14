module main

import vweb
import sqlite
import net.http
import x.json2
import os
import rand

struct App {
	vweb.Context
pub mut:
	db sqlite.DB
}

fn main() {
	db_path := os.getenv_opt("DB_PATH") or { ":memory:" }
	mut app := App{
		db: sqlite.connect(db_path) or { panic(err) }
	}

	sql app.db {
		create table Friend
	}

	vweb.run_at(app, vweb.RunParams{
		port: 8081,
		host: os.getenv("WEB_HOST")
		family: .ip,
	}) or { panic(err) }
}

['/index']
pub fn (mut app App) index() ?vweb.Result {
	return $vweb.html()
}

[post]
pub fn (mut app App) new_friend(name string) ?vweb.Result {
	if name == '' {
		return app.text('How rude.')
	}

	ip := app.ip().split(":")[0]
	mut request := http.Request{
		url: 'https://json.geoiplookup.io/$ip'
		method: .get
	}
	result := request.do() ?
	response := json2.raw_decode(result.text) ?.as_map()
	mut lon := response["longitude"] or { "" }.f64()
	mut lat := response["latitude"] or { "" }.f64()

	// I do hope no one lives in Sao Tome ;)
	if lon != 0 && lat != 0 {
		// add some random noise to offset IP geolocation being concentrated in provider locations
		lat += rand.f64()*0.6-0.3
		lon += rand.f64()*0.6-0.3
	}

	friend := Friend{
		name: name
		lon: lon
		lat: lat
	}

	sql app.db {
		insert friend into Friend
	}
	return app.redirect('/friends')
}

['/friends']
pub fn (mut app App) friends() vweb.Result {
	friends := app.find_all_friends()
	located_friends := friends.filter(it.lon != 0 && it.lat != 0)
	visitors := friends.map(it.name).join(", ")
	myself := Friend {
		name: "myself"
		lat: 51.0771
		lon: 17.0
	}
	return $vweb.html()
}

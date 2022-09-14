module main

import vweb
import sqlite
import net.http
import x.json2
import os

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
		create table Article
	}

	first_article := Article{
		title: 'Hello, world!'
		text: 'V is great.'
	}

	second_article := Article{
		title: 'Second post.'
		text: 'Hm... what should I write about?'
	}

	sql app.db {
		insert first_article into Article
		insert second_article into Article
	}
	vweb.run_at(app, vweb.RunParams{
		port: 8081,
		host: os.getenv("WEB_HOST")
		family: .ip,
	}) or { panic(err) }
}

['/index']
pub fn (mut app App) index() ?vweb.Result {
	ip := app.ip().split(":")[0]
	mut request := http.Request{
		url: 'https://json.geoiplookup.io/$ip'
		method: .get
	}
	result := request.do() ?
	raw_data := json2.raw_decode(result.text) ?
	message := 'Hello, world from Vweb!. You are from $ip We have $result.text'

	articles := app.find_all_articles()
	return $vweb.html()
}

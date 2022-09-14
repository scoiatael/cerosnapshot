module main

struct Friend {
	id    int    [primary; sql: serial]
	name string
	lon  f64
	lat  f64
}

pub fn (app &App) find_all_friends() []Friend {
	return sql app.db {
		select from Friend
	}
}

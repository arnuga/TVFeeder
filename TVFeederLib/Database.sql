CREATE TABLE Feeds (
	feed_id		INTEGER	PRIMARY	KEY,
	name		TEXT,
	url			TEXT,
	latest_scan	DATE
);

CREATE TABLE FeedEntries (
	entry_id		INTEGER PRIMARY KEY,
	feed_id			INTEGER,
	original_title	TEXT,
	original_url	TEXT,
	time_created	DATE
);

CREATE TABLE Shows (
	show_id		INTEGER PRIMARY KEY,
	show_name	TEXT,
	thetvdb_no	INTEGER
);

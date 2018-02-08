cqlsh -e "create keyspace test with replication = {'class':'SimpleStrategy','replication_factor' : 1}"
cqlsh -e "create table test.users ( uid int PRIMARY KEY, age int, gender text, occupation text, zip text)"
cqlsh -e "create table test.movies (  movieid int, title text, genres set<text>, year int, primary key (movieid,year))"
cqlsh -e "create table test.ratings_s ( rmid int, rating double, ruid int,timestamp timestamp,primary key(rmid, rating, ruid))"
cqlsh -e "create table test.ratings( mid int,uid int,rating double,age int,gender text, genres set<text>,occupation int,rating_time timestamp,title text, year text,zip text,PRIMARY KEY (mid, uid, rating)) WITH CLUSTERING ORDER BY (uid ASC, rating DESC)"
cqlsh -e "copy test.movies(movieid, title, genres,year) from '/data/movies.csv' with header = true"
cqlsh -e "copy test.ratings_s(ruid, rmid, rating, timestamp) from '/data/ratings_s.csv' with header = true"
cqlsh -e "copy test.ratings(uid, age, gender, occupation, zip, rating, rating_time, mid, title, year, genres) from '/data/ratings.csv' with header = true"
cqlsh -e "copy test.users(uid,gender,age,occupation,zip) from '/data/users.csv' with header = true"
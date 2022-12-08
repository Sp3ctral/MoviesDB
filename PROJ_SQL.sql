CREATE TABLE person(
    id smallint NOT NULL,
    first_name VARCHAR(80),
    last_name VARCHAR(80),
    dowStart smallint,
    dowEnd smallint,
    dob smallint,
    dod smallint,
    country VARCHAR(80), 
    PRIMARY KEY (id)
);

CREATE TABLE actor(
    person_id smallint NOT NULL,
    stage_name VARCHAR(80) NOT NULL,
    gender VARCHAR(1),
    role_type VARCHAR(80),
    start_year smallint,
    end_year smallint,
    PRIMARY KEY (stage_name),
    FOREIGN KEY (person_id) REFERENCES person(id) ON DELETE CASCADE
);

CREATE TABLE movie(
    id VARCHAR(10) NOT NULL,
    title VARCHAR(80) NOT NULL,
    year smallint,
    genre VARCHAR(90),
    Location VARCHAR(100),
    PRIMARY KEY (id)
);

CREATE TABLE award(
    id VARCHAR(15) NOT NULL,
    awarding_org VARCHAR(80) NOT NULL,
    location VARCHAR(80),
    name VARCHAR(80),
    PRIMARY KEY (id)
);

create table studio (
    id smallint not null,
    name varchar(80),
    company varchar(80),
    city varchar(80),
    location varchar(80),
    start_year smallint,
    end_year smallint,
    founder varchar(80),
    successor varchar(80),
    PRIMARY KEY (id)
);

CREATE TABLE remakes(
    movie_id VARCHAR(10) NOT NULL, 
    priorFilmId VARCHAR(10) NOT NULL,
    fraction FLOAT,
    PRIMARY KEY (movie_id, priorFilmId),
    FOREIGN KEY (movie_id) REFERENCES MOVIE(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (priorFilmId) REFERENCES MOVIE(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE casts_in(
    movie_id VARCHAR(10) NOT NULL, 
    stage_name VARCHAR(40) NOT NULL, 
    role_type VARCHAR(30), 
    role_desc VARCHAR(160), 
    role_name VARCHAR(30), 
    award_id VARCHAR(15),
    PRIMARY KEY (movie_id, stage_name),
    FOREIGN KEY (movie_id) REFERENCES MOVIE(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (stage_name) REFERENCES ACTOR(stage_name) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (award_id) REFERENCES award(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE directs(
    person_id smallint NOT NULL,
    movie_id VARCHAR(10) NOT NULL,
    PRIMARY KEY (person_id, movie_id),
    FOREIGN KEY (person_id) REFERENCES person(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES movie(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE produces(
    person_id smallint NOT NULL,
    movie_id VARCHAR(10) NOT NULL,
    PRIMARY KEY (person_id, movie_id),
    FOREIGN KEY (person_id) REFERENCES PERSON(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES MOVIE(id) ON DELETE CASCADE ON UPDATE CASCADE
);

create table made_by(
    studio_id smallint NOT NULL,
    movie_id varchar(10) NOT NULL,
    PRIMARY KEY (studio_id, movie_id),
    FOREIGN KEY (studio_id) references studio(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (movie_id) references movie(id) ON DELETE CASCADE ON UPDATE CASCADE
); 

create table movie_receives_award(
    movie_id varchar(10) NOT NULL,
    award varchar(140) NOT NULL,
    FOREIGN KEY (movie_id) references movie(id) ON DELETE CASCADE ON UPDATE CASCADE
); 

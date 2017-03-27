
--revise age to DOB (Date of birth) in order to reduce the updating of database 

DROP TABLE IF EXISTS member CASCADE;
DROP TABLE IF EXISTS court_schedule CASCADE;
DROP TABLE IF EXISTS pardon_history CASCADE;
DROP TABLE IF EXISTS court CASCADE;
DROP TABLE IF EXISTS reservation CASCADE;


---create schema
CREATE TABLE member(name VARCHAR(40) Not NULL CHECK (name <> ''),
member_id serial PRIMARY KEY,
gender VARCHAR(4) CONSTRAINT gender_match CHECK(gender in ('F','M','T','','NULL')),
DOB	DATE CONSTRAINT correct_date CHECK (DOB<now()::date ), 
penalty_points INT DEFAULT 0 CONSTRAINT postitve_penatlty_points CHECK ( penalty_points >=0)
);

CREATE TABLE pardon_history(
member_id INT references member(member_id) NOT NULL,
pardoned_date TIMESTAMP  NOT NULL,
PRIMARY KEY (member_id,pardoned_date)
);

CREATE TABLE court(
court_id serial PRIMARY KEY ,
court_location VARCHAR NOT NULL,
court_name VARCHAR NOT NULL,
CONSTRAINT unique_court Unique(court_location,court_name)
);

CREATE TABLE reservation(
reservation_id serial PRIMARY KEY ,
booking_date TIMESTAMP NOT NULL,
play_time TIMESTAMP CONSTRAINT correct_date CHECK(play_time>=booking_date) NOT NULL  ,
member_id INT references member(member_id) ON DELETE CASCADE ON UPDATE CASCADE,
booking_status VARCHAR NOT NULL DEFAULT 'pending',
reserved_court INT references court(court_id) NOT NULL
);

CREATE TABLE court_schedule(
court_id INT references court(court_id)  ON DELETE CASCADE ON UPDATE CASCADE,
time_slot TIMESTAMP,
RID INT references reservation(reservation_id) ON DELETE CASCADE ON UPDATE CASCADE,
PRIMARY KEY(court_id,time_slot,RID)
);


--create trigger
--update booking status default pending
 
CREATE OR REPLACE FUNCTION check_court()
  RETURNS trigger AS 
$BODY$
	BEGIN
		IF NEW.play_time > now()::date+(7-(SELECT member.penalty_points FROM member WHERE member.member_id = NEW.member_id))
		THEN NEW.booking_status :='unavailable';
		RETURN NEW;
		END IF;
		IF (SELECT count(*) FROM (SELECT * FROM court_schedule where  court_schedule.court_id=New.reserved_court)as foo
		WHERE NEW.play_time between foo.time_slot and foo.time_slot + interval '1 hour' )>=1 THEN 
			NEW.booking_status :='unavailable';
			RETURN NEW;
		ELSE NEW.booking_status :='accepted';
		RETURN NEW;
		END IF;
		
		

	END 
$BODY$
	LANGUAGE plpgsql;

	
DROP TRIGGER IF EXISTS status_update1 ON reservation;
CREATE TRIGGER status_update1
	BEFORE INSERT ON reservation
	FOR EACH ROW
		EXECUTE PROCEDURE check_court();
		
---update booking status default accept
CREATE OR REPLACE FUNCTION status_accept()
  RETURNS trigger AS 
$BODY$
	BEGIN
		IF NEW.booking_status ='accepted' THEN
			INSERT INTO court_schedule(court_id,time_slot,RID)
			SELECT NEW.reserved_court,NEW.play_time,NEW.reservation_id 
			Where NEW.reserved_court not in (SELECT court_id FROM court_schedule)
			and NEW.play_time not in (SELECT time_slot FROM court_schedule)
			and NEW.reservation_id not in (SELECT RID FROM court_schedule);	
		END IF;
		RETURN NEW;
	END 
$BODY$
	LANGUAGE plpgsql;
	
DROP TRIGGER IF EXISTS status_update2 ON reservation;
CREATE TRIGGER status_update2
	AFTER INSERT ON reservation
	FOR EACH ROW
		EXECUTE PROCEDURE status_accept();


---run the procedure when the status 'dropped', 'confirmed' or 'cancelled'
CREATE OR REPLACE FUNCTION set_status()
  RETURNS trigger AS 
$BODY$
	BEGIN
		IF NEW.booking_status='dropped' THEN 
			DELETE FROM pardon_history WHERE pardoned_date<now()::date-42; --6 weeks
			INSERT INTO pardon_history(member_id,pardoned_date) 
			SELECT NEW.member_id,NEW.play_time
			WHERE NEW.member_id not in (SELECT member_id FROM pardon_history) 
			and NEW.play_time not in (SELECT pardoned_date FROM pardon_history);
			UPDATE member 
			SET penalty_points=(SELECT COUNT(*) FROM pardon_history AS A GROUP BY A.member_id)
			WHERE member.member_id=NEW.member_id;
			DELETE FROM court_schedule WHERE New.reservation_id=court_schedule.RID and 
			NEW.reserved_court=court_schedule.court_id;
		END IF;
		IF NEW.booking_status='confirmed' THEN
			--status_change to confirmed 
			INSERT INTO court_schedule(court_id,time_slot,RID)
			SELECT NEW.reserved_court,NEW.play_time,NEW.reservation_id 
			Where NEW.reserved_court not in (SELECT court_id FROM court_schedule)
			and NEW.play_time not in (SELECT time_slot FROM court_schedule)
			and NEW.reservation_id not in (SELECT RID FROM court_schedule);	

		END IF;
		IF NEW.booking_status='cancelled' THEN
			--status_change to confirmed 
			--record of cancelled reservation would be still kept
			DELETE FROM court_schedule
			WHERE court_schedule.court_id=NEW.reserved_court
			and court_schedule.time_slot=NEW.play_time
			and court_schedule.RID=NEW.reservation_id ;
		END IF;
		RETURN NULL;


	END;
$BODY$
	LANGUAGE plpgsql;	


		
DROP TRIGGER IF EXISTS status_update3 ON reservation;

CREATE TRIGGER status_update3
	AFTER UPDATE ON reservation
	FOR EACH ROW
		EXECUTE PROCEDURE set_status();
--before update the confirmed or dropped status needs to check time requirement 
CREATE OR REPLACE FUNCTION check_status()
  RETURNS trigger AS 
$BODY$
	BEGIN
		IF NEW.booking_status='dropped' THEN
			 RETURN NEW;
		END IF;
		IF NEW.booking_status='confirmed' THEN
			IF now()::timestamp<NEW.play_time+interval '10 minutes' and now()::timestamp>NEW.play_time-interval '20 minutes'
			THEN
			--status_change to confirmed 
			RETURN NEW; 
			ELSE RAISE NOTICE 'Confirmed time must be from 20 minutes before until 10 minutes after the hour';
			END IF;
		END IF;
		RETURN NULL;
	END;
$BODY$
	LANGUAGE plpgsql;	

DROP TRIGGER IF EXISTS status_update4 ON reservation;

CREATE TRIGGER status_update4
	BEFORE UPDATE ON reservation
	FOR EACH ROW
		EXECUTE PROCEDURE check_status();

--auto change to dropped in a period
UPDATE reservation
SET booking_status='dropped' WHERE play_time>now()::timestamp+interval '10 minutes';

-- Procedure to add a reservation
CREATE OR REPLACE FUNCTION add_reservation(booking_date TIMESTAMP,
play_time TIMESTAMP,
member_id INT,
reserved_court INT)
RETURNS void AS $$
BEGIN
INSERT INTO reservation(booking_date,play_time,member_id,reserved_court) VALUES(booking_date,play_time,member_id,reserved_court);
END;
$$ LANGUAGE plpgsql;

--Procedure to update_reservation_status
CREATE OR REPLACE FUNCTION update_reservation_status(confirmed_status VARCHAR
,RID INT)
RETURNS void AS $$
BEGIN
update reservation set booking_status=confirmed_status where RID=reservation_id;
END;
$$ LANGUAGE plpgsql;

---list all reservations for a particular date (parameter)
DROP FUNCTION list_all_reservation(date);
CREATE OR REPLACE FUNCTION list_all_reservation(chosen_date DATE)
RETURNS TABLE(reservation_id INT,
member_id INT,
name VARCHAR,
booking_date TIMESTAMP,
play_time TIMESTAMP,
COURT_ID INT,
court_name VARCHAR,
Confirmation_status VARCHAR ) AS $$
BEGIN
	RETURN QUERY
	SELECT A.reservation_id,A.member_id, B.name,A.booking_date, A.play_time as time_when_play, C.court_id,C.court_name, A.booking_status as confirmation_status 
	FROM reservation A,member B,court C 
	WHERE B.member_id=A.member_id and C.court_id =A.reserved_court and A.play_time::date=chosen_date;
END;
$$ LANGUAGE plpgsql;
--now()::date

		
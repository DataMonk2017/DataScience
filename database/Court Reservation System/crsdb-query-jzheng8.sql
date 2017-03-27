



--a.List all of today's reservations (members, times, courts and confirmation status). This might be what the receptionist prints and posts every morning.
--use stored_procedure values(now()::timestamp WITH TIME ZONE) (TO_CHAR(now()::timestamp WITH TIME ZONE,'MM/DD/YYYY'))
--Assume database operate at rochester with Summer time
SET TIMEZONE TO '-4';
SELECT * FROM list_all_reservation(now()::date);
-- or using query
SELECT A.member_id, B.name, A.play_time as time_when_play, C.court_id,C.court_name, A.booking_status as confirmation_status 
FROM reservation A,member B,court C 
WHERE B.member_id=A.member_id and C.court_id =A.reserved_court and TO_CHAR(A.play_time,'MM/DD/YYYY')=TO_CHAR(now()::date,'MM/DD/YYYY');

--b.Show all of member m's reservations (minimally 3; show times, courts and confirmation status) for the next 7 days. Include p: the current number of penalty points incurred by m (must be > 1 for member m).
SELECT * FROM reservation A inner join member B on B.member_id=A.member_id 
inner join court C on C.court_id =A.reserved_court WHERE A.member_id=3;



--c.Add a reservation for member m for some court at some time t for n days from today, where n + p > 7. 

insert into  reservation(booking_date,play_time,member_id,reserved_court)
values (TIMESTAMP '2016-04-15 15:36:38',TIMESTAMP '2016-04-22 9:00:38',3,1);

--Repeat with a different n such that n + p <= 7.
insert into  reservation(booking_date,play_time,member_id,reserved_court)
values (TIMESTAMP '2016-04-15 15:36:38',TIMESTAMP '2016-04-18 23:48:38',3,1);

--or use stored procedure add_reservation
SELECT add_reservation(TIMESTAMP '2016-04-15 15:36:38',TIMESTAMP '2016-04-18 9:00:38',3,2);


SELECT add_reservation(TIMESTAMP '2016-04-15 15:36:38',TIMESTAMP '2016-04-18 9:00:38',3,2);


insert into  reservation(booking_date,play_time,member_id,reserved_court)
values (TIMESTAMP '2016-04-15 15:36:38',TIMESTAMP '2016-04-17 9:00:38',3,3);

insert into  reservation(booking_date,play_time,member_id,reserved_court)
values (TIMESTAMP '2016-04-15 15:36:38',TIMESTAMP '2016-04-16 9:00:38',3,4);


--d.Confirm member m's next reservation.

--previous view
SELECT * From reservation WHERE member_id=3 ;

WITH B AS
(SELECT reservation_id FROM reservation A 
WHERE A.member_id=3 and A.play_time>now()::timestamp and A.booking_status='accepted'
order by (A.play_time-now()::timestamp)limit 1)
update reservation set booking_status='confirmed' FROM B 
where reservation.member_id=3 and reservation.reservation_id=B.reservation_id and B.reservation_id IS NOT NULL ;
--doesnot work since  Confirmed time must be from 20 minutes before until 10 minutes after the hour.
--try another one

--view after update
SELECT * From reservation WHERE member_id=3 ;


--e.Cancel one of member m's upcoming reservations.

--previous view
SELECT * From reservation WHERE member_id=3 ;
WITH B AS
(SELECT reservation_id FROM reservation A 
WHERE A.member_id=3 and A.play_time>now()::timestamp and A.booking_status='accepted'
order by (A.play_time-now()::timestamp)limit 1)
update reservation set booking_status='cancelled' FROM B 
where reservation.member_id=3 and reservation.reservation_id=B.reservation_id and B.reservation_id IS NOT NULL ;
--view after update
SELECT * From reservation WHERE member_id=3;

--f.Show all of m's reservations again, as before.
SELECT * From reservation WHERE member_id=3;

--g.Add any additional queries and commands you deem appropriate to show off the effectiveness of your constraints.
--I build several triggers. Before insert column into Table resevation, the system will check the available court
--if availabe, it will automatically change the booking status to 'accepted'
--if not avalabe, may becuase the date is far way from n -penalty points, it will automatically change the booking status to 'unavailable'

--Also every time update the status, the corresponding Table court schedule will delete or insert.
--For example,I update booking status of the reseavtion id = 5 tp 'dropped'
--1.
--previous view
SELECT * FROM court_schedule;
--updating
update reservation set booking_status='dropped' where reservation_id=5;
--view after update
SELECT * FROM court_schedule;

--2.DROP member on casacde
--I drop the member_id=2 in member 
--the resevation correlating to member_id=2 is also dropped. 
SELECT A.member_id FROM reservation A WHERE A.member_id=2 ;

DELETE From member WHERE member.member_id=2;

SELECT A.member_id FROM reservation A WHERE A.member_id=2 ;

--3.file definitions of stored procedures (in any language supported by PostgreSQL, preferably plpgsql) for listing all reservations for a particular date (parameter)
--i have already show the results in a. I will show here again.
SET TIMEZONE TO '-4';
SELECT * FROM list_all_reservation(now()::date);
--4.for making a reservation for a member on a particular date and time (parameters)
--i have already show the results in c. I will show here again.
-- use stored procedure add_reservation
--before
SELECT * FROM reservation where member_id=3 and reserved_court=2;
SELECT add_reservation(TIMESTAMP '2016-04-17 15:36:38',TIMESTAMP '2016-04-18 23:45:38',3,2);
--after
SELECT * FROM reservation where member_id=3 and reserved_court=2;
--5. and for confirming and canceling a reservation (with appropriate parameters). 
-- use stored procedure update_reservation_status.
SELECT * FROM reservation where reservation_id=18;
SELECT update_reservation_status('pending',18);
SELECT * FROM reservation where reservation_id=18;
SELECT update_reservation_status('confirmed',18);
SELECT * FROM reservation where reservation_id=18;

--DELETE FROM member;
--member
insert into member(name,gender,DOB)
values ('Jason Martin', 'M',to_date('19960725','YYYYMMDD'));

insert into member(name,gender,DOB)
values ('James Smith', 'M',to_date('19781212','YYYYMMDD'));

insert into member(name,gender,DOB)
values ('Alison Mathews','M',to_date('19760321','YYYYMMDD') );

insert into member(name,gender,DOB)
values ('Celia Rice', 'F' ,  to_date('19821024','YYYYMMDD'));

insert into member(name,gender,DOB)
values ('Robert Black', 'M' ,  to_date('19840115','YYYYMMDD'));

insert into member(name,gender,DOB)
values ('Linda GREEN', 'F' ,  to_date('19870730','YYYYMMDD'));

insert into member(name,gender,DOB)
values ('Jasmine Rice', 'F' ,  to_date('19901231','YYYYMMDD'));

insert into member(name,gender,DOB)
values ('Morris Cat', 'F' ,  to_date('19921231','YYYYMMDD'));

SELECT * From member;


--court
insert into  court(court_location,court_name)
values ('5795 Madison Street, Amsterdam, NY 12010','court rice');

insert into  court(court_location,court_name)
values ('6475 Route 5, Astoria, NY 11102','court sushi');

insert into  court(court_location,court_name)
values ('6532 Canal Street, Mebane, NC 27302','court curry');
insert into  court(court_location,court_name)
values ('3538 State Street, Encino, CA 91316','court ham');
insert into  court(court_location,court_name)
values ('781 Devon Road, Winter, Haven, FL 33880','court fruit');
insert into  court(court_location,court_name)
values ('6532 Canal Street, Mebane, NC 27302','court veggie');
insert into  court(court_location,court_name)
values ('4902 Woodland Avenu, Shakopee, MN 55379','court pizza');
insert into  court(court_location,court_name)
values ('998 2nd Street West,Smyrna, GA 30080','court meow');
insert into  court(court_location,court_name)
values ('6532 Canal Street, Mebane, NC 27302','court wurf');
SELECT * From court;
--reservation
insert into  reservation(booking_date,play_time,member_id,reserved_court)
values (TIMESTAMP '2016-04-16 15:36:38', TIMESTAMP '2016-04-18 17:36:38', 3,2);
insert into  reservation(booking_date,play_time,member_id,reserved_court)
values (TIMESTAMP '2016-04-17 16:36:38', TIMESTAMP '2016-04-18 15:36:38', 3,2);
insert into  reservation(booking_date,play_time,member_id,reserved_court)
values (TIMESTAMP '2016-04-16 17:36:38', TIMESTAMP '2016-04-18 18:36:38', 3,5);
insert into  reservation(booking_date,play_time,member_id,reserved_court)
values (TIMESTAMP '2016-04-16 18:36:38', TIMESTAMP '2016-04-20 15:36:38', 3,6);
insert into  reservation(booking_date,play_time,member_id,reserved_court)
values (TIMESTAMP '2016-04-16 19:36:38', TIMESTAMP '2016-04-19 15:36:38', 4,1);
insert into  reservation(booking_date,play_time,member_id,reserved_court)
values (TIMESTAMP '2016-04-20 17:36:38', TIMESTAMP '2016-04-26 15:36:38', 5,3);
insert into  reservation(booking_date,play_time,member_id,reserved_court)
values (TIMESTAMP '2016-04-21 15:36:38', TIMESTAMP '2016-04-21 15:36:38', 1,4);
insert into  reservation(booking_date,play_time,member_id,reserved_court)
values (TIMESTAMP '2016-04-16 12:36:38', TIMESTAMP '2016-04-18 15:36:38', 6,5);
insert into  reservation(booking_date,play_time,member_id,reserved_court)
values (TIMESTAMP '2016-04-19 17:36:38', TIMESTAMP '2016-04-28 15:36:38', 2,1);
insert into  reservation(booking_date,play_time,member_id,reserved_court)
values (TIMESTAMP '2016-04-18 15:36:38', TIMESTAMP '2016-04-29 15:36:38', 3,1);
insert into  reservation(booking_date,play_time,member_id,reserved_court)
values (TIMESTAMP '2016-04-17 16:36:38', TIMESTAMP '2016-04-30 15:36:38', 4,3);
insert into  reservation(booking_date,play_time,member_id,reserved_court)
values (TIMESTAMP '2016-04-16 14:36:38', TIMESTAMP '2016-04-22 15:36:38', 5,5);
insert into  reservation(booking_date,play_time,member_id,reserved_court)
values (TIMESTAMP '2016-04-14 12:36:38', TIMESTAMP '2016-04-24 15:36:38', 6,6);
insert into  reservation(booking_date,play_time,member_id,reserved_court)
values (TIMESTAMP '2016-04-15 14:36:38', TIMESTAMP '2016-04-18 21:36:38', 2,7);
insert into  reservation(booking_date,play_time,member_id,reserved_court)
values (TIMESTAMP '2016-04-18 15:36:38', TIMESTAMP '2016-04-21 15:36:38', 1,8);
insert into  reservation(booking_date,play_time,member_id,reserved_court)
values (TIMESTAMP '2016-04-19 18:36:38', TIMESTAMP '2016-04-27 15:36:38', 1,4);

--penatlty points change to 3 for member_id =3
update member set penalty_points = 3 where member_id=3;

1. -- What movies (list title and year) have "george" (in any form) at the end of their titles. Order by the title.

SELECT title
FROM movie
WHERE RIGHT(title, 6) ilike 'george'
ORDER BY title;

--> 4 rows 

2. -- Has any actor ever appeared in both a movie and an immediate remake of an immediate remake? If so, list the 
   -- actor's stagename, the movie titles, the years, and the roles. Order by stagename, year, and movie title.

select distinct a1.stage_name, m1.title, m2.title, m1.year, m2.year, a1.role_desc, a2.role_desc
from casts_in as a1
join movie as m1 on a1.movie_id = m1.id
join remakes as r1 on m1.id = r1.priorfilmid
join remakes as r2 on r1.movie_id = r1.priorfilmid
join movie as m2 on m2.id = r2.movie_id
join casts_in as a2 on a2.movie_id = m2.id
where a1.stage_name = a2.stage_name
order by a1.stage_name, m1.year, m1.title;

--> 26 rows

3. -- Which immediate remake is most simmilar to the original movie (i.e., has the highest percentage)? Show the title, 
   -- year, director for the original movie and the remake along with the percentage of similarity between them.

select max(fraction), original.title, original.year, firstDir.first_name, remake.title, remake.year, secondDir.last_name
from remakes as r
join movie as original on r.priorfilmid = original.id
join directs as oridir on oridir.movie_id = original.id
join person as firstDir on oridir.person_id = firstDir.id
join movie as remake on r.movie_id = remake.id
join directs as priDir on priDir.movie_id = remake.id
join person as secondDir on priDir.person_id = secondDir.id
where r.fraction = (select max(r2.fraction) from remakes as r2)
group by original.title, original.year, firstDir.first_name, remake.title, remake.year, secondDir.last_name;

--> 18 rows

4. -- Which movie has been remade (directly or indirectly) the most times over all (i.e., is the ancestor of the most 
   -- remakes)?

with recursive findAncestor(priorfilmid, movie_id, depth) AS
(
  select r.priorfilmid, r.movie_id, 0
  from remakes r
  where not exists
   (
     select r2. priorfilmid
     from remakes as r2
     where r2. priorfilmid = r.movie_id
   )

   union all
 
   select remakes.priorfilmid, remakes.movie_id, findAncestor.depth + 1
   from remakes join findAncestor on findAncestor.priorfilmid = remakes.movie_id
)
  
select max(depth), title from findAncestor
join movie on priorfilmid = id
group by priorfilmid, depth, title
order by depth desc;

--> 1 row

5. -- Which movies are neither a remake nor have ever been remade? Order by title.

select * from movie m
where not exists 
   (
      select priorfilmid, movie_id
      from remakes r
      where r.priorfilmid = m.id or r.movie_id = m.id
   )
  order by title;

--> 10,981 rows

6. -- List the stagename of actors that have won an Academy Award for their role in a movie; include their name and 
   -- role, the name of the movie they won the award for, and the year they won; order the list by the year the movie
   -- was made.

select stage_name, first_name, role_name, title, year
from casts_in as c
natural join actor
join person as p
on p.id = actor.person_id
join movie as m
on c.movie_id = m.id
join award as a
on a.id = c.award_id
where a.awarding_org ilike '%academy%'
order by year;

--> 20 rows

7. -- Which movies, by name, won Academy Awards in 1970?

select m.title
from movie as m
join movie_receives_award as mra
on m.id = mra.movie_id
where mra.award ilike '%AA%' and m.year = 1970;

--> 3 rows

8. -- Has any original movie and an immediate remake both won won an Academy Award? If so, list the name of the
   -- original and the remake along with the year for each ordered by name of the original and remake.

select ori.title, rem.title, ori.year, rem.year
from movie as ori
join remakes as r
on ori.id = r.priorfilmid
join movie as rem
on rem.id = r.movie_id
join movie_receives_award as oriA
on ori.id = oriA.movie_id
join movie_receives_award as remA
on rem.id = remA.movie_id
where oriA.award ilike '%AA%' 
AND remA.award ilike '%AA%'
order by ori.title, rem.title;

--> 4 rows

9. -- Find the name and year of the movie that has the shortest title.

SELECT title, year
FROM movie
WHERE LENGTH(title) IN (
  SELECT MIN(LENGTH(title))
  FROM movie
  where length(title) > 0);

--> 5 rows

10. -- What movies did "George Fox" write?

select title from movie as m 
join writer as w on m.id = w.movie_id
where w.first_name = 'george' and 
w.last_name = 'fox';

-- > 1 row


11. -- Are there any actors that have played more than one role in the same movie?! If so, list the movie title, the 
    -- actor's name and the roles they played. Order by movie title, actor's name, and role.

select m.title, p.first_name, p.last_name, c.role_name
from movie as m
join casts_in as c on m.id = c.movie_id
join actor as a on a.stage_name = c.stage_name
join person as p on p.id = a.person_id
where c.role_name like '%,%'
order by m.title, p.first_name, p.last_name, c.role_name;

--> 4,559 rows

12. -- Are there any pairs of actors that appeared together in two different movies released in the same year? If so, 
    -- list the movie titles, the years, the actor's names and the roles they played. Order by movie title, year, 
    -- actor's names, and roles.

select m1.title, m2.title, m1.year, m2.year, c1.stage_name, c2.stage_name, c1.role_name, c3.role_name, c2.role_name, c4.role_name
from casts_in as c1
join movie as m1
on c1.movie_id = m1.id
join casts_in as c2
on c2.movie_id = m1.id
join movie as m2
on m1.year = m2.year
join casts_in as c3
on m2.id = c3.movie_id
join casts_in as c4
on m2.id = c4.movie_id
where c1.stage_name != c2.stage_name
and c3.stage_name != c4.stage_name
and m1.id != m2.id
and c3.stage_name = c1.stage_name
and c4.stage_name = c2.stage_name
and c1.stage_name < c2.stage_name
order by m1.title, m2.title, m1.year, c1.stage_name, c2.stage_name, c1.role_name, c3.role_name, c2.role_name, 
c4.role_name;

--> 1,208 rows

13. -- List the title, year, and role for movies that "Tom Cruise" appeared in ordered by the year.

select m.title, m.year, c.role_name
from movie as m
join casts_in as c
on m.id = c.movie_id
join actor as a
on a.stage_name = c.stage_name
where c.stage_name = 'tom cruise'
order by m.year;

--> 22 rows

14. -- Is there an actor that has appeared in a movie with "Val Kilmer" and also in a movie with "Tom Cruise" other 
    -- than "Top Gun"? Give the co-actor's name, the movie title, and who they appeard with (Cruise or Kilmer).

select c1.stage_name
from casts_in as c1
join casts_in as c2
on c1.movie_id = c2.movie_id
join casts_in as c3
on c1.stage_name = c3.stage_name
join casts_in as c4
on c3.movie_id = c4.movie_id
join movie as m on c1.movie_id = m.id
where c4.stage_name = 'val kilmer'
and c2.stage_name = 'tom cruise'
and c1.stage_name != 'val kilmer'
and c1.stage_name != 'tom cruise'
and m.title != 'top gun';

--> 2 rows

15. -- Give me the names of all actors within "six degrees" of "Kevin Bacon". Specifically, Bacon's co-stars (1st 
    -- degree), the co-star's co-stars (2nd degree), etc. out to "six degrees". List the actors ordered by stagename.

select distinct c1.stage_name
from casts_in as c1 where c1.stage_name = 'kevin bacon'
union
select distinct c3.stage_name
from casts_in as c2 
join casts_in as c3 on c2.movie_id = c3.movie_id
where c2.stage_name = 'kevin bacon'
union
select distinct c7.stage_name
from casts_in as c4
join casts_in as c5 on c4.movie_id = c5.movie_id
join casts_in as c6 on c5.stage_name = c6.stage_name
join casts_in as c7 on c6.movie_id = c7.movie_id
where c4.stage_name = 'kevin bacon'
union
select distinct c13.stage_name
from casts_in as c8
join casts_in as c9 on c8.movie_id = c9.movie_id
join casts_in as c10 on c9.stage_name = c10.stage_name
join casts_in as c11 on c10.movie_id = c11.movie_id
join casts_in as c12 on c11.stage_name = c12.stage_name
join casts_in as c13 on c12.movie_id = c13.movie_id
where c8.stage_name = 'kevin bacon'
union
select distinct c21.stage_name
from casts_in as c14
join casts_in as c15 on c14.movie_id = c15.movie_id
join casts_in as c16 on c15.stage_name = c16.stage_name
join casts_in as c17 on c16.movie_id = c17.movie_id
join casts_in as c18 on c17.stage_name = c18.stage_name
join casts_in as c19 on c18.movie_id = c19.movie_id
join casts_in as c20 on c19.stage_name = c20.stage_name
join casts_in as c21 on c20.movie_id = c21.movie_id
where c14.stage_name = 'kevin bacon'
union
select distinct c31.stage_name
from casts_in as c22
join casts_in as c23 on c22.movie_id = c23.movie_id
join casts_in as c24 on c23.stage_name = c24.stage_name
join casts_in as c25 on c24.movie_id = c25.movie_id
join casts_in as c26 on c25.stage_name = c26.stage_name
join casts_in as c27 on c26.movie_id = c27.movie_id
join casts_in as c28 on c26.stage_name = c28.stage_name
join casts_in as c29 on c27.movie_id = c29.movie_id
join casts_in as c30 on c28.stage_name = c30.stage_name
join casts_in as c31 on c29.movie_id = c31.movie_id
where c22.stage_name = 'kevin bacon'
union
select distinct c43.stage_name
from casts_in as c32
join casts_in as c33 on c32.movie_id = c33.movie_id
join casts_in as c34 on c33.stage_name = c34.stage_name
join casts_in as c35 on c34.movie_id = c35.movie_id
join casts_in as c36 on c35.stage_name = c36.stage_name
join casts_in as c37 on c36.movie_id = c37.movie_id
join casts_in as c38 on c37.stage_name = c38.stage_name
join casts_in as c39 on c38.movie_id = c39.movie_id
join casts_in as c40 on c39.stage_name = c40.stage_name
join casts_in as c41 on c40.movie_id = c41.movie_id
join casts_in as c42 on c41.stage_name = c42.stage_name
join casts_in as c43 on c42.movie_id = c43.movie_id
where c32.stage_name = 'kevin bacon';

--> 5,230 rows

16. -- List the names of all actors that have appeared in a movie directed by "Clint Eastwood" along with a count of 
    -- how frequently they've appeard in movies he directed ordered by the count (descending) and their name 
    -- (ascending).

select c.stage_name, count(c.movie_id) as num_movies
from casts_in as c
join directs as d
on d.movie_id = c.movie_id
join person as p
on p.id = d.person_id
where p.first_name = 'Clint'
and p.last_name = 'Eastwood'
group by c.stage_name
order by num_movies desc, c.stage_name;

--> 57 rows

17. -- What are the categories (i.e., genre) of movies that "Ronald Reagan" appeared in as an actor?

select distinct m.genre
from movie as m
join casts_in as c
on m.id = c.movie_id
join actor as a
on a. stage_name = c.stage_name
where a.stage_name = 'ronald reagan';

--> 7 rows

18. -- Was there any year where more movies were made in England than in the US? If so, give the years.
select year
from (
		select m.location as location, m.year as year, count(m.id) as num
		from movie as m
		group by m.year, m.location) as nest
where location = 'USA' or location = 'England'
group by year, nest.location
order by location desc
limit 2

--> 1 row

19. -- "Paramount" is a famous studio. What category (i.e., genre) of movie was most commonly made by "Paramount"?

select m.genre, count(m.id)
from made_by as mb
join movie as m
on mb.movie_id = m.id
join studio as s 
on s.id = mb.studio_id
where s.name = 'Paramount'
group by m.genre
having count(m.id) = 
(select max(nest.mCount) from (select count(m2.id) as mCount
from made_by as mb2 join movie as m2 on mb2.movie_id = m2.id
join studio as s2
on s2.id = mb2.studio_id
where s2.name = 'Paramount' group by m2.genre) as nest)

--> 1 row

20. -- Has any person directed and produced a movie they've also acted in? If so, give their stagename, the title of 
    -- the movie they directed and produced, and the role(s) they played.

select c.stage_name, m.title, c.role_name
from movie as m
join casts_in as c
on c.movie_id = m.id
join directs as d
on d.movie_id = m.id
join produces as p
on p.movie_id = m.id
join person as per
on per.id = p.person_id
where d.person_id = p.person_id
and per.first_name = c.stage_name

--> 4 row

21. -- For all of the generic roletypes for actors, list the name of the roletype and a count of how many actors are 
    -- classified by that type in descending order of the counts.

select c.role_name, count(c.stage_name) as actorCount
from casts_in as c
group by c.role_name
order by actorCount desc

--> 9,800 rows

22. -- For all of the generic movie categories (e.g., "drama", "mystery"), list the name of the category (long form, if 
    -- possible) and a count of how many movies are in that category in descending order of the counts.

select m.genre, count(m.id) as movieCount
from movie as m
where m.genre not like '%,%'
group by m.genre
order by movieCount desc

--> 25 rows

23. -- Who was the oldest actor to appear in a movie? I.e., has the largest difference between their date of birth and 
    -- the release of a movie they appeared in. Give their name, rough age at the time, title of the movie, and the 
    -- role they played.

select p.last_name, p.first_name, (m.year - p.dob) as age, m.title, c.role_name
from casts_in as c
join actor as a
on a.stage_name = c.stage_name
join person as p 
on p.id = a.person_id
join movie as m
on m.id = c.movie_id
where m.year is not null
and (m.year - p.dob) = 
(select max(nested.age_at) from
(select(m2.year - p2.dob) as age_at
from casts_in as c2 
join actor as a2
on c2.stage_name = a2.stage_name
join person as p2
on p2.id = a2.person_id
join movie as m2
on m2.id = c2.movie_id
where m2.year is not null
and p2.dob is not null) as nested);

--> 1 row

24. -- Give me a query that joins and returns everything in your database related to the original "Star Wars" movie.

select * from movie join casts_in on movie.id = casts_in.movie_id 
join actor on casts_in.stage_name = actor.stage_name 
left join award on casts_in.award_id = award.id 
left join directs on movie.id = directs.movie_id 
left join made_by on made_by.movie_id = movie.id 
left join studio on made_by.studio_id = studio.id 
join movie_receives_award on movie_receives_award.movie_id = movie.id 
join person on person.id = actor.person_id
left join produces on produces.person_id = person.id
join remakes on remakes.movie_id = movie.id
where title = 'Star Wars';

--> 29 rows




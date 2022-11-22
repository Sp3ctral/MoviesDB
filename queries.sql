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
order by a1.stage_name, m1.year, m1.title

--> 24 rows

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
group by original.title, original.year, firstDir.first_name, remake.title, remake.year, secondDir.last_name

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
order by depth desc
limit 1

5. -- Which movies are neither a remake nor have ever been remade? Order by title.

select * from movie m
where not exists 
   (
      select priorfilmid, movie_id
      from remakes r
      where r.priorfilmid = m.id or r.movie_id = m.id
   )
  order by title;

--> 1 row

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
order by year

--> 205 rows

7. -- Which movies, by name, won Academy Awards in 1970?

select m.title
from movie as m
join movie_receives_award as mra
on m.id = mra.movie_id
where mra.award ilike '%AA%' and m.year = 1970

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
order by ori.title, rem.title

--> 4 rows

9. -- Find the name and year of the movie that has the shortest title.

SELECT title, year
FROM movie
WHERE LENGTH(title) IN (
  SELECT MIN(LENGTH(title))
  FROM movie
  where length(title) > 0)

--> 6 rows
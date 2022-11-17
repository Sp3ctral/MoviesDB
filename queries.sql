1. -- What movies (list title and year) have "george" (in any form) at the end of their titles. Order by the title.

SELECT title
FROM movie
WHERE RIGHT(title, 6) ilike 'george'
ORDER BY title;

2. -- Has any actor ever appeared in both a movie and an immediate remake of an immediate remake? If so, list the 
   -- actor's stagename, the movie titles, the years, and the roles. Order by stagename, year, and movie title.


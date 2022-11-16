# needed for connection
# tutorial website: https://pynative.com/python-postgresql-tutorial/
# psycopg doc: http://initd.org/psycopg/docs/cursor.html#fetch

import psycopg2 as psycopg2
import csv
import re


def main():
    load_studios()


def load_studios():
    try:
        conn = psycopg2.connect(host="dhansen.cs.georgefox.edu",
                                database="movie_bm",
                                user="mhozi18",
                                password="55480222Mh")
        cursor = conn.cursor()

        with open('studio.csv') as csv_file:
            errors = []
            csv_data = csv.reader(csv_file)
            for row in csv_data:
                id = row[0]
                name = row[1]
                company = row[2]
                city = row[3]
                location = row[4]
                founder = row[7]
                successor = row[8]

                try:
                    start_year = int(row[5])
                except ValueError:
                    start_year = None

                try:
                    end_year = int(row[6])
                except ValueError:
                    end_year = None

                print(row)
                try:
                    cursor.execute('begin')
                    cursor.execute(
                        "INSERT INTO studio (id, name, company, city, location, start_year, end_year, founder, successor) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)",
                        (id, name, company, city, location, start_year, end_year, founder, successor))
                    conn.commit()
                except(Exception, psycopg2.Error) as error:
                    errors.append(row)
                    print("Error: ", error)
                    cursor.execute('abort')
        count = cursor.rowcount
        print(count, "record inserted successfully into remakes table")

    except (Exception, psycopg2.Error) as error:
        print("error while connecting to postgresql", error)
    finally:
        if(conn):
            cursor.close()
            conn.close()
    print("ERRORS")
    for error in errors:
        print(error)
main()
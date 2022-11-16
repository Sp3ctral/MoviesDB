# needed for connection
# tutorial website: https://pynative.com/python-postgresql-tutorial/
# psycopg doc: http://initd.org/psycopg/docs/cursor.html#fetch

import psycopg2 as psycopg2
import csv
import re


def main():
    load_actors()


def load_actors():
    try:
        conn = psycopg2.connect(host="dhansen.cs.georgefox.edu",
                                database="movie_bm",
                                user="mhozi18",
                                password="55480222Mh")
        cursor = conn.cursor()

        with open('award.csv') as csv_file:
            errors = []
            csv_data = csv.reader(csv_file)
            for row in csv_data:
                id = row[0]
                awarding_org = row[1]
                location = row[2]
                name = row[3]

                print(row)
                try:
                    cursor.execute('begin')
                    cursor.execute(
                        "INSERT INTO award (id, awarding_org, location, name) VALUES (%s,%s,%s,%s)",
                        (id, awarding_org, location, name))
                    conn.commit()
                except(Exception, psycopg2.Error) as error:
                    errors.append(row)
                    print("Error: ", error)
                    cursor.execute('abort')
        count = cursor.rowcount
        print(count, "record inserted successfully into table")

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
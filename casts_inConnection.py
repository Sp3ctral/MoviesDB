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
        conn = psycopg2.connect(host="dhansen.cs.georgefox.edu",database="movie_bm",user="mhozi18",password="55480222Mh")
        cursor = conn.cursor()

        with open('casts_in.csv') as csv_file:
            errors = []
            csv_data = csv.reader(csv_file)
            for row in csv_data:
                if row[5] == "":
                    row[5] = None
                    
                print(row)
                try:
                    cursor.execute('begin')
                    cursor.execute(
                        "INSERT INTO casts_in (movie_id, stage_name, role_type, role_desc, role_name, award_id) VALUES (%s,%s,%s,%s,%s,%s)",
                        (row[0], row[1], row[2], row[3], row[4], row[5]))
                except(Exception, psycopg2.Error) as error:
                    errors.append(row)
                    print("Error: ", error)
                    cursor.execute('abort')
                conn.commit()

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
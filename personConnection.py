# needed for connection
# tutorial website: https://pynative.com/python-postgresql-tutorial/
# psycopg doc: http://initd.org/psycopg/docs/cursor.html#fetch

import psycopg2 as psycopg2
import csv
import re


def main():
    load_people()


def load_people():
    try:
        conn = psycopg2.connect(host="dhansen.cs.georgefox.edu",
                                database="movie_bm",
                                user="mhozi18",
                                password="55480222Mh")
        cursor = conn.cursor()

        with open('people.csv') as csv_file:
            errors = []
            csv_data = csv.reader(csv_file)
            for row in csv_data:
                id = row[0]
                first_name = row[1]
                last_name = row[2]
                dowstart = row[3]
                dowend = row[4]
                dob = row[5]
                dod = row[6]
                country = row[7]

                try:
                    dowstart = int(row[3])
                except ValueError:
                    dowstart = None

                try:
                    dowend = int(row[4])
                except ValueError:
                    dowend = None

                try:
                    dob = int(row[5])
                except ValueError:
                    dob = None

                try:
                    dod = int(row[6])
                except ValueError:
                    dod = None

                print(row)
                try:
                    cursor.execute('begin')
                    cursor.execute(
                        "INSERT INTO person (id, first_name, last_name, dowstart, dowend, dob, dod, country) VALUES (%s,%s,%s,%s,%s,%s,%s,%s)",
                        (id, first_name, last_name, dowstart, dowend, dob, dod, country))
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
# needed for connection
# tutorial website: https://pynative.com/python-postgresql-tutorial/
# psycopg doc: http://initd.org/psycopg/docs/cursor.html#fetch

import psycopg2
import csv
import pandas as pd


def main():
    # Open actors and casts and filter out the rows in casts that aren't in the actors CSV.
    # original = pd.read_csv("casts_in.csv", header=None)
    # removeDuplicateCasts(original)

    # Open casts in and filter out movies that don't exist in movies tables
    # original = pd.read_csv("casts_filtered.csv", header=None)
    # other = pd.read_csv("movie.csv", header=None)
    # removeBogusMovies(original, other)

    # Open casts in and filter out actors that don't exit in the actors table
    # original = pd.read_csv("casts_filtered.csv", header=None)
    # other = pd.read_csv("actor.csv", header=None)
    # removeBogusActors(original, other)

    load_actors()

def removeDuplicateCasts(original):
    # DO NOT REMOVE THIS FOR CASTS_IN.CSV
    # Lower cases movie_id and stage_name
    original[0] = [x.lower() for x in original[0]]
    original[1] = [x.lower() for x in original[1]]

    # Print the duplicates just to make sure we know them
    result = original[original.duplicated([0, 1], keep="first")]
    print("\nDuplicates:\n")
    print(result)

    # Save casts to new CSV without the duplicates
    result = original.drop_duplicates(subset=[0, 1], keep="first").to_csv("casts_filtered.csv", index=False, header=False)

def removeBogusMovies(original, other):
    print("\nMovies that don't exist in casts_in: \n")

    print(original.loc[~original[0].isin(other[0])])

    original.loc[original[0].isin(other[0])].to_csv("casts_filtered.csv", index=False, header=False)


def removeBogusActors(original, other):
    original[5] = [x.lower() for x in original[5]]

    print("\nActors that don't exist in casts_in: \n")

    print(original.loc[original[1].isin(other[1].str.lower())])

    original.loc[original[1].isin(other[1].str.lower())].to_csv("casts_filtered.csv", index=False, header=False)


def load_actors():
    try:
        conn = psycopg2.connect(host="dhansen.cs.georgefox.edu",database="movie_bm",user="mhozi18",password="55480222Mh")
        cursor = conn.cursor()
    except (Exception, psycopg2.Error) as error:
        print("error while connecting to postgresql", error)

    with open('casts_filtered.csv') as csv_file:
        errors = []
        tuples = []
        csv_data = csv.reader(csv_file)

        for row in csv_data:
            if row[5] == "":
                row[5] = None
            tuples.append([row[0], row[1], row[2], row[3], row[4], row[5]])
                
        for entry in tuples:
            try:
                cursor.execute('begin')
                cursor.execute("INSERT INTO casts_in (movie_id, stage_name, role_type, role_desc, role_name, award_id) VALUES (%s,%s,%s,%s,%s,%s)", (entry[0], entry[1], entry[2], entry[3], entry[4], entry[5]))
                conn.commit()
                print(entry)

            except(Exception, psycopg2.Error) as error:
                errors.append(row)
                print("Error: ", error)
                cursor.execute('abort')
            
    cursor.close()
    conn.close()
    print("ERRORS")
    for error in errors:
        print(error)

main()
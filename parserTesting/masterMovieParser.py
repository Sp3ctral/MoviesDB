import xml.etree.ElementTree as ET
import csv

tree = ET.parse("parserTesting/test.xml")
treeRoot = tree.getroot()
attribute_list = ["fid", "t", "year", "cats", "loc"]

# Create a a CSV file
Main_data = open('test.csv', 'w')

# Create the csv writer object
csvwriter = csv.writer(Main_data)

# For every tag in every "directorfilms" tag...
for tag in treeRoot.findall('directorfilms'):

    # Save the "films" tag
    films = tag.find('films')

    # For every tag inside the "films" tag...
    for film in films:
        if film.tag == "film":
            main = []
            for attribute in attribute_list:
                cats = []
                if attribute == "cats":
                    for child in film.find("cats").findall("cat"):
                        cats.append(child.text)
                    main.append(', '.join(cats))

                if attribute != "cats" and film.find(attribute) is None:
                    main.append(None)

                elif attribute != "cats":
                    main.append(film.find(attribute).text)
            print(main)
            # csvwriter.writerow(main)

#
# for member in root.findall('film'):
#     print(member)
#     # table attributes: title, year of release, topic,  diretor, history, type, producer, award name, original title, original year, fraction_sig
#     attribute_list = ["t", "year", "fid"]
#     main = []
#     for attribute in attribute_list:
#         if member.find(attribute) is None:
#             main.append(None)
#         else:
#             main.append(member.find(attribute).text)
#         print(main)
#

# Main_data.close()

import xml.etree.ElementTree as ET
import csv

tree = ET.parse("parserTesting/mains.xml")
treeRoot = tree.getroot()
attribute_list = ["fid", "t", "year", "cats", "loc"]

# Create a a CSV file
data = open('./movie.csv', 'w')

# Create the csv writer object
csvwriter = csv.writer(data)

# For every tag within every "directorfilms" tag...
for tag in treeRoot.findall('./directorfilms/films/film'):

    # Store the row information to write into the CSV
    main = []

    # For each attribute that we are looking for...
    for attribute in attribute_list:

        # Store the categories here so we can append them to the CSV row data later
        # We use sets because it will eliminate duplicates without work from our end
        categoriesSet = set()

        # Store the locations here so we can append them to the CSV row data later
        locationsSet = set()

        # If the attribute we are on is the location attribute
        if attribute == "loc":

            # Make sure we don't error out by ensuring the children of location exist
            if tag.find("loc") is not None:
                
                # If the children exist then make sure that the continent exists
                countries = tag.find("loc").findall("site")

                # For every country that exists that the movie was made in, append to the set of locations
                for child in countries:
                    if child.find("siteplace") is not None:
                        locationsSet.add(child.find("siteplace").text)
            
            # Try to merge our set into a string, if not then just make it be an empty string (None): ""
            try:
                main.append(', '.join(locationsSet))
            except:
                main.append(None)


        # If we are on the "cats" attribute from the list of attributes
        if attribute == "cats":

            # If the cats tag is not empty...
            if tag.find("cats") is not None:
                
                # We know that cats is now not empty so we can just obtain the children nodes to iterate through...
                categories = tag.find("cats").findall("cat")

                # For each node in categories, append it to the "cats" python set 
                for child in categories:
                    categoriesSet.add(child.text)

            # Turn the python "cats" set into a string delimited by a ", " 
            # -> [drama, action] -> "drama, action"
            # [drama] -> "drama"
            try:
                main.append(', '.join(categoriesSet))
            except TypeError:
                main.append(None)

        # If the attribute we are on is not cats AND loc AND it's NULL, append empty string to row
        if attribute != "cats" and attribute != "loc" and tag.find(attribute).text is None:
            main.append(None)

        # If the attribute we are on is not cats AND loc AND it has a value, append value to row
        elif attribute != "cats" and attribute != "loc":
            main.append(tag.find(attribute).text.lower())

    # Print the row that is getting appended to the CSV
    print(main)
    csvwriter.writerow(main)

data.close()

# Please kill me. I am not touching Python again in my life.

import dimcli
import json
import pandas as pd
import datetime
import os
import configparser

# Load paths from the config file
cfg = configparser.ConfigParser()
cfg.read("config.ini")

# Define data folder
data_folder = cfg["paths"]["data"]

# Get date to add to output file names
today = datetime.datetime.today()
now = today.strftime("%Y-%m-%d")

institutions_grid = {
    "aachen": ['grid.412301.5'],
    "augsburg": ['grid.419801.5'],
    "charite": ['grid.6363.0'],
    "bochum": ['grid.411091.c', 'grid.465549.f'],
    "bonn": ['grid.15090.3d', 'grid.412472.6', 'grid.492007.8'],
    "dresden": ['grid.412282.f', 'grid.488567.0', 'grid.488574.2', 'grid.491994.8', 'grid.492195.2'],
    "duesseldorf": ['grid.14778.3d'],
    "erlangen": ['grid.411668.c'],
    "duisburg-essen": ['grid.410718.b'],
    "frankfurt": ['grid.411088.4', 'grid.459906.7', 'grid.488569.e'],
    "freiburg": ['grid.7708.8', 'grid.488550.4', 'grid.492242.b'],
    "giessen_marburg": ['grid.411067.5', 'grid.470025.4', 'grid.492000.f', 'grid.492260.b'],
    "goettingen": ['grid.411984.1'],
    "greifswald": ['grid.412469.c', 'grid.491939.f'],
    "halle": ['grid.461820.9'],
    "hamburg": ['grid.13648.38', 'grid.412315.0'],
    "hannover": ['grid.10423.34'],
    "heidelberg": ['grid.5253.1', 'grid.469888.3', 'grid.470019.b', 'grid.470023.2', 'grid.470022.3', 'grid.491895.8',
                   'grid.491951.1', 'grid.492125.9'],
    "homburg": ['grid.411937.9', 'grid.492203.e'],
    "jena": ['grid.275559.9', 'grid.492123.f', 'grid.491929.e'],
    "kiel_luebeck": ['grid.412468.d'],
    "koeln": ['grid.411097.a', 'grid.470034.4', 'grid.491942.3', 'grid.491957.7', 'grid.491959.9', 'grid.491974.6',
              'grid.491978.a', 'grid.492121.d', 'grid.492259.1'],
    "leipzig": ['grid.411339.d', 'grid.491934.2', 'grid.491989.4', 'grid.492129.5', 'grid.492134.9'],
    "magdeburg": ['grid.411559.d', 'grid.470028.9', 'grid.488575.3', 'grid.492172.b', 'grid.492176.f', 'grid.492184.2',
                  'grid.492185.3', 'grid.492206.b'],
    "mainz": ['grid.410607.4', 'grid.491984.9'],
    "mannheim": ['grid.411778.c'],
    "muenchenLMU": ['grid.411095.8', 'grid.491963.0', 'grid.491993.f'],
    "muenchenTU": ['grid.15474.33', 'grid.461835.d', 'grid.472756.5', 'grid.491968.b'],
    "muenster": ['grid.16149.3b', 'grid.470024.5', 'grid.482674.b', 'grid.492731.a'],
    "oldenburg": ['grid.419838.f', 'grid.477704.7', 'grid.492168.0'],
    "regensburg": ['grid.411941.8', 'grid.488578.e', 'grid.491897.a', 'grid.459443.b'],
    "rostock": ['grid.413108.f'],
    "tuebingen": ['grid.411544.1', 'grid.488549.c', 'grid.488604.6', 'grid.492128.4'],
    "ulm": ['grid.410712.1'],
    "witten-herdecke": ['grid.490185.1'],
    "wuerzburg": ['grid.411760.5', 'grid.488568.f', 'grid.488580.9']
}

all_years = ["2018"]


def get_record(grid_ids, years):
    dsl = dimcli.Dsl()
    query = f"""search publications
    where year in {json.dumps(years)} and
    research_orgs in {json.dumps(grid_ids)} and
    type="article"
    return publications[doi + year + pmid + type + category_for + authors]"""
    print(query)
    data = dsl.query_iterative(query, limit=300)
    return data.as_dataframe()


dimcli.login()

frames = []
for city, ids in institutions_grid.items():
    data = get_record(ids, all_years)
    data["city"] = city
    print(data)
    frames.append(data)

result = pd.concat(frames)
result = result[["doi", "city", "year", "type", "pmid", "category_for", "authors"]]
result.to_csv(os.path.join(data_folder, now + "_uh-pubs-" + all_years[0] + ".csv"), index=False)

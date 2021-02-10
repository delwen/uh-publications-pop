import dimcli
import json
import pandas as pd

institutions_grid = {
    "aachen": ['grid.412301.5'],
#   "augsburg": [],
    "berlin": ['grid.6363.0'],
    "bochum": ['grid.411091.c'],
    "bonn": ['grid.15090.3d'],
    "cologne": ['grid.411097.a'],
    "dresden": ['grid.412282.f'],
    "duisburg-essen": ['grid.410718.b'],
    "dusseldorf": ['grid.14778.3d'],
    "erlangen": ['grid.411668.c'],
    "frankfurt": ['grid.411088.4'],
    "freiburg": ['grid.7708.8'],
    "giessen_marburg": ['grid.411067.5'],
    "gottingen": ['grid.411984.1'],
    "greifswald": ['grid.412469.c'],
    "halle": ['grid.461820.9'],
    "hamburg": ['grid.13648.38'],
    "hannover": ['grid.10423.34'],
    "heidelberg": ['grid.5253.1'],
#    "homburg": [],
    "jena": ['grid.275559.9'],
    "kiel_luebeck": ['grid.412468.d'],
    "leipzig": ['grid.411339.d'],
    "magdeburg": ['grid.411559.d'],
    "mainz": ['grid.410607.4'],
    "mannheim": ['grid.411778.c'],
    "munich_lmu": ['grid.411095.8'],
    "munich_tu": ['grid.15474.33'],
    "munster": ['grid.16149.3b'],
#   "oldenburg": [],
    "regensburg": ['grid.411941.8'],
    "rostock": ['grid.413108.f'],
    "tubingen": ['grid.411544.1'],
    "ulm": ['grid.410712.1'],
#   "witten": [],
    "wurzburg": ['grid.411760.5']
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
    data = dsl.query_iterative(query, limit=300, maxlimit=2)
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
result.to_csv("data/dimensions-data.csv", index=False)
import requests

def get_city_coord(city_name):
    url = 'https://geocoding-api.open-meteo.com/v1/search'
    params = {
        "name": city_name,
        "count": 1
    }
    result = requests.get(url, params=params).json()
    result = result["results"][0]
    return {"lat": result["latitude"], "long": result["longitude"]}




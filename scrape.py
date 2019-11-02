#!/usr/bin/env python
# -*- coding: utf-8 -*-
import requests

HEADERS = {
    'authority': 'hansard.parliament.uk',
    'pragma': 'no-cache',
    'cache-control': 'no-cache',
    'accept': 'application/json, */*; q=0.01',
    'x-requested-with': 'XMLHttpRequest',
    'user-agent': 'HanscrapeXR',
    'sec-fetch-site': 'same-origin',
    'sec-fetch-mode': 'cors',
    'referer': 'https://hansard.parliament.uk/search?startDate=2016-01-01&endDate=2019-11-02&partial=False',
    'accept-language': 'en-GB,en-US;q=0.9,en;q=0.8',
}

PARAMS = [
    ('startDate', '01/01/2016'),
    ('endDate', '02/11/2019'),
    ('house', '0'),
    ('contributionType', ''),
    ('isDebatesSearch', 'False'),
    ('memberId', ''),
]


def get_data(keywords_str):
    """Get the XHR data as JSON."""
    param = ('searchTerm', '"{}"'.format(keywords_str))

    response = requests.get(
        'https://hansard.parliament.uk/timeline/query',
        headers=HEADERS, params=PARAMS + [param]
    )

    return response.json()


def json_to_csv(json):
    """Turn JSON data into CSV data."""
    lines = ['Date,Days,Count']
    results = json['Results']
    for result in results:
        lines.append('{GroupingDate},{GroupingSize},{Count}'.format(**result))
    return '\n'.join(lines)


def get_search_csv_to_file(keywords_str):
    """Turn a search into a CSV file on disk."""
    fpath = '{}.csv'.format(keywords_str.replace(' ', '_'))
    with open(fpath, 'w') as fp:
        fp.write(json_to_csv(get_data(keywords_str)))


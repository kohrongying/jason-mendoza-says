import json
import requests

# with open('data.json') as file:
#   data = json.load(file)

    # quote = line['quote'].split(":")
    # if quote[0] == 'Jason':

    # jason.write(':'.join(x for x in quote[1:]) + '\n')

count = 0
headers = {'content-type': 'application/json'}
with open('jason.txt', 'r') as f:
  data = f.readlines()
  for line in data:
    line = line.strip()
    # print(line)
    count += 1
    payload = {'quote': line }
    requests.put(f'https://jsonbase.com/dIvRREdwzsIJ05DOsUt1ImStp3Gr8LR8/{count}', data=json.dumps(payload), headers=headers)

print('count', count)
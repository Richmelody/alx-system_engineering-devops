#!/usr/bin/python3
# get subs
from requests import get
from sys import argv


def number_of_subscribers(subreddit):
    """Get number of subscribers for a given subreddit."""
    head = {'User-Agent': 'Dan Kazam'}
    url = 'https://www.reddit.com/r/{}/about.json'.format(subreddit)
    response = get(url, headers=head, allow_redirects=False)

    if response.status_code == 302:
        print("Error: Invalid subreddit '{}'".format(subreddit))
        return 0
    elif response.status_code != 200:
        print("Error: {} - Could not retrieve data for /r/{}".format(response.status_code, subreddit))
        return None

    try:
        count = response.json().get('data').get('subscribers')
        return count
    except:
        print("Error: Could not retrieve subscriber count for /r/{}".format(subreddit))
        return None


if __name__ == "__main__":
    subreddits = argv[1:]
    subscriber_counts = {}

    for subreddit in subreddits:
        count = number_of_subscribers(subreddit)
        if count is not None:
            subscriber_counts[subreddit] = count

    for subreddit, count in sorted(subscriber_counts.items()):
        print("{}: {}".format(subreddit, count))


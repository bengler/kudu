# Kudu

Feedback service.


## Ack

A single piece of feedback is known as an `ack`.

Kudu supports flexible feedback strategies (`kind`), e.g.
* classic kudos ("+1")
* votes: upvote, downvote, and neutral ("+1", "-1", and "0"),
* ratings: e.g. 1 through 5 stars ("+1", "+2", "+3", "+4", "+5")
* arbitrary scores, e.g. -17, +32, +100

An Ack is provided by an `identity` for some object, as identified by a `uid`.
It also must specify a `kind`, which is essentially a feedback strategy defined in the application, and a `value`.

For example:

    Ack.new(:identity => 7, :external_uid => 'post:a.b.c$34', :kind => 'rating', :value => 4)

### Endpoints

Get acks for the current identity. `:uids` can be a comma delimited list of uids, or a single uid.

    GET /acks/:uids

Post feedback for an item:

    POST /acks/:uid

`:kind` is required, and must be a valid label. `:value` is required and must be an integer. `:identity` is required and is retrieved from checkpoint using the session key. `:external_uid` is also required.

## Scores

The aggregate scores for each :uid are available through the `/scores` endpoints.

* `total_count` - how many identities have provided feedback
* `positive_count` - number of ack values that are greater than zero
* `negative_count` - number of ack values that are less than zero
* `neutral_count` - number of ack values that are exactly zero
* `positive` - the sum of positive scores
* `negative` - sum of negative scores
* `average` - average score (total score / total count)
* `controversiality` - a calculation of how much people disagree
* `histogram` - a list of counts per ack value

### Endpoints

All scores for an object, grouped by :kind

    GET /scores/:uid

All scores of a given kind:

    GET /scores/:uid/:kind


Fetch ranked lists. These need to be ranked by an attribute on score. uid includes a wildcard path.

    GET /scores/:uid/:kind/rank/:by


Fetch mixes of ranked, randomized scores, segmented by different groups. Go look at the code. Seriously.

    GET /scores/:uid/sample

## Stats

TODO: implement endpoints at `/stats/:path/:more_stuff`.

These aggregate data about `:scores` and `:kind` (can't aggregate scores of different kinds. Apples and Oranges).

This will deliver stats for paths (i.e. an app, or a region). Currently this is sort of implemented with some hacks, for dittforslag (how many contributors, top contributors, ranked lists of various things -- most controversial, most popular, etc.

This requires support for wildcard paths, which is on the block for the next few days.

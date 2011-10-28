# Kudu

A feedback service that handles
* classic kudos ("+1")
* upvote, downvote, and neutral ("+1", "-1", and "0"),
* possibly a set of arbitrary feedback categories, such as ["fascinating", "funny", "boring", "moving",...]
  These could be implemented as bitmasks (e.g. "fascinating" => 0, "funny" => "1", "boring" => 2, "moving" => 4)

## Terminology

A single identity's score bestowed upon a single post is known as an *ack*.

## Scores

- _score_ sum of all acks
- _count_ count of all acks
- _negative_ count of -1 acks
- _positive_ count of +1 acks
- _controversiality_ ratio between positive and negative acks
- _rank_ rank within a given collection

## What it should do

The realm and identity of the requestor is determined through the session, which is provided either as a parameter in the query

    kudu.dev/v1/ack post=mittap.progdebatt.theme1.prop3&score=+1&session=kewjwkefhwljfhbwelfjhe

or in a cookie called checkpoint.session

## API

### Implement these first...

* give kudos
  POST kudu.dev/v1/ack/:uid data="score=-1&session=abc"
  => 201, return Summary belonging to Ack

* delete kudos (make sure user requesting delete is kudos creator or a realm god)
  DELETE kudu.dev/v1/ack/:uid data="session=abc" # deletes the kudo matching post=uid, identity belonging to session
  DELETE kudu.dev/v1/ack/:uid data="identity=7&session=abc" # deletes the kudo matching post=uid, session is god identity
  => 200, return Summary belonging to Ack



### Then these...

For queries against /ack, the response is the summary of kudos per post
    (score, count, negative, positive, contro) + identites,realm,post uid,collection

  GET kudu.dev/v1/ack?collection=oa:birthday
  GET kudu.dev/v1/ack/:uid
  GET kudu.dev/v1/ack/:uids


### Then these...

* get scores for posts ranked withing a collection (pagination probably required)
  GET kudu.dev/v1/scores?collection=oa:birthday
  GET kudu.dev/v1/scores?posts=uid1,uid2,uid3

* check kudos score for one or several posts
  GET  kudu.dev/v1/scores?post=uid1
  GET  kudu.dev/v1/scores?posts=uid1,uid2,uid3

* all kudos given by an identity within a realm or collection
  GET  kudu.dev/v1/ack?identity=1 # by identity 1 within realm
  GET  kudu.dev/v1/ack?collection=abc&identity=1 # by identity 1 within collection abc

* hente ut alle kudu én person har gitt innenfor et realm eller en collection

ja, så scores er alltid score, count, negative, positive, contro
hvis jeg sier /kudu/scores og poster en lang liste med post-id'er får jeg en hash med alle disse scorene for alle postene jeg ba om
hvis jeg ber om det får jeg med en liste med identity-id'er også

## setup, notes

### On the mac, you can use Pow

    curl get.pow.cx | sh
    cd ~/.pow
    ln -s /Users/me/mycode/projectname

### Deployment
When you know which servers they should be deployed to, edit

    config/deploy/staging.rb
    config/deploy/production.rb

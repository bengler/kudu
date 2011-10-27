# Kudu

## On the mac, you can use Pow

    curl get.pow.cx | sh
    cd ~/.pow
    ln -s /Users/me/mycode/projectname


## Deployment
When you know which servers they should be deployed to, edit

    config/deploy/staging.rb
    config/deploy/production.rb


score (summen av alle stemmene)
count (antallet stemmer totalt)
negative (negative stemmer)
positive (positive stemmer)
controversiality = ratio mellom positive og negative stemmer der vi alltid deler det minste tallet på det største tallet slik at verdien ligger mellom 0 (full enighet) og 1 (total uenighet)
rank (within a collection? realm, too?)

## What it should do

The realm and identity of the requestor is determined through the session, which is provided either as a parameter in the query

    /kudu/v1/feedback post=mittap.progdebatt.theme1.prop3&score=+1&session=kewjwkefhwljfhbwelfjhe

or in a cookie called checkpoint.session

## API

* give kudos
  POST kudu.dev/v1/feedback data="score=-1&session=abc&post=uid1"
  => 201

* delete kudos (make sure user requesting delete is kudos creator or a realm god)
  DELETE kudu.dev/v1/feedback data="post=uid1&session=abc" # deletes the kudo matching post=uid, identity belonging to session
  DELETE kudu.dev/v1/feedback data="post=uid1&identity=7&session=abc" # deletes the kudo matching post=uid, session is god identity
  => 200

For queries against /feedback, the response is the summary of kudos per post
    (score, count, negative, positive, contro) + identites,realm,post uid,collection

  GET kudu.dev/v1/feedback?collection=oa:birthday
  GET kudu.dev/v1/feedback?posts=uid1,uid2,uid3

* get post & score ranked withing a collection (pagination probably required)
  GET kudu.dev/v1/scores?collection=oa:birthday
  GET kudu.dev/v1/scores?posts=uid1,uid2,uid3

* check kudos score for one or several posts
  GET  kudu.dev/v1/scores?post=uid1
  GET  kudu.dev/v1/scores?posts=uid1,uid2,uid3

* all kudos given by an identity within a realm or collection
  GET  kudu.dev/v1/feedback?identity=1 # by identity 1 within realm
  GET  kudu.dev/v1/feedback?collection=abc&identity=1 # by identity 1 within collection abc

* hente ut alle kudu én person har gitt innenfor et realm eller en collection

ja, så scores er alltid score, count, negative, positive, contro
hvis jeg sier /kudu/scores og poster en lang liste med post-id'er får jeg en hash med alle disse scorene for alle postene jeg ba om
hvis jeg ber om det får jeg med en liste med identity-id'er også


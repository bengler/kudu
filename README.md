# Kudu

## On the mac, you can use Pow

    curl get.pow.cx | sh
    cd ~/.pow
    ln -s /Users/me/mycode/projectname


## Deployment
When you know which servers they should be deployed to, edit

    config/deploy/staging.rb
    config/deploy/production.rb


What it should do
-----------------
* Sample request: /kudu/v1/feedback post=mittap.progdebatt.theme1.prop3&score=+1&session=kewjwkefhwljfhbwelfjhe

* give kudos
  POST kudu.dev/v1/feedback (create)
  => 201 created

* delete kudos (make sure user requesting delete is kudos creator)
  DELETE kudu.dev/v1/feedback (destroy)
  => 200 ok


For queries, the response is the summary of kudos per post
    (score, count, negative, positive, contro) + identites,realm,post uid,collection

* get post & score ranked withing a collection (pagination probably required)
  GET kudu.dev/v1/feedback?collection=oa:birthday

* check kudos score for one or several posts
  GET  kudu.dev/v1/feedback?post=uid1
  GET  kudu.dev/v1/feedback?posts=uid1,uid2,uid3


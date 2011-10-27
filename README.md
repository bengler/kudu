API Project
============

git clone git@github.com:origo/apibones.git projectname
cd projectname
./script/bootstrap

Pow
---

    curl get.pow.cx | sh
    cd ~/.pow
    ln -s /Users/me/mycode/projectname



Deployment
----------
# When you know which servers they should be deployed to, edit
config/deploy/staging.rb
config/deploy/production.rb


What it should do
-----------------

* give kudos
* check kudos score for one or several posts
* kudos summary a post (score, count, negative, positive, contro)
* delete kudos (make sure user requesting delete is kudos creator)
* get post & score ranked withing a collection (pagination probably required)
* Sample request: /kudu/v1/feedback post=mittap.progdebatt.theme1.prop3&score=+1&session=kewjwkefhwljfhbwelfjhe

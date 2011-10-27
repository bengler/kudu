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


Elastic Search
--------------
We're using elasticsearch for text indexing.
Get it here:
https://github.com/elasticsearch/elasticsearch

and run with

    ./path/to/bin/elasticsearch -f



Deployment
----------
# When you know which servers they should be deployed to, edit
config/deploy/staging.rb
config/deploy/production.rb

NSW Planning Data Verification Tool
===================================

Deployment
----------

The application uses giddyup to deploy to Anchor Systems hosting.  You can set
this up as follows:

    git remote add sabre40 eplanning@sabre40.anchor.net.au:railsapps/housingcode/repo
    git remote add squid680 eplanning@squid680.anchor.net.au:railsapps/housingcode/repo

Then to do your initial deploy

    git push sabre40 master:master
    git push squid680 master:master

After this, each time you perform a default push, e.g.:

    git push sabre40
    git push squid680

Your code will be pushed to github and the production server.

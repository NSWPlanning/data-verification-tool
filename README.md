NSW Planning Data Verification Tool
===================================

Deployment
----------

The application uses giddyup to deploy to Anchor Systems hosting.  The
production site is temporarily available at the URL 
http://www.eplanning.tmp.anchor.net.au/

You can set up deployment as follows:

    git remote add sabre40 eplanning@sabre40.anchor.net.au:railsapps/housingcode/repo
    git remote add squid680 eplanning@squid680.anchor.net.au:railsapps/housingcode/repo

Then to do your initial deploy

    git push sabre40 master:master
    git push squid680 master:master

After this, each time you perform a default push, e.g.:

    git push sabre40
    git push squid680

You can add the following remote specification to your local `.git/config` to
push to both production servers in one hit:

    [remote "production"]
      url = eplanning@sabre40.anchor.net.au:railsapps/housingcode/repo
      url = eplanning@squid680.anchor.net.au:railsapps/housingcode/repo

Then you can just run:

    git push production

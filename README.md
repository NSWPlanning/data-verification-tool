NSW Planning Data Verification Tool
===================================

The production site is temporarily available at the URL
http://www.eplanning.tmp.anchor.net.au/

Uploading LPI files
-------------------

LPI files can be uploaded with the following command:

    rsync -e ssh -P EHC_LPMA_XXXXXXXX.csv lpi_upload@squid680.anchor.net.au:/data/nfs/lpi_upload/incoming

Where `EHC_LPMA_XXXXXXXX.csv` is the name of the file you wish to upload.  The
upload directory is scanned every minute for incoming files, and any new files
are processed and moved to the `processed` directory.

Deployment
----------

The application uses giddyup to deploy to Anchor Systems hosting.
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

It's possible to restart the application servers manually as follows:

    # Other commands include 'start', 'stop' and 'log'
    sudo /usr/local/bin/allah restart housingcode_unicorn

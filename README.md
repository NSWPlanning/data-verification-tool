NSW Planning Data Verification Tool
===================================
  
The production site is available at the URL
http://data.electronichousingcode.com.au

Test site is at 
http://demo.electronichousingcode.com.au

Uploading LPI files
-------------------

LPI files can be uploaded as follows:

    $ sftp lpi_upload@sabre40.anchor.net.au
    lpi_upload@sabre40.anchor.net.au's password: 
    Connected to sabre40.anchor.net.au.
    sftp> cd incoming/
    sftp> put EHC_LPMA_XXXXXXXX.csv
    Uploading EHC_LPMA_XXXXXXXX.csv to /data/nfs/lpi_upload/incoming/EHC_LPMA_XXXXXXXX.csv
    EHC_LPMA_XXXXXXXX.csv                         100%  119MB 637.0KB/s   03:11    
    sftp> exit

Where `EHC_LPMA_XXXXXXXX.csv` is the name of the file you wish to upload.  The
`incoming` directory is scanned every 5 minutes for incoming files, and any new
files are processed and moved to the `processed` directory.

Uploading LGA files
-------------------

LGA files are generally uploaded to the relevant council through the web site
interface.

If automation is required, uploads can be performed in one of two ways:

Administrators can upload using: 

    curl  -u admin@example.com:password \
          -H "Accept: application/json" \
          -F data_file=@/path/to/ehc_lga_20120919.csv \
          http://SITE_URL/local_government_areas/import

Users with permissions for a single LGA can upload as follows:

    curl  -u admin@example.com:password \
          -H "Accept: application/json" \
          -F data_file=@/path/to/ehc_lga_20120919.csv \
          http://SITE_URL/local_government_areas/LGA_ID/import

You will need to know the LGA_ID. Note the requirement for JSON.


Running in development mode
---------------------------

In addition to starting the Rails server, you will also need to start a queue
worker if you want to test any functionality that uses background tasks.

    rake qc:work

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

It's possible to restart the application servers manually at Anchor. See config/hooks/start and config/hooks/stop for the complete process. Those hooks assume a current directory of the app root.

The core commands are:
    # Other commands include 'start', 'stop' and 'log'
    sudo /usr/local/bin/allah restart housingcode_unicorn
    sudo /usr/local/bin/allah restart housingcode_qc

Note: New Relic is enabled on production.


Licence
=======
See NOTICE and LICENCE files for the licencing of this project.


The Rails Application
---------------------

The Rails application is a relatively standard layout Rails app.  Most of the
operational code is contained within the `app` directory, apart from some
library code contained in `lib/dvt`, and a custom form builder, which are
discussed below.

The application uses the sorcery gem for authentication.


LGA Import
----------

One of the key operations from the web UI is the import of an LGA file.  This
can be performed by any user who is a member of an LGA.

The LGA file is POSTed to the LocalGovernmentAreasController#uploads action.
This in turn calls LocalGovernmentAreaRecordImporter.enqueue, which sets up
a queue_classic worker to perform the import task via
LocalGovernmentAreaRecordImporter#import


LPI Importer
------------

The LPI imports are not driven through the web UI, but are instead started
through an scp process onto the server.  The LPI files are copied into a folder
which is scanned periodically via a cron job which moves any files with a
modification time older than 5 minutes ago in this directory into a second
directory.  A second cronjob calls `rake lpi:process_dir` on the second
directory, which will process any files in this new directory.

The reason for this two stage approach is that scp copies the file to it's
final location during the upload process.  Because of this, if the rake task
simply scanned the upload directory it would be very likely to catch in progress
uploads and try to import them.


Importer superclass
-------------------

Both the LPI and LGA import classes inherit from the Importer superclass.
This class sets up basic behaviour, with the Importer#import method being
the main entry point.

The import life cycle calls the following lifecycle methods during the import,
which can be overriden in the subclasses, they are noops by default:

  before_import
  after_import

Other responsibilities of the importer are to instantiate an ImportLog object
of the correct class for the import, and record counters for how many records
have been imported, the number of errors and the types of any exceptions raised
during the import.

The final statistics of the import are stored and saved in the ImportLog
instance, which is an ActiveRecord object.


DVT lib directory
-----------------

Much of the code for extracting records from the import files is extracted
into classes in the `lib/dvt` directory in an attempt to decouple these from
the ActiveRecord classes used to persist the records.

The primary responsibilites of these classes are as follows

- Provide an Enumerable interface for efficiently iterating over the import
  CSVs without memory bloat.
- Provide a DSL to describe the properties of the LGA and LPI records.
- Provide some basic validation of the records prior to the ActiveRecord
  validations.
- Provide a mechanism to convert the records to a Hash for initializing an
  ActiveRecord object.

Some validations are performed after conversion to ActiveRecord objects as they
are are more practical to perform there, for example uniqueness validations.  A
future code improvement would be to share the validation code across the
ActiveRecord and DVT lib classes.

The `lib/dvt/*/converters.rb` classes provide lambdas for the Ruby CSV library
to automatically coerce particular columns into specific types.

The `lib/dvt/*/record.rb` classes are the main implementations of the DSL for
the LGA and LPI records types and define the properties of each file.

The `md5sum` method on the record classes is used to determine whether an
individual row has been modified since the last import, see the 'Lookup Classes'
section below.


Lookup classes
--------------

One of the most resource intensive parts of the import process is looking up
records for their existence in the database, checking for their presence and
whether they have been modified.

The performance impact of loading several thousand ActiveRecord objects into
memory, or performing several thousand individual database lookups, means
another approach has been adopted for this process.  These are the subclass
implementations of the `Lookup` superclass in the `app/models` directory
(`LandAndPropertyInformationLookup` and `LocalGovernmentAreaRecordLookup`)

The prime responsibilites of these classes are:

- Provide a mechanism to preload the complete set of records of the given type
  in a sparse hash containing only the object properties required to uniquely
  identify a record from an import file, map it to an ActiveRecord ID, and
  provide it's MD5 checksum from the import.
- Raise exceptions for certain error conditions, for example the same record
  being seen multiple times in the same import.
- Keep track of records in the set that have been seen during an import, and
  therefore records that have not been seen.  These records, present in the
  application database but not in the most recent import, are candidates for
  deletion.

These `Lookup` classes are instantiated by `Importer` instances, and are used
exclusively from them.  Any new records in the import are added to the lookup
hash during the import run to ensure integrity of the duplicate checks, etc.

The `md5sum` element of each records hash values is used to determine if the
record has changed since the last import.  The md5sum value is determined from
the `DVT::LPI::Record` and `DVT::LGA::Record` instances.


Foundation form builder
-----------------------

The application uses the Foundation CSS framework for it's responsive layout.

To ease the integration of this with Rails' form helpers a custom FormBuilder
class has been implemented to create the correct markup for foundation forms
from the standard Rails form helpers, and to automatically format form errors
with the correct markup.

The FormBuilder itself is defined in `lib/foundation_form_builder.rb`, and
is initialized in `config/initializers/form_builder.rb` and
`config/initializers/foundation_field_error_proc.rb`


Deployment
----------

Deployment is performed via [giddyup](https://github.com/mpalmer/giddyup).
Setting up locally for deployment is documented in the top level README.md of
this repository.

The deployment configuration is all stored within the `config/hooks` directory.
The `start` and `stop` hook scripts are run when starting and stopping the
service remotely.

The rails server and queue_classic background worker tasks are controlled by
the root level `allah` service.  As the servers are managed by Anchor systems,
any changes made to this must be performed by the Anchor Hosting team.

The confiuration directory for allah is /etc/service.  The permissions of this
directory do not make it possible to list it's contents, but it's sub directory
contents can be viewed if their names are known.  The subdirectories are
/etc/service/housingcode_unicorn and /etc/service/housingcode_qc in the event
that their contents need to be examined.

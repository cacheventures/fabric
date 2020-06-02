# todo
* handle models
  * write migrations for postgres models
  * write activerecord models
  * abstract out code (validations, instance methods) that can be shared and put them in a module that can be included in both ORMs' models
* change the loading code to execute differently per ORM
* search for any place where there is mongoid-specific querying (search for .where) and add code to allow for querying differently per ORM
* search for usage of mongoid specific stuff (BSON::ObjectId, Mongoid::Document, etc.) and make it work with both ORMs
* write test helpers for postgres usage (can reference devise/test/orm/active_record.rb), run, and, if necessary, adapt tests to work with postgres
* test it in a rails project, making sure everything works properly
* update the README with instructions and information on postgres usage, ORM selection, etc.

# done
* edit the gemfile and gemspec to allow for both ORMs
* edit the Config class to allow setting ORM

# questions
* what is this going to do to my versions code?

PATH := ${HOME}/.gem/ruby/1.9.1/bin:${HOME}/.bundle/ruby/1.9.1/bin:${PATH}

build:
	LANG="en_US.UTF-8" LC_ALL="en_US.UTF-8" gem1.9.1 install --no-rdoc --no-ri --user-install bundler
	bundle install --deployment --without=test development

	cp config/database.yml.sample config/database.yml

	bundle exec rake db:create db:migrate assets:precompile RAILS_ENV=production

	rm -rf vendor/bundle/ruby/*/bin vendor/bundle/ruby/*/cache vendor/bundle/ruby/*/doc
	rm -f config/database.yml

install:
	cp -a app bin script public vendor config lib db ${DESTDIR}usr/share/streamcontrol
	cp -a Gemfile Gemfile.lock .bundle ${DESTDIR}usr/share/streamcontrol
	rm -f ${DESTDIR}usr/share/streamcontrol/config/environments/production.rb
	cp debian/database.yml debian/production.rb debian/apache2.conf ${DESTDIR}etc/streamcontrol/
	cp debian/darkice-safe ${DESTDIR}usr/bin/

clean:
	rm -rf vendor/rails vendor/bundle vendor/gems db/production.sqlite3

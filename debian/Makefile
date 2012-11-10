PATH := ${HOME}/.gem/ruby/1.8/bin:${HOME}/.bundle/ruby/1.8/bin:${PATH}

build:
	gem install --no-rdoc --no-ri --user-install bundler
	bundle install --deployment --without=test development cucumber

	cp config/database.yml.sample config/database.yml

	bundle exec rake db:create db:migrate RAILS_ENV=production

	rm -rf vendor/bundle/ruby/1.8/bin vendor/bundle/ruby/1.8/cache vendor/bundle/ruby/1.8/doc
	rm -f config/database.yml

install:
	cp -a app bin script public vendor config lib db ${DESTDIR}usr/share/streamcontrol
	cp -a Gemfile Gemfile.lock .bundle ${DESTDIR}usr/share/streamcontrol
	rm -f ${DESTDIR}usr/share/streamcontrol/config/environments/production.rb
	cp debian/database.yml debian/production.rb debian/apache2.conf ${DESTDIR}etc/streamcontrol/
	cp debian/darkice-safe ${DESTDIR}usr/bin/

clean:
	rm -rf vendor/rails vendor/bundle vendor/gems db/production.sqlite3

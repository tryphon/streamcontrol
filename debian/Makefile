PATH := ${HOME}/.gem/ruby/1.8/bin:${HOME}/.bundle/ruby/1.8/bin:${PATH}

build:
	gem install --no-rdoc --no-ri --user-install bundler
	bundle install vendor --without=test --without=development

	cp config/database.yml.sample config/database.yml
	bundle exec rake rails:freeze:gems 
	bundle exec rake db:create db:migrate RAILS_ENV=production

	rm -rf vendor/bin vendor/cache vendor/doc vendor/specifications 
	rm -rf vendor/gems/actionmailer-* vendor/gems/actionpack-* vendor/gems/activerecord-* vendor/gems/activeresource-* vendor/gems/activesupport-* vendor/gems/rails-*
	rm -f config/database.yml

install:
	cp -a app bin script public vendor config lib db ${DESTDIR}usr/share/streamcontrol
	rm -f ${DESTDIR}usr/share/streamcontrol/config/environments/production.rb
	cp debian/database.yml debian/production.rb debian/apache2.conf ${DESTDIR}etc/streamcontrol/
	cp debian/syslog_logger.rb ${DESTDIR}usr/share/streamcontrol/lib
	cp debian/darkice-safe ${DESTDIR}usr/bin/

clean:
	rm -rf vendor/rails vendor/gems db/production.sqlite3

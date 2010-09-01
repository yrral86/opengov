FILES = componentmanager.rb \
	components-available \
	components-enabled \
	config/environments.yml \
	db/config.yml \
	javascript \
	lib \
	config.ru \
	production-ruby

#USER=www-data
USER=root

deploy:
	ENV=production rake db:migrate
	service apache2 stop
	service opengov stop
	rm -rf /var/www/opengov
	mkdir -p /var/www/opengov
	cp -a --parents $(FILES) /var/www/opengov
	chown -R $(USER):$(USER) /var/www/opengov
	cp config/opengov.httpd /etc/apache2/sites-available/opengov
	rm -f /etc/apache2/sites-enabled/001-opengov
	ln -s /etc/apache2/sites-available/opengov /etc/apache2/sites-enabled/001-opengov
	cp config/opengov /etc/init.d/opengov
	/usr/sbin/update-rc.d -f opengov defaults
	service opengov start
	service apache2 start

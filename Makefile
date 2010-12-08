FILES = control.rb \
	components-available \
	components-enabled \
	config/environments.yml \
	db/config.yml \
	javascript \
	layouts \
	lib \
	config.ru \
	production-ruby

#USER=www-data
USER=root

deploy:
	service opengov stop
	service apache2 stop
	ENV=production rake db:migrate
	rm -rf /var/www/opengov
	rm -rf /tmp/opengov
	mkdir -p /var/www/opengov
	mkdir -p /tmp/opengov
	chown root:www-data /tmp/opengov
	chmod -R 775 /tmp/opengov
	cp -a --parents $(FILES) /var/www/opengov
	chown -R $(USER):$(USER) /var/www/opengov
	cp config/opengov.httpd /etc/apache2/sites-available/opengov
	rm -f /etc/apache2/sites-enabled/001-opengov
	ln -s /etc/apache2/sites-available/opengov /etc/apache2/sites-enabled/001-opengov
	cp config/opengov /etc/init.d/opengov
	/usr/sbin/update-rc.d -f opengov defaults
	service opengov start
	service apache2 start

FILES = componentmanager.rb \
	components \
	config/components \
	db/config.yml \
	javascript \
	lib \
	requestrouter.rb \
	config.ru

deploy:
	rm -rf /var/www/opengov
	mkdir -p /var/www/opengov
	cp -a --parents $(FILES) /var/www/opengov
	chown -R www-data:www-data /var/www/opengov
	cp config/opengov.httpd /etc/apache2/sites-available/opengov
	rm /etc/apache2/sites-enabled/001-opengov
	ln -s /etc/apache2/sites-available/opengov /etc/apache2/sites-enabled/001-opengov
	cp config/opengov /etc/init.d/opengov
	/usr/sbin/update-rc.d -f opengov defaults

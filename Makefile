FILES = componentmanager.rb \
	components \
	config/components \
	db/config.yml \
	javascript \
	lib \
	requestrouter.rb \
	router.ru

deploy:
	rm -rf /var/www/opengov
	mkdir -p /var/www/opengov
	cp -a --parents $(FILES) /var/www/opengov
	chown -R www-data:www-data /var/www/opengov
	cp config/opengov.yml /etc/thin/
	cp config/opengov /etc/init.d/opengov

deploy:
	cp -a --parents componentmanager.rb components db/config.yml javascript lib main.rb requestrouter.rb router.ru /var/www/opengov
	chown -R www-data:www-data /var/www/opengov
	cp config/opengov.yml /etc/thin/
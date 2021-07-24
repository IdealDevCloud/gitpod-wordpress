# Gitpod docker image for WordPress | https://github.com/luizbills/gitpod-wordpress
# License: MIT (c) 2020 Luiz Paulo "Bills"
# Version: 0.8
FROM gitpod/workspace-mysql

### General Settings ###
ENV APACHE_DOCROOT="public"

### Setups, Node, NPM ###
USER gitpod
ADD https://api.wordpress.org/secret-key/1.1/salt?rnd=152634 /dev/null
RUN git clone https://github.com/luizbills/gitpod-wordpress $HOME/gitpod-wordpress && \
	cat $HOME/gitpod-wordpress/conf/.bashrc.sh >> $HOME/.bashrc && \
	# . $HOME/.bashrc && \
	bash -c ". .nvm/nvm.sh && nvm install --lts"

### MailHog ###
USER root
ARG DEBIAN_FRONTEND=noninteractive
RUN go get github.com/mailhog/MailHog && \
	go get github.com/mailhog/mhsendmail && \
	cp $GOPATH/bin/MailHog /usr/local/bin/mailhog && \
	cp $GOPATH/bin/mhsendmail /usr/local/bin/mhsendmail && \
	ln $GOPATH/bin/mhsendmail /usr/sbin/sendmail && \
	ln $GOPATH/bin/mhsendmail /usr/bin/mail && \
	### Apache ###
	apt-get update && \
	apt-get -qy install \
	php-xdebug && \
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* && \
	PHP_VERSION=$(php -v | cut -c 5-7 | sed '2,5d') && \
	cat /home/gitpod/gitpod-wordpress/conf/php.ini >> /etc/php/${PHP_VERSION}/apache2/php.ini && \
	### WP-CLI ###
	wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O $HOME/wp-cli.phar && \
	chmod +x $HOME/wp-cli.phar && \
	mv $HOME/wp-cli.phar /usr/local/bin/wp && \
	chown gitpod:gitpod /usr/local/bin/wp

USER gitpod

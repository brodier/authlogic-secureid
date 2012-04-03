#
# Makefile for rpam
#

all: ext/RpamSecureID/Makefile
	(cd ext/RpamSecureID; make)

ext/RpamSecureID/Makefile: ext/RpamSecureID/extconf.rb
	(cd ext/RpamSecureID; ruby extconf.rb)

install: all
	(cd ext/RpamSecureID; make install)
	install -c -m 0644 rpam.pam $(DESTDIR)/etc/pam.d/rpam

uninstall:
	rm -f $(shell ruby -r rbconfig -e "print Config::CONFIG['vendorarchdir']")/rpam_secureid.so
	rm -f $(DESTDIR)/etc/pam.d/rpam

doc: ext/RpamSecureID/Makefile
	(cd ext/Rpam; rdoc --all --line-numbers --charset=UTF-8 --fmt=html -p --inline-source --op=rdoc)

test: all
	(cd test; make)

clean:
	(cd ext/RpamSecureID; make clean || exit 0)
	(cd test; make clean || exit 0)
	
distclean: clean
	rm -f *~
	rm -f ext/RpamSecureID/*~
	rm -f ext/RpamSecureID/*o
	rm -rf ext/RpamSecureID/rdoc
	rm -f ext/RpamSecureID/Makefile

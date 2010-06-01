##
## The neurospaces project : modeling tools for computational
## neuroscience.
##

##############################################################################
##'
##' The neurospaces project
##'
##' Copyright (C) 2007-2008 Hugo Cornelis
##'
##' Hugo Cornelis, hugo.cornelis@gmail.com
##'
##############################################################################


SUBDIRS = perl

dist_bin_SCRIPTS = \
	bin/neurospaces_exchange

exchangetestdir=$(prefix)/exchange
nobase_dist_exchangetest_DATA=@TEST_SPECIFICATION_FILES@

RELEASE_MAJOR=`release-extract --major`
RELEASE_MINOR=`release-extract --minor`
RELEASE_MICRO=`release-extract --micro`

clean-local:
	$(RM) -rf $(top_srcdir)/docs/html
	$(RM) -rf $(top_srcdir)/tests/html
	$(RM) -rf $(top_srcdir)/*.deb
	$(RM) -rf $(top_srcdir)/*.dsc
	$(RM) -rf $(top_srcdir)/*.changes
	$(RM) -f $(top_srcdir)/build_debian.log
	$(RM) -f exchange*.tar.gz
	$(RM) -rf RPM_BUILD/
	$(RM) -f build_rpm.log

show-release-labels:
	echo "Release information (major-minor-micro): $(RELEASE_MAJOR).$(RELEASE_MINOR)-$(RELEASE_MICRO)"

dist-keywords:
	release-expand exchange $(RELEASE_MAJOR) $(RELEASE_MINOR) $(RELEASE_MICRO) $(RELEASE_MAJOR).$(RELEASE_MINOR) hugo.cornelis@gmail.com --verbose
#	release-expand exchange des 10 0 des-10 hugo.cornelis@gmail.com --verbose

am__tar = ${AMTAR} chf - --format=posix "$$tardir"

dist-hook: 
#	cd $(srcdir) && if test -n "`mtn ls changed `" ; then false ; else true ; fi
	find $(distdir) -name _Inline -exec chmod u+w -R \{\} \;
	$(RM) -fr `find $(distdir) -name _Inline`
	cp $(srcdir)/license.txt $(distdir)
#	cp -R $(srcdir)/docs $(distdir)
	$(srcdir)/install-sh -d $(distdir)/tests
	$(srcdir)/install-sh -d $(distdir)/tests/html
	cp -pR $(srcdir)/tests/command_extractor $(distdir)/tests
	cp -pR $(srcdir)/tests/command_extractor.ptkdb $(distdir)/tests
	cp -pR $(srcdir)/tests/tests_2_html $(distdir)/tests
	cp -pR $(srcdir)/tests/tests_2_html.ptkdb $(distdir)/tests
	cp -pR $(srcdir)/tests/tests.config $(distdir)/tests
	cp -pR $(srcdir)/tests.config $(distdir)
	( cd $(distdir)/tests && chmod -R u+w . && ./tests_2_html --introduction introduction.html )

html-upload-prepare:
	rm -fr html/htdocs/neurospaces_project/exchange
	mkdir -p html/htdocs/neurospaces_project/exchange
# $Format: "	( cd tests && ./tests_2_html --header '<img src=\"ns-main-logo-dark2-notext-32x32.jpg\" alt=\"Main Neurospaces logo\"> ${package}, ${label}, ${email} <hr>' --introduction introduction.html )" $
	( cd tests && ./tests_2_html --header '<img src="ns-main-logo-dark2-notext-32x32.jpg" alt="Main Neurospaces logo"> neurospaces 0.1675 Thu, 27 Dec 2007 15:58:18 -0600 hugo<hr>' --introduction introduction.html )
	tar cfh - tests/html | ( cd html/htdocs/neurospaces_project/exchange && tar vxf - )

#t perhaps also add a target to check the syntax of all the html ?

html-upload: html-upload-prepare
	scp -pr html/htdocs/* hcornelis,neurospaces@web.sourceforge.net:/home/groups/n/ne/neurospaces/htdocs/

test: check

docs-level1:

docs-level2:

docs-level3: html-upload-prepare
	echo "Converted the regression tests to HTML"

docs-level4:

docs-level5:

docs-level6:

docs-level7:

docs: docs-level1 docs-level2 docs-level3 docs-level4 docs-level5 docs-level6 docs-level7

TESTS = /usr/local/bin/neurospaces_harness

#-------------------------------------------------------
# Packaging
# the pkg-src target must create pkg/$(APP_NAME)-$(VERSION).tar.gz
TMP_DIR = tmp

pkg-src: dist
	mkdir -p pkg
	cp $(PACKAGE)-$(VERSION).tar.gz pkg/$(PACKAGE)-$(VERSION).tar.gz

# Create a deb package
pkg-deb: pkg-src
	nspkg-deb $(TMP_DIR) $(PACKAGE) $(VERSION)

pkg-rpm: dist
	nspkg-rpm $(PACKAGE) $(VERSION)

#--- end packaging --------------------------------------
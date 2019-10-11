#
# The Qubes OS Project, http://www.qubes-os.org
#
# Copyright (C) 2011  Marek Marczykowski <marmarek@invisiblethingslab.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
#

RPMS_DIR=rpm/
VERSION := $(shell cat version)

help:
	@echo "Qubes addons main Makefile:" ;\
	    echo "make rpms                 <--- make all rpms and sign them";\
	    echo; \
	    echo "make clean                <--- clean all the binary files";\
	    echo "make update-repo-current  <-- copy newly generated rpms to qubes yum repo";\
	    echo "make update-repo-current-testing <-- same, but for -current-testing repo";\
	    echo "make update-repo-unstable <-- same, but to -testing repo";\
	    echo "make update-repo-installer -- copy dom0 rpms to installer repo"
	    @exit 0;

rpms: rpms-vm

rpms-dom0:

rpms-vm:
	rpmbuild --define "_rpmdir rpm/" -bb rpm_spec/3isec-tor.spec
	rpm --addsign rpm/x86_64/3isec-tor-*$(VERSION)*.rpm

clean:

update-repo-current:
	for vmrepo in ../yum/current-release/current/vm/* ; do \
		dist=$$(basename $$vmrepo) ;\
		ln -f $(RPMS_DIR)/x86_64/3isec-tor-*$(VERSION)*$$dist*.rpm $$vmrepo/rpm/ ;\
	done

update-repo-current-testing:
	for vmrepo in ../yum/current-release/current-testing/vm/* ; do \
		dist=$$(basename $$vmrepo) ;\
		ln -f $(RPMS_DIR)/x86_64/3isec-tor-*$(VERSION)*$$dist*.rpm $$vmrepo/rpm/ ;\
	done

update-repo-unstable:
	for vmrepo in ../yum/current-release/unstable/vm/* ; do \
		dist=$$(basename $$vmrepo) ;\
		ln -f $(RPMS_DIR)/x86_64/3isec-tor-*$(VERSION)*$$dist*.rpm $$vmrepo/rpm/ ;\
	done

install-common:
	install -D start_tor_proxy.sh $(DESTDIR)/usr/lib/3isec-tor/start_tor_proxy.sh
	install -D torrc.tpl $(DESTDIR)/usr/lib/3isec-tor/torrc.tpl
	install -D filter.nft $(DESTDIR)/usr/lib/3isec-tor/nft/filter.nft
	install -D nat.nft $(DESTDIR)/usr/lib/3isec-tor/nft/nat.nft
	install -D watch_fw.sh $(DESTDIR)/usr/lib/3isec-tor/nft/watch_fw.sh
	install -D update_nat.awk $(DESTDIR)/usr/lib/3isec-tor/nft/update_nat.awk
	install -D update_ruleset.awk $(DESTDIR)/usr/lib/3isec-tor/nft/update_ruleset.awk
	install -D update_nft.sh $(DESTDIR)/usr/lib/3isec-tor/nft/update_nft.sh
	install -D README.md $(DESTDIR)/usr/lib/3isec-tor/README
	install -D 99-3isec-tor-hook.rules $(DESTDIR)/etc/udev/rules.d/99-3isec-tor-hook.rules
	install -D 3isec-tor.service $(DESTDIR)/lib/systemd/system/3isec-tor.service 

install-rh: install-common
	install -D torproject.repo $(DESTDIR)/etc/yum.repos.d/torproject.repo
	install -D RPM-GPG-KEY-torproject.org.asc $(DESTDIR)/etc/pki/rpm-gpg/RPM-GPG-KEY-torproject.org.asc

install-deb: install-common
	install -D torproject.list $(DESTDIR)/etc/apt/sources.lists.d/torproject.list
	install -D torprojectarchive.asc $(DESTDIR)/usr/lib/3isec-tor/torprojectarchive.asc

%define _topdir	 	~/nerospaces_project/developer/source/snapshots/0
%define _bindir		/usr/local/bin
%define _mandir		/usr/local/share/man/man1
%define name		developer
%define release		1
%define version 	alpha.1
%define buildroot 	%{_topdir}/%{name}-%{version}-root

BuildRoot:		%{buildroot}
Summary: 		Neurospaces Developer Package
License: 		GPL
Name: 			%{name}
Version: 		%{version}
Release: 		%{release}
Source: 		%{name}-%{version}.tar.gz
Prefix: 		/usr/local
Group: 			Science
Vendor: 		Hugo Cornelis <hugo.cornelis@gmail.com>
Packager: 		Mando Rodriguez <mandorodriguez@gmail.com>
URL:			http://www.neurospaces.org

%description
The Neurospaces developer package contains essential tools for Neurospaces development. 
 The Neurospaces project develops software components of neuronal
 simulator that integrate in a just-in-time manner for the
 exploration, simulation and validation of accurate neuronal models.
 Neurospaces spans the range from single molecules to subcellular
 networks, over single cells to neuronal networks.  Neurospaces is
 backwards-compatible with the GENESIS simulator, integrates with
 Python and Perl, separates models from experimental protocols, and
 reads model definitions from declarative specifications in a variety
 of formats.
 This package contains utilities requires for Neurospaces development.

%prep
echo %_target
echo %_target_alias
echo %_target_cpu
echo %_target_os
echo %_target_vendor
%setup -q

%build
./configure --prefix=$RPM_BUILD_ROOT/usr/local
make

%install
rm -rf $RPM_BUILD_ROOT
mkdir $RPM_BUILD_ROOT/usr/local/bin
mkdir $RPM_BUILD_ROOT/usr/local/share/man/man1
make install prefix=$RPM_BUILD_ROOT/usr/local

%clean
rm -rf %{buildroot}

# listing a directory name under files will include all files in the directory.
%files
%defattr(0755,root,root) bin

%doc %attr(0444,root,root) docs
#%doc %attr(0444,root,root) /usr/local/share/man/man1/wget.1
# need to put whatever docs to link to here.

%changelog
* Mon Apr  5 2010 Mando Rodriguez <mandorodriguez@gmail.com> - 
- Initial build.


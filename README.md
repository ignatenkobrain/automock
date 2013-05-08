automock
========
Build with mock at one command
Requirements to use automock:
1. .spec file and source files;
2. Source files should be in the same directory as the .spec file in the folder SOURCES;
3. Installed mock.
Example tree:
.
|-- control-center.spec
`-- SOURCES
    |-- distro-logo.patch
    `-- gnome-control-center-3.8.1.5.tar.xz
How to use automock:
As user:
/path/to/automock.sh /path/to/spec version_of_fedora
Example to build control-center to Fedora 19:
/home/brain/git/automock/automock.sh ~/rpmbuild/SPECS/control-center.spec 19

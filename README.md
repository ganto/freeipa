freeipa
=======

Inofficial Gentoo Overlay for FreeIPA and related ebuilds
---------------------------------------------------------

This Gentoo overlay should act as a brewery for FreeIPA related ebuilds. It contains ebuild for the following applications and libraries:

* **app-admin/authconfig** (6.2.4) - Tool for setting up authentication from network services
* **app-admin/freeipa** (2.2.1) - The Identity, Policy and Audit system
* **app-crypt/certmonger** (0.61) - D-Bus -based service to simplify interaction with certificate authorities
* **dev-java/osutil** (2.0.2) - Operating System Utilities JNI Package
* **dev-python/python-krbV** (1.0.90) - Python extension module for Kerberos 5
* **net-nds/389-ds-base** (1.2.11.15) - 389 Directory Server (core librares and daemons)

So far, the FreeIPA ebuild is able to successfully configure a Gentoo box as nearly fully-featured IPA client. For server support a lot more ebuilds of dependencies are required to be written yet. Any help is appreciated.

### ATTENTION: This overlay is highly experimental. Don’t use it on your workstation if you are not familiar with FreeIPA and its technologies. It might break your system login. I don’t take any responsibility if you blow up your machine. You have been warned!

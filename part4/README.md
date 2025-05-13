# To reproduce CVE-2024-25062
This bug is described in:
- https://www.cve.org/CVERecord?id=CVE-2024-25062
- https://gitlab.gnome.org/GNOME/libxml2/-/issues/604


To reproduce the bug the reproduce bug script:

**Make sure that docker is installed in your machine before running this script.**
```sh
./reproduce_bug.sh
```

or just run the following commands:
```sh
docker build --tag libxml2-cve-2024-25062 .
docker run -t libxml2-cve-2024-25062
```
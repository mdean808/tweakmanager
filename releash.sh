export DEBUG=0
make package
yes | cp -rf packages/`ls -Art packages/ | tail -n 1` ../../repo/debs/xyz.mogdan.tweakmanager.deb
dpkg-scanpackages -m ../../repo/debs/xyz.mogdan.tweakmanager.deb

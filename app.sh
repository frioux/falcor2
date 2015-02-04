#!/bin/dash

cd /opt/app

exec 2>&1 sudo -Eu app \
   carton exec \
   perl -Ilib bin/falcor2.pl

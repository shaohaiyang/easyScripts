#!/bin/sh
sed -r -e '/---/{n;}' -e 's#.*up (.*)(days|min).*#\1#g' a

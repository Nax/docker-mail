#!/bin/sh

exec /usr/local/bin/spamc -U /var/run/spamd/spamd.sock -u vmail -L spam

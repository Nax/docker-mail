require ["vnd.dovecot.pipe", "copy", "imapsieve", "environment", "variables", "fileinto", "mailbox", "imap4flags"];

if environment :matches "imap.mailbox" "*" {
  set "mailbox" "${1}";
}

if string "${mailbox}" "Trash" {
  stop;
}

if environment :matches "imap.user" "*" {
  set "username" "${1}";
}

removeflag "$Junk";
addflag "$NotJunk";
pipe :copy "learn-ham.sh" [ "${username}" ];

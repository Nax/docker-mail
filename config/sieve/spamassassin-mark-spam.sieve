require ["vnd.dovecot.pipe", "copy", "imapsieve", "environment", "variables", "fileinto", "mailbox", "imap4flags"];

if environment :matches "imap.user" "*" {
  set "username" "${1}";
}

removeflag "$NotJunk";
addflag "$Junk";
pipe :copy "learn-spam.sh" [ "${username}" ];

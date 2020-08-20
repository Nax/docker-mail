require ["fileinto", "mailbox", "imap4flags"];

if header :contains "X-Spam-Flag" "YES" {
    addflag "$Junk";
    fileinto :create "Spam";
}

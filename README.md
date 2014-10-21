==== Description

Responsible for uploading recordings marked for upload to a server
via secure FTP. After uploading the recording the database will be
changed so that the file is no longer marked for upload.

==== Installation 

Any rack based application server should be compatible. A passenger based
example would be :

    Alias /uploader_service /var/sunra/services/uploader-service/public
    <Location /uploader_service>
        PassengerBaseURI /uploader_service
        PassengerAppRoot /var/sunra/services/uploader-service
        PassengerRuby /usr/bin/ruby
    </Location>
    <Directory /var/sunra/services/uploader-service/public>
        Allow from all
        Options -MultiViews
        Require all granted
    </Directory>
 
==== Timed upload

Add a cron entry to run this at a given time e.g.

0 1 * * * /usr/bin/wget http://localhost/uploader_service/manual_start

==== TODO

- Stop/Abort does not work
- log complete runs and individual file uploads. Important for auditing.
- secure via api-key. although not particularly vulnerable it does expose
  some information via the status information. 

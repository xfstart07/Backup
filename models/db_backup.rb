# encoding: utf-8
require 'backup2qiniu'
require 'figaro'

Figaro.application = Figaro::Application.new(environment: "production", path: "config/application.yml")
Figaro.load

Model.new(:db_backup, 'Description for DB backup') do
  split_into_chunks_of 250

  database MySQL do |db|
    db.name               = Figaro.env.db_name
    db.username           = Figaro.env.db_username
    db.password           = Figaro.env.db_password
    db.host               = "localhost"
    db.port               = 3306
    db.socket             = "/tmp/mysql.sock"
    # db.socket             = "/var/run/mysqld/mysqld.sock"
  end

  store_with Local do |local|
    local.path = '~/Backup/'
    # Use a number or a Time object to specify how many backups to keep.
    local.keep = 5
  end

  store_with Qiniu do |q|
    ## when using uploadToken, you can not delete the old backup (for security concern)
    q.keep = 7
    q.access_key = Figaro.env.qiniu_ak
    q.access_secret = Figaro.env.qiniu_sk
    q.bucket = Figaro.env.bucket
  end

  ##
  # Gzip [Compressor]
  #
  compress_with Gzip

end

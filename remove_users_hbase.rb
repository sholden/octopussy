["disable 'users'", "drop 'users'", "create 'users', {NAME => 'data'}", "enable 'users'"].each {|cmd|
  `echo "#{cmd}" | hbase shell`
}

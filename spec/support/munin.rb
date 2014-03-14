FileUtils.cp_r "public/images/munin", "tmp", :preserve => true
Monitoring.munin_resources_directory = "tmp/munin"

task :dbinit do
    sh 'sudo docker run -p 5984:5984 -d --name cs588couchdb couchdb:2.3.1'
    puts "Sleeping to let CouchDB spin up..."
    sleep(10)
    sh 'curl -X PUT http://localhost:5984/_global_changes'
    sh 'curl -X PUT http://localhost:5984/_replicator'
    sh 'curl -X PUT http://localhost:5984/_users'
end

task :start do
    sh 'sudo docker start cs588couchdb'
end

task :load do
    sh 'curl -X DELETE http://localhost:5984/bounty'
    sh 'curl -X PUT http://localhost:5984/bounty'
    ruby './load_events_and_event_pages anonymized.sqlite3'
    ruby './load_needs anonymized.sqlite3'
end

task :stop do
    sh 'sudo docker stop cs588couchdb'
end

task :clean do
    Rake::Task["stop"].invoke
    sh 'sudo docker rm cs588couchdb'
end

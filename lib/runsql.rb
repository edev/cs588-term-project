def runsql(db, filename, header=nil, tabs=2)
    puts header unless header.nil?
    puts "\t" * tabs + "Read SQL from disk (#{filename})"
    sql = File.read(filename)
    puts "\t" * tabs + "Execute SQL"
    db.execute sql
end


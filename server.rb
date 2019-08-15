require "sqlite3"
require "rack"
require "erb"

class Server
  def initialize
    @tpl = File.read("./index.erb")
    @db = SQLite3::Database.new("./database.db")
    @db.execute("CREATE TABLE IF NOT EXISTS numbers (id INTEGER PRIMARY KEY, number INTEGER);")
  end

  def call(env)
    req = Rack::Request.new(env)
    res = Rack::Response.new

    unless req.params.empty?
        if req.params.key? "insert"
            number = req.params["insert"].to_i
            @db.execute("INSERT INTO numbers (number) VALUES (?);", number)
        end
        if req.params.key? "update"
            id = req.params["update"].to_i
            @db.execute("UPDATE numbers SET number = number + 1 WHERE id IS ?;", id)
            @db.execute("SELECT * FROM numbers WHERE id IS ?;", id) do |row|
                if row[1] > 15
                    @db.execute("DELETE FROM numbers WHERE id IS ?;", id)
                end
            end
        end
    end

    res.write ERB.new(@tpl).result(binding)
    res.finish
  end
end

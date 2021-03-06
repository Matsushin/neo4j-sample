
Neography.configure do |config|
  config.server         = ENV["GRAPHENEDB_BOLT_SERVER"] || "localhost"
  config.port           = ENV["GRAPHENEDB_PORT"] || "7474"
  config.directory      = ""  # prefix this path with '/'
  config.cypher_path    = "/cypher"
  config.gremlin_path   = "/ext/GremlinPlugin/graphdb/execute_script"
  config.log_file       = "neography.log"
  config.log_enabled    = false
  config.max_threads    = 20
  config.authentication = 'basic'  # 'basic' or 'digest'
  config.username       = ENV["GRAPHENEDB_BOLT_USER"] || 'neo4j'
  config.password       = ENV["GRAPHENEDB_BOLT_PASSWORD"] || 'password'
  config.parser         = MultiJsonParser
end

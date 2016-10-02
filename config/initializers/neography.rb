
Neography.configure do |config|
  config.server         = "hobby-cagbfjhcfnhggbkecdimgfnl.dbs.graphenedb.com" || "localhost" # ENV["GRAPHENEDB_BOLT_SERVER"]
  config.port           = 24789 || "7474" # ENV["GRAPHENEDB_PORT"]
  config.directory      = ""  # prefix this path with '/'
  config.cypher_path    = "/cypher"
  config.gremlin_path   = "/ext/GremlinPlugin/graphdb/execute_script"
  config.log_file       = "neography.log"
  config.log_enabled    = false
  config.max_threads    = 20
  config.authentication = 'basic'  # 'basic' or 'digest'
  config.username       = "app57363794-nzRyWS" || 'neo4j' # ENV["GRAPHENEDB_BOLT_USER"]
  config.password       = "oMzcwUeW340J81SuDN1F" || 'password' # ENV["GRAPHENEDB_BOLT_PASSWORD"]
  config.parser         = MultiJsonParser
end

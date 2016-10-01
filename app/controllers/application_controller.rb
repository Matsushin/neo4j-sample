class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def set_neography
    @neo = Neography::Rest.new({
                                 authentication: 'basic',
                                 username: "neo4j",
                                 password: "password"
                               })
  end
end

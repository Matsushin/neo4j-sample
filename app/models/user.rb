class User < ApplicationRecord
  has_many :user_follows, class_name: 'Friendship', foreign_key: :user_id
  has_many :follows, through: :user_follows
  has_many :user_followers, class_name: 'Friendship', foreign_key: :friend_id
  has_many :followers, through: :user_followers

  acts_as_birthday :date_of_birth

  after_create :create_node
  after_update :update_node


  def create_node
    connect_neo4j
    user_node = Neography::Node.create({ user_id: id, name: name, age: date_of_birth_age })
    @neo.add_label(user_node, 'User')
    user_node.add_to_index('user_index', 'user_id', id)
    create_relationship(user_node)
  end

  def update_node
    connect_neo4j
    user_node = Neography::Node.find('user_index', 'user_id', id)
    @neo.set_node_properties(user_node, { age: date_of_birth_age} ) if date_of_birth_changed?
    user_node.rels(:KNOWS).outgoing.each { |relation| relation.del } # リレーション全削除
    create_relationship(user_node)
  end

  def friend_of_friend
    connect_neo4j
    user_node = Neography::Node.find('user_index', 'user_id', id)
    user_node
      .outgoing(:KNOWS)
      .depth(2)
      .uniqueness(:nodeglobal)
      .filter("position.length() == 2;")
      .map do |n|
        User.find(n[:user_id]) unless friend_ids.include?(n[:user_id])
       end.compact
  end

  def friend_ids
    follows.pluck(:id)
  end

  private

  def create_relationship(user_node)
    follow_ids.each do |follow_id|
      friend_node = Neography::Node.find('user_index', 'user_id', follow_id)
      user_node.outgoing(:KNOWS) << friend_node
    end
  end

  def connect_neo4j
    @neo = Neography::Rest.new({
                                authentication: 'basic',
                                username: 'neo4j',
                                password: 'password'
                              })
  end
end

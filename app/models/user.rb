class User < ApplicationRecord
  has_many :user_follows, class_name: 'Friendship', foreign_key: :user_id
  has_many :follows, through: :user_follows
  has_many :user_followers, class_name: 'Friendship', foreign_key: :friend_id
  has_many :followers, through: :user_followers

  acts_as_birthday :date_of_birth

  after_create :create_node
  after_update :update_node
  after_destroy :destroy_node

  def create_node
    user_node = Neography::Node.create({ user_id: id, name: name, age: date_of_birth_age }) # ノード追加
    neo4j_connect.add_label(user_node, 'User')  # ラベル追加
    user_node.add_to_index('user_index', 'user_id', id) # 検索用にインデックス追加
    create_relationship(user_node)
  end

  def update_node
    user_node = user_node(id)
    user_node[:name] = name if name_changed?
    user_node[:age] = date_of_birth_age if date_of_birth_changed?
    user_node.rels(:FRIEND).outgoing.each { |relation| relation.del } # リレーション全削除
    create_relationship(user_node)
  end

  def destroy_node
    user_node = user_node(id)
    user_node.rels(:FRIEND).outgoing.each { |relation| relation.del } # リレーション全削除
    user_node.del # ノード削除
  end

  def friend_of_friend
    user_node = user_node(id)
    users = User.hash_by_id
    user_node
      .outgoing(:FRIEND)
      .depth(2)
      .uniqueness(:nodeglobal)
      .filter("position.length() == 2;")
      .map do |n|
        users[n[:user_id]] unless friend_ids.include?(n[:user_id])
       end.compact
  end

  def user_node(id)
    # ノード検索
    Neography::Node.find('user_index', 'user_id', id)
  end

  def friend_ids
    follows.pluck(:id)
  end

  def self.hash_by_id
    users = {}
    User.order(:id).each { |user| users[user.id] = user }
    users
  end

  private

  def create_relationship(user_node)
    follow_ids.each do |follow_id|
      friend_node = Neography::Node.find('user_index', 'user_id', follow_id)
      user_node.outgoing(:FRIEND) << friend_node
    end
  end

  def neo4j_connect
    url = ENV['GRAPHENEDB_URL'] || 'http://neo4j:password@localhost:7474'
    Neography::Rest.new(url)
  end
end

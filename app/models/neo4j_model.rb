class Neo4jModel
  def self.constract_any_nodes_and_relations
    @neo = Neography::Rest.new({
                                 authentication: 'basic',
                                 username: "neo4j",
                                 password: "neo4j"
                               })

    User.select('id, birthday').find_each do |user|
      # 以下でuserのnode構築
      user_node = Neography::Node.create({ user_id: user.id, age: user.age })
      @neo.add_label(user_node, "User")
      user_node.add_to_index("user_index", "user_id", user.id)

      # リレーション構築(応募)
      user.applies.each do |apply|
        job_id   = apply.job_id
        job_node = first_or_create_for_job_offer_node(job_id)
        user_node.outgoing(:apply) << job_node
        if job_apply.passed?
          # 通過している場合にはjobからもリレーションを構築
          job_node.outgoing(:pass) << user_node
        end
      end

      # リレーション構築(気になる)
      user.favorites.each do |favorite|
        job_id   = favorite.job_id
        job_node = first_or_create_for_job_offer_node(job_id)
        if favorite.only_user?
          user_node.outgoing(:favorite) << job_node
        elsif favorite.only_client?
          user_node.incoming(:favorite) << job_node
        else
          user_node.both(:favorite) << job_node
        end
      end

      # リレーション構築(閲覧)
      user.footprints.each do |footprint|
        job_id   = footprint.job_id
        job_node = first_or_create_for_job_offer_node(job_id)
        user_node.outgoing(:footprint) << job_node
      end
    end
  end

  private

  def self.first_or_create_for_job_node(job_id)
    job_node = Neography::Node.find("job_index", "job_id", job_id)
    if job_node.blank?
      # node構築
      job_node = Neography::Node.create(job_id: job_id)
      @neo.add_label(job_node, "Job")
      job_node.add_to_index("job_index", "job_id", job_id)
    end
    job_node
  end
end

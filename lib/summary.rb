class Summary


  CONTRO_LIMIT = 4.freeze

  def self.calculate
    summaries = {}
    Ack.all.each do |ack|
      summary = summaries[ack.external_uid]
      unless summary
        summary = summaries[ack.external_uid] = Summary.new(:external_uid => ack.external_uid)
      end
      summary.apply_score! ack.score
    end
    summaries.each_pair do |external_uid, summary|
      $redis.set external_uid, summary.to_json
    end
  end

  #TODO: make it save to redis without gradually loosing sync
  def apply_score!(score)
    self.total_ack_count += 1
    if score > 0
      self.positive_ack_count += 1
    elsif score < 0
      self.negative_ack_count += 1
    else
      self.neutral_ack_count += 1
    end
    self.positive_score += score if score > 0
    self.negative_score -= score if score < 0
    self.controversiality = self.calculate_controversiality
  end

  #TODO: make it save to redis without gradually loosing sync
  def rollback_score!(score)
    self.total_ack_count -= 1
    if score > 0
      self.positive_ack_count -= 1
    elsif score < 0
      self.negative_ack_count -= 1
    else
      self.neutral_ack_count -= 1
    end
    self.positive_score -= score if score > 0
    self.negative_score += score if score < 0
    self.controversiality = self.calculate_controversiality
  end

  def calculate_controversiality
    contro = nil
    if self.positive_ack_count + self.negative_ack_count > Summary::CONTRO_LIMIT
      values = [self.positive_ack_count.to_f, self.negative_ack_count.to_f]
      contro = values.min / values.max
    end
    contro
  end

  def acks
    Ack.find_all_by_external_uid(self.external_uid)
  end


  # Redis ActiveRecord look-a-likes, maybe refactor these out later
  def self.find_by_external_uid(external_uid)
    redis_result = $redis.get external_uid
    if redis_result
      Summary.new(JSON.parse(redis_result)['summary'])
    else
      nil
    end  
  end

  def self.find_or_create_by_external_uid(external_uid)
    summary = Summary.find_by_external_uid(external_uid)
    unless summary
      summary = Summary.create!(:external_uid => external_uid)
    end
    summary
  end

  def self.create!(options)
    return nil unless options && options["external_uid"]
    summary = Summary.new(options)
    $redis.set options["external_uid"], summary.to_json
    summary
  end

end

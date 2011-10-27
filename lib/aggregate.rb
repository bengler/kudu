class Aggregate

  def initialize(values)
    @values = values
  end

  def score
    @values.inject(0) do |sum, entry|
      sum += entry[:value] * entry[:tally]
    end
  end

  def count(value)
    @values.each do |entry|
      return entry[:tally] if entry[:value] == value
    end
  end

  def neutral
    count(0)
  end

  def positive
    count(1)
  end

  def negative
    count(-1)
  end

  def controversiality
    if negative == 0 && positive == 0
      0
    else
      smallest, largest = [negative.to_f, positive.to_f].sort
      smallest / largest
    end
  end

end

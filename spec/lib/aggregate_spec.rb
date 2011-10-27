require 'aggregate'
def summarize(negative, neutral, positive)
  [
    {:value => -1, :tally => negative},
    {:value => 0, :tally => neutral},
    {:value => 1, :tally => positive}
  ]
end

describe Aggregate do

  describe "basic scoring" do
    let(:summary) {
      [
        {:value => -1, :tally => 10},
        {:value => 0, :tally => 40},
        {:value => 1, :tally => 17}
      ]
    }

    subject { Aggregate.new(summary) }

    its(:score) { should eq(7) }
    its(:negative) { should eq(10) }
    its(:positive) { should eq(17) }
    its(:neutral) { should eq(40) }
  end

  describe "controversiality" do
    it "is nil. Truly, nobody cares" do
      summary = summarize(0, 100, 0)
      Aggregate.new(summary).controversiality.should eq(0)
    end

    it "is complete. Can't get worse more exciting than this!" do
      summary = summarize(50, 0, 50)
      Aggregate.new(summary).controversiality.should eq(1)
    end

    xit "is low, overwhelmingly positive response" do
      summary = summarize(5, 5, 90)
      Aggregate.new(summary).controversiality.should eq(:something_small)
    end

    xit "is low, overwhelmingly negative response" do
      summary = summarize(90, 5, 5)
      Aggregate.new(summary).controversiality.should eq(:something_small)
    end

    xit "is low, meh across the board" do
      summary = summarize(5, 90, 5)
      Aggregate.new(summary).controversiality.should eq(:something_small)
    end

    xit "is very controversial, with a slight positive slant" do
      summary = summarize(40, 10, 50)
      Aggregate.new(summary).controversiality.should eq(:something_big)
    end

    xit "is very controversial, with a slight negative slant" do
      summary = summarize(50, 10, 40)
      Aggregate.new(summary).controversiality.should eq(:something_big)
    end

    xit "is pretty controversial, with an even spread" do
      summary = summarize(40, 20, 40)
      Aggregate.new(summary).controversiality.should eq(:something_pretty_big)
    end
  end
end

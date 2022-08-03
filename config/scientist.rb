module Scientist::Experiment
  def self.new(name)
    case name
    when "test-fibonaci-series"
      MyExperiment.new(name: name)
    end
  end
end

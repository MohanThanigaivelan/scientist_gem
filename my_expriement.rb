require "scientist/experiment"
require "redis"
require 'statsd-instrument'

$redis = Redis.new
$statsd = StatsD
class MyExperiment
  include Scientist::Experiment

  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def enabled?
    # see "Ramping up experiments" below
    true
  end

  def raised(operation, error)
    # see "In a Scientist callback" below
    p "Operation '#{operation}' failed with error '#{error.inspect}'"
    super # will re-raise
  end

  def publish(result)
    # see "Publishing results" below
    p result.control.duration
    p result.candidates.first.duration
    p result.context
    if result.matched?
      $statsd.increment "science.#{name}.matched"
    else
      $statsd.increment "science.#{name}.mismatched"
      store_mismatch_data(result)
    end

    # p result
  end

  def store_mismatch_data(result)
    payload = {
      :name            => name,
      :context         => context,
      :control         => observation_payload(result.control),
      :candidate       => observation_payload(result.candidates.first),
      :execution_order => result.observations.map(&:name)
    }

    key = "science.#{name}.mismatch"
    $redis.lpush key, payload
    $redis.ltrim key, 0, 1000
  end

  def observation_payload(observation)
    if observation.raised?
      {
        :exception => observation.exception.class,
        :message   => observation.exception.message,
        :backtrace => observation.exception.backtrace
      }
    else
      {
        :value => observation.cleaned_value
      }
    end
  end
end

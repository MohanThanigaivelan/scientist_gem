require "scientist"
require "./my_expriement.rb"
require "./config/scientist.rb"
require 'rails'
require 'lab_tech'

class Fibonaci
  include Scientist

  def print_fibonaci_series
    result = science "test-fibonaci-series" do |experiment|
      experiment.context :value => 40
      experiment.before_run do
        p "Hiiiiii"
      end
      experiment.use { old_fibonoci_logic(40) }
      experiment.try { new_finoboci_logic(40) }

      experiment.compare do |control, candidate|
        control.class == candidate.class
      end

      compare_error_message_and_class = ->(control, candidate) do
        p "compare message"
        control.class == candidate.class &&
        control.message == candidate.message
      end

      compare_argument_errors = ->(control, candidate) do
        p "compare argument error"
        control.class == ArgumentError &&
        candidate.class == ArgumentError &&
        control.message.start_with?("Input has invalid characters") &&
        candidate.message.start_with?("Invalid characters in input")
      end

      experiment.compare_errors do |control, candidate|
        p "compare error"
        compare_error_message_and_class.call(control, candidate) ||
        compare_argument_errors.call(control, candidate)
      end
    end

    puts "Final result", result
  end

  def old_fibonoci_logic(number)
    first = 1
    second = 2
    total = first + second
    for i in 2...number
      total = first + second
      first = second
      second = total
    end
    total
  end

  def new_finoboci_logic(number)
    if number == 1
      return 1
    elsif number == 2
      return 2
    end
    new_finoboci_logic(number - 1) + new_finoboci_logic(number - 2)
  end
end

Fibonaci.new.print_fibonaci_series

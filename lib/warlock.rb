require "warlock/version"
require "warlock/commands"
require "thor"

module Warlock
  class Error < StandardError; end
  # Your code goes here...
  class CLI < Thor
    desc "add_src <file_name>", "say <file_name>"
    def add_src(file_name)
      Warlock::Commands.new().add_src(file_name)
    end
  end
end

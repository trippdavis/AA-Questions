require 'singleton'
require 'sqlite3'
require_relative 'qmodel'


class QDB < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.results_as_hash = true
    self.type_translation = true
  end
end

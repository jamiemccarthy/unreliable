# frozen_string_literal: true

class Owner < ActiveRecord::Base
  has_many :cats
end

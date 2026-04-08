# frozen_string_literal: true

class Cat < ActiveRecord::Base
  belongs_to :owner, optional: true
end

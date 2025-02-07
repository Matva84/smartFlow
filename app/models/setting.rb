class Setting < ApplicationRecord
  def self.get(key)
    find_by(key: key)&.value
  end
end

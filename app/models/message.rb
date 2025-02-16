class Message < ApplicationRecord
  belongs_to :user
  belongs_to :messageable, polymorphic: true
end

class Setting < ApplicationRecord
  has_one_attached :file_upload

  def self.get(key)
    find_by(key: key)&.value
  end
  def parsed_value
    case value_type
    when 'boolean'
      ActiveModel::Type::Boolean.new.cast(value)
    when 'float'
      value.to_f
    else
      value
    end
  end
end

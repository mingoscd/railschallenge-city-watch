class Responder < ActiveRecord::Base
  self.inheritance_column = :_type_disabled

  validates :name,     uniqueness: true,
                       presence: true
  validates :capacity, presence: true,
                       inclusion: { in: 1..5 }
  validates :type,     presence: true

  scope :total,             ->(type) { where(type: type) }
  scope :available,         ->(type) { where(type: type, assigned: nil) }
  scope :on_duty,           ->(type) { where(type: type, on_duty: true) }
  scope :available_on_duty, ->(type) { where(type: type, assigned: nil, on_duty: true) }
  scope :capacity_sum,      ->()     { sum(:capacity) }

  def self.types
    %w(Fire Police Medical)
  end

  def self.responders
    responders = Responder.select('name, capacity, lower(type) as type')
                          .where(on_duty: true)
                          .order(capacity: :desc)
    { fire: [], medical: [], police: [] }.merge responders.group_by(&:type).symbolize_keys
  end

  def self.capacity_statistics
    capacity = {}
    types.each { |type| capacity[type] = type_statistics(type) }
    capacity
  end

  def self.type_statistics(type)
    [
      Responder.total(type).capacity_sum,
      Responder.available(type).capacity_sum,
      Responder.on_duty(type).capacity_sum,
      Responder.available_on_duty(type).capacity_sum
    ]
  end
end

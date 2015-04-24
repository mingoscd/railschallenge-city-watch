class Responder < ActiveRecord::Base
  validates :capacity, :name, :type, presence: true
  validates :capacity, inclusion: { within: 1..5 }
  validates :name, uniqueness: true

  self.inheritance_column = :_type_disabled

  def self.responders
    responders = Responder.select('name, capacity, lower(type) as type')
                 .where(on_duty: true)
                 .order(capacity: :desc)

    { fire: [], medical: [], police: [] }.merge responders.group_by(&:type).symbolize_keys
  end

  def self.capacity_statistics
    fire = type_statistics('Fire')
    police = type_statistics('Police')
    medical = type_statistics('Medical')
    { Fire: fire, Police: police, Medical: medical }
  end

  def self.type_statistics(type)
    statistics = [0, 0, 0, 0]
    Responder.where(type: type).find_each do |responder|
      c = responder[:capacity]
      statistics[0] += c
      statistics[1] += c if responder[:assigned].nil?
      statistics[2] += c if responder[:on_duty]
      statistics[3] += c if responder[:assigned].nil? && responder[:on_duty]
    end
    statistics
  end
end

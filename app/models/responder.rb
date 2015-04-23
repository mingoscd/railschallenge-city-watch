class Responder < ActiveRecord::Base
  validates :capacity, :name, :type, presence: true
  validates :capacity, inclusion: { within: 1..5 }
  validates :name, uniqueness: true

  def self.responders
    fire, police, medical = [], [], []

    Responder.where(on_duty: true).order(capacity: :desc).each do |responder|
      responder_object = { name: responder[:name], capacity: responder[:capacity] }
      case responder[:type]
      when 'Fire'
        fire << responder_object
      when 'Police'
        police << responder_object
      when 'Medical'
        medical << responder_object
      end
    end
    { fire: fire, police: police, medical:	medical }
  end

  def self.capacity_statistics
    fire = type_statistics('Fire')
    police = type_statistics('Police')
    medical = type_statistics('Medical')
    JSON[{ Fire: fire, Police: police, Medical: medical }.to_json]
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

  def self.inheritance_column
    nil
  end
end

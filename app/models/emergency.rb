class Emergency < ActiveRecord::Base
  validates :code, presence: true, uniqueness: true
  validates :fire_severity, :police_severity, :medical_severity, presence: true,
                                                                 numericality: { greater_than_or_equal_to: 0 }

  attr_accessor :responders

  def assign_responders(responders)
    fire = choose_responders(fire_severity, responders[:fire])
    police = choose_responders(police_severity, responders[:police])
    medical = choose_responders(medical_severity, responders[:medical])
    @responders = fire + police + medical
    self.served = @full_response_value
  end

  def choose_responders(severity, responders)
    @full_response_value = true if @full_response_value != false
    return [] if severity == 0

    responders.map do |responder|
      return [responder[:name]] if responder[:capacity] == severity
    end
    get_responders_list(severity, responders)
  end

  def get_responders_list(severity, responders)
    result, capacity = [], 0

    responders.map do |responder|
      if responder[:capacity] > severity
        return [responder[:name]]
      else
        result << responder[:name]
        capacity += responder[:capacity]
        return result if capacity >= severity
      end
    end
    @full_response_value = false
    result
  end

  def full_response
    served
  end

  def send_responders
    @responders.each do |responder|
      Responder.find_by(name: responder).update_attribute(:assigned, self[:code])
    end
  end

  def self.responders_back(params)
    if params[:emergency][:resolved_at]
      responders = Responder.where(assigned: params[:id])
      responders.each { |responder| responder.update_attribute(:assigned, nil) }
    end
  end
end

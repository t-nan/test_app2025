class Api::V1::Users::Create < ActiveInteraction::Base

  string :name,
         :patronymic,
         :surname,
         :email,
         :nationality,
         :country,
         :gender,
         :skills, default: nil

  integer :age

  array :interests, default: []

  validates :name, :patronymic, :surname, :email, :nationality, :country, :gender, presence: true
  validates :age, inclusion: { in: 0..90 }
  validates :gender, inclusion: { in: ["male", "female"] }

  def execute
    return if User.where(email: email).present?

    user = User.new(inputs.to_h.compact.without([:interests, :skills]).merge(full_name: user_full_name))
    return user.errors unless user.save

    return unless interests.present?

    interests.each do |interest_type|
      interest = Interest.find_or_create_by(name: interest_type)
      user.interests << interest
    end

    return unless skills.present?

    skills_list.each do |skill|
      skill = Skill.find_or_create_by(name: skill)
      user.skills << skill
    end
  end

  private

  def user_full_name
    "#{surname} #{name} #{patronymic}"
  end

  def skills_list
    skills.split(', ').map(&:strip)
  end
end
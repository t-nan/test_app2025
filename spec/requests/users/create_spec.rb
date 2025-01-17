require 'rails_helper'
require 'faker'

RSpec.describe "Users", type: :request do
  subject { post '/api/v1/users', :params => params.to_json, :headers => { "Content-Type": "application/json" } }

  let(:params) do
    {
      name: Faker::Name.name,
      patronymic: Faker::Name.middle_name,
      surname: Faker::Name.last_name,
      email: Faker::Internet.email,
      nationality: Faker::Address.country,
      country: Faker::Address.country,
      gender: Faker::Gender.binary_type.downcase,
      age: Faker::Number.between(from: 0, to: 90),
      interests: ["reading", "music", "programming"],
      skills: "ruby, python, java"
    }
  end

  context 'success' do
    let(:full_name) { "#{params[:surname]} #{params[:name]} #{params[:patronymic]}" }

    before do
      Interest.create(name: "music")
      Skill.create(name: "ruby")
      subject
    end

    it 'returns success response status' do
      expect(JSON.parse(response.body)).to eq('success' => true)
      expect(response).to have_http_status(:ok)
    end

    it 'increases users count' do
      expect(User.count).to eq(1)
      expect(User.last.attributes.except("id", "created_at", "updated_at"))
        .to eq(params.except(:interests, :skills).merge(full_name: full_name).as_json)
    end

    it 'increases interests count' do
      expect(Interest.count).to eq(3)
      expect(Interest.find_by(name: "reading")).to be_present
      expect(Interest.where(name: "music").count).to eq(1)
    end

    it 'increases skills count' do
      expect(Skill.count).to eq(3)
      expect(Skill.find_by(name: "java")).to be_present
      expect(Skill.where(name: "ruby").count).to eq(1)
    end
  end

  context 'when interests not present' do
    before do
      params.except!(:interests)
      subject
    end

    it 'should not increases interests count' do
      expect(Interest.count).to eq(0)
    end
  end

  context 'when skills not present' do
    before do
      params.except!(:skills)
      subject
    end

    it 'should not increases skills count' do
      expect(Skill.count).to eq(0)
    end
  end

  context 'when incorrect age' do
    before do
      params[:age] = 123
      subject
    end

    it 'return incorrect age error' do
      expect(response).to have_http_status(:unprocessable_entity)

      expect(JSON.parse(response.body)).to eq(
        "errors"=>[{"key"=>"age", "messages"=>["Age is not included in the list"]}],
        "success"=>false
      )
    end
  end

  context 'when incorrect gender' do
    before do
      params[:gender] = '123'
      subject
    end

    it 'return incorrect age error' do
      expect(response).to have_http_status(:unprocessable_entity)

      expect(JSON.parse(response.body)).to eq(
        "errors"=>[{"key"=>"gender", "messages"=>["Gender is not included in the list"]}],
        "success"=>false
      )
    end
  end

  context 'when required param is missing' do
    before do
      params.except!(:surname)
      subject
    end

    it 'return blank surname error' do
      expect(response).to have_http_status(:unprocessable_entity)

      expect(JSON.parse(response.body)).to eq(
        "errors"=>[{"key"=>"surname", "messages"=>["Surname can't be blank"]}],
        "success"=>false
      )
    end
  end
end
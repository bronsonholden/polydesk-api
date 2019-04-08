require 'rails_helper'

RSpec.describe 'Reports', type: :request do
  describe 'GET /rspec/reports' do
    let!(:report) { create :report }
    it 'retrieves all reports' do
      get '/rspec/reports', headers: rspec_session
      expect(response).to have_http_status(200)
      expect(json).to be_array_of('report')
    end
  end

  describe 'POST /rspec/reports' do
    it 'creates new report' do
      params = {
        name: 'RSpec Report'
      }
      post '/rspec/reports', headers: rspec_session, params: params.to_json
      expect(response).to have_http_status(201)
      expect(json).to be_a('report')
    end
  end
end

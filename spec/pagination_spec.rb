require 'rails_helper'

RSpec.describe 'Pagination', type: :request do
  let(:blueprint) { create :blueprint, namespace: 'doodads' }
  let(:count) { 100 }
  let(:offset) { 0 }
  let(:limit) { 25 }
  let(:params) {
    {
      'page[offset]' => offset.to_s,
      'page[limit]' => limit.to_s
    }
  }

  before(:each) do
    count.times {
      create :prefab, blueprint: blueprint, data: { string: 'string' }
    }
  end

  def check_pagination_metadata
    expect(json.fetch('meta').fetch('page-offset')).to eq(offset)
    expect(json.fetch('meta').fetch('page-limit')).to eq(limit)
    expect(json.fetch('meta').fetch('item-count')).to eq(count)
    expect(json.fetch('meta').fetch('total-pages')).to eq((count / limit).ceil)
  end

  def check_paginated_results
    expect(json.fetch('data')).to be_an(Array)
    expect(json.fetch('data').size).to eq(limit)
    expect(json.fetch('data').first.fetch('id').to_i).to eq(offset * limit + 1)
  end

  shared_examples 'paginated_results' do
    it 'returns paginated results' do
      get '/rspec/prefabs/doodads', headers: rspec_session, params: params
      expect(response).to have_http_status(200)
      check_pagination_metadata
      check_paginated_results
    end
  end

  # Using variable values specified above...
  include_examples 'paginated_results'

  context 'with offset' do
    let(:offset) { 1 }
    include_examples 'paginated_results'
  end

  # Should still paginate with default offset and limit of 0 and 25
  # respectively when no page params are specified in the request.
  context 'without pagination params provided' do
    let(:params) { nil }
    include_examples 'paginated_results'
  end
end
